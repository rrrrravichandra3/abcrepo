/**
* @author Apuroop Gadde
* @date 06-30-2017
* @group Unit Test Classes
* @description Unit Test Class for WDR_JobTriggerHandler Class
*/
@isTest
private class WDR_JobTriggerHandlerTest {
    /**
    * @description Method to setup test data and configurations for unit tests
    **/
    @testSetup 
    static void testSetup() {

    }

    /**
    * @description Method to test initializing WDR_JobHandler
    **/
    @isTest
    static void testConstructorForWDRJobHandler() {
        WDR_JobTriggerHandler testJobHandler = new WDR_JobTriggerHandler();
        System.assertNotEquals(testJobHandler,null,'Initializing WDR Job data validator returned null');
    }

    /**
    * @description Method to test before and after insert handlers on WDR Job
    **/
    @isTest
    static void testBeforeAndAfterInsertOnWDRJobHandler() {
        TF2_Company__c testCompany = WDR_TestUtils.createCompany();
        Business_Unit__c testBU = WDR_TestUtils.createBusinessUnit();
        TF2_Department__c testDep = WDR_TestUtils.createDepartment();
        TF2_PCC__c testPCC = WDR_TestUtils.createPrimaryCountryOfCoverage();
        User testHM = WDR_TestUtils.createHiringManagerWithNoHeirarchy('testFname','testLName');
        WDR_Job__c testJob = new WDR_Job__c(Name = 'test job',Job_Title__c = 'test job', Job_Code__c = 'test Code', Job_Level__c = 'test JL', Employment_Type__c = 'testET',
                                            Company__c = testCompany.Id, Business_Unit__c = testBU.Id , Department__c = testDep.Id, PCC__c = testPCC.Id, Division__c = 'testDiv',
                                            Region__c = 'AMER', Hiring_Manager__c = testHM.Id);
        try {
            insert testJob;
        }
        catch(Exception e) {
            System.assert(false,'Assertion failed with Exception:'+e.getMessage());
        }
    }

    /**
    * @description Method to test before and after update handlers on WDR Job
    **/
    @isTest
    static void testBeforeAndAfterUpdateOnWDRJobValidator() {
        WDR_Job__c testJob = WDR_TestUtils.createWDRJobReq('test Job');
        testJob.Region__c = 'update Region';
        try {
            update testJob;
        }
        catch(Exception e) {
            System.assert(false,'Assertion failed with Exception:'+e.getMessage());
        }
    }

    /**
    * @description Method to test before and after delete handlers on WDR Job
    **/
    @isTest
    static void testBeforeAndAfterDeleteOnWDRJobHandler() {
        WDR_Job__c testJob = WDR_TestUtils.createWDRJobReq('test Job for Delete');
        try {
            delete testJob;
        }
        catch(Exception e) {
            System.assert(false,'Assertion failed with Exception:'+e.getMessage());
        }
    }

    /**
    * @description Method to test after undelete handler on WDR Job
    **/
    @isTest
    static void testAfterUndeleteOnWDRJobHandler() {
        WDR_Job__c testJob = WDR_TestUtils.createWDRJobReq('test Job');
        delete testJob;     
        try {
            undelete testJob;
        }
        catch(Exception e) {
            System.assert(false,'Assertion failed with Exception:'+e.getMessage());
        }
    }   
}