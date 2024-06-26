public without sharing class CEMCI_Sync_Leads_with_Workday {
  public static void wdCandidateToLeadUpdate(
    List<WDR_Candidate__c> newWDCandidates,
    List<Field_Mapping__mdt> fieldMappingList
  ) {
    final String candidateType = System.Label.WD_Candidate_Type_Prospect_Label;

    Map<Id, Lead> wdcIdToLeadMap = new Map<Id, Lead>();
    List<Lead> leadsToUpdate = new List<Lead>();
    Map<Id, WDR_Candidate__c> mapOfCandIdCand = new Map<Id, WDR_Candidate__c>();
    List<String> cands = new List<String>();
    Set<Id> cIds = new Set<Id>();
    Map<Id, Id> matchingLeadsToWDCandidate = new Map<Id, Id>();
    Set<Id> leadIds = new Set<Id>();

    if (!newWDCandidates.isEmpty() && newWDCandidates != null) {
      for (WDR_Candidate__c wdc : newWDCandidates) {
        if (wdc.Is_Lead_Created_for_this_WD_Candidate__c == true && wdc.Candidate_Type__c == candidateType) {
          mapOfCandIdCand.put(wdc.id, wdc);
          cands.add('%' + wdc.id + '%');
          if (wdc.Matching_Lead_Id__c != null) {
            matchingLeadsToWDCandidate.put(wdc.Matching_Lead_Id__c, wdc.Id);
            leadIds.add(wdc.Matching_Lead_Id__c);
          }
        }
      }

      String query = 'Select Id,Duplicate_Candidates__c';
      for (Field_Mapping__mdt mapping : [
        SELECT To_Field__c, Is_Active__c
        FROM Field_Mapping__mdt
        WHERE To_Object__c = :Schema.SObjectType.Lead.getName() AND Mapping_Category__c = 'CEMCI'
      ]) {
        if (mapping.Is_Active__c == true) {
          query += ' ,' + mapping.To_Field__c;
        }
      }
      cIds = mapOfCandIdCand.keyset();
      if ((!cIds.isEmpty() && cIds != null) || (!cands.isEmpty() && cands != null)) {
        query =
          query + ' from Lead where WDR_Prospect__c IN :cIds or Duplicate_Candidates__c like :cands or Id IN :leadIds';

        for (Lead ld : Database.query(query)) {
          if (mapOfCandIdCand.containsKey(ld.WDR_Prospect__c)) {
            wdcIdToLeadMap.put(ld.WDR_Prospect__c, ld);
          } else {
            if (ld.Duplicate_Candidates__c != null) {
              for (String str : ld.Duplicate_Candidates__c.split(':')) {
                Id candId = Id.valueOf(str);
                if (mapOfCandIdCand.containsKey(candId)) {
                  wdcIdToLeadMap.put(candId, ld);
                  continue;
                }
              }
            } else if (matchingLeadsToWDCandidate.containsKey(ld.Id)) {
              wdcIdToLeadMap.put(matchingLeadsToWDCandidate.get(ld.Id), ld);
            }
          }
        }

        if (!wdcIdToLeadMap.isEmpty() && !mapOfCandIdCand.isEmpty()) {
          for (WDR_Candidate__c wdCand : mapOfCandIdCand.values()) {
            WDR_Candidate__c candidate = (WDR_Candidate__c) wdCand;
            for (Field_Mapping__mdt mapping : fieldMappingList) {
              if (mapping.Is_Active__c == true) {
                Object data = candidate.get(mapping.From_Field__c);
                if (
                  (wdcIdToLeadMap.get(candidate.Id).get(mapping.To_Field__c) == null ||
                  wdcIdToLeadMap.get(candidate.Id).get(mapping.To_Field__c) == false) && data != null
                ) {
                  if (mapping.To_Length_Limit__c != null && data != null) {
                    String dataValue = String.valueOf(data);
                    dataValue = dataValue.length() > mapping.To_Length_Limit__c
                      ? dataValue.left(Integer.valueOf(mapping.To_Length_Limit__c))
                      : dataValue;
                    data = dataValue;
                  }
                  wdcIdToLeadMap.get(candidate.Id).put(mapping.To_Field__c, data);
                }
              }
            }
            if (
              wdcIdToLeadMap.get(candidate.Id).Company == System.Label.CEMCI_Lead_Company_Not_Provided_Label &&
              candidate.Current_Company__c != null
            )
              wdcIdToLeadMap.get(candidate.Id).Company = candidate.Current_Company__c;

            leadsToUpdate.add(wdcIdToLeadMap.get(candidate.Id));
          }
        }

        if (leadsToUpdate.size() > 0) {
          Database.SaveResult[] srList = Database.update(leadsToUpdate, false);
          for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
              for (Database.Error err : sr.getErrors()) {
                PF_Logger.log('CEMCI', 'WD Candidate to Lead Update', err.getMessage(), '' + err.getFields(), '', '');
              }
            }
          }
          if (PF_Logger.logs.size() > 0)
            PF_Logger.createLogs(PF_Logger.logs);
        }
      }
    }
  }
}