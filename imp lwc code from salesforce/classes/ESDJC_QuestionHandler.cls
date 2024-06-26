public with sharing class ESDJC_QuestionHandler {
//public without sharing class ESDJC_QuestionHandler {
    
    /*
     * Method which updates all cases associated to the replies to the closed
     * status if the reply was marked as "Best Reply". 
     */
    public static void updateCaseStatusOnUpdate(List<Question> newRecords, Map<Id, Question> oldRecords)
    {
        
        if(Schema.Sobjecttype.Case.isUpdateable()){
            List<Question> updatedQuestions = new List<Question>();
            
            //get all questions that have had their best reply set.
            for (Question ques: newRecords)
            {
                //if we have a best reply and we didn't have a best reply before.
                if (ques.BestReplyId != null && oldRecords.get(ques.Id).BestReplyId == null)
                {
                    updatedQuestions.add(ques);
                }
            }
            
            //get the question Ids associated with the questions.
            Set<Id> questionIds = ESDJC_CollectionHelper.getIdFieldSet(updatedQuestions, 'Id');
            
            //get the cases associated with the questions
            List<Case> cases = [SELECT Id, Status FROM Case WHERE QuestionId IN :questionIds];
            
            //update all case status to Closed.
            for (Case cse: cases)
            {
                cse.Status = 'Closed';
            }
            
            update cases;
        } else {
            ESDJC_Util.displayAccessPrivilegeError('Update Case');
        }
        
    }
    
    /*
     * Method which updates case details when a question is deleted.  This includes
     * setting values to allow workflow to fire an email to the employee. 
     */
    public static void updateCaseStatusOnDelete(List<Question> oldRecords)
    {
        
        if(Schema.Sobjecttype.Case.isUpdateable()){
            //are we delaing with an employee or team member
            Profile profile = [SELECT Id, Name FROM Profile WHERE Name = 'Customer Portal Manager Custom'];
            Boolean isEmployee = false;
            if (UserInfo.getProfileId() == profile.Id)
            {
                isEmployee = true;
            }
                    
            //get the question Ids associated with the questions.
            Set<Id> questionIds = ESDJC_CollectionHelper.getIdFieldSet(oldRecords, 'Id');
            
            //get the cases associated with the questions
            List<Case> cases = [SELECT Id, Status, QuestionId, OwnerId FROM Case WHERE QuestionId IN :questionIds];
            Set<Id> caseOwnerIds = ESDJC_CollectionHelper.getIdFieldSet(cases, 'OwnerId');
            Map<Id, SObject> casesByQuestionId = ESDJC_CollectionHelper.getSimpleIdMappedObjects(cases, 'QuestionId');
            List<User> owners = null;
            Map<Id, SObject> usersById = null;
            
            //get the created by Ids associated with the questions.
            Set<Id> CreatedByIds = ESDJC_CollectionHelper.getIdFieldSet(oldRecords, 'CreatedById');
            Map<id, User> CreatedByIdMapToUser = new Map<Id, User>([select id, LanguageLocaleKey,Email  from user where id in :CreatedByIds]);
            
            if (cases.size() > 0)
            {
                //get the owners associated with the cases
                owners = [SELECT Id, Email FROM User WHERE ID = :caseOwnerIds];
                usersById = ESDJC_CollectionHelper.getSimpleIdMappedObjects(owners, 'Id');
            }           
            //update case details.
            for (Question question: oldRecords)
            {
                
                String language = CreatedByIdMapToUser.get(question.CreatedById).LanguageLocaleKey;
                String user_email = CreatedByIdMapToUser.get(question.CreatedById).Email;
                
                if (language==null){
                    language = 'en_US';
                }
                //IS AN EMPLOYEE
                if (isEmployee)
                {
                    
                    //IS AN ASSOCIATED CASE
                    if (casesByQuestionId.get(question.Id) != null)
                    {                       
                        Case cse = (Case) casesByQuestionId.get(question.Id);
                        cse.Status = 'Closed';
                        cse.ES_DJC_Is_Question_Deleted__c = true;
                        cse.ES_DJC_Question_Deleted_By__c = 'Employee';
                        
                        //send email
                        // commenting out as per story W-2153430
                        /*if(cse != null && cse.OwnerId != null && usersById.get(cse.OwnerId) != null){
                            String email = ((User) usersById.get(cse.OwnerId)).Email;                           
                            sendEmail('ES DJC Question Deletion Email to Case Owner', email, cse.OwnerId);
                        }*/
                    }
                
                //IS NOT AN EMPLOYEE
                } else {                    
                    //IS AN ASSOCIATED CASE
                    if (casesByQuestionId.get(question.Id) != null)
                    {                       
                        //update case
                        Case cse = (Case) casesByQuestionId.get(question.Id);
                        cse.ES_DJC_Question_Deleted_By__c = 'ES Team Member';
                        cse.ES_DJC_Is_Question_Deleted__c = true;
                    
                        //send email 
                        // commenting out as per story W-2153430                       
                        /*if(language.equalsIgnoreCase('ja')){                            
                            sendEmail('ES DJC Question Deletion Email to Employee(Japanese)', user_email, question.CreatedById);
                        }
                        else{                           
                            sendEmail('ES DJC Question Deletion Email to Employee', user_email, question.CreatedById);
                        }*/
                    
                    } 
                    //send email
                        // commenting out as per story W-2153430
                    /*else {
                        
                        
                        if(language.equalsIgnoreCase('ja')){                            
                            sendEmail('ES DJC Question Deletion Email to Employee(Japanese)', user_email, question.CreatedById);
                        }
                        else{                                                       
                            sendEmail('ES DJC Question Deletion Email to Employee', user_email, question.CreatedById);
                        }
                        
                    }*/
                
                }
                
            }
            
            //update cases;
        } else {
            ESDJC_Util.displayAccessPrivilegeError('Update Case');
        }
        
    }
    
    /*
     * Method to send an email to a user given a template name and the email address.
     * Note that currently no merging of fields takes place.  It assumes that there
     * are no fields that need to be merged.
     */
    private static void sendEmail(String templateName, String email, String targetObjectId)
    {
        
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE Name = :templateName];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> emailAddresses = new List<String>();
        emailAddresses.add(email);
        mail.setToAddresses(emailAddresses);
        mail.setTemplateId(template.Id);
        mail.setTargetObjectId(targetObjectId);
        mail.setSaveAsActivity(false);
        if (!Test.isRunningTest()) 
        {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
    }

        
    public static void chatter_answers_question_escalation_to_case_trigger (List<Question> questions, Map<Id, Question> oldQuestions) {
        List<ESDJC_QuestionTopic2CaseType_Mapping__c> topic2caseList = [SELECT Question_Topic__c, Case_Type__c from ESDJC_QuestionTopic2CaseType_Mapping__c];
        Map <String, ESDJC_QuestionTopic2CaseType_Mapping__c> topic2caseMapping = new Map <String, ESDJC_QuestionTopic2CaseType_Mapping__c>();
        for(ESDJC_QuestionTopic2CaseType_Mapping__c t2c : topic2caseList){
            topic2caseMapping.put(t2c.Question_Topic__c, t2c);
        }
        
        Map<Id,Question> questionMap = new Map<Id, Question>();
        for(Question q: questions){
            questionMap.put(q.Id, q);
        }
        List<QuestionDataCategorySelection> qdcss = [SELECT ParentId, DataCategoryName FROM QuestionDataCategorySelection WHERE ParentId IN :questionMap.keySet()];
    
        Map <Id, QuestionDataCategorySelection> question2qdcsMapping = new Map <Id, QuestionDataCategorySelection>();
        for(QuestionDataCategorySelection qdcs : qdcss){
            question2qdcsMapping.put(qdcs.ParentId, qdcs);
        }
        
        List<Case> cases = [SELECT QuestionId, Id FROM Case WHERE QuestionId IN: questionMap.keySet()];
        Map<Id,Case> qId2CaseMap = new Map<Id, Case>();
        for(Case aCase: cases){
            if(aCase.QuestionId != null){
                qId2CaseMap.put(aCase.QuestionId, aCase);
            }
        }
        
        for (Question q: questions) {
            QuestionDataCategorySelection topic;
            ESDJC_QuestionTopic2CaseType_Mapping__c caseType;
            try {
                if(Schema.Sobjecttype.Case.isCreateable()){
                    if (q.Priority == 'high' && (q.Cases == null || q.Cases.size() == 0) && qId2CaseMap.get(q.Id) == null && oldQuestions.get(q.id).Priority != 'high') {
                        q = [select Id, Title, Body, CommunityId, createdById, createdBy.AccountId, createdBy.ContactId from Question where Id = :q.Id];
                        Case newCase = new Case(Origin='Chatter Answers', Tier__c='Tier 1', OwnerId=q.CreatedById, QuestionId=q.Id, CommunityId=q.CommunityId, Subject=q.Title, /*Description=q.Body*/ ES_DJC_Description__c=q.Body, AccountId=q.CreatedBy.AccountId, ContactId=q.CreatedBy.ContactId,Question_Type__c='Public');
                        
                        topic = question2qdcsMapping.get(q.Id);
                        if(topic != null && topic.DataCategoryName  != null){
                            caseType = topic2caseMapping.get(topic.DataCategoryName);
                            if(caseType != null && caseType.Case_Type__c != null){
                                newCase.Type = caseType.Case_Type__c;
                                newCase.Tier__c = 'Tier 1';
                            }
                        }
                        
                        /*//Fetching the assignment rules on case
                        //AssignmentRule AR = new AssignmentRule();
                        //AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
                        
                        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                        Database.DMLOptions dmlOpts = new Database.DMLOptions();
                        dmlOpts.assignmentRuleHeader.useDefaultRule = true;
                        //dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
                        newCase.setOptions(dmlOpts);
                        insert newCase;*/
                        
                        
                        //AssignmentRule AR = new AssignmentRule();
                        //AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
                                                    
                        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                        Database.DMLOptions dmlOpts =ESDJC_Util.getAssignmentRulesDMLOption(null);
                        newCase.setOptions(dmlOpts);
                        insert newCase;
                        
                    }
                } else {
                    ESDJC_Util.displayAccessPrivilegeError('Create Case');
                }
            } catch (Exception e) {
                String subjectText = 'Case Escalation exception in site ' + Site.getName();
                String bodyText = 'Case Escalation on Question having ID: ' + q.Id + ' has failed with the following message: ' + e.getMessage() +
                    '\n\nStacktrace: ' + e.getStacktraceString();
    
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] { Site.getAdminEmail() };
    
                mail.setReplyTo('no-reply@salesforce.com');
                mail.setSenderDisplayName('#djc Salesforce Chatter Answers User');
    
                // The default sender is the portal user causing this trigger to run, to change this, set an organization-wide address for
                // the portal user profile, and set the ID in the following line.
                // mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
                mail.setToAddresses(toAddresses);
                mail.setSubject(subjectText);
                mail.setPlainTextBody(bodyText);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }
}