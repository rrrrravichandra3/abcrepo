/**
 * W-10702588
 * Class to auto-enrol acquisition contacts to acquisition company tasks.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         24/02/2022      Chakshu Malhotra        Holds Queueable chaining logic to auto-enrol or remove (upsert / delete) acquisition contacts to acquisition company tasks.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public class MA_AcqCompanyTaskAutoEnroller extends MA_AcqCompanyTaskEnroller {
    
    @TestVisible private static Boolean testJobEnqueued = false;
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to initialize queueable instance and enqueue it.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    statefulInstance          DESCRIPTION (Data type Object, Wrapper instance containing details of MA_Auto_Enrolment_Event__e records)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    protected override void execute(Object statefulInstance) {
        enqueueCompanyScannerJob(statefulInstance);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to enqueue MA_AcquisitionCompanyScanner queueable job & attach finalizer actions with it.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    statefulInstance          DESCRIPTION (Data type Object, Serialized state of queueable job)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void enqueueCompanyScannerJob(Object statefulInstance) {
        enqueueJob(new MA_AcquisitionCompanyScanner(statefulInstance, new MA_AcquisitionCompanyScannerFinalizer(statefulInstance)));
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to enqueue MA_TaskAutoEnroller queueable job & attach finalizer actions with it.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    statefulInstance          DESCRIPTION (Data type Object, Serialized state of queueable job)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @TestVisible
    private static void enqueueTaskAutoEnrollerJob(Object statefulInstance) {
        enqueueJob(new MA_TaskAutoEnroller(statefulInstance, new MA_TaskAutoEnrollerFinalizer(statefulInstance)));
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to scan through each acquistion company to process auto-enrolment of company tasks.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class MA_AcquisitionCompanyScanner extends MA_AcqCompanyTaskEnroller.MA_TaskEnrolJob {
        public MA_AcquisitionCompanyScanner(Object jobParams, MA_AcqCompanyTaskEnroller.JobFinalizer jobFinalizerImpl) {
            super(jobParams, jobFinalizerImpl);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to process auto-enrolment logic for each acquisition company as received from platform events.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void execute(QueueableContext qContext) {
            MA_AcqCompanyTaskEnrolWrapper.AutoEnrolStateful jobParams = (MA_AcqCompanyTaskEnrolWrapper.AutoEnrolStateful)super.jobParams;
            if(jobParams.currentCount < jobParams.totalCompanies) {
                jobFinalizerImpl.handleSingleJobCompletion();
            }else {
                jobFinalizerImpl.handleAllJobsCompletion();
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to auto-enrol / auto-remove acquisition contacts from company tasks.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class MA_TaskAutoEnroller extends MA_AcqCompanyTaskEnroller.MA_TaskEnrolJob {
        public MA_TaskAutoEnroller(Object jobParams, MA_AcqCompanyTaskEnroller.JobFinalizer jobFinalizerImpl) {
            super(jobParams, jobFinalizerImpl);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to process auto-enrolment or removal of acquisition contacts from company tasks.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void execute(QueueableContext qContext) {
            MA_AcqCompanyTaskEnrolWrapper.AutoEnrolStateful jobParams = (MA_AcqCompanyTaskEnrolWrapper.AutoEnrolStateful)super.jobParams;
            
            Id asyncJobId = qContext.getJobId();

            MA_AcqCompanyTaskEnrolWrapper.AutoEnrolTaskWrapper taskWrapper = jobParams.taskWrapperList[jobParams.currentCount];
            Acquisition_Company_Task__c currentTask = taskWrapper.companyTasks[taskWrapper.currentCount];
            Set<String> eligibleContactIds = MA_AcqCompanyTaskEnrollerHelper.getEligibleContactIds(currentTask, taskWrapper.acqContactIds);
            
            MA_AcqCompanyTaskEnrollerHelper.enrolToCompanyTask(currentTask, asyncJobId, taskWrapper.acqContactIds);
            MA_AcqCompanyTaskEnrollerHelper.removeIneligibleTaskEnrolment(currentTask.Id, eligibleContactIds, taskWrapper.acqContactIds);
            taskWrapper.currentCount++;

            if(taskWrapper.currentCount < taskWrapper.totalCompanyTasks) {
                jobFinalizerImpl.handleSingleJobCompletion();
            }else {
                jobFinalizerImpl.handleAllJobsCompletion();
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of AbstractJobFinalizer to provide JobFinalizer implementation for MA_AcquisitionCompanyScanner queueable job.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class MA_AcquisitionCompanyScannerFinalizer extends MA_AcqCompanyTaskEnroller.AbstractJobFinalizer {
        public MA_AcquisitionCompanyScannerFinalizer(Object jobParams) {
            super(jobParams);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on each single job completion; enqueues a MA_TaskAutoEnroller job to auto-enrol / auto-remove acquisition 
        * contacts in all eligible company tasks for a given acquisition company
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion() {
            MA_AcqCompanyTaskEnrolWrapper.AutoEnrolStateful jobParams = (MA_AcqCompanyTaskEnrolWrapper.AutoEnrolStateful)super.jobParams;
            MA_AcqCompanyTaskEnrolWrapper.AutoEnrolTaskWrapper taskWrapper = jobParams.taskWrapperList[jobParams.currentCount];
            taskWrapper.companyTasks = MA_AcqCompanyTaskEnrollerHelper.getCompanyTasks(taskWrapper.companyId);
            taskWrapper.totalCompanyTasks = taskWrapper.companyTasks.size();
            if(!testJobEnqueued) {
                MA_AcqCompanyTaskAutoEnroller.enqueueTaskAutoEnrollerJob(jobParams);
            }
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on all jobs completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleAllJobsCompletion() {
            // For any future enhancement : may need to notify user once auto-enrolment is completed
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of AbstractJobFinalizer to provide JobFinalizer implementation for MA_TaskAutoEnroller queueable job.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class MA_TaskAutoEnrollerFinalizer extends MA_AcqCompanyTaskEnroller.AbstractJobFinalizer {
        public MA_TaskAutoEnrollerFinalizer(Object jobParams) {
            super(jobParams);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on each single job completion; recursively chains the same job handle next company task enrolment.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion() {
            MA_AcqCompanyTaskEnrolWrapper.AutoEnrolStateful jobParams = (MA_AcqCompanyTaskEnrolWrapper.AutoEnrolStateful)super.jobParams;
            if(!testJobEnqueued) {
                MA_AcqCompanyTaskAutoEnroller.enqueueTaskAutoEnrollerJob(jobParams);
            }
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on all jobs completion; enqueues a MA_AcquisitionCompanyScanner job to scan through the next acquistion company
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleAllJobsCompletion() {
            MA_AcqCompanyTaskEnrolWrapper.AutoEnrolStateful jobParams = (MA_AcqCompanyTaskEnrolWrapper.AutoEnrolStateful)super.jobParams;
            jobParams.currentCount++;
            if(!testJobEnqueued) {
                MA_AcqCompanyTaskAutoEnroller.enqueueCompanyScannerJob(jobParams);
            }
        }
    }
}