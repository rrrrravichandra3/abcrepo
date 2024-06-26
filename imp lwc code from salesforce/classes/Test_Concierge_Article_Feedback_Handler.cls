@isTest
private class Test_Concierge_Article_Feedback_Handler {
    
    private static Case createCase() {
        Id recordTypeId = [select Id from RecordType where DeveloperName='Article_Feedback' and SobjectType='Case'].Id;
        return new Case(RecordTypeId=recordTypeId, Type='Article Feedback', ES_DJC_Topic__c='Article Feedback', ES_DJC_Sub_Topic__c='Article Feedback');
    }
    
    private static Concierge_Article_Feedback__c createFeedback(Id pId) {
        return new Concierge_Article_Feedback__c(
            Concierge_Feedback_Case__c = pId
        );
    }
    
    
    @isTest static void test_updateCases() {
        Case c = createCase();
        c.Status = 'Open';
        insert c;
        
        System.assertEquals(
            'Open',
            c.Status,
            'status before insert of feedback'
        );
        
        Concierge_Article_Feedback__c f = createFeedback(c.Id);
        insert f;
        
        System.assertEquals(
            'Open',
            [SELECT Status FROM Case WHERE Id = :c.Id].Status,
            'status after insert of feedback'
        );
        
        f.Concierge_Status__c = 'Closed';
        update f;
        
        System.assertEquals(
            'Closed',
            [SELECT Status FROM Case WHERE Id = :c.Id].Status,
            'status after insert of feedback'
        );
    }
    
    @isTest static void test_updateCases_Closed() {
        Case c = createCase();
        c.Status = 'Open';
        insert c;
        
        System.assertEquals(
            'Open',
            c.Status,
            'status before insert of feedback'
        );
        
        Concierge_Article_Feedback__c f = createFeedback(c.Id);
        f.Concierge_Status__c = 'Closed';
        insert f;
        
        System.assertEquals(
            'Closed',
            [SELECT Status FROM Case WHERE Id = :c.Id].Status,
            'status after insert of feedback'
        );
    }
    
    @isTest
    private static void testCaseCount() {        
        List<Knowledge__kav> howtos = new List<Knowledge__kav>();
        Id howToRecordTypeId = [Select Id from RecordType where DeveloperName='How_To'].Id;

        howtos.add(createArticle('title1', 'question1', 'solution1','url1', false, '3', 'Benefits - EMEA',howToRecordTypeId));
        howtos.add(createArticle('title2', 'question2', 'solution2','url2', false, '3', 'Benefits - EMEA',howToRecordTypeId));
        howtos.add(createArticle('title3', 'question3', 'solution3','url3', false, '3', 'Benefits - EMEA',howToRecordTypeId));
        howtos.add(createArticle('title4', 'question4', 'solution4','url4', false, '3', 'Benefits - EMEA',howToRecordTypeId));
        howtos.add(createArticle('title5', 'question5', 'solution5','url5', false, '3', 'Benefits - EMEA',howToRecordTypeId));
        insert howtos;
        List<Knowledge__kav> insertedHowTos = [Select KnowledgeArticleId from Knowledge__kav where ID in :howtos];
        // Publish
        for (Knowledge__kav howto : insertedHowTos) {
            KbManagement.PublishingService.publishArticle(howto.KnowledgeArticleId, true);   
        }
        List<Knowledge__kav> publishedHowTos = [Select KnowledgeArticleId from Knowledge__kav where publishStatus = 'Online'
                                            and language = 'en_US' and RecordTypeId = :howToRecordTypeId];
        
        
        List<Case> caseList = new List<Case>();
        Contact aContact = ESDJC_AssignmentHelper.getContacts(1, 'Americas - USA', 'San Francisco', 'United States')[0];//ESDJC_TestUtil.getContact();        
        Case aCase = createCase(aContact.Id);
        Case bCase = createCase(aContact.Id);
        Case cCase = createCase(aContact.Id);
        Case dCase  = createCase(aContact.Id);
        Case eCase = createCase(aContact.Id);         
        caseList.add(aCase);
        caseList.add(bCase);
        caseList.add(cCase);
        caseList.add(dCase);
        caseList.add(eCase);
        insert caseList;   
        
        List<CaseArticle> caseArticles = new List<CaseArticle>();
        caseArticles.add(new CaseArticle(caseId=aCase.id, KnowledgeArticleId=publishedHowTos[0].knowledgeArticleId));
        caseArticles.add(new CaseArticle(caseId=bCase.id, KnowledgeArticleId=publishedHowTos[0].knowledgeArticleId));
        caseArticles.add(new CaseArticle(caseId=cCase.id, KnowledgeArticleId=publishedHowTos[0].knowledgeArticleId));
        caseArticles.add(new CaseArticle(caseId=dCase.id, KnowledgeArticleId=publishedHowTos[1].knowledgeArticleId));
        caseArticles.add(new CaseArticle(caseId=eCase.id, KnowledgeArticleId=publishedHowTos[2].knowledgeArticleId));
        insert caseArticles;
        
        Test.startTest();
        Concierge_Article_Feedback__c fb1 = new Concierge_Article_Feedback__c(Concierge_Feedback_Case__c = aCase.id);
        Concierge_Article_Feedback__c fb2 = new Concierge_Article_Feedback__c(Concierge_Feedback_Case__c = bCase.id);
        Concierge_Article_Feedback__c fb3 = new Concierge_Article_Feedback__c(Concierge_Feedback_Case__c = cCase.id);
        Concierge_Article_Feedback__c fb4 = new Concierge_Article_Feedback__c(Concierge_Feedback_Case__c = dCase.id);
        Concierge_Article_Feedback__c fb5 = new Concierge_Article_Feedback__c(Concierge_Feedback_Case__c = eCase.id);
        List<Concierge_Article_Feedback__c> feedbackList = new List<Concierge_Article_Feedback__c>();
        feedbackList.add(fb1); feedbackList.add(fb2); feedbackList.add(fb3);feedbackList.add(fb4);feedbackList.add(fb5);
        insert feedbackList;
        Test.stopTest();
        
        for (Concierge_Article_Feedback__c fb : [select id, Concierge_Total_Attached_Cases__c 
                                                 from Concierge_Article_Feedback__c]) {
            
            if (fb.id == fb1.id) {
                System.assertEquals(3, fb.Concierge_Total_Attached_Cases__c);
            }

            if (fb.id == fb2.id) {
                System.assertEquals(3, fb.Concierge_Total_Attached_Cases__c);
            }
            if (fb.id == fb3.id) {
                System.assertEquals(3, fb.Concierge_Total_Attached_Cases__c);
            }
            if (fb.id == fb4.id) {
                System.assertEquals(1, fb.Concierge_Total_Attached_Cases__c);
            }
            if (fb.id == fb5.id) {
                System.assertEquals(1, fb.Concierge_Total_Attached_Cases__c);
            }
         }
    }
    
    private static Case createCase(Id cid) {
        Case c = new Case(contactid = cid);
        return c;
    }
    private static Knowledge__kav createArticle(String title, String question, String solution, String url, boolean doInsert,
                                            String reviewCycle, String ownerGroup,Id recTypeId) {
        Knowledge__kav howto = new Knowledge__kav();
        howto.Title = title;
        howto.Question__c = question;
        howto.Solution__c = solution;
        howTo.Language = 'en_US';
        howto.UrlName = url;
        howto.Review_Cycle__c = reviewCycle;
        howto.Article_Owner_Group__c = ownerGroup;
        howto.RecordTypeId = recTypeId;
        if (doInsert) {
            insert howto;   
        }
        return howto;                
    }
}