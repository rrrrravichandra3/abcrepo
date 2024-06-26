/**
 * W-10702588
 * Base Abstract class to enrol acquisition contacts to acquisition company tasks.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         24/02/2022      Chakshu Malhotra        Executes Queueable chaining logic to enrol or remove (upsert / delete attendees) acquisition contacts to acquisition company tasks.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract class MA_AcqCompanyTaskEnroller {
    
    public enum TASK_EXECUTION_MODE {AUTO_ENROL, SELECT_ENROL}

    private static TaskEnrollerStrategy taskEnrollerStrategy;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Abstract method to execute enrolment logic to enrol acquisition contacts to acquisition company tasks.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    protected abstract void execute(Object statefulInstance);

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to enqueue the queueable job if it's within governor limits.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    asyncJob        DESCRIPTION (Data type Queueable, Queueable job instance)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void enqueueJob(Queueable asyncJob) {
        if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
            System.enqueueJob(asyncJob);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to retrieve singleton instance of TaskEnrollerStrategy type.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   TaskEnrollerStrategy        DESCRIPTION (return instance of TaskEnrollerStrategy)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static TaskEnrollerStrategy getTaskEnrollerStrategy() {
        if(taskEnrollerStrategy == null) {
            taskEnrollerStrategy = new TaskEnrollerStrategy();
        }
        return taskEnrollerStrategy;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Strategy class to idenitfy & execute right implementation of MA_AcqCompanyTaskEnroller. 
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class TaskEnrollerStrategy {
        private TaskEnrollerStrategy() {
            // to enforce singleton design
        }
        
        public void execute(Object enrolStateful, TASK_EXECUTION_MODE executionMode) {
            MA_AcqCompanyTaskEnroller taskEnroller = getTaskEnroller(executionMode);
            taskEnroller.execute(enrolStateful);
        }

        private MA_AcqCompanyTaskEnroller getTaskEnroller(TASK_EXECUTION_MODE executionMode) {
            Type taskEnroller;

            switch on executionMode {
                when AUTO_ENROL {
                    taskEnroller = MA_AcqCompanyTaskAutoEnroller.class;
                }when SELECT_ENROL {
                    taskEnroller = MA_AcqCompanyTaskSelectEnroller.class;
                }
            }

            return (MA_AcqCompanyTaskEnroller)taskEnroller.newInstance();
        }
    }

    public abstract class MA_TaskEnrolJob implements Queueable {
        protected Object jobParams;
        protected JobFinalizer jobFinalizerImpl;

        public MA_TaskEnrolJob() {
            // default constructor : lef blank intentionally to allow parameterized constructor to work.
        }

        public MA_TaskEnrolJob(Object jobParams, JobFinalizer jobFinalizerImpl) {
            this.jobParams = jobParams;
            this.jobFinalizerImpl = jobFinalizerImpl;
        }

        protected abstract void execute(QueueableContext qContext);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Interface to attach final action to queueable execution for each chained job as well as completion of all chained jobs.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public interface JobFinalizer {
        void handleAllJobsCompletion();
        void handleSingleJobCompletion();
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Abstract class to provide JobFinalizer implementation & common logic for its sub-classes.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public abstract class AbstractJobFinalizer implements JobFinalizer {
        protected Object jobParams;

        public AbstractJobFinalizer() {
            // default constructor : lef blank intentionally to allow parameterized constructor to work.
        }

        public AbstractJobFinalizer(Object jobParams) {
            this.jobParams = jobParams;
        }

        protected abstract void handleAllJobsCompletion();
        protected abstract void handleSingleJobCompletion();
    }
}