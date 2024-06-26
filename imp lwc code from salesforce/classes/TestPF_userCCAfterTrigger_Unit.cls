/******************************************************************************/
//Name          : TestuserCCAfterTrigger
//Author        : 
//Date          : 06 Nov, 2009
//Description   : Code coverage for userCCAfterInsertUpdateTrigger
/******************************************************************************/
@isTest
private class TestPF_userCCAfterTrigger_Unit {

    /*
    private static testmethod void testuserCCAfterTrigger(){
        String username ='hello1@world.com';        
        User user = new User(LastName = 'T'+String.ValueOf(DateTime.Now()) ,FirstName = 'W'+ String.ValueOf(DateTime.Now()));
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
        
        
        User oldUser = [select id, Division from User where id=: user.id];
        oldUser.Division = 'Japan';
        update oldUser;
    }
    */
}