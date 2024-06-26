/**
 * W-10702588
 * Trigger helper class for MA_ACTaskTriggerHandler
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         01/03/2022      Chakshu Malhotra        Trigger helper logic for MA_ACTaskTriggerHandler.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public class MA_ACTaskTriggerHelper {
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method handles before insert logic on Acquisition_Company_Task__c records.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newTasks 	   	DESCRIPTION (Data type List<Acquisition_Company_Task__c>, List of new Task records)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void handleBeforeInsert(List<Acquisition_Company_Task__c> newTasks) {
        for(Acquisition_Company_Task__c newTask : newTasks) {
            MA_ACTaskTriggerUtility.updateTaskStatus(newTask, null);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method handles before update logic on Acquisition_Company_Task__c records.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newTasks 	   	DESCRIPTION (Data type List<Acquisition_Company_Task__c>, List of new Task records)
    * @param    oldTaskMap      DESCRIPTION (Data type Map<Id, Acquisition_Company_Task__c>, Trigger.oldMap of Task record)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void handleBeforeUpdate(List<Acquisition_Company_Task__c> newTasks, Map<Id, Acquisition_Company_Task__c> oldTaskMap) {
        for(Acquisition_Company_Task__c newTask : newTasks) {
            Acquisition_Company_Task__c oldTask = oldTaskMap.get(newTask.Id);
            MA_ACTaskTriggerUtility.updateTaskStatus(newTask, oldTask);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method handles after delete logic on Acquisition_Company_Task__c records.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    oldTaskMap      DESCRIPTION (Data type Map<Id, Acquisition_Company_Task__c>, Trigger.oldMap of Task record)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void handleBeforeDelete(Map<Id, Acquisition_Company_Task__c> oldTaskMap) {
        MA_ACTaskTriggerUtility.enqueueContactTaskPurgerJob(new List<Id>(oldTaskMap.keySet()), 0);
    }
}