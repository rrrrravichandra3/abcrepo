/**
 * W-12578116
 * Class to hold MA_DS_ManagerSummaryPrepService.SummaryPrepJob implementation to process Package Distributions for Manager Summary Prep.
 * Holds MA_DS_ManagerSummaryPrepService.SummaryPrepJobFinalizer implementation to provide actions for single / final job completion.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         27/03/2023      Chakshu Malhotra        W-12578116 - Adds logic to process Package Distributions for Manager Summary Prep.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_OfferCommunicatorsPrepService extends MA_DS_ManagerSummaryPrepService.SummaryPrepService {
    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize the OfferCommunicatorsPrep Job with JobParams & JobFinalizer to identify Offer Communicator Ids for which Manager Summary Prep need to be initiated.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                    DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    acqCompanyId	                DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    summaryTemplateId	            DESCRIPTION (Data Type Id, Template record Id of Document type Manager Summary)
    * @param    summaryPrepPDIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to process them for Manager Summary Prep or Regeneration)
    * @param    auditFailedCommonIds	        DESCRIPTION (Data Type Set<String>, Set of Manager Summary Common Ids to be processed for Manager Summary Prep or Regeneration when ExecutionOrigin is AUDIT_FAILED_REGEN)
    * @param    offerCommunicatorIds	        DESCRIPTION (Data Type Set<String>, Set of Offer Communicator Ids processed for Manager Summary Prep)
    * @param    executionOriginType	            DESCRIPTION (Data Type MA_DS_ManagerSummaryPrepService.ExecutionOrigin, Enum Type ExecutionOrigin)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void initSummaryPrepJob(Id srcRecordId, Id acqCompanyId, Id summaryTemplateId, Set<Id> summaryPrepPDIds, Set<String> auditFailedCommonIds, Set<String> offerCommunicatorIds, MA_DS_ManagerSummaryPrepService.ExecutionOrigin executionOriginType) {
        MA_DS_ManagerSummaryPrepWrapper.OfferCommunicatorsPrepParams jobParams = new MA_DS_ManagerSummaryPrepWrapper.OfferCommunicatorsPrepParams();
        jobParams.srcRecordId = srcRecordId;
        jobParams.acqCompanyId = acqCompanyId;
        jobParams.summaryPrepPDIds = summaryPrepPDIds;
        jobParams.summaryTemplateId = summaryTemplateId;
        jobParams.executionOriginType = executionOriginType;
        jobParams.auditFailedCommonIds = auditFailedCommonIds;
        jobParams.offerCommunicatorIds.addAll(offerCommunicatorIds);
        jobParams.isAuditFailedRegen = (jobParams.executionOriginType == MA_DS_ManagerSummaryPrepService.ExecutionOrigin.AUDIT_FAILED_REGEN);
        jobParams.isAuditFailedRegenAll = (jobParams.isAuditFailedRegen && jobParams.offerCommunicatorIds.size() == 0);
        this.summaryPrepJob = new OfferCommunicatorsPrep(jobParams, new OfferCommunicatorsPrepFinalizer(jobParams));
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to process Package Distributions for Manager Summary Prep.
    * Recursively self-chains itself to process all eligible / selected Package Distribution records to identify Offer Communicator Ids. 
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class OfferCommunicatorsPrep extends MA_DS_ManagerSummaryPrepService.SummaryPrepJob {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the OfferCommunicatorsPrep class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the SummaryPrepJob type)
        * @param    jobFinalizer	    DESCRIPTION (Data Type JobFinalizer, JobFinalizer instance for the SummaryPrepJob type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public OfferCommunicatorsPrep(MA_DS_ManagerSummaryPrepService.JobParams jobParams, MA_DS_ManagerSummaryPrepService.JobFinalizer jobFinalizer) {
            super(jobParams, jobFinalizer);
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to find all eligible Offer Communicator Ids for which Manager Summary Prep process need to be initiated.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext            DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void execute(QueueableContext qContext) {
            //System.debug('OfferCommunicatorsPrep jobParams : ' + JSON.serialize(jobParams));
            MA_DS_ManagerSummaryPrepWrapper.OfferCommunicatorsPrepParams jobParams = (MA_DS_ManagerSummaryPrepWrapper.OfferCommunicatorsPrepParams)this.jobParams;
            Integer currentPrepQuerySize = 0;

            for(Integer currentQueryCount=1; currentQueryCount <= jobParams.maxQueryCount; currentQueryCount++) {
                if((!jobParams.isAuditFailedRegen && jobParams.summaryPrepPDIds.size() > 0) || (jobParams.isAuditFailedRegenAll)) {
                    List<String> offerCommunicatorIds = MA_DS_OfferCommunicatorsPrepUtility.getSummaryPrepOfferCommunicatorIds(jobParams.isAuditFailedRegen, jobParams.auditFailedCommonIds, jobParams.summaryPrepPDIds, jobParams.lastRecordId, jobParams.querySizeLimit);
                    currentPrepQuerySize = offerCommunicatorIds.size();
                    jobParams.offerCommunicatorIds.addAll(new Set<String>(offerCommunicatorIds));
                    jobParams.lastRecordId = (offerCommunicatorIds.size() > 0) ? offerCommunicatorIds[offerCommunicatorIds.size() - 1] : jobParams.lastRecordId;
                }

                if(currentPrepQuerySize < jobParams.querySizeLimit) {
                    break;
                }
            }

            jobParams.commonId = jobParams.isAuditFailedRegen ? new List<String>(jobParams.auditFailedCommonIds)?.get(0) : qContext.getJobId();
            this.invokeJobFinalizer(currentPrepQuerySize, jobParams.querySizeLimit);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to invoke JobFinalizer action to handle Single Job completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    currentPrepQuerySize            DESCRIPTION (Data type Integer, Last Query Size of the Aggregated Applied Rules retrieved based on grouping by Offer Communicators)
        * @param    querySizeLimit                  DESCRIPTION (Data type Integer, Maximum number of records allowed to fetch in a single query for the OfferCommunicatorsPrep job)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void invokeJobFinalizer(Integer currentPrepQuerySize, Integer querySizeLimit) {
            if(currentPrepQuerySize < querySizeLimit) {
                this.jobFinalizer.handleFinalJobCompletion();
            }else {
                this.jobFinalizer.handleSingleJobCompletion();
            }
        }
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of MA_DS_ManagerSummaryPrepService.SummaryPrepJobFinalizer to provide JobFinalizer implementation for OfferCommunicatorsPrep Queueable job.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class OfferCommunicatorsPrepFinalizer extends MA_DS_ManagerSummaryPrepService.SummaryPrepJobFinalizer {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the OfferCommunicatorsPrepFinalizer class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the SummaryPrepJobFinalizer type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public OfferCommunicatorsPrepFinalizer(MA_DS_ManagerSummaryPrepService.JobParams jobParams) {
            super(jobParams);
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on each single job completion, initializes OfferCommunicatorsPrep job & enqueues it.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion() {
            OfferCommunicatorsPrep summaryPrepJob = new OfferCommunicatorsPrep(this.jobParams, new OfferCommunicatorsPrepFinalizer(this.jobParams));
            MA_DS_ManagerSummaryPrepService.execute(summaryPrepJob);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on final job completion, initializes SummaryPrepJob to process all Offer Communicators to prepare the Manager Summary details for the DocuSign CLM.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleFinalJobCompletion() {
            MA_DS_ManagerSummaryPrepWrapper.OfferCommunicatorsPrepParams jobParams = (MA_DS_ManagerSummaryPrepWrapper.OfferCommunicatorsPrepParams)this.jobParams;
            MA_DS_ManagerSummaryPrepService.strategyInstance.setCommonId(jobParams.commonId)
                                                            .setSrcRecordId(jobParams.srcRecordId)
                                                            .setAcqCompanyId(jobParams.acqCompanyId)
                                                            .setSummaryTemplateId(jobParams.summaryTemplateId)
                                                            .setSummaryPrepPDIds(jobParams.summaryPrepPDIds)
                                                            .setofferCommunicatorIds(jobParams.offerCommunicatorIds)
                                                            .setExecutionJobType(MA_DS_ManagerSummaryPrepService.ExecutionJob.PREP_SUMMARIZED_CONTACTS)
                                                            .setExecutionJobOriginType(jobParams.executionOriginType)
                                                            .initPrepService()
                                                            .initSummaryPrepJob()
                                                            .execute();
        }
    }
}