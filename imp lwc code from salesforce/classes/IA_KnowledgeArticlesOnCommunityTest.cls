/**
 * @description       : Test class for IA_KnowledgeArticlesOnCommunity and IA_KnowledgeArticlesOnCommunityService
 * @author            : lolivera@salesforce.com
 * @last modified on  : 09-22-2021
 **/
@isTest
private class IA_KnowledgeArticlesOnCommunityTest {
    @testSetup
    static void setup() {
        // Test Knowledge Articles creation
        Id insidersRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('Insiders').getRecordTypeId();

        List<Knowledge__kav> testArticlesWithRecordTypeList = new List<Knowledge__kav>();
        for (Integer i = 0; i < 5; i++) {
            Knowledge__kav article = new Knowledge__kav(
                Title = 'Test Article ' + i,
                Solution__c = 'Test Answer ' + i,
                UrlName = 'Test-Answer-' + i,
                IsVisibleInCsp = true,
                recordtypeId = insidersRecordTypeId
            );
            testArticlesWithRecordTypeList.add(article);    
        }
        insert testArticlesWithRecordTypeList;

        List<Knowledge__kav> testArticlesWithoutRecordTypeList = new List<Knowledge__kav>();
        for (Integer i = 5; i < 10; i++) {
            Knowledge__kav article = new Knowledge__kav(
                Title = 'Test Article ' + i,
                Solution__c = 'Test Answer ' + i,
                UrlName = 'Test-Answer-' + i,
                IsVisibleInCsp = true
            );
            testArticlesWithoutRecordTypeList.add(article);    
        }
        insert testArticlesWithoutRecordTypeList;
        
        for (Knowledge__kav article : [SELECT KnowledgeArticleId FROM Knowledge__kav]) {
            KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);
        }
    }

    /*******************************************************************************************************
    * @description Check getInsidersKnowledgeArticles() retrieves all articles with 'Insiders' record
    *              type.
    */
    @IsTest
    static void getInsidersKnowledgeArticlesTest() {
        Test.startTest();
        List<Map<String,String>> articles = IA_KnowledgeArticlesOnCommunity.getInsidersKnowledgeArticles();
        Test.stopTest();

        System.assertEquals(5, articles.size(), '5 Articles with correct record type should have been retrieved');
    }

    /*******************************************************************************************************
    * @description Check getKnowledgeArticle() retrieves the Article information only if the Article
    *              has 'Insiders' record type.
    */
    @IsTest
    static void getKnowledgeArticleTest() {
        Id articleIdWithRecordType = [SELECT Id FROM Knowledge__kav WHERE Title='Test Article 0'].Id;
        Id articleIdWithoutRecordType = [SELECT Id FROM Knowledge__kav WHERE Title='Test Article 5'].Id;

        Test.startTest();
        Map<String,String> articleWithRecordType = IA_KnowledgeArticlesOnCommunity.getKnowledgeArticle(articleIdWithRecordType);
        Map<String,String> articleWithoutRecordType = IA_KnowledgeArticlesOnCommunity.getKnowledgeArticle(articleIdWithoutRecordType);
        Test.stopTest();

        System.assertEquals('Test Article 0', articleWithRecordType.get('Title'), 'TEST');
        System.assertEquals(null, articleWithoutRecordType.get('Title'), 'TEST');
    }
    
    /*******************************************************************************************************
    * @description Checks Service class retrieves all articles correctly.
    */
    @IsTest
    static void service_getInsidersKnowledgeArticlesTest() {
        Test.startTest();
        List<Map<String, String>> retrievedArticles = IA_KnowledgeArticlesOnCommunityService.getInsidersKnowledgeArticles();
        System.assertNotEquals(0, retrievedArticles.size(), 'At least one article should exist.');
        Test.stopTest();
    }
    
    /*******************************************************************************************************
    * @description Checks Service class retrieves specific article correctly.
    */
    @IsTest
    static void service_getKnowledgeArticleTest() {
        Knowledge__kav testArticle = [SELECT Id FROM Knowledge__kav LIMIT 1];
        
        Test.startTest();
        Map<String, String> retrievedArticle = IA_KnowledgeArticlesOnCommunityService.getKnowledgeArticle(testArticle.Id);
        System.assertNotEquals('', retrievedArticle.get('Title'), 'The retrieved article should have a Title');
        Test.stopTest();
    }
    
}