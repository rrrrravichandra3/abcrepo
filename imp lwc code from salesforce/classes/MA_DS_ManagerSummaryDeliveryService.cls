/**
 * W-12578130
 * Abstract Class to asynchronously inititate the process to Deliver Manager Summaries for selected Package Distribution records.
 * The ExecutionJob Enum Type will determine which DeliveryService implementation to be initiated to execute the SummaryDeliveryJob.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         20/04/2023      Chakshu Malhotra        W-12578130 - Adds logic to asynchronously initiate processing of Manager Summaries Delivery within a Queueable job.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_ManagerSummaryDeliveryService {

    public enum ExecutionJob {DELIVER_PACKAGE_DISTRIBUTION, DELIVER_OFFER_COMMUNICATORS}
    public enum ExecutionOrigin {DELIVER_ALL, DELIVER_SELECTED, SCHEDULED_DELIVERY}
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Marker interface to serialize singleton instances of JobParams implementations and use across Async Jobs of type SummaryDeliveryJob.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public interface JobParams {
        // Marker interface
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to set & hold the final singleton instance of ExecutionStrategy.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static final ExecutionStrategy strategyInstance {
        get {
            if(strategyInstance == null) {
                strategyInstance = new ExecutionStrategy();
            }
            return strategyInstance;
        }private set;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to enqueue the SummaryDeliveryJob (Queueable Job) if within the Queueable Jobs Governor Limits.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void execute(SummaryDeliveryJob summaryDeliveryJob) {
        MA_DS_QueueableUtil.execute(summaryDeliveryJob);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Strategy class to identify & execute the right implementation of the SummaryDeliveryJob based on ExecutionJob Enum Type.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class ExecutionStrategy {
        private ExecutionJob executionJobType;
        private ExecutionOrigin executionOriginType;

        private Id srcRecordId;
        private Id targetUserId;
        private Id acqCompanyId;
        private Acquisition_Company__c acqCompany;

        private SummaryDeliveryJob asyncJob;
        private DeliveryService deliveryService;

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Package Distribution Ids, used by SummaryDeliveryJob to identify the Offer Communicator Ids to process them for Manager Summary Delivery.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Set<Id> summaryDeliveryPDIds {
            get {
                if(summaryDeliveryPDIds == null) {
                    summaryDeliveryPDIds = new Set<Id>();
                }
                return summaryDeliveryPDIds;
            }set;
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Map of Package Distribution Id to List of Offer Communicator Ids, used by SummaryDeliveryJob to prepare & send payload for Manager Summary Delivery API callout to DocuSign CLM.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Map<Id, List<Id>> offerCommunicatorMap {
            get {
                if(offerCommunicatorMap == null) {
                    offerCommunicatorMap = new Map<Id, List<Id>>();
                }
                return offerCommunicatorMap;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Map of Package Distribution Id to "Custom Manager Summary Email" flag value, used by SummaryDeliveryJob to prepare & send payload for Manager Summary Delivery API callout to DocuSign CLM.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Map<Id, Boolean> customSummaryEmailMap {
            get {
                if(customSummaryEmailMap == null) {
                    customSummaryEmailMap = new Map<Id, Boolean>();
                }
                return customSummaryEmailMap;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Private default constructor of ExecutionStrategy class to enforce the singleton design.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private ExecutionStrategy() {
            // to enforce singleton design
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the srcRecordId, used by SummaryDeliveryJob to set the notification target upon completion of all Summary Delivery API callouts.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    srcRecordId	                        DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
        * @return   ExecutionStrategy                   DESCRIPTION (return ExecutionStrategy instance)
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setSrcRecordId(Id srcRecordId) {
            this.srcRecordId = srcRecordId;
            return this;
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the targetUserId, used by SummaryDeliveryJob to set the notification target upon completion of all Summary Delivery API callouts.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    targetUserId	                    DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
        * @return   ExecutionStrategy                   DESCRIPTION (return ExecutionStrategy instance)
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setTargetUserId(Id targetUserId) {
            this.targetUserId = targetUserId;
            return this;
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the acqCompanyId, used by SummaryDeliveryJob to identify the Acquisition Contacts related to the Acquisition Company Id.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    acqCompanyId	                    DESCRIPTION (Data Type Id, Acquisition Company record Id)
        * @return   ExecutionStrategy                   DESCRIPTION (return ExecutionStrategy instance)
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setAcqCompanyId(Id acqCompanyId) {
            this.acqCompanyId = acqCompanyId;
            return this;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the acqCompany, used by SummaryDeliveryJob to send in the Manager Summary Delivery API request payload.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    acqCompany	                        DESCRIPTION (Data Type String, Acquisition Company record containing Manager Summary Email Subject & Body)
        * @return   ExecutionStrategy                   DESCRIPTION (return ExecutionStrategy instance)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setAcquisitionCompany(Acquisition_Company__c acqCompany) {
            this.acqCompany = acqCompany;
            return this;
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the summaryDeliveryPDIds, used by SummaryDeliveryJob to identify the Offer Communicator Ids to process them for Manager Summary Delivery.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    summaryDeliveryPDIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to be processed for Manager Summary Delivery)
        * @return   ExecutionStrategy                   DESCRIPTION (return ExecutionStrategy instance)
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setSummaryDeliveryPDIds(Set<Id> summaryDeliveryPDIds) {
            this.summaryDeliveryPDIds.addAll(summaryDeliveryPDIds);
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the offerCommunicatorMap, used by SummaryDeliveryJob to prepare & send payload for Manager Summary Delivery API callout to DocuSign CLM.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    offerCommunicatorMap	            DESCRIPTION (Data Type Map<Id, List<Id>>, Map of Package Distribution Id to List of Offer Communicator Ids for Manager Summary Delivery)
        * @return   ExecutionStrategy                   DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setOfferCommunicatorMap(Map<Id, List<Id>> offerCommunicatorMap) {
            this.offerCommunicatorMap.putAll(offerCommunicatorMap);
            return this;
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the customSummaryEmailMap, used by SummaryDeliveryJob to prepare & send payload for Manager Summary Delivery API callout to DocuSign CLM.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    customSummaryEmailMap	            DESCRIPTION (Data Type Map<Id, Boolean>, Map of Package Distribution Id to "Custom Manager Summary Email" flag value for Manager Summary Delivery)
        * @return   ExecutionStrategy                   DESCRIPTION (return ExecutionStrategy instance)
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setCustomSummaryEmailMap(Map<Id, Boolean> customSummaryEmailMap) {
            this.customSummaryEmailMap.putAll(customSummaryEmailMap);
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the executionJobType, used by ExecutionStrategy to enqueue appropriate SummaryDeliveryJob.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    executionJobType	                DESCRIPTION (Data Type ExecutionJob, Enum Type ExecutionJob)
        * @return   ExecutionStrategy                   DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setExecutionJobType(ExecutionJob executionJobType) {
            this.executionJobType = executionJobType;
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the executionOriginType, used by ExecutionStrategy to enqueue appropriate SummaryDeliveryJob.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    executionOriginType	                DESCRIPTION (Data Type ExecutionOrigin, Enum Type ExecutionOrigin)
        * @return   ExecutionStrategy                   DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setExecutionJobOriginType(ExecutionOrigin executionOriginType) {
            this.executionOriginType = executionOriginType;
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to initialize the DeliveryService implementation based on ExecutionJob Enum type.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy initDeliveryService() {
            Type deliveryServiceType;

            switch on this.executionJobType {
                when DELIVER_PACKAGE_DISTRIBUTION {
                    deliveryServiceType = MA_DS_PackageDistributionDeliveryService.class;
                }when DELIVER_OFFER_COMMUNICATORS {
                    deliveryServiceType = MA_DS_OfferCommunicatorsDeliveryService.class;
                }
            }
            
            this.deliveryService = (DeliveryService)deliveryServiceType.newInstance();
            return this;
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to initialize the SummaryDeliveryJob by the DeliveryService implementation, based on ExecutionJob Enum type.
        * Sets JobParams as well as JobFinalizer on the SummaryDeliveryJob.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy initSummaryDeliveryJob() {
            switch on this.executionJobType {
                when DELIVER_PACKAGE_DISTRIBUTION {
                    this.deliveryService.initSummaryDeliveryJob(srcRecordId, acqCompanyId, summaryDeliveryPDIds, executionOriginType);
                }when DELIVER_OFFER_COMMUNICATORS {
                    this.deliveryService.initSummaryDeliveryJob(srcRecordId, targetUserId, acqCompany, summaryDeliveryPDIds, offerCommunicatorMap, customSummaryEmailMap, executionOriginType);
                }
            }
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to enqueue and execute the SummaryDeliveryJob to process Package Distributions for Manager Summary Delivery.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void execute() {
            this.deliveryService.executeSummaryDeliveryJob();
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Interface to initialize SummaryDeliveryJob implementation with JobParams & JobFinalizer and execute the job.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public interface DeliveryService {
        void executeSummaryDeliveryJob();
        void initSummaryDeliveryJob(Id srcRecordId, Id acqCompanyId, Set<Id> summaryDeliveryPDIds, ExecutionOrigin executionOriginType);
        void initSummaryDeliveryJob(Id srcRecordId, Id targetUserId, Acquisition_Company__c acqCompany, Set<Id> summaryDeliveryPDIds, Map<Id, List<Id>> offerCommunicatorMap, Map<Id, Boolean> customSummaryEmailMap, ExecutionOrigin executionOriginType);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Abstract class to provide DeliveryService implementation & common logic for its sub-classes.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public abstract class SummaryDeliveryService implements DeliveryService {
        protected SummaryDeliveryJob summaryDeliveryJob;

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute the SummaryDeliveryJob to process Package Distributions for Manager Summary Delivery.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void executeSummaryDeliveryJob() {
            //MA_DS_ManagerSummaryDeliveryService.execute(this.summaryDeliveryJob);
            MA_DS_QueueableUtil.execute(this.summaryDeliveryJob);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the SummaryDeliveryService implementation classes, to initialize the SummaryDeliveryJob.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void initSummaryDeliveryJob(Id srcRecordId, Id acqCompanyId, Set<Id> summaryDeliveryPDIds, ExecutionOrigin executionOriginType) {}

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the SummaryDeliveryService implementation classes, to initialize the SummaryDeliveryJob.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void initSummaryDeliveryJob(Id srcRecordId, Id targetUserId, Acquisition_Company__c acqCompany, Set<Id> summaryDeliveryPDIds, Map<Id, List<Id>> offerCommunicatorMap, Map<Id, Boolean> customSummaryEmailMap, ExecutionOrigin executionOriginType) {}
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Abstract Queueable implementation class, to be extended by Summary Delivery Execution Jobs to process Package Distributions for Manager Summary Delivery.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public abstract class SummaryDeliveryJob implements System.Queueable, Database.AllowsCallouts {
        protected JobParams jobParams;
        protected JobFinalizer jobFinalizer;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Default constructor of the SummaryDeliveryJob abstract class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public SummaryDeliveryJob() {
            // default constructor : left blank intentionally to allow parameterized constructor to work.
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the SummaryDeliveryJob abstract class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the SummaryDeliveryJob type)
        * @param    jobFinalizer	    DESCRIPTION (Data Type JobFinalizer, JobFinalizer instance for the SummaryDeliveryJob type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public SummaryDeliveryJob(JobParams jobParams, JobFinalizer jobFinalizer) {
            this.jobParams = jobParams;
            this.jobFinalizer = jobFinalizer;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method of Queueable interface, to be implemented by the SummaryDeliveryJob implementation classes.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        protected abstract void execute(QueueableContext qContext);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Interface to attach final action to queueable execution for each chained job as well as completion of final chained job.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public interface JobFinalizer {
        void handleFinalJobCompletion();
        void handleSingleJobCompletion();
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Abstract class to provide JobFinalizer implementation & common logic for its sub-classes.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public abstract class SummaryDeliveryJobFinalizer implements JobFinalizer {
        protected JobParams jobParams;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Default constructor of the SummaryDeliveryJobFinalizer abstract class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public SummaryDeliveryJobFinalizer() {
            // default constructor : left blank intentionally to allow parameterized constructor to work.
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the SummaryDeliveryJobFinalizer abstract class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the SummaryDeliveryJobFinalizer type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public SummaryDeliveryJobFinalizer(JobParams jobParams) {
            this.jobParams = jobParams;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the SummaryDeliveryJobFinalizer implementation classes, to perform action after final job completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void handleFinalJobCompletion() {}
        
        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the SummaryDeliveryJobFinalizer implementation classes, to perform action after single job completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void handleSingleJobCompletion() {}
    }
}