/**
*
* This Class Contains Test Methde for CcEmp_PagesConfiguration.
*/
@isTest
public class CcEmp_PagesConfiguration_Test {
    
    @testSetup
    static void setup() {
        // Create test data
        User user = new User(
            FirstName = 'Test',
            LastName = 'User',
            EmployeeNumber = '12345',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            Username = 'test.pageconfig@example.com.careerconnect',
            Email = 'test.pageconfig@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert user;
        System.runAs(user){
            PermissionSet ps = [SELECT Id FROM PermissionSet  WHERE Name = 'Career_Connect_Users'];
            PermissionSetAssignment objAssignment = new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = user.Id);
            insert objAssignment;
        }
    }
    
    @isTest
    static void getNavigationItemTest() {
        List<CcEmp_NavigationItem__mdt> navigationList = new List<CcEmp_NavigationItem__mdt>();
        Test.startTest();
        navigationList = CcEmp_PagesConfiguration.getNavigationItem();
        Test.stopTest();
        
        Assert.isNotNull(navigationList);
    }
    
    @isTest
    static void getPreferencesTest() {
        User objUser = [SELECT Id FROM User WHERE Email = 'test.pageconfig@example.com' LIMIT 1];
        system.RunAs(objUser){
            CcEmp_Preferences__c preference = new CcEmp_Preferences__c(
                User__c = objUser.Id,
                Onboarding_Completed_Steps__c = 'test'
            );
            insert preference;
        }
        List<CcEmp_Preferences__c> preferencesList = new List<CcEmp_Preferences__c>();
        Test.startTest();
        preferencesList = CcEmp_PagesConfiguration.getPreferences(objUser.Id);
        Test.stopTest();
        
        Assert.isNotNull(preferencesList);
    }
    
    @isTest
    static void savePreferenceTest() {
        User objUser = [SELECT Id FROM User WHERE Email = 'test.pageconfig@example.com' LIMIT 1];
        Test.startTest();
        CcEmp_PagesConfiguration.savePreference(objUser.Id, 'step1');
        Test.stopTest();
        
        List<CcEmp_Preferences__c> preferences = [SELECT Id,Onboarding_Completed_Steps__c FROM CcEmp_Preferences__c WHERE User__c = :objUser.Id LIMIT 1];
        Assert.isNotNull(preferences[0].Onboarding_Completed_Steps__c);
    }
}