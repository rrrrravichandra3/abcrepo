/**
 * ******************************************** W-12578108 : RULE ENGINE ********************************************
 * 
 * Class to hold MA_DS_AppliedRulesService.AppliedRuleJob implementation to process Package Distribution type Applied Rules.
 * Holds MA_DS_AppliedRulesService.AppliedRuleJobFinalizer implementation to provide actions for single / final job completion.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         18/03/2023      Chakshu Malhotra        W-12578108 - Adds logic to process Package Distribution type Applied Rules.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_PackageAppliedRuleSyncService extends MA_DS_AppliedRulesService.AppliedRuleSyncService {
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize the PackageRuleSync Job with JobParams & JobFinalizer to process Package Distribution type Applied Rules.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	                    DESCRIPTION (Data Type Id, Acquisition Company record Id of the Package record)
    * @param    pkgId	                            DESCRIPTION (Data Type Id, Package record Id of the Package Distribution record)
    * @param    pkgDistributionId	                DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    originExecMode	                    DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionMode, ExecutionMode enum type)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void initAppliedRuleJob(Id acqCompanyId, Id pkgId, Id pkgDistributionId, MA_DS_AppliedRulesService.ExecutionMode originExecMode) {
        MA_DS_AppliedRulesService.JobParams jobParams = MA_DS_AppliedRulesServiceUtility.getPackageAppliedRulesParams(acqCompanyId, pkgId, pkgDistributionId, originExecMode);
        MA_DS_AppliedRulesService.JobFinalizer jobFinalizer = new PackageRuleSyncFinalizer(jobParams);
        this.appliedRuleJob = new PackageRuleSync(jobParams, jobFinalizer);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to Upsert Package Distribution type Applied Rules.
    * Recursively self-chains itself to process all eligible Acquisition Contacts based on the Rules Criteria Query set on the Package Distribution. 
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class PackageRuleSync extends MA_DS_AppliedRulesService.AppliedRuleJob {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the PackageRuleSync class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the AppliedRuleJob type)
        * @param    jobFinalizer	    DESCRIPTION (Data Type JobFinalizer, JobFinalizer instance for the AppliedRuleJob type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public PackageRuleSync(MA_DS_AppliedRulesService.JobParams jobParams, MA_DS_AppliedRulesService.JobFinalizer jobFinalizer) {
            super(jobParams, jobFinalizer);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to find eligible Acquisition Contacts for upserting Package Distribution type Applied Rules.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void execute(QueueableContext qContext) {
            //System.debug('PackageRuleSync jobParams : ' + JSON.serialize(jobParams));
            MA_DS_AppliedRulesWrapper.PackageAppliedRuleParams jobParams = (MA_DS_AppliedRulesWrapper.PackageAppliedRuleParams)this.jobParams;
            Integer currentQuerySize = 0;
            Id asyncApexJobId = qContext.getJobId();

            for(Integer currentQueryCount=1; currentQueryCount <= jobParams.maxQueryCount; currentQueryCount++) {
                List<Id> acqContactIds = MA_DS_PackageAppliedRuleSyncUtility.getEligibleAcquisitionContactIds(jobParams.rulesQueryWrapper, jobParams.lastRecordId, jobParams.querySizeLimit);
                currentQuerySize = acqContactIds.size();

                List<MA_DS_Applied_Rule__c> appliedRules = MA_DS_PackageAppliedRuleSyncUtility.getAppliedRules(jobParams.pkgDistributionId, acqContactIds, asyncApexJobId);
                MA_DS_PackageAppliedRuleSyncUtility.bulkUpsertAppliedRules(appliedRules);
                
                jobParams.lastRecordId = (currentQuerySize > 0) ? acqContactIds[currentQuerySize - 1] : jobParams.lastRecordId;

                if(currentQuerySize < jobParams.querySizeLimit) {
                    break;
                }
            }
            
            jobParams.asyncApexJobIds.add(asyncApexJobId);
            this.invokeJobFinalizer(currentQuerySize, jobParams.querySizeLimit);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to invoke JobFinalizer action to handle Single Job / Final Job completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    currentQuerySize    DESCRIPTION (Data type Integer, Last Query Size of the Acquisition Contacts retrieved based on Rules Criteria Query & querySizeLimit)
        * @param    querySizeLimit      DESCRIPTION (Data type Integer, Maximum number of records allowed to fetch in a single query for the PackageRuleSync job)
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
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of MA_DS_AppliedRulesService.AppliedRuleJobFinalizer to provide JobFinalizer implementation for PackageRuleSync Queueable job.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class PackageRuleSyncFinalizer extends MA_DS_AppliedRulesService.AppliedRuleJobFinalizer {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the PackageRuleSyncFinalizer class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the AppliedRuleJobFinalizer type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public PackageRuleSyncFinalizer(MA_DS_AppliedRulesService.JobParams jobParams) {
            super(jobParams);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on each single job completion, initializes PackageRuleSync job & enqueues it.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion() {
            PackageRuleSync appliedRuleJob = new PackageRuleSync(this.jobParams, new PackageRuleSyncFinalizer(this.jobParams));
            MA_DS_AppliedRulesService.execute(appliedRuleJob);
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on final job completion, updates Rules Sync Status, initializes AppliedRuleJob for Templates rules syncing & enqueues it.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleFinalJobCompletion() {
            MA_DS_AppliedRulesWrapper.PackageAppliedRuleParams jobParams = (MA_DS_AppliedRulesWrapper.PackageAppliedRuleParams)this.jobParams;
            MA_DS_PackageAppliedRuleSyncUtility.updateRulesSyncStatusForTemplates(jobParams.pkgDistributionId);
            MA_DS_PackageAppliedRuleSyncUtility.initTemplateAppliedRuleJob(jobParams.originExecMode, jobParams.acqCompanyId, jobParams.pkgId, jobParams.pkgDistributionId, jobParams.asyncApexJobIds);
        }
    }
}