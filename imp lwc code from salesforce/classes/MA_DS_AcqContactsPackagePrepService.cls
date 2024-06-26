/**
 * W-13011399
 * Class to hold MA_DS_PackagePrepService.PackagePrepJob implementation to process all eligible Acquisition Contacts for Package Prep.
 * Holds MA_DS_PackagePrepService.PackagePrepJobFinalizer implementation to provide actions for single / final job completion.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         29/04/2023      Chakshu Malhotra        W-13011399 - Adds logic to process Package Distributions for Package Prep.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_AcqContactsPackagePrepService extends MA_DS_PackagePrepService.PackagePrepService {
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize the AcqContactsPackagePrep Job with JobParams & JobFinalizer to identify & process Acquisition Contacts for Package Prep API callout.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                    DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    acqCompanyId	                DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    packagePrepPDIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to be processed for Package Prep or Regeneration)
    * @param    auditFailedCommonIds	        DESCRIPTION (Data Type Set<String>, Set of Package Common Ids to be processed for Package Prep or Regeneration when ExecutionOrigin is AUDIT_FAILED_REGEN)
    * @param    templateIds	                    DESCRIPTION (Data Type Set<String>, Set of Template Ids to be processed for Package Prep or Regeneration when ExecutionOrigin is AUDIT_FAILED_REGEN)
    * @param    acqContactIds	                DESCRIPTION (Data Type Set<String>, Set of Acquisition Contact Ids to be processed for Package Prep or Regeneration when ExecutionOrigin is AUDIT_FAILED_REGEN)
    * @param    appliedRuleIds	                DESCRIPTION (Data Type Set<String>, Set of Applied Rule Ids to be processed for Package Prep or Regeneration when ExecutionOrigin is AUDIT_FAILED_REGEN)
    * @param    executionOriginType	            DESCRIPTION (Data Type MA_DS_PackagePrepService.ExecutionOrigin, Enum Type ExecutionOrigin)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void initPackagePrepJob(Id srcRecordId, Id acqCompanyId, Set<Id> packagePrepPDIds, Set<String> auditFailedCommonIds, Set<String> templateIds, Set<String> acqContactIds, Set<String> appliedRuleIds, MA_DS_PackagePrepService.ExecutionOrigin executionOriginType) {
        MA_DS_PackagePrepWrapper.AcqContactsPackagePrepParams jobParams = new MA_DS_PackagePrepWrapper.AcqContactsPackagePrepParams();
        jobParams.srcRecordId = srcRecordId;
        jobParams.acqCompanyId = acqCompanyId;
        jobParams.templateIds.addAll(templateIds);
        jobParams.acqContactIds.addAll(acqContactIds);
        jobParams.appliedRuleIds.addAll(appliedRuleIds);
        jobParams.packagePrepPDIds.addAll(packagePrepPDIds);
        jobParams.executionOriginType = executionOriginType;
        jobParams.auditFailedCommonIds.addAll(auditFailedCommonIds);
        jobParams.isAuditFailedRegen = (jobParams.executionOriginType == MA_DS_PackagePrepService.ExecutionOrigin.AUDIT_FAILED_REGEN);
        this.packagePrepJob = new AcqContactsPackagePrep(jobParams, new AcqContactsPackagePrepFinalizer(jobParams));
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to process Package Distributions for Package Prep.
    * Recursively self-chains itself to process all eligible / selected Package Distribution records to identify & process Acquisition Contacts. 
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class AcqContactsPackagePrep extends MA_DS_PackagePrepService.PackagePrepJob {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the AcqContactsPackagePrep class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the PackagePrepJob type)
        * @param    jobFinalizer	    DESCRIPTION (Data Type JobFinalizer, JobFinalizer instance for the PackagePrepJob type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public AcqContactsPackagePrep(MA_DS_PackagePrepService.JobParams jobParams, MA_DS_PackagePrepService.JobFinalizer jobFinalizer) {
            super(jobParams, jobFinalizer);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to find & process all eligible Acquisition Contacts for the Package Prep API Callout.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext            DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void execute(QueueableContext qContext) {
            //System.debug('AcqContactsPackagePrep jobParams : ' + JSON.serialize(jobParams));
            MA_DS_PackagePrepWrapper.AcqContactsPackagePrepParams jobParams = (MA_DS_PackagePrepWrapper.AcqContactsPackagePrepParams)this.jobParams;

            Integer currentPrepQuerySize = 0;
            Id asyncApexJobId = qContext.getJobId();

            List<MA_DS_CalloutFramework.RequestParams> requestParamsList = new List<MA_DS_CalloutFramework.RequestParams>();
            jobParams.commonId = (jobParams.commonId == null) ? jobParams.isAuditFailedRegen ? new List<String>(jobParams.auditFailedCommonIds)?.get(0) : asyncApexJobId : jobParams.commonId;

            for(Integer currentAPICalloutCount=1; currentAPICalloutCount <= jobParams.maxAPICalloutCount; currentAPICalloutCount++) {
                List<Acquisition_Contacts__c> acqContacts = new List<Acquisition_Contacts__c>();

                if(jobParams.packagePrepPDIds.size() > 0) {
                    List<String> acqContactIds = MA_DS_PackagePrepServiceUtility.getPackagePrepAcquisitionContactIds(jobParams.isAuditFailedRegen, jobParams.packagePrepPDIds, jobParams.auditFailedCommonIds, jobParams.templateIds, jobParams.acqContactIds, jobParams.appliedRuleIds, jobParams.lastRecordId, jobParams.querySizeLimit);
                    currentPrepQuerySize = acqContactIds.size();

                    if(currentPrepQuerySize > 0) {
                        updatePrepAcquisitionContacts(currentPrepQuerySize, acqContactIds, acqContacts);
                        
                        MA_DS_CalloutFramework.RequestParams requestParams = getPackagePrepParams(currentPrepQuerySize, jobParams.commonId, asyncApexJobId, acqContacts);
                        requestParamsList.add(requestParams);

                        MA_DS_AcqContactsPackagePrepUtility.calloutPackagePrepWorkflow(jobParams.srcRecordId, requestParams);
                    
                        if(MA_DS_AcqContactsPackagePrepUtility.calloutSuccess(requestParams)) {
                            jobParams.successCount += acqContacts.size();
                        }
                    }
                }

                if(jobParams.finalBatch || currentPrepQuerySize == 0) {
                    break;
                }
            }

            if(requestParamsList.size() > 0 && jobParams.successCount == jobParams.totalContacts) {
                MA_DS_AcqContactsPackagePrepUtility.updateAcquisitionContacts(asyncApexJobId, requestParamsList);
            }

            this.invokeJobFinalizer(jobParams.finalBatch, currentPrepQuerySize);
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to update the List of Acquisition Contacts to be included in the Package Prep API request payload.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    currentPrepQuerySize                        DESCRIPTION (Data type Integer, Last Query Size of the Aggregated Applied Rules retrieved based on grouping by Acquisition Contact for packagePrepPDIds)
        * @param    acqContactIds	                            DESCRIPTION (Data Type List<String>, Acquisition Contact Ids, to be processed for Package Prep)
        * @param    acqContacts	                                DESCRIPTION (Data Type List<Acquisition_Contacts__c>, List of Acquisition Contacts to be updated with Package Prep contacts)
        * @return   void
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void updatePrepAcquisitionContacts(Integer currentPrepQuerySize, List<String> acqContactIds, List<Acquisition_Contacts__c> acqContacts) {
            MA_DS_PackagePrepWrapper.AcqContactsPackagePrepParams jobParams = (MA_DS_PackagePrepWrapper.AcqContactsPackagePrepParams)this.jobParams;
            jobParams.lastRecordId = (currentPrepQuerySize == jobParams.querySizeLimit) ? acqContactIds.remove(currentPrepQuerySize - 1) : acqContactIds[currentPrepQuerySize - 1];
            acqContacts.addAll(MA_DS_AcqContactsPackagePrepUtility.getAquisitionContacts(jobParams.isAuditFailedRegen, jobParams.packagePrepPDIds, jobParams.auditFailedCommonIds, jobParams.templateIds, new Set<String>(acqContactIds), jobParams.appliedRuleIds));
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to prepare the wrapper instance of PackagePrepParams, to be used by API callout request to form the payload for Package Prep.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    currentPrepQuerySize                                    DESCRIPTION (Data type Integer, Last Query Size of the Aggregated Applied Rules retrieved based on grouping by Acquisition Contact for packagePrepPDIds)
        * @param    commonId	                                            DESCRIPTION (Data Type Id, Package Common Id for the Package Prep payload)
        * @param    asyncApexId	                                            DESCRIPTION (Data Type Id, Async Apex Job Id)
        * @param    acqContacts	                                            DESCRIPTION (Data Type List<Acquisition_Contacts__c>, List of Acquisition Contacts along with their Compensation & Applied Rule details)
        * @return   MA_DS_CalloutFramework.RequestParams                    DESCRIPTION (return MA_DS_CalloutFramework.RequestParams wrapper instance to be used by CalloutFramework to form request payload for the API callout)
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private MA_DS_CalloutFramework.RequestParams getPackagePrepParams(Integer currentPrepQuerySize, Id commonId, Id asyncApexId, List<Acquisition_Contacts__c> acqContacts) {
            MA_DS_PackagePrepWrapper.AcqContactsPackagePrepParams jobParams = (MA_DS_PackagePrepWrapper.AcqContactsPackagePrepParams)this.jobParams;
            jobParams.firstBatch = (jobParams.totalContacts == 0);
            jobParams.totalContacts += acqContacts.size();
            jobParams.finalBatch = (currentPrepQuerySize < jobParams.querySizeLimit);
            return MA_DS_AcqContactsPackagePrepUtility.getPackagePrepParams(commonId, jobParams.acqCompanyId, asyncApexId, jobParams.firstBatch, jobParams.finalBatch, acqContacts);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to invoke JobFinalizer action to handle Single Job completion.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    finalBatch              DESCRIPTION (Data type Boolean, True if the last API callout was the final batch of the Acquisition Contacts processed for Package Prep)
        * @param    currentPrepQuerySize    DESCRIPTION (Data type Integer, Last Query Size of the Aggregated Applied Rules retrieved based on grouping by Acquisition Contact for packagePrepPDIds)
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void invokeJobFinalizer(Boolean finalBatch, Integer currentPrepQuerySize) {
            if(finalBatch || currentPrepQuerySize == 0) {
                this.jobFinalizer.handleFinalJobCompletion();
            }else {
                this.jobFinalizer.handleSingleJobCompletion();
            }
        }
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of MA_DS_PackagePrepService.PackagePrepJobFinalizer to provide JobFinalizer implementation for AcqContactsPackagePrep Queueable job.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class AcqContactsPackagePrepFinalizer extends MA_DS_PackagePrepService.PackagePrepJobFinalizer {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the AcqContactsPackagePrepFinalizer class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the PackagePrepJobFinalizer type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public AcqContactsPackagePrepFinalizer(MA_DS_PackagePrepService.JobParams jobParams) {
            super(jobParams);
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on each single job completion, initializes AcqContactsPackagePrep job & enqueues it.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion() {
            AcqContactsPackagePrep packagePrepJob = new AcqContactsPackagePrep(this.jobParams, new AcqContactsPackagePrepFinalizer(this.jobParams));
            MA_DS_PackagePrepService.execute(packagePrepJob);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on final job completion, updates Package Distribution records to denote Package Prep process is completed.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleFinalJobCompletion() {
            MA_DS_PackagePrepWrapper.AcqContactsPackagePrepParams jobParams = (MA_DS_PackagePrepWrapper.AcqContactsPackagePrepParams)this.jobParams;
            Boolean allSuccess = (jobParams.totalContacts == jobParams.successCount);
            
            MA_DS_AcqContactsPackagePrepUtility.updatePackageDistributions(jobParams.packagePrepPDIds);
            MA_DS_AcqContactsPackagePrepUtility.updatePackageAuditIfNeeded(jobParams.isAuditFailedRegen, jobParams.acqCompanyId);
            MA_DS_AcqContactsPackagePrepUtility.notifyTargetIfNeeded(jobParams.isAuditFailedRegen, allSuccess, jobParams.srcRecordId, jobParams.totalContacts);
        }
    }
}