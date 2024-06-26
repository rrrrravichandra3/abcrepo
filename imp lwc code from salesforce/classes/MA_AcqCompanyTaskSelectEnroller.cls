/**
 * W-10702588
 * Class to select-enrol acquisition contacts to acquisition company tasks.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         01/03/2022      Chakshu Malhotra        Holds Queueable chaining logic to select-enrol or remove (upsert / delete) acquisition contacts to acquisition company tasks.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public class MA_AcqCompanyTaskSelectEnroller extends MA_AcqCompanyTaskEnroller {
    
    @TestVisible private static Boolean testJobEnqueued = false;

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to initialize queueable instance and enqueue it.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    enrolStateful          DESCRIPTION (Data type Object, Wrapper instance containing details of Acquisition_Company_Task__c records)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    protected override void execute(Object enrolStateful) {
        MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful statefulInstance = (MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful)enrolStateful;
        if(statefulInstance.totalRecordCount > 0 && statefulInstance.deleteContactTasks == MA_AcqCompanyTaskEnrollerHelper.DeleteContactTasks.COMPANY_MISMATCH) {
            enqueueContactTaskPurgerJob(statefulInstance);
        }else {
            enqueueTaskSelectEnrollerJob(statefulInstance, MA_AcqCompanyTaskEnrollerHelper.EligibleContacts.FIRST_BATCH, null);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to enqueue MA_ContactTaskPurger queueable job & attach finalizer actions with it.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    enrolStateful          DESCRIPTION (Data type Object, Serialized state of queueable job)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void enqueueContactTaskPurgerJob(Object enrolStateful) {
        MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful statefulInstance = (MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful)enrolStateful;
        
        if(statefulInstance.deleteRecordList == null) {
            statefulInstance.deleteRecordList = new List<Acquisition_Contact_Task__c>();
        }
        
        statefulInstance.deleteRecordList.clear();
        statefulInstance.deleteRecordList.addAll(MA_AcqCompanyTaskEnrollerHelper.getDeleteContactTasks(statefulInstance.deleteContactTasks, statefulInstance.task, statefulInstance.upsertAsyncJobIds, statefulInstance.batchConfig.dmlQueueableSize));        
        enqueueJob(new MA_ContactTaskPurger(statefulInstance, new MA_ContactTaskPurgerFinalizer(statefulInstance)));
        
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to enqueue MA_TaskSelectEnroller queueable job & attach finalizer actions with it.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    enrolStateful       DESCRIPTION (Data type Object, Serialized state of queueable job)
    * @param    eligibleContacts    DESCRIPTION (Data type MA_AcqCompanyTaskEnrollerHelper.EligibleContacts, Enum to specify if it's the initial list of contacts or subsequent)
    * @param    lastRecordId        DESCRIPTION (Data type Id, last record Id of contact from the previous list of eligible contacts)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void enqueueTaskSelectEnrollerJob(Object enrolStateful, MA_AcqCompanyTaskEnrollerHelper.EligibleContacts eligibleContacts, Id lastRecordId) {
        MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful statefulInstance = (MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful)enrolStateful;
        
        if(statefulInstance.eligibleContactList == null) {
            statefulInstance.totalRecordsQueried = 0;
            statefulInstance.upsertAsyncJobIds = new Set<Id>();
            statefulInstance.eligibleContactList = new List<Acquisition_Contacts__c>();
        }

        statefulInstance.eligibleContactList.clear();
        statefulInstance.eligibleContactList.addAll(MA_AcqCompanyTaskEnrollerHelper.getEligibleContactList(eligibleContacts, statefulInstance.task, lastRecordId, statefulInstance.batchConfig.dmlQueueableSize));
        enqueueJob(new MA_TaskSelectEnroller(statefulInstance, new MA_TaskSelectEnrollerFinalizer(statefulInstance)));
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to reset few attributes of SelectEnrolStateful upon completion of all chained jobs of either of the Queueable type.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    jobParams    DESCRIPTION (Data type StatefulQueueable, Serialized state of queueable job)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void resetJobParams(MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful jobParams) {
        jobParams.curentDmlCount = 0;
        jobParams.totalRecordCount = 0;
        jobParams.deleteRecordList?.clear();
        jobParams.eligibleContactList?.clear();
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to delete acquisition contact task records.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class MA_ContactTaskPurger extends MA_AcqCompanyTaskEnroller.MA_TaskEnrolJob {
        public MA_ContactTaskPurger(Object jobParams, MA_AcqCompanyTaskEnroller.JobFinalizer jobFinalizerImpl) {
            super(jobParams, jobFinalizerImpl);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to bulk hard delete contact task records that do not meet criteria for task processing.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void execute(QueueableContext qContext) {
            MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful jobParams = (MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful)super.jobParams;
            
            MA_AcqCompanyTaskEnrollerHelper.bulkHardDeleteContactTasks(jobParams.deleteRecordList);
            jobParams.curentDmlCount += jobParams.deleteRecordList.size();

            if(jobParams.curentDmlCount < jobParams.totalRecordCount && !jobParams.deleteRecordList.isEmpty()) {
                jobFinalizerImpl.handleSingleJobCompletion();
            }else if(jobParams.deleteContactTasks == MA_AcqCompanyTaskEnrollerHelper.DeleteContactTasks.COMPANY_MISMATCH) {
                jobFinalizerImpl.handleAllJobsCompletion();
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to upsert contact task records.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class MA_TaskSelectEnroller extends MA_AcqCompanyTaskEnroller.MA_TaskEnrolJob {
        public MA_TaskSelectEnroller(Object jobParams, MA_AcqCompanyTaskEnroller.JobFinalizer jobFinalizerImpl) {
            super(jobParams, jobFinalizerImpl);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to bulk upsert contact task records for acquisition contacts that meet criteria for task processing.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void execute(QueueableContext qContext) {
            MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful jobParams = (MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful)super.jobParams;
            jobParams.totalRecordsQueried += jobParams.eligibleContactList.size();
            
            List<Acquisition_Contacts__c> filteredEligibleContactList = MA_AcqCompanyTaskEnrollerHelper.getFilteredEligibleContactList(jobParams.eligibleContactList);
            List<User> eligibleUsers = filteredEligibleContactList.isEmpty() ? new List<User>() : MA_AcqCompanyTaskEnrollerHelper.getEligibleUsersFromContacts(filteredEligibleContactList);
            
            Id asyncJobId = qContext.getJobId();
            jobParams.upsertAsyncJobIds.add(asyncJobId);

            List<Acquisition_Contact_Task__c> contactTasks = new List<Acquisition_Contact_Task__c>();

            for(User eligibleUser : eligibleUsers) {
                Acquisition_Contact_Task__c contactTask = MA_AcqCompanyTaskEnrollerHelper.getContactTask(jobParams.task, eligibleUser.Contact.Acquisition_Contacts__c, asyncJobId);
                contactTasks.add(contactTask);
            }

            MA_AcqCompanyTaskEnrollerHelper.bulkUpsertContactTasks(contactTasks);
            jobParams.curentDmlCount += eligibleUsers.size();

            if(jobParams.totalRecordsQueried < jobParams.totalRecordCount && jobParams.eligibleContactList.size() > 0) {
                jobFinalizerImpl.handleSingleJobCompletion();
            }else {
                jobFinalizerImpl.handleAllJobsCompletion();
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of AbstractJobFinalizer to provide JobFinalizer implementation for MA_ContactTaskPurgerFinalizer queueable job.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class MA_ContactTaskPurgerFinalizer extends MA_AcqCompanyTaskEnroller.AbstractJobFinalizer {
        public MA_ContactTaskPurgerFinalizer(Object jobParams) {
            super(jobParams);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on each single job completion; recursively adds a chained job to fetch & delete next set of contact tasks.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion() {
            MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful jobParams = (MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful)super.jobParams;
            MA_AcqCompanyTaskSelectEnroller.enqueueContactTaskPurgerJob(jobParams);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on all jobs completion; adds a chained job to upsert contact tasks if tasks were deleted due to company mismatch.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleAllJobsCompletion() {
            MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful jobParams = (MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful)super.jobParams;
            MA_AcqCompanyTaskSelectEnroller.resetJobParams(jobParams);
            jobParams.totalRecordCount = MA_AcqCompanyTaskEnrollerHelper.getEligibleContactsCount(jobParams.task);
            if(!testJobEnqueued) {
                MA_AcqCompanyTaskSelectEnroller.enqueueTaskSelectEnrollerJob(jobParams, MA_AcqCompanyTaskEnrollerHelper.EligibleContacts.FIRST_BATCH, null);
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of AbstractJobFinalizer to provide JobFinalizer implementation for MA_TaskSelectEnrollerFinalizer queueable job.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class MA_TaskSelectEnrollerFinalizer extends MA_AcqCompanyTaskEnroller.AbstractJobFinalizer {
        public MA_TaskSelectEnrollerFinalizer(Object jobParams) {
            super(jobParams);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on each single job completion; recursively adds a chained job to fetch & upsert next set of contact tasks.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion() {
            MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful jobParams = (MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful)super.jobParams;
            Integer lastEligibleContactIndex = jobParams.eligibleContactList.size() - 1;
            Id lastRecordId = jobParams.eligibleContactList.get(lastEligibleContactIndex).Id;
            if(!testJobEnqueued) {
                MA_AcqCompanyTaskSelectEnroller.enqueueTaskSelectEnrollerJob(jobParams, MA_AcqCompanyTaskEnrollerHelper.EligibleContacts.QUERY_MORE, lastRecordId);
            }
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on all jobs completion; adds a chained job to delete contact tasks that do not meet criteria.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleAllJobsCompletion() {
            MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful jobParams = (MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful)super.jobParams;
            MA_AcqCompanyTaskEnrollerHelper.updateTaskStatus(jobParams.task, MA_AcqCompanyTaskEnrollerHelper.TaskStatus.CHANGES_COMPLETE, jobParams.batchConfig.batchJobId);
            MA_AcqCompanyTaskSelectEnroller.resetJobParams(jobParams);
            jobParams.deleteContactTasks = MA_AcqCompanyTaskEnrollerHelper.DeleteContactTasks.NOT_MEETING_CRITERIA;
            jobParams.totalRecordCount = MA_AcqCompanyTaskEnrollerHelper.getDeleteContactTaskCount(jobParams.deleteContactTasks, jobParams.task, jobParams.upsertAsyncJobIds);
            if(!testJobEnqueued) {
                MA_AcqCompanyTaskSelectEnroller.enqueueContactTaskPurgerJob(jobParams);
            }
        }
    }
}