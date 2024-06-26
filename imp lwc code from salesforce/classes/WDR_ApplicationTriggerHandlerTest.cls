/**
* @author Apuroop Gadde
* @date 06-30-2017
* @group Unit Test Classes
* @description Unit Test Class for WDR_ApplicationTriggerHandler Class
*/
@isTest
private class WDR_ApplicationTriggerHandlerTest {
    /**
    * @description Method to setup test data and configurations for unit tests
    **/
    @testSetup 
    static void testSetup() {


    }

    /**
    * @description Method to test initializing WDR_ApplicationTriggerHandler
    **/
    @isTest
    static void testConstructorForWDRApplicationHandler() {
        WDR_ApplicationTriggerHandler testApplicationHandler = new WDR_ApplicationTriggerHandler();
        System.assertNotEquals(testApplicationHandler,null,'Initializing Application handler returned null');
    }

    /**
    * @description Method to test before and after insert handlers on WDR Application
    **/
    @isTest
    static void testBeforeAndAfterInsertOnWDRApplicationHandler() {
        WDR_Candidate__c testCand = WDR_TestUtils.createWDRCandidate();
        WDR_Job__c testJob = WDR_TestUtils.createWDRJobReq('test Job');
        TF2_Business_Site__c testBusSite = WDR_TestUtils.createTestBusSite();
        WDR_Application__c testApp = new WDR_Application__c(Job__c = testJob.Id, Candidate__c = testCand.Id, Internal_Candidate__c = false, 
                                Business_Site__c = testBusSite.Id, Offer_Type__c = 'test Offer', Candidate_Stage__c = 'test status', 
                                Start_Date__c = Date.today().addDays(50));
        try {
            insert testApp;
        }
        catch(Exception e) {
            System.assert(false,'Assertion failed with Exception:'+e.getMessage());
        }
    }

    /**
    * @description Method to test before and after update handler on WDR Application
    **/
    @isTest
    static void testBeforeAndAfterUpdateOnWDRApplicationHandler() {
        WDR_Application__c testApp = WDR_TestUtils.createWDRApplication();
        testApp.Internal_Candidate__c = true;
        try {
            update testApp;
        }
        catch(Exception e) {
            System.assert(false,'Assertion failed with Exception:'+e.getMessage());
        }
    }

    /**
    * @description Method to test before and after delete handlers on WDR Application
    **/
    @isTest
    static void testBeforeAndAfterDeleteOnWDRApplicationHandler() {
        WDR_Application__c testApp = WDR_TestUtils.createWDRApplication();
        try {
            delete testApp;
        }
        catch(Exception e) {
            System.assert(false,'Assertion failed with Exception:'+e.getMessage());
        }
    }

    /**
    * @description Method to test after undelete handler on WDR Application
    **/
    @isTest
    static void testAfterUndeleteOnWDRApplicationHandler() {
        WDR_Application__c testApp = WDR_TestUtils.createWDRApplication();
        delete testApp;     
        try {
            undelete testApp;
        }
        catch(Exception e) {
            System.assert(false,'Assertion failed with Exception:'+e.getMessage());
        }
    }
}