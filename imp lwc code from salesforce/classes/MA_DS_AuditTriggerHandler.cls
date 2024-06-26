/**
 * W-12578116
 * Trigger handler for MA_DS_AuditTrigger
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         01/04/2023      Chakshu Malhotra        Trigger handler logic for MA_DS_AuditTrigger.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class MA_DS_AuditTriggerHandler {
    
    public static Boolean triggerDisabled = false;

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method invokes the appropriate trigger handler method based on TriggerOperation.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_DS_Audit__c>, Trigger.new list)
    * @param    oldMap 	   		DESCRIPTION (Data type Map<Id, MA_DS_Audit__c>, Trigger.oldMap)
    * @param    operation 	    DESCRIPTION (Data type TriggerOperation, TriggerOperation enum type)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void handler(List<MA_DS_Audit__c> newRecords, Map<Id, MA_DS_Audit__c> oldMap, TriggerOperation operation) {
        switch on operation {
            when AFTER_UPDATE {
                onAfterUpdate(newRecords, oldMap);
            }
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method handles after update logic on MA_DS_Audit__c records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_DS_Audit__c>, Trigger.new list)
    * @param    oldMap          DESCRIPTION (Data type Map<Id, MA_DS_Audit__c>, Trigger.oldMap of Audit records)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void onAfterUpdate(List<MA_DS_Audit__c> newRecords, Map<Id, MA_DS_Audit__c> oldMap) {
        MA_DS_AuditTriggerHelper.helperInstance.handleFailedCommonIdUpdate(newRecords, oldMap);
    }
}