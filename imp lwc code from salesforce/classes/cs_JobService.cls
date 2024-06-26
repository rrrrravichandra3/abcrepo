public without sharing class cs_JobService {
    
    @AuraEnabled
    public static List<WDR_Job__c> getOpenJobs() {
        return [SELECT Id, Name, Primary_Work_Location__c 
            FROM WDR_Job__c 
            WHERE Primary_Work_Location__c != null limit 5];

    }
}