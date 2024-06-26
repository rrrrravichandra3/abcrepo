@isTest(SeeAllData=false)
public with sharing class Test_ESDJC_ReplyHandler {

    static testMethod void runTests(){
        init();
        //CREATE ACCOUNT
        Account acc = new Account(Name = 'Test Account for Apex Test', Phone = '(312)111 2222', 
                                    BillingStreet = 'Test Street', BillingCity = 'Chicago', 
                                    BillingPostalCode = '60605', BillingState = 'IL');
        
        //insert account
        insert acc;
                
        //refesh account
        acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account for Apex Test' limit 1];
        
        System.assert(acc != null);
                
        //GET COMMUNITIES
        List<Community> communities = [SELECT Id FROM Community WHERE IsActive = true];
        
        contact amerContact = ESDJC_AssignmentHelper.getContacts(1, 'Americas - USA', 'San Francisco')[0];

        //CREATE QUESTIONS
        List<Question> questions = new List<Question>();
        Question ques = null;
        for (Integer i = 0; i < 200; i++)
        {
            ques = new Question(Title = 'Question Title ' + i, CommunityId = communities[0].Id, Body = 'Body of question ' + i);
            questions.add(ques);
        }
        
        insert questions;

        //refresh questions
        questions = [SELECT Id, Origin FROM Question WHERE Title LIKE '%Question Title%'];
        System.assert(questions.size() == 200);
        List<Id> questionIds = ESDJC_CollectionHelper.getIdFieldList(questions, 'Id');


        //CREATE CASES
        List<Case> cases = new List<Case>();
        Case cse = null;
        for (Integer i = 0; i < 200; i++){
            cse = new Case(Subject = 'Test Subject ' + i, contactId = amerContact.id, 
                            Description = 'Description ' + i, 
                            Status = 'Waiting for Response', Origin = 'Chatter Answers',  QuestionId = questionIds[i], Type='ESPP',
                            ES_DJC_Topic__c = 'How to Enroll', ES_DJC_Sub_Topic__c = 'New Hire');
            cases.add(cse);
        }        
        
        System.assertEquals(200,cases.size());
        insert cases;
        
        //refresh cases
        cases = [SELECT Id, Tier__c FROM Case WHERE Subject LIKE 'Test Subject%'];
        System.assertEquals(200,cases.size());

        //CREATE REPLIES
        List<Reply> replies = new List<Reply>();
        Reply rep = null;
        for (Integer i = 0; i < 200; i++){
            rep = new Reply(QuestionId = questionIds[i], Body = 'Test Reply Body ' + i);
            replies.add(rep);
        }

        insert replies;

        //refresh cases
        cases = [SELECT Id, Tier__c, Status FROM Case WHERE Subject LIKE 'Test Subject%'];        

        for (Case c: cases){
            System.assertEquals('Waiting for Response',c.Status);
        }       
    }
        
    static testMethod void testNotifySubscribers() {    
        init();
        Community comm = ESDJC_TestUtil.getCommunity();
        Question aQuestion = ESDJC_TestUtil.getQuestion(comm);
               
        //Question aQuestion = new Question(); 
        //aQuestion.Body = 'Test Question';
        //List<Community> communities = [SELECT ID from Community];
        //if(communities.size() > 0){
        //  aQuestion.CommunityId = communities.get(0).Id;
        //}
        //insert aQuestion;
        
        List<User> users = [SELECT id from User WHERE Profile.Name='Customer Portal Manager Custom'];
        if(users.size() > 0) {
            QuestionSubscription subscription = new QuestionSubscription();
            subscription.QuestionId = aQuestion.Id;
            subscription.SubscriberId = users.get(0).Id;
            insert subscription;
        }

        Reply aReply = new Reply();
        aReply.Body = 'Reply';
        aReply.QuestionId = aQuestion.Id; 
        //insert aReply; 
    }               
    
    private static void init(){
        ESDJC_Settings__c setting = new ESDJC_Settings__c();
        setting.Run_trigger__c = true;
        setting.Site_URL__c = '/site/url';
        setting.Portal_User_Profile_Id__c = '00e70000000xEB1';
        setting.Concierge_API_User_Profile_Id__c = '00en0000000HgEa';
        setting.djc_Helpdesk_API_User__c = '00570000002SpX4AAK';
        setting.Valid_SLA_Origins__c='Web,REWS - Web,Chatter Answers,Personal Email,Concierge';
        setting.Ergo_Locations__c = 'san francisco,new york,chicago,portland,spokane,toronto';
        insert setting;
        REWS_Setting__c rewsSetting = new REWS_Setting__c();
        rewsSetting.Mail_services_queue_Id__c = '00Gn0000000JH8YEAW';
        rewsSetting.Case_Package_Delivery_Record_Type__c = '00Gn0000000JH8YEAW';
        insert  rewsSetting;

    }
    
}