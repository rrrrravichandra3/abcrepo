/**
 * W-10149775
 * Batchable & Schedulable class to publish changes in all events where Event Invite Status is "Changes Pending".
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         07/12/2021      Chakshu Malhotra        Publishes event changes in Pending state. Email & Notification is sent to users who have RSVP'ed the event.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
global class MA_CommunityEventInviteSender implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    private static final Integer THRESHOLD_SIZE = 1;
    private MA_CommunityEventSendInvites.EventInviteSenderConfig batchConfig;

    public MA_CommunityEventInviteSender(MA_CommunityEventSendInvites.EventInviteSenderConfig batchConfig) {
        this.batchConfig = batchConfig;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Database.Batchable interface method to fetch all required event records using Database.QueryLocator.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    batchContext 	   	   DESCRIPTION (Data type Database.BatchableContext, Batch context variable containing Batch Job Id.)
    * @return   Database.QueryLocator  DESCRIPTION (return Database.QueryLocator)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    global Database.QueryLocator start(Database.BatchableContext batchContext) {
        batchConfig.batchJobId = batchContext.getJobId();
        return MA_CommunityEventInviteHelper.getEventQueryLocator();
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Database.Batchable interface method to publish event changes for each event.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    batchContext    DESCRIPTION (Data type Database.BatchableContext, Batch context variable containing Batch Job Id.)
    * @param    events 	   	    DESCRIPTION (Data type List<MA_Community_Events__c>, List of Community Events based on batch chunk size.)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    global void execute (Database.BatchableContext batchContext, List<MA_Community_Events__c> events) {
        // Batch size set to 1; 1 MA_Community_Events__c record per batch chunk execution
        MA_Community_Events__c event = events[0];
        MA_CommunityEventInviteHelper.updateEventStatus(event, MA_CommunityEventInviteHelper.EventStatus.CHANGES_IN_PROGRESS, batchConfig.batchJobId);
        MA_CommunityEventSendInvites.execute(event, batchConfig);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Database.Batchable interface method to process post batch execution logic if any.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    batchContext    DESCRIPTION (Data type Database.BatchableContext, Batch context variable containing Batch Job Id.)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    global void finish(Database.BatchableContext batchContext) {
        // no post-batch execution logic needed.
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Schedulable interface method to schedule MA_CommunityEventInviteSender batch class.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    schedulableContext    DESCRIPTION (Data type SchedulableContext, Schedulable context variable containing Scheduled Job Id.)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    global void execute(SchedulableContext schedulableContext) {
        MA_CommunityEventSendInvites.EventInviteSenderConfig batchConfig = MA_CommunityEventInviteHelper.getBatchConfig();
        MA_CommunityEventInviteSender batchJob = new MA_CommunityEventInviteSender(batchConfig);
        Integer batchSize = Integer.valueOf(batchConfig.batchSize);
        Database.executeBatch(batchJob, (batchSize > 0 && batchSize <= THRESHOLD_SIZE) ? batchSize : THRESHOLD_SIZE);
    }
}