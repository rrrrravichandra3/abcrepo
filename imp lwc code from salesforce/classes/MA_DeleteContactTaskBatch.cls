/**
 * @description       : Batch apex to delete Acquisition Contact Tasks
 * @author            : Satyam Kumar
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   09-06-2021   Satyam Kumar   Initial Version
**/
global without sharing class MA_DeleteContactTaskBatch implements Database.Batchable<sObject>{
    
    public Set<Id> acqContactTaskDelIdSet;
    
    global MA_DeleteContactTaskBatch(Set<Id> acqContactTaskIdSet) 
    {
        acqContactTaskDelIdSet = acqContactTaskIdSet;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator('Select Id From Acquisition_Contact_Task__c Where Id IN: acqContactTaskDelIdSet');
    }
    
    global void execute(Database.BatchableContext BC, List<Acquisition_Contact_Task__c> scope)
    {
        try 
        {
            //Delete Tasks
            Database.DeleteResult[] taskResultList = Database.delete(scope,false);
            for(Integer i=0; i<taskResultList.size();i++)
            {
                Database.DeleteResult result = taskResultList.get(i);
                if(!result.isSuccess()){
                    PF_Logger.log('MA','ERROR',String.valueOf(result.getErrors()),null,'Error during Contact Task record deletion on Acquisition_Contact_Task__c', 'MA_DeleteContactTaskBatch');
                }
            }
            
            //Insert error log for failed records
            if(PF_Logger.logs.size() > 0)
            {
                PF_Logger.createLogs(PF_Logger.logs);
            }
            
        } catch(Exception e)
        {
            PF_Logger.log('MA','ERROR',e.getMessage(),null,'Error during Contact Task record deletion on Acquisition_Contact_Task__c. Error Trace : ' + e.getStackTraceString(), 'MA_DeleteContactTaskBatch');
            PF_Logger.createLogs(PF_Logger.logs);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        // Logic to be Executed at finish
    } 
    
}