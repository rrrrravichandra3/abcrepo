/**
 * W-13465459
 * Abstract Class to asynchronously inititate the process to Deliver Packages for selected Package Distribution records.
 * The ExecutionJob Enum Type will determine which DeliveryService implementation to be initiated to execute the PackageDeliveryJob.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         24/05/2023      Chakshu Malhotra        W-13465459 - Adds logic to asynchronously initiate processing of Packages Delivery within a Queueable job.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_PackageDeliveryService {
    
    public enum ExecutionJob {DELIVER_ACQ_CONTACTS}
    public enum ExecutionOrigin {DELIVER_ALL, DELIVER_SELECTED, SCHEDULED_DELIVERY, SINGLE_CONTACT_DELIVERY}

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Marker interface to serialize singleton instances of JobParams implementations and use across Async Jobs of type PackageDeliveryJob.
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
    * Method to enqueue the PackageDeliveryJob (Queueable Job) if within the Queueable Jobs Governor Limits.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void execute(PackageDeliveryJob packageDeliveryJob) {
        MA_DS_QueueableUtil.execute(packageDeliveryJob);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Strategy class to identify & execute the right implementation of the PackageDeliveryJob based on ExecutionJob Enum Type.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class ExecutionStrategy {
        private ExecutionJob executionJobType;
        private ExecutionOrigin executionOriginType;

        private Id srcRecordId;
        private Id acqCompanyId;
        private Id acqContactId;

        private PackageDeliveryJob asyncJob;
        private DeliveryService deliveryService;

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Package Distribution Ids, used by PackageDeliveryJob to identify the Acquisition Contacts to process them for Package Delivery.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Set<Id> packageDeliveryPDIds {
            get {
                if(packageDeliveryPDIds == null) {
                    packageDeliveryPDIds = new Set<Id>();
                }
                return packageDeliveryPDIds;
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
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the srcRecordId, used by PackageDeliveryJob to set the notification target upon completion of all Package Delivery API callouts.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    srcRecordId	                        DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
        * @return   ExecutionStrategy                   DESCRIPTION (return ExecutionStrategy instance)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setSrcRecordId(Id srcRecordId) {
            this.srcRecordId = srcRecordId;
            return this;
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the acqCompanyId, used by PackageDeliveryJob to identify the Acquisition Contacts related to the Acquisition Company Id.
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
        * Method to set the acqContactId, used by PackageDeliveryJob to initiate the Single Acquisition Contact Package Delivery.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    acqContactId	                    DESCRIPTION (Data Type Id, Acquisition Contact record Id)
        * @return   ExecutionStrategy                   DESCRIPTION (return ExecutionStrategy instance)
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setAcqContactId(Id acqContactId) {
            this.acqContactId = acqContactId;
            return this;
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the packageDeliveryPDIds, used by PackageDeliveryJob to identify the Acquisition Contacts to process them for Package Delivery.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    packageDeliveryPDIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to be processed for Package Delivery)
        * @return   ExecutionStrategy                   DESCRIPTION (return ExecutionStrategy instance)
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setPackageDeliveryPDIds(Set<Id> packageDeliveryPDIds) {
            if(packageDeliveryPDIds != null) {
                this.packageDeliveryPDIds.addAll(packageDeliveryPDIds);
            }
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the executionJobType, used by ExecutionStrategy to enqueue appropriate PackageDeliveryJob.
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
        * Method to set the executionOriginType, used by ExecutionStrategy to enqueue appropriate PackageDeliveryJob.
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
                when DELIVER_ACQ_CONTACTS {
                    deliveryServiceType = MA_DS_AcqContactsPackageDeliveryService.class;
                }
            }
            
            this.deliveryService = (DeliveryService)deliveryServiceType.newInstance();
            return this;
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to initialize the PackageDeliveryJob by the DeliveryService implementation, based on ExecutionJob Enum type.
        * Sets JobParams as well as JobFinalizer on the PackageDeliveryJob.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy initPackageDeliveryJob() {
            switch on this.executionJobType {
                when DELIVER_ACQ_CONTACTS {
                    this.deliveryService.initPackageDeliveryJob(srcRecordId, acqCompanyId, acqContactId, packageDeliveryPDIds, executionOriginType);
                }
            }
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to enqueue and execute the PackageDeliveryJob to process Package Distributions for Package Delivery.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void execute() {
            this.deliveryService.executePackageDeliveryJob();
        }
    }


    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Interface to initialize PackageDeliveryJob implementation with JobParams & JobFinalizer and execute the job.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public interface DeliveryService {
        void executePackageDeliveryJob();
        void initPackageDeliveryJob(Id srcRecordId, Id acqCompanyId, Id acqContactId, Set<Id> packageDeliveryPDIds, ExecutionOrigin executionOriginType);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Abstract class to provide DeliveryService implementation & common logic for its sub-classes.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public abstract class PackageDeliveryService implements DeliveryService {
        protected PackageDeliveryJob packageDeliveryJob;

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute the PackageDeliveryJob to process Package Distributions for Package Delivery.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void executePackageDeliveryJob() {
            MA_DS_PackageDeliveryService.execute(this.packageDeliveryJob);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the PackageDeliveryService implementation classes, to initialize the PackageDeliveryJob.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void initPackageDeliveryJob(Id srcRecordId, Id acqCompanyId, Id acqContactId, Set<Id> packageDeliveryPDIds, ExecutionOrigin executionOriginType) {}
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Abstract Queueable implementation class, to be extended by Package Delivery Execution Jobs to process Package Distributions for Package Delivery.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public abstract class PackageDeliveryJob implements System.Queueable, Database.AllowsCallouts {
        protected JobParams jobParams;
        protected JobFinalizer jobFinalizer;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Default constructor of the PackageDeliveryJob abstract class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public PackageDeliveryJob() {
            // default constructor : left blank intentionally to allow parameterized constructor to work.
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the PackageDeliveryJob abstract class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the PackageDeliveryJob type)
        * @param    jobFinalizer	    DESCRIPTION (Data Type JobFinalizer, JobFinalizer instance for the PackageDeliveryJob type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public PackageDeliveryJob(JobParams jobParams, JobFinalizer jobFinalizer) {
            this.jobParams = jobParams;
            this.jobFinalizer = jobFinalizer;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method of Queueable interface, to be implemented by the PackageDeliveryJob implementation classes.
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
    public abstract class PackageDeliveryJobFinalizer implements JobFinalizer {
        protected JobParams jobParams;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Default constructor of the PackageDeliveryJobFinalizer abstract class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public PackageDeliveryJobFinalizer() {
            // default constructor : left blank intentionally to allow parameterized constructor to work.
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the PackageDeliveryJobFinalizer abstract class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the PackageDeliveryJobFinalizer type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public PackageDeliveryJobFinalizer(JobParams jobParams) {
            this.jobParams = jobParams;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the PackageDeliveryJobFinalizer implementation classes, to perform action after final job completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void handleFinalJobCompletion() {}
        
        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the PackageDeliveryJobFinalizer implementation classes, to perform action after single job completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void handleSingleJobCompletion() {}
    }
}