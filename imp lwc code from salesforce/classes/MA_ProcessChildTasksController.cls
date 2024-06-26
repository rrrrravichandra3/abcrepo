/**
 * W-10702588
 * Controller class for maProcessChildTasks (LWC component).
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         02/03/2022      Chakshu Malhotra        To execute queueable to enrol acquisition contacts to company tasks.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_ProcessChildTasksController {
    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method updates Status to "Changes In Progress" and enqueues job to process compay tasks.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    taskId 	   			   DESCRIPTION (Data type String, Id of the acquisition company task)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static void executeCompanyTaskEnroller(String taskId) {
        List<Acquisition_Company_Task__c> companyTasks = MA_AcqCompanyTaskEnrollerHelper.getCompanyTasks(new Set<Id> {Id.valueOf(taskId)});
        if(!companyTasks.isEmpty()) {
            MA_AcqCompanyTaskEnrolWrapper.TaskEnrollerConfig batchConfig = MA_AcqCompanyTaskEnrollerHelper.getBatchConfig();
            MA_AcqCompanyTaskEnrollerHelper.updateTaskStatus(companyTasks[0], MA_AcqCompanyTaskEnrollerHelper.TaskStatus.CHANGES_IN_PROGRESS, batchConfig.batchJobId);
            MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful enrolStateful = MA_AcqCompanyTaskEnrollerHelper.getSelectEnrolStateful(companyTasks[0], batchConfig);
            MA_AcqCompanyTaskEnroller.getTaskEnrollerStrategy().execute(enrolStateful, MA_AcqCompanyTaskEnroller.TASK_EXECUTION_MODE.SELECT_ENROL);
        }
    }
}