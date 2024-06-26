/**
 * W-12578130
 * Class to hold MA_DS_ManagerSummaryDeliveryService.SummaryDeliveryJob implementation to process Package Distributions for Manager Summary Delivery.
 * Holds MA_DS_ManagerSummaryDeliveryService.SummaryDeliveryJobFinalizer implementation to provide actions for single / final job completion.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         21/04/2023      Chakshu Malhotra        W-12578130 - Adds logic to process Package Distributions for Manager Summary Delivery.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_PackageDistributionDeliveryService extends MA_DS_ManagerSummaryDeliveryService.SummaryDeliveryService {
    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize the PackageDistributionDelivery Job with JobParams & JobFinalizer to prepare Offer Communicators Map for which Manager Summary Delivery need to be initiated.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                        DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    acqCompanyId	                    DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    summaryDeliveryPDIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to be processed for Manager Summary Delivery)
    * @param    executionOriginType	                DESCRIPTION (Data Type MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin, MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin enum type)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void initSummaryDeliveryJob(Id srcRecordId, Id acqCompanyId, Set<Id> summaryDeliveryPDIds, MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin executionOriginType) {
        MA_DS_ManagerSummaryDeliveryWrapper.PackageDistributionDeliveryParams jobParams = new MA_DS_ManagerSummaryDeliveryWrapper.PackageDistributionDeliveryParams();
        MA_DS_Package_Distribution__c pkgDistribution = (executionOriginType == MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin.SCHEDULED_DELIVERY) ? MA_DS_PackageDistributionDeliveryUtility.getScheduledDeliveryPkgDistribution(summaryDeliveryPDIds) : null;
        
        jobParams.srcRecordId = (executionOriginType == MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin.SCHEDULED_DELIVERY) ? pkgDistribution.Id : srcRecordId;
        jobParams.targetUserId = (executionOriginType == MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin.SCHEDULED_DELIVERY) ? pkgDistribution.CreatedById : UserInfo.getUserId();
        jobParams.acqCompanyId = (executionOriginType == MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin.SCHEDULED_DELIVERY) ? pkgDistribution.MA_DS_Package__r.MA_DS_Acquisition_Company__c : acqCompanyId;
        
        jobParams.executionOriginType = executionOriginType;
        jobParams.summaryDeliveryPDIds = new List<Id>(summaryDeliveryPDIds);
        jobParams.totalPkgDistributions = jobParams.summaryDeliveryPDIds.size();
        this.summaryDeliveryJob = new PackageDistributionDelivery(jobParams, new PackageDistributionDeliveryFinalizer(jobParams));
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to process Package Distributions for Manager Summary Delivery.
    * Recursively self-chains itself to process all eligible / selected / scheduled Package Distribution records to prepare Offer Communicators Map. 
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class PackageDistributionDelivery extends MA_DS_ManagerSummaryDeliveryService.SummaryDeliveryJob {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the PackageDistributionDelivery class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the SummaryDeliveryJob type)
        * @param    jobFinalizer	    DESCRIPTION (Data Type JobFinalizer, JobFinalizer instance for the SummaryDeliveryJob type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public PackageDistributionDelivery(MA_DS_ManagerSummaryDeliveryService.JobParams jobParams, MA_DS_ManagerSummaryDeliveryService.JobFinalizer jobFinalizer) {
            super(jobParams, jobFinalizer);
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to find all eligible Offer Communicator Ids for which Manager Summary Delivery process need to be initiated, for each Package Distribution.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext            DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void execute(QueueableContext qContext) {
            //System.debug('PackageDistributionDelivery jobParams : ' + JSON.serialize(this.jobParams));
            MA_DS_ManagerSummaryDeliveryWrapper.PackageDistributionDeliveryParams jobParams = (MA_DS_ManagerSummaryDeliveryWrapper.PackageDistributionDeliveryParams)this.jobParams;
            Integer currentDeliveryQuerySize = 0;

            for(Integer currentQueryCount=1; jobParams.currentIndex < jobParams.totalPkgDistributions && currentQueryCount <= jobParams.maxQueryCount; currentQueryCount++) {
                if(jobParams.summaryDeliveryPDIds.size() > 0) {
                    Id pkgDistributionId = jobParams.summaryDeliveryPDIds[jobParams.currentIndex];

                    List<Id> offerCommunicatorIds = MA_DS_PackageDistributionDeliveryUtility.getSummaryDeliveryOfferCommunicatorIds(pkgDistributionId, jobParams.lastRecordId, jobParams.querySizeLimit);
                    currentDeliveryQuerySize = offerCommunicatorIds.size();

                    if(currentDeliveryQuerySize > 0) {
                        List<Id> offerCommunicatorIdList = jobParams.offerCommunicatorMap.containsKey(pkgDistributionId) ? jobParams.offerCommunicatorMap.get(pkgDistributionId) : new List<Id>();
                        offerCommunicatorIdList.addAll(getUniqueOfferCommunicatorIds(new Set<Id>(offerCommunicatorIds), jobParams));
                        jobParams.offerCommunicatorMap.put(pkgDistributionId, offerCommunicatorIdList);
                    }

                    jobParams.offerCommunicatorIds.addAll(new Set<Id>(offerCommunicatorIds));
                    jobParams.lastRecordId = (currentDeliveryQuerySize > 0) ? offerCommunicatorIds[currentDeliveryQuerySize - 1] : jobParams.lastRecordId;
                }

                if(currentDeliveryQuerySize < jobParams.querySizeLimit && currentQueryCount < jobParams.maxQueryCount) {
                    resetForNextSummaryDeliveryPD(jobParams);
                }
            }

            this.invokeJobFinalizer(currentDeliveryQuerySize, jobParams);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get unique Offer Communicator Ids, by filtering out the ones in jobParams.offerCommunicatorIds .
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    offerCommunicatorIds            DESCRIPTION (Data type Set<Id>, Set of Offer Communicator Ids)
        * @param    jobParams                       DESCRIPTION (Data type JobParams, JobParams instance for the SummaryDeliveryJob type)
        * @return   List<Id>                        DESCRIPTION (return List of Unique Offer Communicator Ids)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private List<Id> getUniqueOfferCommunicatorIds(Set<Id> offerCommunicatorIds, MA_DS_ManagerSummaryDeliveryWrapper.PackageDistributionDeliveryParams jobParams) {
            offerCommunicatorIds.removeAll(jobParams.offerCommunicatorIds);
            return new List<Id>(offerCommunicatorIds);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to increment jobParams.currentIndex and reset jobParams.lastRecordId for the next Package Distribution in the jobParams.summaryDeliveryPDIds list.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams                       DESCRIPTION (Data type JobParams, JobParams instance for the SummaryDeliveryJob type)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void resetForNextSummaryDeliveryPD(MA_DS_ManagerSummaryDeliveryWrapper.PackageDistributionDeliveryParams jobParams) {
            jobParams.currentIndex++;
            jobParams.lastRecordId = null;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to invoke JobFinalizer action to handle Single Job completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    querySizeLimit                  DESCRIPTION (Data type Integer, Maximum number of records allowed to fetch in a single query for the PackageDistributionDelivery job)
        * @param    jobParams                       DESCRIPTION (Data type JobParams, JobParams instance for the SummaryDeliveryJob type)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void invokeJobFinalizer(Integer currentDeliveryQuerySize, MA_DS_ManagerSummaryDeliveryWrapper.PackageDistributionDeliveryParams jobParams) {
            if(jobParams.currentIndex >= jobParams.totalPkgDistributions) {
                this.jobFinalizer.handleFinalJobCompletion();
            }else if(currentDeliveryQuerySize < jobParams.querySizeLimit) {
                resetForNextSummaryDeliveryPD(jobParams);
                this.jobFinalizer.handleSingleJobCompletion();
            }else {
                this.jobFinalizer.handleSingleJobCompletion();
            }
        }
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of MA_DS_ManagerSummaryDeliveryService.SummaryDeliveryJobFinalizer to provide JobFinalizer implementation for PackageDistributionDelivery Queueable job.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class PackageDistributionDeliveryFinalizer extends MA_DS_ManagerSummaryDeliveryService.SummaryDeliveryJobFinalizer {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the PackageDistributionDeliveryFinalizer class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the SummaryDeliveryJobFinalizer type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public PackageDistributionDeliveryFinalizer(MA_DS_ManagerSummaryDeliveryService.JobParams jobParams) {
            super(jobParams);
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on each single job completion, initializes PackageDistributionDelivery job & enqueues it.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion() {
            PackageDistributionDelivery summaryDeliveryJob = new PackageDistributionDelivery(this.jobParams, new PackageDistributionDeliveryFinalizer(this.jobParams));
            MA_DS_ManagerSummaryDeliveryService.execute(summaryDeliveryJob);
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on final job completion, initializes SummaryDeliveryJob to process all Offer Communicators to deliver the Manager Summary to the DocuSign CLM.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleFinalJobCompletion() {
            MA_DS_ManagerSummaryDeliveryWrapper.PackageDistributionDeliveryParams jobParams = (MA_DS_ManagerSummaryDeliveryWrapper.PackageDistributionDeliveryParams)this.jobParams;
            List<Acquisition_Company__c> acqCompanyList = MA_DS_PackageDistributionDeliveryUtility.getAcquisitionCompanyWithSummaryEmail(jobParams.acqCompanyId);
            Map<Id, Boolean> customSummaryEmailMap = MA_DS_PackageDistributionDeliveryUtility.getCustomSummaryEmailMap(jobParams.offerCommunicatorMap.keySet());
            
            MA_DS_ManagerSummaryDeliveryService.strategyInstance.setSrcRecordId(jobParams.srcRecordId)
                                                                .setTargetUserId(jobParams.targetUserId)
                                                                .setAcquisitionCompany(acqCompanyList[0])
                                                                .setSummaryDeliveryPDIds(new Set<Id>(jobParams.summaryDeliveryPDIds))
                                                                .setOfferCommunicatorMap(jobParams.offerCommunicatorMap)
                                                                .setCustomSummaryEmailMap(customSummaryEmailMap)
                                                                .setExecutionJobType(MA_DS_ManagerSummaryDeliveryService.ExecutionJob.DELIVER_OFFER_COMMUNICATORS)
                                                                .setExecutionJobOriginType(jobParams.executionOriginType)
                                                                .initDeliveryService()
                                                                .initSummaryDeliveryJob()
                                                                .execute();
        }
    }
}