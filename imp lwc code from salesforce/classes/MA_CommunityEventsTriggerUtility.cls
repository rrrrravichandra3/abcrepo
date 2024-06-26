/**
 * W-10149775
 * Trigger utility class for MA_CommunityEventsTriggerHelper
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         05/12/2021      Chakshu Malhotra        Trigger utility logic for MA_CommunityEventsTriggerHelper.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public class MA_CommunityEventsTriggerUtility {

    private static final String EVENT_STATUS_NEW = Label.MA_Event_Status_New;
    private static final String EVENT_STATUS_INACTIVE = Label.MA_Event_Status_Inactive;
    private static final String EVENT_STATUS_CHANGES_PENDING = Label.MA_Event_Status_Ready_To_Send;
    private static final String EVENT_STATUS_CHANGES_IN_PROGRESS = Label.MA_Event_Status_Sending_Invites;
    private static final List<String> EVENT_DETAIL_FIELDS = Label.MA_Event_Detail_Fields.toLowerCase().split(';');

    public enum EventStatus {INACTIVE, CHANGES_PENDING}

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method updates the Status if some fields of an event record are updated or event is turned inactive.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newEvent 	   	DESCRIPTION (Data type MA_Community_Events__c, The new Event record)
    * @param    oldEvent 	   	DESCRIPTION (Data type Id, MA_Community_Events__c, The old Event record)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updateEventStatus(MA_Community_Events__c newEvent, MA_Community_Events__c oldEvent) {
        if(isEventActive(newEvent) && isEligibleForPendingState(newEvent, oldEvent)) {
            updateEventStatus(newEvent, oldEvent, EventStatus.CHANGES_PENDING);
        }else if(isEventInactive(newEvent)) {
            updateEventStatus(newEvent, oldEvent, EventStatus.INACTIVE);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method checks if event is active & currenlty not in "Pending" or already in "Progress".
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newEvent 	   	DESCRIPTION (Data type MA_Community_Events__c, The new Event record)
    * @return   Boolean         DESCRIPTION (return if event is active)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isEventActive(MA_Community_Events__c newEvent) {
        List<String> statusList = new List<String> {EVENT_STATUS_CHANGES_PENDING.toLowerCase(), EVENT_STATUS_CHANGES_IN_PROGRESS.toLowerCase()};
        return newEvent.Active__c && String.isNotBlank(newEvent.Event_Invite_Status__c) && !statusList.contains(newEvent.Event_Invite_Status__c.toLowerCase());
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method checks if event is inactive & currenlty not in "Pending" or already in "Progress".
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newEvent 	   	DESCRIPTION (Data type MA_Community_Events__c, The new Event record)
    * @return   Boolean         DESCRIPTION (return if event is inactive)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isEventInactive(MA_Community_Events__c newEvent) {
        List<String> statusList = new List<String> {EVENT_STATUS_INACTIVE.toLowerCase(), EVENT_STATUS_CHANGES_IN_PROGRESS.toLowerCase()};
        return !newEvent.Active__c && String.isNotBlank(newEvent.Event_Invite_Status__c) && !statusList.contains(newEvent.Event_Invite_Status__c.toLowerCase());
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method checks if event is eligible to put in Pending state.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newEvent 	   	DESCRIPTION (Data type MA_Community_Events__c, The new Event record)
    * @param    oldEvent 	   	DESCRIPTION (Data type MA_Community_Events__c, The old Event record)
    * @return   Boolean         DESCRIPTION (return if event is eligible)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isEligibleForPendingState(MA_Community_Events__c newEvent, MA_Community_Events__c oldEvent) {
        return isEventStatusNew(newEvent) || isEventUpated(newEvent, oldEvent) || isEventStatusInactive(newEvent);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method checks if event is in New state.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newEvent 	   	DESCRIPTION (Data type MA_Community_Events__c, The new Event record)
    * @return   Boolean         DESCRIPTION (return if event is New)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isEventStatusNew(MA_Community_Events__c newEvent) {
        return newEvent.Event_Invite_Status__c?.equalsIgnoreCase(EVENT_STATUS_NEW);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method checks event is not already in "Progress" state & if any of the important event fields are updated.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newEvent 	   	DESCRIPTION (Data type MA_Community_Events__c, The new Event record)
    * @param    oldEvent 	   	DESCRIPTION (Data type MA_Community_Events__c, The old Event record)
    * @return   Boolean         DESCRIPTION (return if any of the fields are updated)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isEventUpated(MA_Community_Events__c newEvent, MA_Community_Events__c oldEvent) {
        return !newEvent.Event_Invite_Status__c?.equalsIgnoreCase(EVENT_STATUS_CHANGES_IN_PROGRESS) && 
               (Trigger.isInsert || newEvent.Filter_Criteria_Query__c != oldEvent.Filter_Criteria_Query__c || 
               isEventDetailUpdated(newEvent, oldEvent));
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method checks if event detail is updated.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newEvent 	   	DESCRIPTION (Data type MA_Community_Events__c, The new Event record)
    * @param    oldEvent 	   	DESCRIPTION (Data type MA_Community_Events__c, The old Event record)
    * @return   Boolean         DESCRIPTION (return if event detail is updated)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isEventDetailUpdated(MA_Community_Events__c newEvent, MA_Community_Events__c oldEvent) {
        Boolean isUpdated = false;

        for(String eventField : EVENT_DETAIL_FIELDS) {
            if(newEvent.get(eventField) != oldEvent.get(eventField)) {
                isUpdated = true;
                break;
            }
        }
        return isUpdated;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method checks if Status is inactive.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newEvent 	   	DESCRIPTION (Data type MA_Community_Events__c, The new Event record)
    * @return   Boolean         DESCRIPTION (return if Status is inactive)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isEventStatusInactive(MA_Community_Events__c newEvent) {
        return newEvent.Event_Invite_Status__c?.equalsIgnoreCase(EVENT_STATUS_INACTIVE);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method updates Status to either "Pending" or "Inactive" state based on its eligibility.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newEvent 	   	    DESCRIPTION (Data type MA_Community_Events__c, The new Event record)
    * @param    oldEvent 	   	    DESCRIPTION (Data type MA_Community_Events__c, The old Event record)
    * @param    eventStatus 	    DESCRIPTION (Data type EventStatus, The EventStatus enum type)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateEventStatus(MA_Community_Events__c newEvent, MA_Community_Events__c oldEvent, EventStatus eventStatus) {
        String currentEventStatus = newEvent.Event_Invite_Status__c;

        switch on eventStatus {
            when INACTIVE {
                newEvent.Event_Invite_Status__c = EVENT_STATUS_INACTIVE;
            }when CHANGES_PENDING {
                newEvent.Event_Invite_Status__c = EVENT_STATUS_CHANGES_PENDING;
            }
        }
        
        updateLastActiveStatus(newEvent, oldEvent, currentEventStatus);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method captures Status just before it is turned inactive & stores it in Last Active Status.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newEvent 	   	        DESCRIPTION (Data type MA_Community_Events__c, The new Event record)
    * @param    oldEvent 	   	        DESCRIPTION (Data type MA_Community_Events__c, The old Event record)
    * @param    currentEventStatus 	    DESCRIPTION (Data type String, Status before it is turned inactive)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateLastActiveStatus(MA_Community_Events__c newEvent, MA_Community_Events__c oldEvent, String currentEventStatus) {
        Boolean isTurnedActive = !Trigger.isInsert && newEvent.Active__c && (newEvent.Active__c != oldEvent.Active__c);
        Boolean isTurnedInactive = !Trigger.isInsert && !newEvent.Active__c && (newEvent.Active__c != oldEvent.Active__c);

        if(isTurnedActive && String.isNotBlank(newEvent.Last_Active_Invite_Status__c)) {
            newEvent.Event_Invite_Status__c = newEvent.Last_Active_Invite_Status__c;
        }else if(isTurnedInactive) {
            newEvent.Last_Active_Invite_Status__c = currentEventStatus;
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method updates the Event End Date & End Time fields if "All Day Event" is set.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newEvent 	   	DESCRIPTION (Data type MA_Community_Events__c, The new Event record)
    * @param    oldEvent 	   	DESCRIPTION (Data type Id, MA_Community_Events__c, The old Event record)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updateEventEndDateTime(MA_Community_Events__c newEvent, MA_Community_Events__c oldEvent) {
        if(newEvent.All_Day_Event__c) {
            newEvent.End_Date__c = (newEvent.Start_Date__c != oldEvent?.Start_Date__c) ? newEvent.Start_Date__c : newEvent.End_Date__c;
            newEvent.Start_Time__c = Time.newInstance(0, 0, 0, 0);
            newEvent.End_Time__c = Time.newInstance(23, 59, 0, 0);
        }
    }
}