@isTest (seeAllData=false)
private class Test_ESDJC_SidebarController {
	    
    private static testmethod void testErgoVisibilityForAMER() {
        ESDJC_TestUtil.createSSOIdSetting();
        User portalUser = ESDJC_TestUtil.getPortalUser('United States','Americas - USA');
        user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission(portalUser.id,'ES_DJC_Employee_AMER');
        }        
        system.runAs(portalUser){
            ESDJC_SidebarController con = new ESDJC_SidebarController();
            system.assertEquals(true, con.showErgo);
    	}
    }
    
    private static testmethod void testErgoVisibilityForAPAC() {
        ESDJC_TestUtil.createSSOIdSetting();
        User portalUser = ESDJC_TestUtil.getPortalUser('India','APAC - All Countries');
        user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission(portalUser.id,'ES_DJC_Employee_APAC');
        }        
        system.runAs(portalUser){
            ESDJC_SidebarController con = new ESDJC_SidebarController();
            system.assertEquals(false, con.showErgo);
    	}
    }

    //Commenting as this method is not relevant anymore DJC_Wellness_Health_Policy__c -> migrated to Reimbursement_Policy__mdt 
    /*private static testmethod void testWellnessVisibilityForAPAC() {
        Test_Wellness_Util.init();
        ESDJC_TestUtil.createSSOIdSetting();
        User portalUser = ESDJC_TestUtil.getPortalUser('India','APAC - All Countries');
        user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission(portalUser.id,'ES_DJC_Employee_APAC');
        }        
        system.runAs(portalUser) {
            ESDJC_SidebarController con = new ESDJC_SidebarController();
            system.assertEquals(true, con.showWellness);
    	}        
    }*/
    
    private static testmethod void testWellnessVisibilityForAMER() {
        Test_Wellness_Util.init();
        ESDJC_TestUtil.createSSOIdSetting();
        User portalUser = ESDJC_TestUtil.getPortalUser('United States','Americas - USA');
        user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission(portalUser.id,'ES_DJC_Employee_AMER');
        }        
        system.runAs(portalUser) {
            ESDJC_SidebarController con = new ESDJC_SidebarController();
            system.assertEquals(false, con.showWellness);
    	}        
    }    
}