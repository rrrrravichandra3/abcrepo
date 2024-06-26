/**
* @description       : Apex trigger handler for Acquisition Company Task
* @author            : Satyam Kumar
* Modifications Log 
* Ver   Date         Author          Modification
* 1.0   29-07-2021   Satyam Kumar   Initial Version
* */
public class MA_SlackNotificationTriggerHandler {
    
    public void handler(List<MA_Slack_Notification__e> newRecords, Map<Id, MA_Slack_Notification__e> newMap, TriggerOperation operation){
        
        switch on operation 
        {
            when AFTER_INSERT 
            {
                afterInsert(newRecords,newMap);
            }
        }
        
    }

    public void afterInsert(List<MA_Slack_Notification__e> newRecords, Map<Id, MA_Slack_Notification__e> newMap){
			sendSlackNotification(newRecords);
    }
    
    //Method to send slack notification
    public static void sendSlackNotification(List<MA_Slack_Notification__e> newRecords) {
        List<Id> acqContactTaskIdOnInsertList = new List<Id>();
        List<Id> acqContactTaskIdOnUpdateList = new List<Id>();
        
        Try {
            for(MA_Slack_Notification__e slackNotif: newRecords) 
            {
                if(String.isNotBlank(slackNotif.Acquisition_Contact_Task_Id__c)) {
                    if(slackNotif.Is_Insert__c) {
                        acqContactTaskIdOnInsertList.add(slackNotif.Acquisition_Contact_Task_Id__c);
                    } else {
                        acqContactTaskIdOnUpdateList.add(slackNotif.Acquisition_Contact_Task_Id__c);
                    }
                }
            }
            
            if(acqContactTaskIdOnInsertList != null && !acqContactTaskIdOnInsertList.isEmpty()) {
                MA_Util.processTaskNotification(acqContactTaskIdOnInsertList, true);
            }
            
            if(acqContactTaskIdOnUpdateList != null && !acqContactTaskIdOnUpdateList.isEmpty()) {
                MA_Util.processTaskNotification(acqContactTaskIdOnUpdateList, false);
            }
            
        } catch(Exception e)
        {
            PF_Logger.log('MA','ERROR',e.getMessage(),null,'Error during sedning slack notification in sendSlackNotification method. Error Trace : ' + e.getStackTraceString(), 'MA_SlackNotificationTriggerHandler');
            PF_Logger.createLogs(PF_Logger.logs);
        }
    }
}