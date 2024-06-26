/**
* @author Apuroop Gadde
* @date 06-29-2017
* @group Unit Test Classes
* @description Unit Test Class for WDR_TriggerFactoryTest Class
*/
@isTest
private class WDR_TriggerFactoryTest {
    /**
    * @description Method to setup test data and configurations for unit tests
    **/
    @testSetup 
    static void testSetup() {

    }

    /**
    * @description Method to test initiating Dispatcher with null object
    **/
    @isTest static void testInitiateDispatcherWithNullObject() {
    	WDR_TriggerFactory.initiateDispatcher(null);
    	System.assertEquals(WDR_TriggerFactory.objectDispatchers.keySet().size(),0);
    }

    /**
    * @description Method to test initiating Dispatcher with valid object
    **/
    @isTest static void testInitiateDispatcherWithValidObject() {
    	WDR_TriggerFactory.initiateDispatcher(WDR_Candidate__c.sObjectType);
    	System.assertEquals(WDR_TriggerFactory.objectDispatchers.keySet().size(),1);
    }

    /**
    * @description Method to test before and after insert event
    **/
    @isTest static void testBeforeAndAfterInsertOnExecuteWithValidObject() {
    	WDR_Candidate__c testCandidate = new WDR_Candidate__c(Name='TestCandidate',First_Name__c = 'Ftest', Last_Name__c = 'LTest',Mailing_City__c = 'MCity',
    						Mailing_State__c = 'MState', Mailing_Country__c = 'MCountry',Mailing_Postal_Code__c = 'PostalCode', Mailing_Street__c = 'MStreet', 
    						Email__c = 'testEmail@test.com');
    	try {
    		insert testCandidate;
    	}
    	catch(Exception e) {
    		System.assert(false, 'Assertion failed with message:'+e.getMessage());
    	}
    }

    /**
    * @description Method to test before and after update event
    **/
    @isTest static void testBeforeAndAfterUpdateOnExecuteWithValidObject() {
    	WDR_Candidate__c testCandidate = new WDR_Candidate__c(Name='TestCandidate',First_Name__c = 'Ftest', Last_Name__c = 'LTest',Mailing_City__c = 'MCity',
    						Mailing_State__c = 'MState', Mailing_Country__c = 'MCountry',Mailing_Postal_Code__c = 'PostalCode', Mailing_Street__c = 'MStreet', 
    						Email__c = 'testEmail@test.com');
    	insert testCandidate;
    	try {
    		testCandidate.Email__c = 'test345@test.com';
    		update testCandidate;
    	}
    	catch(Exception e) {
    		System.assert(false, 'Assertion failed with message:'+e.getMessage());
    	}
    }

    /**
    * @description Method to test before and after delete event
    **/
    @isTest static void testBeforeAndAfterDeleteOnExecuteWithValidObject() {
    	WDR_Candidate__c testCandidate = new WDR_Candidate__c(Name='TestCandidate',First_Name__c = 'Ftest', Last_Name__c = 'LTest',Mailing_City__c = 'MCity',
    						Mailing_State__c = 'MState', Mailing_Country__c = 'MCountry',Mailing_Postal_Code__c = 'PostalCode', Mailing_Street__c = 'MStreet', 
    						Email__c = 'testEmail@test.com');
    	insert testCandidate;
    	try {
    		delete testCandidate;
    	}
    	catch(Exception e) {
    		System.assert(false, 'Assertion failed with message:'+e.getMessage());
    	}
    }

    /**
    * @description Method to test after undelete event
    **/
    @isTest static void testAfterUnDeleteOnExecuteWithValidObject() {
    	WDR_Candidate__c testCandidate = new WDR_Candidate__c(Name='TestCandidate',First_Name__c = 'Ftest', Last_Name__c = 'LTest',Mailing_City__c = 'MCity',
    						Mailing_State__c = 'MState', Mailing_Country__c = 'MCountry',Mailing_Postal_Code__c = 'PostalCode', Mailing_Street__c = 'MStreet', 
    						Email__c = 'testEmail@test.com');
    	insert testCandidate;
    	delete testCandidate;    	
    	try {
    		undelete testCandidate;
    	}
    	catch(Exception e) {
    		System.assert(false, 'Assertion failed with message:'+e.getMessage());
    	}
    }
}