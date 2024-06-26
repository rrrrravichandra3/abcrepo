/**
 * W-10449458
 * Helper class to auto-enrol or remove acquisition contacts from community events.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         02/02/2022      Chakshu Malhotra        Holds utility methods to perform SOQL queries or DML operations during auto-enrolment process.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public class MA_CommunityEventAutoEnrollerHelper {

    private static final String CONTACT_STATUS_CANCELLED = Label.MA_Contact_Status_Cancelled;
    private static final String EVENT_AUTO_ENROL_CRITERIA_QUERY_ERROR = Label.MA_Event_Auto_Enrol_Criteria_Query_Parse_Error;
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch List of published community events for a given acquisition company Id.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId                    DESCRIPTION (Data type Id, Id of acquisition company)
    * @return   List<MA_Community_Events__c>    DESCRIPTION (return List of published community events for an acquisition company)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<MA_Community_Events__c> getCommunityEvents(Id acqCompanyId) {
        return [SELECT Id, Acquisition_Company__c, Last_Processed_Criteria_Query__c 
                FROM MA_Community_Events__c 
                WHERE Last_Processed_Date__c != null AND
                Acquisition_Company__c = :acqCompanyId];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create Set of eligible acquisition Ids that need to be auto-enroled for the community event.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    event               DESCRIPTION (Data type MA_Community_Events__c, Event record to be enroled in)
    * @param    acqContactIds       DESCRIPTION (Data type Set<String>, Set of acquisition contact Ids)
    * @return   Set<String>         DESCRIPTION (return Set of eligible acquisition contact Ids to be auto-enroled for the event)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Set<String> getEligibleContactIds(MA_Community_Events__c event, Set<String> acqContactIds) {
        List<Acquisition_Contacts__c> contactList = new List<Acquisition_Contacts__c>();

        try {
            contactList.addAll(getContactListFromCriteriaQuery(event, acqContactIds));
        }catch(Exception exType) {
            MA_AbstractLogger.logException(exType, EVENT_AUTO_ENROL_CRITERIA_QUERY_ERROR);
            contactList.addAll(getContactList(event, acqContactIds));
        }

        return getEligibleContactIds(contactList);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch List of eligible acquisition contacts as per the last published filter criteria of the community event.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    event                           DESCRIPTION (Data type MA_Community_Events__c, Event record to be enroled in)
    * @param    acqContactIds                   DESCRIPTION (Data type Set<String>, Set of acquisition contact Ids)
    * @return   List<Acquisition_Contacts__c>   DESCRIPTION (return List of eligible acquisition contacts as per last published state)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<Acquisition_Contacts__c> getContactListFromCriteriaQuery(MA_Community_Events__c event, Set<String> acqContactIds) {
        String queryStr = event.Last_Processed_Criteria_Query__c;

        if(String.isBlank(queryStr)) {
            Id acqCompanyId = event.Acquisition_Company__c;
            queryStr = 'SELECT Id, (SELECT Id FROM Acquisition_Compensation__r), (SELECT Id FROM Acquisition_Provisioning__r) ' +
                       'FROM Acquisition_Contacts__c ' +
                       'WHERE Contact_Status__c != :CONTACT_STATUS_CANCELLED AND ' +
                       'Acquisition_Company__c = :acqCompanyId';
        }

        queryStr += ' AND Id IN :acqContactIds';
        return (List<Acquisition_Contacts__c>)Database.query(queryStr);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch List of eligible acquisition contacts if criteria query is blank or results in runtime-exception.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    event                           DESCRIPTION (Data type MA_Community_Events__c, Event record to be enroled in)
    * @param    acqContactIds                   DESCRIPTION (Data type Set<String>, Set of acquisition contact Ids)
    * @return   List<Acquisition_Contacts__c>   DESCRIPTION (return List of eligible acquisition contacts)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @TestVisible
    private static List<Acquisition_Contacts__c> getContactList(MA_Community_Events__c event, Set<String> acqContactIds) {
        return [SELECT Id, (SELECT Id FROM Acquisition_Compensation__r), (SELECT Id FROM Acquisition_Provisioning__r) 
                FROM Acquisition_Contacts__c 
                WHERE Id IN :acqContactIds AND 
                Contact_Status__c != :CONTACT_STATUS_CANCELLED AND
                Acquisition_Company__c = :event.Acquisition_Company__c];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to return Set of eligible acquisition contact Ids based on if its linked User record is Active.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    contactList     DESCRIPTION (Data type List<Acquisition_Contacts__c>, List of acquisition contact records)
    * @return   Set<String>     DESCRIPTION (return Set of eligible acquisition contacts)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Set<String> getEligibleContactIds(List<Acquisition_Contacts__c> contactList) {
        List<Acquisition_Contacts__c> eligibleAcqContacts = MA_CommunityEventInviteHelper.getFilteredEligibleContactList(contactList);
        Set<String> acqContactIds = new Set<String>();

        for(Acquisition_Contacts__c eligibleAcqContact : eligibleAcqContacts) {
            acqContactIds.add(eligibleAcqContact.Id);
        }

        return acqContactIds;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to enrol all eligible acquisition contacts to the community event.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    eventId         DESCRIPTION (Data type Id, Id of community event record)
    * @param    asyncJobId      DESCRIPTION (Data type Id, Id of the current queueable job in process)
    * @param    acqContactIds   DESCRIPTION (Data type Set<String>, Set of eligible acquisition contact Ids)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void enrolToCommunityEvent(Id eventId, Id asyncJobId, Set<String> acqContactIds) {
        List<MA_Community_Event_Attendee__c> eventAttendees = new List<MA_Community_Event_Attendee__c>();

        for(String acqContactId : acqContactIds) {
            eventAttendees.add(MA_CommunityEventInviteHelper.getEventAttendee(eventId, Id.valueOf(acqContactId), asyncJobId, false));
        }

        MA_CommunityEventInviteHelper.bulkUpsertEventAttendees(eventAttendees);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to remove all in-eligible acquisition contacts from the community event.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    eventId               DESCRIPTION (Data type Id, Id of community event record)
    * @param    eligibleContactIds    DESCRIPTION (Data type Set<String>, Set of eligible acquisition contact Ids)
    * @param    allAcqContactIds      DESCRIPTION (Data type Set<String>, Set of all acquisition contact Ids as per platform event record)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void removeIneligibleEventEnrolment(Id eventId, Set<String> eligibleContactIds, Set<String> allAcqContactIds) {
        Set<String> ineligibleContactIds = allAcqContactIds.clone();
        ineligibleContactIds.removeAll(eligibleContactIds);
        List<MA_Community_Event_Attendee__c> ineligibleEventAttendees = getAttendeesNotMeetingCriteria(eventId, ineligibleContactIds);
        MA_CommunityEventInviteHelper.bulkHardDeleteAttendees(ineligibleEventAttendees);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch all in-eligible event attendee records for removal.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    eventId                                 DESCRIPTION (Data type Id, Id of community event record)
    * @param    ineligibleContactIds                    DESCRIPTION (Data type Set<String>, Set of in-eligible acquisition contact Ids)
    * @return   List<MA_Community_Event_Attendee__c>    DESCRIPTION (return List of in-eligible event attendee records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<MA_Community_Event_Attendee__c> getAttendeesNotMeetingCriteria(Id eventId, Set<String> ineligibleContactIds) {
        return [SELECT Id 
                FROM MA_Community_Event_Attendee__c 
                WHERE Community_Event__c = :eventId AND 
                Acquisition_Contacts__c IN :ineligibleContactIds];
    }
}