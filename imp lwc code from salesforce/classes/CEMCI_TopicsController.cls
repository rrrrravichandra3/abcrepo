/**
 * @description       :
 * @author            : Urvish Shah (ushah)
 * @group             :
 * @last modified on  : 01-23-2023
 * @last modified by  : Urvish Shah (ushah)
 **/
public with sharing class CEMCI_TopicsController {
  @AuraEnabled
  public static List<SObJectResult> getResults(String value, List<String> selectedRecId) {
    List<SObJectResult> sObjectResultList = new List<SObJectResult>();
    value = String.escapeSingleQuotes(value);

    if (selectedRecId == null) {
      selectedRecId = new List<String>();
    }

    if (String.isNotEmpty(value)) {
      String query =
        'Select Id, Name FROM CEMCI_Tags__c WHERE Name LIKE \'%' +
        value.trim() +
        '%\' and ID NOT IN: selectedRecId ORDER BY Name ASC';
      try {
        for (sObject so : Database.Query(query)) {
          String fieldvalue = (String) so.get('Name');
          sObjectResultList.add(new SObjectResult(fieldvalue, so.Id));
        }
      } catch (Exception e) {
        CEMCI_TopicsController.createLog(e);
        throw new AuraHandledException(e.getMessage());
      }
    }
    return sObjectResultList;
  }

  @AuraEnabled
  public static void createTag(Id recordId, String topicId) {
    CEMCI_Add_to_Campaign__e addToCamaignEvent;
    String sobjectTypeString = recordId.getSObjectType().getDescribe().getName();
    CEMCI_TagAssignment__c tag = new CEMCI_TagAssignment__c();
    tag.Topic__c = topicId;

    if (sobjectTypeString.contains('__c')) {
      tag.put(sobjectTypeString, recordId);
    } else {
      tag.put(sobjectTypeString + '__c', recordId);

      addToCamaignEvent = new CEMCI_Add_to_Campaign__e();
      addToCamaignEvent.recordId__c = recordId;
      addToCamaignEvent.sObjectTypeString__c = sobjectTypeString;
      addToCamaignEvent.topicId__c = topicId;
    }

    try {
      if (Schema.sObjectType.CEMCI_TagAssignment__c.isCreateable()) {
        insert tag;

        if (addToCamaignEvent != null)
          Eventbus.publish(addToCamaignEvent);
      }
      else{
        throw new InsufficientAccessException('You do not have a permission to create tags');
      }
    } catch (Exception e) {
      CEMCI_TopicsController.createLog(e);
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static List<CEMCI_TagAssignment__c> getTagsforRecord(String recordId, String objectAPIName) {
    List<CEMCI_TagAssignment__c> tags = new List<CEMCI_TagAssignment__c>();
    if (recordId == null) {
      return tags;
    }
    recordId = String.escapeSingleQuotes(recordId);
    objectAPIName = String.escapeSingleQuotes(objectAPIName);

    if (!objectAPIName.contains('__c'))
      objectAPIName = String.escapeSingleQuotes(objectAPIName + '__c');

    String query =
      'Select Topic__r.Name, Topic__c, Id FROM CEMCI_TagAssignment__c WHERE ' +
      objectAPIName +
      ' =\'' +
      recordId +
      '\'';
    try {
      tags = Database.Query(query);
    } catch (Exception e) {
      CEMCI_TopicsController.createLog(e);
      throw new AuraHandledException(e.getMessage());
    }
    return tags;
  }

  @AuraEnabled
  public static void deleteTag(Id recordId, String topicId) {
    String sobjectTypeString = recordId.getSObjectType().getDescribe().getName();

    if (!sobjectTypeString.contains('__c'))
      sobjectTypeString = sobjectTypeString + '__c';

    recordId = String.escapeSingleQuotes(recordId);
    topicId = String.escapeSingleQuotes(topicId);
    String query =
      'SELECT id FROM CEMCI_TagAssignment__c WHERE Topic__c =\'' +
      topicId +
      '\' AND ' +
      sobjectTypeString +
      ' =\'' +
      recordId +
      '\'';
    try {
      CEMCI_TagAssignment__c tag = Database.Query(query);
      if (Schema.sObjectType.CEMCI_TagAssignment__c.isDeletable()) {
        delete tag;
      }
      else{
        throw new InsufficientAccessException('You do not have a permission to delete tags');
      }
    } catch (Exception e) {
      CEMCI_TopicsController.createLog(e);
      throw new AuraHandledException(e.getMessage());
    }
  }

  private static void createLog(Exception e) {
    PF_Logger.log('CEMCI', 'ERROR', e.getMessage(), e.getTypeName(), String.valueOf(e), 'CEMCI_TopicsController');
    PF_Logger.createLogs(PF_Logger.logs);
  }

  public static Set<String> getTopicIdforRecord(String recordId, String objectAPIName) {
    List<CEMCI_TagAssignment__c> tags = new List<CEMCI_TagAssignment__c>();
    Set<String> tagSet = new Set<String>();

    if (!objectAPIName.contains('__c'))
      objectAPIName = objectAPIName + '__c';

    String query = 'Select Topic__c FROM CEMCI_TagAssignment__c WHERE ' + objectAPIName + ' =\'' + recordId + '\'';
    try {
      tags = Database.Query(query);
      for (CEMCI_TagAssignment__c tag : tags) {
        tagSet.add(tag.Topic__c);
      }
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
    return tagSet;
  }

  public static void createTagAssignments(Map<Id, Set<String>> leadToTagsMapping) {
    List<CEMCI_TagAssignment__c> tagList = new List<CEMCI_TagAssignment__c>();
    List<CEMCI_Add_to_Campaign__e> campaignEvents = new List<CEMCI_Add_to_Campaign__e>();
    try {
      for (Id recordId : leadToTagsMapping.keySet()) {
        String sobjectTypeString = recordId.getSObjectType().getDescribe().getName();
        for (String topicId : leadToTagsMapping.get(recordId)) {
          CEMCI_Add_to_Campaign__e addToCamaignEvent = new CEMCI_Add_to_Campaign__e(
            recordId__c = recordId,
            sObjectTypeString__c = sobjectTypeString,
            topicId__c = topicId
          );
          campaignEvents.add(addToCamaignEvent);
          CEMCI_TagAssignment__c tag = new CEMCI_TagAssignment__c();
          tag.Topic__c = topicId;
          tag.put(sobjectTypeString + '__c', recordId);
          tagList.add(tag);
        }
      }
      if (Schema.sObjectType.CEMCI_TagAssignment__c.isCreateable()) {
        insert tagList;
        Eventbus.publish(campaignEvents);
      }
      else{
        throw new InsufficientAccessException('You do not have a permission to create tags');
      }
    } catch (Exception e) {
      CEMCI_TopicsController.createLog(e);
      throw new AuraHandledException(e.getMessage());
    }
  }

  public class SObjectResult {
    @AuraEnabled
    public String recName;
    @AuraEnabled
    public Id recId;

    public SObJectResult(String recNameTemp, Id recIdTemp) {
      recName = recNameTemp;
      recId = recIdTemp;
    }
    public SObJectResult() {
    }
  }
}