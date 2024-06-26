public with sharing class EmploymentApplicationTriggerHelper{

    //For new records, if Electronic_Consent_NDA__c is checked, populate Date_Signed_NDA__c as Today's Date
    public static void populateSignedDateNDADateInsert(list<Employment_Application__c > newEmpAppRecords){
        for(Employment_Application__c currRecord : newEmpAppRecords){
           if(currRecord.Electronic_Consent_NDA__c == true){
           }
        }
    }
    
    //For existing records, if Electronic_Consent_NDA__c changed from False to True, populate Date_Signed_NDA__c as Today's Date
    public static void populateSignedDateNDADateUpdate(Map<Id,Employment_Application__c> oldRecMap,Map<Id,Employment_Application__c> newRecMap){
        for(Employment_Application__c currNewRecord : newRecMap.values()){
           if(((oldRecMap.get(currNewRecord.Id)).Electronic_Consent_NDA__c == false) && (currNewRecord.Electronic_Consent_NDA__c == true)){
           }
        }
    }
}