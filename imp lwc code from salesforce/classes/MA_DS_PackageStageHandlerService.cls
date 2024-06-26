/**
 * W-12218399
 * Abstract Class to asynchronously initiate and handle the post-processing logic of Package Stage update on Acquisition Contact.
 * The HandlerAction Enum Type will determine what appropriate action need to be taken to handle the package stage update.
 * 
 * GET_CLIENT_IP_ADDRESS      : Job calls out DocuSign eSignature API using the Envelope Id, to fetch the Client IP Address of the Signer.
 * 
 * Version      Date            Author                  Description
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         12/11/2023      Chakshu Malhotra        W-12218399 - Adds logic to asynchronously initiate and handle the post-processing logic of Package Stage update on Acquisition Contact.
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_PackageStageHandlerService {
    
    public enum HandlerAction {GET_CLIENT_IP_ADDRESS}

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Marker interface to serialize singleton instances of JobParams implementations and use across Async Jobs of type MA_DS_PackageStageHandlerService.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
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
    * Method to enqueue the PackageStageHandlerJob (Queueable Job) if within the Queueable Jobs Governor Limits.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void execute(PackageStageHandlerJob packageStageHandlerJob) {
        MA_DS_QueueableUtil.execute(packageStageHandlerJob);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Strategy class to identify & execute the right implementation of the PackageStageHandlerJob based on HandlerAction Enum Type.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class ExecutionStrategy {
        private HandlerAction handlerActionType;

        private Map<Id, String> envelopeIdsMap;

        private PackageStageHandlerJob asyncJob;
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
        * Method to set the envelopeIdsMap, used by PackageStageHandlerJob to fetch Client IP Address of the Signer via API callout to DocuSign eSignature.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    envelopeIdsMap	        DESCRIPTION (Data Type Map<Id, String>, Map of Acquisition Contact Id to the Envelope Id)
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setEnvelopeIdsMap(Map<Id, String> envelopeIdsMap) {
            this.envelopeIdsMap = envelopeIdsMap;
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the handlerActionType, used by ExecutionStrategy to enqueue appropriate PackageStageHandlerJob.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    handlerActionType	        DESCRIPTION (Data Type HandlerAction, Enum Type HandlerAction)
        * @return   ExecutionStrategy           DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy setHandlerActionType(HandlerAction handlerActionType) {
            this.handlerActionType = handlerActionType;
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to initialize the HandlerService implementation based on HandlerAction Enum type.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy initHandlerService() {
            Type handlerServiceType;

            switch on this.handlerActionType {
                when GET_CLIENT_IP_ADDRESS {
                    handlerServiceType = MA_DS_GetClientIPAddressHandlerService.class;
                }
            }
            
            this.handlerService = (HandlerService)handlerServiceType.newInstance();
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to initialize the PackageStageHandlerJob by the HandlerService implementation, based on HandlerAction Enum type.
        * Sets JobParams as well as JobFinalizer on the PackageStageHandlerJob.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   ExecutionStrategy       DESCRIPTION (return ExecutionStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public ExecutionStrategy initPackageStageHandlerJob() {
            switch on this.handlerActionType {
                when GET_CLIENT_IP_ADDRESS {
                    this.handlerService.initPackageStageHandlerJob(this.envelopeIdsMap);
                }
            }
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to enqueue and execute the PackageStageHandlerJob to handle the post-processing logic of Package Stage update on Acquisition Contact.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void execute() {
            this.handlerService.executePackageStageHandlerJob();
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Interface to initialize PackageStageHandlerJob implementation with JobParams & JobFinalizer and execute the job.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public interface HandlerService {
        void executePackageStageHandlerJob();
        void initPackageStageHandlerJob(Map<Id, String> envelopeIdsMap);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Abstract class to provide HandlerService implementation & common logic for its sub-classes.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public abstract class PackageStageHandlerService implements HandlerService {
        protected PackageStageHandlerJob packageStageHandlerJob;

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute the PackageStageHandlerJob to handle the post-processing logic of Package Stage update on Acquisition Contact.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void executePackageStageHandlerJob() {
            MA_DS_PackageStageHandlerService.execute(this.packageStageHandlerJob);
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the PackageStageHandlerService implementation classes, to initialize the PackageStageHandlerJob.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void initPackageStageHandlerJob(Map<Id, String> envelopeIdsMap) {}
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Abstract Queueable implementation class, to be extended by Package Stage Handler Execution Jobs to handle the post-processing logic of Package Stage update on Acquisition Contact.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public abstract class PackageStageHandlerJob implements System.Queueable, Database.AllowsCallouts {
        protected JobParams jobParams;
        protected JobFinalizer jobFinalizer;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Default constructor of the PackageStageHandlerJob abstract class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public PackageStageHandlerJob() {
            // default constructor : left blank intentionally to allow parameterized constructor to work.
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the PackageStageHandlerJob abstract class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the PackageStageHandlerJob type)
        * @param    jobFinalizer	    DESCRIPTION (Data Type JobFinalizer, JobFinalizer instance for the PackageStageHandlerJob type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public PackageStageHandlerJob(JobParams jobParams, JobFinalizer jobFinalizer) {
            this(); // invokes default constructor : added for the sole purpose of test coverage
            this.jobParams = jobParams;
            this.jobFinalizer = jobFinalizer;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method of Queueable interface, to be implemented by the PackageStageHandlerJob implementation classes.
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
    public abstract class PackageStageHandlerJobFinalizer implements JobFinalizer {
        protected JobParams jobParams;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Default constructor of the PackageStageHandlerJobFinalizer abstract class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public PackageStageHandlerJobFinalizer() {
            // default constructor : left blank intentionally to allow parameterized constructor to work.
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the PackageStageHandlerJobFinalizer abstract class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the PackageStageHandlerJobFinalizer type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public PackageStageHandlerJobFinalizer(JobParams jobParams) {
            this(); // invokes default constructor : added for the sole purpose of test coverage
            this.jobParams = jobParams;
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the PackageStageHandlerJobFinalizer implementation classes, to perform action after final job completion.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void handleFinalJobCompletion() {}
        
        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the PackageStageHandlerJobFinalizer implementation classes, to perform action after single job completion.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual void handleSingleJobCompletion() {}
    }
}