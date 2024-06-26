/**
 * W-12578116
 * Class to hold MA_DS_ManagerSummaryPrepService.SummaryPrepJob implementation to process Offer Communicators & Summarized Contacts for Manager Summary Prep.
 * Holds MA_DS_ManagerSummaryPrepService.SummaryPrepJobFinalizer implementation to provide actions for single / final job completion.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         29/03/2023      Chakshu Malhotra        W-12578116 - Adds logic to process Offer Communicators & Summarized Contacts for Manager Summary Prep.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_SummarizedContactsPrepService extends MA_DS_ManagerSummaryPrepService.SummaryPrepService {
    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize the OfferCommunicatorsPrep Job with JobParams & JobFinalizer to identify Offer Communicator Ids for which Manager Summary Prep need to be initiated.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    commonId	                        DESCRIPTION (Data Type Id, Manager Summary Common Id to be added in the payload of Manager Summary Prep API callout)
    * @param    srcRecordId	                        DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    acqCompanyId	                    DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    summaryTemplateId	                DESCRIPTION (Data Type Id, Template record Id of Document type Manager Summary)
    * @param    summaryPrepPDIds	                DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to process them for Manager Summary Prep or Regeneration)
    * @param    offerCommunicatorIds	            DESCRIPTION (Data Type Set<String>, Set of Offer Communicator Ids processed for Manager Summary Prep)
    * @param    executionOriginType	                DESCRIPTION (Data Type MA_DS_ManagerSummaryPrepService.ExecutionOrigin, Enum Type ExecutionOrigin)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void initSummaryPrepJob(Id commonId, Id srcRecordId, Id acqCompanyId, Id summaryTemplateId, Set<Id> summaryPrepPDIds, Set<String> offerCommunicatorIds, MA_DS_ManagerSummaryPrepService.ExecutionOrigin executionOriginType) {
        MA_DS_ManagerSummaryPrepWrapper.SummarizedContactsPrepParams jobParams = new MA_DS_ManagerSummaryPrepWrapper.SummarizedContactsPrepParams();
        jobParams.commonId = commonId;
        jobParams.srcRecordId = srcRecordId;
        jobParams.acqCompanyId = acqCompanyId;
        jobParams.summaryPrepPDIds = summaryPrepPDIds;
        jobParams.summaryTemplateId = summaryTemplateId;
        jobParams.executionOriginType = executionOriginType;
        jobParams.totalBatches = offerCommunicatorIds.size();
        jobParams.offerCommunicatorIds = new List<String>(offerCommunicatorIds);
        jobParams.isAuditFailedRegen = (jobParams.executionOriginType == MA_DS_ManagerSummaryPrepService.ExecutionOrigin.AUDIT_FAILED_REGEN);
        this.summaryPrepJob = new SummarizedContactsPrep(jobParams, new SummarizedContactsPrepFinalizer(jobParams));
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to process Manager Summary Prep for all Offer Communicators & their Summarized Contacts.
    * Recursively self-chains itself to process all Offer Communicators to send the Manager Summary report details to the DocuSign CLM.
    * Each SummaryPrepJob instance makes a set number of API callouts to DocuSign CLM to initiate Manager Summary Prep workflow.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class SummarizedContactsPrep extends MA_DS_ManagerSummaryPrepService.SummaryPrepJob {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the SummarizedContactsPrep class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the SummaryPrepJob type)
        * @param    jobFinalizer	    DESCRIPTION (Data Type JobFinalizer, JobFinalizer instance for the SummaryPrepJob type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public SummarizedContactsPrep(MA_DS_ManagerSummaryPrepService.JobParams jobParams, MA_DS_ManagerSummaryPrepService.JobFinalizer jobFinalizer) {
            super(jobParams, jobFinalizer);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to process Manager Summary Prep for all Offer Communicators & their Summarized Contacts.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void execute(QueueableContext qContext) {
            //System.debug('SummarizedContactsPrep jobParams : ' + JSON.serialize(jobParams));
            MA_DS_ManagerSummaryPrepWrapper.SummarizedContactsPrepParams jobParams = (MA_DS_ManagerSummaryPrepWrapper.SummarizedContactsPrepParams)this.jobParams;
            
            Integer remainingCount = (jobParams.totalBatches - jobParams.currentIndex);
            Integer maxAPICalloutCount = (remainingCount < jobParams.maxAPICalloutCount) ? remainingCount : jobParams.maxAPICalloutCount;

            Map<Id, Acquisition_Contacts__c> offerCommunicatorMap = MA_DS_SummarizedContactsPrepUtility.getOfferCommunicatorMap(jobParams.offerCommunicatorIds, jobParams.currentIndex, maxAPICalloutCount);
            Map<Id, Map<Id, Acquisition_Contacts__c>> summarizedContactsMap = MA_DS_SummarizedContactsPrepUtility.getSummarizedContactsMap(offerCommunicatorMap.keySet(), jobParams.summaryPrepPDIds);

            Integer currentBatchNumber = jobParams.currentIndex;
            List<MA_DS_CalloutFramework.RequestParams> requestParamsList = new List<MA_DS_CalloutFramework.RequestParams>();
            
            Id asyncApexJobId = qContext.getJobId();

            for(Id offerCommunicatorId : summarizedContactsMap.keySet()) {
                currentBatchNumber++;

                Acquisition_Contacts__c offerCommunicator = offerCommunicatorMap.get(offerCommunicatorId);
                Map<Id, Acquisition_Contacts__c> summarizedContacts = summarizedContactsMap.get(offerCommunicatorId);
                MA_DS_CalloutFramework.RequestParams requestParams = getManagerSummaryPrepParams(asyncApexJobId, currentBatchNumber, offerCommunicator, summarizedContacts.values());
                
                requestParamsList.add(requestParams);
                MA_DS_SummarizedContactsPrepUtility.calloutManagerSummaryPrepWorkflow(jobParams.acqCompanyId, requestParams);

                if(MA_DS_SummarizedContactsPrepUtility.calloutSuccess(requestParams)) {
                    jobParams.successCount += 1;
                }
            }

            jobParams.currentIndex += (maxAPICalloutCount - 1);

            if(requestParamsList.size() > 0 && jobParams.successCount == (jobParams.currentIndex + 1)) {
                MA_DS_SummarizedContactsPrepUtility.updateOfferCommunicatorsAndSummarizedContacts(asyncApexJobId, requestParamsList);
            }

            this.invokeJobFinalizer(jobParams.currentIndex, jobParams.totalBatches);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to prepare the wrapper instance of ManagerSummaryPrepParams, to be used by API callout request to form the payload for Manager Summary Prep.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    asyncApexId	                                            DESCRIPTION (Data Type Id, Async Apex Job Id)
        * @param    currentBatchNumber	                                    DESCRIPTION (Data Type Integer, Current Batch Number representing the current Callout count)
        * @param    offerCommunicator	                                    DESCRIPTION (Data Type Acquisition_Contacts__c, Offer Communicator (Acquisition Contact) record details)
        * @param    summarizedContacts	                                    DESCRIPTION (Data Type List<Acquisition_Contacts__c>, List of Summarized Contacts (Acquisition Contacts) along with their Compensation & Applied Rule details)
        * @return   MA_DS_CalloutFramework.RequestParams                    DESCRIPTION (return MA_DS_CalloutFramework.RequestParams wrapper instance to be used by CalloutFramework to form request payload for the API callout)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private MA_DS_CalloutFramework.RequestParams getManagerSummaryPrepParams(Id asyncApexId, Integer currentBatchNumber, Acquisition_Contacts__c offerCommunicator, List<Acquisition_Contacts__c> summarizedContacts) {
            MA_DS_ManagerSummaryPrepWrapper.SummarizedContactsPrepParams jobParams = (MA_DS_ManagerSummaryPrepWrapper.SummarizedContactsPrepParams)this.jobParams;
            return MA_DS_SummarizedContactsPrepUtility.getManagerSummaryPrepParams(jobParams.commonId, jobParams.acqCompanyId, jobParams.summaryTemplateId, asyncApexId, jobParams.totalBatches, currentBatchNumber, jobParams.summaryPrepPDIds, offerCommunicator, summarizedContacts);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to invoke JobFinalizer action to handle Single Job completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    currentIndex            DESCRIPTION (Data type Integer, Index of the last Offer Communicator Id processed for Manager Summary Prep)
        * @param    totalBatches            DESCRIPTION (Data type Integer, Total number of Offer Communicators being processed)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void invokeJobFinalizer(Integer currentIndex, Integer totalBatches) {
            if(currentIndex == (totalBatches - 1)) {
                this.jobFinalizer.handleFinalJobCompletion();
            }else {
                this.jobFinalizer.handleSingleJobCompletion();
            }
        }
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of MA_DS_ManagerSummaryPrepService.SummaryPrepJobFinalizer to provide JobFinalizer implementation for SummarizedContactsPrep Queueable job.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class SummarizedContactsPrepFinalizer extends MA_DS_ManagerSummaryPrepService.SummaryPrepJobFinalizer {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the SummarizedContactsPrepFinalizer class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the SummaryPrepJobFinalizer type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public SummarizedContactsPrepFinalizer(MA_DS_ManagerSummaryPrepService.JobParams jobParams) {
            super(jobParams);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on each single job completion, increments currentIndex by 1, initializes SummarizedContactsPrep job & enqueues it.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion() {
            MA_DS_ManagerSummaryPrepWrapper.SummarizedContactsPrepParams jobParams = (MA_DS_ManagerSummaryPrepWrapper.SummarizedContactsPrepParams)this.jobParams;
            jobParams.currentIndex++;

            SummarizedContactsPrep summaryPrepJob = new SummarizedContactsPrep(jobParams, new SummarizedContactsPrepFinalizer(jobParams));
            MA_DS_ManagerSummaryPrepService.execute(summaryPrepJob);
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on final job completion, updates Package Distribution records to denote Manager Summary Prep process is completed.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleFinalJobCompletion() {
            MA_DS_ManagerSummaryPrepWrapper.SummarizedContactsPrepParams jobParams = (MA_DS_ManagerSummaryPrepWrapper.SummarizedContactsPrepParams)this.jobParams;
            Boolean allSuccess = (jobParams.totalBatches == jobParams.successCount);

            MA_DS_SummarizedContactsPrepUtility.updatePackageDistributions(jobParams.summaryPrepPDIds);
            MA_DS_SummarizedContactsPrepUtility.updateManagerSummaryAuditIfNeeded(jobParams.isAuditFailedRegen, jobParams.acqCompanyId);
            MA_DS_SummarizedContactsPrepUtility.notifyTargetIfNeeded(jobParams.isAuditFailedRegen, allSuccess, jobParams.srcRecordId, jobParams.totalBatches);
        }
    }
}