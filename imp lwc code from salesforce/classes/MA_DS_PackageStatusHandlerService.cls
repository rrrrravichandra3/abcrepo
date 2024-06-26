/**
 * W-13484430 & W-13576017
 * Abstract Class to asynchronously initiate and handle the post-processing logic of Package Distribution Status update.
 * The PackageStatus Enum Type will determine what appropriate action need to be taken to handle the status update.
 * 
 * RECALLED         : Job sets the "Need To Generate" & resets "Need To Deliver" fields on Package Document IUT type Applied Rules for all Acquisition Contacts matching the Package Distribution Ids.
 * 
 * Version      Date            Author                  Description
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         23/06/2023      Chakshu Malhotra        W-13484430 & W-13576017 - Adds logic to asynchronously initiate and handle the post-processing logic of Package Distribution Status update.
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_PackageStatusHandlerService {
    
    public enum PackageStatus {RECALLED}

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Marker interface to serialize singleton instances of JobParams implementations and use across Async Jobs of type PackageStatusHandlerJob.
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
    * Method to enqueue the PackageStatusHandlerJob (Queueable Job) if within the Queueable Jobs Governor Limits.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void execute(PackageStatusHandlerJob packageStatusHandlerJob) {
        MA_DS_QueueableUtil.execute(packageStatusHandlerJob);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Strategy class to identify & execute the right implementation of the PackageStatusHandlerJob based on PackageStatus Enum Type.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class ExecutionStrategy {
        private PackageStatus packageStatusType;

        public Set<Id> pkgDistributionIds;

        private PackageStatusHandlerJob asyncJob;
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
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the pkgDistributionIds, used by PackageStatusHandlerJob to identify Package Distributions and related records to appropriate action post Status update.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    pkgDistributionIds	    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setPkgDistributionIds(Set<Id> pkgDistributionIds) {
            this.pkgDistributionIds = pkgDistributionIds;
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the packageStatusType, used by ExecutionStrategy to enqueue appropriate PackageStatusHandlerJob.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    packageStatusType	        DESCRIPTION (Data Type PackageStatus, Enum Type PackageStatus)
        * @return   ExecutionStrategy           DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setPackageStatusType(PackageStatus packageStatusType) {
            this.packageStatusType = packageStatusType;
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to initialize the HandlerService implementation based on PackageStatus Enum type.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy initHandlerService() {
            Type handlerServiceType;

            switch on this.packageStatusType {
                when RECALLED {
                    handlerServiceType = MA_DS_PackageRecalledHandlerService.class;
                }
            }
            
            this.handlerService = (HandlerService)handlerServiceType.newInstance();
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to initialize the PackageStatusHandlerJob by the HandlerService implementation, based on PackageStatus Enum type.
        * Sets JobParams as well as JobFinalizer on the PackageStatusHandlerJob.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy initPackageStatusHandlerJob() {
            switch on this.packageStatusType {
                when RECALLED {
                    this.handlerService.initPackageStatusHandlerJob(this.pkgDistributionIds);
                }
            }
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to enqueue and execute the PackageStatusHandlerJob to handle the post-processing logic of Package Distribution Status update.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void execute() {
            this.handlerService.executePackageStatusHandlerJob();
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Interface to initialize PackageStatusHandlerJob implementation with JobParams & JobFinalizer and execute the job.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public interface HandlerService {
        void executePackageStatusHandlerJob();
        void initPackageStatusHandlerJob(Set<Id> pkgDistributionIds);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Abstract class to provide HandlerService implementation & common logic for its sub-classes.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public abstract class PackageStatusHandlerService implements HandlerService {
        protected PackageStatusHandlerJob packageStatusHandlerJob;

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute the PackageStatusHandlerJob to handle the post-processing logic of Package Distribution Status update.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void executePackageStatusHandlerJob() {
            MA_DS_PackageStatusHandlerService.execute(this.packageStatusHandlerJob);
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the PackageStatusHandlerService implementation classes, to initialize the PackageStatusHandlerJob.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void initPackageStatusHandlerJob(Set<Id> pkgDistributionIds) {}
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Abstract Queueable implementation class, to be extended by Package Status Handler Execution Jobs to handle the post-processing logic of Package Distribution Status update.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public abstract class PackageStatusHandlerJob implements System.Queueable {
        protected JobParams jobParams;
        protected JobFinalizer jobFinalizer;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Default constructor of the PackageStatusHandlerJob abstract class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public PackageStatusHandlerJob() {
            // default constructor : left blank intentionally to allow parameterized constructor to work.
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the PackageStatusHandlerJob abstract class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the PackageStatusHandlerJob type)
        * @param    jobFinalizer	    DESCRIPTION (Data Type JobFinalizer, JobFinalizer instance for the PackageStatusHandlerJob type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public PackageStatusHandlerJob(JobParams jobParams, JobFinalizer jobFinalizer) {
            this.jobParams = jobParams;
            this.jobFinalizer = jobFinalizer;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method of Queueable interface, to be implemented by the PackageStatusHandlerJob implementation classes.
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
    public abstract class PackageStatusHandlerJobFinalizer implements JobFinalizer {
        protected JobParams jobParams;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Default constructor of the PackageStatusHandlerJobFinalizer abstract class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public PackageStatusHandlerJobFinalizer() {
            // default constructor : left blank intentionally to allow parameterized constructor to work.
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the PackageStatusHandlerJobFinalizer abstract class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the PackageStatusHandlerJobFinalizer type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public PackageStatusHandlerJobFinalizer(JobParams jobParams) {
            this.jobParams = jobParams;
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the PackageStatusHandlerJobFinalizer implementation classes, to perform action after final job completion.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void handleFinalJobCompletion() {}
        
        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the PackageStatusHandlerJobFinalizer implementation classes, to perform action after single job completion.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void handleSingleJobCompletion() {}
    }
}