/**
 * W-10149775
 * Messaging class for sending out email & custom notification to event attendees who have RSVP'ed the event.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         06/12/2021      Chakshu Malhotra        A singleton class created to send SingleEmailMessages & CustomNotification to event attendees.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public class MA_CommunityEventInvitesMessaging {
    
    private static MA_CommunityEventInvitesMessaging instance;

    private Id eventId;
    private Id emailTemplateId;
    private Id OrgWideEmailAddressId;

    private Set<Id> emailTargetIds;
    private Set<String> notificationUserIds;
    private Messaging.CustomNotification eventNotification;

    private static final String EVENT_UPDATED_STR = Label.MA_Event_Updated_Str;
    private static final String EVENT_TARGET_PAGE_REF = Label.MA_Event_Target_Page_Ref;
    private static final String EVENT_NOTIFICATION_TITLE = Label.MA_Event_Notification_Title;
    private static final String EVENT_NOTIFICATION_ERROR_STR = Label.MA_Event_Notification_Error_Str;

    private MA_CommunityEventInvitesMessaging() {
        emailTargetIds = new Set<Id>();
        notificationUserIds = new Set<String>();
        eventNotification = new Messaging.CustomNotification();
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to retrieve singleton instance of MA_CommunityEventInvitesMessaging type.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   MA_CommunityEventInvitesMessaging        DESCRIPTION (return instance of MA_CommunityEventInvitesMessaging)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static MA_CommunityEventInvitesMessaging getInstance() {
        if(instance == null) {
            instance = new MA_CommunityEventInvitesMessaging();
        }
        return instance;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to retrieve the current size of List of Target Email Ids to process Single Email Messages.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   Integer        DESCRIPTION (return curent size of list of target email ids.)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public Integer getEventEmailTargetIdsSize() {
        return emailTargetIds.size();
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to retrieve the current size of List of User Ids to send out Custom Notification to.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   Integer        DESCRIPTION (return curent size of list of user ids.)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public Integer getNotificationUserIdsSize() {
        return notificationUserIds.size();
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set email configuration by providing eventId as whatId & email template id.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    eventId 	        DESCRIPTION (Data type Id, Id of the community event being processed)
    * @param    emailTemplateId 	DESCRIPTION (Data type Id, Id of the email template used to send email to eligible contacts)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void setEmailConfig(Id eventId, Id emailTemplateId, Id OrgWideEmailAddressId) {
        this.eventId = eventId;
        this.emailTemplateId = emailTemplateId;
        this.OrgWideEmailAddressId = OrgWideEmailAddressId;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set notification configuration by providing the notification type id & setting title, body & target page reference.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    typeId 	    DESCRIPTION (Data type Id, Id of the notification type)
    * @param    eventName 	DESCRIPTION (Data type String, Name of the community event in process)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void setEventNotification(Id typeId, String eventName) {
        eventNotification.setNotificationTypeId(typeId);
        eventNotification.setTitle(EVENT_NOTIFICATION_TITLE);
        eventNotification.setTargetPageRef(EVENT_TARGET_PAGE_REF);
        eventNotification.setBody(eventName + ' ' + EVENT_UPDATED_STR);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to add contact id to the list of target email ids.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    contactId 	    DESCRIPTION (Data type Id, Id of the eligible contact to send out an email to)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void addEventEmailTargetId(Id contactId) {
        emailTargetIds.add(contactId);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & send SingleEmailMessage using the email configuration & target email ids.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    emailThresholdLimit 	    DESCRIPTION (Data type Integer, Limit on number of SingleEmailMessage to sent at once)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void createAndSendEventEmailMessages(Integer emailThresholdLimit) {
        Set<Id> aboveLimitTargetIds = new Set<Id>();
        List<Id> eventTargetIdList = new List<Id> (emailTargetIds);
        List<Messaging.SingleEmailMessage> eventEmailMessages = new List<Messaging.SingleEmailMessage>();
        
        for(Integer emailMsgIndex=0; emailMsgIndex < eventTargetIdList.size(); emailMsgIndex++) {
            if(eventEmailMessages.size() < emailThresholdLimit) {
                eventEmailMessages.add(getEventEmailMessage(eventTargetIdList[emailMsgIndex]));
            }else {
                aboveLimitTargetIds.add(eventTargetIdList[emailMsgIndex]);
            }
        }

        sendEventEmailMessages(eventEmailMessages, aboveLimitTargetIds);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to populate SingleEmailMessage using the email configuration & target email id.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   Messaging.SingleEmailMessage        DESCRIPTION (return instance of SingleEmailMessage.)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Messaging.SingleEmailMessage getEventEmailMessage(Id emailTargetId) {
        Messaging.SingleEmailMessage eventEmailMessage = new Messaging.SingleEmailMessage();
        eventEmailMessage.setWhatId(eventId);
        eventEmailMessage.setSaveAsActivity(false);
        eventEmailMessage.setTemplateId(emailTemplateId);
        eventEmailMessage.setOrgWideEmailAddressId(OrgWideEmailAddressId);
        eventEmailMessage.setTargetObjectId(emailTargetId);
        return eventEmailMessage;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to send list of SingleEmailMessage and trace of errors in list of SendEmailResult.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    eventEmailMessages 	    DESCRIPTION (Data type List<Messaging.SingleEmailMessage>, List of SingleEmailMessage to send)
    * @param    aboveLimitTargetIds     DESCRIPTION (Data type Set<Id>, Set of target email ids beyond the email threshold limit)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void sendEventEmailMessages(List<Messaging.SingleEmailMessage> eventEmailMessages, Set<Id> aboveLimitTargetIds) {
        List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(eventEmailMessages, false); // to allow partial success
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(emailResults, MA_AbstractLogger.BulkLoggerType.SEND_EMAIL_RESULT);
        clearAndResetEmailTargetIds(aboveLimitTargetIds);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to clear emailTargetIds and add all additional target email ids to it.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    aboveLimitTargetIds     DESCRIPTION (Data type Set<Id>, Set of target email ids beyond the email threshold limit)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void clearAndResetEmailTargetIds(Set<Id> aboveLimitTargetIds) {
        emailTargetIds.clear();
        emailTargetIds.addAll(aboveLimitTargetIds);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to add user id to set of user ids to send notification to.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    userId     DESCRIPTION (Data type Id, Id of the user)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void addEventNotificationUserId(Id userId) {
        notificationUserIds.add(String.valueOf(userId));
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to send CustomNotification using the notification configuration & user ids.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    notificationThresholdLimit 	DESCRIPTION (Data type Integer, Limit on number of user ids to send out the notification to)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void sendEventNotification(Integer notificationThresholdLimit) {
        Set<String> userIds = new Set<String>();
        Set<String> aboveLimitUserIds = new Set<String>();
        List<String> notificationUserIdList = new List<String> (notificationUserIds);
        
        for(Integer userIndex=0; userIndex < notificationUserIdList.size(); userIndex++) {
            if(userIds.size() < notificationThresholdLimit) {
                userIds.add(notificationUserIdList[userIndex]);
            }else {
                aboveLimitUserIds.add(notificationUserIdList[userIndex]);
            }
        }

        sendEventNotification(userIds, aboveLimitUserIds);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to send the notification and trace of errors if any.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    userIds 	          DESCRIPTION (Data type Set<String>, Set of user ids to send notification to)
    * @param    aboveLimitUserIds     DESCRIPTION (Data type Set<Id>, Set of user ids beyond the notification threshold limit)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void sendEventNotification(Set<String> userIds, Set<String> aboveLimitUserIds) {    
        try {
            eventNotification.send(userIds);
        }catch(Exception exType) {
            MA_AbstractLogger.logException(exType, EVENT_NOTIFICATION_ERROR_STR);
        }finally {
            clearAndResetNotificationUserIds(aboveLimitUserIds);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to clear user ids and add all additional user ids to it.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    aboveLimitUserIds     DESCRIPTION (Data type Set<Id>, Set of user ids beyond the notification threshold limit)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void clearAndResetNotificationUserIds(Set<String> aboveLimitUserIds) {
        notificationUserIds.clear();
        notificationUserIds.addAll(aboveLimitUserIds);
    }
}