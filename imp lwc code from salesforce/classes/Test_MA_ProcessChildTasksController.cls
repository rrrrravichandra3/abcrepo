/**
* Test Class for MA_AcqCompanyTaskProcessor
* 
* Version      Date            Author                  Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         23-10-2023      priyanka Kanani         Initial Version
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@IsTest
public class Test_MA_ProcessChildTasksController {
    private Static String maESName = 'processchildtask';
    @testSetup 
    static void setupCompanytaskData() {
        UserRole esrole = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_ESROLE_NAME);
        profile esuserProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_EMPLOYEE_PROFILE);
        List<User> maUser = MA_TestUtil.createESUser(1, esuserProfile.Id, esrole.Id, true, maESName);
        
        PermissionSet maESPS = [SELECT Id FROM PermissionSet WHERE Name = :MA_TestUtilityValues.MA_ES_PERMSET LIMIT 1];
        MA_TestUtil.createPermissionsetAssignment(maESPS.Id, maUser[0].Id, true);
        
        System.runAs(maUser[0]){
            List<Acquisition_Company__c> listCompany = MA_TestUtil.createAcquisitionCompany(1,true);
            
            List<Acquisition_Contacts__c> listAcqContacts = MA_TestUtil.createAcqContact(1, listCompany[0].Id, true);
            
            List<Acquisition_Company_Task__c> listCompanytask = MA_TestUtil.createAcquisitionCompanyTask(listCompany[0].Id,1,true);
        }
    }
    
    public static testMethod void test_executeCompanyTaskEnroller(){
        List<Acquisition_Company_Task__c> lstComptask = [SELECT Id, Acquisition_Company__c, Status__c, Active__c, Process_Status__c 
                                                         FROM Acquisition_Company_Task__c];
        Test.StartTest();
        MA_AcqCompanyTaskSelectEnroller.testJobEnqueued = true;
        MA_ProcessChildTasksController.executeCompanyTaskEnroller(lstComptask[0].Id);
        Test.StopTest();
    }
}