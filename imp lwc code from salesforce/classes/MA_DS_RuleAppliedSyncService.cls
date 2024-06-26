/**
 * ******************************************************* W-12578108 : RULE ENGINE *******************************************************
 * 
 * Class to hold MA_DS_AppliedRulesService.AppliedRuleJob implementation to update Rule Applied Flags on Package Distribution type Applied Rules.
 * Holds MA_DS_AppliedRulesService.AppliedRuleJobFinalizer implementation to provide actions for single / final job completion.
 * 
 * Version      Date            Author                  Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         21/03/2023      Chakshu Malhotra        W-12578108 - Adds logic to purge Package Distributionto update Rule Applied Flags on Package Distribution type Applied Rules.
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_RuleAppliedSyncService extends MA_DS_AppliedRulesService.AppliedRuleSyncService {
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize the RuleAppliedSync Job with JobParams & JobFinalizer to update Rule Applied Flags on Package Distribution type Applied Rules.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	            DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    summaryDocRuleSync	            DESCRIPTION (Data Type Boolean, True if Rules are synced for Manager Summary Document template)
    * @param    packageDocRuleSync	            DESCRIPTION (Data Type Boolean, True if Rules are synced for atleast one Package Document template)
    * @param    originExecJob	                DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionJob, ExecutionJob enum type of the first Job that initiated the Rule Sync process)
    * @param    originExecMode	                DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionMode, ExecutionMode enum type)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void initAppliedRuleJob(Id pkgDistributionId, Boolean summaryDocRuleSync, Boolean packageDocRuleSync, MA_DS_AppliedRulesService.ExecutionJob originExecJob, MA_DS_AppliedRulesService.ExecutionMode originExecMode) {
        MA_DS_AppliedRulesService.JobParams jobParams = MA_DS_AppliedRulesServiceUtility.getRuleAppliedParams(pkgDistributionId, summaryDocRuleSync, packageDocRuleSync, originExecJob, originExecMode);
        MA_DS_AppliedRulesService.JobFinalizer jobFinalizer = new RuleAppliedSyncFinalizer(jobParams);
        this.appliedRuleJob = new RuleAppliedSync(jobParams, jobFinalizer);
    }
    
    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to update Rule Applied Flags on Package Distribution type Applied Rules.
    * Recursively self-chains itself to process all eligible Acquisition Contacts based on the Rules Criteria Query set on the Package Distribution. 
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class RuleAppliedSync extends MA_DS_AppliedRulesService.AppliedRuleJob {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the RuleAppliedSync class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the AppliedRuleJob type)
        * @param    jobFinalizer	    DESCRIPTION (Data Type JobFinalizer, JobFinalizer instance for the AppliedRuleJob type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public RuleAppliedSync(MA_DS_AppliedRulesService.JobParams jobParams, MA_DS_AppliedRulesService.JobFinalizer jobFinalizer) {
            super(jobParams, jobFinalizer);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to to update Rule Applied Flags on Pakcage Distribution type Applied Rules.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void execute(QueueableContext qContext) {
            MA_DS_AppliedRulesWrapper.RuleAppliedParams jobParams = (MA_DS_AppliedRulesWrapper.RuleAppliedParams)this.jobParams;
            //System.debug('PurgeRuleSync jobParams : ' + JSON.serialize(jobParams));
            Integer currentQuerySize = 0;

            for(Integer currentQueryCount=1; currentQueryCount <= jobParams.maxQueryCount; currentQueryCount++) {
                /**
                 * using limit as (jobParams.querySizeLimit * 2) as Grouping of records is based on 2 fields.
                 */
                MA_DS_RuleAppliedSyncUtility.RuleAppliedWrapper wrapperInstance = MA_DS_RuleAppliedSyncUtility.getRuleAppliedWrapper(jobParams.pkgDistributionId, jobParams.lastRecordId, jobParams.querySizeLimit * 2);
                currentQuerySize = wrapperInstance.appliedRules.size();
                
                MA_DS_RuleAppliedSyncUtility.bulkUpsertAppliedRules(wrapperInstance.appliedRules);

                jobParams.lastRecordId = (currentQuerySize > 0) ? wrapperInstance.lastRecordId : jobParams.lastRecordId;

                if(currentQuerySize < jobParams.querySizeLimit) {
                    break;
                }
            }

            this.invokeJobFinalizer(currentQuerySize, jobParams.querySizeLimit);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to invoke JobFinalizer action to handle Single Job / Final Job completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    currentQuerySize    DESCRIPTION (Data type Integer, Last Query Size of the Applied Rule records retrieved for updating Rule Applied flags)
        * @param    querySizeLimit      DESCRIPTION (Data type Integer, Maximum number of records allowed to fetch in a single query for the RuleAppliedSync job)
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
    * Sub-class of MA_DS_AppliedRulesService.AppliedRuleJobFinalizer to provide JobFinalizer implementation for RuleAppliedSync Queueable job.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @TestVisible
    private class RuleAppliedSyncFinalizer extends MA_DS_AppliedRulesService.AppliedRuleJobFinalizer {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the RuleAppliedSyncFinalizer class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the AppliedRuleJobFinalizer type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public RuleAppliedSyncFinalizer(MA_DS_AppliedRulesService.JobParams jobParams) {
            super(jobParams);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on each single job completion, initializes RuleAppliedSync job & enqueues it.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion() {
            RuleAppliedSync appliedRuleJob = new RuleAppliedSync(this.jobParams, new RuleAppliedSyncFinalizer(this.jobParams));
            MA_DS_AppliedRulesService.execute(appliedRuleJob);
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on final job completion, updates the Rules Sync Status, Status & the Sync state of the Package Distribution to indicate that rules have been synced.
        * Notifies user of the completion of the Rules Syncing process.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleFinalJobCompletion() {
            MA_DS_AppliedRulesWrapper.RuleAppliedParams jobParams = (MA_DS_AppliedRulesWrapper.RuleAppliedParams)this.jobParams;
            MA_DS_RuleAppliedSyncUtility.updatePackageDistributionAndNotifyUser(jobParams.pkgDistributionId, jobParams.summaryDocRuleSync, jobParams.packageDocRuleSync, jobParams.originExecJob);
        }
    }
}