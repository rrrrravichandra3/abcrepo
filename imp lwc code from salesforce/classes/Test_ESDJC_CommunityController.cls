@isTest(seeAllData=false)
private class Test_ESDJC_CommunityController{
	
    static testMethod void testCommunityHome() {
        
        ESDJC_TestUtil.createSSOIdSetting();
		User u = ESDJC_TestUtil.getPortalUser('India','EMEA');
		user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission( u.id,'ES_DJC_Employee_APAC');
        }
        ESDJC_TestUtil.createCommunitySetting();
        ESDJC_TestUtil.createRegionRecords();
        
        ESDJC_Settings__c esSetting = new ESDJC_Settings__c(VideoURL__c = 'test url');
        //insert esSetting;
        
        ESDJC_Content__c con = new ESDJC_Content__c(Content__c = 'test',name='test');
        insert con;
        ESDJC_ContryContent__c  countryContent = new ESDJC_ContryContent__c(ESDJC_Content__c = con.Id,ESDJC_Country__c = [select Id from ESDJC_Country__c where Name ='India'].Id);
        insert countryContent;
        
        System.runAs(u) {
        	PageReference pageRef = Page.ESDJC_Communities;
			Test.setCurrentPageReference(pageRef);
        	ESDJC_CommunityController cc = new ESDJC_CommunityController();
        	cc.ChangeCommunity();
        	cc.getContents();
        	system.assert(cc.showChat ==true); 
        	
        }
    } 

    
}