@isTest
private class NHW_TestExecTeamUserEmaillength{

	private final static String MSG_SHOULD_BE_TRUE = 'Should be True, but returning False';
	private final static String MSG_SHOULD_BE_FALSE = 'Should be False, but returning True';
	
	@testsetup static void populateCustomSetting(){
		NHW_Executive_Onboarding_Team_Emails__c testData1 = new NHW_Executive_Onboarding_Team_Emails__c(Name='1',Executive_Member_Email__c='testData1@example.com');
		NHW_Executive_Onboarding_Team_Emails__c testData2 = new NHW_Executive_Onboarding_Team_Emails__c(Name='2',Executive_Member_Email__c='testData2@example.com');
		NHW_Executive_Onboarding_Team_Emails__c longtestData3 = new NHW_Executive_Onboarding_Team_Emails__c(Name='3',Executive_Member_Email__c='longEmail123456789123456789123456789123456789123456789@example.com');
		List<NHW_Executive_Onboarding_Team_Emails__c> testDataList = new List<NHW_Executive_Onboarding_Team_Emails__c>();
		testDataList.add(testData1);
		testDataList.add(testData2);
		testDataList.add(longtestData3);
		insert testDataList;
	}
	//test with user with a regular length email but not part of custom setting
	@isTest static void  testUserShortEmailNotInCustSetting(){
		NHW_Util.testVariableCurrentUserEmail = 'testUserNotExecutive@example.com';
		Boolean isCurrentUserExecutive = NHW_Util.isCurrentUserExecutive();
		system.assertEquals(False,isCurrentUserExecutive, MSG_SHOULD_BE_FALSE );
	}
	//test with user with a regular length email and part of custom setting
	@isTest static void  testUserShortEmailInCustSetting(){
		NHW_Util.testVariableCurrentUserEmail = 'testData1@example.com';
		Boolean isCurrentUserExecutive = NHW_Util.isCurrentUserExecutive();
		system.assertEquals(True,isCurrentUserExecutive, MSG_SHOULD_BE_TRUE );
	}
	//test with user with a long email but not part of custom setting
	@isTest static void  testUserLongEmailNotInCustSetting(){
		NHW_Util.testVariableCurrentUserEmail = 'testUserNotExecutive123456789123456789123456789123456789123456789@example.com';
		Boolean isCurrentUserExecutive = NHW_Util.isCurrentUserExecutive();
		system.assertEquals(False,isCurrentUserExecutive, MSG_SHOULD_BE_FALSE );
	}
	//test with user with a long email and part of custom setting
	@isTest static void  testUserLongEmailInCustSetting(){
		NHW_Util.testVariableCurrentUserEmail = 'longEmail123456789123456789123456789123456789123456789@example.com';
		Boolean isCurrentUserExecutive = NHW_Util.isCurrentUserExecutive();
		system.assertEquals(True,isCurrentUserExecutive, MSG_SHOULD_BE_TRUE );
	}
	//test with user with null email 
	@isTest static void  testUserNullEmailInCustSetting(){
		NHW_Util.testVariableCurrentUserEmail = null;
		Boolean isCurrentUserExecutive = NHW_Util.isCurrentUserExecutive();
		system.assertEquals(False,isCurrentUserExecutive, MSG_SHOULD_BE_FALSE );
	}
	//test with user with empty string as email 
	@isTest static void  testUserBlankEmailInCustSetting(){
		NHW_Util.testVariableCurrentUserEmail = '';
		Boolean isCurrentUserExecutive = NHW_Util.isCurrentUserExecutive();
		system.assertEquals(False,isCurrentUserExecutive, MSG_SHOULD_BE_FALSE );
	}
}