/**
* @description : This Implements IA_InsiderTrackingReminderEmailHandler to perform login checks to send reminder email to candidate if no ServiceAppointment exists within 24rs of candidate login
* @author Manish Pal
* @date 11/10/2022
*
* specific to  Peopleforce
*/
public with sharing class IA_InsiderTrackingReminderEmailHandler {
    /**
     * @description : This method is invoked to check if a candidate needs a reminder email if no ServiceAppointment exists within 24hrs of candidate login.
     * @param NewListTracking : A list of Insiders_Tracking__c records containing candidate login details and email.
     */
    @InvocableMethod
    public static void invokeReminderEmailTrigger(List<Insiders_Tracking__c> NewListTracking){
        
        List<String> emailofInsiderTrackingRecord = new List<String>();
        List<ServiceAppointment> allServiceApp = new List<ServiceAppointment>();
        DateTime candidateLogin = NewListTracking[0].Candidate_Login__c + 1;
        
        for(Insiders_Tracking__c i:NewListTracking){
            if(i.Candidate_Email__c!=NULL && i.Reminder_Email_Sent__c == false){
                emailofInsiderTrackingRecord.add(i.Candidate_Email__c);
            }
        }
        Map<String,List<Id>> applicationIdsMap = retunInternalOrExternalApplication(emailofInsiderTrackingRecord);//returns application Ids for internal or external
        
        //Return if Candidate has any ServiceAppointment within 24hrs of First time login
        allServiceApp = [Select id from ServiceAppointment where Contact.email = :emailofInsiderTrackingRecord[0] 
                         AND CreatedDate >= :NewListTracking[0].Candidate_Login__c 
                         AND CreatedDate<= :candidateLogin];
        if(allServiceApp.isEmpty()){
            processApplicationtoUpdateIVT(applicationIdsMap,emailofInsiderTrackingRecord);//to update reminder checkox in IVT along with sending emails to candidate
        }
    }
    
    /**
     * @description : This method is used to return a map containing the internal and external application ids for the given email addresses of Insider Tracking records.
     * @param emailofInsiderTrackingRecord : A list of strings containing the email addresses of Insider Tracking records.
     * @return Map<String,List<Id>> : A map containing the internal and external application ids for the given email addresses.
     */
    public static Map<String,List<Id>> retunInternalOrExternalApplication(List<String> emailofInsiderTrackingRecord){
        
        List<String> externalCandidateStages = IA_Util.eligibleCandidateStages;
        List<String> internalCandidateStages = IA_Util.eligibleCandidateStagesForInternal;
        Map<String,List<Id>> returnMap = new Map<String,List<Id>>(); 
        List<WDR_Application__c> allApplication = [Select id,name,Internal_Candidate__c,Candidate_Stage__c from WDR_Application__c where Candidate_Email__c IN :emailofInsiderTrackingRecord WITH SECURITY_ENFORCED];
        List<Id> allInternalApplicationIds = new List<Id>();
        List<Id> allExternalApplicationIds = new List<Id>();   
        for(WDR_Application__c all:allApplication){
            if(all.Internal_Candidate__c == True){
                if(internalCandidateStages.contains(all.Candidate_Stage__c)){
                    allInternalApplicationIds.add(all.id);
                }
            }
            else {
                if(externalCandidateStages.contains(all.Candidate_Stage__c)){
                    allExternalApplicationIds.add(all.id);
                }
            }
        }
        returnMap.put('Internal',allInternalApplicationIds);
        returnMap.put('External',allExternalApplicationIds);
        return returnMap;
    }
    /**
     * @description This method is used to update the Insiders_Tracking__c records to mark them as having sent a reminder email.
     * It also handles any errors that may occur during the email sending process and sends an exception email to the configured recipients.
     *
     * @param applicationIdsMap A map containing the internal and external application ids for the given email addresses of Insider Tracking records.
     * @param emailofInsiderTrackingRecord A list of strings containing the email addresses of Insider Tracking records.
     */
    public static void processApplicationtoUpdateIVT(Map<String,List<Id>> applicationIdsMap,List<String> emailofInsiderTrackingRecord){
        List<Insiders_Tracking__c> updateIVTRecords = new List<Insiders_Tracking__c>();
        List<String> failedRecordIds = new List<String>();
        List<Id> listOfId = new List<Id>(); 
        
        for(List<ID> Ids:applicationIdsMap.values()){
            for(Id idsAdd:Ids){
                listOfId.add(idsAdd);
            }
        }
        if(Schema.sObjectType.Insiders_Tracking__c.fields.Reminder_Email_Sent__c.isUpdateable()){
        for(Insiders_Tracking__c i:[Select id,name,Reminder_Email_Sent__c from Insiders_Tracking__c where WD_Job_Application__c IN :listOfId 
                                    AND Reminder_Email_Sent__c = false]){
                                        i.Reminder_Email_Sent__c = true;
                                        updateIVTRecords.add(i);
                                    }
           }
        
        try{
            if(updateIVTRecords.size()>0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, updateIVTRecords);

                if(!securityDecision.getRecords().isEmpty()){
                    update securityDecision.getRecords();
                }
                //update updateIVTRecords;
            }
        }
        catch(exception ex){
            String errorMessage = IA_Util.buildErrorMessage(UserInfo.getUserEmail(), null, 'Reminder Email Flow ', ex.getMessage(), ex.getStackTraceString());
            failedRecordIds.add(updateIVTRecords[0].Id + ' - ' + errorMessage + '\n');
        }
        if (failedRecordIds.size() > 0) {
            String errorMessage = 'The following records have encountered an error when sending the Reminder Email to Insiders App to Candidates: \n';
            errorMessage += String.join(failedRecordIds, ', ');
            IA_Util.sendExceptionMail(new List<String>{ errorMessage });
        }
        if(updateIVTRecords.size()>0){
            sendReminderEmailToCandidate(emailofInsiderTrackingRecord);//Send Email to Candidate
        }
    }
    
    /**
     * @description This method is used to send a reminder email to the candidate if no ServiceAppointment exists within 24hrs of candidate login.
     * @param emailofInsiderTrackingRecord A list of strings containing the email addresses of Insider Tracking records.
     */
    public static void sendReminderEmailToCandidate(List<String> emailofInsiderTrackingRecord){
        List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
        String customLoginAccessImplClass = IA_Util.InsiderConfigDefaultRec.Internal_Login_Access_Class_Name__c;
        Type t = Type.forName(customLoginAccessImplClass);
        OrgWideEmailAddress senderAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'insiders@salesforce.com' LIMIT 1];
        WDR_Candidate__c[] getWDRCandidate = [SELECT Id, Email__c, Candidate_Contact__c from WDR_Candidate__c where Email__c in :emailofInsiderTrackingRecord LIMIT 1];
        List<Contact> c = [Select id from Contact where Id = :getWDRCandidate[0].Candidate_Contact__c];
        EmailTemplate tpl = (EmailTemplate)[select Id FROM EmailTemplate WHERE Name = 'Insiders Candidate 24Hours Reminder' limit 1];
        if(getWDRCandidate.size() > 0) {
            string[] candidateEmail = new string[] {getWDRCandidate[0].Email__c};
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(tpl.Id);
            mail.setTargetObjectId(c[0].id);
            mail.setWhatId(getWDRCandidate[0].id);
            mail.setOrgWideEmailAddressId(senderAddress.Id);
            mail.setToAddresses(candidateEmail);
            if(!test.isRunningTest()){
                results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            if (results.size()>0 && !results[0].success) {
                Insiders_App_Config__mdt appConfig = Insiders_App_Config__mdt.getAll().values()[0];
                String emailIdsFromAppConfig = appConfig.Email_Addresses_for_Exceptions__c;
                if(String.isEmpty(emailIdsFromAppConfig) == true) {
                    return;
                }
                List<String> emailIds = emailIdsFromAppConfig.split(',');
                Messaging.SingleEmailMessage mailError = new Messaging.SingleEmailMessage();
                
                mailError.setToAddresses(emailIds);
                mailError.setSenderDisplayName('Insiders App - Reminder Email Failure');
                mailError.setSubject('Errors that occurred when reminder email to candidate');
                mailError.setPlainTextBody('Insiders app candidate reminder email error details:' + results[0].getErrors());
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailError });
            }
        }
    }
}