/**
 * W-12578130
 * Class to hold MA_DS_ManagerSummaryDeliveryService.SummaryDeliveryJob implementation to process Offer Communicators for Manager Summary Delivery.
 * Holds MA_DS_ManagerSummaryDeliveryService.SummaryDeliveryJobFinalizer implementation to provide actions for single / final job completion.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         22/04/2023      Chakshu Malhotra        W-12578130 - Adds logic to process Offer Communicators for Manager Summary Delivery.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_OfferCommunicatorsDeliveryService extends MA_DS_ManagerSummaryDeliveryService.SummaryDeliveryService {
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize the OfferCommunicatorsDelivery Job with JobParams & JobFinalizer to prepare payload for the Manager Summary Delivery API request.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                        DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    targetUserId	                    DESCRIPTION (Data Type Id, The target User record Id who receives the Notification post all batches of API callouts)
    * @param    acqCompany	                        DESCRIPTION (Data Type String, Acquisition Company record containing Manager Summary Email Subject & Body)
    * @param    summaryDeliveryPDIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to be processed for Manager Summary Delivery)
    * @param    offerCommunicatorMap	            DESCRIPTION (Data Type Map<Id, List<Id>>, Map of Package Distribution Id to List of Offer Communicator Ids for Manager Summary Delivery)
    * @param    customSummaryEmailMap	            DESCRIPTION (Data Type Map<Id, Boolean>, Map of Package Distribution Id to "Custom Manager Summary Email" flag value for Manager Summary Delivery)
    * @param    executionOriginType	                DESCRIPTION (Data Type MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin, MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin enum type)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void initSummaryDeliveryJob(Id srcRecordId, Id targetUserId, Acquisition_Company__c acqCompany, Set<Id> summaryDeliveryPDIds, Map<Id, List<Id>> offerCommunicatorMap, Map<Id, Boolean> customSummaryEmailMap, MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin executionOriginType) {
        MA_DS_ManagerSummaryDeliveryWrapper.OfferCommunicatorsDeliveryParams jobParams = new MA_DS_ManagerSummaryDeliveryWrapper.OfferCommunicatorsDeliveryParams();
        jobParams.acqCompany = acqCompany;
        jobParams.srcRecordId = srcRecordId;
        jobParams.targetUserId = targetUserId;
        jobParams.executionOriginType = executionOriginType;
        jobParams.summaryDeliveryPDIds = summaryDeliveryPDIds;
        jobParams.offerCommunicatorMap = offerCommunicatorMap;
        jobParams.customSummaryEmailMap = customSummaryEmailMap;
        jobParams.offerCommunicatorPDIds = new List<Id>(jobParams.offerCommunicatorMap.keySet());
        jobParams.totalPkgDistributions = jobParams.offerCommunicatorPDIds.size();
        jobParams.totalBatches = MA_DS_OfferCommunicatorsDeliveryUtility.getTotalBatches(offerCommunicatorMap, jobParams.querySizeLimit);
        this.summaryDeliveryJob = new OfferCommunicatorsDelivery(jobParams, new OfferCommunicatorsDeliveryFinalizer(jobParams));
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to process Offer Communicators for Manager Summary Delivery.
    * Recursively self-chains itself to process all Offer Communicators from eligible / selected / scheduled Package Distribution records.
    * Each SummaryDeliveryJob instance makes a set number of API callouts to DocuSign CLM to initiate Manager Summary Delivery workflow.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class OfferCommunicatorsDelivery extends MA_DS_ManagerSummaryDeliveryService.SummaryDeliveryJob {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the OfferCommunicatorsDelivery class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the SummaryDeliveryJob type)
        * @param    jobFinalizer	    DESCRIPTION (Data Type JobFinalizer, JobFinalizer instance for the SummaryDeliveryJob type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public OfferCommunicatorsDelivery(MA_DS_ManagerSummaryDeliveryService.JobParams jobParams, MA_DS_ManagerSummaryDeliveryService.JobFinalizer jobFinalizer) {
            super(jobParams, jobFinalizer);
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to process Manager Summary Delivery for all Offer Communicators.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext            DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void execute(QueueableContext qContext) {
            //System.debug('OfferCommunicatorsDelivery jobParams : ' + JSON.serialize(this.jobParams));
            MA_DS_ManagerSummaryDeliveryWrapper.OfferCommunicatorsDeliveryParams jobParams = (MA_DS_ManagerSummaryDeliveryWrapper.OfferCommunicatorsDeliveryParams)this.jobParams;
            jobParams.commonId = (jobParams.commonId == null) ? qContext.getJobId() : jobParams.commonId;

            List<MA_DS_CalloutFramework.RequestParams> requestParamsList = new List<MA_DS_CalloutFramework.RequestParams>();

            for(Integer currentAPICalloutCount=1; jobParams.currentIndex < jobParams.totalPkgDistributions && currentAPICalloutCount <= jobParams.maxAPICalloutCount; currentAPICalloutCount++) {
                jobParams.currentBatchNumber++;

                Id pkgDistributionId = jobParams.offerCommunicatorPDIds[jobParams.currentIndex];
                jobParams.currentIndexOfferCommunicatorsCount = jobParams.offerCommunicatorMap.get(pkgDistributionId)?.size();
                
                Boolean customSummaryEmail = jobParams.customSummaryEmailMap.get(pkgDistributionId);
                
                Map<Id, Acquisition_Contacts__c> acqContactMap = MA_DS_OfferCommunicatorsDeliveryUtility.getOfferCommunicators(jobParams.offerCommunicatorMap.get(pkgDistributionId), jobParams.lastIndex + 1, jobParams.querySizeLimit);
                MA_DS_CalloutFramework.RequestParams requestParams = MA_DS_OfferCommunicatorsDeliveryUtility.getManagerSummaryDeliveryParams(jobParams.commonId, pkgDistributionId, customSummaryEmail, jobParams.totalBatches, jobParams.currentBatchNumber, jobParams.acqCompany, acqContactMap);
                
                requestParamsList.add(requestParams);
                jobParams.lastIndex += acqContactMap.size();
                jobParams.totalOfferCommunicators += acqContactMap.size();

                MA_DS_OfferCommunicatorsDeliveryUtility.calloutManagerSummaryDeliveryWorkflow(jobParams.acqCompany.Id, requestParams);

                if(MA_DS_OfferCommunicatorsDeliveryUtility.calloutSuccess(requestParams)) {
                    jobParams.successCount += acqContactMap.size();
                }
            }

            if(requestParamsList.size() > 0 && jobParams.successCount == jobParams.totalOfferCommunicators) {
                MA_DS_OfferCommunicatorsDeliveryUtility.updateSummaryAppliedRules(requestParamsList);
            }

            this.invokeJobFinalizer(jobParams);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to invoke JobFinalizer action to handle Single Job completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams                       DESCRIPTION (Data type JobParams, JobParams instance for the SummaryDeliveryJob type)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void invokeJobFinalizer(MA_DS_ManagerSummaryDeliveryWrapper.OfferCommunicatorsDeliveryParams jobParams) {
            if(jobParams.lastIndex < jobParams.currentIndexOfferCommunicatorsCount - 1) {
                this.jobFinalizer.handleSingleJobCompletion();
            }else if(jobParams.lastIndex == jobParams.currentIndexOfferCommunicatorsCount - 1 && jobParams.currentIndex < jobParams.totalPkgDistributions - 1) {
                this.jobFinalizer.handleSingleJobCompletion();
            }else {
                this.jobFinalizer.handleFinalJobCompletion();
            }
        }
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of MA_DS_ManagerSummaryDeliveryService.SummaryDeliveryJobFinalizer to provide JobFinalizer implementation for OfferCommunicatorsDelivery Queueable job.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class OfferCommunicatorsDeliveryFinalizer extends MA_DS_ManagerSummaryDeliveryService.SummaryDeliveryJobFinalizer {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the OfferCommunicatorsDeliveryFinalizer class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the SummaryDeliveryJobFinalizer type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public OfferCommunicatorsDeliveryFinalizer(MA_DS_ManagerSummaryDeliveryService.JobParams jobParams) {
            super(jobParams);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on each single job completion, initializes OfferCommunicatorsDelivery job & enqueues it.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion() {
            MA_DS_ManagerSummaryDeliveryWrapper.OfferCommunicatorsDeliveryParams jobParams = (MA_DS_ManagerSummaryDeliveryWrapper.OfferCommunicatorsDeliveryParams)this.jobParams;

            if(jobParams.lastIndex == jobParams.currentIndexOfferCommunicatorsCount - 1) {
                jobParams.lastIndex = -1;
                jobParams.currentIndex++;
            }

            OfferCommunicatorsDelivery summaryDeliveryJob = new OfferCommunicatorsDelivery(this.jobParams, new OfferCommunicatorsDeliveryFinalizer(this.jobParams));
            MA_DS_ManagerSummaryDeliveryService.execute(summaryDeliveryJob);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on final job completion, updates Package Distribution records to denote Manager Summary Delivery process is completed.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleFinalJobCompletion() {
            MA_DS_ManagerSummaryDeliveryWrapper.OfferCommunicatorsDeliveryParams jobParams = (MA_DS_ManagerSummaryDeliveryWrapper.OfferCommunicatorsDeliveryParams)this.jobParams;
            Boolean allSuccess = (jobParams.totalOfferCommunicators == jobParams.successCount);
            
            MA_DS_OfferCommunicatorsDeliveryUtility.updatePackageDistributions(jobParams.summaryDeliveryPDIds);
            MA_DS_OfferCommunicatorsDeliveryUtility.notifyTargetIfNeeded(allSuccess, jobParams.srcRecordId, jobParams.targetUserId, jobParams.totalOfferCommunicators, jobParams.executionOriginType);
        }
    }
}