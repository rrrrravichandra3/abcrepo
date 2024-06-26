public with sharing class ESDJC_ReplyHandler {
    
    private static final ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();

    /*
    * Method which gets all cases associated with the replies and set their
    * status to Updated if they were in a "waiting for response" status.
    */
    public static void updateCaseStatusOnInsert(List<Reply> newRecords)
    {

        if(Schema.Sobjecttype.Case.isUpdateable()){
            //get all question Id's
            Set<Id> questionIds = ESDJC_CollectionHelper.getIdFieldSet(newRecords, 'QuestionId');
            
            //get all cases given question Ids
            List<Case> cases = [SELECT Id, Status, ES_DJC_Employee_Number__c, Contact.Id FROM Case WHERE QuestionId IN :questionIds AND Status = 'Waiting for Response'];
            
            //get the user profile so that we can get its associated contact ID
            User user = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            
            //go through cases and update status
            for (Case cse: cases)
            {
                
                //ensure case is owned by the same employee sending the reply           
                if (cse.Contact.Id == user.ContactId)
                {
                    cse.Status = 'Updated';
                }
            }
            
            update cases;
        } else {
            ESDJC_Util.displayAccessPrivilegeError('Update Case');
        }
    }
    
    /*
    * Method which gets all cases associated with the replies and set their
    * status ES_DJC_New_Reply_post_Case_closure__c to true when new reply comes after case is closed . 
    

    public static void updateCaseNewReplyOnInsert(List<Reply> newRecords)
    {
        
        if(Schema.Sobjecttype.Case.isUpdateable()){
            //get all question Id's
            Set<Id> questionIds = ESDJC_CollectionHelper.getIdFieldSet(newRecords, 'QuestionId');
            
            //get all cases given question Ids and where case is closed
            List<Case> cases = [SELECT Id, Status, ES_DJC_Employee_Number__c, Contact.Id FROM Case WHERE QuestionId IN :questionIds AND Status = 'Closed'];
            
            //get the user profile so that we can get its associated contact ID
            User user = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            
            //go through cases and update status
            for (Case cse: cases)
            {
    
                //ensure case is owned by the same employee sending the reply           
                if (cse.Contact.Id == user.ContactId)
                {
                    cse.ES_DJC_New_Reply_post_Case_closure__c = true;
                }
            }
    
            update cases;
        } else {
            ESDJC_Util.displayAccessPrivilegeError('Update Case');
        }
    }
    
    */
    
    
    
    /*  when public response is added by empployee or case owner/es rep, then copy to case comment, also change status to re-open 
        when employee adds a comment after case is closed. 
    */
    
    
   public static void AddCaseCommentsOnInsert(List<Reply> newRecords)
    {
        
        // if(Schema.Sobjecttype.Case.isUpdateable()){
        //get all question Id's
        Set<Id> questionIds = ESDJC_CollectionHelper.getIdFieldSet(newRecords, 'QuestionId');
        
        //get all cases given question Ids and where case is closed
        List<Case> cases = [SELECT Id, QuestionId,Status, ES_DJC_Employee_Number__c, contactId FROM Case WHERE QuestionId IN :questionIds ];
        Map<Id,Case> questionToCaseMap = new Map<Id,Case>();
        for(Case c : cases ){
            questionToCaseMap.put(c.QuestionId,c);
        }
        
        //get the user profile so that we can get its associated contact ID
        User user = [SELECT Id,profile.userlicense.name, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        
        List<CaseComment> caseComments = new List<CaseComment>();
        for(Reply re : newRecords){
            if(questionToCaseMap.get(re.questionId)!=null){
               
                String commentBody = re.Body.unescapeHtml4();
                if( (user.profile.userlicense.name.equals('Customer Portal Manager Custom') && (user.contactId==questionToCaseMap.get(re.questionId).contactId)) || (!user.profile.userlicense.name.equals('Customer Portal Manager Custom')) ){
                  CaseComment cc = new CaseComment(ParentId= questionToCaseMap.get(re.questionId).Id, CommentBody=commentBody.replace('<br>','\n'),isPublished=true);
                  caseComments.add(cc);
                }
            }
        }
        
        if(Schema.sObjectType.CaseComment.isCreateable()){
            if(caseComments!=null && caseComments.size()>0){
                
                if(user.profile.userlicense.name.equals('Customer Portal Manager Custom')){
                    Database.DMLOptions dlo = new Database.DMLOptions(); 
                    dlo.EmailHeader.triggerUserEmail = true; 
                    database.insert(caseComments, dlo);
                }
                else{
                    insert caseComments;
                } 
            }
        }
        
        
        
        
        else {
            ESDJC_Util.displayAccessPrivilegeError('Insert Case Comment');
        }
    }
    

    public static void updateCaseResponseFlag(List<Reply> replies){

        if(!UserInfo.getProfileId().contains(settings.Portal_User_Profile_Id__c) && !UserInfo.getProfileId().contains(settings.Concierge_API_User_Profile_Id__c)){
            Set<Id> questionIds = ESDJC_CollectionHelper.getIdFieldSet(replies, 'QuestionId');
            List<Case> cases = [SELECT Id FROM Case WHERE QuestionId IN :questionIds];

            Set<Id> caseIds = ESDJC_CollectionHelper.getIdFieldSet(cases, 'Id');
            ESDJC_CaseHandler.updateCaseResponseFlag(caseIds);
        }
    }
    
    public static void notifySubscribers(List<Reply> newReplyRecords) {
        System.debug('+++notifySubscribers');
        Set<Id> questionIds = ESDJC_CollectionHelper.getIdFieldSet(newReplyRecords, 'QuestionId');
        List<Question> questions = [SELECT id, Body, Title, CreatedById from Question WHERE id IN: questionIds];
        Map<Id, Question> id2QuestionMap = new Map<Id, Question>();
        for(Question q: questions) {
            id2QuestionMap.put(q.Id, q);
        }
        
        List<QuestionSubscription> subscriptions = ESDJC_Util.getQuestionSubscribers(questionIds);
        
        Map<Id, Set<Id>> subscriberToQuestionIds = new Map<Id, Set<Id>>();
        
        for (QuestionSubscription qs : subscriptions) {
        	if (!subscriberToQuestionIds.containsKey(qs.SubscriberId)) {
        		subscriberToQuestionIds.put(qs.SubscriberId, new Set<Id>());
        	}
        	subscriberToQuestionIds.get(qs.SubscriberId).add(qs.QuestionId);
        }
        
        for (Reply r : newReplyRecords) {
        	
        	if (settings != null && settings.Portal_User_Profile_Id__c != null && UserInfo.getProfileId().contains(settings.Portal_User_Profile_Id__c)) {
        		continue;
        	}
        	if (!subscriberToQuestionIds.containsKey(r.CreatedById)) {
        		subscriberToQuestionIds.put(r.CreatedById, new Set<Id>());
        	}
        	subscriberToQuestionIds.get(r.CreatedById).add(r.QuestionId);
        }
        
        List<User> subscribers = ESDJC_Util.fetchUserDetails(subscriberToQuestionIds.keySet());
        Map<Id, List<User>> questionToUsersMap = new Map<Id, List<User>>();
        
        for (User u : subscribers) {
        	Set<Id> qIds = subscriberToQuestionIds.get(u.Id);
        	if (qIds != null) {
        		for (Id qId : qIds) {
        			if (!questionToUsersMap.containsKey(qId)) {
        				questionToUsersMap.put(qId, new List<User>());
        			}
        			questionToUsersMap.get(qId).add(u);
        		}
        	}
        }
        
        List<Question> allQuestions = new List<Question>();
        List<Reply> allReplies = new List<Reply>();
        List<List<User>> allSubscribers = new List<List<User>>();
        
        for (Reply r : newReplyRecords) {
        	if (questionToUsersMap.get(r.QuestionId) != null) {
        		if (id2QuestionMap.containsKey(r.QuestionId) && questionToUsersMap.containsKey(r.QuestionId) && questionToUsersMap.get(r.QuestionId).size() > 0) {
        			allQuestions.add(id2QuestionMap.get(r.QuestionId));
        			allReplies.add(r);
        			allSubscribers.add(questionToUsersMap.get(r.QuestionId));
        		}
        	}
        }
        
        if (questions.size() > 0) {
        	ESDJC_Util.notifyReplyEmail(allQuestions, allReplies, allSubscribers);
        }

    }
    
}