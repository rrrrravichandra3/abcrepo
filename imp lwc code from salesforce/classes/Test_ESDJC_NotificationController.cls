@isTest
private class Test_ESDJC_NotificationController {
	 
	static testMethod void testNotification() {
        ESDJC_TestUtil.createSSOIdSetting();
        User u = ESDJC_TestUtil.getPortalUser('India','EMEA');
        
		user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission( u.id,'ES_DJC_Employee_EMEA');
        }
        
	    ESDJC_Content__c content = new ESDJC_Content__c(Content__c = 'test',name='test');
        insert content;
        
        System.runAs(u) {
        	PageReference pageRef = Page.ESDJC_Notification;
			Test.setCurrentPageReference(pageRef);
        	
        	ApexPages.currentPage().getParameters().put('id',content.id);
			ApexPages.StandardController controller = new ApexPages.StandardController(content);
    		ESDJC_NotificationController con2 = new ESDJC_NotificationController(controller);
    	
        	
        }
	}    
}