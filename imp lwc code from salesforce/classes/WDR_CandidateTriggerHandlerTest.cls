/**
* @author Apuroop Gadde
* @date 06-30-2017
* @group Unit Test Classes
* @description Unit Test Class for WDR_CandidateTriggerHandler Class
*/
@isTest
private class WDR_CandidateTriggerHandlerTest {
	/**
    * @description Method to setup test data and configurations for unit tests
    **/
    @testSetup 
    static void testSetup() {

    }

    /**
    * @description Method to test initializing WDR_CandidateTriggerHandler
    **/
    @isTest
    static void testConstructorForWDRCandidateTriggerHandler() {
    	WDR_CandidateTriggerHandler testCandidateHandler = new WDR_CandidateTriggerHandler();
    	System.assertNotEquals(testCandidateHandler,null,'Initializing WDR Candidate handler returned null');
    }

    /**
    * @description Method to test before and after insert handlers on WDR Candidate
    **/
    @isTest
    static void testBeforeAndAfterInsertOnWDRCandidateTriggerHandler() {
        WDR_Candidate__c testCandidate = new WDR_Candidate__c(Name='TestCandidate',First_Name__c = 'Ftest', Last_Name__c = 'LTest',Mailing_City__c = 'MCity',
    						Mailing_State__c = 'MState', Mailing_Country__c = 'MCountry',Mailing_Postal_Code__c = 'PostalCode', Mailing_Street__c = 'MStreet', 
    						Email__c = 'testEmail@test.com');
    	try {
    		insert testCandidate;
    	}
    	catch(Exception e) {
    		System.assert(false,'Assertion failed with Exception:'+ e.getMessage());
    	}
    }

    /**
    * @description Method to test before and after update handlers on WDR Candidate
    **/
    @isTest
    static void testBeforeAndAfterUpdateOnWDRCandidateTriggerHandler() {
    	WDR_Candidate__c testCandidate = WDR_TestUtils.createWDRCandidate();
    	testCandidate.Email__c = 'updatedEmail@test.com';
    	try {
    		update testCandidate;
    	}
    	catch(Exception e) {
    		System.assert(false,'Assertion failed with Exception:'+ e.getMessage());
    	}
    }

    /**
    * @description Method to test before and after delete handlers on WDR Candidate
    **/
    @isTest
    static void testBeforeAndAfterDeleteOnWDRCandidateTriggerHandler() {
    	WDR_Candidate__c testCandidate = WDR_TestUtils.createWDRCandidate();
    	try {
    		delete testCandidate;
    	}
    	catch(Exception e) {
    		System.assert(false,'Assertion failed with Exception:'+ e.getMessage());
    	}
    }

    /**
    * @description Method to test after undelete handler on WDR Candidate
    **/
    @isTest
    static void testAfterUndeleteOnWDRCandidateTriggerHandler() {
    	WDR_Candidate__c testCandidate = WDR_TestUtils.createWDRCandidate();
    	delete testCandidate;    	
    	try {
    		undelete testCandidate;
    	}
    	catch(Exception e) {
    		System.assert(false,'Assertion failed with Exception:'+ e.getMessage());
    	}
    }	
}