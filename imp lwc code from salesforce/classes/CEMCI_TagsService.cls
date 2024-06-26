/**
 * @description       :
 * @author            : Urvish Shah (ushah)
 * @group             :
 * @last modified on  : 08-18-2022
 * @last modified by  : Urvish Shah (ushah)
 **/
public with sharing class CEMCI_TagsService {
  public static void updateTagsOnMember(Map<Id, List<string>> memberIdToNewTagsMap, String objectName) {
    List<sObject> membersToUpdateList = new List<sObject>();
    Map<Id, String> memberIdToExistingTagsMap = CEMCI_TagsService.getExistingTagsMap(
      memberIdToNewTagsMap.keySet(),
      objectName
    );
    for (Id recId : memberIdToNewTagsMap.keySet()) {
      String newTagsAsString = '';
      for (String tagName : memberIdToNewTagsMap.get(recId)) {
        if (newTagsAsString == '')
          newTagsAsString += tagName;
        else
          newTagsAsString += ',' + tagName;
      }

      if (memberIdToExistingTagsMap.get(recId) == null || memberIdToExistingTagsMap.get(recId) == '') {
        sObject sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject();
        sObj.put('tags__c', newTagsAsString);
        sObj.put('Id', recId);
        membersToUpdateList.add(sObj);
      } else {
        sObject sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject();
        sObj.put('tags__c', memberIdToExistingTagsMap.get(recId) + ',' + newTagsAsString);
        sObj.put('Id', recId);
        membersToUpdateList.add(sObj);
      }
    }
    update membersToUpdateList;
  }

  public static void deleteTagsOnMember(Map<Id, List<string>> memberIdToNewTagsMap, String objectName) {
    List<sObject> membersToUpdateList = new List<sObject>();
    Map<Id, String> memberIdToExistingTagsMap = CEMCI_TagsService.getExistingTagsMap(
      memberIdToNewTagsMap.keySet(),
      objectName
    );
    for (Id recId : memberIdToNewTagsMap.keySet()) {
      String updatedTags = memberIdToExistingTagsMap.get(recId);
      Set<String> duplicateTags = CEMCI_TagsService.findDuplicateTags(updatedTags.split(','));

      for (String tag : memberIdToNewTagsMap.get(recId)) {
        if (updatedTags.contains(',' + tag)) {
          updatedTags = updatedTags.remove(',' + tag);
        }
        if (updatedTags.contains(tag + ',')) {
          updatedTags = updatedTags.remove(tag + ',');
        }
        if (updatedTags.contains(tag)) {
          updatedTags = updatedTags.remove(tag);
        }

        if (duplicateTags.contains(tag)) {
          if (updatedTags == '') {
            updatedTags = tag;
          } else {
            updatedTags += ',' + tag;
          }
        }
      }

      sObject sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject();
      sObj.put('tags__c', updatedTags);
      sObj.put('Id', recId);
      membersToUpdateList.add(sObj);
    }
    update membersToUpdateList;
  }

  public static Set<String> findDuplicateTags(List<String> existingTags) {
    Set<String> duplicateTags = new Set<String>();
    Set<String> encounteredTags = new Set<String>();
    for (String tag : existingTags) {
      if (encounteredTags.contains(tag)) {
        duplicateTags.add(tag);
      } else {
        encounteredTags.add(tag);
      }
    }
    return duplicateTags;
  }

  public static Map<Id, List<string>> createMemberIdToNewTagsMap(
    List<CEMCI_TagAssignment__c> tagAssignmentsList,
    String objectType
  ) {
    Map<Id, List<string>> memberIdToNewTagsMap = new Map<Id, List<String>>();
    Map<Id, List<string>> contactIdToNewTagsMap = new Map<Id, List<String>>();
    Map<Id, List<string>> leadIdToNewTagsMap = new Map<Id, List<String>>();
    Map<Id, List<string>> talentPipeIdToNewTagsMap = new Map<Id, List<String>>();

    for (CEMCI_TagAssignment__c ta : tagAssignmentsList) {
      if (ta.contact__c != null) {
        if (!contactIdToNewTagsMap.containsKey(ta.contact__c)) {
          contactIdToNewTagsMap.put(ta.contact__c, new List<String>{});
        }
        contactIdToNewTagsMap.get(ta.contact__c).add(ta.TagName__c);
      }
      if (ta.lead__c != null) {
        if (!leadIdToNewTagsMap.containsKey(ta.lead__c)) {
          leadIdToNewTagsMap.put(ta.lead__c, new List<String>{});
        }
        leadIdToNewTagsMap.get(ta.lead__c).add(ta.TagName__c);
      }
      if (ta.Talent_Pipeline__c != null) {
        if (!talentPipeIdToNewTagsMap.containsKey(ta.Talent_Pipeline__c)) {
          talentPipeIdToNewTagsMap.put(ta.Talent_Pipeline__c, new List<String>{});
        }
        talentPipeIdToNewTagsMap.get(ta.Talent_Pipeline__c).add(ta.TagName__c);
      }
    }
    if (objectType == 'Contact') {
      memberIdToNewTagsMap = contactIdToNewTagsMap;
    } else if (objectType == 'Lead') {
      memberIdToNewTagsMap = leadIdToNewTagsMap;
    } else if (objectType == 'Talent_Pipeline__c') {
      memberIdToNewTagsMap = talentPipeIdToNewTagsMap;
    }

    return memberIdToNewTagsMap;
  }

  private static Map<Id, String> getExistingTagsMap(Set<Id> recIds, String objectName) {
    Map<Id, String> memberIdToExistingTagsMap = new Map<Id, String>();
    String query = 'SELECT tags__c FROM ' + objectName + ' WHERE Id IN: recIds';
    for (SObject ob : Database.query(query)) {
      memberIdToExistingTagsMap.put(ob.Id, (String) ob.get('tags__c'));
    }
    return memberIdToExistingTagsMap;
  }

  public static List<CEMCI_TagAssignment__c> getTagAssignemts(List<String> recordIds) {
    return [
      SELECT tagName__c, topic__c, contact__c, lead__c, Talent_Pipeline__c, campaign__c
      FROM CEMCI_TagAssignment__c
      WHERE Id IN :recordIds
      ALL ROWS
    ];
  }

  public static Map<Id, Set<String>> getTagAssignmentsMap(List<Id> listRecordIds, String objectAPIName) {
    Map<Id, Set<String>> mapSObjectToTagAssignments = new Map<Id, Set<String>>();

    if (!objectAPIName.contains('__c'))
      objectAPIName = String.escapeSingleQuotes(objectAPIName + '__c');

    String query =
      'Select Topic__c, Lead__c, Contact__c,Talent_Pipeline__c, Id FROM CEMCI_TagAssignment__c WHERE ' +
      objectAPIName +
      ' IN: listRecordIds';
    for (CEMCI_TagAssignment__c ta : Database.query(query)) {
      if (objectAPIName == 'Lead__c') {
        if (!mapSObjectToTagAssignments.containsKey(ta.Lead__c)) {
          mapSObjectToTagAssignments.put(ta.Lead__c, new Set<String>{});
        }
        mapSObjectToTagAssignments.get(ta.Lead__c).add(ta.Topic__c);
      } else if (objectAPIName == 'Contact__c') {
        if (!mapSObjectToTagAssignments.containsKey(ta.Contact__c)) {
          mapSObjectToTagAssignments.put(ta.Contact__c, new Set<String>{});
        }
        mapSObjectToTagAssignments.get(ta.Contact__c).add(ta.Topic__c);
      } else if (objectAPIName == 'Talent_Pipeline__c') {
        if (!mapSObjectToTagAssignments.containsKey(ta.Talent_Pipeline__c)) {
          mapSObjectToTagAssignments.put(ta.Talent_Pipeline__c, new Set<String>{});
        }
        mapSObjectToTagAssignments.get(ta.Talent_Pipeline__c).add(ta.Topic__c);
      }
    }
    return mapSObjectToTagAssignments;
  }
}