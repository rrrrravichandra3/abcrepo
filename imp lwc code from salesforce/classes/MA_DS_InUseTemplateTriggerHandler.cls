/**
 * W-12612799
 * Trigger handler for MA_DS_InUseTemplateTrigger
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         13/03/2023      Chakshu Malhotra        Trigger handler logic for MA_DS_InUseTemplateTrigger.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class MA_DS_InUseTemplateTriggerHandler {

    public static Boolean triggerDisabled = false;

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method invokes the appropriate trigger handler method based on TriggerOperation.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_DS_In_Use_Template__c>, Trigger.new list)
    * @param    oldMap 	   		DESCRIPTION (Data type Map<Id, MA_DS_In_Use_Template__c>, Trigger.oldMap)
    * @param    operation 	    DESCRIPTION (Data type TriggerOperation, TriggerOperation enum type)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void handler(List<MA_DS_In_Use_Template__c> newRecords, Map<Id, MA_DS_In_Use_Template__c> oldMap, TriggerOperation operation) {
        switch on operation {
            when BEFORE_INSERT {
                onBeforeInsert(newRecords);
            }when AFTER_INSERT {
                onAfterInsert(newRecords);
            }when BEFORE_UPDATE {
                onBeforeUpdate(newRecords, oldMap);
            }when AFTER_UPDATE {
                onAfterUpdate(newRecords, oldMap);
            }
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method handles before insert logic on MA_DS_In_Use_Template__c records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_DS_In_Use_Template__c>, Trigger.new list)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void onBeforeInsert(List<MA_DS_In_Use_Template__c> newRecords) {
        for(MA_DS_In_Use_Template__c newRec : newRecords) {
            MA_DS_InUseTemplateTriggerHelper.helperInstance.updateSuppressRulesCriteria(newRec);
            MA_DS_InUseTemplateTriggerHelper.helperInstance.updateNeedSyncOnPDIds(newRec);
            MA_DS_InUseTemplateTriggerHelper.helperInstance.updateConcatenatedId(newRec);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method handles after insert logic on MA_DS_In_Use_Template__c records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_DS_In_Use_Template__c>, Trigger.new list)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void onAfterInsert(List<MA_DS_In_Use_Template__c> newRecords) {
        MA_DS_InUseTemplateTriggerHelper.helperInstance.updatePackageDistributionsWithNeedSyncStatus();
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method handles before update logic on MA_DS_In_Use_Template__c records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_DS_In_Use_Template__c>, Trigger.new list)
    * @param    oldMap          DESCRIPTION (Data type Map<Id, MA_DS_In_Use_Template__c>, Trigger.oldMap of In Use Template records)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void onBeforeUpdate(List<MA_DS_In_Use_Template__c> newRecords, Map<Id, MA_DS_In_Use_Template__c> oldMap) {
        for(MA_DS_In_Use_Template__c newRec : newRecords) {
            MA_DS_InUseTemplateTriggerHelper.helperInstance.updateNeedSyncOnPDIds(newRec, oldMap.get(newRec.Id));
            MA_DS_InUseTemplateTriggerHelper.helperInstance.updateConcatenatedId(newRec);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method handles after update logic on MA_DS_In_Use_Template__c records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_DS_In_Use_Template__c>, Trigger.new list)
    * @param    oldMap          DESCRIPTION (Data type Map<Id, MA_DS_In_Use_Template__c>, Trigger.oldMap of In Use Template records)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void onAfterUpdate(List<MA_DS_In_Use_Template__c> newRecords, Map<Id, MA_DS_In_Use_Template__c> oldMap) {
        MA_DS_InUseTemplateTriggerHelper.helperInstance.updatePackageDistributionsWithNeedSyncStatus();
    }
}