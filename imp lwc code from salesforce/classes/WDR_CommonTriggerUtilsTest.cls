// GHE Rollout Test Comment - 1/11/2018
/**
* @author Apuroop Gadde
* @date 06-28-2017
* @group Unit Test Classes
* @description Unit Test Class for WDR_CommonTriggerUtils Class
*/
@isTest
private class WDR_CommonTriggerUtilsTest {
    /**
    * @description Method to setup test data and configurations for unit tests
    **/
    @testSetup
    static void testSetup() {

    }

    /**
    * @description Method to test validate required fields with all required fields on a 
    * candidate object.
    **/
    @isTest
    static void testValidateRequiredFieldsWithNoMissingFieds() {
        WDR_Candidate__c testCandidate = new WDR_Candidate__c(Name='TestCandidate',First_Name__c = 'Ftest', Last_Name__c = 'LTest',Mailing_City__c = 'MCity',
                            Mailing_State__c = 'MState', Mailing_Country__c = 'MCountry',Mailing_Postal_Code__c = 'PostalCode', Mailing_Street__c = 'MStreet', 
                            Email__c = 'testEmail@test.com');
        try {
            insert testCandidate ;
        }
        catch(Exception e) {
            System.assert(false,'Assertion failed with exception'+e.getMessage());
        }
    }

    /**
    * @description Method to test validate required fields with required fields missing on a 
    * candidate object.
    **/
    @isTest
    static void testValidateRequiredFieldsWithMissingFieds() {
        WDR_Candidate__c testCandidate = new WDR_Candidate__c(Name='TestCandidate');
        try {
            insert testCandidate ;
        }
        catch(Exception e) {
            System.assertEquals(e.getTypeName(),'System.DmlException','Wrong exception thrown');
            return;
        }
        System.assert(false,'Exception not thrown');
    }

    /**
    * @description Method to test validate required fields with all required fields on an 
    * application object.
    **/
    @isTest
    static void testValidateRequiredFieldsWithMissingFiedsOnApplication() {
        WDR_Application__c testApplication = new WDR_Application__c();
        try {
            insert testApplication ;
        }
        catch(Exception e) {
            System.assertEquals(e.getTypeName(),'System.DmlException','Wrong exception thrown');
            return;
        }
        System.assert(false,'Exception not thrown');
    }

    /**
    * @description Method to test validate required fields with all required fields on a 
    * job requistion object.
    **/
    @isTest
    static void testValidateRequiredFieldsWithMissingFiedsOnJobReq() {
        WDR_Job__c testJobReq = new WDR_Job__c(Name='TestJobReq');
        try {
            insert testJobReq ;
        }
        catch(Exception e) {
            System.assertEquals(e.getTypeName(),'System.DmlException','Wrong exception thrown');
            return;
        }
        System.assert(false,'Exception not thrown');
    }

    /**
    * @description Method to test null Sobject type and empty list on validateRequiredFields
    **/
    @isTest
    static void testValidateRequiredFieldsWithNullSObjectType() {
        try {
            WDR_CommonTriggerUtils.validateRequiredFields(null,new List<SObject>());
        }
        catch(Exception e) {
            System.assert(false,'Asserion failed with Exception:'+e.getMessage());
        }
    }


}