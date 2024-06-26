/**
 * @description       : This class is responsible for handling the batch invitations for Insiders program.
 *                      It contains methods for handling scope, sending emails, cleaning up settings, and updating trackings.
 * @author            : 
 **/
public with sharing class IA_InsidersInvitationBatchHandler {
    public IA_InsidersInvitationBatchHandler() {}
    /**
     * @description This method handles the scope of the batch invitations for Insiders program.
     * It takes a list of WDR_Application__c records, a list of ConfigWrapper objects, and a list of EmailTemplate objects as input.
     * The method iterates through the list of applications, checks if each candidate has a contact, and if so, it retrieves the candidate's contact ID.
     * It then matches the candidate's persona with the provided groups and filters the matching personas.
     * If a matching persona is found, it retrieves the corresponding email template and creates an EmailWrapper object.
     * The EmailWrapper object is then added to a list of emails to be sent.
     * If no matching persona is found, the candidate's application is marked for deletion.
     * After processing all the applications, the method checks if any candidate has a scheduled, rescheduled, or completed Service Appointment within the last 90 days.
     * If so, the candidate's contact ID is added to a set of candidate IDs with Service Appointments.
     * Finally, the method returns a HandleScopeWrapper object containing the list of emails to be sent after SA checks and a map of applications to be deleted.
     * @param scope List of WDR_Application__c records to be processed
     * @param groups List of ConfigWrapper objects containing matching criteria for candidate personas
     * @param templates List of EmailTemplate objects to be used for sending emails
     * @return HandleScopeWrapper object containing the list of emails to be sent after SA checks and a map of applications to be deleted
     */
    public static HandleScopeWrapper handleScope(List<WDR_Application__c> scope, List<IA_InsidersInvitationBatchHelper.ConfigWrapper> groups, List<EmailTemplate> templates) {
        List<EmailWrapper> emailsToBeSent = new List<EmailWrapper>();
        List<EmailWrapper> emailsToBeSentAfterSAChecks = new List<EmailWrapper>();
        Map<Id, Id> defaultToDeleteMap = new Map<Id, Id>();
        List<id> candidateIds = new List<id>();
        Map<String, Boolean> defaultToDelete = new Map<String, Boolean>();
        for (WDR_Application__c app : scope) {
            System.debug('\n<<<< ============================================ ' + app.Id + ' ============================================ >>>>');
            Boolean hasRecipient = app.Candidate__c != null && app.Candidate__r.Candidate_Contact__c != null;
            Id recipient = hasRecipient ? app.Candidate__r.Candidate_Contact__c : null;
            candidateIds.add(app.Candidate__r.Candidate_Contact__c);
            defaultToDeleteMap.put(app.Candidate__r.Candidate_Contact__c,app.id);
            if (recipient != null) {
                List<IA_InsidersInvitationBatchHelper.MatchingWrapper> config = IA_InsidersInvitationBatchHelper.matchPersonaByCriteria(app, groups);
                List<IA_InsidersInvitationBatchHelper.MatchingWrapper> filtred = IA_InsidersInvitationBatchHelper.filterMatchingWrapper(config);
                Boolean hasPersonas = !filtred.isEmpty();
                String template = hasPersonas ? filtred[0].personas[0].template : '';
                EmailTemplate templateObj = null;
                // System.debug('templates: ' + templates.size());
                if (String.isNotBlank(template)) {
                    for (EmailTemplate tmp : templates) {
                        // System.debug('tmp: ' + tmp.DeveloperName + ' : ' + template.trim());
                        templateObj = tmp.DeveloperName == template.trim() ? tmp : templateObj;
                    }
                    if (templateObj != null) {
                        EmailWrapper email = new EmailWrapper(recipient, template, templateObj, app);
                        emailsToBeSent.add(email);
                    }
                } else {
                    defaultToDelete.put(app.id, true);
                }
                // System.debug('config: ' + config);
                // System.debug('filtred: ' + filtred);
                // System.debug('templateObj: ' + templateObj);
                // System.debug('hasPersonas: ' + hasPersonas);
            } else {
                System.debug('<NO CONACT FOUND>');
            }
        }
        // SA check for candidate before sending emails
        Set<Id> candidateIdWithSA = IA_InsidersInvitationBatchHandler.handleServiceAppointment(candidateIds);
        for(EmailWrapper em:emailsToBeSent){
            if(!candidateIdWithSA.contains(em.recipient)){
                emailsToBeSentAfterSAChecks.add(em);
            }
            else{
                if(!defaultToDelete.containsKey(defaultToDeleteMap.get(em.recipient))){
                    defaultToDelete.put(defaultToDeleteMap.get(em.recipient), true);
                }
            }
        }
        return new HandleScopeWrapper(emailsToBeSentAfterSAChecks, defaultToDelete);
    }
    /**
     * @description This method mass emails the candidates based on the provided email templates.
     * It retrieves the email templates and composes emails for each candidate.
     * The emails are then sent using the Salesforce Messaging class.
     * The method returns a MassEmailWrapper object containing the map of send result and the list of send result.
     * @param data List of EmailWrapper objects containing the candidate's information, email template, and email template object
     * @return MassEmailWrapper object containing the map of send result and the list of send result
     */
    public static MassEmailWrapper massEmail(List<EmailWrapper> data) {
        // ----------------------------------------------------------------------
        // retrieve email templates
        Map<String, Boolean> mapRes = new Map<String, Boolean>();
        List<Map<String, String>> listRes = new List<Map<String, String>>();
        OrgWideEmailAddress senderAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'insiders@salesforce.com' LIMIT 1];
        // ----------------------------------------------------------------------
        // compose emails
        if (!data.isEmpty()) {
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            for(EmailWrapper item : data) {
                // --------------------------------------------------------------------
                String tmpId = item.templateObj.Id;
                String whoId = item.recipient;
                String whatId = item.what.Candidate__r.Id;
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(tmpId, whoId, whatId);
                email.setOrgWideEmailAddressId(senderAddress.Id);
                // --------------------------------------------------------------------
                // use code below only for development purpose
                // to debug simple matter of emails with no templates
                // Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                // email.setSubject(item.template);
                // email.setPlainTextBody(item.template);
                // email.setTargetObjectId(item.recipient);
                // --------------------------------------------------------------------
                emails.add(email);
            }
            List<Messaging.SendEmailResult> sendResult = Messaging.sendEmail(emails);
            // ----------------------------------------------------------------------
            // validate results:
            Integer increment = 0;
            for (Messaging.SendEmailResult variable : sendResult) {
                Map<String, String> entry = new Map<String, String>();
                String appId = (String)data[increment].what.Id;
                Boolean isSuccess = variable.isSuccess();
                mapRes.put(appId, isSuccess);
                entry.put('jobApp', appId);
                entry.put('status', isSuccess ? 'SUCCESS' : 'ERROR');
                listRes.add(entry);
                increment++;
            }
            return new MassEmailWrapper(mapRes, listRes);
        }
        return new MassEmailWrapper(mapRes, listRes);
    }
    /**
     * @description This method cleans up the settings based on the provided result map.
     * It iterates through the list of settings and checks if the corresponding application has been marked as successful.
     * If so, it adds the setting to a list of records to be deleted.
     * Finally, it deletes the list of records to be deleted.
     * @param result Map of application names and their corresponding success status
     * @param settings List of IA_Invitation_JobApplication__c records to be cleaned up
     */
    public static void cleanUpSettings(Map<String, Boolean> result, List<IA_Invitation_JobApplication__c> settings) {
        List<IA_Invitation_JobApplication__c> toDelete = new List<IA_Invitation_JobApplication__c>();
        for (IA_Invitation_JobApplication__c item : settings) {
            String application = item.Name;
            Boolean isSuccess = result.get(application) != null ? result.get(application) : false;
            if (isSuccess) {
                toDelete.add(item);
            }
        }
        delete toDelete;
    }
    /**
     * @description This method updates the tracking records based on the provided entries and scope.
     * It constructs a query to retrieve the tracking records associated with the given job applications.
     * It then iterates through the list of entries and updates the corresponding tracking records.
     * If a tracking record is found, it sets the "Invitation Email Sent" flag to true and adds the invitation history to the record.
     * If a tracking record is not found, a new record is created with the same parameters.
     * After updating all the tracking records, it checks if any job application has a recruiter notification that needs to be sent.
     * If so, it sends the recruiter notification and updates the corresponding tracking records accordingly.
     * Finally, it upserts all the updated tracking records into the system.
     * @param entries List of maps containing job application IDs and their corresponding invitation history
     * @param query String containing the SOQL query to retrieve the tracking records
     * @param scope List of WDR_Application__c records to be processed
     */
    public static void updateTrackings(List<Map<String, String>> entries, String query, List<WDR_Application__c> scope) {
        // ----------------------------------------------------
        // compose query:
        Integer increment = 0;
        Integer size = entries.size();
        List<Insiders_Tracking__c> trackings;
        String qWhere = '';
        Boolean isEntries = !entries.isEmpty();
        List<id> jobAppIds=new List<id>();
        // ----------------------------------------------------
        // TODO: move this piece to HELPER as weparate funciton
        if (isEntries) {
            qWhere = ' WHERE WD_Job_Application__c IN (';
            for (Map<String, String> entry : entries) {
				jobAppIds.add(entry.get('jobApp'));
                increment ++;
                String delimiter = (increment >= size) ? '' : ', ';
                qWhere = qWhere + '\'' + entry.get('jobApp') + '\'' + delimiter;
            }
            qWhere = qWhere + ') ';
        }
        query = query + qWhere + ' WITH SECURITY_ENFORCED ';
        // System.debug('QUERY: ' + query);
        // ----------------------------------------------------
        // look for trackings to...
        List<Insiders_Tracking__c> lstInsiderTracking = new List<Insiders_Tracking__c>();
        if (isEntries) {
            trackings = Database.query(query);
        }
        // ----------------------------------------------------
        // TODO: move this piece to HELPER as weparate funciton
        // Recruiter Notification check box adding to below variable 
        List<Id> jobAppsThatSendRecruiterNotification = new List<Id>();
        // split to a new or existing trackings set:
        Map<Id, WDR_Application__c> mapJobapps = IA_InsidersInvitationBatchHelper.invitationHistory(scope);
        for (Map<String, String> entry : entries) {
            String jobAppId = (String)entry.get('jobApp');
            Insiders_Tracking__c tracking = IA_InsidersInvitationBatchHelper.findTracking(trackings, jobAppId);
            WDR_Application__c jobApplication = mapJobapps.get(jobAppId);
            String empType = jobApplication.Job__r.Employment_Type__c;
            String reqCrReason = jobApplication.Job__r.RECR_Job_Req_Type_from_Additional_Data__c;
            Boolean isFutureforce = IA_InsidersInvitationBatchHelper.identifyFutureforcePersona(empType, reqCrReason);
            String invitationHistory = jobApplication.Candidate_Stage__c + '-' + jobApplication.Application_Step__c + '-' + System.now();
			if (tracking != null) {
                tracking.Invitation_Email_Sent__c = true;
                tracking.Invitation_History__c += ';\n';
                tracking.Invitation_History__c += invitationHistory;
                lstInsiderTracking.add(tracking);
                if(!tracking.Recruiter_Email_Sent__c && tracking.Invitation_Email_Sent__c){
                    jobAppsThatSendRecruiterNotification.add(tracking.WD_Job_Application__c);
                }
            } else {
                Insiders_Tracking__c newRec = new Insiders_Tracking__c();
                newRec.Invitation_Email_Sent__c = true;
                newRec.Recruiter_Email_Sent__c = false;
                newRec.Reminder_Email_Sent__c = false;
                newRec.WD_Job_Application__c  = jobAppId;
                newRec.Invitation_History__c = invitationHistory;
                newRec.isFutureforce__c = isFutureforce;
                lstInsiderTracking.add(newRec);
                jobAppsThatSendRecruiterNotification.add(jobAppId);
            }
        }
        // ----------------------------------------------------
        if(!jobAppsThatSendRecruiterNotification.isEmpty()){
        	map<Id,Boolean> recruiterEmailSent = IA_RecruiterNotification.sendRecruiterNotification(jobAppsThatSendRecruiterNotification);
            for(Insiders_Tracking__c itr: lstInsiderTracking){
                if(recruiterEmailSent.containsKey(itr.WD_Job_Application__c)){
                	itr.Recruiter_Email_Sent__c= recruiterEmailSent.get(itr.WD_Job_Application__c);
                }
            }
		}
        // ----------------------------------------------------
        // insert / update:
        if(!lstInsiderTracking.isEmpty()){
            upsert lstInsiderTracking;
        }
    }

    /**
     * @description A wrapper class to hold the results of sending mass emails and the corresponding tracking records.
     * @param mapSentResult A map containing the result of sending each email, where the key is the ID of the job application and the value is a boolean indicating whether the email was successfully sent.
     * @param listSentResult A list containing the tracking records for each email sent, where each entry is a map with keys 'jobApp' and 'status' representing the ID of the job application and the status of the email send, respectively.
     */
    public class MassEmailWrapper {
        /**
         * @description The map containing the result of sending each email, where the key is the ID of the job application and the value is a boolean indicating whether the email was successfully sent.
         */
        @AuraEnabled
        public Map<String, Boolean> mapSentResult { get; set; }

        /**
         * @description The list containing the tracking records for each email sent, where each entry is a map with keys 'jobApp' and 'status' representing the ID of the job application and the status of the email send, respectively.
         */
        @AuraEnabled
        public List<Map<String, String>> listSentResult { get; set; }

        /**
         * @description Constructor for the MassEmailWrapper class.
         * @param mapRes A map containing the result of sending each email, where the key is the ID of the job application and the value is a boolean indicating whether the email was successfully sent.
         * @param listRes A list containing the tracking records for each email sent, where each entry is a map with keys 'jobApp' and 'status' representing the ID of the job application and the status of the email send, respectively.
         */
        public MassEmailWrapper(Map<String, Boolean> mapRes, List<Map<String, String>> listRes) {
            this.mapSentResult = mapRes;
            this.listSentResult = listRes;
        }
    }

    /**
     * @description A wrapper class to hold the results of sending mass emails and the corresponding tracking records.
     * @param mapSentResult A map containing the result of sending each email, where the key is the ID of the job application and the value is a boolean indicating whether the email was successfully sent.
     * @param listSentResult A list containing the tracking records for each email sent, where each entry is a map with keys 'jobApp' and 'status' representing the ID of the job application and the status of the email send, respectively.
     */
    public class HandleScopeWrapper {
        /**
         * @description The list containing the tracking records for each email sent, where each entry is a map with keys 'jobApp' and 'status' representing the ID of the job application and the status of the email send, respectively.
         */
        public List<IA_InsidersInvitationBatchHandler.EmailWrapper> emailsToBeSent { get; set; }
        /**
         * @description The map containing the result of sending each email, where the key is the ID of the job application and the value is a boolean indicating whether the email was successfully sent.
         */
        public Map<String, Boolean> defaultsToDelete { get; set; }
        /**
         * @description Constructor for the HandleScopeWrapper class.
         * @param s A list containing the tracking records for each email sent, where each entry is a map with keys 'jobApp' and 'status' representing the ID of the job application and the status of the email send, respectively. 
         * @param d A map containing the result of sending each email, where the key is the ID of the job application and the value is a boolean indicating whether the email was successfully sent.
         */
        public HandleScopeWrapper(List<IA_InsidersInvitationBatchHandler.EmailWrapper> s, Map<String, Boolean> d) {
            this.emailsToBeSent = s;
            this.defaultsToDelete = d;
        }
    }

    public class EmailWrapper {
        /**
         * @description The ID of the recipient contact.
         */
        @AuraEnabled
        public Id recipient {get; set;}

        /**
         * @description The ID of the email template to be used for the email.
         */
        @AuraEnabled
        public String template {get; set;}

        /**
         * @description The actual email template object.
         */
        @AuraEnabled
        public EmailTemplate templateObj {get; set;}

        /**
         * @description The job application record associated with the email.
         */
        @AuraEnabled
        public WDR_Application__c what {get; set;}

        /**
         * @description Constructor for the EmailWrapper class.
         * @param recipient The ID of the recipient contact.
         * @param template The ID of the email template to be used for the email.
         * @param templateObj The actual email template object.
         * @param what The job application record associated with the email.
         */
        public EmailWrapper(Id recipient, String template, EmailTemplate templateObj, WDR_Application__c what) {
            this.recipient = recipient;
            this.template = template;
            this.templateObj = templateObj;
            this.what = what;
        }
    }
    /**
     * @description A utility method to handle Service Appointments for candidates.
     * @param candidateIds A list of candidate IDs to check for Service Appointments.
     * @return A set of candidate IDs that have a Service Appointment with a status of 'Scheduled', 'Rescheduled', or 'Completed' within the last 90 days.
     */
    //Invite should NOT be sent to candidates with Scheduled/Rescheduled/Completed SA less than or equal to 90 days
    public static set<Id> handleServiceAppointment(List<id> candidateIds){
        map<String,Boolean> mapReturn = new map<String,Boolean>();
        set<Id> ContactIds = new set<Id>();
        for(ServiceAppointment sa:[Select id,status,SchedStartTime,email,ContactId from ServiceAppointment where ContactId IN :candidateIds
                                   AND Status IN ('Scheduled','Rescheduled','Completed')])
        {
            if(sa.SchedStartTime.date().daysBetween(system.now().date())<=90){
                ContactIds.add(sa.ContactId);
            }
        }
        return ContactIds;
    }
}