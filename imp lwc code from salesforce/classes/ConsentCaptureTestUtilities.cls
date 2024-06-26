/**
 * Created by stephan.garcia on 2019-09-04.
 */

@isTest
public with sharing class ConsentCaptureTestUtilities {
  // Create Data Use Legal Basis
  public static DataUseLegalBasis createDataUseLegalBasis(String Name, String Description, String Source) {
    DataUseLegalBasis dataUseLegalBasis = new DataUseLegalBasis(
      Name = Name,
      Description = Description,
      Source = Source
    );
    insert dataUseLegalBasis;
    return dataUseLegalBasis;
  }

  // Create Data Use Purpose
  public static DataUsePurpose createDataUsePurpose(
    Id dataUseLegalBasisId,
    String Name,
    String Description,
    Boolean DefaultValue,
    String ConsentType,
    String Countries,
    String ConsentCategory
  ) {
    DataUsePurpose dataUsePurpose = new DataUsePurpose(
      Name = Name,
      Description = Description,
      LegalBasisId = dataUseLegalBasisId,
      Default__c = DefaultValue,
      Consent_Type__c = ConsentType,
      Country_ies__c = Countries,
      Consent_Category__c = ConsentCategory
    );
    insert dataUsePurpose;
    return dataUsePurpose;
  }

  // Create Authorization Form
  public static AuthorizationForm createAuthorizationForm(
    String Name,
    String RevisionNumber,
    Date EffectiveFromDate,
    Date EffectiveToDate
  ) {
    AuthorizationForm authorizationForm = new AuthorizationForm(
      Name = Name,
      RevisionNumber = RevisionNumber,
      EffectiveFromDate = EffectiveFromDate,
      EffectiveToDate = EffectiveToDate
    );
    insert authorizationForm;
    return authorizationForm;
  }

  // Create Authorization Form Text
  public static AuthorizationFormText createAuthorizationFormText(
    Id authorizationFormId,
    Id dataUsePurposeId,
    String Name,
    String ConsentCategory,
    String ConsentType,
    String OptInOut
  ) {
    AuthorizationFormText authorizationFormText = new AuthorizationFormText(
      Name = Name,
      AuthorizationFormId = authorizationFormId,
      Consent_Category__c = ConsentCategory,
      Consent_Type__c = ConsentType,
      Opt_In_Out__c = OptInOut,
      Data_Use_Purpose__c = dataUsePurposeId
    );
    insert authorizationFormText;
    return authorizationFormText;
  }

  // Create Account
  public static Account createAccount() {
    Account account = new Account(Name = 'Test');
    insert account;
    return account;
  }

  // Create Individual
  public static Individual createIndividual(String LastName, String FirstName) {
    Individual individual = new Individual(LastName = LastName, FirstName = FirstName);
    insert individual;
    return individual;
  }

  // Create Contact
  public static Contact createContact(
    Id accountId,
    Id individualId,
    String LastName,
    String emailValue,
    String phoneValue,
    String MailingCountry,
    Id RecordTypeId,
    String RecruitingOptIn,
    String MarketingOptIn
  ) {
    Contact contact = new Contact(
      LastName = LastName,
      Email = emailValue,
      Phone = phoneValue,
      IndividualId = individualId,
      AccountId = accountId,
      Mailing_Country__c = MailingCountry,
      RecordTypeId = RecordTypeId,
      Recruiting_Opt_In__c = RecruitingOptIn,
      Marketing_Opt_In__c = MarketingOptIn
    );
    insert contact;
    return contact;
  }

  // Create Lead
  public static Lead createLead(
    Id individualId,
    String LastName,
    String emailValue,
    String phoneValue,
    String Company,
    String MailingCountry,
    String RecruitingOptIn,
    String MarketingOptIn
  ) {
    Lead lead = new Lead(
      LastName = LastName,
      Email = emailValue,
      Phone = phoneValue,
      Company = Company,
      IndividualId = individualId,
      Mailing_Country_Global__c = MailingCountry,
      Recruiting_Opt_In__c = RecruitingOptIn,
      Marketing_Opt_In__c = MarketingOptIn
    );
    insert lead;
    return lead;
  }

  // Create Campaign
  public static Campaign createCampaign(Id authorizationFormId, String Name, String Status, Id RecordTypeId) {
    Campaign campaign = new Campaign(
      Name = Name,
      Status = Status,
      Authorization_Form__c = authorizationFormId,
      RecordTypeId = RecordTypeId
    );
    insert campaign;
    return campaign;
  }

  // Create Campaign Member
  public static CampaignMember createCampaignMember(
    Id leadId,
    Id campaignId,
    String Status,
    String RecruitingOptIn,
    String MarketingOptIn
  ) {
    CampaignMember campaignMember = new CampaignMember(
      CampaignId = campaignId,
      LeadId = leadId,
      Status = Status,
      Recruiting_Opt_In__c = RecruitingOptIn,
      Marketing_Opt_In__c = MarketingOptIn
    );
    insert campaignMember;
    return campaignMember;
  }

  // Create User
  public static User createUser(Id individualId) {
    List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
    Profile profile = (profiles.size() == 1) ? profiles.get(0) : null;
    List<PermissionSet> permissionSets = [SELECT Id FROM PermissionSet WHERE Name = 'Outbound_Sourcer' LIMIT 1];
    PermissionSet permissionSet = (permissionSets.size() == 1) ? permissionSets.get(0) : null;

    String userName = 'example@example.com' + System.currentTimeMillis();

    User user = new User(
      ProfileId = profile.Id,
      Email = 'example@example.com',
      Username = userName,
      CompanyName = 'Test',
      Title = 'Title',
      Alias = 'alias',
      TimeZoneSidKey = 'America/Los_Angeles',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      LastName = 'testLast',
      FirstName = 'testFirst',
      IndividualId = individualId,
      UserPermissionsMarketingUser = true
    );

    insert user;

    PermissionSetAssignment permAssignment = new PermissionSetAssignment(
      AssigneeId = user.Id,
      PermissionSetId = permissionSet.Id
    );
    insert permAssignment;
    return user;
  }

  // Create ContactPointTypeConsent
  public static ContactPointTypeConsent createContactPointTypeConsent(Id dataUsePurposeId, Id individualId) {
    Datetime today = System.now();
    Datetime future = today.addDays(30);

    ContactPointTypeConsent contactPointTypeConsent = new ContactPointTypeConsent(
      Name = 'Test CPTC',
      DataUsePurposeId = dataUsePurposeId,
      PartyId = individualId,
      ContactPointType = 'Email',
      CaptureSource = 'Event',
      CaptureContactPointType = 'Email',
      CaptureDate = today,
      EffectiveFrom = today,
      EffectiveTo = future,
      PrivacyConsentStatus = 'Seen'
    );
    insert contactPointTypeConsent;
    return contactPointTypeConsent;
  }
}