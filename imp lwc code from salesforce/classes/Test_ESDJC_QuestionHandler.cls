@isTest(SeeAlldata = true)
public with sharing class Test_ESDJC_QuestionHandler {
    public static testMethod void testUpdateStatusOnClose()
    {
        List<RecordType> rtypes = [SELECT Name, Id From RecordType WHERE sObjectType='Contact' AND Name = 'Employee' AND isActive=true];
        
        // create test account
        Account acc = new Account(Name = 'Test Account For unit tests', Phone = '(312)111 2222', 
                                    BillingStreet = 'Test Street', BillingCity = 'Chicago', 
                                    BillingPostalCode = '60605', BillingState = 'IL');
        
        // insert account
        insert acc;
                
        // refesh account
        acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account For unit tests' limit 1 ];
        
        System.assert(acc != null);
        
        //create contact
        Contact cont = new Contact(RecordTypeId = rTypes[0].Id, LastName = 'LastNameQHT',
                                    AccountId = acc.Id);
        
        insert cont;
        
        //refresh contact
        cont = [SELECT Id, Name FROM Contact WHERE LastName = 'LastNameQHT'];
        System.assert(cont != null);
        
        //get community
        Community aCommunity = [Select id FROM Community WHERE IsActive = true Limit 1];
        
        Test.startTest();
        //create questions
        Question ques = null;
        List<Question> questions = new List<Question>();
        for (integer i = 0; i < 20; i++)
        {
            ques = new Question(CommunityId = aCommunity.Id, Title = 'Test Title ' + i);
            questions.add(ques);
        }
        insert questions;
        
        //refresh questions
        questions = [SELECT Id, CommunityId FROM Question where id IN :questions];
        System.assert(questions.size() == 20);
        
        
        //create a list of cases
        List<Case> cases = new List<Case>();
        Case cse = null;
        for (integer i = 0; i < 20; i++)
        {
            cse = new Case(Account = acc, ContactId = cont.id, Subject = 'Test Subject ' + i, 
                            Description = 'Description ' + i, Tier__c = 'Tier 1', QuestionId = questions[i].Id,
                          type = '401K/RRSP', ES_DJC_Topic__c='topic', ES_DJC_Sub_topic__c = 'sub-topic', origin = 'web');
            cases.add(cse);
        }
        
        insert cases;               
        
        //update cases to Closed
        for (integer i = 0; i < cases.size(); i++)
        {
            cases[i].Status = 'Closed';
        }
        
        update cases;
        Test.stopTest();
        //refresh cases and verify escalation user set.
        questions = [SELECT Id, Title, CommunityId, Status__c FROM Question where id IN :questions];
        
        for (Question q: questions)
        { 
            System.assertEquals('Resolved',q.Status__c);
        }
        
        delete questions;

    }
    
    public static testMethod void test_chatter_answers_question_escalation_to_case_trigger(){
        Community aCommunity = [Select id FROM Community WHERE IsActive = true Limit 1];
        
        Question aQuestion = new Question();
        aQuestion.CommunityId = aCommunity.id;//'09a70000000CrO7AAK';//
        aQuestion.title = 'This is my test title';
        insert aQuestion;
        
        QuestionDataCategorySelection topic = new QuestionDataCategorySelection();
        topic.ParentId = aQuestion.Id;
        topic.DataCategoryName = 'Benefits';
        topic.DataCategoryGroupName = 'Topic';
        insert topic;

        aQuestion = [SELECT Priority FROM Question WHERE id =: aQuestion.Id];
        System.assertEquals('medium', aQuestion.Priority);
        aQuestion.Priority = 'high';
        update aQuestion;
        
        List<Case> cases = [SELECT Id,QuestionId, type FROM Case WHERE QuestionId =:aQuestion.Id];
        for(Case aCase : cases){
            //System.assertEquals('ESPP', aCase.Type);
        }
        
        System.debug('+++cases='+cases);
    }

}