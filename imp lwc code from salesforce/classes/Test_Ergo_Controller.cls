@isTest
public with sharing class Test_Ergo_Controller {

	static testMethod void testIsErgoPresent(){

		User sysAdm = ESDJC_TestUtil.getSysAdminUser();
        User portalUser = null;
        System.runAs(sysAdm) {
            init();
            portalUser = ESDJC_TestUtil.getPortalUser('US', 'Americas - USA', 'san francisco');

            System.runAs(portalUser) {
            	ErgoClass ergo = new ErgoClass();
            	System.assert(ergo.isErgoPresent);
            }
        }
	}

    static testMethod void testIsNotErgoPresent(){

		User sysAdm = ESDJC_TestUtil.getSysAdminUser();
        User portalUser = null;
        System.runAs(sysAdm) {
            init();
            portalUser = ESDJC_TestUtil.getPortalUser('US', 'Americas - USA', 'boston');

            System.runAs(portalUser) {
            	ErgoClass ergo = new ErgoClass();
            	System.assert(!ergo.isErgoPresent);
            }
        }
	}

	class ErgoClass extends Ergo_Controller{

	}

	private static void init() {
        ESDJC_Settings__c setting = new ESDJC_Settings__c();
        setting.Run_trigger__c = true;
        setting.Site_URL__c = '/site/url';
        setting.Portal_User_Profile_Id__c = '00e70000000xEB1';
        setting.Concierge_API_User_Profile_Id__c = '00en0000000HgEa';
        setting.djc_Helpdesk_API_User__c = '00570000002SpX4AAK';
        setting.Ergo_Locations__c='san francisco,new york,chicago,portland,spokane,toronto,dublin';
        setting.Valid_SLA_Origins__c='Web,REWS - Web,Chatter Answers,Personal Email,Concierge';
        insert setting;
        REWS_Setting__c rewsSetting = new REWS_Setting__c();
        rewsSetting.Mail_services_queue_Id__c = '00Gn0000000JH8YEAW';
        rewsSetting.REWS_Case_Record_Type_Amer_Non_HQ__c = [select Id from RecordType where Sobjecttype = 'Case' and DeveloperName='All_REWS_cases_AMER_NonHQ'].Id;
        rewsSetting.REWS_Case_Record_Type_Amer_HQ__c = [select Id from RecordType where Sobjecttype = 'Case' and DeveloperName='All_REWS_cases_AMER_HQ'].Id;
        rewsSetting.Ergo_Case_Record_Type_AMER__c = [select Id from RecordType where Sobjecttype='Case' and DeveloperName='DJC_Ergo_All_Ergo_cases_AMER'].Id;
        insert  rewsSetting;
    }

}