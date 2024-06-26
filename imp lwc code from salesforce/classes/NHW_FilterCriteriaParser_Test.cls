@isTest
public class NHW_FilterCriteriaParser_Test {

	private static final String ASSERT_DEFAULT_MESSAGE = 'Error parsing provisioning';

    @testSetup
    private static void setupTest(){
        NHW_TestDataHelper.loadProvisioningsTestData();
	}

    private static testmethod void parseProvisioningTest(){

        List<Case> provisioningCases = new List<Case>{
            new Case(Primary_Coverage_Country__c = 'Canada', NHW_Role__c = 'TestRole'),
            new Case(Primary_Coverage_Country__c = '100-United States of America', NHW_Role__c = 'Services'),
            new Case(Primary_Coverage_Country__c = '128-Brazil', NHW_Role__c = 'Support'),
            new Case(Primary_Coverage_Country__c = 'Canada', NHW_Role__c = 'Support', NH_ET_Team__c = 'Platinum'),
            new Case(Primary_Coverage_Country__c = 'Canada', NHW_Role__c = 'AB'),
            new Case(Primary_Coverage_Country__c = 'Canada', NHW_Role__c = 'CD'),
            new Case(Primary_Coverage_Country__c = 'Canada', NHW_Role__c = 'EF'),
            new Case(Primary_Coverage_Country__c = 'Canada', NHW_Role__c = null)};
                
		
		System.assertEquals(true, NHW_FilterCriteriaParser.parseProvisioning(provisioningCases[0], NHW_TestDataHelper.provisionings[0]), ASSERT_DEFAULT_MESSAGE);
		System.assertEquals(false, NHW_FilterCriteriaParser.parseProvisioning(provisioningCases[0], NHW_TestDataHelper.provisionings[1]), ASSERT_DEFAULT_MESSAGE);
        
		System.assertEquals(false, NHW_FilterCriteriaParser.parseProvisioning(provisioningCases[1], NHW_TestDataHelper.provisionings[0]), ASSERT_DEFAULT_MESSAGE);
		System.assertEquals(true, NHW_FilterCriteriaParser.parseProvisioning(provisioningCases[1], NHW_TestDataHelper.provisionings[1]), ASSERT_DEFAULT_MESSAGE);
        
		System.assertEquals(false, NHW_FilterCriteriaParser.parseProvisioning(provisioningCases[2], NHW_TestDataHelper.provisionings[0]), ASSERT_DEFAULT_MESSAGE);
		System.assertEquals(false, NHW_FilterCriteriaParser.parseProvisioning(provisioningCases[2], NHW_TestDataHelper.provisionings[1]), ASSERT_DEFAULT_MESSAGE);
        
		System.assertEquals(true, NHW_FilterCriteriaParser.parseProvisioning(provisioningCases[3], NHW_TestDataHelper.provisionings[0]), ASSERT_DEFAULT_MESSAGE);
		System.assertEquals(true, NHW_FilterCriteriaParser.parseProvisioning(provisioningCases[3], NHW_TestDataHelper.provisionings[1]), ASSERT_DEFAULT_MESSAGE);
        
		System.assertEquals(true, NHW_FilterCriteriaParser.parseProvisioning(provisioningCases[4], NHW_TestDataHelper.provisionings[4]), ASSERT_DEFAULT_MESSAGE);
		System.assertEquals(true, NHW_FilterCriteriaParser.parseProvisioning(provisioningCases[5], NHW_TestDataHelper.provisionings[4]), ASSERT_DEFAULT_MESSAGE);
		System.assertEquals(false, NHW_FilterCriteriaParser.parseProvisioning(provisioningCases[6], NHW_TestDataHelper.provisionings[4]), ASSERT_DEFAULT_MESSAGE);
        
		System.assertEquals(false, NHW_FilterCriteriaParser.parseProvisioning(provisioningCases[4], NHW_TestDataHelper.provisionings[5]), ASSERT_DEFAULT_MESSAGE);
		System.assertEquals(false, NHW_FilterCriteriaParser.parseProvisioning(provisioningCases[5], NHW_TestDataHelper.provisionings[5]), ASSERT_DEFAULT_MESSAGE);
		System.assertEquals(true, NHW_FilterCriteriaParser.parseProvisioning(provisioningCases[6], NHW_TestDataHelper.provisionings[5]), ASSERT_DEFAULT_MESSAGE);
        
		System.assertEquals(true, NHW_FilterCriteriaParser.parseProvisioning(provisioningCases[4], NHW_TestDataHelper.provisionings[6]), ASSERT_DEFAULT_MESSAGE);
		System.assertEquals(false, NHW_FilterCriteriaParser.parseProvisioning(provisioningCases[5], NHW_TestDataHelper.provisionings[6]), ASSERT_DEFAULT_MESSAGE);
		System.assertEquals(false, NHW_FilterCriteriaParser.parseProvisioning(provisioningCases[6], NHW_TestDataHelper.provisionings[6]), ASSERT_DEFAULT_MESSAGE);
        
		System.assertEquals(true, NHW_FilterCriteriaParser.parseProvisioning(provisioningCases[4], NHW_TestDataHelper.provisionings[7]), ASSERT_DEFAULT_MESSAGE);
		System.assertEquals(false, NHW_FilterCriteriaParser.parseProvisioning(provisioningCases[5], NHW_TestDataHelper.provisionings[7]), ASSERT_DEFAULT_MESSAGE);
		System.assertEquals(true, NHW_FilterCriteriaParser.parseProvisioning(provisioningCases[6], NHW_TestDataHelper.provisionings[7]), ASSERT_DEFAULT_MESSAGE);
        
		System.assertEquals(true, NHW_FilterCriteriaParser.parseProvisioning(provisioningCases[6], NHW_TestDataHelper.provisionings[8]), ASSERT_DEFAULT_MESSAGE);
		System.assertNotEquals(true, NHW_FilterCriteriaParser.parseProvisioning(provisioningCases[7], NHW_TestDataHelper.provisionings[9]), ASSERT_DEFAULT_MESSAGE);        
        System.assertEquals(false, NHW_FilterCriteriaParser.parseProvisioning(provisioningCases[6], NHW_TestDataHelper.provisionings[9]), ASSERT_DEFAULT_MESSAGE);
		System.assertNotEquals(false, NHW_FilterCriteriaParser.parseProvisioning(provisioningCases[7], NHW_TestDataHelper.provisionings[8]), ASSERT_DEFAULT_MESSAGE);

    }
        
}