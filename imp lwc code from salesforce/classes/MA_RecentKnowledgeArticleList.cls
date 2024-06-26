/**
 * ********************** MA_RecentKnowledgeArticleList **********************
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         22/09/2022      Priyanka Kanani     Class to Display Recently Added//Modified articles on home page
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */

public with Sharing class MA_RecentKnowledgeArticleList {

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to retrieve artilces that are added or updated within 2 weeks of time
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   List<Knowledge__kav>      DESCRIPTION (return List of Knowledge Articles)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled(cacheable=true)
    public static  List<Knowledge__kav> getRecentArticles(){
            return [SELECT Id, Title, KnowledgeArticleId, CreatedDate, LastModifiedDate, UrlName, ArticleCreatedDate
                    FROM Knowledge__kav
                    WHERE PublishStatus = 'Online' AND RecordType.Name = 'How_To' AND (CreatedDate = LAST_N_DAYS:14 OR LastModifiedDate = LAST_N_DAYS:14)
                    AND Id IN (SELECT EntityId FROM TopicAssignment where NetworkId =: Network.getNetworkId() and EntityType ='Knowledge')
                    ORDER BY LastModifiedDate DESC];
    }


    
}