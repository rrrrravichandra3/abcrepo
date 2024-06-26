@isTest
public with sharing class CEMCI_Test_Util {

    public static void createCEMCICustomSetting(){
        insert new CEMCI_Settings__c(
            Account_Owner_Profile_Id__c = '00e4u000001n9bX',
            Account_Owner_Role__c = 'Do_NOT_Create_SubOrd_SharingRules',
            Account_Ownership_Limit__c = 20000,
            Auto_Merge_Lead_to_Lead_Limits__c = 0.8000,
            Bypass_Lead_Dedupe__c = false,
            CEMCI_Default_Lead_Owner__c = '0054u000006dKW4AAM',
            Converted_Lead_Status__c = 'Converted',
            EligibleTaskSubjectsforLeadScore__c	= 'Connected,Screen Completed,Submitted to Recruiter,Submitted to Hiring Manager',
            Executive_Recruiting_Queue_Id__c = '00G0g000004PZmZ',
            GlobalValueSet_API_Version__c = 'v47.0',
            OSR_Global_Queue_Id__c = '00G0g000004PZma',
            ScaleR_Changes_Live__c = false
        );
    }
}