global with sharing class CEMCI_ConvertLeadstoContacts implements Database.Batchable<sObject>, Database.RaisesPlatformEvents, Schedulable {
  public Map<String, WDR_Candidate__c> allCandidates = new Map<String, WDR_Candidate__c>();
  public List<WDR_Candidate__c> candsWithoutEmail = new List<WDR_Candidate__c>();

  global Database.QueryLocator start(Database.BatchableContext BC) {
    Map<Id, AsyncApexJob> inProgressBatches = WDR_Util.checkForInProgressBatches(bc.getJobId());

    String query = 'Select Id,Awaiting_Lead_Conversion__c,Candidate_Contact__c, Candidate_Contact__r.Email,Candidate_Contact__r.accountId,Candidate_Contact__r.Confidential__c,Email__c, Candidate_Contact__r.LinkedIn_Substring__c from WDR_Candidate__c where Awaiting_Lead_Conversion__c = true';
    if (inProgressBatches.size() > 0)
      query += ' Limit 0';

    return Database.getQueryLocator(query);
  }
  global void execute(SchedulableContext SC) {
    Integer batchSize = WDR_Util.getBatchSizeforWDRBatch('CEMCI_ConvertLeadstoContacts');
    Database.executeBatch(this, batchSize);
  }

  global void execute(Database.BatchableContext BC, List<WDR_Candidate__c> candidateList) {
    Map<String, Contact> confidentialContactMap = new Map<String, Contact>();
    Map<String, Contact> nonConfidentialContactMap = new Map<String, Contact>();
    Map<String, WDR_Candidate__c> confCandidateMap = new Map<String, WDR_Candidate__c>();
    Map<String, WDR_Candidate__c> nonConfCandidateMap = new Map<String, WDR_Candidate__c>();
    Map<String, Contact> existingContactMap = new Map<String, Contact>();
    List<String> setOfEmails = new List<String>();
    List<CEMCI_LinkedInMerge__e> linkedInMerges = new List<CEMCI_LinkedInMerge__e>();

    if (candidateList.size() > 0) {
      for (WDR_Candidate__c cand : candidateList) {
        if (cand.Email__c != null && !setOfEmails.contains(cand.Email__c)) {
          setOfEmails.add(cand.Email__c);
          allCandidates.put(cand.Email__c, cand);
        }
      }
      for (Contact con : [SELECT Id, Email, AccountId, Confidential__c FROM Contact WHERE Email IN :setOfEmails])
        existingContactMap.put(con.Email, con);

      for (WDR_Candidate__c cand : candidateList) {
        if (cand.Candidate_Contact__c != null) {
          if (cand.Candidate_Contact__r.LinkedIn_Substring__c != null) {
            linkedInMerges.add(
              new CEMCI_LinkedInMerge__e(
                LinkedIn_Substring__c = String.valueOf(cand.Candidate_Contact__r.LinkedIn_Substring__c)
              )
            );
          }
          if (cand.Candidate_Contact__r.Confidential__c) {
            confidentialContactMap.put(
              cand.Candidate_Contact__r.Email.toLowerCase(),
              new Contact(
                Id = cand.Candidate_Contact__c,
                Email = cand.Candidate_Contact__r.Email,
                AccountId = cand.Candidate_Contact__r.accountId,
                Confidential__c = cand.Candidate_Contact__r.Confidential__c
              )
            );
            confCandidateMap.put(cand.Candidate_Contact__r.Email.toLowerCase(), cand);
          } else {
            nonConfidentialContactMap.put(
              cand.Candidate_Contact__r.Email.toLowerCase(),
              new Contact(
                Id = cand.Candidate_Contact__c,
                AccountId = cand.Candidate_Contact__r.accountId,
                Confidential__c = cand.Candidate_Contact__r.Confidential__c
              )
            );
            nonConfCandidateMap.put(cand.Candidate_Contact__r.Email.toLowerCase(), cand);
          }
        } else if (cand.Email__c != null && existingContactMap.containsKey(cand.Email__c)) {
          Contact existingContact = existingContactMap.get(cand.Email__c);
          if (existingContact.Confidential__c) {
            confidentialContactMap.put(cand.Email__c.toLowerCase(), existingContact);
            confCandidateMap.put(cand.Email__c.toLowerCase(), cand);
          } else {
            nonConfidentialContactMap.put(cand.Email__c.toLowerCase(), existingContact);
            nonConfCandidateMap.put(cand.Email__c.toLowerCase(), cand);
          }
        } else if (cand.Email__c == null) {
          cand.Awaiting_Lead_Conversion__c = false;
          candsWithoutEmail.add(cand);
        }
      }
    }
    if (confidentialContactMap.size() > 0)
      convertLeads(confidentialContactMap, true, confCandidateMap);

    if (nonConfidentialContactMap.size() > 0)
      convertLeads(nonConfidentialContactMap, false, nonConfCandidateMap);

    if (!linkedInMerges.isEmpty()) {
      List<Database.SaveResult> eventResults = EventBus.publish(linkedInMerges);
    }
    updateWDRCandidates();
  }

  private void convertLeads(
    Map<String, Contact> ContactEmailtoIdMap,
    Boolean confidential,
    Map<String, WDR_Candidate__c> candidateMap
  ) {
    Map<String, WDR_Candidate__c> emailToCandidateMap = new Map<String, WDR_Candidate__c>();
    Map<String, Contact> failedRecords = new Map<String, Contact>();

    for (String str : candidateMap.keySet())
      emailToCandidateMap.put(
        str,
        new WDR_Candidate__c(Id = candidateMap.get(str).Id, Awaiting_Lead_Conversion__c = false)
      );

    WDRCandidate_To_Contact_BatchHandler convertRecords = new WDRCandidate_To_Contact_BatchHandler();
    failedRecords = convertRecords.convertExistingLeads(ContactEmailtoIdMap, confidential);
    for (String email : failedRecords.keySet())
      allCandidates.remove(email);
  }

  private void updateWDRCandidates() {
    List<WDR_Candidate__c> candidatesToUpdate = new List<WDR_Candidate__c>();
    for (WDR_Candidate__c cand : allCandidates.values()) {
      candidatesToUpdate.add(new WDR_Candidate__c(Id = cand.Id, Awaiting_Lead_Conversion__c = false));
    }
    candidatesToUpdate.addAll(candsWithoutEmail);
    Boolean areFieldsAccessible = PF_AccessibilityUtils.checkFLS(
      'WDR_Candidate__c',
      PF_AccessibilityUtils.PermissionType.UPDATEABLE,
      new List<string>{ 'Awaiting_Lead_Conversion__c' }
    );
    if (areFieldsAccessible) {
      Database.SaveResult[] srList = Database.update(candidatesToUpdate, false);
      for (Database.SaveResult sr : srList) {
        if (!sr.isSuccess()) {
          for (Database.Error err : sr.getErrors())
            PF_Logger.log(
              'CEMCI',
              'ERROR',
              err.getMessage(),
              '' + err.getFields(),
              'Error updating candidates post lead conversion',
              'CEMCI ConvertLeadstoContacts'
            );
        }
      }
      if (PF_Logger.logs.size() > 0)
        PF_Logger.createLogs(PF_Logger.logs);
    }
    allCandidates.clear();
  }

  global void finish(Database.BatchableContext BC) {
    if (WDR_Util.checkForInProgressBatches(bc.getJobId()).size() == 0) {
      Integer batchSize = WDR_Util.getBatchSizeforWDRBatch('WDRJobApp');
      Database.executeBatch(new WDJobApp_To_Contact_Batch(), batchSize);
    }
  }
}