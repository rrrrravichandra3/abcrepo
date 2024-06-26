/**
 * W-10702588
 * Trigger utility class for MA_ACTaskTriggerHelper
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         01/03/2022      Chakshu Malhotra        Trigger utility logic for MA_ACTaskTriggerHelper.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public class MA_ACTaskTriggerUtility {

    private static final String TASK_STATUS_NEW = Label.MA_Task_New;
    private static final String TASK_STATUS_INACTIVE = Label.MA_Task_Inactive;
    private static final String TASK_STATUS_CHANGES_PENDING = Label.MA_Task_Changes_Pending;
    private static final String TASK_STATUS_CHANGES_IN_PROGRESS = Label.MA_Task_Changes_In_Progress;
    private static final List<String> TASK_DETAIL_FIELDS = Label.MA_Task_Detail_Fields.toLowerCase().split(';');

    public enum TaskStatus {INACTIVE, CHANGES_PENDING}

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method updates the Status if some fields of an task record are updated or task is turned inactive.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newTask 	   	DESCRIPTION (Data type Acquisition_Company_Task__c, The new Task record)
    * @param    oldTask 	   	DESCRIPTION (Data type Id, Acquisition_Company_Task__c, The old Task record)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updateTaskStatus(Acquisition_Company_Task__c newTask, Acquisition_Company_Task__c oldTask) {
        if(isTaskActive(newTask) && isEligibleForPendingState(newTask, oldTask)) {
            updateTaskStatus(newTask, oldTask, TaskStatus.CHANGES_PENDING);
        }else if(isTaskInactive(newTask)) {
            updateTaskStatus(newTask, oldTask, TaskStatus.INACTIVE);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method checks if task is active & currenlty not in "Pending" or already in "Progress".
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newTask 	   	DESCRIPTION (Data type Acquisition_Company_Task__c, The new Task record)
    * @return   Boolean         DESCRIPTION (return if task is active)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isTaskActive(Acquisition_Company_Task__c newTask) {
        List<String> statusList = new List<String> {TASK_STATUS_CHANGES_PENDING.toLowerCase(), TASK_STATUS_CHANGES_IN_PROGRESS.toLowerCase()};
        return newTask.Active__c && String.isNotBlank(newTask.Process_Status__c) && !statusList.contains(newTask.Process_Status__c.toLowerCase());
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method checks if task is inactive & currenlty not in "Pending" or already in "Progress".
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newTask 	   	DESCRIPTION (Data type Acquisition_Company_Task__c, The new Task record)
    * @return   Boolean         DESCRIPTION (return if task is inactive)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isTaskInactive(Acquisition_Company_Task__c newTask) {
        List<String> statusList = new List<String> {TASK_STATUS_INACTIVE.toLowerCase(), TASK_STATUS_CHANGES_IN_PROGRESS.toLowerCase()};
        return !newTask.Active__c && String.isNotBlank(newTask.Process_Status__c) && !statusList.contains(newTask.Process_Status__c.toLowerCase());
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method checks if task is eligible to put in Pending state.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newTask 	   	DESCRIPTION (Data type Acquisition_Company_Task__c, The new Task record)
    * @param    oldTask 	   	DESCRIPTION (Data type Id, Acquisition_Company_Task__c, The old Task record)
    * @return   Boolean         DESCRIPTION (return if task is eligible)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isEligibleForPendingState(Acquisition_Company_Task__c newTask, Acquisition_Company_Task__c oldTask) {
        return isTaskStatusNew(newTask) || isTaskUpated(newTask, oldTask) || isTaskStatusInactive(newTask);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method checks if task is in New state.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newTask 	   	DESCRIPTION (Data type Acquisition_Company_Task__c, The new Task record)
    * @return   Boolean         DESCRIPTION (return if task is New)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isTaskStatusNew(Acquisition_Company_Task__c newTask) {
        return newTask.Process_Status__c?.equalsIgnoreCase(TASK_STATUS_NEW);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method checks task is not already in "Progress" state & if any of the important task fields are updated.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newTask 	   	DESCRIPTION (Data type Acquisition_Company_Task__c, The new Task record)
    * @param    oldTask 	   	DESCRIPTION (Data type Id, Acquisition_Company_Task__c, The old Task record)
    * @return   Boolean         DESCRIPTION (return if any of the fields are updated)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isTaskUpated(Acquisition_Company_Task__c newTask, Acquisition_Company_Task__c oldTask) {
        return !newTask.Process_Status__c?.equalsIgnoreCase(TASK_STATUS_CHANGES_IN_PROGRESS) && 
               (Trigger.isInsert || newTask.Filter_Criteria_Query__c != oldTask.Filter_Criteria_Query__c || 
               isTaskDetailUpdated(newTask, oldTask));
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method checks if t dasketail is updated.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newTask 	   	DESCRIPTION (Data type Acquisition_Company_Task__c, The new Task record)
    * @param    oldTask 	   	DESCRIPTION (Data type Id, Acquisition_Company_Task__c, The old Task record)
    * @return   Boolean         DESCRIPTION (return if task detail is updated)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isTaskDetailUpdated(Acquisition_Company_Task__c newTask, Acquisition_Company_Task__c oldTask) {
        Boolean isUpdated = false;

        for(String taskField : TASK_DETAIL_FIELDS) {
            if(newTask.get(taskField) != oldTask.get(taskField)) {
                isUpdated = true;
                break;
            }
        }
        return isUpdated;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method checks if Status is inactive.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newTask 	   	DESCRIPTION (Data type Acquisition_Company_Task__c, The new Task record)
    * @return   Boolean         DESCRIPTION (return if Status is inactive)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isTaskStatusInactive(Acquisition_Company_Task__c newTask) {
        return newTask.Process_Status__c?.equalsIgnoreCase(TASK_STATUS_INACTIVE);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method updates Status to either "Pending" or "Inactive" state based on its eligibility.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newTask 	   	DESCRIPTION (Data type Acquisition_Company_Task__c, The new Task record)
    * @param    oldTask 	   	DESCRIPTION (Data type Id, Acquisition_Company_Task__c, The old Task record)
    * @param    taskStatus 	    DESCRIPTION (Data type TaskStatus, The TaskStatus enum type)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateTaskStatus(Acquisition_Company_Task__c newTask, Acquisition_Company_Task__c oldTask, TaskStatus taskStatus) {
        String currentTaskStatus = newTask.Process_Status__c;

        switch on taskStatus {
            when INACTIVE {
                newTask.Process_Status__c = TASK_STATUS_INACTIVE;
            }when CHANGES_PENDING {
                newTask.Process_Status__c = TASK_STATUS_CHANGES_PENDING;
            }
        }
        
        updateLastActiveStatus(newTask, oldTask, currentTaskStatus);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method captures Status just before it is turned inactive & stores it in Last Active Status.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newTask 	   	    DESCRIPTION (Data type Acquisition_Company_Task__c, The new Task record)
    * @param    oldTask 	   	    DESCRIPTION (Data type Id, Acquisition_Company_Task__c, The old Task record)
    * @param    currentTaskStatus   DESCRIPTION (Data type String, Status before it is turned inactive)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateLastActiveStatus(Acquisition_Company_Task__c newTask, Acquisition_Company_Task__c oldTask, String currentTaskStatus) {
        Boolean isTurnedActive = !Trigger.isInsert && newTask.Active__c && (newTask.Active__c != oldTask.Active__c);
        Boolean isTurnedInactive = !Trigger.isInsert && !newTask.Active__c && (newTask.Active__c != oldTask.Active__c);

        if(isTurnedActive && String.isNotBlank(newTask.Last_Active_Process_Status__c)) {
            newTask.Process_Status__c = newTask.Last_Active_Process_Status__c;
        }else if(isTurnedInactive) {
            newTask.Last_Active_Process_Status__c = currentTaskStatus;
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method to enqueues MA_ContactTaskPurger job to delete related Acquisition_Contact_Task__c records on deletion of task records.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    taskIds 	   	    DESCRIPTION (Data type Set<Id>, Set of Acquisition_Company_Task__c Ids)
    * @param    currentIndex 	    DESCRIPTION (Data type Integer, Index of current company task under purging process)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void enqueueContactTaskPurgerJob(List<Id> taskIds, Integer currentIndex) {
        MA_ContactTaskPurger contactTaskPurgerJob = new MA_ContactTaskPurger(taskIds, currentIndex);
        
        if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
            System.enqueueJob(contactTaskPurgerJob);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to purge related acquisition contact task records on deletion of acquisition company task records.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class MA_ContactTaskPurger implements Queueable {
        private List<Id> taskIds;
        private Integer currentTaskIndex;

        public MA_ContactTaskPurger(List<Id> taskIds, Integer currentTaskIndex) {
            this.taskIds = taskIds;
            this.currentTaskIndex = currentTaskIndex;
        }

        public void execute(QueueableContext qContext) {
            Id currentTaskId = taskIds[currentTaskIndex];
            String keyIdentifierSearchStr = currentTaskId + '%';

            List<Acquisition_Contact_Task__c> contactTasks = [SELECT Id FROM Acquisition_Contact_Task__c
                                                              WHERE Key_Identifier__c LIKE :keyIdentifierSearchStr LIMIT 200];

            if(!contactTasks.isEmpty()) {
                List<Database.DeleteResult> drList = Database.delete(contactTasks, false);
                MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(drList, MA_AbstractLogger.BulkLoggerType.DELETE_RESULT);
            }else {
                currentTaskIndex++;
            }

            if(currentTaskIndex < taskIds.size()) {
                MA_ACTaskTriggerUtility.enqueueContactTaskPurgerJob(taskIds, currentTaskIndex);
            }
        }
    }
}