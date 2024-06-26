/*
*  @Author : Kshitiz Srivastava
*  W-4666152 - SIFT Refactoring
*  This batch job is to be run once for April A release
*  After refactoring, Interview Question object will no longer use following fields -
*  Domain__c (to be replaced by Competency__c)
*  Group__c (to be replaced by SIFT_Group_Lookup__c)
*  Question_Category__c (to be replaced by Question_Category_Text__c)
*  This batch job updates the new fields with values of old fields, so that legacy data keeps working
*/
global class IFB_Batch_UpdateInterviewQuestions implements Database.Batchable<sObject>, Database.Stateful{
    
    Integer successfulUpdateCount = 0;
    Map<String, Id> siftGroupNameToIdMap = new Map<String, Id>();
    Map<String, String> failedInterviewQuestionRecords = new Map<String, String>();

    global IFB_Batch_UpdateInterviewQuestions(){
        //get all existing reocrds of SIFT Groups
        List<SIFT_Group__c> siftGroups = [Select Id, Name from SIFT_Group__c];
        for(SIFT_Group__c sg : siftGroups){
            siftGroupNameToIdMap.put(sg.Name, sg.Id);
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String queryString = 'Select Id, External_Id__c, Domain__c, Competency__c, Group__c, SIFT_Group_Lookup__c, Question_Category__c, Question_Category_Text__c from IFB_Interview_Question__c';
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext BC, List<IFB_Interview_Question__c> scope){
        List<IFB_Interview_Question__c> intvQuestionsToBeUpdated = new List<IFB_Interview_Question__c>();

        for(IFB_Interview_Question__c currIntvQuestion : scope){
            if(!String.isBlank(currIntvQuestion.Group__c)){
                if(!siftGroupNameToIdMap.containsKey(currIntvQuestion.Group__c)){
                    failedInterviewQuestionRecords.put(currIntvQuestion.External_Id__c,'Cannot find a SIFT Group with Name '+currIntvQuestion.Group__c);
                    continue;
                }else{
                    currIntvQuestion.SIFT_Group_Lookup__c = siftGroupNameToIdMap.get(currIntvQuestion.Group__c);
                }
            }
            if(!String.isBlank(currIntvQuestion.Domain__c)){
                currIntvQuestion.Competency__c = currIntvQuestion.Domain__c;
            }
            if(!String.isBlank(currIntvQuestion.Question_Category__c)){
                currIntvQuestion.Question_Category_Text__c = currIntvQuestion.Question_Category__c;
            }
            intvQuestionsToBeUpdated.add(currIntvQuestion);
        }

        Database.SaveResult[] updateResult = Database.Update(intvQuestionsToBeUpdated,false);

        for(Integer i=0;i<updateResult.size();i++){
            if(updateResult.get(i).isSuccess()){
                successfulUpdateCount ++;
            }else{
                String failedIntvQuestionExternalId = String.ValueOf((scope.get(i)).External_Id__c);
                String errorMessage = '';
                for(Database.Error err : updateResult.get(i).getErrors()){
                    errorMessage = errorMessage + ' | ' + err.getMessage();
                }
                failedInterviewQuestionRecords.put(failedIntvQuestionExternalId,errorMessage);
            }
        }
    }

    global void finish(Database.BatchableContext BC){
        //list of recipients for email
        List<String> emailIds = new List<String>();
        emailIds.add('ksrivastava@salesforce.com');
        //get the emails stored in custom setting
        String emailIdsFromCustomSetting = IFB_SIFT_Settings_List__c.getInstance('SIFT').IFB_WD_Integration_Downstream_Err_Emails__c;
        if(!String.isEmpty(emailIdsFromCustomSetting)){
            emailIds.addAll(emailIdsFromCustomSetting.split(','));
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(emailIds);
        mail.setSenderDisplayName('SIFT Interview Questions Update Batch');
        mail.setSubject('Batch IFB_Batch_UpdateInterviewQuestions results');

        String message = successfulUpdateCount + ' SIFT Interview Question Records updated successfully';
        if(!failedInterviewQuestionRecords.isEmpty()){
            message = message + '\nFollowing ' + failedInterviewQuestionRecords.size() +' Interview Question Records Failed to Update :\n';
            for(String intvName : failedInterviewQuestionRecords.keySet()){
                message = message +'\n'+intvName + ' : '+failedInterviewQuestionRecords.get(intvName);
            }
        }
        mail.setPlainTextBody(message);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
    }

}