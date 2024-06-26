/**
 * Created by kmoseley on 1/25/22.
 * Modified by Venkata Akash Gupta Patti 07/18/22.
 */

public with sharing class CEMCI_Lead_Merge_EventTriggerHandler {
  public static void processEvents(List<CEMCI_Lead_Merge__e> events) {
    Map<Id, Id> mapLoosingLeadtoWinningLeadId = new Map<Id, Id>();
    for (CEMCI_Lead_Merge__e e : events) {
      if (e.Loosing_Lead_Id__c != null && e.Winning_Lead_Id__c != null) {
        mapLoosingLeadtoWinningLeadId.put(e.Loosing_Lead_Id__c, e.Winning_Lead_Id__c);
      }
    }
    if (!mapLoosingLeadtoWinningLeadId.isEmpty()) {
      updateWDCandidateRecords(mapLoosingLeadtoWinningLeadId);
      updateTagAssignmentRecords(mapLoosingLeadtoWinningLeadId);
    }
  }

  public static void updateWDCandidateRecords(Map<Id, Id> mapLoosingLeadtoWinningLeadId) {
    List<WDR_Candidate__c> candidates = [
      SELECT id, Matching_Lead_Id__c
      FROM WDR_Candidate__c
      WHERE Matching_Lead_Id__c IN :mapLoosingLeadtoWinningLeadId.keySet()
    ];
    for (WDR_Candidate__c c : candidates) {
      c.Matching_Lead_Id__c = mapLoosingLeadtoWinningLeadId.get(c.Matching_Lead_Id__c);
    }
    update candidates;
  }

  public static void updateTagAssignmentRecords(Map<Id, Id> mapLoosingLeadtoWinningLeadId) {
    List<CEMCI_TagAssignment__c> newLeadTagAssignments = [
      SELECT Topic__r.Name, Topic__c, Id, Name, Lead__c
      FROM CEMCI_TagAssignment__c
      WHERE Lead__c IN :mapLoosingLeadtoWinningLeadId.values()
    ];

    /** Create a map of winninglead to List of all topics **/
    Map<Id, List<CEMCI_TagAssignment__c>> LeadMapToTags = new Map<Id, List<CEMCI_TagAssignment__c>>();
    for (CEMCI_TagAssignment__c newLeadTagAssignment : newLeadTagAssignments) {
      if (!LeadMapToTags.containsKey(newLeadTagAssignment.Lead__c)) {
        LeadMapToTags.put(newLeadTagAssignment.Lead__c, new List<CEMCI_TagAssignment__c>{});
      }
      LeadMapToTags.get(newLeadTagAssignment.Lead__c).add(newLeadTagAssignment);
    }

    /** identify duplicate tags and delete **/
    List<CEMCI_TagAssignment__c> duplicateTagAssignments = new List<CEMCI_TagAssignment__c>();
    for (Id recordId : LeadMapToTags.keySet()) {
      Set<Id> alreadySeen = new Set<Id>();
      for (CEMCI_TagAssignment__c tag : LeadMapToTags.get(recordId)) {
        if (alreadySeen.contains(tag.Topic__c)) {
          duplicateTagAssignments.add(tag);
        } else {
          alreadySeen.add(tag.Topic__c);
        }
      }
    }
    delete duplicateTagAssignments;
  }
}