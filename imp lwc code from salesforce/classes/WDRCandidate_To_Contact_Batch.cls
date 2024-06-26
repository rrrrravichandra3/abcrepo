global with sharing class WDRCandidate_To_Contact_Batch implements Database.Batchable<sObject>, Database.RaisesPlatformEvents, Schedulable {
  private Confidential_WD_Candidate_Fields__mdt batchSetting = [
    SELECT List_of_Fields__c, Candidate_Type__c
    FROM Confidential_WD_Candidate_Fields__mdt
    WHERE DeveloperName = 'WDRCandidate_to_Contact'
  ];

  global Database.QueryLocator start(Database.BatchableContext BC) {
    Map<Id, AsyncApexJob> inProgressBatches = WDR_Util.checkForInProgressBatches(bc.getJobId());

    String query =
      'Select ' +
      batchSetting.List_of_Fields__c +
      ' from WDR_Candidate__c where Ready_to_Process__c = true AND Candidate_Type__c = \'' +
      batchSetting.Candidate_Type__c +
      '\' order by Confidential__c,Current_Company__c, Last_School_Attended__c,Email__c';
    if (inProgressBatches.size() > 0)
      query += ' Limit 0';

    return Database.getQueryLocator(query);
  }

  global void execute(SchedulableContext SC) {
    Integer batchSize = WDR_Util.getBatchSizeforWDRBatch('WDRCandidate_to_Contact');
    Database.executeBatch(this, batchSize);
  }

  global void execute(Database.BatchableContext BC, List<sObject> WDCandidates) {
    if (batchSetting != null) {
      WDRCandidate_To_Contact_BatchHandler handleRecord = new WDRCandidate_To_Contact_BatchHandler();
      handleRecord.candidateType = batchSetting.Candidate_Type__c;
      handleRecord.processBatchRecords(WDCandidates);
    }
  }

  global void finish(Database.BatchableContext BC) {
    List<User> updateUserList = [
      SELECT Id
      FROM User
      WHERE ProfileId = :CEMCI_Settings__c.getInstance().Account_Owner_Profile_Id__c AND UserRoleId = NULL
    ];
    if (updateUserList.size() > 0)
      System.enqueueJob(new CEMCI_AssignRoleToAccountOwner());

    if (WDR_Util.checkForInProgressBatches(bc.getJobId()).size() == 0) {
      Integer batchSize = WDR_Util.getBatchSizeforWDRBatch('CEMCI_ConvertLeadstoContacts');
      Database.executeBatch(new CEMCI_ConvertLeadstoContacts(), batchSize);
    }
  }
}