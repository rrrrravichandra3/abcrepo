@isTest
public with sharing class Test_ESDJC_EmailMessageHandler {

    /*   
     * Method which performs unit tests
     */
    static testMethod void runTests()
    {
        // TODO: increase number of cases inserted after refactoring Case Handler
        
        ESDJC_TestUtil.init();
        
        User portalUser = ESDJC_TestUtil.getPortalUser('US', 'Americas - USA');

        //CREATE CASES
        List<Case> cases = new List<Case>();
        
        System.runAs(portalUser) {
            //GET COMMUNITIES
            List<Community> communities = [SELECT Id FROM Community WHERE IsActive = true];
            //CREATE QUESTIONS
            List<Question> questions = new List<Question>();
            Question ques = null;
            for (Integer i = 0; i < 5; i++)
            {
                ques = new Question(Title = 'Question Title ' + i, CommunityId = communities[0].Id, Body = 'Body of question ' + i);
                questions.add(ques);
            }
            
            insert questions;
    
            //refresh questions
            questions = [SELECT Id, Origin FROM Question];
            System.assert(questions.size() == 5);
            List<Id> questionIds = ESDJC_CollectionHelper.getIdFieldList(questions, 'Id');
            
            for (Integer i = 0; i < 5; i++)
            {
                Case cse = new Case(Subject = 'Test Subject ' + i, 
                                Description = 'Description ' + i,  
                                Status = 'New', Origin = 'Employee Success - Web',  QuestionId = questionIds[i],
                                Type = 'Benefits', ES_DJC_Topic__c = '401K', ES_DJC_Sub_Topic__c = 'Change Amount',
                                ContactId=portalUser.ContactId);
                cases.add(cse);
            }
            insert cases;
        }
        
        
        for (Case c : cases) {
            c.Status = 'Waiting for Response';
        }
        
        update cases;
        
        //refresh cases
        cases = [SELECT Id, Tier__c FROM Case ];
        System.assert(cases.size() == 5);
        
        String contactEmail = [select Email from Contact where Id = :portalUser.ContactId].Email;

        //Insert email responses for the cases - contact creates the email response 
        Test.startTest();
        //CREATE EMAIL RESPONSES
        List<EmailMessage> messages = new List<EmailMessage>();
        EmailMessage message = null;
        for (Integer i = 0; i < 5; i++)
        {
            message = new EmailMessage(ParentId = cases.get(i).Id, Subject = 'New Email Message ' + i, FromAddress = contactEmail);
            messages.add(message);
        }

        insert messages;
        
        //refresh cases
        cases = [SELECT Id, Tier__c, Status FROM Case];
        System.assert(cases.size() == 5);

        for (Case c: cases)
        {
            System.assertEquals('Waiting for Response',c.Status);
        }       
        Test.stopTest();
    }
    
    
    //test for case field updates for : First reponse flag,SLA Expiration warning, First reponse date time. 
    static testMethod void testUpdatecaseResponseFlag() {   
        ESDJC_TestUtil.init();
        ESDJC_TestUtil.createSSOIdSetting();
        User u = ESDJC_TestUtil.getPortalUser('India','EMEA');
        user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission( u.id,'ES_DJC_Employee_APAC');
        }
        Test.startTest();
        Case aCase = new Case();
        aCase.subject='Testing';
        aCase.origin='Employee Success - Web';
        aCase.contactId= [select id,Contactid from user where id =:u.id ].ContactId;
        insert aCase;
        System.assert(aCase.id!=null);
        //List<EmailMessage> emailMessages = new List<EmailMessage>();
        EmailMessage emailMsg_1 = new EmailMessage();
        emailMsg_1.parentId = aCase.Id;
        emailMsg_1.status='1';//status 3 is sent messages (outgoing);
        insert emailMsg_1;
        EmailMessage emailMsg_2 = new EmailMessage();
        emailMsg_2.parentId = aCase.Id;
        emailMsg_2.status='3';//status 3 is sent messages (outgoing);
        insert emailMsg_2;        
        Case c = [select First_Response_Flag__c,ES_DJC_SLA_Expiration_Warning__c from case where id=:aCase.Id];
        System.assertEquals(c.First_Response_Flag__c,true);
        System.assertEquals(c.ES_DJC_SLA_Expiration_Warning__c,false);
        Test.stopTest();
    }
    
    static testMethod void testSendEmailAfterCaseClosure() {
        User sysAdm = ESDJC_TestUtil.getSysAdminUser();
        
        System.runAs(sysAdm) {
            ESDJC_TestUtil.init();
            User portalUser = ESDJC_TestUtil.getPortalUser('US', 'Americas - USA');
            String accountId = [select AccountId from Contact where Id=:portalUser.ContactId].AccountId;
            System.assert(accountId != null);
            ESDJC_TestUtil.createEntitlements(accountId);
            
            String caseId = null;
            
            Test.startTest();
            //Create a case
            System.runAs(portalUser) {
                Case c = new Case(ContactId=portalUser.ContactId, Subject='Test Private Question', Type='Benefits', Description='Test Description', Status='New', Origin='Chatter Answers');
                c.ES_DJC_Topic__c = '401K';
                c.ES_DJC_Sub_Topic__c = 'Change Amount';
                
                insert c;
                caseId = c.Id;
            }
            
            System.assert(caseId != null);
            
            Case c = [select Status, First_Response_Flag__c, Entitlement.Name, EntitlementId from Case where Id=:caseId];
            System.assertEquals('New', c.Status);
            System.assertEquals(false, c.First_Response_Flag__c);
            System.assert(c.EntitlementId != null);
            System.assertEquals('Standard Entitlement', c.Entitlement.Name);
            
            List<CaseMilestone> caseMilestones = [select Id, CompletionDate, CaseId, IsCompleted from CaseMilestone where CaseId = :caseId];
            System.assert(caseMilestones.size() == 1);
            System.assert(caseMilestones[0].IsCompleted == false);
            System.assert(caseMilestones[0].CompletionDate == null);
            
            //Close case
            c.Status = 'Closed';
            update c;
            
            //Refresh Case
            c = [select Status, First_Response_Flag__c, Entitlement.Name, EntitlementId from Case where Id=:caseId];
            System.assertEquals('Closed', c.Status);
            System.assertEquals(false, c.First_Response_Flag__c);
            System.assert(c.EntitlementId != null);
            System.assertEquals('Standard Entitlement', c.Entitlement.Name);
            
            //Refresh milestones
            caseMilestones = [select Id, CompletionDate, CaseId, IsCompleted from CaseMilestone where CaseId = :caseId];
            System.assert(caseMilestones.size() == 1);
            System.assert(caseMilestones[0].IsCompleted == false);
            System.assert(caseMilestones[0].CompletionDate == null);
            
            //Insert an email message
            EmailMessage emailMessage = new EmailMessage(ParentId = caseId, Subject = 'New Email Message');
            insert emailMessage;
            
            //Refresh milestones
            caseMilestones = [select Id, CompletionDate, CaseId, IsCompleted from CaseMilestone where CaseId = :caseId];
            System.assert(caseMilestones.size() == 1);
            System.assert(caseMilestones[0].IsCompleted == false);
            System.assert(caseMilestones[0].CompletionDate == null);
            Test.stopTest();
        }
    }
    
}