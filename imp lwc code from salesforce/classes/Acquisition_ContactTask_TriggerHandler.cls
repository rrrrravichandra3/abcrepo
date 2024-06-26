public class Acquisition_ContactTask_TriggerHandler {
    public static void deleteDuplicateTasks(List<Acquisition_contact_task__c> newAcqContactTasks){
        Map<Id,List<Acquisition_Contact_Task__c>> acqContactstoTasksMap = new Map<Id,List<Acquisition_Contact_Task__c>>();
        List<Acquisition_Contact_Task__c> dupTasksToDelete = new List<Acquisition_Contact_Task__c>();
        List<Id> acqConsList = new List<Id>();
        for(Acquisition_Contact_Task__c act: newAcqContactTasks){
            acqConsList.add(act.acquisition_contact__c);
        }
    for(Acquisition_Contact_Task__c task:[Select subject__c,CreatedDate,acquisition_contact__c 
                                          from Acquisition_Contact_Task__c 
                                          where acquisition_contact__c=:acqConsList AND
                                          Key_Identifier__c != null] ){
        if(!acqContactstoTasksMap.containsKey(task.acquisition_contact__c)){
             acqContactstoTasksMap.put(task.acquisition_contact__c,new List<Acquisition_Contact_Task__c>{task});

        }
        else {
            List<Acquisition_Contact_Task__c> tempList = acqContactstoTasksMap.get(task.acquisition_contact__c);
            tempList.add(task);
            acqContactstoTasksMap.put(task.acquisition_contact__c,tempList);
        }
    }     
    for(Id ac: acqContactstoTasksMap.keySet()){
    List<Acquisition_Contact_Task__c> tasks = acqContactstoTasksMap.get(ac);
    Map<String,Acquisition_Contact_Task__c> taskMap = new Map<String,Acquisition_Contact_Task__c>();
    for(Acquisition_Contact_Task__c task:tasks){
            if(taskMap.get(task.subject__c)==null){
                taskMap.put(task.subject__c,task);
            }
            else if(taskMap.get(task.subject__c)!=null){
                Acquisition_Contact_Task__c firstTask = taskMap.get(task.subject__c);
                if(firstTask.CreatedDate > task.CreatedDate){
                    dupTasksToDelete.add(firstTask);
                } 
                else dupTasksToDelete.add(task);
            }
    }
    
    }
        if(!dupTasksToDelete.isEmpty()){
            delete dupTasksToDelete;
    }
    }
    
    //Method to send slack notification
   /* public static void sendSlackNotification(List<Acquisition_contact_task__c> newRecords, Map<Id, Acquisition_contact_task__c> oldMap) {
        List<MA_Slack_Notification__e> slackNotificationToInsert = new List<MA_Slack_Notification__e>();
        
        Try {
            for(Acquisition_contact_task__c conTask: newRecords) 
            {
                Acquisition_contact_task__c oldTask = oldMap.get(conTask.Id);
                if(conTask.Due_Date__c != oldTask.Due_Date__c || conTask.Description__c != oldTask.Description__c 
                  || conTask.Required__c != oldTask.Required__c || conTask.Priority__c != oldTask.Priority__c
                   || conTask.Subject__c != oldTask.Subject__c)
                {
                    MA_Slack_Notification__e slackNotification = new MA_Slack_Notification__e();
                    slackNotification.Acquisition_Contact_Task_Id__c = conTask.id;
                    slackNotification.Is_Insert__c = false;
                    slackNotificationToInsert.add(slackNotification);
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
            
        } catch(Exception e)
        {
            PF_Logger.log('MA','ERROR',e.getMessage(),null,'Error during sedning slack notification in sendSlackNotification method. Error Trace : ' + e.getStackTraceString(), 'Acquisition_ContactTask_TriggerHandler');
            PF_Logger.createLogs(PF_Logger.logs);
        }
    }*/
}