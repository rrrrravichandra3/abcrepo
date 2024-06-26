/**
 * @description       :
 * @author            : Urvish Shah (ushah)
 * @group             :
 * @last modified on  : 07-26-2022
 * @last modified by  : Urvish Shah (ushah)
 **/
public with sharing class CEMCI_TagAssignmentTriggerHandler {
  public static void onAfterInsert(List<CEMCI_TagAssignment__c> newList) {
    Map<Id, List<string>> contactToTagsMap = CEMCI_TagsService.createMemberIdToNewTagsMap(newList, 'Contact');
    Map<Id, List<string>> leadToTagsMap = CEMCI_TagsService.createMemberIdToNewTagsMap(newList, 'Lead');
    Map<Id, List<string>> talentPipeToTagsMap = CEMCI_TagsService.createMemberIdToNewTagsMap(
      newList,
      'Talent_Pipeline__c'
    );

    if (!contactToTagsMap.isEmpty()) {
      CEMCI_TagsService.updateTagsOnMember(contactToTagsMap, 'Contact');
    }
    if (!leadToTagsMap.isEmpty()) {
      CEMCI_TagsService.updateTagsOnMember(leadToTagsMap, 'Lead');
    }
    if (!talentPipeToTagsMap.isEmpty()) {
      CEMCI_TagsService.updateTagsOnMember(talentPipeToTagsMap, 'Talent_Pipeline__c');
    }
  }

  public static void onAfterDelete(List<CEMCI_TagAssignment__c> oldList) {
    Map<Id, List<string>> contactToTagsMap = CEMCI_TagsService.createMemberIdToNewTagsMap(oldList, 'Contact');
    Map<Id, List<string>> leadToTagsMap = CEMCI_TagsService.createMemberIdToNewTagsMap(oldList, 'Lead');
    Map<Id, List<string>> talentPipeToTagsMap = CEMCI_TagsService.createMemberIdToNewTagsMap(
      oldList,
      'Talent_Pipeline__c'
    );

    if (!contactToTagsMap.isEmpty()) {
      CEMCI_TagsService.deleteTagsOnMember(contactToTagsMap, 'Contact');
    }
    if (!leadToTagsMap.isEmpty()) {
      CEMCI_TagsService.deleteTagsOnMember(leadToTagsMap, 'Lead');
    }
    if (!talentPipeToTagsMap.isEmpty()) {
      CEMCI_TagsService.deleteTagsOnMember(talentPipeToTagsMap, 'Talent_Pipeline__c');
    }
  }
}