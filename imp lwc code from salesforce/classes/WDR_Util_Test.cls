@isTest
public with sharing class WDR_Util_Test {
  @testSetup
  static void setup() {
    List<WDR_Candidate__c> candidateInsertList = new List<WDR_Candidate__c>();

    WDR_Candidate__c candidate1 = populateCandidateFields(
      'Bugs Bunny',
      'Bugs',
      'Bunny',
      'bbunny@not.salesforce.com',
      'Candidate',
      null,
      null,
      null,
      null
    );
    candidateInsertList.add(candidate1);

    WDR_Candidate__c candidate2 = populateCandidateFields(
      'Donald Duck',
      'Donald',
      'Duck',
      'dduck@not.salesforce.com',
      'Candidate',
      'Duck Industries',
      null,
      null,
      null
    );
    candidateInsertList.add(candidate2);

    WDR_Candidate__c candidate3 = populateCandidateFields(
      'Daisy Duck',
      'Daisy',
      'Duck',
      'daisy@not.salesforce.com',
      'Candidate',
      null,
      'Daisy Family University',
      null,
      null
    );
    candidateInsertList.add(candidate3);

    WDR_Candidate__c candidate4 = populateCandidateFields(
      'Road Runner',
      'Road',
      'Runner',
      'rrunner@not.salesforce.com',
      'Candidate',
      'Looney Tunes',
      null,
      'wjwk2kkl2',
      null
    );
    candidateInsertList.add(candidate4);

    WDR_Candidate__c candidate5 = populateCandidateFields(
      'Wile Coyote',
      'Wile',
      'Coyote',
      'wcoyote@not.salesforce.com',
      'Candidate',
      null,
      'Looney Tunes University',
      null,
      'ook2kjjk'
    );
    candidateInsertList.add(candidate5);

    WDR_Candidate__c candidate6 = populateCandidateFields(
      'Yosemite Sam',
      'Yosemite',
      'Sam',
      'ysam@not.salesforce.com',
      'Candidate',
      'Looney Tunes',
      null,
      null,
      null
    );
    candidateInsertList.add(candidate6);

    WDR_Candidate__c candidate7 = populateCandidateFields(
      'Porky Pig',
      'Porky',
      'Pig',
      'ppig@not.salesforce.com',
      'Candidate',
      null,
      'Looney Tunes University',
      null,
      null
    );
    candidateInsertList.add(candidate7);

    List<Account> accountInsertList = new List<Account>();

    Account acc1 = populateAccountFields('Looney Tunes', 'wjwk2kkl2');
    accountInsertList.add(acc1);

    Account acc2 = populateAccountFields('Looney Tunes University', 'ook2kjjk');
    accountInsertList.add(acc2);

    Account acc3 = populateAccountFields('WDR Candidates', null);
    accountInsertList.add(acc3);

    List<User> insertUserList = new List<User>();

    Id sysAdminProfileId = [SELECT Id FROM Profile WHERE name = 'System Administrator'].Id;
    User sysadminUser = populateUserFields(
      'DC',
      'Studios',
      'dcstudios@not.salesforce.com',
      'dcstudios@not.salesforce.com',
      'dc',
      'America/Los_Angeles',
      'en_US',
      'ISO-8859-1',
      'en_US',
      sysAdminProfileId
    );
    insertUserList.add(sysadminUser);

    Id accountOwnerProfileId = [SELECT Id FROM Profile WHERE name = 'APEX Only - Peopleforce Account Owner' LIMIT 1].Id;
    User accountOwner = populateUserFields(
      'Marvel',
      'Studios',
      'mstudios@not.salesforce.com',
      'mstudios@not.salesforce.com',
      'marvel',
      'America/Los_Angeles',
      'en_US',
      'ISO-8859-1',
      'en_US',
      accountOwnerProfileId
    );
    insertUserList.add(accountOwner);

    CEMCI_Settings__c settings = new CEMCI_Settings__c();
    settings.Account_Owner_Profile_Id__c = accountOwnerProfileId;
    settings.Auto_Merge_Lead_to_Lead_Limits__c = 0.8;
    settings.Executive_Recruiting_Queue_Id__c = '123';
    settings.OSR_Global_Queue_Id__c = '456';

    System.runAs(sysadminUser) {
      insert candidateInsertList;
      insert accountInsertList;
      insert settings;
    }
  }

  private static WDR_Candidate__c populateCandidateFields(
    String Name,
    String FirstName,
    String LastName,
    String Email,
    String CandidateType,
    String Company,
    String School,
    String companyWDI,
    String schoolWDI
  ) {
    WDR_Candidate__c candidate = new WDR_Candidate__c();
    candidate.Name = Name;
    candidate.First_Name__c = FirstName;
    candidate.Last_Name__c = LastName;
    candidate.Email__c = Email;
    candidate.Candidate_Type__c = CandidateType;
    candidate.Current_Company__c = Company;
    candidate.Last_School_Attended__c = School;
    candidate.WD_Company_WDI__c = companyWDI;
    candidate.WD_School_WDI__c = schoolWDI;

    return candidate;
  }

  private static Account populateAccountFields(String Name, String AccountWDI) {
    RecordType accountRT = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Account' AND developername = 'WDR_Candidate'
    ];
    Account acc = new Account();
    acc.Name = Name;
    acc.RecordTypeId = accountRT.Id;
    acc.WD_Account_WDI__c = AccountWDI;

    return acc;
  }

  public static User populateUserFields(
    String firstName,
    String lastName,
    String email,
    String username,
    String alias,
    String timeZoneSidKey,
    String localeSidKey,
    String emailEncodingKey,
    String languageLocaleKey,
    Id profileId
  ) {
    User newUser = new User();
    newUser.FirstName = firstName;
    newUser.LastName = lastName;
    newUser.email = email;
    newUser.Username = username;
    newUser.Alias = alias;
    newUser.TimeZoneSidKey = timeZoneSidKey;
    newUser.LocaleSidKey = localeSidKey;
    newUser.EmailEncodingKey = emailEncodingKey;
    newUser.LanguageLocaleKey = languageLocaleKey;
    newUser.profileId = profileId;

    return newUser;
  }

  @isTest
  static void test_CandidatewithNoAccountInfo() {
    Map<Id, Id> candidateToAccountMap = new Map<Id, Id>();
    List<WDR_Candidate__c> candidateList = [
      SELECT Id, Last_School_Attended__c, Current_Company__c, WD_Company_WDI__c, WD_School_WDI__c
      FROM WDR_Candidate__c
      WHERE email__c = 'bbunny@not.salesforce.com'
    ];
    Test.startTest();

    WDR_Util processRecord = new WDR_Util();
    candidateToAccountMap = processRecord.populateAccountonContact(candidateList);
    Test.stopTest();

    Account candidateAccount = [SELECT Id FROM Account WHERE Name = 'WDR Candidates' LIMIT 1];

    for (WDR_Candidate__c cand : candidateList)
      System.assertEquals(candidateAccount.Id, candidateToAccountMap.get(cand.Id));
  }

  @isTest
  static void test_CandidatewithCompany() {
    Map<Id, Id> candidateToAccountMap = new Map<Id, Id>();
    List<WDR_Candidate__c> candidateList = [
      SELECT Id, Last_School_Attended__c, Current_Company__c, WD_Company_WDI__c, WD_School_WDI__c
      FROM WDR_Candidate__c
      WHERE email__c = 'dduck@not.salesforce.com'
    ];

    Test.startTest();

    WDR_Util processRecord = new WDR_Util();
    candidateToAccountMap = processRecord.populateAccountonContact(candidateList);
    Test.stopTest();

    Account candidateAccount = [SELECT Id FROM Account WHERE Name = 'Duck Industries' LIMIT 1];

    for (WDR_Candidate__c cand : candidateList)
      System.assertEquals(candidateAccount.Id, candidateToAccountMap.get(cand.Id));
  }

  @isTest
  static void test_CandidatewithSchool() {
    Map<Id, Id> candidateToAccountMap = new Map<Id, Id>();
    List<WDR_Candidate__c> candidateList = [
      SELECT Id, Last_School_Attended__c, Current_Company__c, WD_Company_WDI__c, WD_School_WDI__c
      FROM WDR_Candidate__c
      WHERE email__c = 'daisy@not.salesforce.com'
    ];

    Test.startTest();

    WDR_Util processRecord = new WDR_Util();
    candidateToAccountMap = processRecord.populateAccountonContact(candidateList);
    Test.stopTest();

    Account candidateAccount = [SELECT Id FROM Account WHERE Name = 'Daisy Family University' LIMIT 1];

    for (WDR_Candidate__c cand : candidateList)
      System.assertEquals(candidateAccount.Id, candidateToAccountMap.get(cand.Id));
  }

  @isTest
  static void test_CandidatewithCompanyWDI() {
    Map<Id, Id> candidateToAccountMap = new Map<Id, Id>();
    List<WDR_Candidate__c> candidateList = [
      SELECT Id, Last_School_Attended__c, Current_Company__c, WD_Company_WDI__c, WD_School_WDI__c
      FROM WDR_Candidate__c
      WHERE email__c = 'rrunner@not.salesforce.com'
    ];

    Test.startTest();

    WDR_Util processRecord = new WDR_Util();
    candidateToAccountMap = processRecord.populateAccountonContact(candidateList);
    Test.stopTest();

    Account candidateAccount = [SELECT Id FROM Account WHERE WD_Account_WDI__c = 'wjwk2kkl2' LIMIT 1];

    for (WDR_Candidate__c cand : candidateList)
      System.assertEquals(candidateAccount.Id, candidateToAccountMap.get(cand.Id));
  }

  @isTest
  static void test_CandidatewithSchoolWDI() {
    Map<Id, Id> candidateToAccountMap = new Map<Id, Id>();
    List<WDR_Candidate__c> candidateList = [
      SELECT Id, Last_School_Attended__c, Current_Company__c, WD_Company_WDI__c, WD_School_WDI__c
      FROM WDR_Candidate__c
      WHERE email__c = 'wcoyote@not.salesforce.com'
    ];

    Test.startTest();

    WDR_Util processRecord = new WDR_Util();
    candidateToAccountMap = processRecord.populateAccountonContact(candidateList);
    Test.stopTest();

    Account candidateAccount = [SELECT Id FROM Account WHERE WD_Account_WDI__c = 'ook2kjjk' LIMIT 1];

    for (WDR_Candidate__c cand : candidateList)
      System.assertEquals(candidateAccount.Id, candidateToAccountMap.get(cand.Id));
  }

  @isTest
  static void test_CandidatewithCompanyName() {
    Map<Id, Id> candidateToAccountMap = new Map<Id, Id>();
    List<WDR_Candidate__c> candidateList = [
      SELECT Id, Last_School_Attended__c, Current_Company__c, WD_Company_WDI__c, WD_School_WDI__c
      FROM WDR_Candidate__c
      WHERE email__c = 'ysam@not.salesforce.com'
    ];

    Test.startTest();

    WDR_Util processRecord = new WDR_Util();
    candidateToAccountMap = processRecord.populateAccountonContact(candidateList);
    Test.stopTest();

    Account candidateAccount = [SELECT Id FROM Account WHERE Name = 'Looney Tunes' LIMIT 1];

    for (WDR_Candidate__c cand : candidateList)
      System.assertEquals(candidateAccount.Id, candidateToAccountMap.get(cand.Id));
  }

  @isTest
  static void test_CandidatewitSchoolName() {
    Map<Id, Id> candidateToAccountMap = new Map<Id, Id>();
    List<WDR_Candidate__c> candidateList = [
      SELECT Id, Last_School_Attended__c, Current_Company__c, WD_Company_WDI__c, WD_School_WDI__c
      FROM WDR_Candidate__c
      WHERE email__c = 'ppig@not.salesforce.com'
    ];

    Test.startTest();

    WDR_Util processRecord = new WDR_Util();
    candidateToAccountMap = processRecord.populateAccountonContact(candidateList);
    Test.stopTest();

    Account candidateAccount = [SELECT Id FROM Account WHERE Name = 'Looney Tunes University' LIMIT 1];

    for (WDR_Candidate__c cand : candidateList)
      System.assertEquals(candidateAccount.Id, candidateToAccountMap.get(cand.Id));
  }

  @isTest
  static void test_getBatchSize() {
    Integer batchSize;
    Test.startTest();
    batchSize = WDR_Util.getBatchSizeforWDRBatch('WDRCandidate_to_Contact');
    Test.stopTest();
    System.assertNotEquals(batchSize, null);
  }

  @IsTest
  static void testGetFieldMap() {
    String leadCheckboxesFieldSetName = 'CEMCILeadCheckboxes';
    Schema.FieldSet leadCheckboxesFieldSet = Schema.SObjectType.Lead.fieldSets.getMap().get(leadCheckboxesFieldSetName);
    Map<String, SObjectField> leadCheckboxes = WDR_Util.getFieldMap(leadCheckboxesFieldSet);
    Map<String, SObjectField> reducedSubset = new Map<String, SObjectField>();
    reducedSubset.put('Boomerang__c', leadCheckboxes.get('Boomerang__c'));
    reducedSubset.put('Remote_Only__c', leadCheckboxes.get('Remote_Only__c'));

    String expectedQuery = 'SELECT Id, Boomerang__c, Remote_Only__c FROM Lead LIMIT 1';
    String query = 'SELECT Id' + CEMCI_Leads.getQueryCheckboxFields(reducedSubset, '') + ' FROM Lead LIMIT 1';

    Boolean testAssertion = (query == expectedQuery);

    System.assert(testAssertion, 'Query is not identical.');
  }
}