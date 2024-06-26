/**
* Test Class for MA_ACTaskTriggerHandler,MA_ACTaskTriggerHelper,MA_ACTaskTriggerUtility
* 
* Version      Date            Author                  Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         31-08-2023      priyanka Kanani         Initial Version
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@IsTest
public class Test_MA_ACTaskTriggerHelper {
    private Static String maESName = 'AcqTaskHelper';

    @testSetup 
    static void setupCompanytaskData() {
        UserRole role = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_ESROLE_NAME);
        profile userProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_EMPLOYEE_PROFILE);
        List<User> maUser = MA_TestUtil.createESUser(1, userProfile.Id, role.Id, true, maESName);
        
        PermissionSet maESPS = [SELECT Id FROM PermissionSet WHERE Name = :MA_TestUtilityValues.MA_ES_PERMSET LIMIT 1];
        MA_TestUtil.createPermissionsetAssignment(maESPS.Id, maUser[0].Id, true);
        
        System.runAs(maUser[0]){
            List<Acquisition_Company__c> lstCompany = MA_TestUtil.createAcquisitionCompany(1,true);
            MA_TestUtil.createAcqContact(1, lstCompany[0].Id, true);
            List<Acquisition_Company_Task__c> lstCompanytask = MA_TestUtil.createAcquisitionCompanyTask(lstCompany[0].Id,1,false);
            lstCompanytask[0].Process_Status__c = MA_TestUtilityValues.STATUS_NEW;
            insert lstCompanytask;
        }
    }
    
    public static testMethod void test_handlebeforeInsert(){
        List<Acquisition_Company_Task__c> listComptask = [SELECT Id, Acquisition_Company__c, Status__c, Active__c, Process_Status__c 
                                                         FROM Acquisition_Company_Task__c];
        Test.StartTest();
        	MA_ACTaskTriggerHelper.handleBeforeInsert(listComptask);
        Test.StopTest();
        Assert.isNotNull(listComptask[0].Id);
    }
    
    public static testMethod void test_handleBeforeUpdate(){
        List<Acquisition_Company_Task__c> listComptask = [SELECT Id, Acquisition_Company__c, Status__c, Active__c, Process_Status__c 
                                                          FROM Acquisition_Company_Task__c];
        User maESUser = [Select id from user where Email = :maESName + MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
        List<Acquisition_Company_Task__c> updatelist = new List<Acquisition_Company_Task__c>();
        for(Acquisition_Company_Task__c comptask : listComptask){
            comptask.Process_Status__c = MA_TestUtilityValues.STATUS_CHNAGES_IN_PROGRESS;
            updatelist.add(comptask);
        }
        Test.StartTest();
        System.runAs(maESUser){
            update updatelist;
        }
        Test.StopTest();
        Assert.isTrue(updatelist[0].Process_Status__c == MA_TestUtilityValues.STATUS_CHNAGES_IN_PROGRESS);
     }
    
    public static testMethod void test_handleBeforeDelete(){
        List<Acquisition_Company_Task__c> listComptask = [SELECT Id, Acquisition_Company__c, Status__c, Active__c, Process_Status__c 
                                                         FROM Acquisition_Company_Task__c];
        User maESUser = [Select id from user where Email = :maESName + MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
        Test.StartTest();
        System.runAs(maESUser){
            delete listComptask;
        }
        Test.StopTest();
        Assert.areEqual(0, [SELECT COUNT() FROM Acquisition_Company_Task__c WHERE Id = :listComptask[0].id]);
        
    }
    
    public static testMethod void test_ChangeTasktoInactive(){
        List<Acquisition_Company_Task__c> listComptask = [SELECT Id, Acquisition_Company__c, Status__c, Active__c, Process_Status__c 
                                                         FROM Acquisition_Company_Task__c];
        User maESUser = [Select id from user where Email = :maESName + MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
        List<Acquisition_Company_Task__c> updatelist = new List<Acquisition_Company_Task__c>();
        for(Acquisition_Company_Task__c comptask : listComptask){
           	comptask.Process_Status__c = MA_TestUtilityValues.STATUS_CHANGES_PENDING;
            comptask.Active__c = false;
            updatelist.add(comptask);
        }
        Test.StartTest();
        System.runAs(maESUser){
            update updatelist;
        }
        Test.StopTest();
        Assert.isTrue(updatelist[0].Active__c == false);
     }
    
    public static testMethod void test_TaskStatusUpdate(){
        List<Acquisition_Company_Task__c> listComptask = [SELECT Id, Acquisition_Company__c, Status__c, Active__c, Process_Status__c 
                                                         FROM Acquisition_Company_Task__c];
        User maESUser = [Select id from user where Email = :maESName + MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
        List<Acquisition_Company_Task__c> updatelist = new List<Acquisition_Company_Task__c>();
        for(Acquisition_Company_Task__c comptask : listComptask){
           	comptask.Process_Status__c = MA_TestUtilityValues.STATUS_CHNAGES_COMPLETE;
            updatelist.add(comptask);
        }
        Test.StartTest();
        System.runAs(maESUser){
            update updatelist;
        }
        Test.StopTest();
        Assert.isTrue(updatelist[0].Process_Status__c == MA_TestUtilityValues.STATUS_CHNAGES_COMPLETE);
     }
    
}