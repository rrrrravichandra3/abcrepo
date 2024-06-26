@isTest(SeeAllData=true)
public with sharing class Test_ESDJC_Login_Handler {
    static testMethod void testCreateAndUpdateUser() {
        ESDJC_Login_Handler handler = new ESDJC_Login_Handler();
        /*Auth.UserData(String identifier,
                  String firstName,
                  String lastName,
                  String fullName,
                  String email,
                  String link,
                  String userName,
                  String locale,
                  String provider,
                  String siteLoginUrl,
                  Map<String, String> attributeMap)*/
    
        //createUser();
        ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
        String username = 'testuser1@' + settings.SSO_Service_Provider_Org__c;
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
            'testFirst testLast', username, null, 'testuserlong', 'en_US', 'facebook',
            null, new Map<String, String>{});
        User u = handler.createUser(null, sampleData);
        //System.assertEquals(settings.Portal_Guest_Username__c, u.userName);
        //System.assertEquals('settings.testuser@example.org', u.email);
                
        sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
            'testNewFirst testNewLast', 'testnewuser@example.org', null, 'testnewuserlong', 'en_US', 'facebook',
            null, new Map<String, String>{});
        //handler.updateUser(uid, null, sampleData);
        
        //User updatedUser = [SELECT userName, email, firstName, lastName, alias FROM user WHERE id=:uid];
    }

    static void createUser() {
        ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
        User u = new User();
        u.username = 'testuser1@' + settings.SSO_Service_Provider_Org__c;
        u.email = 'testuser@test.com';
        u.lastName = 'lastName';
        u.firstName = 'firstName';
        String alias = 'test1';
        u.alias = alias;
        u.CommunityNickname = alias;
        u.languagelocalekey = 'en_US';
        u.localesidkey = 'en_US';
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = 'America/Los_Angeles';
        u.profileId = settings.Portal_User_Profile_Id__c;
        
        u.Manager__c = '00570000001JGKmAAO';
        u.Department = '3020-Enterprise Salesforce Services';
        u.ContactId = '003Q000000hDz7K';//'003Q000000hDz6z';//'003Q000000hEwKyIAK';
        //u.UserType = 'PowerCustomerSuccess';
        u.UserRoleId = '00EQ0000000O6M7MAK';
        u.IsActive = true;
        u.CurrencyIsoCode = 'USD';
        
        System.debug('++++createUser:u='+u);
        insert u;          
    }
}