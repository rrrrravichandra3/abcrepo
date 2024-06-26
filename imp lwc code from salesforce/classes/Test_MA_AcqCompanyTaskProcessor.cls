/**
* Test Class for MA_AcqCompanyTaskProcessor
* 
* Version      Date            Author                  Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         23-10-2023      priyanka Kanani         Initial Version
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@isTest(SeeAllData=false)
public class Test_MA_AcqCompanyTaskProcessor {
    
    private Static String maESName = 'AcqCompanyTaskProcess';
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
        Set<Id> selectedTaskIds = new Set<Id>();
        System.runAs(maESUser){
            List<Acquisition_Company__c> listCompany = MA_TestUtil.createAcquisitionCompany(1,true);
            MA_TestUtil.createAcqContact(1, listCompany[0].Id, true);
            acqCompanyTasks = MA_TestUtil.createAcquisitionCompanyTask(listCompany[0].Id,1,false);
            for(Acquisition_Company_Task__c comTask: acqCompanyTasks){
                comTask.Process_Status__c = 'Changes Pending';
            }
            insert acqCompanyTasks;
        }
        for(Acquisition_Company_Task__c comTask: acqCompanyTasks){
            selectedTaskIds.add(comTask.Id);
        }
        
        Test.startTest();
        MA_AcqCompanyTaskSelectEnroller.testJobEnqueued = true;
        MA_AcqCompanyTaskEnrolWrapper.TaskEnrollerConfig batchConfig = MA_AcqCompanyTaskEnrollerHelper.getBatchConfig();
        MA_AcqCompanyTaskProcessor batchJob = new MA_AcqCompanyTaskProcessor(batchConfig, selectedTaskIds);
        Database.executeBatch(batchJob, batchConfig.batchSize);
        Test.stopTest();
        
        
    }
    
    @isTest static void test_MA_scheduleBatch(){
        User maESUser = [Select id from user where Email = :maESName + MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
        
        Test.startTest();
        System.runAs(maESUser){
            MA_AcqCompanyTaskEnrolWrapper.TaskEnrollerConfig batchConfig = MA_AcqCompanyTaskEnrollerHelper.getBatchConfig();
            new MA_AcqCompanyTaskProcessor(batchConfig);
            new MA_AcqCompanyTaskProcessor(null).execute(null);
        }
        Test.stopTest();
    }

}