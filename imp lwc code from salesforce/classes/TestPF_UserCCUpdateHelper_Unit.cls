/******************************************************************************/
//Name			: TestUserCCUpdateHelper
//Author		: 
//Date			: 06 Nov, 2009
//Description	: Code coverage for UserCCAfterInsertUpdateHelper
/******************************************************************************/
@isTest
private class TestPF_UserCCUpdateHelper_Unit {
	
	static testMethod void testuserCCUpdateHelper(){
		User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
		System.runAs ( thisUser ) {
			String username ='hello1@world.com';        
	        
	        User user = new User(LastName = 't'+String.ValueOf(DateTime.Now()) ,FirstName = 'W'+ String.ValueOf(DateTime.Now()));
	        user.Username = username;
	        user.Alias = 'yoo';
	        user.CommunityNickname = username.subString(0,7);
	        user.TimeZoneSidKey = 'America/Los_Angeles';
	        user.EmailEncodingKey = 'ISO-8859-1';
	        user.LanguageLocaleKey = 'en_US';
	        user.Email = 'test@world.com';
	        user.LocaleSidKey = 'en_US';
	        
	        Test.startTest();
	        List<Profile> lstProfile = [select Id from Profile where id =: PerformanceAccessUtil.getSystem_Administrator_Id()];
	        if(lstProfile.Size()>0){
	            user.ProfileId = lstProfile[0].Id;
	            insert user;
	        }
	        Set<Id> userIds = new Set<Id>();
	        userIds.add(user.Id);
	        UserCCAfterInsertUpdateHelper.createUpdateCCRecords(userIds, 'insert');
	        UserCCAfterInsertUpdateHelper.createUpdateCCRecords(userIds, 'update');
		}
	}
}