/**
 * @description       : Batch job to update Recruiters on Job App when they are updated on  Job Req
 * @author            : vchokkula@salesforce.com
 * @last modified on  : 05-12-2021
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-12-2021   Vinod Chokkula                         Initial version
**/
public class IFB_JRtoJASync_Batch implements Database.Batchable<sObject> {
    Set<String> JRIdsWithUpdates =  IFB_JR_Id_For_Sync__c.getAll().keyset();

    public Database.QueryLocator start(Database.BatchableContext BC) {

        list<String> jobAppNonSyncStages =  IFB_SIFT_Settings_List__c.getOrgDefaults().JA_Non_Sync_Stages__c.split(',');

        return Database.getQueryLocator ( [SELECT External_Recruiter_1__c,
                                               External_Recruiter_2__c,
                                               Internal_Recruiter_1__c,
                                               Internal_Recruiter_2__c,
                                               SIFT_Group_Lookup__c,
                                               SIFT_Position_Lookup__c,
                                               Is_this_a_SIFT_Interview__c,
                                               Job__r.External_Recruiter_1__c,
                                               Job__r.External_Recruiter_2__c,
                                               Job__r.Internal_Recruiter_1__c,
                                               Job__r.Internal_Recruiter_2__c,
                                               Job__c,
                                               Job__r.SIFT_Group__c,
                                               Job__r.SIFT_Position__c,
                                               Candidate_Stage__c
                                                FROM
                                                WDR_Application__c
                                                WHERE
                                                Job__c 
                                                IN : JRIdsWithUpdates
                                                AND Candidate_Stage__c  NOT IN :jobAppNonSyncStages
                                                ]);        
    }
    public void execute(Database.BatchableContext BC, List<WDR_Application__c> scope) {
        
        String ErrorEmailSubject =  'Batch IFB_JRtoJASync_Batch failed to update Job Application records ';
        Boolean encounteredLimitException = false;
        String excpSubject =  'Batch IFB_JRtoJASync_Batch failed with Exception ';
        String excpMessage =  'Exception while updating Job Applications';
        set<Id> JobReqIdsProcessed = new set<Id>();
        for(WDR_Application__c jobApp: scope){
            jobApp.External_Recruiter_1__c = jobApp.Job__r.External_Recruiter_1__c;
            jobApp.External_Recruiter_2__c = jobApp.Job__r.External_Recruiter_2__c;
            jobApp.Internal_Recruiter_1__c = jobApp.Job__r.Internal_Recruiter_1__c;
            jobApp.Internal_Recruiter_2__c = jobApp.Job__r.Internal_Recruiter_2__c;
            if(jobApp.Is_this_a_SIFT_Interview__c=='Yes' && jobApp.Job__r.SIFT_Group__c!=null){
                jobApp.SIFT_Group_Lookup__c = jobApp.Job__r.SIFT_Group__c;
            } 
            if(jobApp.Is_this_a_SIFT_Interview__c=='Yes'&& jobApp.Job__r.SIFT_Position__c !=null){
                jobApp.SIFT_Position_Lookup__c = jobApp.Job__r.SIFT_Position__c;
            }
            if(jobApp.Is_this_a_SIFT_Interview__c!='Yes' && jobApp.Job__r.SIFT_Group__c!=null && (jobApp.Candidate_Stage__c =='Technical Assessment'|| jobApp.Candidate_Stage__c =='Assessment')){
                jobApp.SIFT_Group_Lookup__c = jobApp.Job__r.SIFT_Group__c;
            } 	
            if(jobApp.Is_this_a_SIFT_Interview__c!='Yes' && jobApp.Job__r.SIFT_Position__c!=null && (jobApp.Candidate_Stage__c =='Technical Assessment'|| jobApp.Candidate_Stage__c =='Assessment')){
                jobApp.SIFT_Position_Lookup__c = jobApp.Job__r.SIFT_Position__c;
            } 	 
            JobReqIdsProcessed.add(jobApp.Job__c)  ; 
         	
       }

         try{
             List<Database.SaveResult> srList = new List<Database.SaveResult>();
             srList = Database.update(scope, false);
            Boolean hasErrors = false;
            String ErrorMessage='';
            Integer i=0;
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    hasErrors = true;
                    for (Database.Error err : sr.getErrors()) {
                        if(err.getMessage().containsIgnoreCase('System.LimitException')){
                            encounteredLimitException = true;
                            ErrorMessage = 'Encountered Limit Exception '+ err.getMessage() + ' while processing following job req Ids '+ '\n'+ String.join(new list<Id>(JobReqIdsProcessed),',');
                            break;
                        }else{
                            ErrorMessage = ErrorMessage + 'The Job app with Id '+ scope[i].Id+' has the Error ' + err.getMessage() + '\n' ;
                        }
                    }
                }
                i++;
            }
            
            if(hasErrors){
                if(encounteredLimitException){
                    throw new  IFB_JRtoJASync_Batch_Exception(ErrorMessage);
                }else{
                    emailException(ErrorMessage,ErrorEmailSubject);            
                }
            }
         } 
         catch(Exception exp){
             if(encounteredLimitException){
                throw new IFB_JRtoJASync_Batch_Exception(exp.getMessage());
             }else{
                excpMessage = excpMessage + exp.getMessage()+ exp.getStackTraceString();
                emailException(excpMessage,excpSubject);
             }

         }
        

    }
    public void finish(Database.BatchableContext BC) { 
        String subject;
        String message;
      // Check batch status - IF COMPLETED then 
     AsyncApexJob job = [SELECT Id, Status,ExtendedStatus
                         FROM AsyncApexJob 
                         WHERE Id = :bc.getJobId()];        

        if(job.Status != 'Failed' && job.Status != 'Aborted' && String.isBlank(job.ExtendedStatus) ) {
        List<IFB_JR_Id_For_Sync__c> JRRecsWithUpdatesDone =  [SELECT name FROM IFB_JR_Id_For_Sync__c 
                                                              where name in :JRIdsWithUpdates];
            try{
                delete JRRecsWithUpdatesDone;
            }
            catch (Exception ex){
                subject =  'Batch IFB_JRtoJASync_Batch failed to delete records from Custom Setting';
                message =  'Exception while deleting the following Ids '+ JRIdsWithUpdates+ 'from Custom Setting - IFB Job Req Id For Sync'+ ex.getMessage()+ ex.getStackTraceString();
                emailException(message,subject);
            }
        }//Notify Eops If Batch Job fails or any unhandled exceptions.
        else if(job.Status == 'Failed' || !(String.isBlank(job.ExtendedStatus))){  
                subject =  'Batch IFB_JRtoJASync_Batch failed with Exception';
                message =  'Batch failed with error '+ job.ExtendedStatus;
                emailException(message,subject);

        }
    }
    

    //Send email to Eops.

    public void emailException(String message,String subject){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String toAddresses = '';
        Organization org = [select Id,IsSandbox from Organization limit 1];
        if(org.IsSandbox){
            subject = 'Org Id:'+ org.Id +' '+subject;
        }
        toAddresses =  IFB_SIFT_Settings_List__c.getOrgDefaults().EmailToCase_Address__c;
            if(!String.isBlank(toAddresses)){
                mail.setToAddresses(toAddresses.split(','));
                mail.setSubject(subject);
                mail.setPlainTextBody(message);
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
            }
    }
    public class IFB_JRtoJASync_Batch_Exception extends Exception {
                        
    }
}