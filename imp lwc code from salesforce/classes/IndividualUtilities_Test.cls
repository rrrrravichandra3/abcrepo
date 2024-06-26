@isTest
public with sharing class IndividualUtilities_Test {
  // Setup Data for tests
  @TestSetup
  static void setupData() {
    CEMCI_Test_Util.createCEMCICustomSetting();

    Individual individual;
    List<User> userList = [SELECT Id FROM User WHERE isActive = TRUE AND Profile.Name = 'System Administrator' LIMIT 2];
    System.runAs(userList[0]) {
      DataUseLegalBasis dataUseLegalBasis = ConsentCaptureTestUtilities.createDataUseLegalBasis(
        'Global Default',
        'Consent',
        'Business Card 1:1'
      );
      DataUsePurpose dataUsePurpose = ConsentCaptureTestUtilities.createDataUsePurpose(
        dataUseLegalBasis.Id,
        'Email',
        'Email',
        true,
        'Email',
        null,
        'Marketing'
      );
      Account account = ConsentCaptureTestUtilities.createAccount();
      individual = ConsentCaptureTestUtilities.createIndividual('test', 'test');
      Id wdrContactRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('WDR_Candidate')
        .getRecordTypeId();
      Contact contact = ConsentCaptureTestUtilities.createContact(
        account.Id,
        individual.Id,
        'testContact',
        'testContact@example.com',
        null,
        null,
        wdrContactRTId,
        null,
        null
      );
      Contact contact2 = ConsentCaptureTestUtilities.createContact(
        account.Id,
        null,
        'testContact2',
        null,
        null,
        null,
        wdrContactRTId,
        null,
        null
      );
      Lead lead = ConsentCaptureTestUtilities.createLead(
        individual.Id,
        'testLead',
        'testLead@example.com',
        '9872872828',
        'TestCompany',
        'US',
        null,
        null
      );
      Lead lead2 = ConsentCaptureTestUtilities.createLead(
        null,
        'testLead2',
        null,
        null,
        'TestCompany',
        'US',
        null,
        null
      );
      ContactPointTypeConsent contactPointTypeConsent = ConsentCaptureTestUtilities.createContactPointTypeConsent(
        dataUsePurpose.Id,
        individual.Id
      );
    }
    System.runAs(userList[1]) {
      User user = ConsentCaptureTestUtilities.createUser(individual.Id);
    }
  }

  static testMethod void getIndividualId() {
    List<Contact> contacts = [SELECT Id FROM Contact WHERE Name = 'testContact' LIMIT 1];
    Contact contact = (contacts.size() == 1) ? contacts.get(0) : null;

    Test.startTest();

    String individualId = IndividualUtilities.getIndividualId(contact.Id);

    Test.stopTest();

    System.assertNotEquals(null, individualId);
  }

  static testMethod void getSObjectType() {
    List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
    Contact contact = (contacts.size() == 1) ? contacts.get(0) : null;

    Test.startTest();

    String sObjectType = IndividualUtilities.getSObjectType(contact.Id);

    Test.stopTest();

    System.assertEquals('Contact', sObjectType);
  }

  static testMethod void getIndividualIdFromContact() {
    List<Contact> contacts = [SELECT Id, IndividualId FROM Contact LIMIT 1];
    Contact contact = (contacts.size() == 1) ? contacts.get(0) : null;

    List<Individual> individuals = [SELECT Id FROM Individual LIMIT 1];
    Individual individual = (individuals.size() == 1) ? individuals.get(0) : null;

    Test.startTest();

    Id individualId = IndividualUtilities.getIndividualIdFromContact(contact.Id);

    Test.stopTest();

    System.assertEquals(individual.Id, individualId);
  }

  static testMethod void getIndividualIdFromLead() {
    List<Lead> leads = [SELECT Id, IndividualId FROM Lead LIMIT 1];
    Lead lead = (leads.size() == 1) ? leads.get(0) : null;

    List<Individual> individuals = [SELECT Id FROM Individual LIMIT 1];
    Individual individual = (individuals.size() == 1) ? individuals.get(0) : null;

    Test.startTest();

    Id individualId = IndividualUtilities.getIndividualIdFromLead(lead.Id);

    Test.stopTest();

    System.assertEquals(individual.Id, individualId);
  }

  static testMethod void getIndividualIdFromAccount() {
    List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
    Account account = (accounts.size() == 1) ? accounts.get(0) : null;

    Test.startTest();

    String individualId = IndividualUtilities.getIndividualId(account.Id);

    Test.stopTest();

    System.assertNotEquals(null, individualId);
  }

  static testMethod void getBlankIndividualIdfromLead() {
    List<Lead> leads = [SELECT Id FROM Lead WHERE Name = 'testLead2' LIMIT 1];
    Lead lead = (leads.size() == 1) ? leads.get(0) : null;

    Test.startTest();

    String individualId = IndividualUtilities.getIndividualId(lead.Id);

    Test.stopTest();

    System.assertNotEquals(null, individualId);
  }

  static testMethod void getBlankIndividualIdfromContact() {
    List<Contact> contacts = [SELECT Id FROM Contact WHERE Name = 'testContact2' LIMIT 1];
    Contact contact = (contacts.size() == 1) ? contacts.get(0) : null;

    Test.startTest();

    String individualId = IndividualUtilities.getIndividualId(contact.Id);

    Test.stopTest();

    System.assertNotEquals(null, individualId);
  }
}