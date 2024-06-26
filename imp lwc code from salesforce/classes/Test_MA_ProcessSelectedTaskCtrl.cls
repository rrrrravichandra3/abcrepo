/**
* Test Class for MA_ProcessSelectedTaskCtrl
* 
* Version      Date            Author                  Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         23-10-2023      priyanka Kanani         Initial Version
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@isTest(SeeAllData=false)
public class Test_MA_ProcessSelectedTaskCtrl {
    private Static String maESName = 'processSelectedTask';
    @testSetup static void createTestData() {
        UserRole esrole = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_ESROLE_NAME);
        profile esuserProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_EMPLOYEE_PROFILE);
        List<User> maUser = MA_TestUtil.createESUser(1, esuserProfile.Id, esrole.Id, true, maESName);
        
        PermissionSet maESPS = [SELECT Id FROM PermissionSet WHERE Name = :MA_TestUtilityValues.MA_ES_PERMSET LIMIT 1];
        MA_TestUtil.createPermissionsetAssignment(maESPS.Id, maUser[0].Id, true);
        
        
    }
    
    @isTest static void test_MA_ProcessSelectedTaskCtrl(){
        User maESUser = [Select id from user where Email = :maESName + MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
        List<Acquisition_Company_Task__c> acqCompanyTasks = new List<Acquisition_Company_Task__c> ();
        
        System.runAs(maESUser){
            List<Acquisition_Company__c> listCompany = MA_TestUtil.createAcquisitionCompany(1,true);
            MA_TestUtil.createAcqContact(1, listCompany[0].Id, true);
            acqCompanyTasks = MA_TestUtil.createAcquisitionCompanyTask(listCompany[0].Id,2,true);
        }
        
        String query = 'SELECT Id FROM Acquisition_Company_Task__c WHERE Id IN :acqCompanyTasks';
        Database.QueryLocator queryLocator = Database.getQueryLocator(query);
        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(queryLocator);
        MA_ProcessSelectedTaskCtrl controller = new MA_ProcessSelectedTaskCtrl(stdController);
        
        Test.startTest();
        System.runAs(maESUser){
            controller.executeBatchClass();
            // Test the back() method
            PageReference pageRef = controller.back();
        }
        Test.stopTest();
        
        
    }
}