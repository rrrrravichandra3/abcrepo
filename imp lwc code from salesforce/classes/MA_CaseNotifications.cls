/**
 * W-10946113, W-11122415
 * Flow Apex Action class to process email messages & notifications for Wayfinder Cases.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         11/04/2022      Chakshu Malhotra        Holds Invocable Methods to send email messages & notifications on case creation, closure and on comments update.
 * v2.0         23/05/2022      Priyanka Kanani         Handles logic to create SurveyInvitation & send it in Case Closure email.
 * v3.0         30/06/2022      Chakshu Malhotra        Added logic to send bell icon notifications in Wayfinder on case creation, closure and on comments update.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_CaseNotifications {

    private static final String CASE_RECORD_TYPE_MA = Label.MA_Case_Record_Type_MA;

    private static final String CONFIG_TYPE_CASE_CLOSURE = Label.MA_Close_Case_Config_Type;

    private static final String CASE_COMMENT_TITLE = Label.MA_Case_Comment_Notification_Title;
    private static final String CASE_CLOSURE_TITLE = Label.MA_Case_Closure_Notification_Title;
    private static final String CASE_CREATION_TITLE = Label.MA_Case_Creation_Notification_Title;

    private static final String CASE_CLOSURE_BODY = Label.MA_Case_Closure_Notification_Body;
    private static final String CASE_CREATION_BODY = Label.MA_Case_Creation_Notification_Body;
    private static final String CASE_COMMENT_BODY_SUFFIX = Label.MA_Case_Comment_Notification_Body_Suffix;

    private static Id maRecordTypeId;

    static {
        maRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CASE_RECORD_TYPE_MA).getRecordTypeId();
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold Invocable Variables as received from MA_Wayfinder_Case_Notifications flow upon case creation, closure and on comments update.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class NotificationDetail {
        @InvocableVariable(label='Case Id' description='Case record Id' required=true)
        public String caseId;

        @InvocableVariable(label='Case Number' description='Case Number' required=true)
        public String caseNumber;

        @InvocableVariable(label='Contact Id' description='Case Contact record Id' required=true)
        public String contactId;

        @InvocableVariable(label='Case RecordTypeId' description='Case record type Id' required=true)
        public String recordTypeId;

        @InvocableVariable(label='Community URL' description='MA Contact Community URL' required=true)
        public String communityURL;

        @InvocableVariable(label='Config Type' description='Messaging config type for MA' required=true)
        public String messageConfigType;
    }

    /** 
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold Notification Details based on each Config Type & mapping of Contact Id to it M&A Community URL.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class NotificationDetailWrapper {
        private Map<Id, String> caseIdToCaseNumberMap;
        private Map<Id, String> contactIdToCommunityURLMap;
        private Map<String, Map<Id, Set<Id>>> notificationDetailsMap;

        public NotificationDetailWrapper(Map<Id, String> caseIdToCaseNumberMap, Map<Id, String> contactIdToCommunityURLMap, 
                                         Map<String, Map<Id, Set<Id>>> notificationDetailsMap) {
            this.caseIdToCaseNumberMap = caseIdToCaseNumberMap;
            this.notificationDetailsMap = notificationDetailsMap;
            this.contactIdToCommunityURLMap = contactIdToCommunityURLMap;
        }
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Apex method to process email / custom notifications upon case creation, closure and on comments update.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    notificationDetails     DESCRIPTION (Data type List<NotificationDetail>, List of Notification Details as received from Flow.)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @InvocableMethod(label='Send Case Notifications' description='Sends Email / Custom notifications to Case Contacts' category='Case')
    public static void sendNotifications(List<NotificationDetail> notificationDetails) {
        NotificationDetailWrapper detailWrapperObj = getNotificationDetailWrapperInstance(notificationDetails);

        for(String messageConfigType : detailWrapperObj.notificationDetailsMap.keySet()) {
            enqueueJob(new NotifyContacts(messageConfigType, detailWrapperObj));
        }
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & return wrapper instance of NotificationDetailWrapper.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    notificationDetails         DESCRIPTION (Data type List<NotificationDetail>, List of Notification Details as received from Flow.)
    * @return   NotificationDetailWrapper   DESCRIPTION (return wrapper instance of NotificationDetailWrapper.)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static NotificationDetailWrapper getNotificationDetailWrapperInstance(List<NotificationDetail> notificationDetails) {
        Map<Id, String> caseIdToCaseNumberMap = new Map<Id, String>();
        Map<Id, String> contactIdToCommunityURLMap = new Map<Id, String>();
        Map<String, Map<Id, Set<Id>>> notificationDetailsMap = new Map<String, Map<Id, Set<Id>>>();
       
        for(NotificationDetail notificationDetail : notificationDetails) {
            if(notificationDetail.recordTypeId == maRecordTypeId) {
                Id caseId = Id.valueOf(notificationDetail.caseId);
                Id contactId = Id.valueOf(notificationDetail.contactId);
              
                String messageConfigType = notificationDetail.messageConfigType;
                Boolean containsConfigType = notificationDetailsMap.containsKey(messageConfigType);
                Map<Id, Set<Id>> caseIdToContactIdsMap = containsConfigType ? notificationDetailsMap.get(messageConfigType) : new Map<Id, Set<Id>>();
                Set<Id> contactIds = caseIdToContactIdsMap.containsKey(caseId) ? caseIdToContactIdsMap.get(caseId) : new Set<Id>();
                
                contactIds.add(contactId);
                caseIdToContactIdsMap.put(caseId, contactIds);
                caseIdToCaseNumberMap.put(caseId, notificationDetail.caseNumber);
                notificationDetailsMap.put(messageConfigType, caseIdToContactIdsMap);
                contactIdToCommunityURLMap.put(contactId, notificationDetail.communityURL);
            }
        }

        return new NotificationDetailWrapper(caseIdToCaseNumberMap, contactIdToCommunityURLMap, notificationDetailsMap);
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
    * Queueable implementation to notify case contact of the case creation, closure and on update of any comments on the case.
    * Handles logic to create SurveyInvitation for Cases upon its closure.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class NotifyContacts implements Queueable {
        private String configType;
        private Map<Id, String> caseIdToCaseNumberMap;
        private Map<Id, Set<Id>> emailWhatIdToTargetIdsMap;
        private Map<Id, String> contactIdToCommunityURLMap;

        private Map<Id, Id> caseIdToContactIdMap {
            get {
                if(caseIdToContactIdMap == null) {
                    caseIdToContactIdMap = new Map<Id, Id>();

                    for(Id caseId : emailWhatIdToTargetIdsMap.keySet()) {
                        caseIdToContactIdMap.put(caseId, new List<Id>(emailWhatIdToTargetIdsMap.get(caseId))[0]);
                    }
                }
                return caseIdToContactIdMap;
            }set;
        }

        private Map<Id, String> notificationUserIdMap {
            get {
                if(notificationUserIdMap == null) {
                    Set<Id> contactIds = new Set<Id>();

                    for(String whatId : emailWhatIdToTargetIdsMap.keySet()) {
                        contactIds.addAll(emailWhatIdToTargetIdsMap.get(whatId));
                    }

                    notificationUserIdMap = new Map<Id, String>();

                    for(User wayfinderUser : [SELECT Id, ContactId FROM User WHERE IsActive = true AND ContactId IN :contactIds]) {
                        notificationUserIdMap.put(wayfinderUser.ContactId, wayfinderUser.Id);
                    }
                }
                return notificationUserIdMap;
            }set;
        }

        public NotifyContacts(String configType, NotificationDetailWrapper detailWrapperObj) {
            this.configType = configType;
            this.caseIdToCaseNumberMap = detailWrapperObj.caseIdToCaseNumberMap;
            this.contactIdToCommunityURLMap = detailWrapperObj.contactIdToCommunityURLMap;
            this.emailWhatIdToTargetIdsMap = detailWrapperObj.notificationDetailsMap.get(configType);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to notfiy case contact of the case creation, closure and on update of any comments on the case.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void execute(QueueableContext qContext) {
            if(configType == CONFIG_TYPE_CASE_CLOSURE) {
                MA_CaseClosureSurvey.createCaseClosureSurvey(caseIdToContactIdMap, contactIdToCommunityURLMap);
            }
            initBulkNotifications();
            MA_MessageProcessing.initEmailMessaging(configType, emailWhatIdToTargetIdsMap, MA_Messaging.EmailMessageType.SINGLE_EMAIL);
            MA_MessageProcessing.initNotificationMessaging(configType, MA_Messaging.NotificationTargetType.PAGE_REF_TYPE);
            MA_MessageProcessing.processMessages(MA_MessageProcessing.ExecutionType.SINGLE_CHAINED_JOB);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to initialize BulkNotification list in MA_MessageProcessing to send dynamic notifications to different users.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void initBulkNotifications() {
            for(String caseId : caseIdToContactIdMap.keySet()) {
                Id contactId = caseIdToContactIdMap.get(caseId);
                String caseNumber = caseIdToCaseNumberMap.get(caseId);
                String title = getNotificationTitleAndBody(true, caseNumber);
                String body = getNotificationTitleAndBody(false, caseNumber);
                MA_MessageProcessing.addBulkNotification(title, body, new List<String> {notificationUserIdMap.get(contactId)});
            }
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get Notification title or body based on its Case configType.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    isTitle         DESCRIPTION (Data type Boolean, Fetches notification title if true, otherwise body.)
        * @param    caseNumber      DESCRIPTION (Data type Boolean, CaseNumber to add in title / body based on type of notification.)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private String getNotificationTitleAndBody(Boolean isTitle, String caseNumber) {
            String notificationTitleAndBody = '';
            switch on configType {
                when 'MA_WayfinderCaseClosure' {
                    notificationTitleAndBody = isTitle ? (CASE_CLOSURE_TITLE + ' ' + caseNumber) : CASE_CLOSURE_BODY;
                }when 'MA_WayfinderCaseCreation' {
                    notificationTitleAndBody = isTitle ? (CASE_CREATION_TITLE + ' ' + caseNumber) : CASE_CREATION_BODY;
                }when 'MA_WayfinderCaseComment' {
                    notificationTitleAndBody = isTitle ? (CASE_COMMENT_TITLE + ' ' + caseNumber) : (caseNumber + ' ' + CASE_COMMENT_BODY_SUFFIX);
                }
            }
            return notificationTitleAndBody;
        }
    }    
}