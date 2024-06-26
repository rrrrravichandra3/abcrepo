@isTest
private class CEMCI_Contacts_Test {
  @testSetup
  static void setup() {
    CEMCI_Test_Util.createCEMCICustomSetting();
    Test.startTest();
    List<Contact> ConList = getContact();
    ConList[0].LinkedIn_Profile_URL__c = 'https://www.linkedin.com/in/test-9a9a5b3a/';
    insert ConList;
    Contact con = [SELECT id, LinkedIn_Profile_URL__c, IsValid_LinkedIn_URL__c FROM Contact WHERE ID = :conList[0].Id];
    System.assertEquals(true, Con.IsValid_LinkedIn_URL__c);
    Test.stopTest();
  }

  static testMethod void validateLinkedinURLPos() {
    Test.startTest();
    Contact con = [
      SELECT id, LinkedIn_Profile_URL__c, IsValid_LinkedIn_URL__c
      FROM Contact
      WHERE LinkedIn_Profile_URL__c = NULL
    ];
    System.assertEquals(true, con <> null);
    con.lastname = 'test con1';
    con.LinkedIn_Profile_URL__c = 'https://www.linkedin.com/in/testing1-9a9a5b3b/';
    update con;
    Contact con1 = [SELECT id, LinkedIn_Profile_URL__c, IsValid_LinkedIn_URL__c FROM Contact WHERE ID = :con.Id];
    System.assertEquals(true, con1.IsValid_LinkedIn_URL__c);
    Test.stopTest();
  }

  static testMethod void validateLinkedinURLNeg() {
    Test.startTest();
    Contact con = [
      SELECT id, LinkedIn_Profile_URL__c, IsValid_LinkedIn_URL__c
      FROM Contact
      WHERE LinkedIn_Profile_URL__c = NULL
    ];
    System.assertEquals(true, con <> null);
    con.lastname = 'test con1';
    con.LinkedIn_Profile_URL__c = 'www.google.com';
    update con;
    Contact con1 = [SELECT id, LinkedIn_Profile_URL__c, IsValid_LinkedIn_URL__c FROM Contact WHERE ID = :con.Id];
    System.assertEquals(false, con1.IsValid_LinkedIn_URL__c);
    Test.stopTest();
  }
  private static List<Contact> getContact() {
    List<Contact> ConList = new List<Contact>();
    for (integer i = 0; i < 2; i++) {
      Contact aContact = new Contact();
      aContact.AccountId = ESDJC_TestUtil.createAccount().Id;
      aContact.FirstName = 'DJC';
      aContact.LastName = 'Dream Job Central';
      ConList.add(aContact);
    }
    return ConList;
  }

  private static User createUser(String recruitingRole) {
    Profile p = [SELECT id FROM Profile WHERE Name = 'Employee'];

    User u = new User(
      Alias = 'newUser',
      Email = 'newuser@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'newTestUser1',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = recruitingRole.deleteWhitespace() + '@not.salesforce.com',
      Recruiting_Role__c = recruitingRole
    );

    return u;
  }

  /**
   * GIVEN: A Candidate Contact exists or is created in CRM
   * WHEN: Marketing_Opt_In__c and Recruiting_Opt_In__c both Equal 'Opt Out'
   * THEN: hasoptedoutofemail should be 'true'
   */
  @IsTest
  private static void testContactHardOptOut_OPTOUT() {
    Contact con = new Contact();
    con.FirstName = 'Opt';
    con.LastName = 'Out';
    con.Email = 'optOut@not.salesforce.com';
    con.AccountId = ESDJC_TestUtil.createAccount().Id;
    con.Marketing_Opt_In__c = 'Opt Out';
    con.Recruiting_Opt_In__c = 'Opt Out';

    Test.startTest();
    insert con;
    Test.stopTest();

    con = [SELECT id, HasOptedOutOfEmail FROM Contact WHERE email = 'optOut@not.salesforce.com'];
    System.assertEquals(true, con.HasOptedOutOfEmail, 'HasOptedOutofEmail should be marked as true');
  }

  /**
   * GIVEN: A Candidate Contact exists or is created in CRM
   * WHEN: either Marketing_Opt_In__c and Recruiting_Opt_In__c are 'Opt In'
   * THEN: hasoptedoutofemail should be 'false'
   */
  @IsTest
  private static void testContactHardOptOut_OPTIN() {
    Contact con = new Contact();
    con.FirstName = 'Opt';
    con.LastName = 'In';
    con.Email = 'optIn@not.salesforce.com';
    con.AccountId = ESDJC_TestUtil.createAccount().Id;
    con.Marketing_Opt_In__c = 'Opt In';
    con.Recruiting_Opt_In__c = 'Opt Out';

    Test.startTest();
    insert con;
    Test.stopTest();

    con = [SELECT id, HasOptedOutOfEmail FROM Contact WHERE email = 'optIn@not.salesforce.com'];
    System.assertEquals(false, con.HasOptedOutOfEmail, 'HasOptedOutofEmail should be marked as true');
  }

  /**
   * GIVEN: A lead is owned by a RMM
   * WHEN: it is converted
   * THEN: the method to set contactOwnerId should be null.
   */
  
   /*
  @IsTest
  private static void testContactOwnerInValid_RMM() {
    User RMM = createUser('Recruitment Marketing Manager');
    insert RMM;

    User u = [SELECT id, Name FROM User WHERE Recruiting_Role__c = 'Recruitment Marketing Manager' LIMIT 1];
    Test.startTest();
    Id contactOwnerId = CEMCI_Util.setLeadOwnerValidforContactOwner(u.Id);
    Test.stopTest();
    System.assertEquals(null, contactOwnerId, 'OwnerId should have returned null');
  }
  */

  /**
   * GIVEN:
   * WHEN:
   * THEN:
   */
  @IsTest
  private static void testContactOwnerValid_Sourcer() {
    User sourcer = createUser('Sourcer');
    insert sourcer;

    User u = [SELECT id FROM User WHERE Recruiting_Role__c = 'Sourcer' LIMIT 1];
    Test.startTest();
    Id contactOwnerId = CEMCI_Util.setLeadOwnerValidforContactOwner(u.Id);
    Test.stopTest();
    System.assertEquals(u.Id, contactOwnerId, 'OwnerId should match the UserId passed in');
  }
}