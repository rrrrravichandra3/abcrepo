/**
 * @description       :
 * @author            : Urvish Shah (ushah)
 * @group             :
 * @last modified on  : 07-12-2022
 * @last modified by  : Urvish Shah (ushah)
 **/
public with sharing class CEMCI_Add_to_Campaign_TriggerHandler {
  public static void processEvents(List<CEMCI_Add_to_Campaign__e> events) {
    Map<Id, Id> mapTopicToCampaign = new Map<Id, Id>();
    Set<Id> topicIds = new Set<Id>();
    for (CEMCI_Add_to_Campaign__e e : events) {
      topicIds.add(e.topicId__c);
    }
    List<CEMCI_TagAssignment__c> campaignTagAssignments = [
      SELECT id, Topic__c, Campaign__c
      FROM CEMCI_TagAssignment__c
      WHERE Topic__c IN :topicIds AND Campaign__c != NULL
    ];
    for (CEMCI_TagAssignment__c ta : campaignTagAssignments) {
      mapTopicToCampaign.put(ta.Topic__c, ta.Campaign__c);
    }

    List<CampaignMember> campaignMembersToInsert = new List<CampaignMember>();

    for (CEMCI_Add_to_Campaign__e e : events) {
      //No need to create campaign member instance if tag is being created for campaign object type. It causes error otherwise as "ContactId" or "LeadId" will be blank
      if (mapTopicToCampaign.containsKey(e.topicId__c) && e.sObjectTypeString__c != 'Campaign') {
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = mapTopicToCampaign.get(e.topicId__c);
        cm.Status = 'Responded';
        switch on e.sObjectTypeString__c {
          when 'Contact' {
            cm.ContactId = e.recordId__c;
          }
          when 'Lead' {
            cm.LeadId = e.recordId__c;
          }
        }
        campaignMembersToInsert.add(cm);
      }
    }
    Database.SaveResult[] saveResultList = Database.insert(campaignMembersToInsert, false);
  }
}