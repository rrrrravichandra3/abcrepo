@isTest
private class CEMCI_Leads_Test {
  /*
  @testSetup
  static void setup() {
    Id sysAdminProfileId = [SELECT Id FROM Profile WHERE name = 'System Administrator'].Id;
    User sysadminUser = WDR_Util_Test.populateUserFields(
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
    insert sysadminUser;

    Id employeeProfileId = [SELECT Id FROM Profile WHERE name = 'Employee' LIMIT 1].Id;
    User osrUsr = WDR_Util_Test.populateUserFields(
      'OSR',
      'USER',
      'osrUser@not.salesforce.com',
      'osrUser@not.salesforce.com',
      'osrUs',
      'America/Los_Angeles',
      'en_US',
      'ISO-8859-1',
      'en_US',
      employeeProfileId
    );
    osrUsr.Recruiting_Role__c = 'Sourcer';
    insert osrUsr;

    PermissionSet sourcerPS = [SELECT id FROM PermissionSet WHERE Name = 'Outbound_Sourcer'];
    Test.startTest();
    System.runAs(sysadminUser){
      PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = osrUsr.Id, PermissionSetId = sourcerPS.Id);
      insert psa;
    }
    Test.stopTest();
    Group grp = [SELECT id FROM Group WHERE DeveloperName = 'Outbound_Sourcers'];

    GroupMember gm = new GroupMember(GroupId = grp.Id, UserOrGroupId = osrUsr.Id);

    insert gm;

    Test.startTest();
    System.runAs(sysadminUser) {
      CEMCI_Test_Util.createCEMCICustomSetting();

      List<Lead> LeadList = getLead();
      Lead ld = [SELECT id, Linked_In_URL__c, IsValid_LinkedIn_URL__c FROM Lead WHERE ID = :LeadList[0].Id];
      System.assertEquals(true, ld.IsValid_LinkedIn_URL__c);
    }
    Test.stopTest();
  }

  @IsTest
  static void validateLinkedinURLPos() {
    Test.startTest();
    Lead ld = [SELECT id, lastName, Company FROM Lead WHERE Linked_In_URL__c != NULL];
    System.assertEquals(true, ld <> null);
    ld.Linked_In_URL__c = 'https://www.linkedin.com/in/testing1-9a9a5b3b/';
    update ld;
    Lead ld1 = [SELECT id, Linked_In_URL__c, IsValid_LinkedIn_URL__c FROM Lead WHERE ID = :ld.Id];
    System.assertEquals(true, ld1.IsValid_LinkedIn_URL__c);
    Test.stopTest();
  }

  @IsTest
  static void validateLinkedinURLNeg() {
    Test.startTest();
    Lead ld = new Lead(lastname = 'testl', company = 'Test1');
    insert ld;
    System.assertEquals(true, ld <> null);
    ld.company = 'company';
    update ld;
    Lead ld1 = [SELECT id, Linked_In_URL__c, IsValid_LinkedIn_URL__c FROM Lead WHERE ID = :ld.Id];
    System.assertEquals(false, ld1.IsValid_LinkedIn_URL__c);
    Test.stopTest();
  }

  private static List<Lead> getLead() {
    List<Lead> LdList = new List<Lead>();
    Lead ld = new Lead(
      lastname = 'test lead',
      company = 'Test',
      Email = 'aa@invalid.salesfoce.com',
      Status = 'Inquiry',
      Linked_In_URL__c = 'https://www.linkedin.com/in/test-9a9a5b3a',
      IsValid_LinkedIn_URL__c = true
    );
    LdList.add(ld);
    insert ld;
    return LdList;
  }

  @IsTest
  static void mergeToCon() {
    Test.startTest();
    Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName()
      .get('WDR Candidate')
      .getRecordTypeId();
    List<Lead> LeadList = getLead();
    Account testAccount = ESDJC_TestUtil.createAccount();
    List<contact> conlist1 = new List<contact>();
    Contact cont1 = new Contact(
      FirstName = 'Test',
      LastName = 'Testing',
      Accountid = testAccount.id,
      email = LeadList[0].email,
      RecordtypeId = RecordTypeIdContact
    );
    conlist1.add(cont1);
    insert conlist1;
    List<contact> conlist = new List<contact>();
    Contact cont = new Contact(
      FirstName = 'Test',
      LastName = 'Test',
      Accountid = testAccount.id,
      email = LeadList[0].email,
      RecordtypeId = RecordTypeIdContact
    );
    conlist.add(cont);
    insert conlist;
    CEMCI_Leads.mergeToContactsAndLeads();
    Test.stopTest();
  }

  @IsTest
  static void mergeToCon1() {
    Test.startTest();
    Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName()
      .get('WDR Candidate')
      .getRecordTypeId();
    List<Lead> LeadList = getLead();
    Account testAccount = ESDJC_TestUtil.createAccount();
    List<contact> conlist = new List<contact>();
    Contact cont = new Contact(
      FirstName = 'Test',
      LastName = 'Test',
      Accountid = testAccount.id,
      email = LeadList[0].email,
      RecordtypeId = RecordTypeIdContact
    );
    conlist.add(cont);
    insert conlist;
    System.assertEquals('aa@invalid.salesfoce.com', conlist[0].email);
    CEMCI_Leads.mergeToContactsAndLeads();
    Test.stopTest();
  }

  static Database.LeadConvertResult[] setUpRecords() {
    List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();

    String randomString = '1010110100';
    String leadStatus = 'New';
    String leadConvertedStatus = 'Converted';
    String company = 'ACME';
    String emailSuffix = '@not.salesforce.com';
    String leadEmail = randomString + emailSuffix;
    RecordType contactWRCandidateType = [
      SELECT Id, DeveloperName
      FROM RecordType
      WHERE SOBjecttype = 'Contact' AND developername = 'WDR_Candidate'
    ];

    Account testAccount = new Account(Name = 'ACME');

    insert testAccount;

    Contact confidentialContact = new Contact(
      FirstName = randomString,
      LastName = randomString,
      Email = leadEmail,
      AccountId = testAccount.Id,
      RecordTypeId = contactWRCandidateType.Id,
      Boomerang__c = false,
      Remote_Only__c = false,
      Confidential__c = true
    );

    insert confidentialContact;

    // Mixing confidential and non-confidential records to avoid the
    // trigger merge records in this test
    Lead nonConfidentialLead = new Lead(
      LastName = randomString,
      Status = leadStatus,
      Company = company,
      Email = leadEmail,
      Boomerang__c = true,
      Remote_Only__c = true,
      Confidential__c = false
    );

    insert nonConfidentialLead;

    Database.LeadConvert leadConvertContact = new Database.LeadConvert();
    leadConvertContact.setLeadId(nonConfidentialLead.Id);
    leadConvertContact.setContactId(confidentialContact.Id);
    leadConvertContact.setAccountId(testAccount.Id);
    leadConvertContact.setDoNotCreateOpportunity(true);
    leadConvertContact.setConvertedStatus(leadConvertedStatus);

    leadsToConvert.add(leadConvertContact);

    Database.LeadConvertResult[] convertResults = Database.convertLead(leadsToConvert, true);

    return convertResults;
  }

  @IsTest
  static void testCheckboxAssigmentGlobal() {
    Database.LeadConvertResult[] convertResults = setUpRecords();
    CEMCI_Leads.assignConvertedLeadValuesToContact(convertResults);
    Map<Id, Contact> convertedContacts = new Map<Id, Contact>(
      [SELECT Id, Boomerang__c, Remote_Only__c FROM Contact WHERE Account.Name = 'ACME']
    );

    Lead nonConfidentialLead = [
      SELECT Id, Boomerang__c, Remote_Only__c, ConvertedContactId
      FROM Lead
      WHERE ConvertedContact.Account.Name = 'ACME'
      LIMIT 1
    ];

    Contact converted = convertedContacts.get(nonConfidentialLead.ConvertedContactId);

    Boolean testAssertion = (converted.Boomerang__c == nonConfidentialLead.Boomerang__c &&
    converted.Remote_Only__c == nonConfidentialLead.Remote_Only__c);

    System.assert(testAssertion, 'Some checkboxes were not assigned.');
  }

  @IsTest
  static void testChecboxAssignment() {
    Database.LeadConvertResult[] convertResults = setUpRecords();
    List<Id> leadIds = CEMCI_Leads.getConvertedLeadsIds(convertResults);
    List<Lead> convertedLeads = CEMCI_Leads.getConvertedLeadsAndContacts(leadIds);
    Map<Id, Contact> convertedContacts = new Map<Id, Contact>(CEMCI_Leads.assignConvertedLeadValues(convertedLeads));

    Lead nonConfidentialLead = [
      SELECT Id, Boomerang__c, Remote_Only__c, ConvertedContactId
      FROM Lead
      WHERE ConvertedContact.Account.Name = 'ACME'
      LIMIT 1
    ];

    Contact converted = convertedContacts.get(nonConfidentialLead.ConvertedContactId);

    Boolean testAssertion = (converted.Boomerang__c == nonConfidentialLead.Boomerang__c &&
    converted.Remote_Only__c == nonConfidentialLead.Remote_Only__c);

    System.assert(testAssertion, 'Some checkboxes were not assigned.');
  }

  @IsTest
  static void testGetConvertedRecords() {
    Database.LeadConvertResult[] convertResults = setUpRecords();
    List<Id> leadIds = CEMCI_Leads.getConvertedLeadsIds(convertResults);
    Map<Id, Lead> convertedLeads = new Map<Id, Lead>(CEMCI_Leads.getConvertedLeadsAndContacts(leadIds));

    Lead nonConfidentialLead = [
      SELECT Id, ConvertedContact.Account.Name, ConvertedContactId
      FROM Lead
      WHERE ConvertedContact.Account.Name = 'ACME'
      LIMIT 1
    ];

    Boolean testAssertion = (convertedLeads.get(nonConfidentialLead.Id) != null);

    System.assert(testAssertion, 'Lead was not converted.');
  }

  @IsTest
  static void testGetConvertedLeadIds() {
    Database.LeadConvertResult[] convertResults = setUpRecords();
    Set<Id> leadIds = new Set<Id>(CEMCI_Leads.getConvertedLeadsIds(convertResults));
    Lead nonConfidentialLead = [SELECT Id FROM Lead WHERE Company = 'ACME' LIMIT 1];
    Boolean testAssertion = leadIds.contains(nonConfidentialLead.Id);
    System.assert(testAssertion, 'Lead Id was not retrieved.');
  }

  @IsTest
  private static void testGetQueryFields() {
    String leadCheckboxesFieldSetName = 'CEMCILeadCheckboxes';
    Schema.FieldSet leadCheckboxesFieldSet = Schema.SObjectType.Lead.fieldSets.getMap().get(leadCheckboxesFieldSetName);
    Map<String, SObjectField> leadCheckboxes = WDR_Util.getFieldMap(leadCheckboxesFieldSet);
    List<String> currentLeadCheckboxes = new List<String>{
      'Awaiting_Lead_De_duplication__c',
      'Boomerang__c',
      'Confidential__c',
      'Currently_Enrolled_in_MC_Journey__c',
      'Do_Not_Hire__c',
      'DoNotCall',
      'HasOptedOutOfFax',
      'IsConverted',
      'IsLead__c',
      'IsUnreadByOwner',
      'Phone_Opt_In__c',
      'Privacy_Policy_Intro__c',
      'Regrettable_Boomerang__c',
      'Remote_Only__c',
      'RM_Lead__c',
      'Withdrawn__c'
    };

    Set<String> fields = leadCheckboxes.keySet();
    Boolean testAssertion = fields.containsAll(currentLeadCheckboxes);
    System.assert(testAssertion, 'Some fields are missing.');
  }

  /**
   * GIVEN: A lead (A) with an email and no linkedin url exists in the database
   * WHEN: a new lead(B) is inserted with the same email address
   * THEN: lead B should be merged into lead A with blank LinkedInURL
   */
  /*
  @IsTest
  private static void test_mergeLeads_SameEmail_NoLinkedIn() {
    User osrUser = [SELECT id FROM User WHERE Email = 'osrUser@not.salesforce.com'];

    Lead leadA = generateLead('LeadA', 'LeadA', 'leadA@not.salesforce.com', null);
    leadA.OwnerId = osrUser.Id;
    insert leadA;
    Lead leadB = generateLead('LeadB', 'LeadB', 'leadA@not.salesforce.com', null);

    Test.startTest();
    System.runAs(osrUser) {
      System.assertEquals(
        true,
        FeatureManagement.checkPermission('CEMCI_Auto_Merge'),
        'User should be assigned automerge perm'
      );
      Database.DMLOptions dml = new Database.DMLOptions();
      dml.DuplicateRuleHeader.allowSave = true;
      dml.DuplicateRuleHeader.runAsCurrentUser = true;
      Database.Insert(leadB, dml);
    }
    Test.stopTest();
    List<Lead> ldList = [
      SELECT id, Email, IsDeleted
      FROM Lead
      WHERE email = 'leadA@not.salesforce.com' AND IsDeleted = FALSE
    ];
    System.assertEquals(1, ldList.size(), 'Lead should have been merged');
  }

  /**
   * GIVEN: A lead (A) with an email and no linkedin url exists in the database
   * WHEN: a new lead(B) is inserted with the same email address and LinkedIn URL
   * THEN: lead B should be merged into lead A with LinkedIn URL copied to Lead A
   */
  /*
  @IsTest
  private static void test_mergeLeads_SameEmail_LinkedInOnLosing() {
  }

  /**
   * GIVEN: A lead (A) with an email and LinkedIn URL
   * WHEN: a new lead(B) is inserted with the same email address and LinkedIn URL
   * THEN: lead B should be merged into lead A with LinkedIn URL copied to Lead A
   */
  
