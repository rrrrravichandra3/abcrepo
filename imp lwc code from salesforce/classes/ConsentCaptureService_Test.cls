/**
 * Created by stephan.garcia on 2019-09-04.
 */

@isTest
public with sharing class ConsentCaptureService_Test {
  // Setup Data for tests
  @TestSetup
  static void setupData() {
    CEMCI_Test_Util.createCEMCICustomSetting();

    List<User> userList = [SELECT Id FROM User WHERE isActive = TRUE AND Profile.Name = 'System Administrator' LIMIT 2];
    Individual leadIndividual, leadIndividual2, contactIndividual1, contactIndividual2;
    AuthorizationForm recruitingAuthorizationForm, marketingAuthorizationForm;
    AuthorizationFormText recruitingAuthorizationFormText, marketingAuthorizationFormText;
    User user;
    Lead lead, lead2;
    System.runAs(userList[0]) {
      DataUseLegalBasis dataUseLegalBasis = ConsentCaptureTestUtilities.createDataUseLegalBasis(
        'Global Default',
        'Consent',
        'Business Card 1:1'
      );
      DataUsePurpose globalDefaultDataUsePurpose = ConsentCaptureTestUtilities.createDataUsePurpose(
        dataUseLegalBasis.Id,
        'Email',
        'Email',
        true,
        'Email',
        null,
        'Marketing'
      );
      DataUsePurpose countryDefaultEmailDataUsePurpose = ConsentCaptureTestUtilities.createDataUsePurpose(
        dataUseLegalBasis.Id,
        'Email',
        'Email',
        true,
        'Email',
        'US',
        'Marketing'
      );
      DataUsePurpose countryDefaultEmailDataUsePurpose1 = ConsentCaptureTestUtilities.createDataUsePurpose(
        dataUseLegalBasis.Id,
        'Email',
        'Email',
        true,
        'Email',
        'US;CA',
        'Recruiting'
      );
      DataUsePurpose recruitingDataUsePurpose = ConsentCaptureTestUtilities.createDataUsePurpose(
        dataUseLegalBasis.Id,
        'Email',
        'Email',
        true,
        'Email',
        'US',
        'Recruiting'
      );
      DataUsePurpose marketingDataUsePurpose = ConsentCaptureTestUtilities.createDataUsePurpose(
        dataUseLegalBasis.Id,
        'Email',
        'Email',
        true,
        'Email',
        'US',
        'Marketing'
      );
      DataUsePurpose countryDefaultPhoneDataUsePurpose = ConsentCaptureTestUtilities.createDataUsePurpose(
        dataUseLegalBasis.Id,
        'Phone',
        'Phone',
        true,
        'Phone',
        'US;CA',
        'Recruiting'
      );

      recruitingAuthorizationForm = ConsentCaptureTestUtilities.createAuthorizationForm(
        'CEMCI Recruiting Authorization Form',
        'V0',
        System.today(),
        System.today().addDays(60)
      );
      recruitingAuthorizationFormText = ConsentCaptureTestUtilities.createAuthorizationFormText(
        recruitingAuthorizationForm.Id,
        recruitingDataUsePurpose.Id,
        'CEMCI Authorization - Recruiting Email Opt In',
        'Recruiting',
        'Email',
        'Opt In'
      );
      marketingAuthorizationForm = ConsentCaptureTestUtilities.createAuthorizationForm(
        'CEMCI Marketing Authorization Form',
        'V0',
        System.today(),
        System.today().addDays(60)
      );
      marketingAuthorizationFormText = ConsentCaptureTestUtilities.createAuthorizationFormText(
        marketingAuthorizationForm.Id,
        marketingDataUsePurpose.Id,
        'CEMCI Authorization - Marketing Email Opt In',
        'Marketing',
        'Email',
        'Opt In'
      );

      leadIndividual = ConsentCaptureTestUtilities.createIndividual('test', 'lead');
      leadIndividual2 = ConsentCaptureTestUtilities.createIndividual('test', 'lead2');
      lead = ConsentCaptureTestUtilities.createLead(
        leadIndividual.Id,
        'testLead2',
        'testLead@example.com',
        '9872872828',
        'TestCompany',
        'US',
        'Opt In',
        'Opt In'
      );
      lead2 = ConsentCaptureTestUtilities.createLead(
        leadIndividual2.Id,
        'testLead2',
        'testLead@example.com',
        '9872872828',
        'TestCompany',
        'CA',
        null,
        null
      );

      Account account = ConsentCaptureTestUtilities.createAccount();
      Id wdrContactRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('WDR_Candidate')
        .getRecordTypeId();
      contactIndividual1 = ConsentCaptureTestUtilities.createIndividual('test', 'lead1');
      contactIndividual2 = ConsentCaptureTestUtilities.createIndividual('test', 'lead2');
      Contact contact = ConsentCaptureTestUtilities.createContact(
        account.Id,
        contactIndividual1.Id,
        'testContact',
        'testContact@example.com',
        null,
        null,
        wdrContactRTId,
        null,
        null
      );
      Contact contactwithCountry = ConsentCaptureTestUtilities.createContact(
        account.Id,
        contactIndividual2.Id,
        'testContact2',
        'testContact2@example.com',
        '9872872828',
        'US',
        wdrContactRTId,
        null,
        null
      );

      ContactPointTypeConsent contactPointTypeConsent = ConsentCaptureTestUtilities.createContactPointTypeConsent(
        globalDefaultDataUsePurpose.Id,
        leadIndividual.Id
      );
    }
    System.runAs(userList[1]) {
      user = ConsentCaptureTestUtilities.createUser(leadIndividual.Id);
    }
    System.runAs(user) {
      Id RTId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName()
        .get('Recruitment_Marketing')
        .getRecordTypeId();
      Campaign recruitingCampaign = ConsentCaptureTestUtilities.createCampaign(
        recruitingAuthorizationForm.Id,
        'Recruitment Marketing Campaign',
        'In Progress',
        RTId
      );
      CampaignMember recruitingCampaignMember = ConsentCaptureTestUtilities.createCampaignMember(
        lead.Id,
        recruitingCampaign.Id,
        'Sent',
        'Opt In',
        null
      );

      Campaign marketingCampaign = ConsentCaptureTestUtilities.createCampaign(
        marketingAuthorizationForm.Id,
        'Marketing Campaign',
        'In Progress',
        RTId
      );
      CampaignMember marketingCampaignMember = ConsentCaptureTestUtilities.createCampaignMember(
        lead.Id,
        marketingCampaign.Id,
        'Sent',
        null,
        'Opt In'
      );
    }

  }

  static testMethod void getIndividualConsent() {
    List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
    Contact contact = (contacts.size() == 1) ? contacts.get(0) : null;

    Test.startTest();

    List<Map<String, Object>> flatList = ConsentCaptureService.getIndividualConsent(contact.Id);

    Test.stopTest();

    System.assertEquals(1, flatList.size());
  }

  static testMethod void getCountryDefaultConsentforContact() {
    List<Contact> contacts = [SELECT Id FROM Contact WHERE Mailing_Country__c = 'US' LIMIT 1];
    Contact contact = (contacts.size() == 1) ? contacts.get(0) : null;

    Test.startTest();

    List<Map<String, Object>> flatList = ConsentCaptureService.getIndividualConsent(contact.Id);

    Test.stopTest();

    System.assertEquals(2, flatList.size());
  }

  static testMethod void getCountryDefaultConsentforLead() {
    List<Lead> leads = [SELECT Id FROM Lead WHERE Mailing_Country_Global__c = 'CA' LIMIT 1];
    Lead lead = (leads.size() == 1) ? leads.get(0) : null;

    Test.startTest();

    List<Map<String, Object>> flatList = ConsentCaptureService.getIndividualConsent(lead.Id);

    Test.stopTest();

    System.assertEquals(2, flatList.size());
  }

  static testMethod void getLeadConsent() {
    List<Lead> leads = [SELECT Id FROM Lead WHERE Mailing_Country_Global__c = 'US' LIMIT 1];
    Lead lead = (leads.size() == 1) ? leads.get(0) : null;

    Test.startTest();

    List<Map<String, Object>> flatList = ConsentCaptureService.getIndividualConsent(lead.Id);

    Test.stopTest();

    System.assertEquals(2, flatList.size());
  }

  static testMethod void getContactPointTypeDescription() {
    Test.startTest();

    String description = ConsentCaptureService.getContactPointTypeDescription('Email');

    Test.stopTest();

    System.assertNotEquals(null, description);
  }
}