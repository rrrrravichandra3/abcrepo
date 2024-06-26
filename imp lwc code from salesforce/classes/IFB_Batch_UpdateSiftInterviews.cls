/*
*  @Author : Kshitiz Srivastava
*  W-4666152 - SIFT Refactoring
*  This batch job is to be run once for April A release
*  After refactoring, SIFT Interview Object has a new lookup field "Interview_Type__c" which is a lookup to record of Object "SIFT Interview Type"
*  Value of the field needs to be mapped to "SIFT Interview Type" record with same name as current interview's recordType's label
*
*  TODO : Update recordtypes to "Default" once every other code change is done and tested in dev sandbox
*/
global class IFB_Batch_UpdateSiftInterviews implements Database.Batchable<sObject>, Database.Stateful{
    
    Integer successfulUpdateCount = 0;
    Map<String,Id> interviewTypeNameToIdMap = new Map<String,Id>();
    Map<String, String> failedInterviewRecords = new Map<String, String>();

    global IFB_Batch_UpdateSiftInterviews(){
        //get all existing reocrds of SIFT Interview Type
        List<SIFT_Interview_Type__c> existingInterviewTypeRecords = [Select Id, Name from SIFT_Interview_Type__c];
        for(SIFT_Interview_Type__c intvType : existingInterviewTypeRecords){
            interviewTypeNameToIdMap.put(intvType.Name, intvType.Id);
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String queryString = 'Select Id, Name, RecordType.Name, Interview_Type__c from IFB_Interview__c where Interview_Type__r.Id = null';
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext BC, List<IFB_Interview__c> scope){
        List<IFB_Interview__c> intvToBeUpdaed = new List<IFB_Interview__c>();

        for(IFB_Interview__c currIntv : scope){
            Id intvTypeId = interviewTypeNameToIdMap.get(currIntv.RecordType.Name);
            if(intvTypeId == null){
                failedInterviewRecords.put(String.ValueOf(currIntv.Name),'Could not find matching Interview Type Record with name '+currIntv.RecordType.Name);
                continue;
            }
            currIntv.Interview_Type__c = intvTypeId;
            intvToBeUpdaed.add(currIntv);
        }

        Database.SaveResult[] updateResult = Database.Update(intvToBeUpdaed,false);

        for(Integer i=0;i<updateResult.size();i++){
            if(updateResult.get(i).isSuccess()){
                successfulUpdateCount ++;
            }else{
                String failedIntvName = String.ValueOf((scope.get(i)).Name);
                String errorMessage = '';
                for(Database.Error err : updateResult.get(i).getErrors()){
                    errorMessage = errorMessage + ' | ' + err.getMessage();
                }
                failedInterviewRecords.put(failedIntvName,errorMessage);
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
        mail.setSenderDisplayName('SIFT Interview Update Batch');
        mail.setSubject('Batch IFB_Batch_UpdateSiftInterviews results');

        String message = successfulUpdateCount + ' SIFT Interview Records updated successfully';
        if(!failedInterviewRecords.isEmpty()){
            message = message + '\nFollowing ' + failedInterviewRecords.size() +' Interview Records Failed to Update :\n';
            for(String intvName : failedInterviewRecords.keySet()){
                message = message +'\n'+intvName + ' : '+failedInterviewRecords.get(intvName);
            }
        }
        mail.setPlainTextBody(message);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
    }

}