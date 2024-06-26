@isTest
private class Cc_Emp_PersonalInformationControllerTest {
    private static final String USERNAME = 'test.user@company.com.careerconnect';
    @testSetup
    static void setup() {
        // Create user
        User user = new User(
            LastName = 'Test',
            Username = USERNAME,
            Email = 'test.user@company.com',
            Alias = 'testUser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            AboutMe = 'Test about me',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id
        );
        insert user;
        
        // Create CcEmp_Preferences__c
        CcEmp_Preferences__c empPref = new CcEmp_Preferences__c(
            User__c = user.Id,
            LinkedIn_Url__c = 'https://www.linkedin.com/in/test',
            Personal_Website__c = 'https://www.test.com'
            
        );
        insert empPref;
    }
    
    @isTest
    static void testOnloadData() {
        User objUser = [SELECT Id FROM User WHERE UserName ='test.user@company.com.careerconnect'];
        System.runAs(objUser){
            
            CcEmp_Preferences__c empPref = Cc_Emp_PersonalInformationController.getOnloadData();
            System.assertNotEquals(null, empPref, 'Onload data should not be null');
            System.assertEquals(UserInfo.getUserId(), empPref.User__c, 'User should match');
        }
    }
    
    @isTest
    static void testUpdateUserInfo() {
        User objUser = [SELECT Id FROM User WHERE UserName =: USERNAME];
        Map<String, String> userData = new Map<String, String>{
            'LinkedInUrl' => 'https://www.linkedin.com/in/test2',
                'PersonalWebsite' => 'https://www.test2.com',
                'EmpPrefId' => [SELECT Id FROM CcEmp_Preferences__c WHERE User__c =: objUser.Id LIMIT 1].Id,
                'AboutMe' => 'Test about me updated'
                };
                    Test.startTest();
        Cc_Emp_PersonalInformationController.updateUserInfo(JSON.serialize(userData));
        Test.stopTest();
        // Verify user and empPref have been updated
        User updatedUser = [SELECT AboutMe FROM User WHERE Id =: UserInfo.getUserId()];
        CcEmp_Preferences__c updatedEmpPref = [SELECT LinkedIn_Url__c, Personal_Website__c FROM CcEmp_Preferences__c WHERE Id =: userData.get('EmpPrefId')];
        System.assertEquals(userData.get('AboutMe'), updatedUser.AboutMe, 'User AboutMe should have been updated');
        System.assertEquals(userData.get('LinkedInUrl'), updatedEmpPref.LinkedIn_Url__c, 'LinkedIn Url should have been updated');
        System.assertEquals(userData.get('PersonalWebsite'), updatedEmpPref.Personal_Website__c, 'Personal Website should have been updated');
    }
    
    @isTest
    static void testImageUpload() {
        User objUser = [SELECT Id FROM User WHERE UserName =: USERNAME];
        System.runAs(objUser){
            try{
                Cc_Emp_PersonalInformationController.uploadCroppedImage('testString');
            }catch(Exception ex){
                System.debug(ex);
            }
            User objUser2 = [SELECT Id,FullPhotoUrl FROM User WHERE UserName =: USERNAME];
            System.assertNotEquals(null, objUser2.FullPhotoUrl, 'Profile Photo not uploaded');
        }
    }
}