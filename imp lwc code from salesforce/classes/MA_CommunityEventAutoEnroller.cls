/**
 * W-10449458
 * Abstract class to auto-enrol or remove community users from events using Queueable chaining logic.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         01/02/2022      Chakshu Malhotra        Holds Queueable chaining logic to auto-enrol or remove (upsert / delete attendees) community users from events.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract class MA_CommunityEventAutoEnroller {
    @TestVisible private static Boolean testJobEnqueued = false;
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to create & pass serialized state of event enrolment detail across recursively instantiated queueable jobs.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class StatefulQueueable {
        public Integer currentCount {get; set;}
        public Integer totalCompanies {get; set;}
        public List<AutoEnrolEventWrapper> eventWrapperList {get; set;}
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold details of MA_Community_Event_Auto_Enrol_Event__e records.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class AutoEnrolEventWrapper {
        public Id companyId {get; set;}
        public Integer totalEvents {get; set;}
        public Integer currentCount {get; set;}
        public Set<String> acqContactIds {get; set;}
        public List<MA_Community_Events__c> events {get; set;}
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to initialize queueable instance and enqueue it.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    statefulInstance          DESCRIPTION (Data type StatefulQueueable, Serialized state of queueable job)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void execute(StatefulQueueable statefulInstance) {
        enqueueCompanyScannerJob(statefulInstance);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to enqueue MA_AcquisitionCompanyScanner queueable job & attach finalizer actions with it.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    statefulInstance          DESCRIPTION (Data type StatefulQueueable, Serialized state of queueable job)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void enqueueCompanyScannerJob(StatefulQueueable statefulInstance) {
        enqueueJob(new MA_AcquisitionCompanyScanner(statefulInstance, MA_AcquisitionCompanyScannerFinalizer.class));
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to enqueue MA_EventAutoEnroller queueable job & attach finalizer actions with it.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    statefulInstance          DESCRIPTION (Data type StatefulQueueable, Serialized state of queueable job)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @TestVisible
    private static void enqueueEventAutoEnrollerJob(StatefulQueueable statefulInstance) {
        enqueueJob(new MA_EventAutoEnroller(statefulInstance, MA_EventAutoEnrollerFinalizer.class));
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to enqueue the queueable job if it's within governor limits.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    asyncJob        DESCRIPTION (Data type Queueable, Queueable job instance)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void enqueueJob(Queueable asyncJob) {
        if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
            System.enqueueJob(asyncJob);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to scan through each acquistion company to process auto-enrolment on its events.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    class MA_AcquisitionCompanyScanner implements Queueable {
        private StatefulQueueable jobParams;
        private Type queueableFinalizerImpl;

        public MA_AcquisitionCompanyScanner(StatefulQueueable jobParams, Type queueableFinalizerImpl) {
            this.jobParams = jobParams;
            this.queueableFinalizerImpl = queueableFinalizerImpl;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to process auto-enrolment logic for each acquisition company as received from platform events.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void execute(QueueableContext qContext) {
            QueueableFinalizer queueableFinalizer = (QueueableFinalizer)queueableFinalizerImpl.newInstance();

            if(jobParams.currentCount < jobParams.totalCompanies) {
                queueableFinalizer.handleSingleJobCompletion(jobParams);
            }else {
                queueableFinalizer.handleAllJobsCompletion(jobParams);
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to auto-enrol / auto-remove acquisition contacts from community events.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    class MA_EventAutoEnroller implements Queueable {
        private StatefulQueueable jobParams;
        private Type queueableFinalizerImpl;

        public MA_EventAutoEnroller(StatefulQueueable jobParams, Type queueableFinalizerImpl) {
            this.jobParams = jobParams;
            this.queueableFinalizerImpl = queueableFinalizerImpl;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to process auto-enrolment or removal of acquisition contacts from community events.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void execute(QueueableContext qContext) {
            Id asyncJobId = qContext.getJobId();

            AutoEnrolEventWrapper eventWrapper = jobParams.eventWrapperList[jobParams.currentCount];
            MA_Community_Events__c currentEvent = eventWrapper.events[eventWrapper.currentCount];
            Set<String> eligibleContactIds = MA_CommunityEventAutoEnrollerHelper.getEligibleContactIds(currentEvent, eventWrapper.acqContactIds);
            
            MA_CommunityEventAutoEnrollerHelper.enrolToCommunityEvent(currentEvent.Id, asyncJobId, eventWrapper.acqContactIds);
            MA_CommunityEventAutoEnrollerHelper.removeIneligibleEventEnrolment(currentEvent.Id, eligibleContactIds, eventWrapper.acqContactIds);
            eventWrapper.currentCount++;

            QueueableFinalizer queueableFinalizer = (QueueableFinalizer)queueableFinalizerImpl.newInstance();

            if(eventWrapper.currentCount < eventWrapper.totalEvents) {
                queueableFinalizer.handleSingleJobCompletion(jobParams);
            }else {
                queueableFinalizer.handleAllJobsCompletion(jobParams);
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Interface to attach final action to queueable execution for each chained job as well as completion of all chained jobs.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private interface QueueableFinalizer {
        void handleAllJobsCompletion(StatefulQueueable jobParams);
        void handleSingleJobCompletion(StatefulQueueable jobParams);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Abstract class to provide QueueableFinalizer implementation & common logic for its sub-classes.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private abstract class AbstractQueueableFinalizer implements QueueableFinalizer {
        public abstract void handleAllJobsCompletion(StatefulQueueable jobParams);
        public abstract void handleSingleJobCompletion(StatefulQueueable jobParams);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of AbstractQueueableFinalizer to provide QueueableFinalizer implementation for MA_AcquisitionCompanyScanner queueable job.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class MA_AcquisitionCompanyScannerFinalizer extends AbstractQueueableFinalizer {
        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on each single job completion; enqueues a MA_EventAutoEnroller job to auto-enrol / auto-remove acquisition 
        * contacts in all eligible community events for a given acquisition company
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams    DESCRIPTION (Data type StatefulQueueable, Serialized state of queueable job)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion(StatefulQueueable jobParams) {
            AutoEnrolEventWrapper eventWrapper = jobParams.eventWrapperList[jobParams.currentCount];
            eventWrapper.events = MA_CommunityEventAutoEnrollerHelper.getCommunityEvents(eventWrapper.companyId);
            eventWrapper.totalEvents = eventWrapper.events.size();
            if(!testJobEnqueued) {
                MA_CommunityEventAutoEnroller.enqueueEventAutoEnrollerJob(jobParams);
            }
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on all jobs completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams    DESCRIPTION (Data type StatefulQueueable, Serialized state of queueable job)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleAllJobsCompletion(StatefulQueueable jobParams) {
            // For any future enhancement : may need to notify user once auto-enrolment is completed
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of AbstractQueueableFinalizer to provide QueueableFinalizer implementation for MA_EventAutoEnroller queueable job.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class MA_EventAutoEnrollerFinalizer extends AbstractQueueableFinalizer {
        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on each single job completion; recursively chains the same job handle next community event enrolment.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams    DESCRIPTION (Data type StatefulQueueable, Serialized state of queueable job)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion(StatefulQueueable jobParams) {
            MA_CommunityEventAutoEnroller.enqueueEventAutoEnrollerJob(jobParams);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on all jobs completion; enqueues a MA_AcquisitionCompanyScanner job to scan through the next acquistion company
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams    DESCRIPTION (Data type StatefulQueueable, Serialized state of queueable job)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleAllJobsCompletion(StatefulQueueable jobParams) {
            jobParams.currentCount++;
            if(!testJobEnqueued) {
                MA_CommunityEventAutoEnroller.enqueueCompanyScannerJob(jobParams);
            }
        }
    }
}