/**
 * W-13011399
 * Abstract Class to asynchronously inititate the process to Prepare Packages for selected Package Distribution records.
 * The ExecutionJob Enum Type will determine which PrepService implementation to be initiated to execute the PackagePrepJob.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         28/04/2023      Chakshu Malhotra        W-13011399 - Adds logic to asynchronously initiate processing of Package Prep within a Queueable job.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_PackagePrepService {
    
    public enum ExecutionJob {PREP_ACQ_CONTACTS}
    public enum ExecutionOrigin {PREP_REGEN_ALL, PREP_REGEN_SELECTED, AUDIT_FAILED_REGEN}

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Marker interface to serialize singleton instances of JobParams implementations and use across Async Jobs of type PackagePrepJob.
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
    * Method to enqueue the PackagePrepJob (Queueable Job) if within the Queueable Jobs Governor Limits.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void execute(PackagePrepJob packagePrepJob) {
        MA_DS_QueueableUtil.execute(packagePrepJob);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Strategy class to identify & execute the right implementation of the PackagePrepJob based on ExecutionJob Enum Type.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class ExecutionStrategy {
        private ExecutionJob executionJobType;
        private ExecutionOrigin executionOriginType;

        private Id srcRecordId;
        private Id acqCompanyId;

        private PackagePrepJob asyncJob;
        private PrepService prepService;

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Package Distribution Ids, used by PackagePrepJob to identify the Acquisition Contacts to process them for Package Prep or Regenration.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Set<Id> packagePrepPDIds {
            get {
                if(packagePrepPDIds == null) {
                    packagePrepPDIds = new Set<Id>();
                }
                return packagePrepPDIds;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Package Common Ids, used by PackagePrepJob in case of ExecutionOrigin.AUDIT_FAILED_REGEN to identify the Applied Rules based on Package Common Id on Acquisition Contacts to process them for Package Regeneration.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
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
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Template Ids, used by PackagePrepJob in case of ExecutionOrigin.AUDIT_FAILED_REGEN to identify the Applied Rules based on Template Ids to process them for Package Regeneration.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Set<String> templateIds {
            get {
                if(templateIds == null) {
                    templateIds = new Set<String>();
                }
                return templateIds;
            }set;
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Acquisition Contact Ids, used by PackagePrepJob in case of ExecutionOrigin.AUDIT_FAILED_REGEN to identify the Applied Rules based on Acquisition Contact Ids to process them for Package Regeneration.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Set<String> acqContactIds {
            get {
                if(acqContactIds == null) {
                    acqContactIds = new Set<String>();
                }
                return acqContactIds;
            }set;
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Applied Rule Ids, used by PackagePrepJob in case of ExecutionOrigin.AUDIT_FAILED_REGEN to identify the Applied Rules based on Applied Rule Ids to process them for Package Regeneration.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Set<String> appliedRuleIds {
            get {
                if(appliedRuleIds == null) {
                    appliedRuleIds = new Set<String>();
                }
                return appliedRuleIds;
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
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the srcRecordId, used by PackagePrepJob to set the notification target upon completion of all Package Prep API callouts.
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
        * Method to set the acqCompanyId, used by PackagePrepJob to identify the Acquisition Contacts related to the Acquisition Company Id.
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
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the packagePrepPDIds, used by PackagePrepJob to identify the Acquisition Contacts to process them for Package Prep or Regeneration.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    packagePrepPDIds	                DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to be processed for Package Prep or Regeneration)
        * @return   ExecutionStrategy                   DESCRIPTION (return ExecutionStrategy instance)
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setPackagePrepPDIds(Set<Id> packagePrepPDIds) {
            if(packagePrepPDIds != null) {
                this.packagePrepPDIds.addAll(packagePrepPDIds);
            }
            return this;
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the auditFailedCommonIds, used by PackagePrepJob to identify the Applied Rules to process them for Package Prep or Regeneration.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    auditFailedCommonIds	            DESCRIPTION (Data Type Set<String>, Set of Package Common Ids to be processed for Package Prep or Regeneration)
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
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the templateIds, used by PackagePrepJob to identify the Applied Rules to process them for Package Prep or Regeneration.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    templateIds	                        DESCRIPTION (Data Type Set<String>, Set of Package Common Ids to be processed for Package Prep or Regeneration)
        * @return   ExecutionStrategy                   DESCRIPTION (return ExecutionStrategy instance)
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setTemplateIds(Set<String> templateIds) {
            if(templateIds != null) {
                this.templateIds.addAll(templateIds);
            }
            return this;
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the acqContactIds, used by PackagePrepJob to identify the Applied Rules to process them for Package Prep or Regeneration.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    acqContactIds	                    DESCRIPTION (Data Type Set<String>, Set of Package Common Ids to be processed for Package Prep or Regeneration)
        * @return   ExecutionStrategy                   DESCRIPTION (return ExecutionStrategy instance)
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setAcqContactIds(Set<String> acqContactIds) {
            if(acqContactIds != null) {
                this.acqContactIds.addAll(acqContactIds);
            }
            return this;
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the appliedRuleIds, used by PackagePrepJob to identify the Applied Rules to process them for Package Prep or Regeneration.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    appliedRuleIds	                    DESCRIPTION (Data Type Set<String>, Set of Package Common Ids to be processed for Package Prep or Regeneration)
        * @return   ExecutionStrategy                   DESCRIPTION (return ExecutionStrategy instance)
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setAppliedRuleIds(Set<String> appliedRuleIds) {
            if(appliedRuleIds != null) {
                this.appliedRuleIds.addAll(appliedRuleIds);
            }
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the executionJobType, used by ExecutionStrategy to enqueue appropriate PackagePrepJob.
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
        * Method to set the executionOriginType, used by ExecutionStrategy to enqueue appropriate PackagePrepJob.
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
                when PREP_ACQ_CONTACTS {
                    prepServiceType = MA_DS_AcqContactsPackagePrepService.class;
                }
            }
            
            this.prepService = (PrepService)prepServiceType.newInstance();
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to initialize the PackagePrepJob by the PrepService implementation, based on ExecutionJob Enum type.
        * Sets JobParams as well as JobFinalizer on the PackagePrepJob.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy initPackagePrepJob() {
            switch on this.executionJobType {
                when PREP_ACQ_CONTACTS {
                    this.prepService.initPackagePrepJob(srcRecordId, acqCompanyId, packagePrepPDIds, auditFailedCommonIds, templateIds, acqContactIds, appliedRuleIds, executionOriginType);
                }
            }
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to enqueue and execute the PackagePrepJob to process Package Distributions for Package Prep.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void execute() {
            this.prepService.executePackagePrepJob();
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Interface to initialize PackagePrepJob implementation with JobParams & JobFinalizer and execute the job.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public interface PrepService {
        void executePackagePrepJob();
        void initPackagePrepJob(Id srcRecordId, Id acqCompanyId, Set<Id> packagePrepPDIds, Set<String> auditFailedCommonIds, Set<String> templateIds, Set<String> acqContactIds, Set<String> appliedRuleIds, ExecutionOrigin executionOriginType);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Abstract class to provide PrepService implementation & common logic for its sub-classes.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public abstract class PackagePrepService implements PrepService {
        protected PackagePrepJob packagePrepJob;

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute the PackagePrepJob to process Package Distributions for Package Prep.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void executePackagePrepJob() {
            MA_DS_PackagePrepService.execute(this.packagePrepJob);
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the PackagePrepService implementation classes, to initialize the PackagePrepJob.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void initPackagePrepJob(Id srcRecordId, Id acqCompanyId, Set<Id> packagePrepPDIds, Set<String> auditFailedCommonIds, Set<String> templateIds, Set<String> acqContactIds, Set<String> appliedRuleIds, ExecutionOrigin executionOriginType) {}
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Abstract Queueable implementation class, to be extended by Package Prep Execution Job(s) to process Package Distributions for Package Prep.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public abstract class PackagePrepJob implements System.Queueable, Database.AllowsCallouts {
        protected JobParams jobParams;
        protected JobFinalizer jobFinalizer;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Default constructor of the PackagePrepJob abstract class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public PackagePrepJob() {
            // default constructor : left blank intentionally to allow parameterized constructor to work.
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the PackagePrepJob abstract class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the PackagePrepJob type)
        * @param    jobFinalizer	    DESCRIPTION (Data Type JobFinalizer, JobFinalizer instance for the PackagePrepJob type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public PackagePrepJob(JobParams jobParams, JobFinalizer jobFinalizer) {
            this.jobParams = jobParams;
            this.jobFinalizer = jobFinalizer;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method of Queueable interface, to be implemented by the PackagePrepJob implementation classes.
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
    public abstract class PackagePrepJobFinalizer implements JobFinalizer {
        protected JobParams jobParams;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Default constructor of the PackagePrepJobFinalizer abstract class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public PackagePrepJobFinalizer() {
            // default constructor : left blank intentionally to allow parameterized constructor to work.
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the PackagePrepJobFinalizer abstract class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the PackagePrepJobFinalizer type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public PackagePrepJobFinalizer(JobParams jobParams) {
            this.jobParams = jobParams;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the PackagePrepJobFinalizer implementation classes, to perform action after final job completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void handleFinalJobCompletion() {}
        
        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the PackagePrepJobFinalizer implementation classes, to perform action after single job completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void handleSingleJobCompletion() {}
    }
}