/**
 * ********************** MA Messaging Framework **********************
 * Generic Messaging class for sending out email & custom notification.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         19/02/2022      Chakshu Malhotra        A singleton class created to send SingleEmailMessages & CustomNotification.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public class MA_Messaging {
    
    public enum EmailMessageType {SINGLE_EMAIL, MASS_EMAIL}
    public enum NotificationTargetType {RECORD_ID_TYPE, PAGE_REF_TYPE}

    private static MA_Messaging instance;

    private Integer totalEmailTargetIds;

    private Set<String> notificationUserIds;
    private Map<Id, Set<Id>> emailWhatIdToTargetIdsMap;

    public MessagingConfig messagingConfig {get; private set;}
    public Messaging.CustomNotification notification {get; private set;}
    
    private static final String MESSAGING_NOTIFICATION_ERROR_STR = Label.MA_Messaging_Notification_Error_Str;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold messaging configuration as obtained from MA_Messaging_Configuration__mdt.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class MessagingConfig {
        public String configType {get; private set;}
        public Id emailTemplateId {get; private set;}
        public Id owdEmailAddressId {get; private set;}
        public Id notificationTypeId {get; private set;}
        public Integer emailThreshold {get; private set;}
        public Integer notificationThreshold {get; private set;}
        public String notificationTargetPageRef {get; private set;}
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to retrieve singleton instance of MA_Messaging type.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   MA_Messaging        DESCRIPTION (return instance of MA_Messaging)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static MA_Messaging getInstance(String configType) {
        if(instance == null) {
            instance = new MA_Messaging(configType);
        }
        return instance;
    }

    private MA_Messaging(String configType) {
        this();
        messagingConfig = getMessagingConfig(configType);
    }

    private MA_Messaging() {
        totalEmailTargetIds = 0;
        notificationUserIds = new Set<String>();
        notification = new Messaging.CustomNotification();
        emailWhatIdToTargetIdsMap = new Map<Id, Set<Id>>();
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get MA_Messaging_Configuration__mdt for a configType & create MessagingConfig wrapper instance.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    configType                      DESCRIPTION (Data type String, Messaging Configuration metadata type)
    * @return   MA_Messaging.MessagingConfig    DESCRIPTION (return MessagingConfig wrapper instance)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static MessagingConfig getMessagingConfig(String configType) {
        MA_Messaging_Configuration__mdt configMetadata = MA_MessageProcessingHelper.getMessagingConfigMetadata(configType);

        MessagingConfig messagingConfig = new MessagingConfig();
        messagingConfig.configType = configType;
        messagingConfig.emailThreshold = Integer.valueOf(configMetadata.Email_Threshold__c);
        messagingConfig.notificationTargetPageRef = configMetadata.Notification_Target_Page_Ref__c;
        messagingConfig.notificationThreshold = Integer.valueOf(configMetadata.Notification_Threshold__c);
        messagingConfig.emailTemplateId = MA_MessageProcessingHelper.getEmailTemplateId(configMetadata.Email_Template__c);
        messagingConfig.notificationTypeId = MA_MessageProcessingHelper.getNotificationTypeId(configMetadata.Notification_Type__c);
        messagingConfig.owdEmailAddressId = MA_MessageProcessingHelper.getOrgWideEmailAddressId(configMetadata.OWD_Email_Address__c);

        return messagingConfig;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set notification configuration by providing the notification type id & setting title, body & target id or page reference.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    title 	            DESCRIPTION (Data type String, Title of the custom notificatio type)
    * @param    body 	            DESCRIPTION (Data type String, Body of the custom notificatio type)
    * @param    target 	            DESCRIPTION (Data type String, targetId or targetPageRef of the custom notification type)
    * @param    notification 	    DESCRIPTION (Data type Messaging.CustomNotification, The custom notification)
    * @param    targetType 	        DESCRIPTION (Data type NotificationTargetType, Target type of the notificaition)
    * @param    messagingConfig     DESCRIPTION (Data type MessagingConfig,  MessagingConfig wrapper instance)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void setNotificationConfig(String title, String body, String target, Messaging.CustomNotification notification, NotificationTargetType targetType, MessagingConfig messagingConfig) {
        notification.setBody(body);
        notification.setTitle(title);
        notification.setNotificationTypeId(messagingConfig.notificationTypeId);

        switch on targetType {
            when RECORD_ID_TYPE {
                notification.setTargetId(target);
            }when PAGE_REF_TYPE {
                notification.setTargetPageRef(messagingConfig.notificationTargetPageRef);
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to retrieve the current size of List of Target Email Ids to process Single Email Messages.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   Integer        DESCRIPTION (return curent size of list of target email ids.)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public Integer getEmailTargetIdsSize() {
        return totalEmailTargetIds;
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
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to add contact id to the list of target email messages.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    emailWhatId     DESCRIPTION (Data type Id, whatId of Email Message referred in email template)
    * @param    contactId 	    DESCRIPTION (Data type Id, Id of the contact to send out an email to)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void addEmailTargetId(Id emailWhatId, Id contactId) {
        totalEmailTargetIds++;
        Set<Id> emailTargetIds = emailWhatIdToTargetIdsMap.containsKey(emailWhatId) ? emailWhatIdToTargetIdsMap.get(emailWhatId) : new Set<Id>();
        emailTargetIds.add(contactId);
        emailWhatIdToTargetIdsMap.put(emailWhatId, emailTargetIds);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to add user id to set of user ids to send notification to.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    userId     DESCRIPTION (Data type Id, Id of the user)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void addNotificationUserId(String userId) {
        notificationUserIds.add(userId);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & send List of Email Messages using the email configuration & target email ids.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void createAndSendEmailMessages() {
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        for(Id emailWhatId : emailWhatIdToTargetIdsMap.keySet()) {
            emailMessages.addAll(getEmailMessages(emailWhatId, emailWhatIdToTargetIdsMap.get(emailWhatId)));
        }
        sendEmailMessages(emailMessages);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & return List of SingleEmailMessage using the email configuration & target email ids.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    emailWhatId                         DESCRIPTION (Data type Id, whatId of Email Message referred in email template)
    * @param    emailTargetIds                      DESCRIPTION (Data type Set<Id>, Set of Ids of the contact records)
    * @return   Messaging.SingleEmailMessage        DESCRIPTION (return instance of SingleEmailMessage.)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private List<Messaging.SingleEmailMessage> getEmailMessages(Id emailWhatId, Set<Id> emailTargetIds) {
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        for(Id emailTargetId : emailTargetIds) {
            emailMessages.add(getEmailMessage(emailWhatId, emailTargetId));
        }
        return emailMessages;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to populate SingleEmailMessage using the email configuration & target email id.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    emailWhatId                         DESCRIPTION (Data type Id, whatId of Email Message referred in email template)
    * @param    emailTargetId                       DESCRIPTION (Data type Id, Id of the contact)
    * @return   Messaging.SingleEmailMessage        DESCRIPTION (return instance of SingleEmailMessage.)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Messaging.SingleEmailMessage getEmailMessage(Id emailWhatId, Id emailTargetId) {
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        emailMessage.setSaveAsActivity(false);
        emailMessage.setTargetObjectId(emailTargetId);
        emailMessage.setWhatId(emailWhatId);
        emailMessage.setTemplateId(messagingConfig.emailTemplateId);
        if(messagingConfig.owdEmailAddressId != null) {
            emailMessage.setOrgWideEmailAddressId(messagingConfig.owdEmailAddressId);
        }
        return emailMessage;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to send list of SingleEmailMessage and trace of errors in list of SendEmailResult.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    emailMessages 	    DESCRIPTION (Data type List<Messaging.SingleEmailMessage>, List of SingleEmailMessage to send)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void sendEmailMessages(List<Messaging.SingleEmailMessage> emailMessages) {
        List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(emailMessages, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(emailResults, MA_AbstractLogger.BulkLoggerType.SEND_EMAIL_RESULT);
        clearAndResetEmailTargetIds();
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to clear & reset emailTargetIds.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void clearAndResetEmailTargetIds() {
        totalEmailTargetIds = 0;
        emailWhatIdToTargetIdsMap.clear();
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to send the notification and trace of errors if any.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void sendNotifications() {
        try {
            notification.send(notificationUserIds);
        }catch(Exception exType) {
            MA_AbstractLogger.logException(exType, MESSAGING_NOTIFICATION_ERROR_STR);
        }finally {
            clearAndResetNotificationUserIds();
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to clear & reset notification user ids.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void clearAndResetNotificationUserIds() {
        notificationUserIds.clear();
    }
}