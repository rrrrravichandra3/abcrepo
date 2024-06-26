/**
 * W-13465433
 * Class to hold MA_DS_FailureHandlerService.FailureHandlerJob implementation to identify & process Applied Rules to denote "Need To Generate", during Summary Audit process.
 * Holds MA_DS_FailureHandlerService.FailureHandlerJobFinalizer implementation to provide actions for single / final job completion.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         23/05/2023      Chakshu Malhotra        W-13465433 - Adds logic to identify & process Applied Rules to denote "Need To Generate".
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_SummaryAuditFailureHandlerService extends MA_DS_FailureHandlerService.FailureHandlerService {
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize the PrepFailureHandler Job with JobParams & JobFinalizer to identify & process Applied Rules to denote "Need To Generate".
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    commonIds	                        DESCRIPTION (Data Type Set<String>, Set of Manager Summary Common Ids)
    * @param    offerCommunicatorIds	            DESCRIPTION (Data Type Set<String>, Set of Offer Communicator Ids)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void initFailureHandlerJob(Set<String> commonIds, Set<String> offerCommunicatorIds) {
        MA_DS_FailureHandlerWrapper.SummaryAuditFailureParams jobParams = new MA_DS_FailureHandlerWrapper.SummaryAuditFailureParams();
        jobParams.commonIds = commonIds;
        jobParams.offerCommunicatorIds = offerCommunicatorIds;
        this.failureHandlerJob = new AuditFailureHandler(jobParams, new AuditFailureHandlerFinalizer(jobParams));
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to identify & process Applied Rules to denote "Need To Generate", during Summary Audit process.
    * Recursively self-chains itself to process all eligible Applied Rule records based on the Set of Manager Summary Common Ids / Offer Communicator Ids. 
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class AuditFailureHandler extends MA_DS_FailureHandlerService.FailureHandlerJob {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the AuditFailureHandler class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the FailureHandlerJob type)
        * @param    jobFinalizer	    DESCRIPTION (Data Type JobFinalizer, JobFinalizer instance for the FailureHandlerJob type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public AuditFailureHandler(MA_DS_FailureHandlerService.JobParams jobParams, MA_DS_FailureHandlerService.JobFinalizer jobFinalizer) {
            super(jobParams, jobFinalizer);
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to identify & process Applied Rules to denote "Need To Generate".
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void execute(QueueableContext qContext) {
            //System.debug('AuditFailureHandler jobParams : ' + JSON.serialize(jobParams));
            MA_DS_FailureHandlerWrapper.SummaryAuditFailureParams jobParams = (MA_DS_FailureHandlerWrapper.SummaryAuditFailureParams)this.jobParams;
            Integer currentQuerySize = 0;

            for(Integer currentQueryCount=1; currentQueryCount <= jobParams.maxQueryCount; currentQueryCount++) {
                List<MA_DS_Applied_Rule__c> appliedRules = MA_DS_FailureHandlerUtility.getAppliedRules(true, jobParams.commonIds, null, jobParams.offerCommunicatorIds, null, null, jobParams.lastRecordId, jobParams.querySizeLimit);
                currentQuerySize = appliedRules.size();
                
                MA_DS_FailureHandlerUtility.updateAppliedRules(true, appliedRules, MA_DS_FailureHandlerService.Failure.SUMMARY_AUDIT);

                jobParams.lastRecordId = (currentQuerySize > 0) ? appliedRules[appliedRules.size() - 1].Id : jobParams.lastRecordId;

                if(currentQuerySize < jobParams.querySizeLimit) {
                    break;
                }
            }

            this.invokeJobFinalizer(currentQuerySize, jobParams.querySizeLimit);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to invoke JobFinalizer action to handle Single Job completion.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    currentQuerySize    DESCRIPTION (Data type Integer, Last Query Size of the Applied Rules retrieved based on the Set of Manager Summary Common Ids / Offer Communicator Ids)
        * @param    querySizeLimit      DESCRIPTION (Data type Integer, Maximum number of records allowed to fetch in a single query for the AuditFailureHandler job)
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void invokeJobFinalizer(Integer currentQuerySize, Integer querySizeLimit) {
            if(currentQuerySize < querySizeLimit) {
                this.jobFinalizer.handleFinalJobCompletion();
            }else {
                this.jobFinalizer.handleSingleJobCompletion();
            }
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of MA_DS_FailureHandlerService.FailureHandlerJobFinalizer to provide JobFinalizer implementation for AuditFailureHandler Queueable job.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class AuditFailureHandlerFinalizer extends MA_DS_FailureHandlerService.FailureHandlerJobFinalizer {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the AuditFailureHandlerFinalizer class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the FailureHandlerJobFinalizer type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public AuditFailureHandlerFinalizer(MA_DS_FailureHandlerService.JobParams jobParams) {
            super(jobParams);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on each single job completion, initializes AuditFailureHandler job & enqueues it.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion() {
            AuditFailureHandler failureHandlerJob = new AuditFailureHandler(this.jobParams, new AuditFailureHandlerFinalizer(this.jobParams));
            MA_DS_FailureHandlerService.execute(failureHandlerJob);
        }
    }
}