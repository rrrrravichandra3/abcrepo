/**
 * ******************************************** W-12578108 : RULE ENGINE ********************************************
 * 
 * Utility class for AppliedRuleJob & AppliedRuleJobFinalizer implementations within MA_DS_PurgeAppliedRuleSyncService.
 * Purges unwanted Applied Rules that are no longer valid due to rules syncing process.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         21/03/2023      Chakshu Malhotra        W-12578108 - Adds utility methods to purge Applied Rules.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_PurgeAppliedRuleSyncUtility {

    private static final String PKG_DIST_VAR = 'pkgDistributionId';
    private static final String PKG_DIST_FILTER = 'MA_DS_Package_Distribution__c = :{0}';

    private static final String ASYNC_APEX_JOBS_VAR = 'asyncApexJobIds';
    private static final String ASYNC_APEX_JOBS_FILTER = ' AND MA_DS_Async_Apex_Job_Id__c NOT IN :{0}';

    private static final String PD_RULE_TYPE_VAR = 'pdRuleType';
    private static final String IUT_RULE_TYPE_VAR = 'iutRuleType';
    private static final String RULE_TYPE_FILTER = 'MA_DS_Rule_Type__c = :{0}';
    
    private static final String TEMPLATE_IDS_VAR = 'templateIds';
    private static final String TEMPLATE_IDS_FILTER = ' AND MA_DS_Template__c = :{0}';

    private static final String QUERY_SIZE_LIMIT_VAR = 'querySizeLimit';
    private static final String QUERY_SIZE_LIMIT_FILTER = ' LIMIT :{0}';
    
    private static final String APPLIED_RULE_QUERY_STRING = 'SELECT Id FROM MA_DS_Applied_Rule__c WHERE {0}';

    private static final String PD_APPLIED_RULE = Label.MA_DS_PD_Type_Applied_Rule;
    private static final String IUT_APPLIED_RULE = Label.MA_DS_IUT_Type_Applied_Rule;

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the unwanted Applied Rule records of type Package Distribution & In Use Template, to be purged by the AppliedRuleJob.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	            DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    originExecJob	                DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionJob, ExecutionJob enum type of the first Job that initiated the Rule Sync process)
    * @param    asyncApexJobIds	                DESCRIPTION (Data Type Set<Id>, AsyncApexJob Ids of the Queueable Jobs that processed the Applied Rules)
    * @param    templateIds	                    DESCRIPTION (Data Type List<Id>, List of referenced Template Ids of the In Use Templates)
    * @param    querySizeLimit                  DESCRIPTION (Data Type Integer, Maximum number of records allowed to fetch for the AppliedRuleJob)
    * @return   List<MA_DS_Applied_Rule__c>     DESCRIPTION (return the Applied Rule record list to be purged by the AppliedRuleJob)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<MA_DS_Applied_Rule__c> getAppliedRules(Id pkgDistributionId, MA_DS_AppliedRulesService.ExecutionJob originExecJob, Set<Id> asyncApexJobIds, List<Id> templateIds, Integer querySizeLimit) {
        return invalidForPurge(originExecJob, templateIds) ? new List<MA_DS_Applied_Rule__c>() : getPurgedAppliedRules(pkgDistributionId, originExecJob, asyncApexJobIds, templateIds, querySizeLimit);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check if it is invalid to start the Purge process based on the origin of the AppliedRuleJob & the size of templateIds processed for Template Rule sync process.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    originExecJob	                DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionJob, ExecutionJob enum type of the first Job that initiated the Rule Sync process)
    * @param    templateIds	                    DESCRIPTION (Data Type List<Id>, List of referenced Template Ids of the In Use Templates)
    * @return   Boolean                         DESCRIPTION (return True if it is invalid to start the Purge process)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean invalidForPurge(MA_DS_AppliedRulesService.ExecutionJob originExecJob, List<Id> templateIds) {
        return (originExecJob == MA_DS_AppliedRulesService.ExecutionJob.TEMPLATE_RULE_SYNC) && (templateIds.size() == 0);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get Applied Rule records to be purged by the AppliedRuleJob.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	                DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    originExecJob	                    DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionJob, ExecutionJob enum type of the first Job that initiated the Rule Sync process)
    * @param    asyncApexJobIds	                    DESCRIPTION (Data Type Set<Id>, AsyncApexJob Ids of the Queueable Jobs that processed the Applied Rules)
    * @param    templateIds	                        DESCRIPTION (Data Type List<Id>, List of referenced Template Ids of the In Use Templates)
    * @param    querySizeLimit	                    DESCRIPTION (Data Type Integer, Maximum number of records that are allowed to fetch in a single query)
    * @return   List<MA_DS_Applied_Rule__c>         DESCRIPTION (return Applied Rule records)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<MA_DS_Applied_Rule__c> getPurgedAppliedRules(Id pkgDistributionId, MA_DS_AppliedRulesService.ExecutionJob originExecJob, Set<Id> asyncApexJobIds, List<Id> templateIds, Integer querySizeLimit) {
        String filters = getAppliedRuleQueryFilters(originExecJob, asyncApexJobIds, templateIds);
        String queryString = String.format(APPLIED_RULE_QUERY_STRING, new String[] {filters});
        Map<String, Object> bindMap = getAppliedRuleQueryBindMap(pkgDistributionId, asyncApexJobIds, templateIds, querySizeLimit);
        return getPurgedAppliedRules(queryString, bindMap);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the Filters string, to be used to form the Applied Rule queryString (to fetch records dynamically using Database.queryWithBinds() method).
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    originExecJob	                    DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionJob, ExecutionJob enum type of the first Job that initiated the Rule Sync process)
    * @param    asyncApexJobIds	                    DESCRIPTION (Data Type Set<Id>, AsyncApexJob Ids of the Queueable Jobs that processed the Applied Rules)
    * @param    templateIds	                        DESCRIPTION (Data Type List<Id>, List of referenced Template Ids of the In Use Templates)
    * @return   String                              DESCRIPTION (return Filters string, used to form the Applied Rule queryString)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getAppliedRuleQueryFilters(MA_DS_AppliedRulesService.ExecutionJob originExecJob, Set<Id> asyncApexJobIds, List<Id> templateIds) {
        String filterString = String.format(PKG_DIST_FILTER, new String[] {PKG_DIST_VAR});
        filterString +=  (asyncApexJobIds.size() > 0) ? String.format(ASYNC_APEX_JOBS_FILTER, new String[] {ASYNC_APEX_JOBS_VAR}) : '';
        filterString += ' AND ' + ((originExecJob == MA_DS_AppliedRulesService.ExecutionJob.TEMPLATE_RULE_SYNC) ? '' : '(');
        filterString += (originExecJob == MA_DS_AppliedRulesService.ExecutionJob.TEMPLATE_RULE_SYNC) ? getQueryFiltersForJobOriginTemplateRuleSync(templateIds) : getQueryFiltersForJobOriginPackageRuleSync(templateIds);
        filterString += (originExecJob == MA_DS_AppliedRulesService.ExecutionJob.TEMPLATE_RULE_SYNC) ? '' : ')';
        filterString += String.format(QUERY_SIZE_LIMIT_FILTER, new String[] {QUERY_SIZE_LIMIT_VAR});
        return filterString;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the sub-string of the Filters if origin of the ExecutionJob is MA_DS_AppliedRulesService.ExecutionJob.TEMPLATE_RULE_SYNC.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    templateIds	                        DESCRIPTION (Data Type List<Id>, List of referenced Template Ids of the In Use Templates)
    * @return   String                              DESCRIPTION (return Filters string, used to form the Applied Rule queryString)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getQueryFiltersForJobOriginTemplateRuleSync(List<Id> templateIds) {
        String filterString = '(';
        filterString += String.format(RULE_TYPE_FILTER, new String[] {IUT_RULE_TYPE_VAR});
        filterString += (templateIds.size() > 0) ? String.format(TEMPLATE_IDS_FILTER, new String[] {TEMPLATE_IDS_VAR}) : '';
        filterString += ')';
        return filterString;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the sub-string of the Filters if origin of the ExecutionJob is MA_DS_AppliedRulesService.ExecutionJob.PACKAGE_RULE_SYNC.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    templateIds	                        DESCRIPTION (Data Type List<Id>, List of referenced Template Ids of the In Use Templates)
    * @return   String                              DESCRIPTION (return Filters string, used to form the Applied Rule queryString)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getQueryFiltersForJobOriginPackageRuleSync(List<Id> templateIds) {
        String filterString = '(';
        filterString += String.format(RULE_TYPE_FILTER, new String[] {PD_RULE_TYPE_VAR});
        filterString += ') OR ' + getQueryFiltersForJobOriginTemplateRuleSync(templateIds);
        return filterString;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the bindMap for the Applied Rule queryString, sets value for all the Bind Variables used in the queryString.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	                DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    asyncApexJobIds	                    DESCRIPTION (Data Type Set<Id>, AsyncApexJob Ids of the Queueable Jobs that processed the Applied Rules)
    * @param    templateIds	                        DESCRIPTION (Data Type List<Id>, List of referenced Template Ids of the In Use Templates)
    * @param    querySizeLimit	                    DESCRIPTION (Data Type Integer, Maximum number of records that are allowed to fetch in a single query)
    * @return   Map<String, Object>                 DESCRIPTION (return bindMap for the Applied Rule queryString)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, Object> getAppliedRuleQueryBindMap(Id pkgDistributionId, Set<Id> asyncApexJobIds, List<Id> templateIds, Integer querySizeLimit) {
        Map<String, Object> bindMap = new Map<String, Object>();
        bindMap.put(PD_RULE_TYPE_VAR, PD_APPLIED_RULE);
        bindMap.put(IUT_RULE_TYPE_VAR, IUT_APPLIED_RULE);
        bindMap.put(PKG_DIST_VAR, pkgDistributionId);
        bindMap.put(ASYNC_APEX_JOBS_VAR, asyncApexJobIds);
        bindMap.put(TEMPLATE_IDS_VAR, templateIds);
        bindMap.put(QUERY_SIZE_LIMIT_VAR, querySizeLimit);
        return bindMap;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to execute the Database.queryWithBinds() & return the Applied Rules retrieved by the dynamic query string.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    queryString                         DESCRIPTION (Data Type String, Query String to use in Database.queryWithBinds() method)
    * @param    bindMap                             DESCRIPTION (Data Type Map<String, Object>, bindMap wrapped in the QueryWrapper instance)
    * @return   List<MA_DS_Applied_Rule__c>         DESCRIPTION (return Package Distribution type Applied Rule records)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @TestVisible
    private static List<MA_DS_Applied_Rule__c> getPurgedAppliedRules(String queryString, Map<String, Object> bindMap) {
        List<MA_DS_Applied_Rule__c> appliedRules = new List<MA_DS_Applied_Rule__c>();

        try {
            appliedRules.addAll((List<MA_DS_Applied_Rule__c>)Database.queryWithBinds(queryString, bindMap, AccessLevel.SYSTEM_MODE));
        }catch(QueryException exType) {
            MA_AbstractLogger.logException(exType, MA_DS_PurgeAppliedRuleSyncUtility.class.getName());
        }

        return appliedRules;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to hard delete list of unwanted Applied Rule records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    appliedRules    DESCRIPTION (Data type List<MA_DS_Applied_Rule__c>, List of Applied Rule records)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void bulkHardDeleteContactTasks(List<MA_DS_Applied_Rule__c> appliedRules) {
        Acquisition_Contacts_Trigger_Handler.triggerDisabled = true;
        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = true;
        List<Database.DeleteResult> appliedRuleDRList = Database.delete(appliedRules, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(appliedRuleDRList, MA_AbstractLogger.BulkLoggerType.DELETE_RESULT);

        if(appliedRuleDRList.size() > 0) {
            DataBase.emptyRecycleBin(appliedRules);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize & enqueue the AppliedRuleJob to update the Rule Applied flags on Package Distribution type Applied Rules.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	                DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    summaryDocRuleSync	                DESCRIPTION (Data Type Boolean, True if Rules are synced for Manager Summary Document template)
    * @param    packageDocRuleSync	                DESCRIPTION (Data Type Boolean, True if Rules are synced for atleast one Package Document template)
    * @param    originExecJob	                    DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionJob, ExecutionJob enum type of the first Job that initiated the Rule Sync process)
    * @param    originExecMode	                    DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionMode, ExecutionMode enum type)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void initRuleAppliedJob(Id pkgDistributionId, Boolean summaryDocRuleSync, Boolean packageDocRuleSync, MA_DS_AppliedRulesService.ExecutionJob originExecJob, MA_DS_AppliedRulesService.ExecutionMode originExecMode) {
        MA_DS_AppliedRulesService.strategyInstance.setExecutionModeEnum(originExecMode)
                                                  .setExecutionJobEnum(MA_DS_AppliedRulesService.ExecutionJob.RULE_APPLIED_SYNC)
                                                  .setOriginExecutionJobEnum(originExecJob)
                                                  .setPackageDistributionId(pkgDistributionId)
                                                  .setSummaryDocRuleSync(summaryDocRuleSync)
                                                  .setPackageDocRuleSync(packageDocRuleSync)
                                                  .initAppliedRuleJob()
                                                  .execute();
    }
}