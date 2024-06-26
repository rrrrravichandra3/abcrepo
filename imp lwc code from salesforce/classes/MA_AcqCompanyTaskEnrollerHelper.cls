/**
 * W-10702588
 * Helper class to enrol acquisition contacts to acquisition company tasks.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         28/02/2022      Chakshu Malhotra        Holds utility methods to perform SOQL queries or DML operations during enrolment process.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public class MA_AcqCompanyTaskEnrollerHelper {

    public enum EligibleContacts {FIRST_BATCH, QUERY_MORE}
    public enum TaskStatus {CHANGES_IN_PROGRESS, CHANGES_COMPLETE}
    public enum DeleteContactTasks {COMPANY_MISMATCH, NOT_MEETING_CRITERIA}
    
    private static final String BATCH_CONFIG_NAME = Label.MA_Task_Enroller_Config;
    private static final String CONTACT_STATUS_CANCELLED = Label.MA_Contact_Status_Cancelled;

    private static final String TASK_CRITERIA_QUERY_ERROR = Label.MA_Task_Criteria_Query_Parse_Error;
    private static final String TASK_AUTO_ENROL_CRITERIA_QUERY_ERROR = Label.MA_Task_Auto_Enrol_Criteria_Query_Parse_Error;

    private static final String TASK_STATUS_CHANGES_PENDING = Label.MA_Task_Changes_Pending;
    private static final String TASK_STATUS_CHANGES_COMPLETE = Label.MA_Task_Changes_Complete;
    private static final String TASK_STATUS_CHANGES_IN_PROGRESS = Label.MA_Task_Changes_In_Progress;

    private static final List<String> TASK_ACTIVE_COMPANY_STATUS = Label.MA_Event_Active_Company_Status.split(';');

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get acquisition company task batch configuration metadata and create wrapper instance for it.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   MA_AcqCompanyTaskEnrolWrapper.TaskEnrollerConfig    DESCRIPTION (return TaskEnrollerConfig)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static MA_AcqCompanyTaskEnrolWrapper.TaskEnrollerConfig getBatchConfig() {
        MA_Batch_Configuration__mdt batchConfigMetadata = getBatchConfigMetadata();
        MA_AcqCompanyTaskEnrolWrapper.TaskEnrollerConfig batchConfig = new MA_AcqCompanyTaskEnrolWrapper.TaskEnrollerConfig();
        batchConfig.batchSize = Integer.valueOf(batchConfigMetadata.Batch_Size__c);
        batchConfig.dmlQueueableSize = Integer.valueOf(batchConfigMetadata.DML_Execute_Queueable_Size__c);        
        return batchConfig;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get acquisition company task batch configuration metadata
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   MA_Batch_Configuration__mdt  DESCRIPTION (return MA_Batch_Configuration__mdt)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static MA_Batch_Configuration__mdt getBatchConfigMetadata() {
        return [SELECT Id, Batch_Size__c, DML_Execute_Queueable_Size__c
                FROM MA_Batch_Configuration__mdt 
                WHERE DeveloperName = :BATCH_CONFIG_NAME LIMIT 1];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch task details for the company tasks being processed.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    taskIds 	   	                    DESCRIPTION (Data type Set<Id>, Set of Id of the tasks in process)
    * @return   List<Acquisition_Company_Task__c>   DESCRIPTION (return list of task records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Acquisition_Company_Task__c> getCompanyTasks(Set<Id> taskIds) {
        return [SELECT Id, Acquisition_Company__c, Active__c, AsyncApexJobId__c, Category__c, Critical__c, Task_Context__c, Due_Date__c, 
                Email_Reminder__c, Filter_Criteria_Query__c, Last_Processed_Criteria_Query__c, Last_Processed_Date__c, Link__c, Priority__c, 
                Process_Status__c, Remove_Task_Assignment__c, Required__c, Status__c, Subject__c, Last_Processed_Status__c
                FROM Acquisition_Company_Task__c 
                WHERE Id IN :taskIds AND 
                Process_Status__c = :TASK_STATUS_CHANGES_PENDING AND 
                Acquisition_Company__r.Status__c IN :TASK_ACTIVE_COMPANY_STATUS];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create query string for task and return Database.QueryLocator for it.
    * @param    acqCompanyTaskIds 	   	DESCRIPTION (Data type Set<Id>, Set of Id of the tasks in process)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   Database.QueryLocator   DESCRIPTION (return Database.QueryLocator for tasks)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Database.QueryLocator getTaskQueryLocator(Set<Id> acqCompanyTaskIds) {
        String taskQueryStr = 'SELECT Id, Acquisition_Company__c, Active__c, AsyncApexJobId__c, Category__c, Critical__c, ' + 
                              'Task_Context__c, Due_Date__c, Email_Reminder__c, Filter_Criteria_Query__c, Last_Processed_Criteria_Query__c, ' + 
                              'Last_Processed_Date__c, Link__c, Priority__c, Process_Status__c, Remove_Task_Assignment__c, Required__c, ' + 
                              'Status__c, Subject__c, Last_Processed_Status__c ' + 
                              'FROM Acquisition_Company_Task__c ' +
                              'WHERE Active__c = true AND ' +
                              'Process_Status__c = :TASK_STATUS_CHANGES_PENDING AND ' +
                              'Acquisition_Company__r.Status__c IN :TASK_ACTIVE_COMPANY_STATUS';
        taskQueryStr += (acqCompanyTaskIds != null && acqCompanyTaskIds.size() > 0) ? ' AND Id IN :acqCompanyTaskIds' : '';
        return Database.getQueryLocator(taskQueryStr);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Status on task record when changes are in progress & it's completed.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    task 	   	    DESCRIPTION (Data type Acquisition_Company_Task__c, Task record being published)
    * @param    taskStatus 	   	DESCRIPTION (Data type TaskStatus, Enum type to identify the task status)
    * @param    batchJobId 	    DESCRIPTION (Data type Id, Id of batch job)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updateTaskStatus(Acquisition_Company_Task__c task, TaskStatus taskStatus, Id batchJobId) {
        switch on taskStatus {
            when CHANGES_IN_PROGRESS {
                task.Process_Status__c = TASK_STATUS_CHANGES_IN_PROGRESS;
            }when CHANGES_COMPLETE {
                task.AsyncApexJobId__c = batchJobId;
                task.Last_Processed_Date__c = Datetime.now();
                task.Process_Status__c = TASK_STATUS_CHANGES_COMPLETE;
                task.Last_Processed_Status__c = task.Status__c;
                task.Last_Processed_Criteria_Query__c = task.Filter_Criteria_Query__c;
            }
        }
        List<Database.SaveResult> srList = Database.update(new List<Acquisition_Company_Task__c>{task}, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(srList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get wrapper instance of MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful to process aquisition company task.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    task 	   	                                        DESCRIPTION (Data type Acquisition_Company_Task__c, The task record in process)
    * @param    batchConfig 	   	                                DESCRIPTION (Data type Set<Id>, Batch configuration for acquisition company task in process)
    * @return   MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful   DESCRIPTION (return count of contact task records to delete)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful getSelectEnrolStateful(Acquisition_Company_Task__c task, MA_AcqCompanyTaskEnrolWrapper.TaskEnrollerConfig batchConfig) {
        MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful statefulInstance = new MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful();
        statefulInstance.task = task;
        statefulInstance.curentDmlCount = 0;
        statefulInstance.batchConfig = batchConfig;

        MA_AcqCompanyTaskEnrollerHelper.DeleteContactTasks companyMismatch = MA_AcqCompanyTaskEnrollerHelper.DeleteContactTasks.COMPANY_MISMATCH;
        Integer deleteRecordCount = MA_AcqCompanyTaskEnrollerHelper.getDeleteContactTaskCount(companyMismatch, task, null);
        statefulInstance.totalRecordCount = (deleteRecordCount > 0) ? deleteRecordCount : MA_AcqCompanyTaskEnrollerHelper.getEligibleContactsCount(task);
        
        if(deleteRecordCount > 0) {
            statefulInstance.deleteContactTasks = companyMismatch;
        }

        return statefulInstance;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get total count of aquisition contact task record to delete based on deletion type (DeleteContactTasks enum).
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    deleteContactTasks 	   	DESCRIPTION (Data type DeleteContactTasks, Deletion type based on enum value)
    * @param    task 	   	            DESCRIPTION (Data type Acquisition_Company_Task__c, The task record in process)
    * @param    upsertAsyncJobIds 	   	DESCRIPTION (Data type Set<Id>, Set of queueable job Ids to look for records not meeting criteria)
    * @return   Integer                 DESCRIPTION (return count of contact task records to delete)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Integer getDeleteContactTaskCount(DeleteContactTasks deleteContactTasks, Acquisition_Company_Task__c task, Set<Id> upsertAsyncJobIds) {
        Integer deleteContactTaskCount = 0;

        switch on deleteContactTasks {
            when COMPANY_MISMATCH {
                deleteContactTaskCount = getContactTaskCountWithCompanyMismatch(task);
            }when NOT_MEETING_CRITERIA {
                deleteContactTaskCount = getContactTaskCountWithNotMeetingCriteria(task, upsertAsyncJobIds);
            }
        }

        return deleteContactTaskCount;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get total count of contact task record where company doesn't match with company task.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    task 	   	            DESCRIPTION (Data type Acquisition_Company_Task__c, The task record in process)
    * @return   Integer                 DESCRIPTION (return count of contact task records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Integer getContactTaskCountWithCompanyMismatch(Acquisition_Company_Task__c task) {
        return [SELECT COUNT() 
                FROM Acquisition_Contact_Task__c 
                WHERE Acquisition_Company_Task__c = :task.Id AND 
                Acquisition_Contact__r.Acquisition_Company__c != :task.Acquisition_Company__c];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get total count of contact task record that no longer match with task criteria.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    task 	   	            DESCRIPTION (Data type Acquisition_Company_Task__c, The task record in process)
    * @return   Integer                 DESCRIPTION (return count of contact task records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Integer getContactTaskCountWithNotMeetingCriteria(Acquisition_Company_Task__c task, Set<Id> upsertAsyncJobIds) {
        return [SELECT COUNT() 
                FROM Acquisition_Contact_Task__c 
                WHERE Acquisition_Company_Task__c = :task.Id AND 
                AsyncApexJobId__c NOT IN :upsertAsyncJobIds];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get total count of acquisition contacts record related to the company of the task.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    task 	   	            DESCRIPTION (Data type Acquisition_Company_Task__c, The task record in process)
    * @return   Integer                 DESCRIPTION (return count of acquisition contact records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Integer getEligibleContactsCount(Acquisition_Company_Task__c task) {
        return [SELECT COUNT()
                FROM Acquisition_Contacts__c
                WHERE Acquisition_Company__c = :task.Acquisition_Company__c AND
                Contact_Status__c != :CONTACT_STATUS_CANCELLED];
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get list of contact task records to delete based on deletion type (DeleteContactTasks enum).
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    deleteContactTasks 	   	                DESCRIPTION (Data type DeleteContactTasks, Deletion type based on enum value)
    * @param    task 	   	                            DESCRIPTION (Data type Acquisition_Company_Task__c, The task record in process)
    * @param    upsertAsyncJobIds 	   	                DESCRIPTION (Data type Set<Id>, Set of queueable job Ids to look for records not meeting criteria)
    * @param    thresholdLimit 	   	                    DESCRIPTION (Data type Integer, Threshold limit on records to fetch)
    * @return   List<Acquisition_Contact_Task__c>       DESCRIPTION (return list of contact task records to delete)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Acquisition_Contact_Task__c> getDeleteContactTasks(DeleteContactTasks deleteContactTasks, Acquisition_Company_Task__c task, Set<Id> upsertAsyncJobIds, Integer thresholdLimit) {
        List<Acquisition_Contact_Task__c> deleteContactTaskList = new List<Acquisition_Contact_Task__c>();

        switch on deleteContactTasks {
            when COMPANY_MISMATCH {
                deleteContactTaskList.addAll(getContactTasksWithCompanyMismatch(task, thresholdLimit));
            }when NOT_MEETING_CRITERIA {
                deleteContactTaskList.addAll(getContactTasksWithNotMeetingCriteria(task, upsertAsyncJobIds, thresholdLimit));
            }
        }

        return deleteContactTaskList;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get list of contact task records where company doesn't match with task company.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    task 	   	                            DESCRIPTION (Data type Acquisition_Company_Task__c, The task record in process)
    * @param    thresholdLimit 	   	                    DESCRIPTION (Data type Integer, Threshold limit on records to fetch)
    * @return   List<Acquisition_Contact_Task__c>       DESCRIPTION (return list of contact task records to delete)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<Acquisition_Contact_Task__c> getContactTasksWithCompanyMismatch(Acquisition_Company_Task__c task, Integer thresholdLimit) {
        return [SELECT Id 
                FROM Acquisition_Contact_Task__c 
                WHERE Acquisition_Company_Task__c = :task.Id AND 
                Acquisition_Contact__r.Acquisition_Company__c != :task.Acquisition_Company__c LIMIT :thresholdLimit];
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get list of contact task records that no longer match with task criteria.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    task 	   	                            DESCRIPTION (Data type Acquisition_Company_Task__c, The task record in process)
    * @param    upsertAsyncJobIds 	   	                DESCRIPTION (Data type Set<Id>, Set of queueable job Ids to look for records not meeting criteria)
    * @param    thresholdLimit 	   	                    DESCRIPTION (Data type Integer, Threshold limit on records to fetch)
    * @return   List<Acquisition_Contact_Task__c>       DESCRIPTION (return list of contact task records to delete)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @TestVisible
    private static List<Acquisition_Contact_Task__c> getContactTasksWithNotMeetingCriteria(Acquisition_Company_Task__c task, Set<Id> upsertAsyncJobIds, Integer thresholdLimit) {
        return [SELECT Id 
                FROM Acquisition_Contact_Task__c 
                WHERE Acquisition_Company_Task__c = :task.Id AND 
                AsyncApexJobId__c NOT IN :upsertAsyncJobIds LIMIT :thresholdLimit];
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to hard delete list of contact task records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    List<Acquisition_Contact_Task__c>    DESCRIPTION (Data type Integer, List of contact task records)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void bulkHardDeleteContactTasks(List<Acquisition_Contact_Task__c> contactTaskList) {
        List<Database.DeleteResult> drList = Database.delete(contactTaskList, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(drList, MA_AbstractLogger.BulkLoggerType.DELETE_RESULT);

        if(contactTaskList.size() > 0) {
            DataBase.emptyRecycleBin(contactTaskList);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get list of eligible contacts based on criteria query or eligibleContacts type (EligibleContacts enum) in case of exception.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    eligibleContacts 	   	        DESCRIPTION (Data type EligibleContacts, EligibleContacts query type based on enum value)
    * @param    task 	   	                    DESCRIPTION (Data type Acquisition_Company_Task__c, The task record in process)
    * @param    lastRecordId 	   	            DESCRIPTION (Data type Id, Id last acquisition contact record fetched in previous job)
    * @param    thresholdLimit 	   	            DESCRIPTION (Data type Integer, Threshold limit on records to fetch)
    * @return   List<Acquisition_Contacts__c>   DESCRIPTION (return List of acquisition contacts records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Acquisition_Contacts__c> getEligibleContactList(EligibleContacts eligibleContacts, Acquisition_Company_Task__c task, Id lastRecordId, Integer thresholdLimit) {
        List<Acquisition_Contacts__c> contactList = new List<Acquisition_Contacts__c>();

        try {
            contactList.addAll(getContactListFromCriteriaQuery(task, lastRecordId, thresholdLimit));
        }catch(Exception exType) {
            MA_AbstractLogger.logException(exType, TASK_CRITERIA_QUERY_ERROR);
            switch on eligibleContacts {
                when FIRST_BATCH {
                    contactList.addAll(getContactListFirstBatch(task, thresholdLimit));
                }when QUERY_MORE {
                    contactList.addAll(queryMoreContactList(task, lastRecordId, thresholdLimit));
                }
            }
        }

        return contactList;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get acquisition contact record list based on criteria query string.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    task 	   	                    DESCRIPTION (Data type Acquisition_Company_Task__c, The task record in process)
    * @param    lastRecordId 	   	            DESCRIPTION (Data type Id, Id last acquisition contact record fetched in previous job)
    * @param    thresholdLimit 	   	            DESCRIPTION (Data type Integer, Threshold limit on records to fetch)
    * @return   List<Acquisition_Contacts__c>   DESCRIPTION (return List of acquisition contacts records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<Acquisition_Contacts__c> getContactListFromCriteriaQuery(Acquisition_Company_Task__c task, Id lastRecordId, Integer thresholdLimit) {
        String queryStr = task.Filter_Criteria_Query__c;

        if(String.isBlank(queryStr)) {
            Id acqCompanyId = task.Acquisition_Company__c;
            queryStr = 'SELECT Id, (SELECT Id FROM Acquisition_Compensation__r), (SELECT Id FROM Acquisition_Provisioning__r) ' +
                       'FROM Acquisition_Contacts__c ' +
                       'WHERE Contact_Status__c != :CONTACT_STATUS_CANCELLED AND ' +
                       'Acquisition_Company__c = :acqCompanyId';
        }

        queryStr += (lastRecordId == null) ? '' : ' AND Id > :lastRecordId';
        queryStr += ' ORDER BY Id ASC LIMIT :thresholdLimit';
        return (List<Acquisition_Contacts__c>)Database.query(queryStr);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get first batch of acquisition contact record list order by Id.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    task 	   	                    DESCRIPTION (Data type Acquisition_Company_Task__c, The task record in process)
    * @param    thresholdLimit 	   	            DESCRIPTION (Data type Integer, Threshold limit on records to fetch)
    * @return   List<Acquisition_Contacts__c>   DESCRIPTION (return List of acquisition contacts records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @TestVisible
    private static List<Acquisition_Contacts__c> getContactListFirstBatch(Acquisition_Company_Task__c task, Integer thresholdLimit) {
        return [SELECT Id, (SELECT Id FROM Acquisition_Compensation__r), (SELECT Id FROM Acquisition_Provisioning__r)
                FROM Acquisition_Contacts__c
                WHERE Acquisition_Company__c = :task.Acquisition_Company__c AND
                Contact_Status__c != :CONTACT_STATUS_CANCELLED
                ORDER BY Id ASC LIMIT :thresholdLimit];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get subsequent batches of acquisition contact record list order by Id & based on last record fetched in previous job.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    task 	   	                    DESCRIPTION (Data type Acquisition_Company_Task__c, The task record in process)
    * @param    lastRecordId 	   	            DESCRIPTION (Data type Id, Id last acquisition contact record fetched in previous job)
    * @param    thresholdLimit 	   	            DESCRIPTION (Data type Integer, Threshold limit on records to fetch)
    * @return   List<Acquisition_Contacts__c>   DESCRIPTION (return List of acquisition contacts records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @TestVisible
    private static List<Acquisition_Contacts__c> queryMoreContactList(Acquisition_Company_Task__c task, Id lastRecordId, Integer thresholdLimit) {
        return [SELECT Id, (SELECT Id FROM Acquisition_Compensation__r), (SELECT Id FROM Acquisition_Provisioning__r)
                FROM Acquisition_Contacts__c
                WHERE Acquisition_Company__c = :task.Acquisition_Company__c AND
                Contact_Status__c != :CONTACT_STATUS_CANCELLED AND
                Id > :lastRecordId
                ORDER BY Id ASC LIMIT :thresholdLimit];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get filtered eligible acquisition contact list if it has compensation & provisioning record.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    contactList 	   	            DESCRIPTION (Data type List<Acquisition_Contacts__c>, List of acquisition contacts)
    * @return   List<Acquisition_Contacts__c>   DESCRIPTION (return List of eligible acquisition contacts)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Acquisition_Contacts__c> getFilteredEligibleContactList(List<Acquisition_Contacts__c> contactList) {
        List<Acquisition_Contacts__c> eligibleContactList = new List<Acquisition_Contacts__c>();

        for(Acquisition_Contacts__c acqContact : contactList) {
            Boolean hasCompensation = (acqContact.Acquisition_Compensation__r != null && !acqContact.Acquisition_Compensation__r.isEmpty());
            Boolean hasProvisioning = (acqContact.Acquisition_Provisioning__r != null && !acqContact.Acquisition_Provisioning__r.isEmpty());
            if(hasCompensation && hasProvisioning) {
                eligibleContactList.add(acqContact);
            }
        }

        return eligibleContactList;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get list of active user records that meet task criteria based on eligible contacts.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    eligibleContactList 	DESCRIPTION (Data type List<Acquisition_Contacts__c>, list of eligibile acquisition contacts)
    * @return   List<User>              DESCRIPTION (return List of user records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<User> getEligibleUsersFromContacts(List<Acquisition_Contacts__c> eligibleContactList) {
        Set<Id> acquisitionContactIds = (new Map<Id, Acquisition_Contacts__c>(eligibleContactList)).keySet();

        return [SELECT Id, ContactId, Contact.Acquisition_Contacts__c, CreatedDate
                FROM User
                WHERE IsActive = true AND
                Contact.Acquisition_Contacts__c IN :acquisitionContactIds];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get Acquisition Contact Task record to upsert.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    task 	   	                    DESCRIPTION (Data type Acquisition_Company_Task__c, The task record in process)
    * @param    acqContactId 	                DESCRIPTION (Data type Id, Id of the eligible acquisition contact)
    * @param    asyncJobId 	   	                DESCRIPTION (Data type Id, Id of the current queueable job in process)
    * @return   Acquisition_Contact_Task__c     DESCRIPTION (return Aquisition Contact Task record to be upserted)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Acquisition_Contact_Task__c getContactTask(Acquisition_Company_Task__c task, Id acqContactId, Id asyncJobId) {
        String keyIdentifier = String.valueOf(task.Id) + String.valueOf(acqContactId);

        Acquisition_Contact_Task__c contactTask = new Acquisition_Contact_Task__c(Key_Identifier__c = keyIdentifier);
        contactTask.Subject__c = task.Subject__c;
        contactTask.AsyncApexJobId__c = asyncJobId;
        contactTask.Due_Date__c = task.Due_Date__c;
        contactTask.Priority__c = task.Priority__c;
        contactTask.Category__c = task.Category__c;
        contactTask.Required__c = task.Required__c;
        contactTask.Acquisition_Company_Task__c = task.Id;
        contactTask.Acquisition_Contact__c = acqContactId;
        contactTask.Task_Context__c = task.Task_Context__c;

        if(task.Status__c != task.Last_Processed_Status__c) {
            contactTask.Status__c = task.Status__c;
        }

        return contactTask;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to bulk upsert Acquisition Contact Task records based on the eligible contacts identified.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    contactTaskList 	    DESCRIPTION (Data type List<Acquisition_Contact_Task__c>, List of contact tasks to bulk upsert)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void bulkUpsertContactTasks(List<Acquisition_Contact_Task__c> contactTaskList) {
        List<Database.UpsertResult> urList = Database.upsert(contactTaskList, Acquisition_Contact_Task__c.Key_Identifier__c, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(urList, MA_AbstractLogger.BulkLoggerType.UPSERT_RESULT);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch List of processed company tasks for a given acquisition company Id.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId 	                    DESCRIPTION (Data type Id, Id of acquisition company)
    * @return   List<Acquisition_Company_Task__c>   DESCRIPTION (return List of processed company tasks for an acquisition company)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Acquisition_Company_Task__c> getCompanyTasks(Id acqCompanyId) {
        return [SELECT Id, Acquisition_Company__c, Active__c, AsyncApexJobId__c, Category__c, Critical__c, Task_Context__c, Due_Date__c, 
                Email_Reminder__c, Filter_Criteria_Query__c, Last_Processed_Criteria_Query__c, Last_Processed_Date__c, Link__c, Priority__c, 
                Process_Status__c, Remove_Task_Assignment__c, Required__c, Status__c, Subject__c, Last_Processed_Status__c 
                FROM Acquisition_Company_Task__c 
                WHERE Last_Processed_Date__c != null AND
                Acquisition_Company__c = :acqCompanyId];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create Set of eligible acquisition Ids that need to be auto-enroled for the company task.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    task 	            DESCRIPTION (Data type Acquisition_Company_Task__c, Task record to be enroled in)
    * @param    acqContactIds       DESCRIPTION (Data type Set<String>, Set of acquisition contact Ids)
    * @return   Set<String>         DESCRIPTION (return Set of eligible acquisition contact Ids to be auto-enroled for the task)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Set<String> getEligibleContactIds(Acquisition_Company_Task__c task, Set<String> acqContactIds) {
        List<Acquisition_Contacts__c> contactList = new List<Acquisition_Contacts__c>();

        try {
            contactList.addAll(getContactListFromCriteriaQuery(task, acqContactIds));
        }catch(Exception exType) {
            MA_AbstractLogger.logException(exType, TASK_AUTO_ENROL_CRITERIA_QUERY_ERROR);
            contactList.addAll(getContactList(task, acqContactIds));
        }

        return getEligibleContactIds(contactList);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch List of eligible acquisition contacts as per the last processed filter criteria of the company task.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    task 	                        DESCRIPTION (Data type Acquisition_Company_Task__c, Task record to be enroled in)
    * @param    acqContactIds                   DESCRIPTION (Data type Set<String>, Set of acquisition contact Ids)
    * @return   List<Acquisition_Contacts__c>   DESCRIPTION (return List of eligible acquisition contacts as per last processed state)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<Acquisition_Contacts__c> getContactListFromCriteriaQuery(Acquisition_Company_Task__c task, Set<String> acqContactIds) {
        String queryStr = task.Last_Processed_Criteria_Query__c;
        if(String.isBlank(queryStr)) {
            queryStr = 'SELECT Id, (SELECT Id FROM Acquisition_Compensation__r), (SELECT Id FROM Acquisition_Provisioning__r) ' +
                       'FROM Acquisition_Contacts__c ' +
                       'WHERE Contact_Status__c != :CONTACT_STATUS_CANCELLED';
        }
        queryStr += ' AND Id IN :acqContactIds';
        return (List<Acquisition_Contacts__c>)Database.query(queryStr);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch List of eligible acquisition contacts if criteria query is blank or results in runtime-exception.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    task 	                        DESCRIPTION (Data type Acquisition_Company_Task__c, Task record to be enroled in)
    * @param    acqContactIds                   DESCRIPTION (Data type Set<String>, Set of acquisition contact Ids)
    * @return   List<Acquisition_Contacts__c>   DESCRIPTION (return List of eligible acquisition contacts)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @TestVisible
    private static List<Acquisition_Contacts__c> getContactList(Acquisition_Company_Task__c task, Set<String> acqContactIds) {
        return [SELECT Id, (SELECT Id FROM Acquisition_Compensation__r), (SELECT Id FROM Acquisition_Provisioning__r) 
                FROM Acquisition_Contacts__c 
                WHERE Id IN :acqContactIds AND 
                Contact_Status__c != :CONTACT_STATUS_CANCELLED AND
                Acquisition_Company__c = :task.Acquisition_Company__c];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to return Set of eligible acquisition contact Ids based on if its linked User record is Active.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    contactList     DESCRIPTION (Data type List<Acquisition_Contacts__c>, List of acquisition contact records)
    * @return   Set<String>     DESCRIPTION (return Set of eligible acquisition contacts)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Set<String> getEligibleContactIds(List<Acquisition_Contacts__c> contactList) {
        List<Acquisition_Contacts__c> eligibleAcqContacts = getFilteredEligibleContactList(contactList);
        Set<String> acqContactIds = new Set<String>();

        for(Acquisition_Contacts__c eligibleAcqContact : eligibleAcqContacts) {
            acqContactIds.add(eligibleAcqContact.Id);
        }

        return acqContactIds;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to enrol all eligible acquisition contacts to the company task.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    task 	   	    DESCRIPTION (Data type Acquisition_Company_Task__c, The task record in process)
    * @param    asyncJobId      DESCRIPTION (Data type Id, Id of the current queueable job in process)
    * @param    acqContactIds   DESCRIPTION (Data type Set<String>, Set of eligible acquisition contact Ids)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void enrolToCompanyTask(Acquisition_Company_Task__c task, Id asyncJobId, Set<String> acqContactIds) {
        List<Acquisition_Contact_Task__c> contactTasks = new List<Acquisition_Contact_Task__c>();

        for(String acqContactId : acqContactIds) {
            contactTasks.add(getContactTask(task, Id.valueOf(acqContactId), asyncJobId));
        }

        bulkUpsertContactTasks(contactTasks);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to remove all in-eligible acquisition contacts from the company task.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    taskId                DESCRIPTION (Data type Id, Id of company task record)
    * @param    eligibleContactIds    DESCRIPTION (Data type Set<String>, Set of eligible acquisition contact Ids)
    * @param    allAcqContactIds      DESCRIPTION (Data type Set<String>, Set of all acquisition contact Ids as per platform event record)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void removeIneligibleTaskEnrolment(Id taskId, Set<String> eligibleContactIds, Set<String> allAcqContactIds) {
        Set<String> ineligibleContactIds = allAcqContactIds.clone();
        ineligibleContactIds.removeAll(eligibleContactIds);
        List<Acquisition_Contact_Task__c> ineligibleContactTasks = getContactTasksNotMeetingCriteria(taskId, ineligibleContactIds);
        bulkHardDeleteContactTasks(ineligibleContactTasks);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch all in-eligible contact task records for removal.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    taskId                              DESCRIPTION (Data type Id, Id of company task record)
    * @param    ineligibleContactIds                DESCRIPTION (Data type Set<String>, Set of in-eligible acquisition contact Ids)
    * @return   List<Acquisition_Contact_Task__c>   DESCRIPTION (return List of in-eligible contact task records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<Acquisition_Contact_Task__c> getContactTasksNotMeetingCriteria(Id taskId, Set<String> ineligibleContactIds) {
        return [SELECT Id 
                FROM Acquisition_Contact_Task__c 
                WHERE Acquisition_Company_Task__c = :taskId AND 
                Acquisition_Contact__c IN :ineligibleContactIds];
    }
}