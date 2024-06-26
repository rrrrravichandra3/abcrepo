global with sharing class WDRCandidate_To_Lead_Batch implements Database.Batchable<sObject>, Database.RaisesPlatformEvents, Schedulable {
  private Confidential_WD_Candidate_Fields__mdt batchSetting = [
    SELECT List_of_Fields__c, Candidate_Type__c
    FROM Confidential_WD_Candidate_Fields__mdt
    WHERE DeveloperName = 'WDRCandidate_to_Lead'
  ];

  global Database.QueryLocator start(Database.BatchableContext BC) {
    Map<Id, AsyncApexJob> inProgressBatches = WDR_Util.checkForInProgressBatches(bc.getJobId());
    String query =
      'Select ' +
      batchSetting.List_of_Fields__c +
      ' from WDR_Candidate__c where Last_Name__c != null AND Is_Lead_Created_for_this_WD_Candidate__c = false' +
      ' AND Candidate_Type__c = \'' +
      batchSetting.Candidate_Type__c +
      '\'  Order By Email__c,lastModifiedDate  NULLS LAST';
    if (inProgressBatches.size() > 0)
      query += ' Limit 0';

    return Database.getQueryLocator(query);
  }

  global void execute(SchedulableContext SC) {
    Integer batchSize = WDR_Util.getBatchSizeforWDRBatch('WDRCandidate_to_Lead');
    Database.executeBatch(this, batchSize);
  }

  global void execute(Database.BatchableContext BC, List<sObject> WDCandidates) {
    if (batchSetting != null) {
      WDRCandidate_To_Lead_BatchHandler handleRecord = new WDRCandidate_To_Lead_BatchHandler();
      handleRecord.candidateType = batchSetting.Candidate_Type__c;
      handleRecord.processBatchRecords(WDCandidates);
    }
  }

  global void finish(Database.BatchableContext BC) {
    if (WDR_Util.checkForInProgressBatches(bc.getJobId()).size() == 0) {
      Integer batchSize = WDR_Util.getBatchSizeforWDRBatch('CEMCI_DeDupeBatch');
      Database.executeBatch(new CEMCI_DeDupeBatch(), batchSize);
    }
  }
}