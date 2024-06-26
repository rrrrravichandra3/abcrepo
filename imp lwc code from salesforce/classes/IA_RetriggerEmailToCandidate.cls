/**
 * @author Anchana Rajamathe
 * @date 07/05/2021
 * @description Apex class for handling email alerts for Insiders Candidate Invitation.
 */
Public with sharing class IA_RetriggerEmailToCandidate {
    public static List<WDR_Application__c> jobApplications = new List<WDR_Application__c>();
    public static Map<Id, Boolean> jobAppToInvitationSentMap = new Map<Id, Boolean>();
	public static Map<Id, Insiders_Tracking__c> jobAppToTrackingRecordMap = new Map<Id, Insiders_Tracking__c>();    
    /**
     * @description This method retrieves a list of email templates based on the provided record IDs.
     * It filters the templates based on the 'Insiders Candidate Invitation' label.
     *
     * @param recordids A comma-separated list of record IDs.
     * @return A list of maps, where each map contains the label and value of an email template.
     * @throws Exception If an error occurs during the execution of the method.
     */
    @AuraEnabled
    Public Static List<Map<String, String>> getListEmailTempalte( string recordids){
        String ObjName;

        List<Map <String, String>> templateOptions = new List<Map<String, String>> ();
        if(string.isNotBlank(recordids)){
            Set<id> recids = splitRecords(recordIds);
            for(id ids : recids){
                ObjName = getobjectName(ids);
                break;
            }
        
        	Map<String, String> mapTemplateValues = new Map <String, String> {'label' => 'Insiders Candidate Invitation',
                                                                              'value' => 'Insiders_Candidate_Invitation'};
        	templateOptions.add(mapTemplateValues);
           /* List<EmailTemplate> lstemialtemplate=[SELECT Id,IsActive,Name,DeveloperName,Subject FROM EmailTemplate where Name like 'insider%' or Name like 'IA%'];
            for(EmailTemplate template : lstemialtemplate){
                Map<String, String> mapTemplateValues = new Map <String, String> {'label' => template.Name,
                                                                                  'value' => template.DeveloperName};
                templateOptions.add(mapTemplateValues);                                                                                  
            }*/
        }
        
        return templateOptions;
    }
    /**
     * @description This method checks if the current user has the 'Insiders_App_Admin' permission set.
     *
     * @return A boolean value indicating whether the current user has the 'Insiders_App_Admin' permission set.
     * @throws Exception If an error occurs during the execution of the method.
     */
    @AuraEnabled
    Public Static Boolean isProgramAdmin(){
        Boolean isadmin=false;
        if(IA_Util.isUserHasIndicatedPermSet(userinfo.getuserid(),'Insiders_App_Admin')){
            isadmin=true;
        }
        return isadmin;
    }
    /**
     * @description This method retrieves the name of the SObjectType associated with the provided Id.
     *
     * @param recid An Id representing a Salesforce record.
     * @return A string containing the name of the SObjectType associated with the provided Id.
     */
    Public Static String getobjectName(Id recid){
        String sObjName = recid.getSObjectType().getDescribe().getName();
        return sObjName;
    }
    /**
     * @description This method splits a comma-separated list of Ids into a Set of Ids.
     *
     * @param recordIds A comma-separated list of Salesforce record Ids.
     * @return A Set of Ids, where each Id is a unique record Id from the input string.
     */
    Public Static set<id> splitRecords(string Ids){
        set<id> setrecords=new set<id>();
        for(String str : Ids.replaceAll( '\\s+', '').split(';')){
            setrecords.add(Id.valueOf(str));
        }
        return setrecords;
    }
    /**
     * @description This method sends email alerts to candidates for Insiders Candidate Invitation.
     *
     * @param jobAppIds A set of Ids representing the Job Applications for which email alerts need to be sent.
     * @throws Exception If an error occurs during the execution of the method.
     */
    public static void sendEmailAlerts(Set<Id> jobAppIds) {
        // Note: This query may need updates for ES Next changes
        jobApplications = [SELECT Id, Application_Step__c, Candidate_Stage__c, Candidate__c, Candidate__r.Candidate_Contact__c, Division__c, Job__c, Job__r.Country__c, Job__r.Employment_Type__c, Job__r.Req_Creation_Reason__c FROM WDR_Application__c WHERE Id IN :jobAppIds WITH SECURITY_ENFORCED];
        // Tracking Records related to Job Applications
        jobAppToTrackingRecordMap = new Map<Id, Insiders_Tracking__c>();
        
        for (Insiders_Tracking__c trackingRecord : [SELECT Id, WD_Job_Application__c, Invitation_Email_Sent__c, Invitation_History__c, Recruiter_Email_Sent__c FROM Insiders_Tracking__c WHERE WD_Job_Application__c IN :jobAppIds WITH SECURITY_ENFORCED]) {
            jobAppToTrackingRecordMap.put(trackingRecord.WD_Job_Application__c, trackingRecord);
        }
        
        // Get all contact Ids
        Set<Id> contactIds = new Set<Id>();
        Map<Id, Id> contactToJobAppMap = new Map<Id, Id>();
        for (WDR_Application__c jobApp : jobApplications) {
            contactIds.add(jobApp.Candidate__r.Candidate_Contact__c);
            contactToJobAppMap.put(jobApp.Candidate__r.Candidate_Contact__c, jobApp.Id);
        }
        try {
            List<String> failedRecordIds = new List<String>();
            
            // for every job application
            Map<Id, Id> candidateToJobAppMap = new Map<Id, Id>();
            Set<Id> processedCandidates = new Set<Id>();
            jobAppToInvitationSentMap = new Map<Id, Boolean>();
            List<WDR_Application__c> processedApplications = new List<WDR_Application__c>();
            for (WDR_Application__c jobApplication : jobApplications) {
                // If we do not have a Candidate__c or Candidate_Contact__c associated, the invitation email will break at runtime
                if (String.isBlank(jobApplication.Candidate__c) || String.isBlank(jobApplication.Candidate__r.Candidate_Contact__c)) {
                    continue;
                }
                // Input data for IA_SendInvitationEmailToCandidate autolaunched Flow
                Map<String, Object> inputVarMap = new Map<String, Object>();
                inputVarMap.put('recordId', jobApplication.Candidate__c);
                // Bulkification Note : Each Job Application creates a flow interview (instance of flow).
                // However, When multiple flow interviews exist for same flow in a transaction, AND when they have bulkifiable flow elements.(Eg:Email)
                // Platform automatically bulkfies and executes them in a batch,
                // More Info - https://developer.salesforce.com/docs/atlas.en-us.216.0.salesforce_vpm_guide.meta/salesforce_vpm_guide/vpm_admin_bulkification.htm#vpm_admin_bulkification
                try {
                    Flow.Interview.IA_SendInvitationEmailToCandidate sendInvitationEmailToCandidateFlow = new Flow.Interview.IA_SendInvitationEmailToCandidate(inputVarMap);
                    sendInvitationEmailToCandidateFlow.start();
                    processedCandidates.add(jobApplication.Candidate__c);
                    jobAppToInvitationSentMap.put(jobApplication.Id, true);
                    processedApplications.add(jobApplication);
                } catch (Exception ex) {
                    String errorMessage = IA_Util.buildErrorMessage(UserInfo.getUserEmail(), null, 'Invitation Email Flow - IA_InvitationEmailQueueableClass', ex.getMessage(), ex.getStackTraceString());
                    failedRecordIds.add(jobApplication.Id + ' - ' + errorMessage + '\n');
                }
            }
            /* Get Tracking record or create it for every processed Job Application
             * and mark Invitation Email and Recruiter notification if applicable.
             * This used to be handled on the "Insiders Invitation Email Flow".
             */
            handleTrackingRecordsAndRecruiterNotifications(processedApplications);
            // Send email to Eops for failing records
            if (failedRecordIds.size() > 0) {
                String errorMessage = 'The following records have encountered an error when sending the Invitation to Insiders App to Candidates: \n';
                errorMessage += String.join(failedRecordIds, ', ');
                IA_Util.sendExceptionMail(new List<String>{ errorMessage });
            }
            // Update Contact's Insider_Job_Application__c
            Set<Id> candidateContactsThatWillBeUpdated = new Set<Id>();
            for (WDR_Candidate__c wdc : [SELECT Candidate_Contact__c FROM WDR_Candidate__c WHERE Id IN :processedCandidates WITH SECURITY_ENFORCED]) {
                candidateContactsThatWillBeUpdated.add(wdc.Candidate_Contact__c);
            }
            List<Contact> contactsToUpdate = new List<Contact>();
            
               for (Contact con : [SELECT Id, Insider_Job_Application__c FROM Contact WHERE Id IN :candidateContactsThatWillBeUpdated WITH SECURITY_ENFORCED]) {
                    if (String.isBlank(con.Insider_Job_Application__c) ) {
                        con.Insider_Job_Application__c = contactToJobAppMap.get(con.Id);
                        contactsToUpdate.add(con);
                    }
                }
            
            if (contactsToUpdate.size() > 0) {
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, contactsToUpdate);

                if(!securityDecision.getRecords().isEmpty()){
                    update securityDecision.getRecords();
                }
                //update contactsToUpdate;
            }
        } catch (Exception ex) {
            IA_Util.sendExceptionMail(new List<String>{ 'The following error occured when sending Insider Invitation email for WD Job Applications' + jobAppIds + '\n' + ex.getMessage() + ' Stack Trace:' + ex.getStackTraceString() });
        }
    }
    
    
    /**
     * @description This method sends email alerts to candidates for Insiders Candidate Invitation.
     *
     * @param recordIds A comma-separated list of Ids representing the Job Applications for which email alerts need to be sent.
     * @param emailTemplate A string representing the email template to be used for sending the email alerts.
     * @return A boolean value indicating whether the email alerts were successfully sent.
     */
    @AuraEnabled
    Public Static boolean sendEmails(string recordIds, String emailTemplate){
        try{
            If(string.isNotBlank(recordIds)){
                set<id> records = splitRecords(recordIds);
                sendEmailAlerts(records);
                return true;
            }
        }catch(Exception exp){
            IA_Util.sendExceptionMail(new List<String>{ 'The following Resend email \n' + exp.getMessage() + ' Stack Trace:' + exp.getStackTraceString() });
        }
        return false;
    }
    
    /**
     * @description This method handles the tracking records and recruiter notifications for the given job applications.
     *
     * @param jobApps A list of WDR_Application__c records representing the job applications for which tracking records and recruiter notifications need to be handled.
     */
    private static void handleTrackingRecordsAndRecruiterNotifications(List<WDR_Application__c> jobApps) {
        List<Insiders_Tracking__c> trackingRecordsToUpsert = new List<Insiders_Tracking__c>();
        List<Id> jobAppsThatSendRecruiterNotification = new List<Id>();
        for (WDR_Application__c jobApp : jobApps) {
            Insiders_Tracking__c trackingRecord;
            Boolean currentJobAppJustFiredInvitationEmail = jobAppToInvitationSentMap.containsKey(jobApp.Id);
            // Check if Insiders Tracking record exists for current Job Application
            if (jobAppToTrackingRecordMap.containsKey(jobApp.Id)) {
                // Exists
                trackingRecord = jobAppToTrackingRecordMap.get(jobApp.Id);
            } else {
                // Does not exist, create one
                trackingRecord = new Insiders_Tracking__c();
                trackingRecord.WD_Job_Application__c = jobApp.Id;
                trackingRecord.isFutureforce__c = IA_InvitationEmailHelper.identifyFutureforcePersona(jobApp.Job__r.Employment_Type__c, jobApp.Job__r.Req_Creation_Reason__c);
            }
            // Validate if invitation email was sent
            if (currentJobAppJustFiredInvitationEmail) {
                String invitationHistory = jobApp.Candidate_Stage__c + '-' + jobApp.Application_Step__c + '-' + System.now();
                trackingRecord.Invitation_Email_Sent__c = true;
                // Update Invitation History
                if (String.isBlank(trackingRecord.Invitation_History__c)) {
                    trackingRecord.Invitation_History__c = invitationHistory;
                } else {
                    trackingRecord.Invitation_History__c += ';\n';
                    trackingRecord.Invitation_History__c += invitationHistory;
                }
            }

            // Validate if Recruiter Notification was sent
            if (!trackingRecord.Recruiter_Email_Sent__c && (trackingRecord.Invitation_Email_Sent__c || currentJobAppJustFiredInvitationEmail)) {
                jobAppsThatSendRecruiterNotification.add(jobApp.Id);
                trackingRecord.Recruiter_Email_Sent__c = true;
            }
            trackingRecordsToUpsert.add(trackingRecord);
        }
        try {
            
            SObjectAccessDecision updateSecurityDecision = Security.stripInaccessible(AccessType.UPDATABLE, trackingRecordsToUpsert);
            SObjectAccessDecision createSecurityDecision = Security.stripInaccessible(AccessType.CREATABLE, updateSecurityDecision.getRecords());
            if(!createSecurityDecision.getRecords().isEmpty()){
                upsert createSecurityDecision.getRecords();
            }
            //upsert trackingRecordsToUpsert;
            
            IA_RecruiterNotification.sendRecruiterNotification(jobAppsThatSendRecruiterNotification);
        } catch (Exception ex) {
            System.debug(ex.getMessage());
            IA_Util.buildErrorMessage(UserInfo.getUserEmail(), null, 'IA_InvitationEmailQueueableClass - Upsert trackingRecordsToUpsert', ex.getMessage(), ex.getStackTraceString());
        }
    }
    
    
    
}