/**
 * W-13465459
 * Class to hold MA_DS_PackageDeliveryService.PackageDeliveryJob implementation to process all eligible Acquisition Contacts for Package Delivery.
 * Holds MA_DS_PackageDeliveryService.PackageDeliveryJobFinalizer implementation to provide actions for single / final job completion.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         26/05/2023      Chakshu Malhotra        W-13465459 - Adds logic to process Package Distributions for Package Delivery.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_AcqContactsPackageDeliveryService extends MA_DS_PackageDeliveryService.PackageDeliveryService {
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize the AcqContactsPackageDelivery Job with JobParams & JobFinalizer to identify & process Acquisition Contacts for Package Delivery API callout.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                    DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    acqCompanyId	                DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    acqContactId	                DESCRIPTION (Data Type Id, Acquisition Contact record Id)
    * @param    packageDeliveryPDIds	        DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to process them for Package Delivery)
    * @param    executionOriginType	            DESCRIPTION (Data Type MA_DS_PackageDeliveryService.ExecutionOrigin, Enum Type ExecutionOrigin)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void initPackageDeliveryJob(Id srcRecordId, Id acqCompanyId, Id acqContactId, Set<Id> packageDeliveryPDIds, MA_DS_PackageDeliveryService.ExecutionOrigin executionOriginType) {
        MA_DS_PackageDeliveryWrapper.AcqContactsPackageDeliveryParams jobParams = new MA_DS_PackageDeliveryWrapper.AcqContactsPackageDeliveryParams();

        List<MA_DS_Package_Distribution__c> pkgDistributions = MA_DS_AcqContactsPackageDeliveryUtility.getPackageDistributions(packageDeliveryPDIds);
        jobParams.sortOrderMap = MA_DS_AcqContactsPackageDeliveryUtility.getSortOrderMap(pkgDistributions);
        jobParams.customDeliveryEmailMap = MA_DS_AcqContactsPackageDeliveryUtility.getCustomDeliveryEmailMap(pkgDistributions);

        jobParams.acqContactId = acqContactId;

        Boolean scheduledDelivery = (executionOriginType == MA_DS_PackageDeliveryService.ExecutionOrigin.SCHEDULED_DELIVERY);
        jobParams.singleContactDelivery = (executionOriginType == MA_DS_PackageDeliveryService.ExecutionOrigin.SINGLE_CONTACT_DELIVERY);

        jobParams.srcRecordId = (scheduledDelivery && pkgDistributions.size() > 0) ? pkgDistributions[0].Id : srcRecordId;
        jobParams.targetUserId = (scheduledDelivery && pkgDistributions.size() > 0) ? pkgDistributions[0].CreatedById : UserInfo.getUserId();

        acqCompanyId = ((scheduledDelivery || jobParams.singleContactDelivery) && pkgDistributions.size() > 0) ? pkgDistributions[0].MA_DS_Package__r.MA_DS_Acquisition_Company__c : acqCompanyId;
        jobParams.acqCompany = MA_DS_AcqContactsPackageDeliveryUtility.getAcquisitionCompanyWithPackageEnvelopeEmail(acqCompanyId);

        jobParams.executionOriginType = executionOriginType;
        jobParams.packageDeliveryPDIds = packageDeliveryPDIds;
        
        this.packageDeliveryJob = new AcqContactsPackageDelivery(jobParams, new AcqContactsPackageDeliveryFinalizer(jobParams));
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to process Package Distributions for Package Delivery.
    * Recursively self-chains itself to process all eligible / selected Package Distribution records to identify & process Acquisition Contacts. 
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class AcqContactsPackageDelivery extends MA_DS_PackageDeliveryService.PackageDeliveryJob {
        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the AcqContactsPackageDelivery class.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the PackageDeliveryJob type)
        * @param    jobFinalizer	    DESCRIPTION (Data Type JobFinalizer, JobFinalizer instance for the PackageDeliveryJob type)
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public AcqContactsPackageDelivery(MA_DS_PackageDeliveryService.JobParams jobParams, MA_DS_PackageDeliveryService.JobFinalizer jobFinalizer) {
            super(jobParams, jobFinalizer);
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to find & process all eligible Acquisition Contacts for the Package Delivery API Callout.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext            DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void execute(QueueableContext qContext) {
            //System.debug('AcqContactsPackageDelivery jobParams : ' + JSON.serialize(jobParams));
            MA_DS_PackageDeliveryWrapper.AcqContactsPackageDeliveryParams jobParams = (MA_DS_PackageDeliveryWrapper.AcqContactsPackageDeliveryParams)this.jobParams;

            Integer currentDeliveryQuerySize = 0;
            jobParams.commonId = (jobParams.commonId == null) ? qContext.getJobId() : jobParams.commonId;

            List<MA_DS_CalloutFramework.RequestParams> requestParamsList = new List<MA_DS_CalloutFramework.RequestParams>();
            
            for(Integer currentAPICalloutCount=1; currentAPICalloutCount <= jobParams.maxAPICalloutCount; currentAPICalloutCount++) {
                List<Acquisition_Contacts__c> acqContacts = new List<Acquisition_Contacts__c>();

                if(jobParams.packageDeliveryPDIds.size() > 0) {
                    List<String> acqContactIds = jobParams.singleContactDelivery ? new List<String> {String.valueOf(jobParams.acqContactId)} : MA_DS_PackageDeliveryServiceUtility.getPackageDeliveryAcquisitionContactIds(jobParams.packageDeliveryPDIds, jobParams.lastRecordId, jobParams.querySizeLimit);
                    currentDeliveryQuerySize = acqContactIds.size();

                    if(currentDeliveryQuerySize > 0) {
                        updateDeliveryAcquisitionContacts(currentDeliveryQuerySize, acqContactIds, acqContacts);
                        updateBackgroundCheckTemplates(acqContacts);

                        MA_DS_CalloutFramework.RequestParams requestParams = getPackageDeliveryParams(currentDeliveryQuerySize, acqContacts);
                        requestParamsList.add(requestParams);

                        MA_DS_AcqContactsPackageDeliveryUtility.calloutPackageDeliveryWorkflow(jobParams.srcRecordId, requestParams);
                        
                        if(MA_DS_AcqContactsPackageDeliveryUtility.calloutSuccess(requestParams)) {
                            jobParams.successCount += acqContacts.size();
                        }
                    }
                }

                if(jobParams.finalBatch || currentDeliveryQuerySize == 0) {
                    break;
                }
            }

            if(requestParamsList.size() > 0 && jobParams.successCount == jobParams.totalContacts) {
                MA_DS_AcqContactsPackageDeliveryUtility.updatePackageAppliedRules(requestParamsList);
            }

            this.invokeJobFinalizer(jobParams.finalBatch, currentDeliveryQuerySize);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to update the List of Acquisition Contacts to be included in the Package Delivery API request payload.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    currentDeliveryQuerySize                    DESCRIPTION (Data type Integer, Last Query Size of the Aggregated Applied Rules retrieved based on grouping by Acquisition Contact for packageDeliveryPDIds)
        * @param    acqContactIds	                            DESCRIPTION (Data Type List<String>, Acquisition Contact Ids, to be processed for Package Delivery)
        * @param    acqContacts	                                DESCRIPTION (Data Type List<Acquisition_Contacts__c>, List of Acquisition Contacts to be updated with Package Delivery contacts)
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void updateDeliveryAcquisitionContacts(Integer currentDeliveryQuerySize, List<String> acqContactIds, List<Acquisition_Contacts__c> acqContacts) {
            MA_DS_PackageDeliveryWrapper.AcqContactsPackageDeliveryParams jobParams = (MA_DS_PackageDeliveryWrapper.AcqContactsPackageDeliveryParams)this.jobParams;
            jobParams.lastRecordId = (currentDeliveryQuerySize == jobParams.querySizeLimit) ? acqContactIds.remove(currentDeliveryQuerySize - 1) : acqContactIds[currentDeliveryQuerySize - 1];
            acqContacts.addAll(MA_DS_AcqContactsPackageDeliveryUtility.getAquisitionContacts(jobParams.packageDeliveryPDIds, new Set<String>(acqContactIds)));
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to update the Map of Background Check Email Templates for the Acquisition Contacts based on their Office Address Countries.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    acqContacts	                                DESCRIPTION (Data Type List<Acquisition_Contacts__c>, List of Acquisition Contacts to be updated with Package Delivery contacts)
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void updateBackgroundCheckTemplates(List<Acquisition_Contacts__c> acqContacts) {
            MA_DS_PackageDeliveryWrapper.AcqContactsPackageDeliveryParams jobParams = (MA_DS_PackageDeliveryWrapper.AcqContactsPackageDeliveryParams)this.jobParams;
            Set<String> bgcRegions = MA_DS_AcqContactsPackageDeliveryUtility.getBackgroundCheckRegions(acqContacts);

            jobParams.bgcEmailTemplateMap.keySet().retainAll(bgcRegions);
            bgcRegions.removeAll(jobParams.bgcEmailTemplateMap.keySet());

            if(bgcRegions.size() > 0) {
                jobParams.bgcEmailTemplateMap.putAll(MA_DS_AcqContactsPackageDeliveryUtility.getBackgroudCheckEmailTemplateMap(jobParams.acqCompany.Id, bgcRegions));
            }
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to prepare the wrapper instance of PackageDeliveryParams, to be used by API callout request to form the payload for Package Delivery.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    currentDeliveryQuerySize                                DESCRIPTION (Data type Integer, Last Query Size of the Aggregated Applied Rules retrieved based on grouping by Acquisition Contact for packageDeliveryPDIds)
        * @param    acqContacts	                                            DESCRIPTION (Data Type List<Acquisition_Contacts__c>, List of Acquisition Contacts along with their Compensation & Applied Rule details)
        * @return   MA_DS_CalloutFramework.RequestParams                    DESCRIPTION (return MA_DS_CalloutFramework.RequestParams wrapper instance to be used by CalloutFramework to form request payload for the API callout)
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private MA_DS_CalloutFramework.RequestParams getPackageDeliveryParams(Integer currentDeliveryQuerySize, List<Acquisition_Contacts__c> acqContacts) {
            MA_DS_PackageDeliveryWrapper.AcqContactsPackageDeliveryParams jobParams = (MA_DS_PackageDeliveryWrapper.AcqContactsPackageDeliveryParams)this.jobParams;
            jobParams.firstBatch = (jobParams.totalContacts == 0);
            jobParams.totalContacts += acqContacts.size();
            jobParams.finalBatch = (currentDeliveryQuerySize < jobParams.querySizeLimit);
            return MA_DS_AcqContactsPackageDeliveryUtility.getPackageDeliveryParams(jobParams.commonId, jobParams.acqCompany, jobParams.firstBatch, jobParams.finalBatch, jobParams.singleContactDelivery, acqContacts, jobParams.sortOrderMap, jobParams.bgcEmailTemplateMap.values(), jobParams.customDeliveryEmailMap);
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to invoke JobFinalizer action to handle Single Job completion.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    finalBatch                  DESCRIPTION (Data type Boolean, True if the last API callout was the final batch of the Acquisition Contacts processed for Package Delivery)
        * @param    currentDeliveryQuerySize    DESCRIPTION (Data type Integer, Last Query Size of the Aggregated Applied Rules retrieved based on grouping by Acquisition Contact for packageDeliveryPDIds)
        * @return   void
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void invokeJobFinalizer(Boolean finalBatch, Integer currentDeliveryQuerySize) {
            if(finalBatch || currentDeliveryQuerySize == 0) {
                this.jobFinalizer.handleFinalJobCompletion();
            }else {
                this.jobFinalizer.handleSingleJobCompletion();
            }
        }
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of MA_DS_PackageDeliveryService.PackageDeliveryJobFinalizer to provide JobFinalizer implementation for AcqContactsPackageDelivery Queueable job.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class AcqContactsPackageDeliveryFinalizer extends MA_DS_PackageDeliveryService.PackageDeliveryJobFinalizer {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the AcqContactsPackageDeliveryFinalizer class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the PackageDeliveryJobFinalizer type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public AcqContactsPackageDeliveryFinalizer(MA_DS_PackageDeliveryService.JobParams jobParams) {
            super(jobParams);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on each single job completion, initializes AcqContactsPackageDelivery job & enqueues it.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion() {
            AcqContactsPackageDelivery packageDeliveryJob = new AcqContactsPackageDelivery(this.jobParams, new AcqContactsPackageDeliveryFinalizer(this.jobParams));
            MA_DS_PackageDeliveryService.execute(packageDeliveryJob);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on final job completion, updates Package Distribution records to denote Package Delivery process is completed.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleFinalJobCompletion() {
            MA_DS_PackageDeliveryWrapper.AcqContactsPackageDeliveryParams jobParams = (MA_DS_PackageDeliveryWrapper.AcqContactsPackageDeliveryParams)this.jobParams;
            Boolean allSuccess = (jobParams.totalContacts == jobParams.successCount);
            
            MA_DS_AcqContactsPackageDeliveryUtility.updatePackageDistributions(jobParams.packageDeliveryPDIds);
            MA_DS_AcqContactsPackageDeliveryUtility.notifyTargetIfNeeded(allSuccess, jobParams.srcRecordId, jobParams.targetUserId, jobParams.totalContacts, jobParams.executionOriginType);
        }
    }
}