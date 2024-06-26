/**
 * W-12578116, W-12578130 & W-13465433
 * Abstract Class to asynchronously initiate the processing of Applied Rules to denote "Need To Generate" / "Need To Deliver" to handle Failure Type.
 * The Failure Enum Type will determine what appropriate action need to be taken to handle the failure.
 * 
 * SUMMARY_PREP     : Job sets the "Need To Generate" field on Manager Summary IUT type Applied Rules for all Acquisition Contacts matching the Package Distribution Ids.
 * SUMMARY_AUDIT    : Job sets the "Need To Generate" field on Manager Summary IUT type Applied Rules for all Acquisition Contacts matching the Common Ids / Offer Communicator Ids.
 * SUMMARY_DELIVERY : Job sets the "Need To Deliver" field on Manager Summary IUT type Applied Rules for all Acquisition Contacts matching the "Failed Offer Communicator Ids".
 * PACKAGE_PREP     : Job sets the "Need To Generate" field on Package Document IUT type Applied Rules for all Acquisition Contacts matching the Package Distribution Ids.
 * PACKAGE_AUDIT    : Job sets the "Need To Generate" field on Package Document IUT type Applied Rules for all Acquisition Contacts matching the Common Ids / Template Ids / Acquisition Contact Ids / Applied Rule Ids.
 * PACKAGE_DELIVERY : Job sets the "Need To Deliver" field on Package Document IUT type Applied Rules for all Acquisition Contacts matching the "Failed Package Contact Ids".
 * 
 * Version      Date            Author                  Description
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         30/03/2023      Chakshu Malhotra        W-12578116 - Adds logic to asynchronously initiate processing of Applied Rules to denote "Need To Generate" / "Need To Deliver".
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_FailureHandlerService {
    
    public enum Failure {SUMMARY_PREP, SUMMARY_AUDIT, SUMMARY_DELIVERY, PACKAGE_PREP, PACKAGE_AUDIT, PACKAGE_DELIVERY}

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Marker interface to serialize singleton instances of JobParams implementations and use across Async Jobs of type FailureHandlerJob.
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
    * Method to enqueue the FailureHandlerJob (Queueable Job) if within the Queueable Jobs Governor Limits.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void execute(FailureHandlerJob failureHandlerJob) {
        MA_DS_QueueableUtil.execute(failureHandlerJob);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Strategy class to identify & execute the right implementation of the FailureHandlerJob based on Failure Enum Type.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class ExecutionStrategy {
        private Failure failureType;

        private Set<String> commonIds;
        public Set<Id> pkgDistributionIds;

        private Set<String> templateIds;
        private Set<String> acqContactIds;
        private Set<String> appliedRuleIds;

        private FailureHandlerJob asyncJob;
        private HandlerService handlerService;

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
        * Method to set the commonIds, used by FailureHandlerJob to identify Applied Rules to denote "Need To Generate" / "Need To Deliver".
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    commonIds	            DESCRIPTION (Data Type Set<String>, Set of Manager Summary / Package Common Id on Acquisition Contact records)
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setCommonIds(Set<String> commonIds) {
            this.commonIds = commonIds;
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the pkgDistributionIds, used by FailureHandlerJob to identify Applied Rules to denote "Need To Generate" / "Need To Deliver".
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    pkgDistributionIds	    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setPkgDistributionIds(Set<Id> pkgDistributionIds) {
            this.pkgDistributionIds = pkgDistributionIds;
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the templateIds, used by FailureHandlerJob to identify Applied Rules to denote "Need To Generate" / "Need To Deliver".
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    templateIds	                        DESCRIPTION (Data Type Set<String>, Set of Template Ids)
        * @return   ExecutionStrategy                   DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setTemplateIds(Set<String> templateIds) {
            this.templateIds = templateIds;
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the acqContactIds, used by FailureHandlerJob to identify Applied Rules to denote "Need To Generate" / "Need To Deliver".
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    acqContactIds	                    DESCRIPTION (Data Type Set<String>, Set of Offer Communicator Ids / Package Acquisition Contact Ids)
        * @return   ExecutionStrategy                   DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setAcqContactIds(Set<String> acqContactIds) {
            this.acqContactIds = acqContactIds;
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the appliedRuleIds, used by FailureHandlerJob to identify Applied Rules to denote "Need To Generate" / "Need To Deliver".
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    appliedRuleIds	                    DESCRIPTION (Data Type Set<String>, Set of Applied Rule Ids)
        * @return   ExecutionStrategy                   DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setAppliedRuleIds(Set<String> appliedRuleIds) {
            this.appliedRuleIds = appliedRuleIds;
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the failureType, used by ExecutionStrategy to enqueue appropriate FailureHandlerJob.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    failureType	                DESCRIPTION (Data Type Failure, Enum Type Failure)
        * @return   ExecutionStrategy           DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setFailureType(Failure failureType) {
            this.failureType = failureType;
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to initialize the HandlerService implementation based on Failure Enum type.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy initHandlerService() {
            Type handlerServiceType;

            switch on this.failureType {
                when SUMMARY_PREP {
                    handlerServiceType = MA_DS_SummaryPrepFailureHandlerService.class;
                }when SUMMARY_AUDIT {
                    handlerServiceType = MA_DS_SummaryAuditFailureHandlerService.class;
                }when SUMMARY_DELIVERY {
                    handlerServiceType = MA_DS_SummaryDelvryFailureHandlerService.class;
                }when PACKAGE_PREP {
                    handlerServiceType = MA_DS_PackagePrepFailureHandlerService.class;
                }when PACKAGE_AUDIT {
                    handlerServiceType = MA_DS_PackageAuditFailureHandlerService.class;
                }when PACKAGE_DELIVERY {
                    handlerServiceType = MA_DS_PackageDelvryFailureHandlerService.class;
                }
            }
            
            this.handlerService = (HandlerService)handlerServiceType.newInstance();
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to initialize the FailureHandlerJob by the HandlerService implementation, based on Failure Enum type.
        * Sets JobParams as well as JobFinalizer on the FailureHandlerJob.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy initFailureHandlerJob() {
            switch on this.failureType {
                when SUMMARY_PREP {
                    this.handlerService.initFailureHandlerJob(this.commonIds);
                }when SUMMARY_AUDIT {
                    this.handlerService.initFailureHandlerJob(this.commonIds, this.acqContactIds);
                }when SUMMARY_DELIVERY {
                    this.handlerService.initFailureHandlerJob(this.pkgDistributionIds, this.acqContactIds);
                }when PACKAGE_PREP {
                    this.handlerService.initFailureHandlerJob(this.pkgDistributionIds, this.commonIds, this.templateIds);
                }when PACKAGE_AUDIT {
                    this.handlerService.initFailureHandlerJob(this.commonIds, this.acqContactIds, this.templateIds, this.appliedRuleIds);
                }when PACKAGE_DELIVERY {
                    this.handlerService.initFailureHandlerJob(this.pkgDistributionIds, this.acqContactIds);
                }
            }
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to enqueue and execute the FailureHandlerJob to identify & process Applied Rules to denote "Need To Generate" / "Need To Deliver".
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void execute() {
            this.handlerService.executeFailureHandlerJob();
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Interface to initialize FailureHandlerJob implementation with JobParams & JobFinalizer and execute the job.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public interface HandlerService {
        void executeFailureHandlerJob();
        void initFailureHandlerJob(Set<String> commonIds);
        void initFailureHandlerJob(Set<String> commonIds, Set<String> acqContactIds);
        void initFailureHandlerJob(Set<Id> pkgDistributionIds, Set<String> acqContactIds);
        void initFailureHandlerJob(Set<Id> pkgDistributionIds, Set<String> commonIds, Set<String> templateIds);
        void initFailureHandlerJob(Set<String> commonIds, Set<String> acqContactIds, Set<String> templateIds, Set<String> appliedRuleIds);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Abstract class to provide HandlerService implementation & common logic for its sub-classes.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public abstract class FailureHandlerService implements HandlerService {
        protected FailureHandlerJob failureHandlerJob;

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute the FailureHandlerJob to identify & process Applied Rules to denote "Need To Generate" / "Need To Deliver".
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void executeFailureHandlerJob() {
            MA_DS_FailureHandlerService.execute(this.failureHandlerJob);
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the FailureHandlerService implementation classes, to initialize the FailureHandlerJob.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void initFailureHandlerJob(Set<String> commonIds) {}

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the FailureHandlerService implementation classes, to initialize the FailureHandlerJob.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void initFailureHandlerJob(Set<String> commonIds, Set<String> failedIds) {}

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the FailureHandlerService implementation classes, to initialize the FailureHandlerJob.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void initFailureHandlerJob(Set<Id> pkgDistributionIds, Set<String> acqContactIds) {}

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the FailureHandlerService implementation classes, to initialize the FailureHandlerJob.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void initFailureHandlerJob(Set<Id> pkgDistributionIds, Set<String> commonIds, Set<String> templateIds) {}

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the FailureHandlerService implementation classes, to initialize the FailureHandlerJob.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void initFailureHandlerJob(Set<String> commonIds, Set<String> acqContactIds, Set<String> templateIds, Set<String> appliedRuleIds) {}
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Abstract Queueable implementation class, to be extended by Failure Handler Execution Jobs to identify & process Applied Rules to denote "Need To Generate" / "Need To Deliver".
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public abstract class FailureHandlerJob implements System.Queueable {
        protected JobParams jobParams;
        protected JobFinalizer jobFinalizer;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Default constructor of the FailureHandlerJob abstract class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public FailureHandlerJob() {
            // default constructor : left blank intentionally to allow parameterized constructor to work.
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the FailureHandlerJob abstract class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the FailureHandlerJob type)
        * @param    jobFinalizer	    DESCRIPTION (Data Type JobFinalizer, JobFinalizer instance for the FailureHandlerJob type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public FailureHandlerJob(JobParams jobParams, JobFinalizer jobFinalizer) {
            this.jobParams = jobParams;
            this.jobFinalizer = jobFinalizer;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method of Queueable interface, to be implemented by the FailureHandlerJob implementation classes.
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
    public abstract class FailureHandlerJobFinalizer implements JobFinalizer {
        protected JobParams jobParams;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Default constructor of the FailureHandlerJobFinalizer abstract class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public FailureHandlerJobFinalizer() {
            // default constructor : left blank intentionally to allow parameterized constructor to work.
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the FailureHandlerJobFinalizer abstract class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the FailureHandlerJobFinalizer type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public FailureHandlerJobFinalizer(JobParams jobParams) {
            this.jobParams = jobParams;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the FailureHandlerJobFinalizer implementation classes, to perform action after final job completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void handleFinalJobCompletion() {}
        
        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the FailureHandlerJobFinalizer implementation classes, to perform action after single job completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void handleSingleJobCompletion() {}
    }
}