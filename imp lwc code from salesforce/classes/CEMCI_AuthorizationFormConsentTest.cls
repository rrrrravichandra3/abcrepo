/**
 * @author Dharma Teja Sudungunta
 * @date 02-04-2019
 * @description AuthorizationFrom Consent Test Class
 */

@isTest
public with sharing class CEMCI_AuthorizationFormConsentTest {
  @testSetup
  static void setup() {
    CEMCI_Test_Util.createCEMCICustomSetting();
    List<Lead> leadList = new List<Lead>();
    List<AuthorizationForm> authorizationFormList = new List<AuthorizationForm>();
    List<AuthorizationFormText> AuthorizationFormTexts = new List<AuthorizationFormText>();
    List<Campaign> campaignList = new List<Campaign>();
    List<Contact> contactList = new List<Contact>();
    Id WDRCandirecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
      .get('WDR_Candidate')
      .getRecordTypeId();
    for (Integer i = 0; i < 10; i++) {
      Contact con = new Contact(
        FirstName = 'test',
        LastName = 'contactAuthorization' + i,
        email = 'test' + i + '@example.com',
        phone = '123456789' + i + '',
        recordtypeId = WDRCandirecordtypeId,
        Recruiting_Opt_In__c = 'Opt In',
        Marketing_Opt_In__c = 'Opt Out'
      );
      contactList.add(con);
    }
    insert contactList;
    for (Integer i = 0; i < 10; i++) {
      Lead leadsForAuthorizationForm = new Lead(
        firstname = 'Test',
        lastname = 'LeadForAuthorization' + i,
        email = 'test' + i + '@example.com',
        phone = '123456789' + i + '',
        Marketing_Opt_In__c = 'Opt In',
        Recruiting_Opt_In__c = 'Opt Out',
        Company = 'Test'
      );
      leadList.add(leadsForAuthorizationForm);
      Lead leadsForAuthorizationFormWithOutOptValues = new Lead(
        firstname = 'leadOptvalues',
        lastname = 'LeadForAuthorizationopt' + i,
        email = 'testopt' + i + '@example.com',
        phone = '123456785' + i + '',
        Company = 'Test'
      );
      leadList.add(leadsForAuthorizationFormWithOutOptValues);
      Lead leadsForAuthorizationFormWithmarketingOptValues = new Lead(
        firstname = 'marketingOptOutValues',
        lastname = 'LeadForAuthorizationMarketing' + i,
        email = 'testMarketingopt' + i + '@example.com',
        phone = '123497753' + i + '',
        Marketing_Opt_In__c = 'Opt In',
        Recruiting_Opt_In__c = 'Opt Out',
        Company = 'Test'
      );
      leadList.add(leadsForAuthorizationFormWithmarketingOptValues);
    }
    insert leadList;

    for (Integer i = 0; i < 6; i++) {
      AuthorizationForm authorizationFormForCampaign = new AuthorizationForm(
        Name = 'CEMCI Authorization Form' + i,
        EffectiveFromDate = date.today(),
        IsSignatureRequired = true,
        RevisionNumber = 'v0'
      );
      authorizationFormList.add(authorizationFormForCampaign);
    }
    insert authorizationFormList;

    for (Integer i = 0; i < 3; i++) {
      AuthorizationFormText AuthorizationFormTextOptIn = new AuthorizationFormText(
        name = 'MarketingEmail Opt In',
        AuthorizationFormId = authorizationFormList[i].id,
        Consent_Category__c = 'Marketing',
        Consent_Type__c = 'Email',
        Opt_In_Out__c = 'Opt In',
        SummaryAuthFormText = 'Marketing Opt In'
      );
      AuthorizationFormTexts.add(AuthorizationFormTextOptIn);
      AuthorizationFormText AuthorizationFormTextOptOut = new AuthorizationFormText(
        name = 'MarketingEmail Opt out',
        AuthorizationFormId = authorizationFormList[i].id,
        Consent_Category__c = 'Marketing',
        Consent_Type__c = 'Email',
        Opt_In_Out__c = 'Opt Out',
        SummaryAuthFormText = 'Marketing Opt Out'
      );
      AuthorizationFormTexts.add(AuthorizationFormTextOptOut);
      AuthorizationFormText AuthorizationFormTextRecrOptIn = new AuthorizationFormText(
        name = 'RecruitingEmail Opt In',
        AuthorizationFormId = authorizationFormList[i].id,
        Consent_Category__c = 'Recruiting',
        Consent_Type__c = 'Email',
        Opt_In_Out__c = 'Opt In',
        SummaryAuthFormText = 'Recruiting Opt In'
      );
      AuthorizationFormTexts.add(AuthorizationFormTextRecrOptIn);
      AuthorizationFormText AuthorizationFormTextRecrOptOut = new AuthorizationFormText(
        name = 'RecruitingEmail Opt Out',
        AuthorizationFormId = authorizationFormList[i].id,
        Consent_Category__c = 'Recruiting',
        Consent_Type__c = 'Email',
        Opt_In_Out__c = 'Opt Out',
        SummaryAuthFormText = 'Recruiting Opt Out'
      );
      AuthorizationFormTexts.add(AuthorizationFormTextRecrOptOut);
      AuthorizationFormText AuthorizationFormTextRecrphOptIn = new AuthorizationFormText(
        name = 'RecruitingPhone Opt In',
        AuthorizationFormId = authorizationFormList[i].id,
        Consent_Category__c = 'Recruiting',
        Consent_Type__c = 'Phone',
        Opt_In_Out__c = 'Opt In',
        SummaryAuthFormText = 'Recruiting Opt In'
      );
      AuthorizationFormTexts.add(AuthorizationFormTextRecrphOptIn);
      AuthorizationFormText AuthorizationFormTextRecrphOptOut = new AuthorizationFormText(
        name = 'RecruitingPhone Opt Out',
        AuthorizationFormId = authorizationFormList[i].id,
        Consent_Category__c = 'Recruiting',
        Consent_Type__c = 'Phone',
        Opt_In_Out__c = 'Opt Out',
        SummaryAuthFormText = 'Recruiting Opt Out'
      );
      AuthorizationFormTexts.add(AuthorizationFormTextRecrphOptOut);
    }

    for (Integer i = 3; i < 5; i++) {
      AuthorizationFormText AuthorizationFormTextOptIn = new AuthorizationFormText(
        name = 'MarketingEmail Opt In',
        AuthorizationFormId = authorizationFormList[i].id,
        Consent_Category__c = 'Marketing',
        Consent_Type__c = 'Email',
        Opt_In_Out__c = 'Opt In',
        SummaryAuthFormText = 'Marketing Opt In'
      );
      AuthorizationFormTexts.add(AuthorizationFormTextOptIn);
      AuthorizationFormText AuthorizationFormTextOptOut = new AuthorizationFormText(
        name = 'MarketingEmail Opt Out',
        AuthorizationFormId = authorizationFormList[i].id,
        Consent_Category__c = 'Marketing',
        Consent_Type__c = 'Email',
        Opt_In_Out__c = 'Opt Out',
        SummaryAuthFormText = 'Marketing Opt Out'
      );
      AuthorizationFormTexts.add(AuthorizationFormTextOptOut);
    }
    AuthorizationFormText AuthorizationFormTextRecrOptIn = new AuthorizationFormText(
      name = 'RecruitingEmail Opt In',
      AuthorizationFormId = authorizationFormList[5].id,
      Consent_Category__c = 'Recruiting',
      Consent_Type__c = 'Email',
      Opt_In_Out__c = 'Opt In',
      SummaryAuthFormText = 'Recruiting Opt In'
    );
    AuthorizationFormTexts.add(AuthorizationFormTextRecrOptIn);
    AuthorizationFormText AuthorizationFormTextRecrOptOut = new AuthorizationFormText(
      name = 'RecruitingEmail Opt Out',
      AuthorizationFormId = authorizationFormList[5].id,
      Consent_Category__c = 'Recruiting',
      Consent_Type__c = 'Email',
      Opt_In_Out__c = 'Opt Out',
      SummaryAuthFormText = 'Recruiting Opt Out'
    );
    AuthorizationFormTexts.add(AuthorizationFormTextRecrOptOut);
    AuthorizationFormText AuthorizationFormTextRecrphOptIn = new AuthorizationFormText(
      name = 'RecruitingPhone Opt In',
      AuthorizationFormId = authorizationFormList[5].id,
      Consent_Category__c = 'Recruiting',
      Consent_Type__c = 'Phone',
      Opt_In_Out__c = 'Opt In',
      SummaryAuthFormText = 'Recruiting Opt In'
    );
    AuthorizationFormTexts.add(AuthorizationFormTextRecrphOptIn);
    AuthorizationFormText AuthorizationFormTextRecrphOptOut = new AuthorizationFormText(
      name = 'RecruitingPhone Opt Out',
      AuthorizationFormId = authorizationFormList[5].id,
      Consent_Category__c = 'Recruiting',
      Consent_Type__c = 'Phone',
      Opt_In_Out__c = 'Opt Out',
      SummaryAuthFormText = 'Recruiting Opt Out'
    );
    AuthorizationFormTexts.add(AuthorizationFormTextRecrphOptOut);

    insert AuthorizationFormTexts;

    for (Integer i = 0; i < 6; i++) {
      Campaign cmpgn = new Campaign(
        Name = 'TestCampaignForAuthorization' + i,
        Authorization_Form__c = authorizationFormList[i].id,
        IsActive = true
      );
      campaignList.add(cmpgn);
    }

    insert campaignList;
  }

  /**
   * @description checking the Campaign Has No AuthorizationForm and Checking no authorization form created.
   **/
  @isTest
  static void checkCampaignWithNoAuthorizationForm() {
    List<Lead> leadsForAuthorization = [
      SELECT Id, FirstName, LastName, email, phone, IndividualId
      FROM Lead
      WHERE FirstName LIKE '%Test'
    ];
    List<CampaignMember> CampMemList = new List<CampaignMember>();
    List<Id> individualIdsForLeads = new List<Id>();
    Campaign cmpgn = new Campaign(Name = 'NoAuthorizationFormCampaign', IsActive = true);

    insert cmpgn;
    for (Integer i = 0; i < 10; i++) {
      CampaignMember CampMemb = new CampaignMember();
      CampMemb.LeadId = leadsForAuthorization[i].Id;
      CampMemb.Status = 'Responded';
      CampMemb.CampaignId = cmpgn.Id;
      CampMemList.add(CampMemb);
      individualIdsForLeads.add(leadsForAuthorization[i].IndividualId);
    }
    insert CampMemList;
    List<AuthorizationFormConsent> AuthorizationConsent = [
      SELECT id
      FROM AuthorizationFormConsent
      WHERE id IN :individualIdsForLeads
    ];
    System.assertEquals(0, AuthorizationConsent.size());
  }

  /**
   * @description checking the Lead Or contacts Having the Marketing and recruiting As Blank We will not create  authorization form consents
   **/
  @isTest
  static void checkLeadOrContactWithBlankOptInOptOutValues() {
    List<Lead> leadsForAuthorizationOptValues = [
      SELECT Id, FirstName, LastName, email, phone, IndividualId
      FROM Lead
      WHERE FirstName LIKE '%leadOptvalues'
    ];
    List<CampaignMember> CampMemList = new List<CampaignMember>();
    List<Id> individualIdsForLeads = new List<Id>();
    Campaign cmpgn = new Campaign(Name = 'NoAuthorizationFormCampaign', IsActive = true);
    insert cmpgn;
    for (Integer i = 0; i < 10; i++) {
      CampaignMember CampMemb = new CampaignMember();
      CampMemb.LeadId = leadsForAuthorizationOptValues[i].Id;
      CampMemb.Status = 'Responded';
      CampMemb.CampaignId = cmpgn.Id;
      CampMemList.add(CampMemb);
      individualIdsForLeads.add(leadsForAuthorizationOptValues[i].IndividualId);
    }
    insert CampMemList;
    List<AuthorizationFormConsent> AuthorizationConsent = [
      SELECT id
      FROM AuthorizationFormConsent
      WHERE id IN :individualIdsForLeads
    ];
    System.assertEquals(0, AuthorizationConsent.size());
  }
  /**
   * @description check the AuthorizationFormConsents Created For the Leads inserted in to campaign with marketingoptin or RecruitingOptin
   **/
  @isTest
  static void checkAuthorizationFormConsentsInsertedForLeadsWithGLobalAuthorizationForm() {
    List<Lead> leadsForAuthorization = [
      SELECT Id, FirstName, LastName, email, phone, IndividualId
      FROM Lead
      WHERE FirstName LIKE '%Test'
    ];
    List<Campaign> campaignWithAutorizationForms = [
      SELECT id, Authorization_Form__c
      FROM Campaign
      WHERE Authorization_Form__c != NULL
    ];
    List<CampaignMember> CampMemList = new List<CampaignMember>();
    List<Id> individualIdsForLeads = new List<Id>();

    for (Integer i = 0; i < 10; i++) {
      CampaignMember CampMemb = new CampaignMember();
      CampMemb.LeadId = leadsForAuthorization[i].Id;
      CampMemb.Status = 'Responded';
      CampMemb.CampaignId = campaignWithAutorizationForms[0].Id;
      CampMemb.Hired__c = true;
      CampMemList.add(CampMemb);

      individualIdsForLeads.add(leadsForAuthorization[i].IndividualId);
    }
    insert CampMemList;
    List<AuthorizationFormConsent> AuthorizationConsent = [
      SELECT id, ConsentGiverId
      FROM AuthorizationFormConsent
      WHERE ConsentGiverId IN :individualIdsForLeads AND IsActive__c = TRUE
    ];
    System.assertEquals(30, AuthorizationConsent.size());
  }

  /**
   * @description check the AuthorizationFormConsents Created For the Leads inserted in to campaign with marketingoptin and Authorform Only for marketingoptin
   **/
  @isTest
  static void checkAuthorizationFormConsentForLeadsWithOPtinWithMarketingAuthorizationForm() {
    List<Lead> leadsForAuthorization = [
      SELECT Id, FirstName, LastName, email, phone, IndividualId
      FROM Lead
      WHERE FirstName LIKE '%marketingOptOutValues'
    ];
    List<Campaign> campaignWithAutorizationForms = [
      SELECT id, Authorization_Form__c
      FROM Campaign
      WHERE Authorization_Form__c != NULL
    ];
    List<CampaignMember> CampMemList = new List<CampaignMember>();
    List<Id> individualIdsForLeads = new List<Id>();

    for (Integer i = 0; i < 10; i++) {
      CampaignMember CampMemb = new CampaignMember();
      CampMemb.LeadId = leadsForAuthorization[i].Id;
      CampMemb.Status = 'Responded';
      CampMemb.CampaignId = campaignWithAutorizationForms[3].Id;
      CampMemList.add(CampMemb);

      individualIdsForLeads.add(leadsForAuthorization[i].IndividualId);
    }
    insert CampMemList;
    List<AuthorizationFormConsent> AuthorizationConsent = [
      SELECT id, ConsentGiverId
      FROM AuthorizationFormConsent
      WHERE ConsentGiverId IN :individualIdsForLeads AND IsActive__c = TRUE
    ];
    System.assertEquals(10, AuthorizationConsent.size());
  }

  /**
   * @description check the AuthorizationFormConsents Created For the Leads inserted in to campaign with marketingoptin and Authorform Only for marketingoptin
   **/
  @isTest
  static void checkAuthorizationFormConsentForLeadsWithOPtinWithRecruitingAuthorizationForm() {
    List<Lead> leadsForAuthorization = [
      SELECT Id, FirstName, LastName, email, phone, IndividualId, Recruiting_Opt_In__c, Marketing_Opt_In__c
      FROM Lead
      WHERE FirstName LIKE '%leadOptvalues'
    ];
    List<Lead> updatedOptInValuesForLead = new List<Lead>();
    for (lead l : leadsForAuthorization) {
      l.Recruiting_Opt_In__c = 'Opt In';
      updatedOptInValuesForLead.add(l);
    }
    update updatedOptInValuesForLead;
    List<Campaign> campaignWithAutorizationForms = [
      SELECT id, Authorization_Form__c
      FROM Campaign
      WHERE Authorization_Form__c != NULL
    ];
    List<CampaignMember> CampMemList = new List<CampaignMember>();
    List<Id> individualIdsForLeads = new List<Id>();

    for (Integer i = 0; i < 10; i++) {
      CampaignMember CampMemb = new CampaignMember();
      CampMemb.LeadId = updatedOptInValuesForLead[i].Id;
      CampMemb.Status = 'Responded';
      CampMemb.CampaignId = campaignWithAutorizationForms[5].Id;
      CampMemList.add(CampMemb);

      individualIdsForLeads.add(leadsForAuthorization[i].IndividualId);
    }
    insert CampMemList;
    List<AuthorizationFormConsent> AuthorizationConsent = [
      SELECT id, ConsentGiverId
      FROM AuthorizationFormConsent
      WHERE ConsentGiverId IN :individualIdsForLeads AND IsActive__c = TRUE
    ];
    System.assertEquals(20, AuthorizationConsent.size());
  }
  /**
   * @description check the AuthorizationFormConsents Created For the Leads inserted in to campaign with marketingoptou and Authorform global when added to new campaign
   **/
  @isTest
  static void checkAuthorizationFormConsentForLeadsWithMarketingOptOutAddingToOtherCampaign() {
    List<Lead> leadsForAuthorization = [
      SELECT Id, FirstName, LastName, email, phone, IndividualId, Recruiting_Opt_In__c, Marketing_Opt_In__c
      FROM Lead
      WHERE FirstName LIKE '%Test'
    ];
    List<Lead> updatedOptInValuesForLead = new List<Lead>();
    List<Campaign> campaignWithAutorizationForms = [
      SELECT id, Authorization_Form__c
      FROM Campaign
      WHERE Authorization_Form__c != NULL
    ];
    List<CampaignMember> CampMemList = new List<CampaignMember>();
    List<Id> individualIdsForLeads = new List<Id>();

    for (Integer i = 0; i < 10; i++) {
      CampaignMember CampMemb = new CampaignMember();
      CampMemb.LeadId = leadsForAuthorization[i].Id;
      CampMemb.Status = 'Responded';
      CampMemb.CampaignId = campaignWithAutorizationForms[1].Id;
      CampMemList.add(CampMemb);
      individualIdsForLeads.add(leadsForAuthorization[i].IndividualId);
    }
    insert CampMemList;

    for (lead l : leadsForAuthorization) {
      l.Marketing_Opt_In__c = 'Opt Out';
      l.Recruiting_Opt_In__c = 'Opt In';
      updatedOptInValuesForLead.add(l);
    }
    update updatedOptInValuesForLead;
    List<CampaignMember> CampMemList1 = new List<CampaignMember>();
    for (Integer i = 0; i < 10; i++) {
      CampaignMember CampMemb = new CampaignMember();
      CampMemb.LeadId = updatedOptInValuesForLead[i].Id;
      CampMemb.Status = 'Responded';
      CampMemb.CampaignId = campaignWithAutorizationForms[2].Id;
      CampMemList1.add(CampMemb);
      individualIdsForLeads.add(updatedOptInValuesForLead[i].IndividualId);
    }
    insert CampMemList1;
    List<AuthorizationFormConsent> AuthorizationConsent = [
      SELECT id, ConsentGiverId
      FROM AuthorizationFormConsent
      WHERE ConsentGiverId IN :individualIdsForLeads AND IsActive__c = TRUE
    ];
    List<CampaignMember> camapignList = [
      SELECT id, CampaignId
      FROM CampaignMember
      WHERE LeadId IN :updatedOptInValuesForLead
    ];
    System.assertEquals(30, AuthorizationConsent.size());
  }
  /**
   * @description check the AuthorizationFormConsents Created For the Contacts inserted in to campaign with marketing opt in and recruiting opt out and Authorform global when added to new campaign
   **/
  @isTest
  static void checkAuthorizationFormConsentForContactsByAddingToNewCampaign() {
    List<Contact> ContactsForAuthorization = [
      SELECT Id, FirstName, LastName, email, phone, IndividualId, Recruiting_Opt_In__c, Marketing_Opt_In__c
      FROM Contact
      WHERE FirstName LIKE '%Test'
    ];
    List<Contact> updatedOptInValuesForContact = new List<Contact>();
    List<Campaign> campaignWithAutorizationForms = [
      SELECT id, Authorization_Form__c
      FROM Campaign
      WHERE Authorization_Form__c != NULL
    ];
    List<CampaignMember> CampMemList = new List<CampaignMember>();
    List<Id> individualIdsForContacts = new List<Id>();

    for (Integer i = 0; i < 10; i++) {
      CampaignMember CampMemb = new CampaignMember();
      CampMemb.ContactId = ContactsForAuthorization[i].Id;
      CampMemb.Status = 'Responded';
      CampMemb.CampaignId = campaignWithAutorizationForms[1].Id;
      CampMemList.add(CampMemb);
      individualIdsForContacts.add(ContactsForAuthorization[i].IndividualId);
    }
    insert CampMemList;

    for (Contact Con : ContactsForAuthorization) {
      Con.Recruiting_Opt_In__c = 'Opt Out';
      updatedOptInValuesForContact.add(Con);
    }
    update updatedOptInValuesForContact;
    List<CampaignMember> CampMemList1 = new List<CampaignMember>();
    for (Integer i = 0; i < 10; i++) {
      CampaignMember CampMemb = new CampaignMember();
      CampMemb.ContactId = updatedOptInValuesForContact[i].Id;
      CampMemb.Status = 'Responded';
      CampMemb.CampaignId = campaignWithAutorizationForms[2].Id;
      CampMemList1.add(CampMemb);
      individualIdsForContacts.add(updatedOptInValuesForContact[i].IndividualId);
    }
    insert CampMemList1;
    List<AuthorizationFormConsent> AuthorizationConsent = [
      SELECT id, ConsentGiverId
      FROM AuthorizationFormConsent
      WHERE ConsentGiverId IN :individualIdsForContacts AND IsActive__c = TRUE
    ];
    System.assertEquals(30, AuthorizationConsent.size());
  }
  /**
   * @description check the AuthorizationFormConsents Created For the Contacts inserted in to campaign with marketing opt in and recruiting opt out and Authorform global when added to new campaign and  updating the campaign member
   **/
  @isTest
  static void checkAuthorizationFormConsentForContactsUpdatingCampaignMember() {
    List<Contact> ContactsForAuthorization = [
      SELECT Id, FirstName, LastName, email, phone, IndividualId, Recruiting_Opt_In__c, Marketing_Opt_In__c
      FROM Contact
      WHERE FirstName LIKE '%Test'
    ];
    List<Contact> updatedOptInValuesForContact = new List<Contact>();
    List<Campaign> campaignWithAutorizationForms = [
      SELECT id, Authorization_Form__c
      FROM Campaign
      WHERE Authorization_Form__c != NULL
    ];
    List<CampaignMember> CampMemList = new List<CampaignMember>();
    List<Id> individualIdsForContacts = new List<Id>();

    for (Integer i = 0; i < 10; i++) {
      CampaignMember CampMemb = new CampaignMember();
      CampMemb.ContactId = ContactsForAuthorization[i].Id;
      CampMemb.Status = 'Responded';
      CampMemb.CampaignId = campaignWithAutorizationForms[1].Id;
      CampMemList.add(CampMemb);
      individualIdsForContacts.add(ContactsForAuthorization[i].IndividualId);
    }
    insert CampMemList;

    List<CampaignMember> CampMemList1 = new List<CampaignMember>();
    for (CampaignMember Con : [
      SELECT Id, Recruiting_Opt_In__c, Marketing_Opt_In__c
      FROM CampaignMember
      WHERE ContactId IN :ContactsForAuthorization
    ]) {
      Con.Marketing_Opt_In__c = 'Opt In';
      CampMemList1.add(Con);
    }
    update CampMemList1;

    List<AuthorizationFormConsent> AuthorizationConsent = [
      SELECT id, ConsentGiverId
      FROM AuthorizationFormConsent
      WHERE ConsentGiverId IN :individualIdsForContacts AND IsActive__c = TRUE
    ];
    System.assertEquals(30, AuthorizationConsent.size());
  }
}