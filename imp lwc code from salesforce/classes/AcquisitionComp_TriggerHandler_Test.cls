/**
* Test Class for Acquisition_Compensation_TriggerHandler
* 
* Version      Date            Author                  Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         26-06-2023      Ashutosh Belwal         Initial Version
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@isTest
public class AcquisitionComp_TriggerHandler_Test {
    private Static String maESName = 'AcqcompTrigger';
    
    @testSetup 
    static void setupCompanyData() {
        
        UserRole role = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_ESROLE_NAME);
        profile userProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_EMPLOYEE_PROFILE);
        List<User> maUser = MA_TestUtil.createESUser(1, userProfile.Id, role.Id, true, maESName);
        
        PermissionSet maESPS = [SELECT Id FROM PermissionSet WHERE Name = :MA_TestUtilityValues.MA_ES_PERMSET LIMIT 1];
        MA_TestUtil.createPermissionsetAssignment(maESPS.Id, maUser[0].Id, true);
        
        System.runAs(maUser[0]){
            List<Acquisition_Company__c> lstCompany = MA_TestUtil.createAcquisitionCompany(1,true);
            List<Acquisition_Contacts__c> acqContactlist = MA_TestUtil.createAcqContact(1, lstCompany[0].Id, false);
            acqContactlist[0].Business_Title__c = '';
            acqContactlist[0].Executive__c = true;
            insert acqContactlist;
        }        
        
    }
    
    public static testMethod void test_copyOfferStatusToProvisionOnUpdate(){
        Map<Id, Acquisition_Compensation__c> oldMap = new Map<Id, Acquisition_Compensation__c>([SELECT Id, Acquisition_Contact__c, MuleExtId__c, Status__c 
                                                                                                FROM Acquisition_Compensation__c]);
        Map<Id, Acquisition_Compensation__c> newMap = new Map<Id, Acquisition_Compensation__c>([SELECT Id, Acquisition_Contact__c, MuleExtId__c, Status__c 
                                                                                                FROM Acquisition_Compensation__c]);
        for(Id compId : oldMap.keySet()){
            newMap.get(compId).Status__c = MA_TestUtilityValues.READY_TO_HARM_STATUS;
        }
        Test.startTest();
        Acquisition_Compensation_TriggerHandler.copyOfferStatusToProvisionOnUpdate(oldMap, newMap);
        Test.stopTest();
    }    
    
    public static testMethod void test_updateFieldOnCompInsertUpdate(){
        Map<Id, Acquisition_Compensation__c> oldMap = new Map<Id, Acquisition_Compensation__c>([SELECT Id, Acquisition_Contact__c, Pay_Rate_Type__c, Status__c,
                                                                                                Posting_Title__c, Job_Profile_Title__c, Job_Code__c
                                                                                                FROM Acquisition_Compensation__c]);
        Map<Id, Acquisition_Compensation__c> newMap = new Map<Id, Acquisition_Compensation__c>([SELECT Id, Acquisition_Contact__c, Pay_Rate_Type__c, Status__c,
                                                                                                Posting_Title__c, Job_Profile_Title__c, Job_Code__c
                                                                                                FROM Acquisition_Compensation__c]);
        for(Id compId : oldMap.keySet()){
            newMap.get(compId).Pay_Rate_Type__c = MA_TestUtilityValues.SALARY_PAY_RATE;
            newMap.get(compId).Job_Profile_Title__c = MA_TestUtilityValues.JOB_PROFILE_TITLE;
            newMap.get(compId).Job_Code__c = MA_TestUtilityValues.JOB_CODE_EXECUTIVE;
        }
        Boolean isNew = False;
        //This is on Update so Adding IsNew Field as False;
        Test.startTest();
        Acquisition_Compensation_TriggerHandler.updateFieldsOnAcqContact(isNew, newMap, oldMap);
        Test.stopTest();
    }
    
    public static testMethod void test_publishAutoEnrolmentEvents(){
        Map<Id, Acquisition_Compensation__c> oldMap = new Map<Id, Acquisition_Compensation__c>([SELECT Id, Acquisition_Contact__c, Pay_Rate_Type__c, Status__c 
                                                                                                FROM Acquisition_Compensation__c]);
        Map<Id, Acquisition_Compensation__c> newMap = new Map<Id, Acquisition_Compensation__c>([SELECT Id, Acquisition_Contact__c, Pay_Rate_Type__c, Status__c 
                                                                                                FROM Acquisition_Compensation__c]);
        for(Id compId : oldMap.keySet()){
            newMap.get(compId).Pay_Rate_Type__c = MA_TestUtilityValues.SALARY_PAY_RATE;
        }
        Test.startTest();
        Acquisition_Compensation_TriggerHandler.publishAutoEnrolmentEvents(newMap);
        Test.stopTest();
    }
    
    public static testMethod void test_updatePostingTitleOnCompensation(){
        Map<Id, Acquisition_Compensation__c> oldMap = new Map<Id, Acquisition_Compensation__c>([SELECT Id, Acquisition_Contact__c, Pay_Rate_Type__c, Status__c,
                                                                                                Posting_Title__c, Job_Profile_Title__c, Job_Code__c
                                                                                                FROM Acquisition_Compensation__c]);
        Map<Id, Acquisition_Compensation__c> newMap = new Map<Id, Acquisition_Compensation__c>([SELECT Id, Acquisition_Contact__c, Pay_Rate_Type__c, Status__c,
                                                                                                Posting_Title__c, Job_Profile_Title__c, Job_Code__c
                                                                                                FROM Acquisition_Compensation__c]);
        
        for(Id compId : oldMap.keySet()){
            newMap.get(compId).Posting_Title__c = MA_TestUtilityValues.POSTING_TITLE;
            newMap.get(compId).Job_Code__c = MA_TestUtilityValues.JOB_CODE_EXECUTIVE_0;
        }
        Boolean isNew = False;
        //This is on Update so Adding IsNew Field as False;
        Test.startTest();
        Acquisition_Compensation_TriggerHandler.updateFieldsOnAcqContact(isNew, newMap, oldMap);
        Test.stopTest();
    }    
}