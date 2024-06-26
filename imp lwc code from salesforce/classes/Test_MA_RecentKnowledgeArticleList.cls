/**
* Test Class for MA_RecentKnowledgeArticleList
* 
* Version      Date            Author                  Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         30-10-2023      priyanka Kanani         Initial Version
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@IsTest(SeeAllData=false)
public class Test_MA_RecentKnowledgeArticleList {
    private Static String maESName = 'taskAutoController';
    static testMethod void testGetRecentArticles() {
        List<knowledge__kav> articlelist = MA_TestUtil.createKnowledgeArticle(1, maESName, true);
        
        topic newTopic = new topic(NetworkId = Network.getNetworkId(), name = 'test');
        insert newTopic;
        TopicAssignment Topicass = new TopicAssignment(TopicId = newTopic.Id, EntityId = articlelist[0].Id, NetworkId = Network.getNetworkId());
        insert Topicass;
        
        knowledge__kav obj1 = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id =: articlelist[0].Id];
        KbManagement.PublishingService.publishArticle(obj1.KnowledgeArticleId, true);
        
        Test.startTest();
        List<Knowledge__kav> recentArticles = MA_RecentKnowledgeArticleList.getRecentArticles();
        Test.stopTest();
        
        Assert.AreEqual(1, recentArticles.size(), 'Number of articles should match');
        Assert.AreEqual(maESName, recentArticles[0].Title, 'Article title should match');
        
        
    }
}