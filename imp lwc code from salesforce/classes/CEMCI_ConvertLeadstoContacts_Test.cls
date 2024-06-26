@isTest
public with sharing class CEMCI_ConvertLeadstoContacts_Test {
  @TestSetup
  static void makeData() {
    CEMCI_Test_Util.createCEMCICustomSetting();

    Lead newLead = new Lead();
    newLead.LastName = 'TestLead';
    newLead.Company = 'BlueWave';
    newLead.LeadSource = 'Event Invited';
    newLead.Email = 'test@gmail.com';
    newLead.Status = 'New';

    Account newAcc = new Account();
    newAcc.Name = 'BlueWave';
    newAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('WDR_Candidate')
      .getRecordTypeId();

    insert newAcc;
    Contact newCon = new Contact();
    newCon.FirstName = 'Test';
    newCon.LastName = 'Contact';
    newCon.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
      .get('WDR_Candidate')
      .getRecordTypeId();
    newCon.Email = 'test@gmail.com';
    newCon.AccountId = newAcc.Id;

    insert newLead;
    insert newCon;

    WDR_Candidate__c newCand = new WDR_Candidate__c();
    newCand.First_Name__c = 'Test';
    newCand.Last_Name__c = 'Contact';
    newCand.Current_Company__c = 'BlueWave';
    newCand.Email__c = 'test@gmail.com';
    newCand.Candidate_Contact__c = newCon.Id;

    insert newCand;
  }
  @isTest
  static void ConvertLead() {
    Contact con = [SELECT Id, email, accountId, IndividualID FROM Contact WHERE email = 'test@gmail.com' LIMIT 1];
    Map<String, Contact> ContactEmailtoIdMap = new Map<String, Contact>();

    ContactEmailtoIdMap.put(con.email, con);
    Test.startTest();
    Id batchId = Database.executeBatch(new CEMCI_ConvertLeadstoContacts());
    Test.stopTest();
    AsyncApexJob job = [SELECT Status FROM AsyncApexJob WHERE Id = :batchId];
    System.assertEquals('Completed', job.Status);
  }
}