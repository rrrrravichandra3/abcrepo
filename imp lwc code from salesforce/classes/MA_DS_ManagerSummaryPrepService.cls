/**
 * W-12578116
 * Abstract Class to asynchronously inititate the process to Prepare Manager Summaries for selected Package Distribution records.
 * The ExecutionJob Enum Type will determine which PrepService implementation to be initiated to execute the SummaryPrepJob.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         27/03/2023      Chakshu Malhotra        W-12578116 - Adds logic to asynchronously initiate processing of Manager Summaries Prep within a Queueable job.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_ManagerSummaryPrepService {

    public enum ExecutionJob {PREP_OFFER_COMMUNICATORS, PREP_SUMMARIZED_CONTACTS}
    public enum ExecutionOrigin {PREP_REGEN_ALL, PREP_REGEN_SELECTED, AUDIT_FAILED_REGEN}
    
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Marker interface to serialize singleton instances of JobParams implementations and use across Async Jobs of type SummaryPrepJob.
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
    * Method to enqueue the SummaryPrepJob (Queueable Job) if within the Queueable Jobs Governor Limits.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void execute(SummaryPrepJob summaryPrepJob) {
        MA_DS_QueueableUtil.execute(summaryPrepJob);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Strategy class to identify & execute the right implementation of the SummaryPrepJob based on ExecutionJob Enum Type.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class ExecutionStrategy {
        private ExecutionJob executionJobType;
        private ExecutionOrigin executionOriginType;

        private Id commonId;
        private Id srcRecordId;
        private Id acqCompanyId;
        private Id summaryTemplateId;

        private SummaryPrepJob asyncJob;
        private PrepService prepService;

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Package Distribution Ids, used by SummaryPrepJob to identify the Offer Communicator Ids to process them for Manager Summary Prep or Regenration.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Set<Id> summaryPrepPDIds {
            get {
                if(summaryPrepPDIds == null) {
                    summaryPrepPDIds = new Set<Id>();
                }
                return summaryPrepPDIds;
            }set;
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Manager Summary Common Ids, used by SummaryPrepJob in case of ExecutionOrigin.AUDIT_FAILED_REGEN to identify the Applied Rules to process them for Manager Summary Regeneration.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Set<String> auditFailedCommonIds {
            get {
                if(auditFailedCommonIds == null) {
                    auditFailedCommonIds = new Set<String>();
                }
                return auditFailedCommonIds;
            }set;
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Offer Communicator Ids, used by SummaryPrepJob to prepare & send payload for Manager Summary Prep callout to DocuSign CLM.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Set<String> offerCommunicatorIds {
            get {
                if(offerCommunicatorIds == null) {
                    offerCommunicatorIds = new Set<String>();
                }
                return offerCommunicatorIds;
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
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the commonId, used by SummaryPrepJob to add in the payload of Manager Summary Prep API callout.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    commonId	                    DESCRIPTION (Data Type Id, Manager Summary Common Id to be added in the payload of Manager Summary Prep API callout)
        * @return   ExecutionStrategy               DESCRIPTION (return ExecutionStrategy instance)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setCommonId(Id commonId) {
            this.commonId = commonId;
            return this;
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the srcRecordId, used by SummaryPrepJob to set the notification target upon completion of all Summary Prep API callouts.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    srcRecordId	                        DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
        * @return   ExecutionStrategy                   DESCRIPTION (return ExecutionStrategy instance)
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setSrcRecordId(Id srcRecordId) {
            this.srcRecordId = srcRecordId;
            return this;
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the acqCompanyId, used by SummaryPrepJob to identify the Acquisition Contacts related to the Acquisition Company Id.
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
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the summaryTemplateId, used by SummaryPrepJob to add it to the API payload for Manager Summary Prep callout.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    summaryTemplateId	                DESCRIPTION (Data Type Id, Template record Id of Document type Manager Summary)
        * @return   ExecutionStrategy                   DESCRIPTION (return ExecutionStrategy instance)
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setSummaryTemplateId(Id summaryTemplateId) {
            this.summaryTemplateId = summaryTemplateId;
            return this;
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the summaryPrepPDIds, used by SummaryPrepJob to identify the Offer Communicator Ids to process them for Manager Summary Prep or Regeneration.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    summaryPrepPDIds	                DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to be processed for Manager Summary Prep or Regeneration)
        * @return   ExecutionStrategy                   DESCRIPTION (return ExecutionStrategy instance)
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setSummaryPrepPDIds(Set<Id> summaryPrepPDIds) {
            if(summaryPrepPDIds != null) {
                this.summaryPrepPDIds.addAll(summaryPrepPDIds);
            }
            return this;
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the auditFailedCommonIds, used by SummaryPrepJob to identify the Offer Communicator Ids to process them for Manager Summary Prep or Regeneration.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    auditFailedCommonIds	            DESCRIPTION (Data Type Set<String>, Set of Manager Summary Common Ids to be processed for Manager Summary Prep or Regeneration)
        * @return   ExecutionStrategy                   DESCRIPTION (return ExecutionStrategy instance)
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setAuditFailedCommonIds(Set<String> auditFailedCommonIds) {
            if(auditFailedCommonIds != null) {
                this.auditFailedCommonIds.addAll(auditFailedCommonIds);
            }
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the offerCommunicatorIds, used by SummaryPrepJob to prepare & send payload for Manager Summary Prep callout to DocuSign CLM.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    offerCommunicatorIds	            DESCRIPTION (Data Type Set<String>, Set of Offer Communicator Ids processed for Manager Summary Prep)
        * @return   ExecutionStrategy                   DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setOfferCommunicatorIds(Set<String> offerCommunicatorIds) {
            if(offerCommunicatorIds != null) {
                this.offerCommunicatorIds.addAll(offerCommunicatorIds);
            }
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the executionJobType, used by ExecutionStrategy to enqueue appropriate SummaryPrepJob.
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
        * Method to set the executionOriginType, used by ExecutionStrategy to enqueue appropriate SummaryPrepJob.
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
        * Method to initialize the PrepService implementation based on ExecutionJob Enum type.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy initPrepService() {
            Type prepServiceType;

            switch on this.executionJobType {
                when PREP_OFFER_COMMUNICATORS {
                    prepServiceType = MA_DS_OfferCommunicatorsPrepService.class;
                }when PREP_SUMMARIZED_CONTACTS {
                    prepServiceType = MA_DS_SummarizedContactsPrepService.class;
                }
            }
            
            this.prepService = (PrepService)prepServiceType.newInstance();
            return this;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to initialize the SummaryPrepJob by the PrepService implementation, based on ExecutionJob Enum type.
        * Sets JobParams as well as JobFinalizer on the SummaryPrepJob.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy initSummaryPrepJob() {
            switch on this.executionJobType {
                when PREP_OFFER_COMMUNICATORS {
                    this.prepService.initSummaryPrepJob(srcRecordId, acqCompanyId, summaryTemplateId, summaryPrepPDIds, auditFailedCommonIds, offerCommunicatorIds, executionOriginType);
                }when PREP_SUMMARIZED_CONTACTS {
                    this.prepService.initSummaryPrepJob(commonId, srcRecordId, acqCompanyId, summaryTemplateId, summaryPrepPDIds, offerCommunicatorIds, executionOriginType);
                }
            }
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to enqueue and execute the SummaryPrepJob to process Package Distributions for Manager Summary Prep.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void execute() {
            this.prepService.executeSummaryPrepJob();
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Interface to initialize SummaryPrepJob implementation with JobParams & JobFinalizer and execute the job.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public interface PrepService {
        void executeSummaryPrepJob();
        void initSummaryPrepJob(Id commonId, Id srcRecordId, Id acqCompanyId, Id summaryTemplateId, Set<Id> summaryPrepPDIds, Set<String> offerCommunicatorIds, ExecutionOrigin executionOriginType);
        void initSummaryPrepJob(Id srcRecordId, Id acqCompanyId, Id summaryTemplateId, Set<Id> summaryPrepPDIds, Set<String> auditFailedCommonIds, Set<String> offerCommunicatorIds, ExecutionOrigin executionOriginType);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Abstract class to provide PrepService implementation & common logic for its sub-classes.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public abstract class SummaryPrepService implements PrepService {
        protected SummaryPrepJob summaryPrepJob;

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute the SummaryPrepJob to process Package Distributions for Manager Summary Prep.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void executeSummaryPrepJob() {
            MA_DS_ManagerSummaryPrepService.execute(this.summaryPrepJob);
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the SummaryPrepService implementation classes, to initialize the SummaryPrepJob.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void initSummaryPrepJob(Id commonId, Id srcRecordId, Id acqCompanyId, Id summaryTemplateId, Set<Id> summaryPrepPDIds, Set<String> offerCommunicatorIds, ExecutionOrigin executionOriginType) {}

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the SummaryPrepService implementation classes, to initialize the SummaryPrepJob.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void initSummaryPrepJob(Id srcRecordId, Id acqCompanyId, Id summaryTemplateId, Set<Id> summaryPrepPDIds, Set<String> auditFailedCommonIds, Set<String> offerCommunicatorIds, ExecutionOrigin executionOriginType) {}
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Abstract Queueable implementation class, to be extended by Summary Prep Execution Jobs to process Package Distributions for Manager Summary Prep.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public abstract class SummaryPrepJob implements System.Queueable, Database.AllowsCallouts {
        protected JobParams jobParams;
        protected JobFinalizer jobFinalizer;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Default constructor of the SummaryPrepJob abstract class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public SummaryPrepJob() {
            // default constructor : left blank intentionally to allow parameterized constructor to work.
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the SummaryPrepJob abstract class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the SummaryPrepJob type)
        * @param    jobFinalizer	    DESCRIPTION (Data Type JobFinalizer, JobFinalizer instance for the SummaryPrepJob type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public SummaryPrepJob(JobParams jobParams, JobFinalizer jobFinalizer) {
            this.jobParams = jobParams;
            this.jobFinalizer = jobFinalizer;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method of Queueable interface, to be implemented by the SummaryPrepJob implementation classes.
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
    public abstract class SummaryPrepJobFinalizer implements JobFinalizer {
        protected JobParams jobParams;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Default constructor of the SummaryPrepJobFinalizer abstract class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public SummaryPrepJobFinalizer() {
            // default constructor : left blank intentionally to allow parameterized constructor to work.
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the SummaryPrepJobFinalizer abstract class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the SummaryPrepJobFinalizer type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public SummaryPrepJobFinalizer(JobParams jobParams) {
            this.jobParams = jobParams;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the SummaryPrepJobFinalizer implementation classes, to perform action after final job completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void handleFinalJobCompletion() {}
        
        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the SummaryPrepJobFinalizer implementation classes, to perform action after single job completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void handleSingleJobCompletion() {}
    }
}