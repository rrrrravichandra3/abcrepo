/**
 * W-13484430 & W-13576017
 * Class to hold MA_DS_PackageStatusHandlerService.PackageStatusHandlerJob implementation to identify & process Applied Rules to set "Need To Generate" & reset "Need To Deliver", for Recalled Package Status update.
 * Holds MA_DS_PackageStatusHandlerService.PackageStatusHandlerJobFinalizer implementation to provide actions for single / final job completion.
 * 
 * Version      Date            Author                  Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         23/06/2023      Chakshu Malhotra        W-13484430 & W-13576017 - Adds logic to identify & process Applied Rules to set "Need To Generate" & reset "Need To Deliver".
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_PackageRecalledHandlerService extends MA_DS_PackageStatusHandlerService.PackageStatusHandlerService {
    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize the RecalledStatusHandler Job with JobParams & JobFinalizer to identify & process Applied Rules to set "Need To Generate" & reset "Need To Deliver".
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionIds	    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void initPackageStatusHandlerJob(Set<Id> pkgDistributionIds) {
        MA_DS_PackageStatusHandlerWrapper.PackageRecalledStatusParams jobParams = new MA_DS_PackageStatusHandlerWrapper.PackageRecalledStatusParams();
        jobParams.pkgDistributionIds = pkgDistributionIds;
        this.packageStatusHandlerJob = new RecalledStatusHandler(jobParams, new RecalledStatusHandlerFinalizer(jobParams));
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to identify & process Applied Rules to set "Need To Generate" & reset "Need To Deliver", for Recalled Package Status update.
    * Recursively self-chains itself to process all eligible Applied Rule records based on the Set of Package Distribution Ids. 
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class RecalledStatusHandler extends MA_DS_PackageStatusHandlerService.PackageStatusHandlerJob {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the RecalledStatusHandler class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the PackageStatusHandlerJob type)
        * @param    jobFinalizer	    DESCRIPTION (Data Type JobFinalizer, JobFinalizer instance for the PackageStatusHandlerJob type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public RecalledStatusHandler(MA_DS_PackageStatusHandlerService.JobParams jobParams, MA_DS_PackageStatusHandlerService.JobFinalizer jobFinalizer) {
            super(jobParams, jobFinalizer);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to identify & process Applied Rules to set "Need To Generate" & reset "Need To Deliver".
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void execute(QueueableContext qContext) {
            //System.debug('RecalledStatusHandler jobParams : ' + JSON.serialize(jobParams));
            MA_DS_PackageStatusHandlerWrapper.PackageRecalledStatusParams jobParams = (MA_DS_PackageStatusHandlerWrapper.PackageRecalledStatusParams)this.jobParams;
            Integer currentQuerySize = 0;

            for(Integer currentQueryCount=1; currentQueryCount <= jobParams.maxQueryCount; currentQueryCount++) {
                List<MA_DS_Applied_Rule__c> appliedRules = MA_DS_PackageStatusHandlerUtility.getAppliedRules(jobParams.pkgDistributionIds, jobParams.lastRecordId, jobParams.querySizeLimit);
                currentQuerySize = appliedRules.size();
                
                MA_DS_PackageStatusHandlerUtility.updateAppliedRules(appliedRules, MA_DS_PackageStatusHandlerService.PackageStatus.RECALLED);

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
        * @param    currentQuerySize    DESCRIPTION (Data type Integer, Last Query Size of the Applied Rules retrieved based on the Set of Package Distribution Ids)
        * @param    querySizeLimit      DESCRIPTION (Data type Integer, Maximum number of records allowed to fetch in a single query for the RecalledStatusHandler job)
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
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of MA_DS_PackageStatusHandlerService.PackageStatusHandlerJobFinalizer to provide JobFinalizer implementation for RecalledStatusHandler Queueable job.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class RecalledStatusHandlerFinalizer extends MA_DS_PackageStatusHandlerService.PackageStatusHandlerJobFinalizer {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the RecalledStatusHandlerFinalizer class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the PackageStatusHandlerJobFinalizer type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public RecalledStatusHandlerFinalizer(MA_DS_PackageStatusHandlerService.JobParams jobParams) {
            super(jobParams);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on each single job completion, initializes RecalledStatusHandler job & enqueues it.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion() {
            RecalledStatusHandler recalledStatusHandler = new RecalledStatusHandler(this.jobParams, new RecalledStatusHandlerFinalizer(this.jobParams));
            MA_DS_PackageStatusHandlerService.execute(recalledStatusHandler);
        }
    }
}