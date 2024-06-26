@isTest
public class NHW_BUCCCategoryMatcher_Test {

    private static final String MSG_WRONG_LIST_OF_PROFILES = 'Wrong list of profiles returned by BUCCCategoryMatcher';

    static{
        NHW_TestDataHelper.loadProfilesTestData();
    }

    private static testmethod void matchProfilesTest(){
        
        Case provisioningCase = new Case(NHW_Business_Unit__c = NHW_TestDataHelper.businessUnits[0].Id,
                                        NHW_Cost_Center__c = NHW_TestDataHelper.costCenters[0].Id);
        
        List<NH_Profile__c> profilesTest = [SELECT Id, Name, Grouping_Category__c FROM NH_Profile__c WHERE Type__c = 'Organization'];
        
        NHW_BUCCCategoryMatcher matcher = new NHW_BUCCCategoryMatcher();
        profilesTest = matcher.matchProfiles(provisioningCase, profilesTest);
        
        System.assertEquals(3, profilesTest.size(), MSG_WRONG_LIST_OF_PROFILES);

        System.assert(NHW_TestDataHelper.profiles[0].Id == profilesTest[0].Id || NHW_TestDataHelper.profiles[0].Id == profilesTest[1].Id || NHW_TestDataHelper.profiles[0].Id == profilesTest[2].Id, MSG_WRONG_LIST_OF_PROFILES);
        System.assert(NHW_TestDataHelper.profiles[2].Id == profilesTest[0].Id || NHW_TestDataHelper.profiles[2].Id == profilesTest[1].Id || NHW_TestDataHelper.profiles[2].Id == profilesTest[2].Id, MSG_WRONG_LIST_OF_PROFILES);
        System.assert(NHW_TestDataHelper.profiles[3].Id == profilesTest[0].Id || NHW_TestDataHelper.profiles[3].Id == profilesTest[1].Id || NHW_TestDataHelper.profiles[3].Id == profilesTest[2].Id, MSG_WRONG_LIST_OF_PROFILES);
    }
}