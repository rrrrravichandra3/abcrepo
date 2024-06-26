global with sharing class CEMCI_DeDupeBatch implements Database.Batchable<sObject>, Database.RaisesPlatformEvents, Schedulable {
  private Confidential_WD_Candidate_Fields__mdt batchSetting = [
    SELECT Custom_Soql__c
    FROM Confidential_WD_Candidate_Fields__mdt
    WHERE DeveloperName = 'CEMCI_DeDupeBatch'
  ];

  global Database.QueryLocator start(Database.BatchableContext BC) {
    Map<Id, AsyncApexJob> inProgressBatches = WDR_Util.checkForInProgressBatches(bc.getJobId());
    String query = batchSetting.Custom_Soql__c;
    if (inProgressBatches.size() > 0)
      query += ' Limit 0';

    return Database.getQueryLocator(query);
  }

  global void execute(SchedulableContext SC) {
    Integer batchSize = WDR_Util.getBatchSizeforWDRBatch('CEMCI_DeDupeBatch');
    Database.executeBatch(this, batchSize);
  }

  global void execute(Database.BatchableContext BC, List<sObject> leadsToDedupe) {
    List<Lead> updateLeadList = new List<Lead>();
    CEMCI_DuplicateService dupeService = new CEMCI_DuplicateService(leadsToDedupe, 'Email');
    dupeService.findDuplicates();

    CEMCI_CheckGDPRRecursion.setdoNotRunLeadTriggers();
    Database.SaveResult[] updateLeads = Database.update(updateLeadList, false);
  }

  global void finish(Database.BatchableContext BC) {
    if (WDR_Util.checkForInProgressBatches(bc.getJobId()).size() == 0) {
      Integer batchSize = WDR_Util.getBatchSizeforWDRBatch('WDRCandidate_to_Contact');
      Database.executeBatch(new WDRCandidate_To_Contact_Batch(), batchSize);
    }
  }
}