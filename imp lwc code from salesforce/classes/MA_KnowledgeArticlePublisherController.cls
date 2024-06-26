/**
* W-9556176
* M&A Preboarding App - Allow Community Users to subscribe to article and discussion
* 
* Version      Date            Author                  Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         15/02/2022      Priyanka Kanani         This Class sends Article changes email notification as well as custom notification to Community user who has subscribe the article.
* v1.0         20/02/2022      Chakshu Malhotra        Integrated the messaging framework created to send out emails & notifications using Single / Multiple chained jobs.
* v1.0         07/03/2022      Chakshu Malhotra        Created queueable job "NotifySubscribers" (overcomes 1000 limit on fetching EntitySubscription records) to notify subscribers.
* v1.0         04/05/2022      Ashutosh Belwal         Added logic to call MA_ProcessVideoSharing queueable apex for Knowledge Video sharing
* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public without sharing class MA_KnowledgeArticlePublisherController {
    
    private static final String NOTIFICATION_TITLE = Label.MA_ArticleNotification_Title;
    private static final String NOTIFICATION_SUBTITLE = Label.MA_ArticleNotification_SubTitle;
    private static final String COMMUNITY_USER_PROFILES = Label.MA_Community_Portal_Custom.toLowerCase();
    private static final String CONFIG_TYPE_ARTICLE_PUBLISHER = Label.MA_Messaging_Config_Type_Article_Publisher;
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * AuraEnabled method to publish knowledge article & notfiy all article subscribers of the changes in article.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    articleId 	    DESCRIPTION (Data type String, Knowledge Article Id)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static void publishKnowledgeArticle(String articleId) {
        Knowledge__kav knowledgeArticle = getpublishedKnowledgeArticle(articleId);
        enqueueJob(new NotifySubscribers(articleId, knowledgeArticle, null));
        enqueueJob(new MA_ProcessVideoSharing(articleId));
    }
    
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to get the KnowledgeArticle and Publish the Article
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    articleId 	         DESCRIPTION (Data type String, Knowledge Article Id)
    * @return   Knowledge__kav       DESCRIPTION (return published KnowledgeArticle.)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Knowledge__kav getpublishedKnowledgeArticle(String articleId){
        Knowledge__kav knowledgeArticle = [SELECT Id, Title, KnowledgeArticleId 
                                           FROM Knowledge__kav 
                                           WHERE Id =: articleId];
        KbManagement.PublishingService.publishArticle(knowledgeArticle.KnowledgeArticleId, true);
        return knowledgeArticle;
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
    * Queueable implementation to fetch EntitySubscription list for a given article and notify subscribers of the changes in article.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @testVisible
    private class NotifySubscribers implements Queueable {
        private Set<Id> emailTargetIds;
        private Set<String> notificationUserIds;

        private String articleId;
        private Knowledge__kav knowledgeArticle;
        private List<EntitySubscription> subscriptionList;

        public NotifySubscribers(String articleId, Knowledge__kav knowledgeArticle, Id lastSubscriptionId) {
            initTargets();
            this.articleId = articleId;
            this.knowledgeArticle = knowledgeArticle;
            this.subscriptionList = getEntitySubscriptionList(knowledgeArticle.KnowledgeArticleId, lastSubscriptionId);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method is used to init Email Target Ids and Notification User Ids for each queueable job.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void initTargets() {
            this.emailTargetIds = new Set<Id>();
            this.notificationUserIds = new Set<String>();
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method is used to retrieve List of Article Subscriber with Profile and ContactId.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    articleId 	                    DESCRIPTION (Data type Id, Knowledge Article Id)
        * @param    lastSubscriptionId 	            DESCRIPTION (Data type Id, Last record Id of EntitySubscription from previous query result list)
        * @return   List<EntitySubscription>        DESCRIPTION (return list of Article Subscribers)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private List<EntitySubscription> getEntitySubscriptionList(Id articleId, Id lastSubscriptionId) {
            String queryStr = 'SELECT Id, Subscriber.Id, Subscriber.Contact.Id, Subscriber.Profile.Name ' +
                              'FROM EntitySubscription ' + 
                              'WHERE ParentId = :articleId';

            if(lastSubscriptionId != null) {
                queryStr += ' AND Id > :lastSubscriptionId';
            }

            queryStr += ' ORDER BY Id ASC LIMIT 1000'; // Max Limit of 1000 allowed on EntitySubscription when run by Non-Admin user
            return Database.query(queryStr);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to notfiy all article subscribers of the changes in article.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void execute(QueueableContext qContext) {
            if(subscriptionList != null && subscriptionList.size() > 0) {
                Id lastSubscriptionId = subscriptionList[subscriptionList.size() - 1].Id;
                NotifySubscribers nextJob = new NotifySubscribers(articleId, knowledgeArticle, lastSubscriptionId);
                notifyArticleSubscribers(nextJob);
            }
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Populates email target Ids & notification user Ids and inititates MA_MessageProcessing with execution type as SINGLE_CHAINED_JOB
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void notifyArticleSubscribers(Queueable nextJob) {
            for (EntitySubscription subscription : subscriptionList) {
                if(isApplicableProfile(subscription.Subscriber.Profile.Name.toLowerCase())){
                    notificationUserIds.add(subscription.Subscriber.Id);
                    emailTargetIds.add(subscription.Subscriber.Contact.Id);
                }
            }

            if(!emailTargetIds.isEmpty() || !notificationUserIds.isEmpty()) {
                processMessages(nextJob);
            }
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method is check if subscriber profile is one the of the community user's profile.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    subscriberProfile     DESCRIPTION (Data type String, Subscriber's profile name)
        * @return   Boolean               DESCRIPTION (return True if subscirber profile exists in Community User Profiles label)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Boolean isApplicableProfile(String subscriberProfile) {
            Boolean isProfileNameApplicable = false;
            try {
                String profileNamePattern = '((?<=;)|(?<=^))(' + subscriberProfile + ')(((?=;)|(?=$)))';
                isProfileNameApplicable = Pattern.compile(profileNamePattern).matcher(COMMUNITY_USER_PROFILES).find();
            }catch(Exception ex) {
                isProfileNameApplicable = COMMUNITY_USER_PROFILES.contains(subscriberProfile);
            }
            return isProfileNameApplicable;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to initiate message processing for email target Id & notification user Ids using the Messaging Framework.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        @testVisible
        private void processMessages(Queueable nextJob) {
            String notificationBody = knowledgeArticle.Title + ' ' + NOTIFICATION_SUBTITLE + '.';
            MA_MessageProcessing.initEmailMessaging(CONFIG_TYPE_ARTICLE_PUBLISHER, articleId, emailTargetIds, MA_Messaging.EmailMessageType.SINGLE_EMAIL);
            MA_MessageProcessing.initNotificationMessaging(CONFIG_TYPE_ARTICLE_PUBLISHER, NOTIFICATION_TITLE, notificationBody, articleId, notificationUserIds, MA_Messaging.NotificationTargetType.RECORD_ID_TYPE);
            MA_MessageProcessing.processMessages(MA_MessageProcessing.ExecutionType.SINGLE_CHAINED_JOB, nextJob);
        }
    }
}