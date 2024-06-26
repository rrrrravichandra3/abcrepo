/**
 * W-13011380
 * Trigger handler for MA_DS_TemplateTrigger
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         19/04/2023      Chakshu Malhotra        Trigger handler logic for MA_DS_TemplateTrigger.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class MA_DS_TemplateTriggerHandler {

    public static Boolean triggerDisabled = false;

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method invokes the appropriate trigger handler method based on TriggerOperation.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_DS_Template__c>, Trigger.new list)
    * @param    oldMap 	   		DESCRIPTION (Data type Map<Id, MA_DS_Template__c>, Trigger.oldMap)
    * @param    operation 	    DESCRIPTION (Data type TriggerOperation, TriggerOperation enum type)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void handler(List<MA_DS_Template__c> newRecords, Map<Id, MA_DS_Template__c> oldMap, TriggerOperation operation) {
        switch on operation {
            when BEFORE_INSERT {
                onBeforeInsert(newRecords);
            }when BEFORE_UPDATE {
                onBeforeUpdate(newRecords, oldMap);
            }when BEFORE_DELETE {
                onBeforeDelete(oldMap);
            }
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method handles before insert logic on MA_DS_Template__c records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_DS_Template__c>, Trigger.new list)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void onBeforeInsert(List<MA_DS_Template__c> newRecords) {
        MA_DS_TemplateTriggerHelper.helperInstance.checkTemplatesCRUDAccess(newRecords);
        MA_DS_TemplateTriggerHelper.helperInstance.preventDuplicateTemplates(newRecords);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method handles before update logic on MA_DS_Template__c records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_DS_Template__c>, Trigger.new list)
    * @param    oldMap          DESCRIPTION (Data type Map<Id, MA_DS_Template__c>, Trigger.oldMap of Template records)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void onBeforeUpdate(List<MA_DS_Template__c> newRecords, Map<Id, MA_DS_Template__c> oldMap) {
        MA_DS_TemplateTriggerHelper.helperInstance.checkTemplatesCRUDAccess(newRecords);
        MA_DS_TemplateTriggerHelper.helperInstance.preventDuplicateTemplates(newRecords);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method handles before delete logic on MA_DS_Template__c records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    oldMap 	   		DESCRIPTION (Data type Map<Id, MA_DS_Template__c>, Trigger.oldMap of Template records)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void onBeforeDelete(Map<Id, MA_DS_Template__c> oldMap) {
        for(Id recordId : oldMap.keySet()) {
            MA_DS_TemplateTriggerHelper.helperInstance.preventDeletionIfInsufficientAccess(oldMap.get(recordId));
        }
    }
}