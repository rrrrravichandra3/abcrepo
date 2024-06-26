/*
*  @Author : Priyanka
*  W-9556176 - M&A Preboarding App - AAllow Community Users to subscribe to article and discussion
*  This Class sends Article changes email notification as well as custom notification to Community user who has subscribe the article.
*/

public without sharing class MA_KnowledgeArticleHandler {
    
    @AuraEnabled
    public static void publishArticleBack(String articleId) {
        Knowledge__kav ka = [SELECT Id, Title, UrlName, KnowledgeArticleId 
                             FROM Knowledge__kav 
                             WHERE Id =: articleId];
        KbManagement.PublishingService.publishArticle(ka.KnowledgeArticleId, true);
        
        List<String> communityProfileList = New List<String>{System.Label.MA_Community_Portal_Custom};
        List<EntitySubscription> subscriptionList = [SELECT Id, ParentId,Subscriber.profile.name, Subscriber.Email,Subscriber.Contact.M_A_Community_URL__c FROM EntitySubscription WHERE ParentId =: ka.KnowledgeArticleId];
        EmailTemplate et= [SELECT Id,HtmlValue, Subject   FROM EmailTemplate WHERE DeveloperName =: System.Label.MA_ArticleNotification_TemplateName ];
       
        // Create a savepoint when article is published
		Savepoint sp = Database.setSavepoint();
        String subject = et.Subject;
        subject = subject.replace('{!$Label.MA_ArticleNotification_MailTitle}',System.Label.MA_ArticleNotification_MailTitle);
        String body = et.HtmlValue;
        // Set email details
        List<String> recipientEmails = new List<String>();
        Set<String> recipientsIds = new Set<String>();
        if(!subscriptionList.isEmpty()){
            
            body = body.replace('{!Contact.M_A_Community_URL__c}', subscriptionList[0].Subscriber.Contact.M_A_Community_URL__c);
            body = body.replace('{!Knowledge__kav.UrlName}', ka.UrlName);
            body = body.replace('{!Knowledge__kav.Title}', string.format(Label.MA_ArticleNotification_SubTitle, new String[]{ka.Title}));
            PF_MA_Settings__c pfmaSetting = PF_MA_Settings__c.getInstance(userinfo.getProfileId());
            body = body.replace('{!$Setup.PF_MA_Settings__c.Email_Banner_Image_URL__c}', pfmaSetting.Email_Banner_Image_URL__c);
            body = body.replace('{!$Setup.PF_MA_Settings__c.Email_Scallop_Logo_URL__c}', pfmaSetting.Email_Scallop_Logo_URL__c);
            body = body.replace('{!$Setup.PF_MA_Settings__c.Check_In_Community_URL__c}', pfmaSetting.Check_In_Community_URL__c);
            body = body.replace('{!$Setup.PF_MA_Settings__c.Salesforce_Logo_URL__c}', pfmaSetting.Salesforce_Logo_URL__c);
            
            for (EntitySubscription subscription : subscriptionList) {
                if(communityProfileList.contains(subscription.Subscriber.profile.name)){
                    recipientEmails.add(subscription.Subscriber.Email);
                    recipientsIds.add(subscription.Subscriber.Id);
                }
                
            }
        }
        
        
        
        
        if (!recipientEmails.isEmpty()) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(recipientEmails); 
            mail.setHtmlBody(body);
            mail.setSubject(subject);
            //send email Notification
            try{
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            }
            catch (Exception e) {
                //rollback to savepoint when there is some error
      			Database.rollback(sp);
                PF_Logger.log('M&A','ERROR',e.getMessage(),' Error occured while sending Email Notification ',' UserId '
                              + UserInfo.getUserId(), 'MA_KnowledgeArticleHandler');
                
            }
            
        }
        
        // Get the Id for our custom notification type
        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName =: System.Label.MA_ArticleNotification_NotificationType ]; 
        
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        
        // Set the contents for the notification
        notification.setTitle(System.Label.MA_ArticleNotification_Title);
        notification.setBody(string.format(Label.MA_ArticleNotification_SubTitle, new String[]{ka.Title}));
        
        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(articleId);
        
        // Actually send the notification
        if (!recipientsIds.isEmpty()) {
            try {
                notification.send(recipientsIds);
            }
            catch (Exception e) {
                //rollback to savepoint when there is some error
       		 	Database.rollback(sp);
                PF_Logger.log('M&A','ERROR',e.getMessage(),' Error occured while sending Custom Notification ',' UserId '
                              + UserInfo.getUserId(), 'MA_KnowledgeArticleHandler');
                
            }
        }
         
    } 
}