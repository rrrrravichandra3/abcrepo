@isTest(SeeAllData=true)
public with sharing class Test_ESDJC_LiveAgentChatController {
	
	static testMethod void testChatController() {
		ESDJC_TestUtil.createSSOIdSetting();
		
		User u = ESDJC_TestUtil.getPortalUser('India','EMEA');
		
		user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission( u.id,'ES_DJC_Employee_EMEA');
        }
		
		ESDJC_LiveAgentChatController con1 = new ESDJC_LiveAgentChatController();
		system.runAs(u){
			ESDJC_LiveAgentChatController con = new ESDJC_LiveAgentChatController();
			con.dayOfWeek = DateTime.newInstance(Date.today().addDays(1), Time.newInstance(0, 0, 0, 0)).format('EEEE');
			con.determineLiveAgentAvailability(con.dayOfWeek);
			con.dayOfWeek = DateTime.newInstance(Date.today().addDays(2), Time.newInstance(0, 0, 0, 0)).format('EEEE');
			con.determineLiveAgentAvailability(con.dayOfWeek);
			con.dayOfWeek = DateTime.newInstance(Date.today().addDays(3), Time.newInstance(0, 0, 0, 0)).format('EEEE');
			con.determineLiveAgentAvailability(con.dayOfWeek);
			con.dayOfWeek = DateTime.newInstance(Date.today().addDays(4), Time.newInstance(0, 0, 0, 0)).format('EEEE');
			con.determineLiveAgentAvailability(con.dayOfWeek);
			con.dayOfWeek = DateTime.newInstance(Date.today().addDays(5), Time.newInstance(0, 0, 0, 0)).format('EEEE');
			con.determineLiveAgentAvailability(con.dayOfWeek);
			con.dayOfWeek = DateTime.newInstance(Date.today().addDays(6), Time.newInstance(0, 0, 0, 0)).format('EEEE');
			con.determineLiveAgentAvailability(con.dayOfWeek);
		}
	}
}