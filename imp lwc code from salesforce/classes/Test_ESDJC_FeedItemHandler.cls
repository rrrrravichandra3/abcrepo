@isTest
public with sharing class Test_ESDJC_FeedItemHandler {
    public static testMethod void testCreateArticleFeedback() {
        Id howToRecordTypeId = [Select Id from RecordType where DeveloperName='How_To'].Id;
        Knowledge__kav article = new Knowledge__kav();
        article.title = 'My How To Article';
        article.UrlName = 'My-How-To-Article';
        article.Review_Cycle__c = '3';
        article.Article_Owner_Group__c = 'Benefits - EMEA';
        article.RecordTypeId =howToRecordTypeId; 
        
        insert article;
        article = [SELECT KnowledgeArticleId from Knowledge__kav WHERE id=:article.Id];
        System.assertNotEquals(null, article);
        System.assertNotEquals(null, article.KnowledgeArticleId);
        
        List<PKB_Article_Feedback_Deflection__c> deflections = [SELECT Article_ID__c FROM PKB_Article_Feedback_Deflection__c WHERE Article_ID__c=:article.KnowledgeArticleId];
        System.assertEquals(0,deflections.size());
        
        FeedItem feedItem = new FeedItem();
        feedItem.Body = 'This is the feed item body';
        feedItem.ParentId = article.KnowledgeArticleId;
        insert feedItem;

        deflections = [SELECT Article_ID__c FROM PKB_Article_Feedback_Deflection__c WHERE Article_ID__c=:article.KnowledgeArticleId];
        
        
    }
}