/**
* @description       : Batch apex to create Acquisition Contact Tasks. It is called from MA_ACTaskProcessBatch apex
* @author            : Satyam Kumar
* Modifications Log 
* Ver   Date         Author          Modification
* 1.0   09-06-2021   Satyam Kumar   Initial Version
* */
global without sharing class MA_CreateContactTaskBatch implements Database.Batchable<sObject>, Database.stateful{
    
    public String queryStr;
    public Acquisition_Company_Task__c companyTask;
    public Map<Id,Acquisition_Contact_Task__c> existingContactTaskMap;
    public Set<Id> taskToDeleteSet = new Set<Id>();
    public Boolean taskProcessed = False;
    public MA_TaskManagementSettings__c taskManagementSettings = MA_Util.getTaskManagementSettings();
    
    global MA_CreateContactTaskBatch(Acquisition_Company_Task__c acqCompanyTask, String conQueryStr, Map<Id,Acquisition_Contact_Task__c> existingAcqContactTaskMap) {
        queryStr = conQueryStr;
        companyTask = acqCompanyTask;
        existingContactTaskMap = existingAcqContactTaskMap;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        List<Acquisition_Contacts__c> eligibleAcqContacts = new List<Acquisition_Contacts__c>();
        eligibleAcqContacts = Database.query(queryStr);
        
        if((eligibleAcqContacts == null || (eligibleAcqContacts != null && eligibleAcqContacts.isEmpty())) && 
           existingContactTaskMap != null && !existingContactTaskMap.isEmpty()) 
        {
               for(Acquisition_Contact_Task__c acqCon: existingContactTaskMap.values()) {
                   taskToDeleteSet.add(acqCon.Id);
               }
           }
        return Database.getQueryLocator(queryStr);

    }
    
    global void execute(Database.BatchableContext BC, List<Acquisition_Contacts__c> scope){
        try 
        {
            List<Acquisition_Contact_Task__c> contactTasksToInsert = new List<Acquisition_Contact_Task__c>();
            List<MA_Slack_Notification__e> slackNotificationToInsert = new List<MA_Slack_Notification__e>();

            //Loop over contacts and create contact task instance
            for(Acquisition_Contacts__c acqContact: scope) 
            {
                //Create task if there is no existing task
                if((existingContactTaskMap == null || existingContactTaskMap.isEmpty())
                   ||(existingContactTaskMap != null && !existingContactTaskMap.containsKey(acqContact.Id)))
                {
                    contactTasksToInsert.add(Ma_Util.getAcquisitionContactTask(companyTask, acqContact.Id));
                }
                else if(existingContactTaskMap != null && existingContactTaskMap.containsKey(acqContact.Id)) 
                {
                    existingContactTaskMap.remove(acqContact.Id);
                }
            }
            
            //Insert Tasks
            if(contactTasksToInsert != null && !contactTasksToInsert.isEmpty()) {
                Database.SaveResult[] taskResultList = Database.insert(contactTasksToInsert,false);
                for(Integer i=0; i<taskResultList.size();i++)
                {
                    Database.SaveResult result = taskResultList.get(i);
                    if(!result.isSuccess()){
                        PF_Logger.log('MA','ERROR',String.valueOf(result.getErrors()),null,'Error during Contact Task record creation on Acquisition_Contact_Task__c', 'MA_CreateContactTaskBatch');
                    } else {
                        MA_Slack_Notification__e slackNotification = new MA_Slack_Notification__e();
                        slackNotification.Acquisition_Contact_Task_Id__c = taskResultList.get(i).id;
                        slackNotification.Is_Insert__c = true;
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
                        PF_Logger.log('MA','ERROR',String.valueOf(result.getErrors()),null,'Error during MA_Slack_Notification__e event publish', 'MA_CreateContactTaskBatch');
                    }
                }
            }
            
            //Insert error log for failed records
            if(PF_Logger.logs.size() > 0)
            {
                PF_Logger.createLogs(PF_Logger.logs);
            }
            //Mark Acquisition Company task as processed
            taskProcessed = True;
            
        } catch(Exception e)
        {
            PF_Logger.log('MA','ERROR',e.getMessage(),null,'Error during Contact Task record creation on Acquisition_Contact_Task__c. Error Trace : ' + e.getStackTraceString(), 'MA_CreateContactTaskBatch');
            PF_Logger.createLogs(PF_Logger.logs);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        //Update custom settings value
        if(taskProcessed) {
            taskManagementSettings.Task_Batch_Last_Run_Date__c = System.now();
            update taskManagementSettings;
        }
        
        //Delete existing task if not applicable
        if(existingContactTaskMap != null && !existingContactTaskMap.isEmpty()) {
            for(Acquisition_Contact_Task__c acqCon: existingContactTaskMap.values()) {
                taskToDeleteSet.add(acqCon.Id);
            }
        }
        if(taskToDeleteSet != null && !taskToDeleteSet.isEmpty()) {
            MA_DeleteContactTaskBatch batch = new MA_DeleteContactTaskBatch(taskToDeleteSet);
            database.executeBatch(batch,Integer.valueOf(taskManagementSettings.MA_DeleteContactTaskBatch_Size__c));
        }
        
    } 
}