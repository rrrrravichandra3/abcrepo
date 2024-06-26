/**
 * W-13465433
 * Class to hold MA_DS_FailureHandlerService.FailureHandlerJob implementation to identify & process Applied Rules to denote "Need To Generate", during Package Prep process.
 * Holds MA_DS_FailureHandlerService.FailureHandlerJobFinalizer implementation to provide actions for single / final job completion.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         23/05/2023      Chakshu Malhotra        W-13465433 - Adds logic to identify & process Applied Rules to denote "Need To Generate".
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_PackagePrepFailureHandlerService extends MA_DS_FailureHandlerService.FailureHandlerService {
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize the PrepFailureHandler Job with JobParams & JobFinalizer to identify & process Applied Rules to denote "Need To Generate".
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionIds	    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @param    commonIds	            DESCRIPTION (Data Type Set<String>, Set of Package Common Ids)
    * @param    templateIds	            DESCRIPTION (Data Type Set<String>, Set of Template Ids)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void initFailureHandlerJob(Set<Id> pkgDistributionIds, Set<String> commonIds, Set<String> templateIds) {
        MA_DS_FailureHandlerWrapper.PackagePrepFailureParams jobParams = new MA_DS_FailureHandlerWrapper.PackagePrepFailureParams();
        jobParams.commonIds = commonIds;
        jobParams.templateIds = templateIds;
        jobParams.pkgDistributionIds = pkgDistributionIds;
        this.failureHandlerJob = new PrepFailureHandler(jobParams, new PrepFailureHandlerFinalizer(jobParams));
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to identify & process Applied Rules to denote "Need To Generate", during Package Prep process.
    * Recursively self-chains itself to process all eligible Applied Rule records based on the Set of Package Common Ids. 
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class PrepFailureHandler extends MA_DS_FailureHandlerService.FailureHandlerJob {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the PrepFailureHandler class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the FailureHandlerJob type)
        * @param    jobFinalizer	    DESCRIPTION (Data Type JobFinalizer, JobFinalizer instance for the FailureHandlerJob type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public PrepFailureHandler(MA_DS_FailureHandlerService.JobParams jobParams, MA_DS_FailureHandlerService.JobFinalizer jobFinalizer) {
            super(jobParams, jobFinalizer);
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to identify & process Applied Rules to denote "Need To Generate".
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void execute(QueueableContext qContext) {
            //System.debug('PrepFailureHandler jobParams : ' + JSON.serialize(jobParams));
            MA_DS_FailureHandlerWrapper.PackagePrepFailureParams jobParams = (MA_DS_FailureHandlerWrapper.PackagePrepFailureParams)this.jobParams;
            Integer currentQuerySize = 0;

            for(Integer currentQueryCount=1; currentQueryCount <= jobParams.maxQueryCount; currentQueryCount++) {
                List<MA_DS_Applied_Rule__c> appliedRules = MA_DS_FailureHandlerUtility.getAppliedRules(false, jobParams.commonIds, jobParams.pkgDistributionIds, null, jobParams.templateIds, null, jobParams.lastRecordId, jobParams.querySizeLimit);
                currentQuerySize = appliedRules.size();
                
                MA_DS_FailureHandlerUtility.updateAppliedRules(false, appliedRules, MA_DS_FailureHandlerService.Failure.PACKAGE_PREP);

                jobParams.lastRecordId = (currentQuerySize > 0) ? appliedRules[appliedRules.size() - 1].Id : jobParams.lastRecordId;

                if(currentQuerySize < jobParams.querySizeLimit) {
                    break;
                }
            }

            this.invokeJobFinalizer(currentQuerySize, jobParams.querySizeLimit);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to invoke JobFinalizer action to handle Single Job completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    currentQuerySize    DESCRIPTION (Data type Integer, Last Query Size of the Applied Rules retrieved based on the Set of Package Common Ids)
        * @param    querySizeLimit      DESCRIPTION (Data type Integer, Maximum number of records allowed to fetch in a single query for the PrepFailureHandler job)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
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
    * Sub-class of MA_DS_FailureHandlerService.FailureHandlerJobFinalizer to provide JobFinalizer implementation for PrepFailureHandler Queueable job.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class PrepFailureHandlerFinalizer extends MA_DS_FailureHandlerService.FailureHandlerJobFinalizer {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the PrepFailureHandlerFinalizer class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the FailureHandlerJobFinalizer type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public PrepFailureHandlerFinalizer(MA_DS_FailureHandlerService.JobParams jobParams) {
            super(jobParams);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on each single job completion, initializes PrepFailureHandler job & enqueues it.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion() {
            PrepFailureHandler failureHandlerJob = new PrepFailureHandler(this.jobParams, new PrepFailureHandlerFinalizer(this.jobParams));
            MA_DS_FailureHandlerService.execute(failureHandlerJob);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on final job completion, updates Package Distribution records - clears "Package Common Ids".
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleFinalJobCompletion() {
            MA_DS_FailureHandlerWrapper.PackagePrepFailureParams jobParams = (MA_DS_FailureHandlerWrapper.PackagePrepFailureParams)this.jobParams;
            MA_DS_FailureHandlerUtility.updatePackageDistributions(false, null, jobParams.pkgDistributionIds, MA_DS_FailureHandlerService.Failure.PACKAGE_PREP);
        }
    }
}