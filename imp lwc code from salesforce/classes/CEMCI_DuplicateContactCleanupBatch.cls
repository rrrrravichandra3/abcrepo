global with sharing class CEMCI_DuplicateContactCleanupBatch implements Database.Batchable<sObject>, Database.RaisesPlatformEvents {
  Confidential_WD_Candidate_Fields__mdt batchSetting = [
    SELECT Custom_Soql__c, List_of_Fields__c, batch_size__c
    FROM Confidential_WD_Candidate_Fields__mdt
    WHERE DeveloperName = 'ContactDupeCleanup'
  ];

  global database.queryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(batchSetting.Custom_Soql__c);
  }
  global void execute(Database.BatchableContext BC, list<Contact> records) {
    Map<String, Contact> contactWithDuplicateMap = new Map<String, Contact>();
    Contact previousContact;
    for (Contact con : records) {
      if (previousContact == null) {
        previousContact = new Contact();
        previousContact = con;
        continue;
      } else {
        if (previousContact.email == con.email) {
          if (!contactWithDuplicateMap.containsKey(previousContact.email)) {
            contactWithDuplicateMap.put(previousContact.email, previousContact);
          }
        } else {
          previousContact = con;
        }
      }
    }
    if (contactWithDuplicateMap.size() > 0) {
      CEMCI_ContactMerge cntMerge = new CEMCI_ContactMerge(contactWithDuplicateMap.values());
      cntMerge.ProcessRecordsBasedOnDuplicateContacts();
      cntMerge.processMasterRecordWithDuplicates();
    }
  }

  global void finish(Database.BatchableContext BC) {
    List<String> duplicateEmails = new List<String>();
    for (AggregateResult ar : Database.query(batchSetting.List_of_Fields__c))
      duplicateEmails.add(String.valueof(ar.get('email')).tolowercase());

    if (duplicateEmails.size() > 0)
      Database.executeBatch(new CEMCI_DuplicateContactCleanupBatch());
  }
}