public with sharing class Concierge_Article_Feedback_Handler {
    
    public static void updateCases(Map<Id, Concierge_Article_Feedback__c> newMap, Map<Id, Concierge_Article_Feedback__c> oldMap) {
        if (newMap != null) {
            Set<Id> caseIds = new Set<Id>();
            
            for (Concierge_Article_Feedback__c af : newMap.values()) {
                if (oldMap == null || (oldMap.containsKey(af.Id) && oldMap.get(af.Id).Concierge_Status__c != af.Concierge_Status__c)) {
                    caseIds.add(af.Concierge_Feedback_Case__c);
                }
            }
            
            if (caseIds.isEmpty()) {
                return;
            }
            
            Map<String, String> caseToStatusMap = new Map<String, String>();
            for (AggregateResult ar : [select Count(Id) cnt, Concierge_Feedback_Case__c c, Concierge_Status__c s from Concierge_Article_Feedback__c 
                                       WHERE Concierge_Feedback_Case__c IN :caseIds
                                       GROUP BY Concierge_Feedback_Case__c, Concierge_Status__c]) {
                                           String status = (String)ar.get('s');
                                           String cId = (String)ar.get('c');
                                           if (status == null || status == 'New' || status == 'In Progress' || status == 'Waiting for Response') {
                                               caseToStatusMap.put(cId, 'Open');
                                           } else {
                                               if (!caseToStatusMap.containsKey(cId)) {
                                                   caseToStatusMap.put(cId, 'Closed');
                                               }
                                           }
                                       }
            
            List<Case> cases = new List<Case>();
            for (String cId : caseToStatusMap.keySet()) {
                cases.add(new Case(Id=cId, status=caseToStatusMap.get(cId)));
            }
            
            update cases;
        }
    }
    
    public static void updateTotalAttachedCases (List<Concierge_Article_Feedback__c> newRecords) {
        Map<Id, Concierge_Article_Feedback__c> caseIdToFeedback = new Map<Id, Concierge_Article_Feedback__c>();
        Map<Concierge_Article_Feedback__c, Id> feedbackToKAId = new Map<Concierge_Article_Feedback__c, Id>();
        Map<Id, Integer> articleCount = new Map<Id, Integer>();
        
        //1. Accumulate all feedback case id to feedback. 
        for (Concierge_Article_Feedback__c fb : newRecords) {
            caseIdToFeedback.put(fb.Concierge_Feedback_Case__c, fb);               
        }
        
        //2.  Use the info in step 1 to get a map of feedback and KnowledgeId. This step assumes that each feedback 
        //is associated with one and only one Knowledge article.
        List<CaseArticle> caseArticles = [ SELECT CaseId, KnowledgeArticleId 
                                          FROM CaseArticle 
                                          where caseId in :caseIdToFeedback.keySet()];
        
        for (CaseArticle ca : caseArticles) {
            Concierge_Article_Feedback__c feedback = caseIdToFeedback.get(ca.CaseId);
            feedbackToKAId.put(feedback, ca.KnowledgeArticleId);		            
        }
        
        //3. query count of all cases associated with Knowledge Articles found in step 2
        List<AggregateResult> groupedCaseArticles = [SELECT Count(CaseId) caseCount, KnowledgeArticleId 
                                                     FROM CaseArticle 
                                                     where KnowledgeArticleId in :feedbackToKAId.values()
                                                     and case.recordType.developername != 'Article_Feedback'
                                                     group by KnowledgeArticleId];
        
        for (AggregateResult ar : groupedCaseArticles)  {
            integer count = Integer.valueOf(ar.get('caseCount'));
            id kaId = (Id)ar.get('KnowledgeArticleId');
            articleCount.put(kaId, count);            
        }        
        // 4. update feedback with case count
        for (Concierge_Article_Feedback__c fb : feedbackToKAId.keySet()) {
            Id kaId = feedbackToKAId.get(fb);
            fb.Concierge_Total_Attached_Cases__c = articleCount.get(kaId);
        }        
    }
}