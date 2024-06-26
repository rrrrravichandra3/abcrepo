/**
 * @description       :
 * @author            : Urvish Shah (ushah)
 * @group             :
 * @last modified on  : 07-08-2022
 * @last modified by  : Urvish Shah (ushah)
 **/
@isTest
public class CEMCI_TestDataFactory {
  public static List<Account> createAccounts(Integer numAccts) {
    List<Account> accts = new List<Account>();
    for (Integer i = 0; i < numAccts; i++) {
      Account a = new Account(Name = 'TestAccount' + i);
      accts.add(a);
    }
    insert accts;
    return accts;
  }

  public static List<Contact> createBoomerangContacts(Integer numContacts, Account acc, Id jobAppId) {
    List<Contact> contacts = new List<Contact>();
    for (Integer i = 0; i < numContacts; i++) {
      Contact con = new Contact(
        MRS_App__c = jobAppId,
        recordTypeId = getContactRecordTypeId('WDR Candidate'),
        lastName = acc.Name + ' Contact ' + i,
        accountId = acc.Id,
        Candidate_Stage__c = 'Review',
        Title = 'Salesforce Dev',
        Mailing_Country__c = 'US',
        Boomerang__c = true
      );
      contacts.add(con);
    }
    insert contacts;
    return contacts;
  }

  public static List<Contact> createNewApplicantContacts(Integer numContacts, Account acc, Id jobAppId) {
    List<Contact> contacts = new List<Contact>();
    for (Integer i = 0; i < numContacts; i++) {
      Contact con = new Contact(
        MRS_App__c = jobAppId,
        recordTypeId = getContactRecordTypeId('WDR Candidate'),
        lastName = acc.Name + ' Contact ' + i,
        accountId = acc.Id,
        Candidate_Stage__c = 'Review',
        Title = 'Salesforce Dev',
        Mailing_Country__c = 'US',
        Boomerang__c = false
      );
      contacts.add(con);
    }
    insert contacts;
    return contacts;
  }

  public static WDR_Job__c createJobReq(String jobName, Id hiringManagerId, Id recruiterId) {
    WDR_Job__c jobReq = new WDR_Job__c(
      name = jobName,
      Hiring_Manager__c = hiringManagerId,
      External_Recruiter_1__c = recruiterId
    );
    insert jobReq;
    return jobReq;
  }

  public static User getSysAdminUser() {
    return [SELECT Id FROM User WHERE profile.name = 'System Administrator' AND IsActive = TRUE LIMIT 1];
  }

  public static List<WDR_Candidate__c> createCandidates(Integer numCandidates) {
    List<WDR_Candidate__c> candidates = new List<WDR_Candidate__c>();
    for (Integer i = 0; i < numCandidates; i++) {
      WDR_Candidate__c candidate = new WDR_Candidate__c(
        Name = 'Test Candidate' + i,
        First_Name__c = 'Test',
        Last_Name__c = 'Candidate' + i,
        Email__c = 'testCandidate' + i + '@cemci.com'
      );
      candidates.add(candidate);
    }
    insert candidates;
    return candidates;
  }

  public static WDR_Application__c createJobApp(Id candidateId, String offerType, Boolean isBoomerang, Id jobReqId) {
    WDR_Application__c jobApp = new WDR_Application__c(
      Candidate__c = candidateId,
      Offer_Type__c = offerType,
      Boomerang__c = isBoomerang,
      Job__c = jobReqId
    );
    insert jobApp;
    return jobApp;
  }

  public static Id getContactRecordTypeId(String recTypeName) {
    return Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
  }

  public static User createTestUser(String profileName) {
    Profile p = [SELECT Id FROM Profile WHERE Name = :profileName];
    String orgId = UserInfo.getOrganizationId();
    String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
    Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
    String uniqueName = orgId + dateString + randomInt;
    User u = new User(
      Alias = 'standt',
      email = uniqueName + '@test' + orgId + '.org',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      Username = uniqueName + '@test' + orgId + '.org'
    );
    insert u;
    return u;
  }
}