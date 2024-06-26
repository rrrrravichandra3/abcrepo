/**
 * W-10149775 & W-10242698
 * Helper class to process (upsert eligible attendees, send invites & delete unwanted event attendees) community event.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         07/12/2021      Chakshu Malhotra        Holds utility methods to perform SOQL queries or DML operations while sending invites for the event.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public class MA_CommunityEventInviteHelper {

    public enum EligibleContacts {FIRST_BATCH, QUERY_MORE}
    public enum EventStatus {CHANGES_IN_PROGRESS, CHANGES_COMPLETE}
    public enum DeleteAttendees {COMPANY_MISMATCH, NOT_MEETING_CRITERIA}

    private static final String EVENT_CRITERIA_QUERY_ERROR = Label.MA_Event_Criteria_Query_Parse_Error;
    private static final String EVENT_RSVP_JSON_PARSE_ERROR = Label.MA_Event_RSVP_Field_JSON_Parse_Error;

    private static final String CONTACT_STATUS_CANCELLED = Label.MA_Contact_Status_Cancelled;

    private static final String EVENT_STATUS_CHANGES_PENDING = Label.MA_Event_Status_Ready_To_Send;
    private static final String EVENT_STATUS_CHANGES_COMPLETE = Label.MA_Event_Status_Invites_Sent;
    private static final String EVENT_STATUS_CHANGES_IN_PROGRESS = Label.MA_Event_Status_Sending_Invites;
    
    private static final String BATCH_CONFIG_NAME = Label.MA_Event_Invite_Sender_Config;
    private static final List<String> EVENT_DETAIL_FIELDS = Label.MA_Event_Detail_Fields.toLowerCase().split(';');
    private static final List<String> EVENT_ACTIVE_COMPANY_STATUS = Label.MA_Event_Active_Company_Status.split(';');
    private static final Set<String> EVENT_RSVP_FIELDS = new Set<String>(Label.MA_Event_RSVP_Required_Fields.toLowerCase().split(';'));

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get event batch configuration metadata and create wrapper instance for it.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   MA_CommunityEventSendInvites.EventInviteSenderConfig    DESCRIPTION (return EventInviteSenderConfig)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static MA_CommunityEventSendInvites.EventInviteSenderConfig getBatchConfig() {
        MA_Batch_Configuration__mdt batchConfigMetadata = getBatchConfigMetadata();

        MA_CommunityEventSendInvites.EventInviteSenderConfig batchConfig = new MA_CommunityEventSendInvites.EventInviteSenderConfig();
        batchConfig.batchSize = Integer.valueOf(batchConfigMetadata.Batch_Size__c);
        batchConfig.emailQueueableSize = Integer.valueOf(batchConfigMetadata.Email_Queueable_Size__c);
        batchConfig.dmlQueueableSize = Integer.valueOf(batchConfigMetadata.DML_Execute_Queueable_Size__c);
        batchConfig.notificationQueueableSize = Integer.valueOf(batchConfigMetadata.Notification_Queueable_Size__c);
        batchConfig.emailTemplateId = MA_CommunityEventInviteHelper.getEventEmailTemplateId(batchConfigMetadata.Email_Template__c);
        batchConfig.OrgWideEmailAddressId = MA_CommunityEventInviteHelper.getOrgWideEmailAddressId(batchConfigMetadata.OrgWide_Email_Address__c);
        batchConfig.notificationTypeId = MA_CommunityEventInviteHelper.getEventNotificationTypeId(batchConfigMetadata.Notification_Type__c);
        
        return batchConfig;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get event batch configuration metadata
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   MA_Batch_Configuration__mdt  DESCRIPTION (return MA_Batch_Configuration__mdt)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static MA_Batch_Configuration__mdt getBatchConfigMetadata() {
        return [SELECT Id, Batch_Size__c, DML_Execute_Queueable_Size__c, Email_Queueable_Size__c, Notification_Queueable_Size__c, Email_Template__c, OrgWide_Email_Address__c, Notification_Type__c 
                FROM MA_Batch_Configuration__mdt 
                WHERE DeveloperName = :BATCH_CONFIG_NAME LIMIT 1];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch template id for event invite update email.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    emailTemplate 	   	    DESCRIPTION (Data type String, Email template name.)
    * @return   Id                      DESCRIPTION (return Id of email template)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Id getEventEmailTemplateId(String emailTemplate) {
        return [SELECT Id FROM EmailTemplate WHERE DeveloperName = :emailTemplate LIMIT 1]?.Id;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch orgWide Email id for event invite sender.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    OrgwideEmailAddress 	 DESCRIPTION (Data type String, Orgwide EmailAddres sname.)
    * @return   Id                       DESCRIPTION (return Id of Orgwide EmailAddress)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Id getOrgWideEmailAddressId(String OrgwideEmailAddress) {
        return [SELECT Id FROM OrgWideEmailAddress WHERE Address = :OrgwideEmailAddress LIMIT 1]?.Id;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch notification type id for event invite update notification.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    notificationType 	   	DESCRIPTION (Data type String, Notification name.)
    * @return   Id                      DESCRIPTION (return Id of notification type)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Id getEventNotificationTypeId(String notificationType) {
        return [SELECT Id FROM CustomNotificationType WHERE DeveloperName = :notificationType LIMIT 1]?.Id;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch event details for the event being published.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    eventId 	   	        DESCRIPTION (Data type String, Id of the event in process)
    * @return   MA_Community_Events__c  DESCRIPTION (return event details)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<MA_Community_Events__c> getEventDetail(String eventId) {
        return [SELECT Id, Name, Acquisition_Company__c, All_Day_Event__c, Description__c, End_Date__c, End_Datetime__c, End_Time__c, 
                Event_Link__c, Event_Type__c, Location__c, Required_Event__c, Start_Date__c, Start_Datetime__c, Start_Time__c, 
                Event_Invite_Status__c, Filter_Criteria_Query__c, AsyncApexJobId__c, Last_Processed_Date__c, Last_Processed_State__c, 
                Last_Processed_Criteria_Query__c 
                FROM MA_Community_Events__c 
                WHERE Id = :eventId AND 
                Event_Invite_Status__c = :EVENT_STATUS_CHANGES_PENDING AND 
                Acquisition_Company__r.Status__c IN :EVENT_ACTIVE_COMPANY_STATUS];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create query string for event and return Database.QueryLocator for it.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   Database.QueryLocator   DESCRIPTION (return Database.QueryLocator for events)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Database.QueryLocator getEventQueryLocator() {
        String eventQueryStr = 'SELECT Id, Name, Acquisition_Company__c, All_Day_Event__c, Description__c, End_Date__c, ' + 
                               'End_Datetime__c, End_Time__c, Event_Link__c, Event_Type__c, Location__c, Required_Event__c, ' + 
                               'Start_Date__c, Start_Datetime__c, Start_Time__c, Event_Invite_Status__c, Filter_Criteria_Query__c, ' + 
                               'AsyncApexJobId__c, Last_Processed_Date__c, Last_Processed_State__c, Last_Processed_Criteria_Query__c ' +
                               'FROM MA_Community_Events__c ' +
                               'WHERE Active__c = true AND ' +
                               'Event_Invite_Status__c = :EVENT_STATUS_CHANGES_PENDING AND ' +
                               'Acquisition_Company__r.Status__c IN :EVENT_ACTIVE_COMPANY_STATUS';
        return Database.getQueryLocator(eventQueryStr);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Status on event record when changes are in progress & it's completed.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    event 	   	        DESCRIPTION (Data type MA_Community_Events__c, Event record being published)
    * @param    eventStatus 	   	DESCRIPTION (Data type EventStatus, Enum type to identify the event status)
    * @param    batchJobId 	   	    DESCRIPTION (Data type Id, Id of batch job)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updateEventStatus(MA_Community_Events__c event, EventStatus eventStatus, Id batchJobId) {
        switch on eventStatus {
            when CHANGES_IN_PROGRESS {
                event.Event_Invite_Status__c = EVENT_STATUS_CHANGES_IN_PROGRESS;
            }when CHANGES_COMPLETE {
                event.AsyncApexJobId__c = batchJobId;
                event.Last_Processed_Date__c = Datetime.now();
                event.Event_Invite_Status__c = EVENT_STATUS_CHANGES_COMPLETE;
                event.Last_Processed_State__c = getLastProcessedState(event);
                event.Last_Processed_Criteria_Query__c = event.Filter_Criteria_Query__c;
            }
        }
        List<Database.SaveResult> srList = Database.update(new List<MA_Community_Events__c>{event}, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(srList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * W-10449266 : Method to return JSON serialized state of the event record.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    event 	   	DESCRIPTION (Data type MA_Community_Events__c, Event record being published)
    * @return   String      DESCRIPTION (return JSON serailized form of event record)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getLastProcessedState(MA_Community_Events__c event) {
        Map<String, Object> eventFieldValueMap = new Map<String, Object>();
        for(String eventField : EVENT_DETAIL_FIELDS) {
            eventFieldValueMap.put(eventField, event.get(eventField));
        }
        return JSON.serialize(eventFieldValueMap);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * W-10449266 : Method to determine if the RSVP is needed due to re-publishing an updated event.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    event 	   	DESCRIPTION (Data type MA_Community_Events__c, Updated Event record being re-published)
    * @return   Boolean     DESCRIPTION (return if RSVP is required or not)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Boolean isEventRsvpRequired(MA_Community_Events__c event) {
        Boolean isRsvpRequired = false;

        try {
            Map<String, Object> eventFieldValueMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(event));
            Map<String, Object> lastStateMap = (Map<String, Object>)JSON.deserializeUntyped(event.Last_Processed_State__c);
            
            for(String eventField : eventFieldValueMap.keySet()) {
                String eventFieldKey = eventField.toLowerCase();
                Boolean isValidKey = EVENT_RSVP_FIELDS.contains(eventFieldKey) && lastStateMap.containsKey(eventFieldKey);
                
                isRsvpRequired = isValidKey && lastStateMap.get(eventFieldKey) != eventFieldValueMap.get(eventField);
                if(isRsvpRequired) {
                    break;
                }
            }
        }catch(Exception exType) {
            MA_AbstractLogger.logException(exType, EVENT_RSVP_JSON_PARSE_ERROR);
        }

        return isRsvpRequired;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get total count of attendees record to delete based on deletion type (DeleteAttendees enum).
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    deleteAttendees 	   	DESCRIPTION (Data type DeleteAttendees, Deletion type based on enum value)
    * @param    event 	   	            DESCRIPTION (Data type MA_Community_Events__c, The event record in process)
    * @param    upsertAsyncJobIds 	   	DESCRIPTION (Data type Set<Id>, Set of queueable job Ids to look for records not meeting criteria)
    * @return   Integer                 DESCRIPTION (return count of atttendees records to delete)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Integer getDeleteAttendeesCount(DeleteAttendees deleteAttendees, MA_Community_Events__c event, Set<Id> upsertAsyncJobIds) {
        Integer deleteAttendeesCount = 0;

        switch on deleteAttendees {
            when COMPANY_MISMATCH {
                deleteAttendeesCount = getAttendeesCountWithCompanyMismatch(event);
            }when NOT_MEETING_CRITERIA {
                deleteAttendeesCount = getAttendeesCountWithNotMeetingCriteria(event, upsertAsyncJobIds);
            }
        }

        return deleteAttendeesCount;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get total count of attendees record where company doesn't match with event company.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    event 	   	            DESCRIPTION (Data type MA_Community_Events__c, The event record in process)
    * @return   Integer                 DESCRIPTION (return count of atttendees records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Integer getAttendeesCountWithCompanyMismatch(MA_Community_Events__c event) {
        return [SELECT COUNT() 
                FROM MA_Community_Event_Attendee__c 
                WHERE Community_Event__c = :event.Id AND 
                Acquisition_Contacts__r.Acquisition_Company__c != :event.Acquisition_Company__c];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get total count of attendees record that no longer match with event criteria.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    event 	   	            DESCRIPTION (Data type MA_Community_Events__c, The event record in process)
    * @return   Integer                 DESCRIPTION (return count of atttendees records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Integer getAttendeesCountWithNotMeetingCriteria(MA_Community_Events__c event, Set<Id> upsertAsyncJobIds) {
        return [SELECT COUNT() 
                FROM MA_Community_Event_Attendee__c 
                WHERE Community_Event__c = :event.Id AND 
                AsyncApexJobId__c NOT IN :upsertAsyncJobIds];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get total count of acquisition contacts record related to the company event.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    event 	   	            DESCRIPTION (Data type MA_Community_Events__c, The event record in process)
    * @return   Integer                 DESCRIPTION (return count of acquisition contact records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Integer getEligibleContactsCount(MA_Community_Events__c event) {
        return [SELECT COUNT()
                FROM Acquisition_Contacts__c
                WHERE Acquisition_Company__c = :event.Acquisition_Company__c AND
                Contact_Status__c != :CONTACT_STATUS_CANCELLED];
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get list of attendees record to delete based on deletion type (DeleteAttendees enum).
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    deleteAttendees 	   	                DESCRIPTION (Data type DeleteAttendees, Deletion type based on enum value)
    * @param    event 	   	                            DESCRIPTION (Data type MA_Community_Events__c, The event record in process)
    * @param    upsertAsyncJobIds 	   	                DESCRIPTION (Data type Set<Id>, Set of queueable job Ids to look for records not meeting criteria)
    * @param    thresholdLimit 	   	                    DESCRIPTION (Data type Integer, Threshold limit on records to fetch)
    * @return   List<MA_Community_Event_Attendee__c>    DESCRIPTION (return list of atttendees records to delete)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<MA_Community_Event_Attendee__c> getDeleteAttendeesList(DeleteAttendees deleteAttendees, MA_Community_Events__c event, Set<Id> upsertAsyncJobIds, Integer thresholdLimit) {
        List<MA_Community_Event_Attendee__c> deleteAttendeesList = new List<MA_Community_Event_Attendee__c>();

        switch on deleteAttendees {
            when COMPANY_MISMATCH {
                deleteAttendeesList.addAll(getAttendeesWithCompanyMismatch(event, thresholdLimit));
            }when NOT_MEETING_CRITERIA {
                deleteAttendeesList.addAll(getAttendeesWithNotMeetingCriteria(event, upsertAsyncJobIds, thresholdLimit));
            }
        }

        return deleteAttendeesList;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get list of attendees record where company doesn't match with event company.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    event 	   	                            DESCRIPTION (Data type MA_Community_Events__c, The event record in process)
    * @param    thresholdLimit 	   	                    DESCRIPTION (Data type Integer, Threshold limit on records to fetch)
    * @return   List<MA_Community_Event_Attendee__c>    DESCRIPTION (return list of atttendees records)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<MA_Community_Event_Attendee__c> getAttendeesWithCompanyMismatch(MA_Community_Events__c event, Integer thresholdLimit) {
        return [SELECT Id 
                FROM MA_Community_Event_Attendee__c 
                WHERE Community_Event__c = :event.Id AND 
                Acquisition_Contacts__r.Acquisition_Company__c != :event.Acquisition_Company__c LIMIT :thresholdLimit];
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get list of attendees record that no longer match with event criteria.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    event 	   	                            DESCRIPTION (Data type MA_Community_Events__c, The event record in process)
    * @param    upsertAsyncJobIds 	   	                DESCRIPTION (Data type Set<Id>, Set of queueable job Ids to look for records not meeting criteria)
    * @param    thresholdLimit 	   	                    DESCRIPTION (Data type Integer, Threshold limit on records to fetch)
    * @return   List<MA_Community_Event_Attendee__c>    DESCRIPTION (return list of atttendees records)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @TestVisible
    private static List<MA_Community_Event_Attendee__c> getAttendeesWithNotMeetingCriteria(MA_Community_Events__c event, Set<Id> upsertAsyncJobIds, Integer thresholdLimit) {
        return [SELECT Id 
                FROM MA_Community_Event_Attendee__c 
                WHERE Community_Event__c = :event.Id AND 
                AsyncApexJobId__c NOT IN :upsertAsyncJobIds LIMIT :thresholdLimit];
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to hard delete list of attendees records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    List<MA_Community_Event_Attendee__c>    DESCRIPTION (Data type Integer, List of attendees records)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void bulkHardDeleteAttendees(List<MA_Community_Event_Attendee__c> attendeeList) {
        List<Database.DeleteResult> drList = Database.delete(attendeeList, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(drList, MA_AbstractLogger.BulkLoggerType.DELETE_RESULT);

        if(attendeeList.size() > 0) {
            DataBase.emptyRecycleBin(attendeeList);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get list of eligible contacts based on criteria query or eligibleContacts type (EligibleContacts enum) in case of exception.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    eligibleContacts 	   	        DESCRIPTION (Data type EligibleContacts, EligibleContacts query type based on enum value)
    * @param    event 	   	                    DESCRIPTION (Data type MA_Community_Events__c, The event record in process)
    * @param    lastRecordId 	   	            DESCRIPTION (Data type Id, Id last acquisition contact record fetched in previous job)
    * @param    thresholdLimit 	   	            DESCRIPTION (Data type Integer, Threshold limit on records to fetch)
    * @return   List<Acquisition_Contacts__c>   DESCRIPTION (return List of acquisition contacts records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Acquisition_Contacts__c> getEligibleContactList(EligibleContacts eligibleContacts, MA_Community_Events__c event, Id lastRecordId, Integer thresholdLimit) {
        List<Acquisition_Contacts__c> contactList = new List<Acquisition_Contacts__c>();
        try {
            contactList.addAll(getContactListFromCriteriaQuery(event, lastRecordId, thresholdLimit));
        }catch(Exception exType) {
            MA_AbstractLogger.logException(exType, EVENT_CRITERIA_QUERY_ERROR);
            switch on eligibleContacts {
                when FIRST_BATCH {
                    contactList.addAll(getContactListFirstBatch(event, thresholdLimit));
                }when QUERY_MORE {
                    contactList.addAll(queryMoreContactList(event, lastRecordId, thresholdLimit));
                }
            }
        }
        return contactList;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get acquisition contact record list based on criteria query string.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    event 	   	                    DESCRIPTION (Data type MA_Community_Events__c, The event record in process)
    * @param    lastRecordId 	   	            DESCRIPTION (Data type Id, Id last acquisition contact record fetched in previous job)
    * @param    thresholdLimit 	   	            DESCRIPTION (Data type Integer, Threshold limit on records to fetch)
    * @return   List<Acquisition_Contacts__c>   DESCRIPTION (return List of acquisition contacts records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<Acquisition_Contacts__c> getContactListFromCriteriaQuery(MA_Community_Events__c event, Id lastRecordId, Integer thresholdLimit) {
        String queryStr = event.Filter_Criteria_Query__c;

        if(String.isBlank(queryStr)) {
            Id acqCompanyId = event.Acquisition_Company__c;
            queryStr = 'SELECT Id, (SELECT Id FROM Acquisition_Compensation__r), (SELECT Id FROM Acquisition_Provisioning__r) ' +
                       'FROM Acquisition_Contacts__c ' +
                       'WHERE Contact_Status__c != :CONTACT_STATUS_CANCELLED AND ' +
                       'Acquisition_Company__c = :acqCompanyId';
        }

        queryStr += (lastRecordId == null) ? '' : ' AND Id > :lastRecordId';
        queryStr += ' ORDER BY Id ASC LIMIT :thresholdLimit';
        return (List<Acquisition_Contacts__c>)Database.query(queryStr);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get first batch of acquisition contact record list order by Id.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    event 	   	                    DESCRIPTION (Data type MA_Community_Events__c, The event record in process)
    * @param    thresholdLimit 	   	            DESCRIPTION (Data type Integer, Threshold limit on records to fetch)
    * @return   List<Acquisition_Contacts__c>   DESCRIPTION (return List of acquisition contacts records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @TestVisible
    private static List<Acquisition_Contacts__c> getContactListFirstBatch(MA_Community_Events__c event, Integer thresholdLimit) {
        return [SELECT Id, (SELECT Id FROM Acquisition_Compensation__r), (SELECT Id FROM Acquisition_Provisioning__r)
                FROM Acquisition_Contacts__c
                WHERE Acquisition_Company__c = :event.Acquisition_Company__c AND
                Contact_Status__c != :CONTACT_STATUS_CANCELLED
                ORDER BY Id ASC LIMIT :thresholdLimit];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get subsequent batches of acquisition contact record list order by Id & based on last record fetched in previous job.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    event 	   	                    DESCRIPTION (Data type MA_Community_Events__c, The event record in process)
    * @param    lastRecordId 	   	            DESCRIPTION (Data type Id, Id last acquisition contact record fetched in previous job)
    * @param    thresholdLimit 	   	            DESCRIPTION (Data type Integer, Threshold limit on records to fetch)
    * @return   List<Acquisition_Contacts__c>   DESCRIPTION (return List of acquisition contacts records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @TestVisible
    private static List<Acquisition_Contacts__c> queryMoreContactList(MA_Community_Events__c event, Id lastRecordId, Integer thresholdLimit) {
        return [SELECT Id, (SELECT Id FROM Acquisition_Compensation__r), (SELECT Id FROM Acquisition_Provisioning__r)
                FROM Acquisition_Contacts__c
                WHERE Acquisition_Company__c = :event.Acquisition_Company__c AND
                Contact_Status__c != :CONTACT_STATUS_CANCELLED AND
                Id > :lastRecordId
                ORDER BY Id ASC LIMIT :thresholdLimit];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get filtered eligible acquisition contact list if it has compensation & provisioning record.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    contactList 	   	            DESCRIPTION (Data type List<Acquisition_Contacts__c>, List of acquisition contacts)
    * @return   List<Acquisition_Contacts__c>   DESCRIPTION (return List of eligible acquisition contacts)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Acquisition_Contacts__c> getFilteredEligibleContactList(List<Acquisition_Contacts__c> contactList) {
        List<Acquisition_Contacts__c> eligibleContactList = new List<Acquisition_Contacts__c>();

        for(Acquisition_Contacts__c acqContact : contactList) {
            Boolean hasCompensation = (acqContact.Acquisition_Compensation__r != null && !acqContact.Acquisition_Compensation__r.isEmpty());
            Boolean hasProvisioning = (acqContact.Acquisition_Provisioning__r != null && !acqContact.Acquisition_Provisioning__r.isEmpty());
            if(hasCompensation && hasProvisioning) {
                eligibleContactList.add(acqContact);
            }
        }

        return eligibleContactList;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get list of active user records that meet event criteria based on eligible contacts.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    eligibleContactList 	DESCRIPTION (Data type List<Acquisition_Contacts__c>, list of eligibile acquisition contacts)
    * @return   List<User>              DESCRIPTION (return List of user records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<User> getEligibleUsersFromContacts(List<Acquisition_Contacts__c> eligibleContactList) {
        Set<Id> acquisitionContactIds = (new Map<Id, Acquisition_Contacts__c>(eligibleContactList)).keySet();

        return [SELECT Id, ContactId, Contact.Acquisition_Contacts__c, CreatedDate
                FROM User
                WHERE IsActive = true AND
                Contact.Acquisition_Contacts__c IN :acquisitionContactIds];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get set of Key Identifiers of the event attendees where RSVP is not null.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    eventId 	   	        DESCRIPTION (Data type Id, Id of the event in process)
    * @param    eligibleContactList 	DESCRIPTION (Data type List<Acquisition_Contacts__c>, list of eligibile acquisition contacts)
    * @return   Set<String>             DESCRIPTION (return Set of Key Identifiers)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Set<String> getRSVPedEventKeyIdentifiers(Id eventId, List<Acquisition_Contacts__c> eligibleContactList) {
        Set<Id> acquisitionContactIds = (new Map<Id, Acquisition_Contacts__c>(eligibleContactList)).keySet();
        Set<String> keyIdentifiers = new Set<String>();
        for(MA_Community_Event_Attendee__c attendee : [SELECT Id, Key_Identifier__c 
                                                       FROM MA_Community_Event_Attendee__c
                                                       WHERE Community_Event__c = :eventId AND 
                                                       Acquisition_Contacts__c IN :acquisitionContactIds AND 
                                                       RSVP__c != null]) {
            keyIdentifiers.add(attendee.Key_Identifier__c);
        }

        return keyIdentifiers;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get set of Key Identifiers of the event attendees where RSVP is not null.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    eventId 	   	                DESCRIPTION (Data type Id, Id of the event in process)
    * @param    acquisitionContactId 	        DESCRIPTION (Data type Id, Id of the eligible acquisition contact)
    * @param    asyncJobId 	   	                DESCRIPTION (Data type Id, Id of the current queueable job in process)
    * @param    isRsvpRequired 	   	            DESCRIPTION (Data type Boolean, Flag to determine if RSVP is needed)
    * @return   MA_Community_Event_Attendee__c  DESCRIPTION (return Event Attendee record to be upserted)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static MA_Community_Event_Attendee__c getEventAttendee(Id eventId, Id acquisitionContactId, Id asyncJobId, Boolean isRsvpRequired) {
        String keyIdentifier = String.valueOf(eventId) + String.valueOf(acquisitionContactId);
        MA_Community_Event_Attendee__c eventAttendee = new MA_Community_Event_Attendee__c(Key_Identifier__c = keyIdentifier);
        eventAttendee.Community_Event__c = eventId;
        eventAttendee.AsyncApexJobId__c = asyncJobId;
        eventAttendee.Acquisition_Contacts__c = acquisitionContactId;
        if(isRsvpRequired) {
            eventAttendee.RSVP__c = null;
        }
        return eventAttendee;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to add target object id to SingleEmailMessege and User Id for the CustomNotification.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    messaging 	   	DESCRIPTION (Data type MA_CommunityEventInvitesMessaging, Instance of MA_CommunityEventInvitesMessaging)
    * @param    userId 	        DESCRIPTION (Data type Id, Id of the eligible user for the CustomNotification)
    * @param    contactId 	   	DESCRIPTION (Data type Id, Id of the contact for the SingleEmailMessage)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void addToEmailAndNotificationList(MA_CommunityEventInvitesMessaging messaging, Id userId, Id contactId) {
        messaging.addEventEmailTargetId(contactId);
        messaging.addEventNotificationUserId(userId);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to process SingleEmailMessage & CustomNotification based on threshold limit.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    isLastJob 	   	            DESCRIPTION (Data type Boolean, Flag to know if it's the last queueable job being executed)
    * @param    messaging 	   	            DESCRIPTION (Data type MA_CommunityEventInvitesMessaging, Instance of MA_CommunityEventInvitesMessaging)
    * @param    emailThresholdLimit 	    DESCRIPTION (Data type Integer, Limit on number of SingleEmailMessage to sent at once)
    * @param    notificationThresholdLimit 	DESCRIPTION (Data type Integer, Limit on number of users to send the notification to in one call)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void processEventEmailAndNotifications(Boolean isLastJob, MA_CommunityEventInvitesMessaging messaging, Integer emailThresholdLimit, Integer notificationThresholdLimit) {
        if(messaging.getEventEmailTargetIdsSize() >= emailThresholdLimit) {
            messaging.createAndSendEventEmailMessages(emailThresholdLimit);
        }
        if(messaging.getNotificationUserIdsSize() >= notificationThresholdLimit) {
            messaging.sendEventNotification(notificationThresholdLimit);
        }
        if(isLastJob) {
            processRemainingEventNotifications(messaging, emailThresholdLimit, notificationThresholdLimit);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to process remaining SingleEmailMessage & CustomNotification during last queueable job execution.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    messaging 	   	            DESCRIPTION (Data type MA_CommunityEventInvitesMessaging, Instance of MA_CommunityEventInvitesMessaging)
    * @param    emailThresholdLimit 	    DESCRIPTION (Data type Integer, Limit on number of SingleEmailMessage to sent at once)
    * @param    notificationThresholdLimit 	DESCRIPTION (Data type Integer, Limit on number of users to send the notification to in one call)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void processRemainingEventNotifications(MA_CommunityEventInvitesMessaging messaging, Integer emailThresholdLimit, Integer notificationThresholdLimit) {
        if(messaging.getEventEmailTargetIdsSize() > 0) {
            messaging.createAndSendEventEmailMessages(emailThresholdLimit);
        }
        if(messaging.getNotificationUserIdsSize() > 0) {
            messaging.sendEventNotification(notificationThresholdLimit);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to bulk upsert Event Attendees record based on the eligible contacts identified.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    eventAttendees 	    DESCRIPTION (Data type List<MA_Community_Event_Attendee__c>, List of Event Attendees to bulk upsert)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void bulkUpsertEventAttendees(List<MA_Community_Event_Attendee__c> eventAttendees) {
        List<Database.UpsertResult> urList = Database.upsert(eventAttendees, MA_Community_Event_Attendee__c.Key_Identifier__c, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(urList, MA_AbstractLogger.BulkLoggerType.UPSERT_RESULT);
    }
}