@RestResource(urlMapping='/NHWTestDataPrep')
@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
global without sharing class PF_NHW_TestDataPrepRestService {

    @HttpPost
    global static String createData(WDR_Candidate__c candidate, WDR_Job__c job, WDR_Application__c application, Boolean closePreboardingCase){
        
        PF_NHW_TestDataPrepHandler.createTestData(candidate, job, application, closePreboardingCase);
        
        candidate = [SELECT Id, Name, Email__c, Employee_Number__c, First_Name__c, Last_Name__c, Mailing_City__c, Mailing_Country__c, Mailing_Postal_Code__c, Mailing_State__c, Mailing_Street__c, Phone__c FROM WDR_Candidate__c WHERE Id = :candidate.Id];
        job = [SELECT Id, Name, Business_Unit__c, Business_Unit__r.Name, Company__c, Department__c, Department__r.Name, Employment_Type__c, Hiring_Manager__c, Job_Code__c, Job_Level__c, Job_Title__c, PCC__c, PCC__r.Name, Region__c, Target_Hire_Date__c FROM WDR_Job__c WHERE Id = :job.Id];
        application = [SELECT Id, Application_Step__c, Auto_Provisioning_Email_Sent__c, Business_Site__c, Candidate__c, Candidate_Stage__c, Do_Not_Send_NHW__c, Internal_Candidate__c, Job__c, NHW_Create_Preboarding_Case__c, Offer_Status__c, Offer_Type__c, Start_Date__c FROM WDR_Application__c WHERE Id = :application.Id];

        Map<String,Object> result = new Map<String,Object>();
        result.put('candidate', candidate);
        result.put('job', job);
        result.put('application', application);
        
        return JSON.serialize(result);
    }

    @HttpDelete
    global static void deleteRecordsForUser() {
        List<User> userIds = [SELECT Id FROM User WHERE Username =: RestContext.request.params.get('userName').deleteWhitespace()];

        if (!userIds.isEmpty()) {
            PF_NHW_DeleteTestDataBatch deleteTestDataBatch = new PF_NHW_DeleteTestDataBatch(userIds[0].Id);
            database.executeBatch(deleteTestDataBatch);
        }
    }
}