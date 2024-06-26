@isTest
private class Test_ESDJC_HeaderController {
	static testMethod void testHeaderController() {
		ESDJC_TestUtil.createSSOIdSetting();
		User u = ESDJC_TestUtil.getPortalUser('India','EMEA');
		
		user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission( u.id,'ES_DJC_Employee_APAC');
        }
        
		system.runAs(u){
			ESDJC_HeaderController con = new ESDJC_HeaderController();
			con.getStartURL();
		}
	}
}