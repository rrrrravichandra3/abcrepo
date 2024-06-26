/**
 * *************************************** MA Messaging Framework *****************************************
 * Abstract class to process email messages & notifications based on Messaging Configuration metadata type.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         19/02/2022      Chakshu Malhotra        Holds re-usable queueable chaining logic to send email messages & custom notifications.
 * v2.0         07/03/2022      Chakshu Malhotra        Handles nextJob (Queueable) upon completion of Message processing.
 * v3.0         11/04/2022      Chakshu Malhotra        Handles Email processing for multiple WhatId records during chained execution of Message processing.
 * v4.0         30/06/2022      Chakshu Malhotra        Handles logic to process Bulk Notifications or notifications with dynamic title / body.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract class MA_MessageProcessing {

    public enum NotificationType {SINGLE_NOTIFICATION, BULK_NOTIFICATION}
    public enum ExecutionType {EMAIL_JOB, NOTIFICATION_JOB, SINGLE_CHAINED_JOB, MULTIPLE_CHAINED_JOB}
    
    @TestVisible private static Boolean testJobEnqueued = false;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold details to process CustomNotification with different title, body and set of userIds in each Queueable execution.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    class BulkNotification {
        public String body;
        public String title;
        public List<String> userIds;

        public BulkNotification(String body, String title, List<String> userIds) {
            this.body = body;
            this.title = title;
            this.userIds = userIds;
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to instantiate BulkNotification with body, title & userIds and add it to bulkNotifications list.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    title           DESCRIPTION (Data type String, Title of the custom notification)
    * @param    body            DESCRIPTION (Data type String, Body of the custom notification)
    * @param    userIds         DESCRIPTION (Data type List<String>, List of User Ids to send Custom Notifications to)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void addBulkNotification(String title, String body, List<String> userIds) {
        StatefulQueueable statefulInstance = getStatefulQueueable();
        statefulInstance.bulkNotifications.add(new BulkNotification(body, title, userIds));
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to create & pass serialized state of messaging across recursively chained queueable jobs.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    class StatefulQueueable {
        public Queueable nextJob {get; set;}
        public MA_Messaging messaging {get; set;}
        public ExecutionType executionType {get; set;}

        public Integer totalEmails {get; set;}
        public Integer currentEmailCount {get; set;}

        public Integer totalNotifications {get; set;}
        public Integer currentNotificationCount {get; set;}
        
        public Integer nextWhatIdIndex {get; set;}
        public Integer nextTargetIdIndex {get; set;}
        public Integer nextBulkNotificationIndex {get; set;}

        public NotificationType notificationType {get; set;}
        public MA_Messaging.NotificationTargetType targetType {get; set;}

        public List<BulkNotification> bulkNotifications {get; set;}

        public List<String> userIds {get; set;}
        public List<Id> emailWhatIds {get; set;}
        public Map<Id, Set<Id>> emailWhatIdToTargetIdsMap {get; set;}
    }

    private static StatefulQueueable statefulInstance;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & return instance of StatefulQueueable.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   StatefulQueueable       DESCRIPTION (return instance of StatefulQueueable)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static StatefulQueueable getStatefulQueueable() {
        if(statefulInstance == null) {
            statefulInstance = new StatefulQueueable();

            statefulInstance.totalEmails = 0;
            statefulInstance.currentEmailCount = 0;

            statefulInstance.totalNotifications = 0;
            statefulInstance.currentNotificationCount = 0;

            statefulInstance.nextWhatIdIndex = 0;
            statefulInstance.nextTargetIdIndex = 0;
            statefulInstance.nextBulkNotificationIndex = 0;

            statefulInstance.userIds = new List<String>();
            statefulInstance.emailWhatIds = new List<Id>();
            statefulInstance.bulkNotifications = new List<BulkNotification>();
            statefulInstance.emailWhatIdToTargetIdsMap = new Map<Id, Set<Id>>();
        }
        return statefulInstance;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to setup email messaging configuration.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    configType                  DESCRIPTION (Data type String, Messaging Configuration metadata type)
    * @param    emailWhatIdToTargetIdsMap   DESCRIPTION (Data type Map, Map of Email WhatId to Set of Contact Ids to send Email Messages to)
    * @param    messageType                 DESCRIPTION (Data type MA_Messaging.EmailMessageType, EmailMessageType enum type)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void initEmailMessaging(String configType, Map<Id, Set<Id>> emailWhatIdToTargetIdsMap, MA_Messaging.EmailMessageType messageType) {
        StatefulQueueable statefulInstance = getStatefulQueueable();
        statefulInstance.messaging = MA_Messaging.getInstance(configType);

        if(emailWhatIdToTargetIdsMap != null && emailWhatIdToTargetIdsMap.size() > 0) {
            statefulInstance.emailWhatIdToTargetIdsMap.putAll(emailWhatIdToTargetIdsMap);
            initEmailMessaging(statefulInstance);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to setup email messaging configuration.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    configType          DESCRIPTION (Data type String, Messaging Configuration metadata type)
    * @param    emailWhatId         DESCRIPTION (Data type String, whatId of Email Message referred in email template)
    * @param    emailTargetIds      DESCRIPTION (Data type Set<Id>, Set of Contact Ids to send Email Messages to)
    * @param    messageType         DESCRIPTION (Data type MA_Messaging.EmailMessageType, EmailMessageType enum type)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void initEmailMessaging(String configType, String emailWhatId, Set<Id> emailTargetIds, MA_Messaging.EmailMessageType messageType) {
        StatefulQueueable statefulInstance = getStatefulQueueable();
        statefulInstance.messaging = MA_Messaging.getInstance(configType);

        if(emailTargetIds != null && emailTargetIds.size() > 0) {
            statefulInstance.emailWhatIdToTargetIdsMap.put(Id.valueOf(emailWhatId), emailTargetIds);
            initEmailMessaging(statefulInstance);
        }
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to setup email messaging configuration.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    statefulInstance    DESCRIPTION (Data type StatefulQueueable, Serialized state of messaging maintained across queueable jobs)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void initEmailMessaging(StatefulQueueable statefulInstance) {
        for(Id emailWhatId : statefulInstance.emailWhatIdToTargetIdsMap.keySet()) {
            statefulInstance.totalEmails += statefulInstance.emailWhatIdToTargetIdsMap.get(emailWhatId).size();
        }
        statefulInstance.emailWhatIds.addAll(statefulInstance.emailWhatIdToTargetIdsMap.keySet());
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to setup custom notification messaging configuration.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    configType      DESCRIPTION (Data type String, Messaging Configuration metadata type)
    * @param    title           DESCRIPTION (Data type String, Title of the custom notification)
    * @param    body            DESCRIPTION (Data type String, Body of the custom notification)
    * @param    target          DESCRIPTION (Data type String, Notification target record Id or target page reference)
    * @param    userIds         DESCRIPTION (Data type Set<String>, Set of User Ids to send Custom Notifications to)
    * @param    targetType      DESCRIPTION (Data type MA_Messaging.NotificationTargetType, NotificationTargetType enum type)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void initNotificationMessaging(String configType, String title, String body, String target, Set<String> userIds, MA_Messaging.NotificationTargetType targetType) {
        StatefulQueueable statefulInstance = getStatefulQueueable();
        statefulInstance.messaging = MA_Messaging.getInstance(configType);
        initNotificationMessaging(statefulInstance, targetType, NotificationType.SINGLE_NOTIFICATION, body, title, target, new List<String>(userIds));
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to setup custom notification messaging configuration to handle bulk notifications.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    configType      DESCRIPTION (Data type String, Messaging Configuration metadata type)
    * @param    targetType      DESCRIPTION (Data type MA_Messaging.NotificationTargetType, NotificationTargetType enum type)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void initNotificationMessaging(String configType, MA_Messaging.NotificationTargetType targetType) {
        StatefulQueueable statefulInstance = getStatefulQueueable();
        statefulInstance.messaging = MA_Messaging.getInstance(configType);
        BulkNotification bulkNotification = statefulInstance.bulkNotifications?.get(statefulInstance.nextBulkNotificationIndex);
        initNotificationMessaging(statefulInstance, targetType, NotificationType.BULK_NOTIFICATION, bulkNotification?.body, bulkNotification?.title, null, bulkNotification?.userIds);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to setup custom notification messaging configuration.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    statefulInstance    DESCRIPTION (Data type StatefulQueueable, Serialized state of messaging maintained across queueable jobs)
    * @param    targetType          DESCRIPTION (Data type MA_Messaging.NotificationTargetType, NotificationTargetType enum type)
    * @param    notificationType    DESCRIPTION (Data type MA_MessageProcessing.NotificationType, NotificationType enum type)
    * @param    body                DESCRIPTION (Data type String, Body of the custom notification)
    * @param    title               DESCRIPTION (Data type String, Title of the custom notification)
    * @param    target              DESCRIPTION (Data type String, Notification target record Id or target page reference)
    * @param    userIds             DESCRIPTION (Data type Set<String>, Set of User Ids to send Custom Notifications to)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void initNotificationMessaging(StatefulQueueable statefulInstance, MA_Messaging.NotificationTargetType targetType, NotificationType notificationType, 
                                                  String body, String title, String target, List<String> userIds) {
        statefulInstance.targetType = targetType;
        statefulInstance.notificationType = notificationType;

        if(userIds != null && userIds.size() > 0) {
            statefulInstance.userIds.addAll(userIds);
            statefulInstance.totalNotifications = userIds.size();
            statefulInstance.messaging.setNotificationConfig(title, body, target, statefulInstance.messaging.notification, targetType, statefulInstance.messaging.messagingConfig);
        }
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to process messaging jobs based on ExecutionType enum type.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    executionType       DESCRIPTION (Data type ExecutionType, Enum type to determine the way email & notification queueable jobs 
    *                                         are to be executed)
    * @param    nextJob             DESCRIPTION (Data type Queueable, Next Job instance to be enqueued after all messages are processed)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void processMessages(ExecutionType executionType, Queueable nextJob) {
        StatefulQueueable statefulInstance = getStatefulQueueable();
        statefulInstance.nextJob = nextJob;
        processMessages(executionType);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to process messaging jobs based on ExecutionType enum type.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    executionType    DESCRIPTION (Data type ExecutionType, Enum type to determine the way email & notification queueable jobs 
    *                                         are to be executed)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void processMessages(ExecutionType executionType) {
        StatefulQueueable statefulInstance = getStatefulQueueable();
        statefulInstance.executionType = executionType;

        switch on executionType {
            when EMAIL_JOB, SINGLE_CHAINED_JOB {
                enqueueEmailProcessorJob(statefulInstance);
            }when NOTIFICATION_JOB {
                enqueueNotificationProcessorJob(statefulInstance);
            }when MULTIPLE_CHAINED_JOB {
                enqueueEmailProcessorJob(statefulInstance);
                enqueueNotificationProcessorJob(statefulInstance);
            }
        }
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get messaging job (to be executed as nextJob within other Queueable Job's context) based on ExecutionType enum type.
    * MULTIPLE_CHAINED_JOB type will not be eligible for this case.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    executionType    DESCRIPTION (Data type ExecutionType, Enum type to determine the way email & notification queueable jobs 
    *                                         are to be executed)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Queueable getMessagingJob(ExecutionType executionType) {
        StatefulQueueable statefulInstance = getStatefulQueueable();
        statefulInstance.executionType = executionType;
        Queueable messagingJob = null;

        switch on executionType {
            when EMAIL_JOB, SINGLE_CHAINED_JOB {
                if(statefulInstance.totalEmails > 0)  {
                    messagingJob = new MA_EmailProcessor(statefulInstance, MA_EmailProcessorFinalizer.class);
                }
            }when NOTIFICATION_JOB {
                if(statefulInstance.totalNotifications > 0) {
                    messagingJob = new MA_NotificationProcessor(statefulInstance, MA_NotificationProcessorFinalizer.class);
                }
            }
        }

        return messagingJob;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to enqueue MA_EmailProcessor job to process email messages.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    statefulInstance        DESCRIPTION (Data type StatefulQueueable, Serialized state of queueable job)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void enqueueEmailProcessorJob(StatefulQueueable statefulInstance) {
        if(statefulInstance.totalEmails > 0) {
            enqueueJob(new MA_EmailProcessor(statefulInstance, MA_EmailProcessorFinalizer.class));
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to enqueue MA_NotificationProcessor job to process custom notifications.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    statefulInstance        DESCRIPTION (Data type StatefulQueueable, Serialized state of queueable job)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void enqueueNotificationProcessorJob(StatefulQueueable statefulInstance) {
        if(statefulInstance.totalNotifications > 0) {
            enqueueJob(new MA_NotificationProcessor(statefulInstance, MA_NotificationProcessorFinalizer.class));
        }
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
        if(isQueueable()) {
            System.enqueueJob(asyncJob);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check if Queueable Job Governor Limits are not breached and Maximum Stack Depth hasn't reached.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return       Boolean                 DESCRIPTION (return True if Queueable job can be enqueued)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isQueueable() {
        return (Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) && !(Test.isRunningTest() && System.isQueueable());
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to process email messages for a given set of target Ids.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    class MA_EmailProcessor implements Queueable {

        private StatefulQueueable jobParams;
        private Type queueableFinalizerImpl;

        public MA_EmailProcessor(StatefulQueueable jobParams, Type queueableFinalizerImpl) {
            this.jobParams = jobParams;
            this.queueableFinalizerImpl = queueableFinalizerImpl;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to send email messages to target Ids, limiting email count to emailThreshold value per job execution.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void execute(QueueableContext qContext) {
            Integer emailSentCount = jobParams.currentEmailCount;
            Integer emailThreshold = jobParams.messaging.messagingConfig.emailThreshold;

            for(;isValidNextWhatIdIteration(emailSentCount, emailThreshold);) {
                Id emailWhatId = jobParams.emailWhatIds.get(jobParams.nextWhatIdIndex);
                Set<Id> emailTargetIds = jobParams.emailWhatIdToTargetIdsMap.get(emailWhatId);

                createEmailMessages(emailSentCount, emailThreshold, emailWhatId, new List<Id>(emailTargetIds));

                if(!isValidNextTargetIdIndex(emailTargetIds.size())) {
                    jobParams.nextWhatIdIndex++;
                    jobParams.nextTargetIdIndex = 0;
                }
            }

            if(jobParams.messaging.getEmailTargetIdsSize() > 0) {
                jobParams.messaging.createAndSendEmailMessages();
            }
            
            handleJobCompletion();
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to validate the nextWhatIdIndex iteration.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    emailSentCount      DESCRIPTION (Data type Integer, Count of emails sent at the beginning of async execution.)
        * @param    emailThreshold      DESCRIPTION (Data type Integer, Maximum emails that can be sent per job execution based on message config.)
        * @return   Boolean             DESCRIPTION (return true if it's valid nextWhatIdIndex and emails sent are under the limits.)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Boolean isValidNextWhatIdIteration(Integer emailSentCount, Integer emailThreshold) {
            return isValidNextWhatIdIndex() && isValidCurrentEmailCount() && isValidEmailThreshold(emailSentCount, emailThreshold);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to check if it's a valid nextWhatIdIndex.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Boolean isValidNextWhatIdIndex() {
            return jobParams.nextWhatIdIndex < jobParams.emailWhatIds.size();
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to check if current email count less than total emails to be sent.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Boolean isValidCurrentEmailCount() {
            return jobParams.currentEmailCount < jobParams.totalEmails;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to check if current email count is less than threshold limit per job execution.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    emailSentCount      DESCRIPTION (Data type Integer, Count of emails sent at the beginning of async execution.)
        * @param    emailThreshold      DESCRIPTION (Data type Integer, Maximum emails that can be sent per job execution based on message config.)
        * @return   Boolean             DESCRIPTION (return true if current email count is less than threshold limit.)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Boolean isValidEmailThreshold(Integer emailSentCount, Integer emailThreshold) {
            return jobParams.currentEmailCount-emailSentCount < emailThreshold;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to validate the nextTargetIdIndex iteration.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    totalTargetIds      DESCRIPTION (Data type Integer, Total number of Contact Ids for a given WhatId.)
        * @param    emailSentCount      DESCRIPTION (Data type Integer, Count of emails sent at the beginning of async execution.)
        * @param    emailThreshold      DESCRIPTION (Data type Integer, Maximum emails that can be sent per job execution based on message config.)
        * @return   Boolean             DESCRIPTION (return true if it's valid nextTargetIdIndex and emails sent are under the limits.)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Boolean isValidNextTargetIdIteration(Integer totalTargetIds, Integer emailSentCount, Integer emailThreshold) {
            return isValidNextTargetIdIndex(totalTargetIds) && isValidCurrentEmailCount() && isValidEmailThreshold(emailSentCount, emailThreshold);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to check if it's a valid nextTargetIdIndex.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Boolean isValidNextTargetIdIndex(Integer totalTargetIds) {
            return jobParams.nextTargetIdIndex < totalTargetIds;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to create List of Email Messages using the email configuration & target email ids.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    emailSentCount      DESCRIPTION (Data type Integer, Count of emails sent at the beginning of async execution.)
        * @param    emailThreshold      DESCRIPTION (Data type Integer, Maximum emails that can be sent per job execution based on message config.)
        * @param    emailWhatId         DESCRIPTION (Data type String, whatId of Email Message referred in email template)
        * @param    emailTargetIds      DESCRIPTION (Data type Set<Id>, Set of Contact Ids to send Email Messages to)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void createEmailMessages(Integer emailSentCount, Integer emailThreshold, Id emailWhatId, List<Id> emailTargetIds) {
            for(;isValidNextTargetIdIteration(emailTargetIds.size(), emailSentCount, emailThreshold);) {
                jobParams.messaging.addEmailTargetId(emailWhatId, emailTargetIds[jobParams.nextTargetIdIndex]);
                jobParams.nextTargetIdIndex++;
                jobParams.currentEmailCount++;
            }
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to handle finalizer action upon queueable job completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void handleJobCompletion() {
            QueueableFinalizer queueableFinalizer = (QueueableFinalizer)queueableFinalizerImpl.newInstance();

            if(jobParams.currentEmailCount < jobParams.totalEmails) {
                queueableFinalizer.handleSingleJobCompletion(jobParams);
            }else {
                queueableFinalizer.handleAllJobsCompletion(jobParams);
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to process custom notifications for a given set of user Ids.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    class MA_NotificationProcessor implements Queueable {

        private StatefulQueueable jobParams;
        private Type queueableFinalizerImpl;

        public MA_NotificationProcessor(StatefulQueueable jobParams, Type queueableFinalizerImpl) {
            this.jobParams = jobParams;
            this.queueableFinalizerImpl = queueableFinalizerImpl;
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to send notifications to user Ids, limiting notification count to notificationThreshold value per job execution.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void execute(QueueableContext qContext) {
            Integer startIndex = jobParams.currentNotificationCount;
            Integer notificationThreshold = jobParams.messaging.messagingConfig.notificationThreshold;

            for(;isValidCurrentNotificationIteration(startIndex, notificationThreshold);) {
                jobParams.messaging.addNotificationUserId(jobParams.userIds[jobParams.currentNotificationCount]);
                jobParams.currentNotificationCount++;
            }

            if(jobParams.messaging.getNotificationUserIdsSize() > 0) {
                jobParams.messaging.sendNotifications();
            }

            QueueableFinalizer queueableFinalizer = (QueueableFinalizer)queueableFinalizerImpl.newInstance();

            if(hasMoreNotifications()) {
                queueableFinalizer.handleSingleJobCompletion(jobParams);
            }else {
                queueableFinalizer.handleAllJobsCompletion(jobParams);
            }
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to validate the currentNotificationCount iteration.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    startIndex              DESCRIPTION (Data type Integer, Count of users notified at the beginning of async execution.)
        * @param    notificationThreshold   DESCRIPTION (Data type Integer, Maximum users that can be notified per job execution based on message config.)
        * @return   Boolean                 DESCRIPTION (return true if it's valid currentNotificationCount and users notified are under the limits.)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Boolean isValidCurrentNotificationIteration(Integer startIndex, Integer notificationThreshold) {
            return isValidCurrentNotificationCount() && isValidNotificationThreshold(startIndex, notificationThreshold);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to check if currentNotificationCount is less than the totalNotifications for a given CustomNotification.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Boolean isValidCurrentNotificationCount() {
            return jobParams.currentNotificationCount < jobParams.totalNotifications;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to validate if users notified are less under the notificationThreshold.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    startIndex              DESCRIPTION (Data type Integer, Count of users notified at the beginning of async execution.)
        * @param    notificationThreshold   DESCRIPTION (Data type Integer, Maximum users that can be notified per job execution based on message config.)
        * @return   Boolean                 DESCRIPTION (return true if users notified are under the limits.)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Boolean isValidNotificationThreshold(Integer startIndex, Integer notificationThreshold) {
            return jobParams.currentNotificationCount-startIndex < notificationThreshold;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to check if there are more users to be notified or more notifications (in case of bulk notifications) to be processed.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Boolean hasMoreNotifications() {
            Boolean hasMoreNotifications = isValidCurrentNotificationCount();
            if(!hasMoreNotifications && jobParams.notificationType == NotificationType.BULK_NOTIFICATION) {
                jobParams.nextBulkNotificationIndex++;
                hasMoreNotifications = jobParams.nextBulkNotificationIndex < jobParams.bulkNotifications.size();
            }
            return hasMoreNotifications;
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
        * Method to reset bulk notification configuration upon completion of single job.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams    DESCRIPTION (Data type StatefulQueueable, Serialized state of queueable job)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        protected void resetBulkNotificationParams(StatefulQueueable jobParams) {
            jobParams.userIds.clear();
            jobParams.totalNotifications = 0;
            MA_MessageProcessing.initNotificationMessaging(statefulInstance.messaging.messagingConfig.configType, statefulInstance.targetType);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to enqueue Next Job (may need to enqueue the source job instance with different parameters) upon completion of all jobs.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams    DESCRIPTION (Data type StatefulQueueable, Serialized state of queueable job)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        protected void enqueueNextJob(StatefulQueueable jobParams) {
            if(jobParams.nextJob != null) {
                MA_MessageProcessing.enqueueJob(jobParams.nextJob);
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of AbstractQueueableFinalizer to provide QueueableFinalizer implementation for MA_EmailProcessor queueable job.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class MA_EmailProcessorFinalizer extends AbstractQueueableFinalizer {
        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on each single job completion; enqueues a MA_EmailProcessor job to send email messages.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams    DESCRIPTION (Data type Stateful, Serialized state of queueable job)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion(StatefulQueueable jobParams) {
            MA_MessageProcessing.enqueueEmailProcessorJob(jobParams);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on all jobs completion; enqueues MA_NotificationProcessor job if ExecutionType is SINGLE_CHAINED_JOB.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams    DESCRIPTION (Data type Stateful, Serialized state of queueable job)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleAllJobsCompletion(StatefulQueueable jobParams) {
            if(jobParams.executionType == MA_MessageProcessing.ExecutionType.SINGLE_CHAINED_JOB) {
                MA_MessageProcessing.enqueueNotificationProcessorJob(jobParams);
            }else {
                super.enqueueNextJob(jobParams);
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of AbstractQueueableFinalizer to provide QueueableFinalizer implementation for MA_NotificationProcessor queueable job.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class MA_NotificationProcessorFinalizer extends AbstractQueueableFinalizer {
        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * * Method to execute on each single job completion; enqueues a MA_NotificationProcessor job to send custom notifications.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams    DESCRIPTION (Data type Stateful, Serialized state of queueable job)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion(StatefulQueueable jobParams) {
            if(jobParams.notificationType == NotificationType.BULK_NOTIFICATION) {
                super.resetBulkNotificationParams(jobParams);
            }
            MA_MessageProcessing.enqueueNotificationProcessorJob(jobParams);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on all jobs completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams    DESCRIPTION (Data type Stateful, Serialized state of queueable job)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleAllJobsCompletion(StatefulQueueable jobParams) {
            super.enqueueNextJob(jobParams);
        }
    }
}