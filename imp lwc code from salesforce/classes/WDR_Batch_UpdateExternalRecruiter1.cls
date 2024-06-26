/*
* 
*  @Author : Kshitiz Srivastava
*  W-5467905 - Integration Prep Work for Workday to Peopleforce WDR objects
*  This batch job is to be run once for Dec A release
*  Field WDR_Job__c.Recruiter__c is replaced with WDR_Job__c.External_Recruiter_1__c
*  This batch job backfills the field External_Recruiter_1__c for legacy data
*/
global class WDR_Batch_UpdateExternalRecruiter1 implements Database.Batchable<sObject>, Database.Stateful{
    
    Integer successfulUpdateCount = 0;
    Map<String, String> failedUpdates = new Map<String, String>();

    global WDR_Batch_UpdateExternalRecruiter1(){

    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String queryString = 'Select Id, Name,Recruiter__c, External_Recruiter_1__c from WDR_Job__c where Recruiter__c != null';
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext BC, List<WDR_Job__c> jobReqs){
        List<WDR_Job__c> jobReqsToBeUpdated = new List<WDR_Job__c>();
        for(WDR_Job__c currentJobReq : jobReqs){
            if(currentJobReq.External_Recruiter_1__c != currentJobReq.Recruiter__c){
                currentJobReq.External_Recruiter_1__c = currentJobReq.Recruiter__c;
                jobReqsToBeUpdated.add(currentJobReq);
            }
        }

        Database.SaveResult[] updateResult = Database.Update(jobReqsToBeUpdated,false);

        for(Integer i=0;i<updateResult.size();i++){
            if(updateResult.get(i).isSuccess()){
                successfulUpdateCount ++;
            }else{
                String failedJobReqName = String.ValueOf((jobReqs.get(i)).Name);
                String errorMessage = '';
                for(Database.Error err : updateResult.get(i).getErrors()){
                    errorMessage = errorMessage + ' | ' + err.getMessage();
                }
                failedUpdates.put(failedJobReqName,errorMessage);
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
        mail.setSenderDisplayName('WDR Update Batch Job');
        mail.setSubject('Batch WDR_Batch_UpdateExternalRecruiter1 results');

        String message = successfulUpdateCount + ' WD Job Requisition Records updated successfully';
        if(!failedUpdates.isEmpty()){
            message = message + '\nFollowing ' + failedUpdates.size() +' WD Job Req Records Failed to Update :\n';
            for(String jobReqName : failedUpdates.keySet()){
                message = message +'\n'+jobReqName + ' : '+failedUpdates.get(jobReqName);
            }
        }
        mail.setPlainTextBody(message);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
    }

}