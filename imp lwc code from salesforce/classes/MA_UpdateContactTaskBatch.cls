/**
* @description       : Batch apex to update Acquisition Contact Tasks. It is called from MA_ACTaskTriggerHandler
* @author            : Satyam Kumar
* Modifications Log 
* Ver   Date         Author          Modification
* 1.0   11-09-2021   Satyam Kumar   Initial Version
* */
global without sharing class MA_UpdateContactTaskBatch implements Database.Batchable<sObject>, Database.stateful{
    
    public Map<Id, Boolean> companyTaskIdStatusChangedMap;
    public Map<Id, Acquisition_Company_Task__c> updatedTasks;
    Set<Id> companyTaskIds;
    
    global MA_UpdateContactTaskBatch(Map<Id, Boolean> companyTaskIdStatusChanged, Map<Id, Acquisition_Company_Task__c> updatedCompanyTasks) {
        companyTaskIdStatusChangedMap = companyTaskIdStatusChanged;
        updatedTasks = updatedCompanyTasks;
        companyTaskIds = companyTaskIdStatusChanged.keySet();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, Acquisition_Contact__c, Description__c, Due_Date__c, Category__c,'
                                        +'Priority__c, Status__c, Subject__c, Acquisition_Company_Task__c, Required__c, Task_Context__c'
                                        +' FROM Acquisition_Contact_Task__c Where Acquisition_Company_Task__c IN: companyTaskIds');
    }
    
    global void execute(Database.BatchableContext BC, List<Acquisition_Contact_Task__c> scope){
        try 
        {
            List<Acquisition_Contact_Task__c> contactTasksToUpdate = new List<Acquisition_Contact_Task__c>();
            List<MA_Slack_Notification__e> slackNotificationToInsert = new List<MA_Slack_Notification__e>();

            //Loop over Acquisition Contact Task
            for(Acquisition_Contact_Task__c acqContactTask: scope) 
            {
                contactTasksToUpdate.add(MA_Util.getUpdatedAcquisitionContactTask(updatedTasks.get(acqContactTask.Acquisition_Company_Task__c), acqContactTask, companyTaskIdStatusChangedMap.get(acqContactTask.Acquisition_Company_Task__c)));
            }
            
            //Updated Tasks
            if(contactTasksToUpdate != null && !contactTasksToUpdate.isEmpty()) {
                Database.SaveResult[] taskResultList = Database.update(contactTasksToUpdate,false);
                for(Integer i=0; i<taskResultList.size();i++)
                {
                    Database.SaveResult result = taskResultList.get(i);
                    if(!result.isSuccess()){
                        PF_Logger.log('MA','ERROR',String.valueOf(result.getErrors()),null,'Error during Contact Task record update on Acquisition_Contact_Task__c', 'MA_UpdateContactTaskBatch');
                    } else {
                        MA_Slack_Notification__e slackNotification = new MA_Slack_Notification__e();
                        slackNotification.Acquisition_Contact_Task_Id__c = taskResultList.get(i).id;
                        slackNotification.Is_Insert__c = false;
                        slackNotificationToInsert.add(slackNotification);
                    }
                }
            }
            
            //Call method to publish events
            if(slackNotificationToInsert != null && !slackNotificationToInsert.isEmpty()) {
                Database.SaveResult[] notificationResultList = EventBus.publish(slackNotificationToInsert);
                for(Integer i=0; i<notificationResultList.size();i++)
                {
                    Database.SaveResult result = notificationResultList.get(i);
                    if(!result.isSuccess()){
                        PF_Logger.log('MA','ERROR',String.valueOf(result.getErrors()),null,'Error during MA_Slack_Notification__e event publish', 'MA_UpdateContactTaskBatch');
                    }
                }
            }
            
            //Insert error log for failed records
            if(PF_Logger.logs.size() > 0)
            {
                PF_Logger.createLogs(PF_Logger.logs);
            }
            
        } catch(Exception e)
        {
            PF_Logger.log('MA','ERROR',e.getMessage(),null,'Error during Contact Task record update on Acquisition_Contact_Task__c. Error Trace : ' + e.getStackTraceString(), 'MA_UpdateContactTaskBatch');
            PF_Logger.createLogs(PF_Logger.logs);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        //execute neccessary actions on finish
        
    } 
}