public with sharing class PrehireCommunityCaseService {

    static Id provisioningRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('New_Hire_Process_Onboarding').getRecordTypeId();
    static Id preboardingRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('New_Hire_Process').getRecordTypeId();

    public static List<Case> getProvisioningCases(Id contactId) {
        return [select id from case where NHW_Employee__c =: contactId and recordtypeid =:provisioningRecordType and status NOT IN ('Closed','Closed - Cancelled')  order by createddate DESC];
    }
    
    public static List<Case> getPreboardingCases(Id contactId) {
        return [select id from case where NHW_Employee__c =: contactId and recordtypeid =:preboardingRecordType and status = 'Closed' order by createddate DESC];
    }
    
}