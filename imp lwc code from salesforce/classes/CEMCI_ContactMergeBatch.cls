global with sharing class CEMCI_ContactMergeBatch implements Database.Batchable<sObject>, Database.RaisesPlatformEvents {
  private set<Id> contactIds;
  private Map<Contact, List<Contact>> winningRecordWithDuplicateContForBatch;

  global database.queryLocator start(Database.BatchableContext BC) {
    set<Contact> contactsNeedToProcess = winningRecordWithDuplicateContForBatch.keyset();
    string query = 'SELECT Id,Email From Contact WHERE id in :contactsNeedToProcess';
    return Database.getQueryLocator(query);
  }
  public CEMCI_ContactMergeBatch(Map<Contact, List<Contact>> winningRecordWithDuplicateContForBatch) {
    this.winningRecordWithDuplicateContForBatch = winningRecordWithDuplicateContForBatch;
  }

  global void execute(Database.BatchableContext BC, list<Contact> masterContacts) {
    Database.MergeResult[] results = new List<Database.MergeResult>{};
    for (Contact winningContact : winningRecordWithDuplicateContForBatch.keyset()) {
      List<Contact> duplicateContacts = winningRecordWithDuplicateContForBatch.get(winningContact);

      CEMCI_Settings__c cs = CEMCI_Settings__c.getOrgDefaults();
      if (
        Limits.getQueries() <= cs.Auto_Merge_Lead_to_Lead_Limits__c * Limits.getLimitQueries() &&
        Limits.getDMLStatements() <= cs.Auto_Merge_Lead_to_Lead_Limits__c * Limits.getLimitDMLStatements()
      ) {
        if (!winningContact.URM__c) {
          for (Contact cc : duplicateContacts) {
            if (cc.URM__c)
              winningContact.URM__c = true;
          }
        }

        if (!winningContact.URG__c) {
          for (Contact cc : duplicateContacts) {
            if (cc.URG__c)
              winningContact.URG__c = true;
          }
        }
        results.addall(CEMCI_LeadsHelper.mergeContactToContact(winningContact, duplicateContacts));
      }
    }
    Set<Id> mergeContactIds = new Set<Id>();
    if (!results.isEmpty()) {
      for (Database.MergeResult res : results) {
        if (res.isSuccess()) {
          mergeContactIds.add(res.getId());
        } else {
          for (Database.Error err : res.getErrors()) {
            PF_Logger.log(
              'CEMCI',
              'ERROR',
              err.getMessage(),
              ' Error during auto-merge Contact to Contact ',
              ' UserId ' + UserInfo.getUserId(),
              'CEMCI_Contacts'
            );
          }
        }
      }
    }
    if (!PF_Logger.logs.isEmpty()) {
      PF_Logger.createLogs(PF_Logger.logs);
    }
    if (!mergeContactIds.isEmpty()) {
      WDR_Util.updateApplicationFields(mergeContactIds);
    }
  }

  global void finish(Database.BatchableContext BC) {
  }
}