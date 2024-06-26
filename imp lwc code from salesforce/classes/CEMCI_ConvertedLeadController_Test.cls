@isTest
public class CEMCI_ConvertedLeadController_Test {
  @TestSetup
  static void makeData() {
    CEMCI_Test_Util.createCEMCICustomSetting();
    List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
    Profile profile = (profiles.size() == 1) ? profiles.get(0) : null;
    List<User> users = [SELECT Id FROM User WHERE ProfileId = :profile.Id AND isActive = TRUE LIMIT 2];

    List<PermissionSet> permissionSets = [SELECT Id FROM PermissionSet WHERE Name = 'Outbound_Sourcer' LIMIT 1];
    PermissionSet permissionSet = (permissionSets.size() == 1) ? permissionSets.get(0) : null;

    System.runAs(users[0]) {
      String userName1 = 'example1@example.com' + System.currentTimeMillis();
      String userName2 = 'example2@example.com' + System.currentTimeMillis();
      User user1 = new User(
        ProfileId = profile.Id,
        Email = 'example1@example.com',
        Username = userName1,
        CompanyName = 'Test',
        Title = 'Title',
        Alias = 'alias',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        LastName = 'testLast',
        FirstName = 'testFirst',
        isActive = true
      );
      User user2 = new User(
        ProfileId = profile.Id,
        Email = 'example2@example.com',
        Username = userName2,
        CompanyName = 'Test',
        Title = 'Title',
        Alias = 'alias',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        LastName = 'testLast',
        FirstName = 'testFirst',
        isActive = true
      );
      List<User> userList = new List<User>();
      userList.add(user1);
      userList.add(user2);
      insert userList;

      PermissionSetAssignment permAssignment = new PermissionSetAssignment(
        AssigneeId = user1.Id,
        PermissionSetId = permissionSet.Id
      );
      insert permAssignment;
    }

    System.runAs(users[1]) {
      Lead newLead = new Lead();
      newLead.LastName = 'TestLead';
      newLead.Company = 'BlueWave';
      newLead.LeadSource = 'Event Invited';
      newLead.Email = 'test@gmail.com';
      newLead.Status = 'Converted';

      Contact con = new Contact();
      con.LastName = 'TestContact';
      con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('WDR_Candidate')
        .getRecordTypeId();
      con.Email = 'test@gmail.com';

      insert newLead;
      insert con;
    }
  }

  @isTest
  static void ConvertLead() {
    List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
    Contact contact = (contacts.size() == 1) ? contacts.get(0) : null;
    List<User> users = [SELECT Id FROM User WHERE email = 'example1@example.com' LIMIT 1];
    User user = (users.size() == 1) ? users.get(0) : null;

    System.runAs(user) {
      Test.startTest();
      CEMCI_ConvertedLeadController.getLeads(contact.Id);
      Test.stopTest();
    }
  }

  @isTest
  static void checkAccess() {
    List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
    Contact contact = (contacts.size() == 1) ? contacts.get(0) : null;
    List<User> users = [SELECT Id FROM User WHERE email = 'example2@example.com' LIMIT 1];
    User user = (users.size() == 1) ? users.get(0) : null;

    System.runAs(user) {
      Test.startTest();
      CEMCI_ConvertedLeadController.getLeads(contact.Id);
      Test.stopTest();
    }
  }
}