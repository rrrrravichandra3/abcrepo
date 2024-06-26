/**
 * ******************************************** W-12578108 : RULE ENGINE ********************************************
 * 
 * Abstract Class to asynchronously initiate processing of Applied Rules within a Queueable job.
 * Executes Rules Syncing Process or Auto Application of Rules based on the ExecutionMode.
 * Executes the Package or Template ExecutionJob based on the Rules Sync Status value.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         17/03/2023      Chakshu Malhotra        W-12578108 - Adds logic to asynchronously initiate processing of Applied Rules within a Queueable job.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_AppliedRulesService {

    public enum ExecutionMode {SYNC_RULE, AUTO_APPLY_RULE}
    public enum ExecutionJob {PACKAGE_RULE_SYNC, TEMPLATE_RULE_SYNC, PURGE_RULE_SYNC, RULE_APPLIED_SYNC}

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Marker interface to serialize singleton instances of JobParams implementations and use across multiple-chained jobs of type AppliedRuleJob.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
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
    * Method to enqueue the AppliedRuleJob (Queueable Job) if within the Queueable Jobs Governor Limits.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void execute(AppliedRuleJob appliedRuleJob) {
        MA_DS_QueueableUtil.execute(appliedRuleJob);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Strategy class to identify & execute the right implementation of the AppliedRuleJob based on ExecutionMode & ExecutionJob.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class ExecutionStrategy {
        private ExecutionJob execJob;
        private ExecutionMode execMode;
        private ExecutionJob originExecJob;

        private Boolean summaryDocRuleSync;
        private Boolean packageDocRuleSync;

        private Id pkgId;
        private Id acqCompanyId;
        private Id pkgDistributionId;
        private SyncService syncService;
        private AppliedRuleJob asyncJob;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the List of all eligible Derived Template Ids that need to be processed for Applying Rules.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public List<Id> templateIds {
            get {
                if(templateIds == null) {
                    templateIds = new List<Id>();
                }
                return templateIds;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of AsyncApexJob Ids that processed Applied Rules of Package Distribution type or In Use Template type or both.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Set<Id> asyncApexJobIds {
            get {
                if(asyncApexJobIds == null) {
                    asyncApexJobIds = new Set<Id>();
                }
                return asyncApexJobIds;
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
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the ExecutionMode enum type, used by ExecutionStrategy to enqueue appropriate AppliedRuleJob.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    execMode	            DESCRIPTION (Data Type ExecutionMode, ExecutionMode enum type)
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setExecutionModeEnum(ExecutionMode execMode) {
            this.execMode = execMode;
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the ExecutionJob enum type, used by ExecutionStrategy to enqueue appropriate AppliedRuleJob.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    execJob	                DESCRIPTION (Data Type ExecutionJob, ExecutionJob enum type)
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setExecutionJobEnum(ExecutionJob execJob) {
            this.execJob = execJob;
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the ExecutionJob enum type, used by ExecutionStrategy to enqueue appropriate AppliedRuleJob.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    originExecJob	        DESCRIPTION (Data Type ExecutionJob, ExecutionJob enum type of the first Job that initiated the Rule Sync process)
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setOriginExecutionJobEnum(ExecutionJob originExecJob) {
            this.originExecJob = originExecJob;
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the acqCompanyId, used by ExecutionStrategy to initialize properties of JobParams (used within AppliedRuleJob).
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    acqCompanyId	        DESCRIPTION (Data Type Id, Acquisition Company record Id of the Package record)
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setAcquisitionCompanyId(Id acqCompanyId) {
            this.acqCompanyId = acqCompanyId;
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the pkgId, used by ExecutionStrategy to initialize properties of JobParams (used within AppliedRuleJob).
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    pkgId	                DESCRIPTION (Data Type Id, Package record Id of the Package Distribution record)
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setPackageId(Id pkgId) {
            this.pkgId = pkgId;
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the pkgDistributionId, used by ExecutionStrategy to initialize properties of JobParams (used within AppliedRuleJob).
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    pkgDistributionId	    DESCRIPTION (Data Type Id, Package Distribution record Id)
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setPackageDistributionId(Id pkgDistributionId) {
            this.pkgDistributionId = pkgDistributionId;
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the summaryDocRuleSync, used by ExecutionStrategy to initialize properties of JobParams (used within AppliedRuleJob).
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    summaryDocRuleSync	    DESCRIPTION (Data Type Boolean, Package Distribution record Id)
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setSummaryDocRuleSync(Boolean summaryDocRuleSync) {
            this.summaryDocRuleSync = summaryDocRuleSync;
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the packageDocRuleSync, used by ExecutionStrategy to initialize properties of JobParams (used within AppliedRuleJob).
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    packageDocRuleSync	    DESCRIPTION (Data Type Boolean, Package Distribution record Id)
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setPackageDocRuleSync(Boolean packageDocRuleSync) {
            this.packageDocRuleSync = packageDocRuleSync;
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the asyncApexJobIds, used by ExecutionStrategy to initialize the AppliedRuleJob by using the right overloaded method.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    asyncApexJobIds	        DESCRIPTION (Data Type List<Id>, AsyncApexJob Ids of the Queueable Jobs that processed Applied Rules)
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setTemplateIds(List<Id> templateIds) {
            this.templateIds.addAll(templateIds);
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the asyncApexJobIds, used by ExecutionStrategy to initialize the AppliedRuleJob by using the right overloaded method.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    asyncApexJobIds	        DESCRIPTION (Data Type Set<Id>, AsyncApexJob Ids of the Queueable Jobs that processed Applied Rules)
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setAsyncApexJobIds(Set<Id> asyncApexJobIds) {
            this.asyncApexJobIds.addAll(asyncApexJobIds);
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to initialize the AppliedRuleJob based on ExecutionMode & ExecutionJob.
        * Sets JobParams as well as JobFinalizer on the AppliedRuleJob.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy initAppliedRuleJob() {
            switch on this.execMode {
                when SYNC_RULE {
                    this.syncService = this.getSyncService();
                }
            }

            this.initAppliedRuleJob(this.execJob);
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the instance of SyncService implementation.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   SyncService            DESCRIPTION (return SyncService instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private SyncService getSyncService() {
            Type syncService;

            switch on this.execJob {
                when PACKAGE_RULE_SYNC {
                    syncService = MA_DS_PackageAppliedRuleSyncService.class;
                }when TEMPLATE_RULE_SYNC {
                    syncService = MA_DS_TemplateAppliedRuleSyncService.class;
                }when PURGE_RULE_SYNC {
                    syncService = MA_DS_PurgeAppliedRuleSyncService.class;
                }when RULE_APPLIED_SYNC {
                    syncService = MA_DS_RuleAppliedSyncService.class;
                }
            }

            return (SyncService)syncService.newInstance();
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to initialize the AppliedRuleJob based on the current ExecutionJob.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    execJob	                DESCRIPTION (Data Type ExecutionJob, Current ExecutionJob enum type)
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void initAppliedRuleJob(ExecutionJob execJob) {
            switch on execJob {
                when PACKAGE_RULE_SYNC {
                    this.syncService.initAppliedRuleJob(this.acqCompanyId, this.pkgId, this.pkgDistributionId, this.execMode);
                }when TEMPLATE_RULE_SYNC {
                    this.initAppliedRuleJob(this.asyncApexJobIds);
                }when PURGE_RULE_SYNC {
                    this.syncService.initAppliedRuleJob(this.pkgDistributionId, this.summaryDocRuleSync, this.packageDocRuleSync, this.originExecJob, this.execMode, this.asyncApexJobIds, this.templateIds);
                }when RULE_APPLIED_SYNC {
                    this.syncService.initAppliedRuleJob(this.pkgDistributionId, this.summaryDocRuleSync, this.packageDocRuleSync, this.originExecJob, this.execMode);
                }
            }                   
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to initialize the AppliedRuleJob based on the size of the asyncApexJobIds.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    asyncApexJobIds	                DESCRIPTION (Data Type Set<Id>, Queueable Async Apex Job Ids, that processed Applied Rules)
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void initAppliedRuleJob(Set<Id> asyncApexJobIds) {
            if(asyncApexJobIds.size() > 0) {
                this.syncService.initAppliedRuleJob(this.acqCompanyId, this.pkgId, this.pkgDistributionId, this.execMode, this.asyncApexJobIds);
            }else {
                this.syncService.initAppliedRuleJob(this.acqCompanyId, this.pkgId, this.pkgDistributionId, this.execMode);
            }
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to enqueue and execute the AppliedRuleJob to process the Applied Rules.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void execute() {
            this.syncService.executeAppliedRuleJob();
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Interface to initialize AppliedRuleJob implementation with JobParams & JobFinalizer and execute the job.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public interface SyncService {
        void executeAppliedRuleJob();
        void initAppliedRuleJob(Id acqCompanyId, Id pkgId, Id pkgDistributionId, ExecutionMode originExecMode);
        void initAppliedRuleJob(Id acqCompanyId, Id pkgId, Id pkgDistributionId, ExecutionMode originExecMode, Set<Id> asyncApexJobIds);
        void initAppliedRuleJob(Id pkgDistributionId, Boolean summaryDocRuleSync, Boolean packageDocRuleSync, ExecutionJob originExecJob, ExecutionMode originExecMode);
        void initAppliedRuleJob(Id pkgDistributionId, Boolean summaryDocRuleSync, Boolean packageDocRuleSync, ExecutionJob originExecJob, ExecutionMode originExecMode, Set<Id> asyncApexJobIds, List<Id> templateIds);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Abstract class to provide SyncService implementation & common logic for its sub-classes.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public abstract class AppliedRuleSyncService implements SyncService {
        protected AppliedRuleJob appliedRuleJob;

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute the AppliedRuleJob to process Applied Rules.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void executeAppliedRuleJob() {
            MA_DS_AppliedRulesService.execute(this.appliedRuleJob);
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the AppliedRuleSyncService implementation classes, to initialize the AppliedRuleJob.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void initAppliedRuleJob(Id acqCompanyId, Id pkgId, Id pkgDistributionId, ExecutionMode originExecMode) {}

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the AppliedRuleSyncService implementation classes, to initialize the AppliedRuleJob.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void initAppliedRuleJob(Id acqCompanyId, Id pkgId, Id pkgDistributionId, ExecutionMode originExecMode, Set<Id> asyncApexJobIds) {}

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the AppliedRuleSyncService implementation classes, to initialize the AppliedRuleJob.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void initAppliedRuleJob(Id pkgDistributionId, Boolean summaryDocRuleSync, Boolean packageDocRuleSync, ExecutionJob originExecJob, ExecutionMode originExecMode) {}

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the AppliedRuleSyncService implementation classes, to initialize the AppliedRuleJob.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void initAppliedRuleJob(Id pkgDistributionId, Boolean summaryDocRuleSync, Boolean packageDocRuleSync, ExecutionJob originExecJob, ExecutionMode originExecMode, Set<Id> asyncApexJobIds, List<Id> templateIds) {}
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Abstract Queueable implementation class, to be extended by Applied Rule Execution Jobs to process Package & Template Applied Rules.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public abstract class AppliedRuleJob implements System.Queueable {
        protected JobParams jobParams;
        protected JobFinalizer jobFinalizer;
        
        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Default constructor of the AppliedRuleJob abstract class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public AppliedRuleJob() {
            // default constructor : left blank intentionally to allow parameterized constructor to work.
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the AppliedRuleJob abstract class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the AppliedRuleJob type)
        * @param    jobFinalizer	    DESCRIPTION (Data Type JobFinalizer, JobFinalizer instance for the AppliedRuleJob type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public AppliedRuleJob(JobParams jobParams, JobFinalizer jobFinalizer) {
            this(); // invokes default constructor : added for the sole purpose of test coverage
            this.jobParams = jobParams;
            this.jobFinalizer = jobFinalizer;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method of Queueable interface, to be implemented by the AppliedRuleJob implementation classes.
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
    public abstract class AppliedRuleJobFinalizer implements JobFinalizer {
        protected JobParams jobParams;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Default constructor of the AppliedRuleJobFinalizer abstract class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public AppliedRuleJobFinalizer() {
            // default constructor : left blank intentionally to allow parameterized constructor to work.
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the AppliedRuleJobFinalizer abstract class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the AppliedRuleJobFinalizer type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public AppliedRuleJobFinalizer(JobParams jobParams) {
            this(); // invokes default constructor : added for the sole purpose of test coverage
            this.jobParams = jobParams;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the AppliedRuleJobFinalizer implementation classes, to perform action after final job completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        protected abstract void handleFinalJobCompletion();
        
        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the AppliedRuleJobFinalizer implementation classes, to perform action after single job completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        protected abstract void handleSingleJobCompletion();
    }
}