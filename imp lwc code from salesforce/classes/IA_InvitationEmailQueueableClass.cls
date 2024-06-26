/**
 * @author Vinod Chokkula
 * @date 02/18/2020
 *
 * @description Queueable class which updates the account owner and sends invitation email to candidates
 *
 */
public inherited sharing class IA_InvitationEmailQueueableClass implements Queueable {
    List<WDR_Application__c> jobApplications = new List<WDR_Application__c>();
    Map<Id, Boolean> jobAppToInvitationSentMap;
    Map<Id, Insiders_Tracking__c> jobAppToTrackingRecordMap;
    public IA_InvitationEmailQueueableClass(List<WDR_Application__c> jobApplications) {
        this.jobApplications = jobApplications;
    }

    public void execute(QueueableContext qc) {
        Set<Id> jobAppIds = new Set<Id>();
        for (WDR_Application__c jobApp : jobApplications) {
            jobAppIds.add(jobApp.Id);
        }

        // Note: This query may need updates for ES Next changes
        jobApplications = [SELECT Id, Application_Step__c, Candidate_Stage__c, Candidate__c, Candidate__r.Candidate_Contact__c, Division__c, Job__c, Job__r.Country__c, Job__r.Employment_Type__c, Job__r.Req_Creation_Reason__c FROM WDR_Application__c WHERE Id IN :jobAppIds];

        // Tracking Records related to Job Applications
        jobAppToTrackingRecordMap = new Map<Id, Insiders_Tracking__c>();
        for (Insiders_Tracking__c trackingRecord : [SELECT Id, WD_Job_Application__c, Invitation_Email_Sent__c, Invitation_History__c, Recruiter_Email_Sent__c FROM Insiders_Tracking__c WHERE WD_Job_Application__c IN :jobAppIds]) {
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
            // Query CustomMetadattype - to get the Default Account
            Insiders_App_Config__mdt config = [SELECT Insider_CEMCI_User__c FROM Insiders_App_Config__mdt WHERE DeveloperName = 'User_Defaults'];
            //get IA_CheckFLS class name
            String checkFLSClass = IA_Util.InsiderConfigDefaultRec.FLSCheckClassName__c;
            Type t = Type.forName(checkFLSClass);
            // update  account owner
            try {
                if (config.Insider_CEMCI_User__c != null) {
                    if(((IA_FLSCheckInterface)t.newInstance()).canReadObject('Account') && ((IA_FLSCheckInterface)t.newInstance()).canUpdateObject('Account') && ((IA_FLSCheckInterface)t.newInstance()).canReadObject('Contact') && ((IA_FLSCheckInterface)t.newInstance()).canReadObject('User')){
                        if(((IA_FLSCheckInterface)t.newInstance()).canUpdateField('Account','ownerId')){
                    Set<Id> accountsToUpdateOwner = new Set<Id>();
                    // get all the contacts whose account owner userrole is null
                    for (Contact con : [SELECT Account.Owner.UserRoleId, accountID FROM Contact WHERE ID = :contactIds]) {
                        if (con.Account.Owner.UserRoleId == null) {
                            accountsToUpdateOwner.add(con.accountID);
                        }
                    }

                    if (accountsToUpdateOwner.size() > 0) {
                        // Query the account to be updated to
                        Id dummyUserId = [SELECT Id FROM user WHERE name = :config.Insider_CEMCI_User__c LIMIT 1].Id;
                        List<Account> accountsToUpdate = new List<Account>();
                        // update account owner
                        for (Account acc : [SELECT ownerId, Id FROM Account WHERE Id = :accountsToUpdateOwner]) {
                            acc.ownerId = dummyUserId;
                            accountsToUpdate.add(acc);
                        }
                        if (accountsToUpdate.size() > 0 && Schema.sObjectType.Account.fields.ownerId.isUpdateable()) {
                            update accountsToUpdate;
                        }
                    }
                }
                    }
                }
            } catch (Exception e) {
                IA_Util.sendExceptionMail(new List<String>{ 'The following error occured when Accont Owner is being updated' + jobAppIds + '\n' + e.getMessage() + ' Stack Trace:' + e.getStackTraceString() });
                return;
            }

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

                // Check Job Application is in an eligible Candidate Stage and Applicaton Step
                if (!IA_InvitationEmailHelper.validateApplicationIsValidForInvitationEmail(jobApplication)) {
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
            for (WDR_Candidate__c wdc : [SELECT Candidate_Contact__c FROM WDR_Candidate__c WHERE Id IN :processedCandidates]) {
                candidateContactsThatWillBeUpdated.add(wdc.Candidate_Contact__c);
            }

            List<Contact> contactsToUpdate = new List<Contact>();
            for (Contact con : [SELECT Id, Insider_Job_Application__c FROM Contact WHERE Id IN :candidateContactsThatWillBeUpdated]) {
                if (String.isBlank(con.Insider_Job_Application__c) && Schema.sObjectType.Contact.fields.Insider_Job_Application__c.isUpdateable() && ((IA_FLSCheckInterface)t.newInstance()).canUpdateObject('Contact')) {
                    con.Insider_Job_Application__c = contactToJobAppMap.get(con.Id);
                    contactsToUpdate.add(con);
                }
            }
            if (contactsToUpdate.size() > 0) {
                update contactsToUpdate;
            }
        } catch (Exception ex) {
            IA_Util.sendExceptionMail(new List<String>{ 'The following error occured when sending Insider Invitation email for WD Job Applications' + jobAppIds + '\n' + ex.getMessage() + ' Stack Trace:' + ex.getStackTraceString() });
        }
    }

    /**********************************************************************************************
     * @description        This method validates whether the Job Application has an Insiders
     *                     Tracking record and updates it properly. It also sends the Recruiter
     *                     Notification email if it is needed.
     *
     *
     * @param jobApps    : Job Applications that need their Insiders Tracking Record updated
     *                     and their Recruiter notifications send.
     *
     */
    private void handleTrackingRecordsAndRecruiterNotifications(List<WDR_Application__c> jobApps) {
        List<Insiders_Tracking__c> trackingRecordsToUpsert = new List<Insiders_Tracking__c>();
        List<Id> jobAppsThatSendRecruiterNotification = new List<Id>();
        //get IA_CheckFLS class name
        String checkFLSClass = IA_Util.InsiderConfigDefaultRec.FLSCheckClassName__c;
        Type t = Type.forName(checkFLSClass);
        if(((IA_FLSCheckInterface)t.newInstance()).canUpdateObject('Insiders_Tracking__c') && ((IA_FLSCheckInterface)t.newInstance()).canReadObject('Insiders_Tracking__c') && ((IA_FLSCheckInterface)t.newInstance()).canCreateObject('Insiders_Tracking__c')){
            if(((IA_FLSCheckInterface)t.newInstance()).canUpdateField('Insiders_Tracking__c','WD_Job_Application__c') && ((IA_FLSCheckInterface)t.newInstance()).canUpdateField('Insiders_Tracking__c','Invitation_Email_Sent__c')
               && ((IA_FLSCheckInterface)t.newInstance()).canUpdateField('Insiders_Tracking__c','Invitation_History__c') && ((IA_FLSCheckInterface)t.newInstance()).canUpdateField('Insiders_Tracking__c','Recruiter_Email_Sent__c')
               && ((IA_FLSCheckInterface)t.newInstance()).canCreateField('Insiders_Tracking__c','WD_Job_Application__c') && ((IA_FLSCheckInterface)t.newInstance()).canCreateField('Insiders_Tracking__c','Invitation_Email_Sent__c')
               && ((IA_FLSCheckInterface)t.newInstance()).canCreateField('Insiders_Tracking__c','Invitation_History__c') && ((IA_FLSCheckInterface)t.newInstance()).canCreateField('Insiders_Tracking__c','Recruiter_Email_Sent__c')){
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
            upsert trackingRecordsToUpsert;
            IA_RecruiterNotification.sendRecruiterNotification(jobAppsThatSendRecruiterNotification);
        } catch (Exception ex) {
            IA_Util.buildErrorMessage(UserInfo.getUserEmail(), null, 'IA_InvitationEmailQueueableClass - Upsert trackingRecordsToUpsert', ex.getMessage(), ex.getStackTraceString());
        }
    }
}
    }
}