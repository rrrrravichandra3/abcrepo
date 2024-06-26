/**
* @author Apuroop Gadde
* @date 06-30-2017
* @group Unit Test Classes
* @description Unit Test Class for WDR_CandidateTriggerDataValidator Class
*/
@isTest
private class WDR_CandidateTriggerDataValidatorTest {
	/**
    * @description Method to setup test data and configurations for unit tests
    **/
    @testSetup 
    static void testSetup() {


    }

    /**
    * @description Method to test initializing WDR_CandidateDataValidator
    **/
    @isTest
    static void testConstructorForWDRCandidateDataValidator() {
    	WDR_CandidateTriggerDataValidator testCandidateDataValidator = new WDR_CandidateTriggerDataValidator();
    	System.assertNotEquals(testCandidateDataValidator,null,'Initializing WDR Candidate data validator returned null');
    }

    /**
    * @description Method to test before and after insert validation on WDR Candidate
    **/
    @isTest
    static void testBeforeAndAfterInsertOnWDRCandidateDataValidator() {
        WDR_Candidate__c testCandidate = new WDR_Candidate__c(Name='TestCandidate',First_Name__c = 'Ftest', Last_Name__c = 'LTest',Mailing_City__c = 'MCity',
    						Mailing_State__c = 'MState', Mailing_Country__c = 'MCountry',Mailing_Postal_Code__c = 'PostalCode', Mailing_Street__c = 'MStreet', 
    						Email__c = 'testEmail@test.com');
    	try {
    		insert testCandidate;
    	}
    	catch(Exception e) {
    		System.assert(false,'Assertion failed with Exception:'+e.getMessage());
    	}
    }

    /**
    * @description Method to test before and after update validation on WDR Candidate
    **/
    @isTest
    static void testBeforeAndAfterUpdateOnWDRCandidateValidator() {
    	WDR_Candidate__c testCandidate = WDR_TestUtils.createWDRCandidate();
    	testCandidate.Email__c = 'updatedEmail@test.com';
    	try {
    		update testCandidate;
    	}
    	catch(Exception e) {
    		System.assert(false,'Assertion failed with Exception:'+e.getMessage());
    	}
    }

    /**
    * @description Method to test before and after delete validation on WDR Candidate
    **/
    @isTest
    static void testBeforeAndAfterDeleteOnWDRCandidateDataValidator() {
    	WDR_Candidate__c testCandidate = WDR_TestUtils.createWDRCandidate();
    	try {
    		delete testCandidate;
    	}
    	catch(Exception e) {
    		System.assert(false,'Assertion failed with Exception:'+e.getMessage());
    	}
    }

    /**
    * @description Method to test after undelete validation on WDR Candidate
    **/
    @isTest
    static void testAfterUndeleteOnWDRCandidateDataValidator() {
    	WDR_Candidate__c testCandidate = WDR_TestUtils.createWDRCandidate();
    	delete testCandidate;    	
    	try {
    		undelete testCandidate;
    	}
    	catch(Exception e) {
    		System.assert(false,'Assertion failed with Exception:'+e.getMessage());
    	}
    }	
}