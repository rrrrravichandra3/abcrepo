@isTest
public class NHW_BUCCJobProfileCategoryMatcher_Test {
    
    static{
        NHW_TestDataHelper.loadTableauProfilesTestData();
    }
    
    
        private static testmethod void matchProfilesTest(){
        
        Case provisioningCase = new Case(NHW_Business_Unit__c = NHW_TestDataHelper.businessUnits[0].Id,
                                        NHW_Cost_Center__c = NHW_TestDataHelper.costCenters[0].Id,Business_Title__c = 'Tableau Success Technician (Tier 2)');
        
        List<NH_Profile__c> profilesTest = [SELECT Id, Name, Grouping_Category__c FROM NH_Profile__c WHERE Grouping_Category__c = 'BU CC JobProfile'];
        
        NHW_BUCCJobProfileCategoryMatcher matcher = new NHW_BUCCJobProfileCategoryMatcher();
        profilesTest = matcher.matchProfiles(provisioningCase, profilesTest);
        
        System.assertEquals(1, profilesTest.size(), 'Correct list of profiles returned by BUCCJobProfileCategoryMatcher');

    }

}