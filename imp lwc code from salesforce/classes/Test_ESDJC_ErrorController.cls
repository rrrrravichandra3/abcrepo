@isTest
public with sharing class Test_ESDJC_ErrorController {
	static testMethod void testErrorController() {
		init();
		ESDJC_TestUtil.createSSOIdSetting();
		User u = ESDJC_TestUtil.getPortalUser('India','EMEA');
		user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission( u.id,'ES_DJC_Employee_APAC');
        }
		system.runAs(u){
			ESDJC_ErrorController con = new ESDJC_ErrorController();			
		}
	}
	
	private static void init(){
		ESDJC_Settings__c setting = new ESDJC_Settings__c();
		setting.Run_trigger__c = true;
		setting.Site_URL__c = '/site/url';
		setting.SSO_URL__c = 'test/services/auth';
		setting.Portal_User_Profile_Id__c = '00e70000000xEB1';
		setting.Concierge_API_User_Profile_Id__c = '00en0000000HgEa';
		setting.djc_Helpdesk_API_User__c = '00570000002SpX4AAK';
		insert setting;
		REWS_Setting__c rewsSetting = new REWS_Setting__c();
		rewsSetting.Mail_services_queue_Id__c = '00Gn0000000JH8YEAW';
		rewsSetting.Case_Package_Delivery_Record_Type__c = '00Gn0000000JH8YEAW';
		insert  rewsSetting;

	}
	
}