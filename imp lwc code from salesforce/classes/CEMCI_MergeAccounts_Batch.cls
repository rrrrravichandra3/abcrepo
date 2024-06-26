global with sharing class CEMCI_MergeAccounts_Batch implements Database.Batchable<sObject>, Database.RaisesPlatformEvents {
  static final Id accountRTId = [
    SELECT Id
    FROM RecordType
    WHERE sobjecttype = 'Account' AND developername = 'WDR_Candidate'
  ]
  .Id;
  static final Id accountOwnerProfileId = CEMCI_Settings__c.getInstance() != null
    ? CEMCI_Settings__c.getInstance().Account_Owner_Profile_Id__c
    : null;

  global Database.QueryLocator start(Database.BatchableContext BC) {
    String query =
      'Select Id, Name,WD_Account_WDI__c from Account where RecordtypeId = \'' +
      accountRTId +
      '\' and Owner.ProfileId = \'' +
      accountOwnerProfileId +
      '\' Order by Name,WD_Account_WDI__c NULLS LAST,CreatedDate ASC';
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<sObject> Accounts) {
    CEMCI_MergeAccounts runLogic = new CEMCI_MergeAccounts();
    runLogic.mergeAccounts(Accounts);
  }

  global void finish(Database.BatchableContext BC) {
  }
}