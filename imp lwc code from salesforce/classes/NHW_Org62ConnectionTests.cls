@isTest

private class NHW_Org62ConnectionTests{
    
    private static String accessToken = 'testToken'; 
    
    //test getCampaignmembers from org62.. 

    private static testMethod void testFetchCampaigns(){
        NHW_Org62Service.Org62Data org62Results = new NHW_Org62Service.Org62Data();
        org62Results.campaignList = new List<NHW_Org62Service.CampaignResult>();
        org62Results.campaignMemberList = new List<NHW_Org62Service.CampaignMemberResult>();
        Test.startTest(); 
        NHW_TestFactory.prepareMockResponse('MockCampaignResponse',200); 
        NHW_Org62Service.accessToken = accessToken; // hardcode some dummy auth Token; 
        org62Results = NHW_Org62Service.getCampaignResults('testContact@salesforce.com','Test Contact'); 
        Test.stopTest(); 
        //assert that 1 campaign is fetched from org62.. 
        System.assertEquals(1, org62Results.campaignList.size());
         

    }

    //test createCampaignmembers 

    private static testMethod void testCampaignMembers(){
        Test.startTest(); 
        NHW_TestFactory.prepareMockResponse('MockCampaignMembersResponse',200); 
        NHW_Org62Service.accessToken = accessToken; // hardcode some dummy auth Token; 
        NHW_Org62Service.org62CallOut('createCampaignMember',new List<String>{'campaignrecordidtest'},'contactInfo','Test CampaignMember'); // pass test campaignId and contactInfo.
        //assert response.. 
        Test.stopTest(); 
    }

   

    


}