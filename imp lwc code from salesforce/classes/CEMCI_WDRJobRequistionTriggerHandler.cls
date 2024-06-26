public with sharing class CEMCI_WDRJobRequistionTriggerHandler implements WDR_CommonTriggerHandler {
  /**
   * @description Method to propogate changes to CEMCI objects on the before insert event of the WDR_Job object
   **/
  public void beforeInsert() {
  }

  /**
   * @description Method to propogate changes to CEMCI objects on the after insert event of the WDR_Job object
   **/
  public void afterInsert() {
    List<CEMCI_Global_Picklist_Map__mdt> metaRecordList = [
      SELECT
        MasterLabel,
        Active_Field_API_Name__c,
        Can_be_deactivated__c,
        Global_Picklist_Id__c,
        Include_Mapping_Record__c,
        Object_Field_API_Name__c,
        Source_Object_API_Name__c
      FROM CEMCI_Global_Picklist_Map__mdt
      WHERE
        Source_Object_API_Name__c = :String.valueOf(Trigger.new.get(0).getSObjectType())
        AND Include_Mapping_Record__c = TRUE
    ];
    List<sObject> CEMCIRecords = new List<sObject>();
    for (sObject job : Trigger.new) {
      for (CEMCI_Global_Picklist_Map__mdt metaRecord : metaRecordList) {
        if (job.get(metaRecord.Object_Field_API_Name__c) != null)
          CEMCIRecords.add(job);
      }
    }
    if (!CEMCIRecords.isEmpty())
      CEMCI_UpdateGlobalValueSet.updatePicklistValuesFromWorkday(CEMCIRecords);
  }

  /**
   * @description Method to propogate changes to CEMCI objects on the before update event of the WDR_Job object
   **/
  public void beforeUpdate() {
  }

  /**
   * @description Method to propogate changes to CEMCI objects on the after update event of the WDR_Job object
   **/
  public void afterUpdate() {
    Set<Id> jobReqWithHMChange = new Set<Id>();
    List<CEMCI_Global_Picklist_Map__mdt> metaRecordList = [
      SELECT
        MasterLabel,
        Active_Field_API_Name__c,
        Can_be_deactivated__c,
        Global_Picklist_Id__c,
        Include_Mapping_Record__c,
        Object_Field_API_Name__c,
        Source_Object_API_Name__c
      FROM CEMCI_Global_Picklist_Map__mdt
      WHERE
        Source_Object_API_Name__c = :String.valueOf(Trigger.new.get(0).getSObjectType())
        AND Include_Mapping_Record__c = TRUE
    ];
    List<sObject> CEMCIRecords = new List<sObject>();
    for (sObject job : Trigger.new) {
      Id jobId = (Id) job.get('Id');
      sObject oldRecord = Trigger.oldMap.get(jobId);
      if (job.get('Hiring_Manager__c') != oldRecord.get('Hiring_Manager__c')) {
        jobReqWithHMChange.add(jobId);
      }
      for (CEMCI_Global_Picklist_Map__mdt metaRecord : metaRecordList) {
        if (
          job.get(metaRecord.Object_Field_API_Name__c) != null &&
          oldRecord.get(metaRecord.Object_Field_API_Name__c) != job.get(metaRecord.Object_Field_API_Name__c)
        )
          CEMCIRecords.add(job);
      }
    }
    if (!CEMCIRecords.isEmpty()) {
      CEMCI_UpdateGlobalValueSet.updatePicklistValuesFromWorkday(CEMCIRecords);
    }

    if (!jobReqWithHMChange.isEmpty()) {
      CEMCI_ManageCandidatePoolSharing.updateHiringManagerShare(jobReqWithHMChange, Trigger.oldMap, Trigger.newMap);
    }
  }

  /**
   * @description Method to propogate changes to SIFT objects on the before delete event of the WDR_Job object
   **/
  public void beforeDelete() {
  }

  /**
   * @description Method to propogate changes to SIFT objects on the after delete event of the WDR_Job object
   **/
  public void afterDelete() {
  }

  /**
   * @description Method to propogate changes to SIFT objects on the after undelete event of the WDR_Job object
   **/
  public void afterUnDelete() {
  }
}