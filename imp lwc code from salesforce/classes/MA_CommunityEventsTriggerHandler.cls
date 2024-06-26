/**
 * W-10149775
 * Trigger handler for MA_CommunityEventsTrigger
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         05/12/2021      Chakshu Malhotra        Trigger handler logic for MA_CommunityEventsTrigger.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public class MA_CommunityEventsTriggerHandler {

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method invokes the appropriate trigger handler method based on TriggerOperation.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_Community_Events__c>, Trigger.new list)
    * @param    oldMap 	   		DESCRIPTION (Data type Map<Id, MA_Community_Events__c>, Trigger.oldMap)
    * @param    operation 	    DESCRIPTION (Data type TriggerOperation, TriggerOperation enum type)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void handler(List<MA_Community_Events__c> newRecords, Map<Id, MA_Community_Events__c> oldMap, TriggerOperation operation){
        switch on operation {
            when BEFORE_INSERT {
                onBeforeInsert(newRecords);
            }when BEFORE_UPDATE {
                onBeforeUpdate(newRecords, oldMap);
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method handles before insert logic on MA_Community_Events__c records.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_Community_Events__c>, Trigger.new list)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void onBeforeInsert(List<MA_Community_Events__c> newRecords) {
        MA_CommunityEventsTriggerHelper.handleBeforeInsert(newRecords);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method handles before update logic on MA_Community_Events__c records.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_Community_Events__c>, Trigger.new list)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void onBeforeUpdate(List<MA_Community_Events__c> newRecords, Map<Id, MA_Community_Events__c> oldMap){
        MA_CommunityEventsTriggerHelper.handleBeforeUpdate(newRecords, oldMap);
    }
}