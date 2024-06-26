/**
 * W-10149775
 * Trigger helper class for MA_CommunityEventsTriggerHandler
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         05/12/2021      Chakshu Malhotra        Trigger helper logic for MA_CommunityEventsTriggerHandler.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public class MA_CommunityEventsTriggerHelper {

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method handles before insert logic on MA_Community_Events__c records.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newEvents 	   	DESCRIPTION (Data type List<MA_Community_Events__c>, List of new Event records)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void handleBeforeInsert(List<MA_Community_Events__c> newEvents) {
        for(MA_Community_Events__c newEvent : newEvents) {
            MA_CommunityEventsTriggerUtility.updateEventStatus(newEvent, null);
            MA_CommunityEventsTriggerUtility.updateEventEndDateTime(newEvent, null);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method handles before update logic on MA_Community_Events__c records.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newEvents 	   	DESCRIPTION (Data type List<MA_Community_Events__c>, List of new Event records)
    * @param    oldEventsMap    DESCRIPTION (Data type Map<Id, MA_Community_Events__c>, Trigger.oldMap of Event record)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void handleBeforeUpdate(List<MA_Community_Events__c> newEvents, Map<Id, MA_Community_Events__c> oldEventsMap) {
        for(MA_Community_Events__c newEvent : newEvents) {
            MA_Community_Events__c oldEvent = oldEventsMap.get(newEvent.Id);
            MA_CommunityEventsTriggerUtility.updateEventStatus(newEvent, oldEvent);
            MA_CommunityEventsTriggerUtility.updateEventEndDateTime(newEvent, oldEvent);
        }
    }

}