   /*
  @IsTest
  private static void test_mergeLeads_SameEmail_DifferentLinkedIn() {
  }

  /**
   * GIVEN: A lead (A) with an email and linkedin url exists in the database
   * WHEN: a new lead(B) is inserted with a different email address and matching URL to Lead(A)
   * THEN: lead B should be merged into lead A
   */

   /*
  @IsTest
  private static void test_mergeLeads_DiffEmail_SameLinkedIn() {
    User osrUser = [SELECT id FROM User WHERE Email = 'osrUser@not.salesforce.com'];

    Lead leadA = generateLead('LeadA', 'LeadA', 'leadA@not.salesforce.com', 'https://www.linkedin.com/in/lead_a');
    leadA.OwnerId = osrUser.Id;
    insert leadA;
    Lead leadB = generateLead('LeadB', 'LeadB', 'leadB@not.salesforce.com', 'https://www.linkedin.com/in/lead_a');

    Test.startTest();
    System.runAs(osrUser) {
      System.assertEquals(
        true,
        FeatureManagement.checkPermission('CEMCI_Auto_Merge'),
        'User should be assigned automerge perm'
      );
      Database.DMLOptions dml = new Database.DMLOptions();
      dml.DuplicateRuleHeader.allowSave = true;
      dml.DuplicateRuleHeader.runAsCurrentUser = true;
      Database.Insert(leadB, dml);
    }
    Test.stopTest();
    List<Lead> ldList = [
      SELECT id, Email, IsDeleted, LinkedIn_Substring__c
      FROM Lead
      WHERE Linked_In_URL__c = 'https://www.linkedin.com/in/lead_a' AND IsDeleted = FALSE
    ];
    System.assertEquals(1, ldList.size(), 'Lead should have been merged');
  }

  private static Lead generateLead(String firstName, String lastName, String emailAddress, String linkedInURL) {
    Lead l = new Lead();
    l.FirstName = firstName;
    l.LastName = lastName;
    l.Email = emailAddress;
    l.Linked_In_URL__c = linkedInURL;
    l.Status = 'New';
    l.Company = 'TestCompany';
    l.IsValid_LinkedIn_URL__c = true;

    return l;
  }
  */
}