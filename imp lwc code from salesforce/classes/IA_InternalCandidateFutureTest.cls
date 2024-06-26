/**
* @author Manish 
* @date 12/07/2022
*
* @description Test Class for IA_ServiceAppointmentDecomission
*
*/
@isTest(isParallel=false) 
public class IA_InternalCandidateFutureTest {
    @testSetup
    static void setup() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Customer Portal Manager Standard' LIMIT 1];
        
        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'ES_Specialist_Amer' Limit 1];
        
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' Limit 1];
        
        adminUser.UserRoleId = userRole.Id;
        adminUser.isactive = true;
        update adminUser;
        
        List<Contact> testContacts = new List<Contact>();           
        System.runAs(adminUser) {
            // Accounts
            Account testAccount = new Account(Name = 'TestAccount');
            insert testAccount;
            //Contacts
            
            Contact testContact = new Contact(LastName = 'testLastName', Email = 'test@test.com', AccountId = testAccount.id);
            testContacts.add(testContact);
            insert testContacts;
            //Users
            List<User> testUsers = new List<User>();
            User testUser = new User(Username = 'testCandidate@testuser.com', LastName = 'User', Email = 'test@test.com', Alias = 'tUser', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = profileId.Id, contactId = testContacts[0].id, LanguageLocaleKey = 'en_US');
            testUsers.add(testUser);
            insert testUsers;
        }        
    }
    /********************************************************************
* @description check for assignGroupAndPermset
* 				
*/
    @isTest
    static void assignGroupAndPermsetTest() {
        List<id> ids= new List<id>();
        for(User u:[Select id from User LIMIT 1]){
            ids.add(u.id);
        }
        test.startTest();
        IA_InternalCandidateFuture.assignGroupAndPermset(ids);
        test.stopTest();
    }
    
    
    /********************************************************************
* @description check for AssignPermissionSetAndPublicGroup
* 				
*/
    @isTest
    static void AssignPermissionSetAndPublicGroupTest() {
        List<id> ids= new List<id>();
        for(User u:[Select id from User LIMIT 1]){
            ids.add(u.id);
        }
        test.startTest();
        IA_InternalCandidateFuture.AssignPermissionSetAndPublicGroup(ids[0],'Insiders_App_Candidate','Insiders_Candidates');
        test.stopTest();
    }
}