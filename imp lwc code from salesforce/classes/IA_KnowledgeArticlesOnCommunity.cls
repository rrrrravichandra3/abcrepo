/**
 * @description       : Class used by IA_KnowledgeArticlesOnCommunityService to retrieve articles
 *                      for Insiders Community.
 * @author            : lolivera@salesforce.com
 * @last modified on  : 08-30-2021
 * 
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   08-20-2021   lolivera@salesforce.com              Initial Version
 * 1.1   08-30-2021   lolivera@salesforce.com              Class implements interface
 **/
public with sharing class IA_KnowledgeArticlesOnCommunity implements IA_KnowledgeArticlesOnCommunityInterface {

    /*******************************************************************************************************
    * @description Retrieves all published Knowledge Articles that have the 'Insiders' record type.
    * @return List<Knowledge__kav>  To display on community.
    */
    public static List<Map<String, String>> getInsidersKnowledgeArticles() {
        try {
            Id insidersRecordType = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('Insiders').getRecordTypeId();

            final String QUERY_STRING = 'SELECT Id, Title, Summary, LastPublishedDate ' +
                                       'FROM Knowledge__kav ' +
                                       'WHERE RecordTypeId = :insidersRecordType ' +
                                       'AND PublishStatus = \'Online\'' +
                                       'ORDER BY LastPublishedDate DESC';
            List<Knowledge__kav> articles = Database.query(QUERY_STRING);

            List<Map<String, String>> articlesList = new List<Map<String, String>>();
            for (Knowledge__kav article : articles) {
                Map<String, String> articleMap = new Map<String, String>();
                articleMap.put('Id', article.Id);
                articleMap.put('Title', article.Title);
                articleMap.put('Summary', article.Summary);
                articleMap.put('LastPublishedDate', String.valueOf(article.LastPublishedDate.date()));
                articlesList.add(articleMap);
            }

            if (articles.size() > 0) {
                return articlesList;
            }

        } catch (Exception e) {
            IA_Util.sendExceptionMail(new List<String> {e.getMessage()} );
        }

        return new List<Map<String, String>>();
    }

    /*******************************************************************************************************
    * @description Retrieves all published Knowledge Articles that have the 'Insiders' record type.
    * @param articleId : Knowledge Article ID to retrieve the rest of the data.
    * @return Knowledge__kav  To display on the Community.
    */
    public static Map<String, String> getKnowledgeArticle(String articleId) {
        try {
            Id insidersRecordType = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('Insiders').getRecordTypeId();

            final String QUERY_STRING = 'SELECT Id, Title, Summary, Solution__c ' +
                                        'FROM Knowledge__kav ' + 
                                        'WHERE PublishStatus = \'Online\' ' +
                                        'AND Id = :articleId ' +
                                        'AND RecordTypeId = :insidersRecordType';
            List<Knowledge__kav> articles = Database.query(QUERY_STRING);

            if (articles.size() > 0) {
                Map<String, String> articleMap = new Map<String, String>();
                articleMap.put('Id', articles[0].Id);
                articleMap.put('Title', articles[0].Title);
                articleMap.put('Summary', articles[0].Summary);
                articleMap.put('Solution__c', articles[0].Solution__c);
                return articleMap;
            }

        } catch (Exception e) {
            IA_Util.sendExceptionMail(new List<String> {e.getMessage()} );            
        }

        return new Map<String, String>();
    }
}