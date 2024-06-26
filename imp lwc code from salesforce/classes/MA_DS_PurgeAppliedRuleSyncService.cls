/**
 * ******************************************** W-12578108 : RULE ENGINE ********************************************
 * 
 * Class to hold MA_DS_AppliedRulesService.AppliedRuleJob implementation to purge Applied Rules.
 * Holds MA_DS_AppliedRulesService.AppliedRuleJobFinalizer implementation to provide actions for single / final job completion.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         21/03/2023      Chakshu Malhotra        W-12578108 - Adds logic to purge Package Distribution & In Use Template type Applied Rules.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_PurgeAppliedRuleSyncService extends MA_DS_AppliedRulesService.AppliedRuleSyncService {
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize the PurgeRuleSync Job with JobParams & JobFinalizer to purge Applied Rules.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	            DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    summaryDocRuleSync	            DESCRIPTION (Data Type Boolean, True if Rules are synced for Manager Summary Document template)
    * @param    packageDocRuleSync	            DESCRIPTION (Data Type Boolean, True if Rules are synced for atleast one Package Document template)
    * @param    originExecJob	                DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionJob, ExecutionJob enum type of the first Job that initiated the Rule Sync process)
    * @param    originExecMode	                DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionMode, ExecutionMode enum type)
    * @param    asyncApexJobIds	                DESCRIPTION (Data Type Set<Id>, AsyncApexJob Ids of the Queueable Jobs that processed the Applied Rules)
    * @param    templateIds	                    DESCRIPTION (Data Type List<Id>, List of referenced Template Ids of the In Use Templates)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void initAppliedRuleJob(Id pkgDistributionId, Boolean summaryDocRuleSync, Boolean packageDocRuleSync, MA_DS_AppliedRulesService.ExecutionJob originExecJob, MA_DS_AppliedRulesService.ExecutionMode originExecMode, Set<Id> asyncApexJobIds, List<Id> templateIds) {
        MA_DS_AppliedRulesService.JobParams jobParams = MA_DS_AppliedRulesServiceUtility.getPurgeAppliedRulesParams(pkgDistributionId, summaryDocRuleSync, packageDocRuleSync, originExecJob, originExecMode, asyncApexJobIds, templateIds);
        MA_DS_AppliedRulesService.JobFinalizer jobFinalizer = new PurgeRuleSyncFinalizer(jobParams);
        this.appliedRuleJob = new PurgeRuleSync(jobParams, jobFinalizer);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to Purge ineligible Applied Rule records, that are no longer valid (due to update in Package Distribution / In Use Template Rules).
    * Recursively self-chains itself to process all unwanted Applied Rule records. 
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class PurgeRuleSync extends MA_DS_AppliedRulesService.AppliedRuleJob {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the PurgeRuleSync class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the AppliedRuleJob type)
        * @param    jobFinalizer	    DESCRIPTION (Data Type JobFinalizer, JobFinalizer instance for the AppliedRuleJob type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public PurgeRuleSync(MA_DS_AppliedRulesService.JobParams jobParams, MA_DS_AppliedRulesService.JobFinalizer jobFinalizer) {
            super(jobParams, jobFinalizer);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to Purge ineligible Applied Rule records, that are no longer valid (due to update in Package Distribution / In Use Template Rules).
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void execute(QueueableContext qContext) {
            MA_DS_AppliedRulesWrapper.PurgeAppliedRuleParams jobParams = (MA_DS_AppliedRulesWrapper.PurgeAppliedRuleParams)this.jobParams;
            //System.debug('PurgeRuleSync jobParams : ' + JSON.serialize(jobParams));
            Integer currentQuerySize = 0;

            for(Integer currentQueryCount=1; currentQueryCount <= jobParams.maxQueryCount; currentQueryCount++) {
                List<MA_DS_Applied_Rule__c> appliedRules = getAppliedRules(jobParams);
                currentQuerySize = appliedRules.size();

                MA_DS_PurgeAppliedRuleSyncUtility.bulkHardDeleteContactTasks(appliedRules);

                if(currentQuerySize < jobParams.querySizeLimit) {
                    break;
                }
            }

            this.invokeJobFinalizer(currentQuerySize, jobParams.querySizeLimit);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the unwanted Applied Rule records of type Package Distribution & In Use Template, to be purged by the AppliedRuleJob.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	                    DESCRIPTION (Data Type JobParams, JobParams instance for the AppliedRuleJob type)
        * @return   List<MA_DS_Applied_Rule__c>     DESCRIPTION (return the Applied Rule record list to be purged by the AppliedRuleJob)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public List<MA_DS_Applied_Rule__c> getAppliedRules(MA_DS_AppliedRulesWrapper.PurgeAppliedRuleParams jobParams) {
            return MA_DS_PurgeAppliedRuleSyncUtility.getAppliedRules(jobParams.pkgDistributionId, jobParams.originExecJob, jobParams.asyncApexJobIds, jobParams.templateIds, jobParams.querySizeLimit);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to invoke JobFinalizer action to handle Single Job / Final Job completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    currentQuerySize    DESCRIPTION (Data type Integer, Last Query Size of the Applied Rule records retrieved for purge process)
        * @param    querySizeLimit      DESCRIPTION (Data type Integer, Maximum number of records allowed to fetch in a single query for the PurgeRuleSync job)
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
    * Sub-class of MA_DS_AppliedRulesService.AppliedRuleJobFinalizer to provide JobFinalizer implementation for PurgeRuleSync Queueable job.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class PurgeRuleSyncFinalizer extends MA_DS_AppliedRulesService.AppliedRuleJobFinalizer {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the PurgeRuleSyncFinalizer class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the AppliedRuleJobFinalizer type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public PurgeRuleSyncFinalizer(MA_DS_AppliedRulesService.JobParams jobParams) {
            super(jobParams);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on each single job completion, initializes PurgeRuleSync job & enqueues it.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion() {
            PurgeRuleSync appliedRuleJob = new PurgeRuleSync(this.jobParams, new PurgeRuleSyncFinalizer(this.jobParams));
            MA_DS_AppliedRulesService.execute(appliedRuleJob);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on final job completion, initializes AppliedRuleJob for updating Rule Applied flags on Package Distribution type Applied Rules & enqueues it.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleFinalJobCompletion() {
            MA_DS_AppliedRulesWrapper.PurgeAppliedRuleParams jobParams = (MA_DS_AppliedRulesWrapper.PurgeAppliedRuleParams)this.jobParams;
            MA_DS_PurgeAppliedRuleSyncUtility.initRuleAppliedJob(jobParams.pkgDistributionId, jobParams.summaryDocRuleSync, jobParams.packageDocRuleSync, jobParams.originExecJob, jobParams.originExecMode);
        }
    }
}