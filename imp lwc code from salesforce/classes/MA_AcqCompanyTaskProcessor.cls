/**
 * W-10702588
 * Batchable & Schedulable class to process changes in all the company tasks where Process Status is "Changes Pending".
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         01/03/2022      Chakshu Malhotra        Processes acquisition compnay task changes in Pending state.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
global class MA_AcqCompanyTaskProcessor implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    private static final Integer THRESHOLD_SIZE = 1;
    private MA_AcqCompanyTaskEnrolWrapper.TaskEnrollerConfig batchConfig;

    private Set<Id> acqCompanyTaskIds;

    public MA_AcqCompanyTaskProcessor(MA_AcqCompanyTaskEnrolWrapper.TaskEnrollerConfig batchConfig) {
        this.batchConfig = batchConfig;
    }

    public MA_AcqCompanyTaskProcessor(MA_AcqCompanyTaskEnrolWrapper.TaskEnrollerConfig batchConfig, Set<Id> acqCompanyTaskIds) {
        this.batchConfig = batchConfig;
        this.acqCompanyTaskIds = acqCompanyTaskIds;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Database.Batchable interface method to fetch all required company task records using Database.QueryLocator.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    batchContext 	   	   DESCRIPTION (Data type Database.BatchableContext, Batch context variable containing Batch Job Id.)
    * @return   Database.QueryLocator  DESCRIPTION (return Database.QueryLocator)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    global Database.QueryLocator start(Database.BatchableContext batchContext) {
        batchConfig.batchJobId = batchContext.getJobId();
        return MA_AcqCompanyTaskEnrollerHelper.getTaskQueryLocator(acqCompanyTaskIds);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Database.Batchable interface method to process company task changes for each task.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    batchContext    DESCRIPTION (Data type Database.BatchableContext, Batch context variable containing Batch Job Id.)
    * @param    tasks 	   	    DESCRIPTION (Data type List<Acquisition_Company_Task__c>, List of Company Tasks based on batch chunk size.)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    global void execute (Database.BatchableContext batchContext, List<Acquisition_Company_Task__c> tasks) {
        // Batch size set to 1; 1 Acquisition_Company_Task__c record per batch chunk execution
        Acquisition_Company_Task__c task = tasks[0];
        MA_AcqCompanyTaskEnrollerHelper.updateTaskStatus(task, MA_AcqCompanyTaskEnrollerHelper.TaskStatus.CHANGES_IN_PROGRESS, batchConfig.batchJobId);
        MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful enrolStateful = MA_AcqCompanyTaskEnrollerHelper.getSelectEnrolStateful(task, batchConfig);
        MA_AcqCompanyTaskEnroller.getTaskEnrollerStrategy().execute(enrolStateful, MA_AcqCompanyTaskEnroller.TASK_EXECUTION_MODE.SELECT_ENROL);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Database.Batchable interface method to process post batch execution logic if any.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    batchContext    DESCRIPTION (Data type Database.BatchableContext, Batch context variable containing Batch Job Id.)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    global void finish(Database.BatchableContext batchContext) {
        // no post-batch execution logic needed.
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Schedulable interface method to schedule MA_AcqCompanyTaskProcessor batch class.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    schedulableContext    DESCRIPTION (Data type SchedulableContext, Schedulable context variable containing Scheduled Job Id.)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    global void execute(SchedulableContext schedulableContext) {
        MA_AcqCompanyTaskEnrolWrapper.TaskEnrollerConfig batchConfig = MA_AcqCompanyTaskEnrollerHelper.getBatchConfig();
        MA_AcqCompanyTaskProcessor batchJob = new MA_AcqCompanyTaskProcessor(batchConfig);
        Integer batchSize = Integer.valueOf(batchConfig.batchSize);
        Database.executeBatch(batchJob, (batchSize > 0 && batchSize <= THRESHOLD_SIZE) ? batchSize : THRESHOLD_SIZE);
    }
}