@isTest(isParallel=false) 
public class IAAssignPublicGroupToPortalUserImplTest {
    private static final String MSG_EXPECTING_USER_ADDED = 'User added to group';
    private static final String MSG_EXPECTING_USER_NOT_ADDED = 'User not added to group';
	@testSetup
    static void setup() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Customer Portal Manager Standard' LIMIT 1];
            // Accounts
            Account testAccount = new Account(Name = 'TestAccount');
            insert testAccount;
            //Contacts
            List<Contact> testContacts = new List<Contact>();
                Contact testContact = new Contact(LastName = 'testLastName', Email = 'test@test.com', AccountId = testAccount.id);
                testContacts.add(testContact);
            insert testContacts;
        
        assignPG(profileId.Id);
            
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
        List<IA_Assign_Public_Group_To_Portal_User__e> listOfEvents = new List<IA_Assign_Public_Group_To_Portal_User__e>();
        IA_Assign_Public_Group_To_Portal_User__e newRecord = new IA_Assign_Public_Group_To_Portal_User__e();
        newRecord.UserId__c = ids[0];
        listOfEvents.add(newRecord);
        test.startTest();
        IAAssignPublicGroupToPortalUserImpl.assignPGToPortalUsers(listOfEvents);
        List<GroupMember> groupMembersToInserted = [SELECT Id FROM GroupMember WHERE UserOrGroupId =: newRecord.UserId__c];
        System.Assert(!groupMembersToInserted.isEmpty() , MSG_EXPECTING_USER_ADDED);
    	test.stopTest();
    }
    
    @isTest
    static void assignGroupAndPermsetTest1() {
        List<id> ids= new List<id>();
        for(User u:[Select id from User LIMIT 1]){
            ids.add(u.id);
        }
        List<IA_Assign_Public_Group_To_Portal_User__e> listOfEvents = new List<IA_Assign_Public_Group_To_Portal_User__e>();
        IA_Assign_Public_Group_To_Portal_User__e newRecord = new IA_Assign_Public_Group_To_Portal_User__e();
        listOfEvents.add(newRecord);
        test.startTest();
        IAAssignPublicGroupToPortalUserImpl.assignPGToPortalUsers(listOfEvents);
        List<GroupMember> groupMembersToInserted = [SELECT Id FROM GroupMember WHERE UserOrGroupId =: newRecord.UserId__c];
        System.Assert(groupMembersToInserted.isEmpty() , MSG_EXPECTING_USER_NOT_ADDED);
    	test.stopTest();
    }
    
    @future
    static void assignPG(Id profileId){
        List<Contact> testContacts = [Select id from contact LIMIT 1];
        UserRole testUserRole = [SELECT Id  FROM UserRole  LIMIT 1];
        User testUser = new User(UserRoleId = testUserRole.Id,Username = 'testCandidate@testuser.com', LastName = 'User', Email = 'test@test.com', Alias = 'tUser', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = profileId, contactId = testContacts[0].id, LanguageLocaleKey = 'en_US');
        insert testUser;
    }
}