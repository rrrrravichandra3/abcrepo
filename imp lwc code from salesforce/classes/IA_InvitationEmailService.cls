/**
 * @description Class used to send Insiders App Invitation Email to valid candidates Service class
 * @author VenkateswaraReddy Komireddy
 * @date 12/15/2021
 */
public with sharing class IA_InvitationEmailService {
    
    public static Map<Id,Id> contactToJobAppMap = new Map<Id,Id>();
    
    /**
     * @description Method to invoke the email invite process for eligible candidates
     * @param jobApplications - List of job applications for which the email invite process needs to be invoked
     */
    public static void invokeEmailInviteProcess(List<WDR_Application__c> jobApplications) {
        try{
            if( !jobApplications.isEmpty()){
                SendInviteEmailAndUpdateRecs(getInsiderEligibleCandidateJobApps(jobApplications)); 
            }
        }catch(Exception exp){
            throw new IA_CustomException('The issue is related to invokeEmail Invite Process');
        }
    }
    /**
     * @description Method to get the list of eligible candidate Job APPS
     * @param jobApplications - List of job applications for which the email invite process needs to be invoked
     * @return List<WDR_Application__c> - List of eligible candidate Job APPS
     * @throws IA_CustomException - Thrown when there is an issue related to get Insider Eligible Candidate Job Apps
     */
     public static list<WDR_Application__c> getInsiderEligibleCandidateJobApps(List<WDR_Application__c> jobApplications){
        Map<Id,ServiceAppointment> contactIdToServiceAppointment = new Map<Id,ServiceAppointment>();
        Set<Id> jobAppIds = new Set<Id>();
        list<WDR_Application__c> eligibleCandidateJobApps = new List<WDR_Application__c>();
        try{ 
            for(WDR_Application__c jobApp : jobApplications) {
                jobAppIds.add(jobApp.Id);
            }
            // Query all contacts related to WDR_Application__c
            List<WDR_Application__c> jobApplicationWithContacts = [SELECT Id, Candidate__r.Candidate_Contact__c,Candidate__c 
                                                                   FROM WDR_Application__c WHERE Id =: jobAppIds
                                                                   AND Candidate__r.Invitation_Email_Sent__c =false WITH SECURITY_ENFORCED ];
            
            // Get all contact Ids
            for (WDR_Application__c jobApp: jobApplicationWithContacts) {
                contactToJobAppMap.put(jobApp.Candidate__r.Candidate_Contact__c,jobApp.Id);
            }
            // Get appointments based on contact Ids
            List<ServiceAppointment> serviceAppointmentList = [SELECT Id, ContactId FROM ServiceAppointment 
                                                               WHERE ContactId =: contactToJobAppMap.keySet() WITH SECURITY_ENFORCED];
            for (ServiceAppointment serviceApp : serviceAppointmentList) {
                contactIdToServiceAppointment.put(serviceApp.ContactId, serviceApp);
            }
            
            for (WDR_Application__c jobApplication: jobApplications) {
                // Add to eligbileble list IF Candidate does NOT have ServiceAppointment
                if(!contactIdToServiceAppointment.containskey(jobApplication.Candidate__r.Candidate_Contact__c)){
                    eligibleCandidateJobApps.add(jobApplication);
                }
            }
        }catch(Exception exp){
            throw new IA_CustomException('The issue is related to get Insider Eligible Candidate Job Apps');
        }
        return eligibleCandidateJobApps;
    }
    
    /**
     * @description Method to send Insiders App Invitation Email to eligible candidates and update records
     * @param jobApplications - List of job applications for which the email invite process needs to be invoked
     * @throws IA_CustomException - Thrown when there is an issue related to send invitation email and update records
     */
    private static void SendInviteEmailAndUpdateRecs(List<WDR_Application__c> jobApplications){
        
        List<String> failedRecordIds = new List<String>();
        Set<Id> processedCandidateIds = new Set<Id>();                                 
        Set<Id> processedContactIds = new Set<Id>();  
        try{
        //for every job application                                 
        for (WDR_Application__c jobApplication: jobApplications) {
            
            Map<String, Object> inputVarMap = new Map<String, Object>();
            inputVarMap.put('recordId', jobApplication.Candidate__c);
            SYSTEM.debug('inputVarMap'+inputVarMap);
            //Bulkification Note : Each Job Application creates a flow interview (instance of flow).
            //However, When multiple flow interviews exist for same flow in a transaction, AND when they have bulkifiable flow elements.(Eg:Email)
            //Platform automatically bulkfies and executes them in a batch, 
            // More Info - https://developer.salesforce.com/docs/atlas.en-us.216.0.salesforce_vpm_guide.meta/salesforce_vpm_guide/vpm_admin_bulkification.htm#vpm_admin_bulkification
            try {
                Flow.Interview.IA_SendInvitationEmailToCandidate sendInvitationEmailToCandidateFlow = new Flow.Interview.IA_SendInvitationEmailToCandidate(inputVarMap);
                sendInvitationEmailToCandidateFlow.start();
                processedCandidateIds.add(jobApplication.Candidate__c);               
                processedContactIds.add(jobApplication.Candidate__r.Candidate_Contact__c );
            }
            catch(Exception ex) {
                failedRecordIds.add(jobApplication.Id + ' - ' + ex.getMessage() + '\n');
            } 
        }
        
        if (failedRecordIds.size() > 0) {
            String errorMessage = 'The following records have encountered an error when sending the Invitation to Insiders App to Candidates: \n';
            errorMessage += String.join(failedRecordIds, ', ');
            throw new IA_CustomException(errorMessage);
        }     
        if(!processedCandidateIds.isEmpty()) {
            updateInvEmailSentFlagOnCandidate(processedCandidateIds);
        }     
        if( !processedContactIds.isEmpty()){
            updateInsiderJobAppOnContact(processedContactIds);
        }   
        }catch(Exception exp){
            throw new IA_CustomException('The issue is related to Send Invite Email And Update Recs');
        }
        
    }
    /**
     * @description Method to update the 'Invitation_Email_Sent__c' field on the 'WDR_Candidate__c' object for the given candidate IDs.
     * @param processedCandidateIds - Set of IDs of candidates whose 'Invitation_Email_Sent__c' field needs to be updated.
     * @throws IA_CustomException - Thrown when there is an issue related to updating the 'Invitation_Email_Sent__c' field.
     */
    public static void updateInvEmailSentFlagOnCandidate(Set<Id> processedcandidateIds) {
        // Update Invitation_Email_Sent from well processed records
        if(Schema.getGlobalDescribe().get('WDR_Candidate__c').getDescribe().isAccessible()){
            try {
                Set<Id> processedContactIds = new Set<Id>();
                List<WDR_Candidate__c> updatedCandidates = new List<WDR_Candidate__c>();
                
                for (WDR_Candidate__c candidate : [SELECT Invitation_Email_Sent__c,Candidate_Contact__c
                                                    FROM WDR_Candidate__c WHERE Id =: processedcandidateIds]) {
                                                        candidate.Invitation_Email_Sent__c = true;
                                                        updatedCandidates.add(candidate);
                                                        processedContactIds.add(candidate.Candidate_Contact__c);
                                                    }
                
                if(updatedCandidates.size()>0 ){
                    //update updatedCandidates;
                    SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, updatedCandidates);

                    if(!securityDecision.getRecords().isEmpty()){
                        update securityDecision.getRecords();
                    }
                }
            }catch(Exception exp){
                throw new IA_CustomException('The issue is related to when sending Insider Invitation email for WD Job Applications');
            }
        }
    }

    /**
     * @description Method to update the 'Insider_Job_Application__c' field on the 'Contact' object for the given contact IDs.
     * @param processedContactIds - Set of IDs of contacts whose 'Insider_Job_Application__c' field needs to be updated.
     * @throws IA_CustomException - Thrown when there is an issue related to updating the 'Insider_Job_Application__c' field.
     */
    public static void updateInsiderJobAppOnContact(Set<Id> processedContactIds) {
        //get IA_CheckFLS class name
        if(Schema.getGlobalDescribe().get('Contact').getDescribe().isAccessible()){
                try {
                    //	Set<Id> processedContactIds = new Set<Id>();
                    List<Contact> contactsToUpdate = new List<Contact>();
                    if(Schema.sObjectType.Contact.fields.Insider_Job_Application__c.isUpdateable() && 
                       Schema.sObjectType.Contact.fields.Insider_Job_Application__c.isAccessible()){
                        for(Contact con : [SELECT Id,Insider_Job_Application__c from Contact where Id IN :processedContactIds WITH SECURITY_ENFORCED ]){
                            if(con.Insider_Job_Application__c == null ){
                                con.Insider_Job_Application__c = contactToJobAppMap.get(con.Id);
                                contactsToUpdate.add(con);
                            }
                        }
                    }
                    
                    if(contactsToUpdate.size()>0){
                        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, contactsToUpdate);

                        if(!securityDecision.getRecords().isEmpty()){
                            update securityDecision.getRecords();
                        }
                        // update contactsToUpdate;
                    }
                }catch(Exception ex){
                    throw new IA_CustomException('The issue is related to update Insider JobApp On Contact');
                }
        }
    }
}