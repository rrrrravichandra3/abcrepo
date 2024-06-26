public with sharing class CEMCI_WD_Candidates {
  public static List<WDR_Candidate__c> newWDCandidates;
  public static List<WDR_Candidate__c> oldWDCandidates;
  public static Map<Id, SObject> oldWDCandidatesMap;
  public static Map<Id, SObject> newWDCandidateMap;

  public static void updateMailingCountry() {
    Map<String, String> mapLabelValue = new Map<String, String>();
    Schema.DescribeFieldResult fieldResult = WDR_Candidate__c.mailing_Country_Global__c.getDescribe();
    List<Schema.PicklistEntry> countryValues = fieldResult.getPicklistValues();
    Map<Id, String> candtToMailingCntryOld = new Map<Id, String>();
    List<PF_Debug_Log__c> pfDebugLogs = new List<PF_Debug_Log__c>();

    if (Trigger.isUpdate && oldWDCandidates != null) {
      for (WDR_Candidate__c wdc : oldWDCandidates) {
        candtToMailingCntryOld.put(wdc.Id, wdc.Mailing_Country__c);
      }
    }

    for (Schema.PicklistEntry cv : countryValues) {
      mapLabelValue.put(cv.getLabel().toLowerCase(), cv.getValue());
    }

    for (WDR_Candidate__c wdc : newWDCandidates) {
      if (
        wdc.mailing_Country__c != null &&
        wdc.mailing_Country__c != candtToMailingCntryOld.get(wdc.Id) &&
        mapLabelValue.keyset().contains(wdc.mailing_Country__c.toLowerCase())
      ) {
        wdc.mailing_Country_Global__c = mapLabelValue.get(wdc.mailing_Country__c.toLowerCase());
      } else if (
        wdc.mailing_Country__c != null &&
        wdc.mailing_Country__c != candtToMailingCntryOld.get(wdc.Id) &&
        mapLabelValue.values().contains(wdc.Mailing_Country__c)
      ) {
        wdc.mailing_Country_Global__c = wdc.mailing_Country__c;
      } else if (wdc.mailing_Country__c != null && wdc.Mailing_Country__c != candtToMailingCntryOld.get(wdc.Id)) {
        //If there is no corresponding value based on the change, then null to make sure there isn't a mismatch of data.
        wdc.Mailing_Country_Global__c = null;
        PF_Logger.log(
          'CEMCI',
          'ERROR',
          'Invalid Country value for Mailing_Country__c: ' +
          wdc.mailing_Country__c +
          ' for record ' +
          wdc.Id +
          ' when attempting to update Mailing_Country_Global__c',
          'Bad value for restricted pick-list',
          'Error during updating Mailing Country picklist for WD Candidate.' +
          ' User Id: ' +
          UserInfo.getUserId(),
          'CEMCI_WD_Candidates'
        );
        pfDebugLogs.addall(PF_Logger.logs);
      }
    }
    if (!pfDebugLogs.isEmpty()) {
      PF_Logger.createLogs(pfDebugLogs);
    }
  }

  public static void wdCandidateToLeadUpdate() {
    List<WDR_Candidate__c> candidatesForUpdatingLeads = new List<WDR_Candidate__c>();
    List<Field_Mapping__mdt> fieldMappingList;
    fieldMappingList = [
      SELECT
        From_Field__c,
        From_Object__c,
        To_Field__c,
        To_Object__c,
        Is_Active__c,
        Mapping_Category__c,
        To_Length_Limit__c
      FROM Field_Mapping__mdt
      WHERE
        From_Object__c = :Schema.SObjectType.WDR_Candidate__c.getName()
        AND To_Object__c = :Schema.SObjectType.Lead.getName()
        AND Mapping_Category__c = 'CEMCI'
    ];
    candidatesForUpdatingLeads = isValidFortheLeadupdate(fieldMappingList);
    if (candidatesForUpdatingLeads.size() > 0) {
      CEMCI_Sync_Leads_with_Workday.wdCandidateToLeadUpdate(candidatesForUpdatingLeads, fieldMappingList);
    }
  }

  public static List<WDR_Candidate__c> isValidFortheLeadupdate(List<Field_Mapping__mdt> fieldMappingList) {
    List<WDR_Candidate__c> candidatesForUpdatingLeads = new List<WDR_Candidate__c>();
    set<Id> candidateIds = new Set<Id>();
    WDR_Candidate__c oldWDcandidate;
    WDR_Candidate__c newWDcandidate;
    for (Id wdcandidateId : newWDCandidateMap.keySet()) {
      oldWDcandidate = (WDR_Candidate__c) oldWDCandidatesMap.get(wdcandidateId);
      newWDcandidate = (WDR_Candidate__c) newWDCandidateMap.get(wdcandidateId);
      for (Field_Mapping__mdt mapping : fieldMappingList) {
        if (mapping.Is_Active__c == true) {
          if (
            oldWDCandidatesMap != null &&
            (oldWDCandidatesMap.get(wdcandidateId).get(mapping.From_Field__c) !=
            newWDCandidateMap.get(wdcandidateId).get(mapping.From_Field__c))
          ) {
            candidateIds.add(wdcandidateId);
          }
        }
      }
    }
    if (candidateIds.size() > 0) {
      for (Id candidateId : candidateIds) {
        candidatesForUpdatingLeads.add((WDR_Candidate__c) newWDCandidateMap.get(candidateId));
      }
    }
    return candidatesForUpdatingLeads;
  }

  public static void updateSourceofTruthFields() {
    List<Field_Mapping__mdt> fieldMappingList = [
      SELECT From_Field__c, To_Field__c, Is_Active__c, Mapping_Category__c
      FROM Field_Mapping__mdt
      WHERE
        From_Object__c = :Schema.SObjectType.WDR_Candidate__c.getName()
        AND To_Object__c = :Schema.SObjectType.WDR_Candidate__c.getName()
        AND Mapping_Category__c = 'CEMCI_Candidate_Source_of_Truth'
    ];
    for (WDR_Candidate__c wdCand : newWDCandidates) {
      for (Field_Mapping__mdt mapping : fieldMappingList) {
        if (mapping.Is_Active__c == true) {
          Object oldData = oldWDCandidatesMap.get(wdCand.Id).get(mapping.From_Field__c);
          Object newData = newWDCandidateMap.get(wdCand.Id).get(mapping.From_Field__c);
          if (newData != oldData) {
            wdCand.put(mapping.To_Field__c, newData);
          }
        }
      }
    }
  }

  public static void setCandidateTypeField() {
    Set<Id> candIdSet = new Set<Id>();
    Map<String, Integer> candidatetoJobAppMap = new Map<String, Integer>();

    for (WDR_Candidate__c cand : newWDCandidates) {
      if (
        cand.Candidate_Type__c == 'Candidate' ||
        (oldWDCandidatesMap.get(cand.Id).get('Candidate_Type__c') != cand.Candidate_Type__c &&
        cand.Candidate_Type__c == 'Prospect')
      )
        candIdSet.add(cand.Id);
    }
    if (candIdSet != null) {
      for (AggregateResult ar : [
        SELECT Candidate__c, count(Id)
        FROM WDR_Application__c
        WHERE Candidate__c IN :candIdSet
        GROUP BY Candidate__c
      ]) {
        String key = String.valueOf(ar.get('Candidate__c'));
        Integer value = Integer.valueOf(ar.get('expr0'));
        if (!candidatetoJobAppMap.containsKey(key))
          candidatetoJobAppMap.put(key, value);
      }

      for (WDR_Candidate__c cand : newWDCandidates) {
        if (candidatetoJobAppMap.containsKey(cand.Id)) {
          cand.No_of_Job_Applications__c = candidatetoJobAppMap.get(cand.Id);
          if (cand.Candidate_Type__c == 'Prospect') {
            cand.Candidate_Type__c = 'Candidate';
            cand.Ready_to_Process__c = true;
          }
        }
      }
    }
  }
}