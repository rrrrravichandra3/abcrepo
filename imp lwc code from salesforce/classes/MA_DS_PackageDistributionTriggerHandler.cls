/**
 * W-12612799
 * Trigger handler for MA_DS_PackageDistributionTrigger
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         12/03/2023      Chakshu Malhotra        Trigger handler logic for MA_DS_PackageDistributionTrigger.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class MA_DS_PackageDistributionTriggerHandler {

    public static Boolean triggerDisabled = false;

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method invokes the appropriate trigger handler method based on TriggerOperation.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_DS_Package_Distribution__c>, Trigger.new list)
    * @param    oldMap 	   		DESCRIPTION (Data type Map<Id, MA_DS_Package_Distribution__c>, Trigger.oldMap)
    * @param    operation 	    DESCRIPTION (Data type TriggerOperation, TriggerOperation enum type)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void handler(List<MA_DS_Package_Distribution__c> newRecords, Map<Id, MA_DS_Package_Distribution__c> oldMap, TriggerOperation operation) {
        switch on operation {
            when BEFORE_UPDATE {
                onBeforeUpdate(newRecords, oldMap);
            }when AFTER_UPDATE {
                onAfterUpdate(newRecords, oldMap);
            }
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method handles before update logic on MA_DS_Package_Distribution__c records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_DS_Package_Distribution__c>, Trigger.new list)
    * @param    oldMap          DESCRIPTION (Data type Map<Id, MA_DS_Package_Distribution__c>, Trigger.oldMap of Package Distribution records)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void onBeforeUpdate(List<MA_DS_Package_Distribution__c> newRecords, Map<Id, MA_DS_Package_Distribution__c> oldMap) {
        for(MA_DS_Package_Distribution__c newRec : newRecords) {
            MA_DS_PackageDistributionTriggerHelper.helperInstance.updateRuleSyncStatus(newRec, oldMap.get(newRec.Id));
            MA_DS_PackageDistributionTriggerHelper.helperInstance.updateDeliverySchedule(newRec, oldMap.get(newRec.Id));
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method handles after update logic on MA_DS_Package_Distribution__c records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_DS_Package_Distribution__c>, Trigger.new list)
    * @param    oldMap          DESCRIPTION (Data type Map<Id, MA_DS_Package_Distribution__c>, Trigger.oldMap of Package Distribution records)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void onAfterUpdate(List<MA_DS_Package_Distribution__c> newRecords, Map<Id, MA_DS_Package_Distribution__c> oldMap) {
        MA_DS_PackageDistributionTriggerHelper.helperInstance.updateSyncRulesOnPDIds();
        MA_DS_PackageDistributionTriggerHelper.helperInstance.handleStatusUpdate(newRecords, oldMap);
        MA_DS_PackageDistributionTriggerHelper.helperInstance.handleDeliveryScheduleUpdate(newRecords, oldMap);
        MA_DS_PackageDistributionTriggerHelper.helperInstance.handleInitScheduledDelivery(newRecords, oldMap);
    }
}