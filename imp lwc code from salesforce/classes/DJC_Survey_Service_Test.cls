@isTest(SeeAllData=false)
public  class DJC_Survey_Service_Test {
	private static Contact amerContact = ESDJC_AssignmentHelper.getContacts(1, 'Americas - USA', 'San Francisco')[0];
	private static Contact jpnContact = ESDJC_AssignmentHelper.getContacts(1, 'Japan', 'Tokyo')[0];
	
	private static testmethod void runtestWhoops(){
		init();
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', amerContact.id);
		nameValuePair.put('Type','ESPP');
		nameValuePair.put('ES_DJC_Topic__c','How to Enroll');	
		nameValuePair.put('ES_DJC_Sub_Topic__c','New Hire');			
		nameValuePair.put('Tier__c', 'Tier 1');
		nameValuePair.put('Origin','Phone');	
		nameValuePair.put('Subject','');
		Case c = createCase(nameValuePair);
		String s = DJC_Survey_Service.sendSurvey(c.id);
		System.assertEquals('Whoops! You cannot send a survey to this employee because the case is not closed or a survey has already been sent.',s);		
	}
	
	private static testmethod void runtestok(){
		init();
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', amerContact.id);
		nameValuePair.put('Type','ESPP');
		nameValuePair.put('ES_DJC_Topic__c','How to Enroll');	
		nameValuePair.put('ES_DJC_Sub_Topic__c','New Hire');			
		nameValuePair.put('Tier__c', 'Tier 1');
		nameValuePair.put('Origin','Phone');	
		nameValuePair.put('Subject','');
		nameValuePair.put('Status','Closed');
		Case c = createCase(nameValuePair);
		String s = DJC_Survey_Service.sendSurvey(c.id);
		System.assertEquals('ok',s);		
	}
		
	private static testmethod void runtestok_japan(){
		init();
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', jpnContact.id);
		nameValuePair.put('Type','ESPP');
		nameValuePair.put('ES_DJC_Topic__c','How to Enroll');	
		nameValuePair.put('ES_DJC_Sub_Topic__c','New Hire');			
		nameValuePair.put('Tier__c', 'Tier 1');
		nameValuePair.put('Origin','Phone');	
		nameValuePair.put('Subject','');
		nameValuePair.put('Status','Closed');
		Case c = createCase(nameValuePair);
		String s = DJC_Survey_Service.sendSurvey(c.id);
		System.assertEquals('ok',s);		
	}
	
		private static case createCase(Map<String,String> nameValPair){
		Case c = new Case();
		if ((nameValPair!=null)&&(nameValPair.size()>0)){
			for (String key: nameValPair.keySet()){
				String value= nameValPair.get(key);
				c.put(key, value);
			}
			insert c;
			Case newCase = [select owner.name, recordtype.Name, priority,ES_DJC_Case_Re_open_Date__c,type, Tier__c from case where id = :c.id];
			return newCase;					
		}
		return null;		
	}
	
	private static case updateCase(Case c, Map<String,String> nameValPair){
		if (c==null || nameValPair == null || nameValPair.size()==0){
			return null;
		}						
		for (String key: nameValPair.keySet()){
			String value= nameValPair.get(key);
			c.put(key, value);
		}
		update c;
		Case newCase = [select owner.name, recordtype.Name, priority,ES_DJC_Case_Re_open_Date__c, type, Tier__c from case where id = :c.id];
		return newCase;									
	}
	
		private static void init(){
		ESDJC_Settings__c setting = new ESDJC_Settings__c();
		setting.Run_trigger__c = true;
		setting.Site_URL__c = '/site/url';
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