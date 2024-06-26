/**
* W-14202702
* Utility class to help enqueue / execute Queueable jobs for various Docusign CLM lifecycle processes.
* Checks Governor Limits associated with Queueable Jobs and Maximum Stack Depth before enqueuing a job.
* 
* Version      Date            Author                  Description
* --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         22/11/2023      Chakshu Malhotra        W-14202702 - Adds logic to handle execution of Queueable jobs for various Docusign CLM lifecycle processes.
* --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public abstract without sharing class MA_DS_QueueableUtil {
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to enqueue the Queueable Job if within the Queueable Job Governor Limits & Maximum Stack Depth hasn't reached.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param        queueableJob            DESCRIPTION (Data Type Queueable, Queueable Job to be enqueued)
    * @return       void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void execute(Queueable queueableJob) {
        if(isQueueable()) {
            System.enqueueJob(queueableJob);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check if Queueable Job Governor Limits are not breached and Maximum Stack Depth hasn't reached.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return       Boolean                 DESCRIPTION (return True if Queueable job can be enqueued)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isQueueable() {
        return (Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) && !(Test.isRunningTest() && System.isQueueable());
    }
}