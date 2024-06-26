/**
 * @description       :
 * @author            : Urvish Shah (ushah)
 * @group             :
 * @last modified on  : 08-22-2022
 * @last modified by  : Urvish Shah (ushah)
 **/
//class to capture First and Last Interaction Dates on Lead/Contact
//Initial_Interaction_Date__c shows the first ever campaign response or call logged on Lead or Contact
//Last_Interaction_Date__c shows the latest campaign response or call logged on Lead or Contact
//CEMCI R1

public with sharing class CEMCI_Task {
  private static final Id taskRecordTypeId = Task.sObjectType.getDescribe()
    .getRecordTypeInfosByDeveloperName()
    .get('Outbound_Sourcer_Call')
    .getRecordTypeId();

  public static List<Task> taskList;
  public static List<Task> updatedOrDeletedTaskList;
  public static Map<Id, Task> taskMap = new Map<Id, Task>();

  public static void updateDatesFromTask() {
    Set<Id> whoIds = new Set<Id>();
    Map<Id, sObject> whoMap = new Map<Id, sObject>();
    for (Task t : taskList) {
      if (t.RecordTypeId == taskRecordTypeId && t.ActivityDate != null && t.IsClosed == true) {
        if (t.whoId != null) {
          whoIds.add(t.WhoId);
        }
      }
    }
    if (whoIds.size() > 0) {
      //set up maps to populate contacts from text Id after lead/contact check
      Map<Id, Lead> leadMap = new Map<Id, Lead>(
        [SELECT Id, Initial_Interaction_Date__c, Last_Interaction_Date__c FROM Lead WHERE Id IN :whoIds]
      );
      Map<Id, Contact> contactMap = new Map<Id, Contact>(
        [SELECT Id, Initial_Interaction_Date__c, Last_Interaction_Date__c FROM Contact WHERE Id IN :whoIds]
      );

      for (Task t : taskMap.values()) {
        Id whoId = t.WhoId;
        Integer d = t.ActivityDate.day();
        Integer mo = t.ActivityDate.month();
        Integer yr = t.ActivityDate.year();

        DateTime taskDate = DateTime.newInstance(yr, mo, d, 12, 0, 0);

        if (t.WhoId.getSObjectType() == Contact.sObjectType) {
          Contact c = contactMap.get(whoId);
          whoMap.put(c.Id, c);
          if (c.Initial_Interaction_Date__c == null || c.Initial_Interaction_Date__c > t.ActivityDate) {
            c.Initial_Interaction_Date__c = taskDate;
          }
          if (c.Last_Interaction_Date__c == null || c.Last_Interaction_Date__c < t.ActivityDate) {
            c.Last_Interaction_Date__c = taskDate;
          }
        } else if (t.WhoId.getSObjectType() == Lead.sObjectType) {
          Lead l = leadMap.get(whoId);
          whoMap.put(l.Id, l);
          if (l.Initial_Interaction_Date__c == null || l.Initial_Interaction_Date__c > t.ActivityDate) {
            l.Initial_Interaction_Date__c = taskDate;
          }
          if (l.Last_Interaction_Date__c == null || l.Last_Interaction_Date__c < t.ActivityDate) {
            l.Last_Interaction_Date__c = taskDate;
          }
          //if else to check if
        }
      }
    }
    update whoMap.values();
  }

  public static void updateLogInteractionDate() {
    Set<Id> taskIds = new Set<Id>();
    try {
      //Map: Key = lead ID , value = List<Task Id>
      Map<Id, List<Id>> leadVSTaskIds = new Map<Id, List<Id>>();
      for (Task task : taskMap.values()) {
        if (task.WhoId != null && task.WhoId.getSObjectType() != Lead.sObjectType) {
          continue;
        }
        if (leadVSTaskIds.containsKey(task.whoId))
          leadVSTaskIds.get(task.whoId).add(task.Id);
        else
          leadVSTaskIds.put(task.whoId, new List<Id>{ task.Id });
      }

      String eligibleSubjectsStr = CEMCI_Settings__c.getInstance().EligibleTaskSubjectsforLeadScore__c;
      List<String> eligibleSubjects = eligibleSubjectsStr == null ? new List<String>() : eligibleSubjectsStr.split(',');
      //Get all leads
      Map<Id, Lead> leads = new Map<Id, Lead>(
        [SELECT id, ActivityRecentEngagementDate__c FROM Lead WHERE ID IN :leadVSTaskIds.keySet()]
      );
      //Lead ID vs LastModifiedDate
      Map<Id, DateTime> leadVSDates = new Map<Id, DateTime>();
      List<Task> tasks = [
        SELECT id, LastModifiedDate, whoid
        FROM Task
        WHERE WHOID IN :leads.keyset() AND TaskSubtype = 'Call' AND Subject IN :eligibleSubjects
        ORDER BY LastModifiedDate DESC
      ];

      for (Task task : tasks) {
        if (leadVSDates.containsKey(task.whoId))
          continue;
        else {
          leadVSDates.put(task.whoId, task.LastModifiedDate);
          leads.get(task.whoId).ActivityRecentEngagementDate__c = task.LastModifiedDate;
        }
      }
      update leads.values();
    } catch (Exception e) {
      PF_Logger.log(
        'CEMCI',
        'ERROR',
        String.valueOf(e.getCause()),
        ' line no :' + String.valueOf(e.getLineNumber()),
        String.valueOf(e.getMessage()),
        'CEMCI_Task.updateLogInteractionDate'
      );
    }
  }

  public static void updateLeadScore() {
    Set<Id> leadIds = new Set<Id>();
    Map<Id, List<Task>> mapLeadIdToActivities = new Map<Id, List<Task>>();
    List<Lead> listLeadToUpdate = new List<Lead>();

    for (Task task : updatedOrDeletedTaskList) {
      if (task.whoId != null && task.WhoId.getSObjectType() == Lead.sObjectType) {
        leadIds.add(task.WhoId);
      }
    }

    for (Task task : [
      SELECT id, LastModifiedDate, whoid, Subject
      FROM Task
      WHERE WHOID IN :leadIds
      ORDER BY LastModifiedDate DESC
    ]) {
      if (!mapLeadIdToActivities.containsKey(task.WhoId)) {
        mapLeadIdToActivities.put(task.WhoId, new List<Task>{});
      }
      mapLeadIdToActivities.get(task.WhoId).add(task);
    }

    String eligibleSubjectsStr = CEMCI_Settings__c.getInstance().EligibleTaskSubjectsforLeadScore__c;
    List<String> eligibleSubjects = eligibleSubjectsStr == null ? new List<String>() : eligibleSubjectsStr.split(',');

    for (Id leadId : leadIds) {
      Lead lead = new Lead();
      if (!mapLeadIdToActivities.containsKey(leadId)) {
        lead.id = leadId;
        lead.Last_Interaction_Date__c = null;
        lead.ActivityRecentEngagementDate__c = null;
        listLeadToUpdate.add(lead);
      } else {
        lead.id = leadId;
        lead.Last_Interaction_Date__c = mapLeadIdToActivities.get(leadId)[0].LastModifiedDate;
        lead.ActivityRecentEngagementDate__c = null;
        for (Task task : mapLeadIdToActivities.get(leadId)) {
          if (eligibleSubjects.contains(task.Subject)) {
            lead.ActivityRecentEngagementDate__c = task.LastModifiedDate;
            break;
          }
        }
        listLeadToUpdate.add(lead);
      }
    }

    if (!listLeadToUpdate.isEmpty()) {
      update listLeadToUpdate;
    }
  }
}