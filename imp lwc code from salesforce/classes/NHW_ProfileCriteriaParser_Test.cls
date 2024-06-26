@isTest
public class NHW_ProfileCriteriaParser_Test {

	static{
        NHW_TestDataHelper.loadProfilesTestData();
        NHW_TestDataHelper.loadProvisioningsTestData();
    }
    
    private static testmethod void parseProvisioningsTest(){
        
        List<Case> provisioningCases = new List<Case>{
            new Case(NHW_Business_Unit__c = NHW_TestDataHelper.businessUnits[2].Id,
                     Cost_Center_NHW__c = NHW_TestDataHelper.costCenters[2].Id),
			new Case(NHW_Business_Unit__c = NHW_TestDataHelper.businessUnits[3].Id,
                     Cost_Center_NHW__c = NHW_TestDataHelper.costCenters[3].Id)};
                         
        List<NHW_Provisioning__c> provisionings = NHW_ProfileCriteriaParser.parseProvisionings(provisioningCases[0], new List<NHW_Provisioning__c>{NHW_TestDataHelper.provisionings[2], NHW_TestDataHelper.provisionings[3]});
        System.assertEquals(1, provisionings.size(), 'Number of provisionings returned is incorrect');
        System.assertEquals(NHW_TestDataHelper.provisionings[3].Id, provisionings[0].Id);
        
        provisionings = NHW_ProfileCriteriaParser.parseProvisionings(provisioningCases[1], new List<NHW_Provisioning__c>{NHW_TestDataHelper.provisionings[2], NHW_TestDataHelper.provisionings[3]});
        System.assertEquals(1, provisionings.size(), 'Number of provisionings returned is incorrect');
        System.assertEquals(NHW_TestDataHelper.provisionings[3].Id, provisionings[0].Id);
    }
}