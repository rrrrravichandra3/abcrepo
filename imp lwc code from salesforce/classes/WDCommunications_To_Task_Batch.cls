global with sharing class WDCommunications_To_Task_Batch implements Database.Batchable<sObject>, Database.RaisesPlatformEvents, Schedulable {
  private Confidential_WD_Candidate_Fields__mdt batchSetting = [
    SELECT List_of_Fields__c, Custom_Soql__c
    FROM Confidential_WD_Candidate_Fields__mdt
    WHERE DeveloperName = 'WDComm_to_Task'
  ];

  global database.queryLocator start(Database.BatchableContext BC) {
    Map<Id, AsyncApexJob> inProgressBatches = WDR_Util.checkForInProgressBatches(bc.getJobId());

    String query = batchSetting.Custom_Soql__c;
    if (inProgressBatches.size() > 0)
      query += ' Limit 0';

    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, list<WD_Communication__c> scope) {
    WDCommunications_To_Task_BatchHandler handleRecord = new WDCommunications_To_Task_BatchHandler();
    handleRecord.processRecords(scope, batchSetting);
  }

  global void finish(Database.BatchableContext BC) {
  }

  global void execute(SchedulableContext SC) {
    Integer batchSize = WDR_Util.getBatchSizeforWDRBatch('WDComm_to_Task');
    Database.executeBatch(this, batchSize);
  }
}