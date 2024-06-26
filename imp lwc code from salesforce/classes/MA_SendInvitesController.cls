/**
 * W-10149775
 * Controller class for maCommunityEventSendInvites (LWC component).
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         13/12/2021      Chakshu Malhotra        To execute queueable to send out invites to eligible event attendees.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_SendInvitesController {
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method updates Status to "Changes In Progress" and enqueues job to update event changes in community.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    eventId 	   			   DESCRIPTION (Data type String, Id of the community event)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static void executeEventInviteSender(String eventId) {
        List<MA_Community_Events__c> eventList = MA_CommunityEventInviteHelper.getEventDetail(eventId);
        if(!eventList.isEmpty()) {
            MA_CommunityEventSendInvites.EventInviteSenderConfig batchConfig = MA_CommunityEventInviteHelper.getBatchConfig();
            MA_CommunityEventInviteHelper.updateEventStatus(eventList[0], MA_CommunityEventInviteHelper.EventStatus.CHANGES_IN_PROGRESS, null);
            MA_CommunityEventSendInvites.execute(eventList[0], batchConfig);
        }
    }
}