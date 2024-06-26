/**
* @description       : This class is a Trigger Handler for the IA_Send_Invitation_Email trigger.
* It processes the list of job applications and sends the invitation emails to candidates.
* It also updates the Insiders Tracking records and sends the Recruiter Notification emails if needed.
* @author            : Sanghamitra
**/
public with sharing class IA_Send_Invitation_Email_TriggerHandler {
    public static List<WDR_Application__c> jobApplications = new List<WDR_Application__c>();
    public static Map<Id, Boolean> jobAppToInvitationSentMap = new Map<Id, Boolean>();
    public static Map<Id, Insiders_Tracking__c> jobAppToTrackingRecordMap = new Map<Id, Insiders_Tracking__c>();
    /**
* @description : This method processes the events triggered by the IA_Send_Invitation_Email trigger.
* It retrieves the list of job application IDs from the trigger events and sends the email alerts if needed.
* @param events List of IA_Send_Invitation_Email__e events triggered by the IA_Send_Invitation_Email trigger
*/
    public static void processEvents(List<IA_Send_Invitation_Email__e> events) {
        Set<Id> jobAppIds = new Set<Id>();
        for(IA_Send_Invitation_Email__e e: events){
            if(e.JobAppId__c != null){
                jobAppIds.add(e.JobAppId__c);
            }
        }
        if(!jobAppIds.IsEmpty()){
            sendEmailAlerts(jobAppIds);
        }
    }
    /**
* @description: This method sends the email alerts for the given job application IDs.
* It retrieves the job applications and their related data, and sends the invitation emails to candidates.
* It also updates the Insiders Tracking records and sends the Recruiter Notification emails if needed.
* @param jobAppIds Set of job application IDs for which the email alerts need to be sent
*/
    public static void sendEmailAlerts(Set<Id> jobAppIds) {
        // Note: This query may need updates for ES Next changes
        jobApplications = [SELECT Id, Application_Step__c, Candidate_Stage__c, Boomerang__c, Internal_Candidate__c, Candidate__c, 
                           Candidate__r.Candidate_Contact__c, Division__c, Job__c, Job__r.Country__c, Job__r.Employment_Type__c, 
                           Job__r.Req_Creation_Reason__c, Job__r.Job_Level__c FROM WDR_Application__c WHERE Id IN :jobAppIds];
        // Tracking Records related to Job Applications
        jobAppToTrackingRecordMap = getJobAppToTrack(jobAppIds);
        
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
            Insiders_App_Config__mdt config = [SELECT Insider_CEMCI_User__c FROM Insiders_App_Config__mdt 
                                               WHERE DeveloperName = 'User_Defaults' WITH SECURITY_ENFORCED];
            // update account owner
            try {
                if (config.Insider_CEMCI_User__c != null) {
                    updateAccount(contactIds,config);
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
            sendFailingRecord(failedRecordIds);
            
            // Update Contact's Insider_Job_Application__c
            updateContact(processedCandidates,contactToJobAppMap);
            
        } catch (Exception ex) {
            IA_Util.sendExceptionMail(new List<String>{ 'The following error occured when sending Insider Invitation email for WD Job Applications' + jobAppIds + '\n' + ex.getMessage() + ' Stack Trace:' + ex.getStackTraceString() });
        }
    }
    
    /**********************************************************************************************
* @description        This method validates whether the Job Application has an Insiders
*                     Tracking record and updates it properly. It also sends the Recruiter
*                     Notification email if it is needed.
* @param jobApps    : Job Applications that need their Insiders Tracking Record updated
*                     and their Recruiter notifications send.
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
                if(checkJobApplicationFieldAccess()){
                       trackingRecord.WD_Job_Application__c = jobApp.Id;
                       trackingRecord.isFutureforce__c = IA_InvitationEmailHelper.identifyFutureforcePersona(jobApp.Job__r.Employment_Type__c, jobApp.Job__r.Req_Creation_Reason__c);
                   }
            }
            // Validate if invitation email was sent
            if (currentJobAppJustFiredInvitationEmail && checkInvitationEmailFieldAccess()) {
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
            }
            trackingRecordsToUpsert.add(trackingRecord);
            IA_RecruiterNotification.trackingRecordsToUpsert.add(trackingRecord);//Adding IVT data to trackingRecordsToUpsert and upserting from IA_RecruiterNotification
        }
        upsertInsiderTracking(jobAppsThatSendRecruiterNotification, trackingRecordsToUpsert);
    }
    /**
* @description: This method check field has access.
* @return A boolean check whether field have access or not.
*/
    private static boolean checkJobApplicationFieldAccess() {
        return Schema.sObjectType.Insiders_Tracking__c.fields.WD_Job_Application__c.isUpdateable() 
                   && Schema.sObjectType.Insiders_Tracking__c.fields.isFutureforce__c.isUpdateable()
                   && Schema.sObjectType.Insiders_Tracking__c.fields.WD_Job_Application__c.isCreateable() 
                   && Schema.sObjectType.Insiders_Tracking__c.fields.isFutureforce__c.isCreateable();
    }
    
     /**
* @description: This method check field has access.
* @return A boolean check whether field have access or not.
*/
    private static boolean checkInvitationEmailFieldAccess() {
        return Schema.sObjectType.Insiders_Tracking__c.fields.Invitation_Email_Sent__c.isUpdateable() 
                && Schema.sObjectType.Insiders_Tracking__c.fields.Invitation_History__c.isUpdateable()
                && Schema.sObjectType.Insiders_Tracking__c.fields.Invitation_Email_Sent__c.isCreateable() 
                && Schema.sObjectType.Insiders_Tracking__c.fields.Invitation_History__c.isCreateable();
    }
     /**
* @description: This method upsert Insider Tracking.
* @param jobAppsThatSendRecruiterNotification List of Id.
* @param trackingRecordsToUpsert List of Insiders of tracking object.
*/
    private static void upsertInsiderTracking(List<Id> jobAppsThatSendRecruiterNotification, List<Insiders_Tracking__c> trackingRecordsToUpsert) {
         try {
            IA_RecruiterNotification.sendRecruiterNotification(jobAppsThatSendRecruiterNotification);
            if(IA_RecruiterNotification.isEmailSent == False){
                upsert trackingRecordsToUpsert;
            }
        } catch (Exception ex) {
            IA_Util.buildErrorMessage(UserInfo.getUserEmail(), null, 'IA_InvitationEmailQueueableClass - Upsert trackingRecordsToUpsert', ex.getMessage(), ex.getStackTraceString());
        }
    }
    /**
* @description: This method return the insider tracking map.
* @param jobAppIds Set of job application IDs for which the email alerts need to be sent
* @return A Map of Insider Tracking.
*/
    private static Map<Id, Insiders_Tracking__c> getJobAppToTrack(Set<Id> jobAppIds) {
        
        Map<Id, Insiders_Tracking__c> jobAppTrackRecordMap = new Map<Id, Insiders_Tracking__c>(); 
        for (Insiders_Tracking__c trackingRecord : [SELECT Id, WD_Job_Application__c, Invitation_Email_Sent__c, Invitation_History__c, 
                                                    Recruiter_Email_Sent__c FROM Insiders_Tracking__c 
                                                    WHERE WD_Job_Application__c IN :jobAppIds WITH SECURITY_ENFORCED]) {
                                                        jobAppTrackRecordMap.put(trackingRecord.WD_Job_Application__c, trackingRecord);
                                                    }
        
        return jobAppTrackRecordMap;
    }
    /**
* @description: This method to update account.
* @param contactIds Set of contact Ids.
* @param config is object of Insiders_App_Config__mdt. 
*/
    private static void updateAccount(Set<Id> contactIds, Insiders_App_Config__mdt config) {
        Set<Id> accountsToUpdateOwner = new Set<Id>(); 
        for (Contact con : [SELECT Account.Owner.UserRoleId, accountID FROM Contact WHERE ID = :contactIds WITH SECURITY_ENFORCED]) {
            if (con.Account.Owner.UserRoleId == null) {
                accountsToUpdateOwner.add(con.accountID);
            }
        }
        if (accountsToUpdateOwner.size() > 0 && Schema.sObjectType.Account.fields.ownerId.isUpdateable()) {
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
    /**
* @description: This method to update contact Insider_Job_Application__c.
* @param contactIds Set of contact application IDs for which the email alerts need to be sent.
*/
    private static void updateContact(Set<Id> processedCandidates, Map<Id, Id> contactToJobAppMap) {
        Set<Id> candidateContactsThatWillBeUpdated = new Set<Id>();
        for (WDR_Candidate__c wdc : [SELECT Candidate_Contact__c FROM WDR_Candidate__c WHERE Id IN :processedCandidates WITH SECURITY_ENFORCED]) {
            candidateContactsThatWillBeUpdated.add(wdc.Candidate_Contact__c);
        }
        List<Contact> contactsToUpdate = new List<Contact>();
        if(Schema.sObjectType.Contact.fields.Insider_Job_Application__c.isAccessible()){
            for (Contact con : [SELECT Id, Insider_Job_Application__c FROM Contact WHERE Id IN :candidateContactsThatWillBeUpdated]) {
                if (String.isBlank(con.Insider_Job_Application__c) && Schema.sObjectType.Contact.fields.Insider_Job_Application__c.isUpdateable()) {
                    con.Insider_Job_Application__c = contactToJobAppMap.get(con.Id);
                    contactsToUpdate.add(con);
                }
            }
            if (contactsToUpdate.size() > 0) {
                update contactsToUpdate;
            }
        }
    }
    /**
* @description: This method to Send email to Eops for failing records.
* @param failedRecordIds is failed record Ids List.
*/
    private static void sendFailingRecord(List<String> failedRecordIds) {
        if (failedRecordIds.size() > 0) {
            String errorMessage = 'The following records have encountered an error when sending the Invitation to Insiders App to Candidates: \n';
            errorMessage += String.join(failedRecordIds, ', ');
            IA_Util.sendExceptionMail(new List<String>{ errorMessage });
        }
    }
}