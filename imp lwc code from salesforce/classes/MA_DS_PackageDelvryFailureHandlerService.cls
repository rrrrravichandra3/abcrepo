/**
 * W-13465433
 * Class to hold MA_DS_FailureHandlerService.FailureHandlerJob implementation to identify & process Applied Rules to denote "Need To Deliver", during Package Delivery process.
 * Holds MA_DS_FailureHandlerService.FailureHandlerJobFinalizer implementation to provide actions for single / final job completion.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         23/05/2023      Chakshu Malhotra        W-13465433 - Adds logic to identify & process Applied Rules to denote "Need To Deliver".
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_PackageDelvryFailureHandlerService extends MA_DS_FailureHandlerService.FailureHandlerService {
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize the PrepFailureHandler Job with JobParams & JobFinalizer to identify & process Applied Rules to denote "Need To Deliver".
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @param    acqContactIds	                DESCRIPTION (Data Type Set<String>, Set of Offer Communicator Ids)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void initFailureHandlerJob(Set<Id> pkgDistributionIds, Set<String> acqContactIds) {
        MA_DS_FailureHandlerWrapper.PackageDeliveryFailureParams jobParams = new MA_DS_FailureHandlerWrapper.PackageDeliveryFailureParams();
        jobParams.acqContactIds = acqContactIds;
        jobParams.pkgDistributionIds = pkgDistributionIds;
        this.failureHandlerJob = new DeliveryFailureHandler(jobParams, new DeliveryFailureHandlerFinalizer(jobParams));
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to identify & process Applied Rules to denote "Need To Deliver", during Package Delivery process.
    * Recursively self-chains itself to process all eligible Applied Rule records based on the Set of Package Distribution Ids / Acquisition Ids.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class DeliveryFailureHandler extends MA_DS_FailureHandlerService.FailureHandlerJob {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the DeliveryFailureHandler class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the FailureHandlerJob type)
        * @param    jobFinalizer	    DESCRIPTION (Data Type JobFinalizer, JobFinalizer instance for the FailureHandlerJob type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public DeliveryFailureHandler(MA_DS_FailureHandlerService.JobParams jobParams, MA_DS_FailureHandlerService.JobFinalizer jobFinalizer) {
            super(jobParams, jobFinalizer);
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to identify & process Applied Rules to denote "Need To Deliver".
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void execute(QueueableContext qContext) {
            //System.debug('DeliveryFailureHandler jobParams : ' + JSON.serialize(jobParams));
            MA_DS_FailureHandlerWrapper.PackageDeliveryFailureParams jobParams = (MA_DS_FailureHandlerWrapper.PackageDeliveryFailureParams)this.jobParams;
            Integer currentQuerySize = 0;

            for(Integer currentQueryCount=1; currentQueryCount <= jobParams.maxQueryCount; currentQueryCount++) {
                List<MA_DS_Applied_Rule__c> appliedRules = MA_DS_FailureHandlerUtility.getAppliedRules(false, null, jobParams.pkgDistributionIds, jobParams.acqContactIds, null, null, jobParams.lastRecordId, jobParams.querySizeLimit);
                currentQuerySize = appliedRules.size();
                
                MA_DS_FailureHandlerUtility.updateAppliedRules(false, appliedRules, MA_DS_FailureHandlerService.Failure.PACKAGE_DELIVERY);

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
        * @param    currentQuerySize    DESCRIPTION (Data type Integer, Last Query Size of the Applied Rules retrieved based on the Set of Package Distribution Ids / Acquisition Ids)
        * @param    querySizeLimit      DESCRIPTION (Data type Integer, Maximum number of records allowed to fetch in a single query for the DeliveryFailureHandler job)
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
    * Sub-class of MA_DS_FailureHandlerService.FailureHandlerJobFinalizer to provide JobFinalizer implementation for DeliveryFailureHandler Queueable job.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class DeliveryFailureHandlerFinalizer extends MA_DS_FailureHandlerService.FailureHandlerJobFinalizer {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the DeliveryFailureHandlerFinalizer class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the FailureHandlerJobFinalizer type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public DeliveryFailureHandlerFinalizer(MA_DS_FailureHandlerService.JobParams jobParams) {
            super(jobParams);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on each single job completion, initializes DeliveryFailureHandler job & enqueues it.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion() {
            DeliveryFailureHandler failureHandlerJob = new DeliveryFailureHandler(this.jobParams, new DeliveryFailureHandlerFinalizer(this.jobParams));
            MA_DS_FailureHandlerService.execute(failureHandlerJob);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on final job completion, updates Package Distribution records - clears "Failed Package Contact Ids".
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleFinalJobCompletion() {
            MA_DS_FailureHandlerWrapper.PackageDeliveryFailureParams jobParams = (MA_DS_FailureHandlerWrapper.PackageDeliveryFailureParams)this.jobParams;
            MA_DS_FailureHandlerUtility.updatePackageDistributions(false, null, jobParams.pkgDistributionIds, MA_DS_FailureHandlerService.Failure.PACKAGE_DELIVERY);
        }
    }
}