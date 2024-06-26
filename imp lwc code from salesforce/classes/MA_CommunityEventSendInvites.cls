/**
 * W-10149775
 * Abstract class to publish community event changes using Queueable chaining logic.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         07/12/2021      Chakshu Malhotra        Holds Queueable chaining logic to upsert & delete attendees & publish changes based on queueable chunk sizing.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract class MA_CommunityEventSendInvites {
    @TestVisible private static Boolean testJobEnqueued = false;
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold batch configuration.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class EventInviteSenderConfig {
        public Id batchJobId {get; set;}
        public Integer batchSize {get; set;}
        public Id emailTemplateId {get; set;}
        public Id OrgWideEmailAddressId {get; set;}
        public Id notificationTypeId {get; set;}
        public Integer dmlQueueableSize {get; set;}
        public Integer emailQueueableSize {get; set;}
        public Integer notificationQueueableSize {get; set;}
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to create & pass serialized state of event processing in between recursively chained queueable jobs.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    class StatefulQueueable {
        public Boolean isRsvpRequired {get; set;}
        public Integer curentDmlCount {get; set;}
        public Integer totalRecordCount {get; set;}
        public Set<Id> upsertAsyncJobIds {get; set;}
        public Integer totalRecordsQueried {get; set;}
        public MA_Community_Events__c event {get; set;}
        public EventInviteSenderConfig batchConfig {get; set;}
        public MA_CommunityEventInvitesMessaging messaging {get; set;}
        public List<Acquisition_Contacts__c> eligibleContactList {get; set;}
        public List<MA_Community_Event_Attendee__c> deleteRecordList {get; set;}
        public MA_CommunityEventInviteHelper.DeleteAttendees deleteAttendees {get; set;}
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to initialize queueable instance and enqueue it.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    event                 DESCRIPTION (Data type MA_Community_Events__c, Event being processed)
    * @param    batchConfig           DESCRIPTION (Data type EventInviteSenderConfig, Batch configuration)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void execute(MA_Community_Events__c event, EventInviteSenderConfig batchConfig) {
        StatefulQueueable statefulInstance = new StatefulQueueable();
        statefulInstance.event = event;
        statefulInstance.curentDmlCount = 0;
        statefulInstance.batchConfig = batchConfig;

        // W-10449266 : To check if RSVP selection options need to be updated when event is published.
        statefulInstance.isRsvpRequired = String.isBlank(event.Last_Processed_State__c) ? true : MA_CommunityEventInviteHelper.isEventRsvpRequired(event);

        MA_CommunityEventInviteHelper.DeleteAttendees companyMismatch = MA_CommunityEventInviteHelper.DeleteAttendees.COMPANY_MISMATCH;
        Integer deleteRecordCount = MA_CommunityEventInviteHelper.getDeleteAttendeesCount(companyMismatch, event, null);
        statefulInstance.totalRecordCount = (deleteRecordCount > 0) ? deleteRecordCount : MA_CommunityEventInviteHelper.getEligibleContactsCount(event);

        if(deleteRecordCount > 0) {
            statefulInstance.deleteAttendees = companyMismatch;
            enqueueDeleteAttendeesJob(statefulInstance);
        }else {
            enqueueUpsertAttendeesJob(statefulInstance, MA_CommunityEventInviteHelper.EligibleContacts.FIRST_BATCH, null);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get attendees record to delete based on DML record limit (per batch config) and enqueue it in a job.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    statefulInstance        DESCRIPTION (Data type StatefulQueueable, Serialized state of queueable job)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void enqueueDeleteAttendeesJob(StatefulQueueable statefulInstance) {
        if(statefulInstance.deleteRecordList == null) {
            statefulInstance.deleteRecordList = new List<MA_Community_Event_Attendee__c>();
        }
        statefulInstance.deleteRecordList.clear();
        statefulInstance.deleteRecordList.addAll(MA_CommunityEventInviteHelper.getDeleteAttendeesList(statefulInstance.deleteAttendees, statefulInstance.event, statefulInstance.upsertAsyncJobIds, statefulInstance.batchConfig.dmlQueueableSize));
        enqueueJob(new MA_CommunityEventDeleteAttendees(statefulInstance, MA_CommunityEventDeleteAttendeesFinalizer.class));
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get attendees record to upsert based on DML record limit (per batch config) and enqueue it in a job.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    statefulInstance        DESCRIPTION (Data type StatefulQueueable, Serialized state of queueable job)
    * @param    eligibleContacts        DESCRIPTION (Data type MA_CommunityEventInviteHelper.EligibleContacts, Enum to specify if it's the initial list of contacts or subsequent)
    * @param    lastRecordId            DESCRIPTION (Data type Id, last record Id of contact from the previous list of eligible contacts)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void enqueueUpsertAttendeesJob(StatefulQueueable statefulInstance, MA_CommunityEventInviteHelper.EligibleContacts eligibleContacts, Id lastRecordId) {
        if(statefulInstance.eligibleContactList == null) {
            statefulInstance.totalRecordsQueried = 0;
            statefulInstance.upsertAsyncJobIds = new Set<Id>();
            statefulInstance.eligibleContactList = new List<Acquisition_Contacts__c>();
            statefulInstance.messaging = MA_CommunityEventInvitesMessaging.getInstance();
            statefulInstance.messaging.setEmailConfig(statefulInstance.event.Id, statefulInstance.batchConfig.emailTemplateId, statefulInstance.batchConfig.OrgWideEmailAddressId);
            statefulInstance.messaging.setEventNotification(statefulInstance.batchConfig.notificationTypeId, statefulInstance.event.Name);
        }
        statefulInstance.eligibleContactList.clear();
        statefulInstance.eligibleContactList.addAll(MA_CommunityEventInviteHelper.getEligibleContactList(eligibleContacts, statefulInstance.event, lastRecordId, statefulInstance.batchConfig.dmlQueueableSize));
        enqueueJob(new MA_CommunityEventUpsertAttendees(statefulInstance, MA_CommunityEventUpsertAttendeesFinalizer.class));
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to enqueue the queueable job if it's within governor limits.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    asyncJob        DESCRIPTION (Data type Queueable, Queueable job instance)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void enqueueJob(Queueable asyncJob) {
        if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
            System.enqueueJob(asyncJob);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to delete event attendees records.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    class MA_CommunityEventDeleteAttendees implements Queueable {
        private StatefulQueueable jobParams;
        private Type queueableFinalizerImpl;

        public MA_CommunityEventDeleteAttendees(StatefulQueueable jobParams, Type queueableFinalizerImpl) {
            this.jobParams = jobParams;
            this.queueableFinalizerImpl = queueableFinalizerImpl;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to bulk hard delete event attendees records that do not meet criteria for event invite.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void execute(QueueableContext qContext) {
            MA_CommunityEventInviteHelper.bulkHardDeleteAttendees(jobParams.deleteRecordList);
            jobParams.curentDmlCount += jobParams.deleteRecordList.size();

            QueueableFinalizer queueableFinalizer = (QueueableFinalizer)queueableFinalizerImpl.newInstance();

            if(jobParams.curentDmlCount < jobParams.totalRecordCount && !jobParams.deleteRecordList.isEmpty()) {
                queueableFinalizer.handleSingleJobCompletion(jobParams);
            }else if(jobParams.deleteAttendees == MA_CommunityEventInviteHelper.DeleteAttendees.COMPANY_MISMATCH) {
                queueableFinalizer.handleAllJobsCompletion(jobParams);
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to upsert event attendees records & send SingleEmailMessages & CustomNotification to eligible attendees.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    class MA_CommunityEventUpsertAttendees implements Queueable {
        private StatefulQueueable jobParams;
        private Type queueableFinalizerImpl;

        public MA_CommunityEventUpsertAttendees(StatefulQueueable jobParams, Type queueableFinalizerImpl) {
            this.jobParams = jobParams;
            this.queueableFinalizerImpl = queueableFinalizerImpl;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to bulk upsert event attendees records & send email messages & notification to eligible attendees.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void execute(QueueableContext qContext) {
            jobParams.totalRecordsQueried += jobParams.eligibleContactList.size();

            List<Acquisition_Contacts__c> filteredEligibleContactList = MA_CommunityEventInviteHelper.getFilteredEligibleContactList(jobParams.eligibleContactList);
            List<User> eligibleUsers = filteredEligibleContactList.isEmpty() ? new List<User>() : MA_CommunityEventInviteHelper.getEligibleUsersFromContacts(filteredEligibleContactList);
            
            Id asyncJobId = qContext.getJobId();
            jobParams.upsertAsyncJobIds.add(asyncJobId);

            List<MA_Community_Event_Attendee__c> eventAttendees = new List<MA_Community_Event_Attendee__c>();
            Set<String> rsvpedKeyIdentifiers = MA_CommunityEventInviteHelper.getRSVPedEventKeyIdentifiers(jobParams.event.Id, filteredEligibleContactList);
            for(User eligibleUser : eligibleUsers) {
                MA_Community_Event_Attendee__c eventAttendee = MA_CommunityEventInviteHelper.getEventAttendee(jobParams.event.Id, eligibleUser.Contact.Acquisition_Contacts__c, asyncJobId, jobParams.isRsvpRequired);
                eventAttendees.add(eventAttendee);
                if(rsvpedKeyIdentifiers.contains(eventAttendee.Key_Identifier__c)) {
                    MA_CommunityEventInviteHelper.addToEmailAndNotificationList(jobParams.messaging, eligibleUser.Id, eligibleUser.ContactId);
                }
            }
            
            MA_CommunityEventInviteHelper.bulkUpsertEventAttendees(eventAttendees);
            jobParams.curentDmlCount += eligibleUsers.size();

            QueueableFinalizer queueableFinalizer = (QueueableFinalizer)queueableFinalizerImpl.newInstance();

            if(jobParams.totalRecordsQueried < jobParams.totalRecordCount && jobParams.eligibleContactList.size() > 0) {
                queueableFinalizer.handleSingleJobCompletion(jobParams);
            }else {
                queueableFinalizer.handleAllJobsCompletion(jobParams);
            }
        }
    }   

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Interface to attach final action to queuable execution for each chained job as well as completion of all chained jobs.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private interface QueueableFinalizer {
        void handleAllJobsCompletion(StatefulQueueable jobParams);
        void handleSingleJobCompletion(StatefulQueueable jobParams);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Abstract class to provide QueueableFinalizer implementation & common logic for its sub-classes.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private abstract class AbstractQueueableFinalizer implements QueueableFinalizer {
        public abstract void handleAllJobsCompletion(StatefulQueueable jobParams);
        public abstract void handleSingleJobCompletion(StatefulQueueable jobParams);

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to reset few attributes of StatefulQueueable upon completion of all chained jobs of either of the Queueable type.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams    DESCRIPTION (Data type StatefulQueueable, Serialized state of queueable job)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        protected void resetJobParams(StatefulQueueable jobParams) {
            jobParams.curentDmlCount = 0;
            jobParams.totalRecordCount = 0;
            jobParams.deleteRecordList?.clear();
            jobParams.eligibleContactList?.clear();
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of AbstractQueueableFinalizer to provide QueueableFinalizer implementation for MA_CommunityEventDeleteAttendees queueable job.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class MA_CommunityEventDeleteAttendeesFinalizer extends AbstractQueueableFinalizer {
        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on each single job completion; recursively adds a chained job to fetch & delete next set of event attendees.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams    DESCRIPTION (Data type StatefulQueueable, Serialized state of queueable job)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion(StatefulQueueable jobParams) {
            MA_CommunityEventSendInvites.enqueueDeleteAttendeesJob(jobParams);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on all jobs completion; adds a chained job to upsert attendees if attendees were deleted due to company mismatch.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams    DESCRIPTION (Data type StatefulQueueable, Serialized state of queueable job)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleAllJobsCompletion(StatefulQueueable jobParams) {
            super.resetJobParams(jobParams);
            jobParams.totalRecordCount = MA_CommunityEventInviteHelper.getEligibleContactsCount(jobParams.event);
            if(!testJobEnqueued) {
                MA_CommunityEventSendInvites.enqueueUpsertAttendeesJob(jobParams, MA_CommunityEventInviteHelper.EligibleContacts.FIRST_BATCH, null);
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of AbstractQueueableFinalizer to provide QueueableFinalizer implementation for MA_CommunityEventUpsertAttendees queueable job.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class MA_CommunityEventUpsertAttendeesFinalizer extends AbstractQueueableFinalizer {
        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on each single job completion; recursively adds a chained job to fetch & upsert next set of event attendees.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams    DESCRIPTION (Data type StatefulQueueable, Serialized state of queueable job)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion(StatefulQueueable jobParams) {
            MA_CommunityEventInviteHelper.processEventEmailAndNotifications(false, jobParams.messaging, jobParams.batchConfig.emailQueueableSize, jobParams.batchConfig.notificationQueueableSize);
            Integer lastEligibleContactIndex = jobParams.eligibleContactList.size() - 1;
            Id lastRecordId = jobParams.eligibleContactList.get(lastEligibleContactIndex).Id;
            MA_CommunityEventSendInvites.enqueueUpsertAttendeesJob(jobParams, MA_CommunityEventInviteHelper.EligibleContacts.QUERY_MORE, lastRecordId);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on all jobs completion; adds a chained job to delete attendees that do not meet criteria.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams    DESCRIPTION (Data type StatefulQueueable, Serialized state of queueable job)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleAllJobsCompletion(StatefulQueueable jobParams) {
            MA_CommunityEventInviteHelper.processEventEmailAndNotifications(true, jobParams.messaging, jobParams.batchConfig.emailQueueableSize, jobParams.batchConfig.notificationQueueableSize);
            MA_CommunityEventInviteHelper.updateEventStatus(jobParams.event, MA_CommunityEventInviteHelper.EventStatus.CHANGES_COMPLETE, jobParams.batchConfig.batchJobId);
            super.resetJobParams(jobParams);
            
            jobParams.deleteAttendees = MA_CommunityEventInviteHelper.DeleteAttendees.NOT_MEETING_CRITERIA;
            jobParams.totalRecordCount = MA_CommunityEventInviteHelper.getDeleteAttendeesCount(jobParams.deleteAttendees, jobParams.event, jobParams.upsertAsyncJobIds);
            if(!testJobEnqueued) {
                enqueueDeleteAttendeesJob(jobParams);
            }
        }
    }
}