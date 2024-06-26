/**
 * ******************************************** W-12578108 : RULE ENGINE ********************************************
 * 
 * Utility class for AppliedRuleJob & AppliedRuleJobFinalizer implementations within MA_DS_RuleAppliedSyncService.
 * Updates Rule Applied Flags on Package Distribution type Applied Rules.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         21/03/2023      Chakshu Malhotra        W-12578108 - Adds utility methods to update the Rule Applied Flags on Package Distribution type Applied Rules.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_RuleAppliedSyncUtility {

    private static final String AGG_FIELD_DOCUMENT_TYPE_ALIAS = 'documentType';
    private static final String APPLIED_RULE_AGG_FUNC = 'Count(Id) appliedRuleCount';
    private static final String AGG_FIELD_ACQ_CONTACT = 'MA_DS_Acquisition_Contact__c';
    private static final String AGG_FIELD_DOCUMENT_TYPE = 'MA_DS_Template__r.MA_DS_Template_Document_Type__c documentType';
    private static final String GROUP_BY_AGG_FIELDS = 'MA_DS_Acquisition_Contact__c, MA_DS_Template__r.MA_DS_Template_Document_Type__c';

    private static final String PKG_DIST_VAR = 'pkgDistributionId';
    private static final String PKG_DIST_FILTER = 'MA_DS_Package_Distribution__c = :{0}';

    private static final String IUT_RULE_TYPE_VAR = 'iutRuleType';
    private static final String RULE_TYPE_FILTER = ' AND MA_DS_Rule_Type__c = :{0}';

    private static final String LAST_RECORD_ID_VAR = 'lastRecordId';
    private static final String LAST_RECORD_ID_FILTER = ' AND MA_DS_Acquisition_Contact__c > :{0}';

    private static final String COUNT_ID_VAR = 'ruleCount';
    private static final String COUNT_ID_FILTER = 'Count(Id) > :{0}';

    private static final String QUERY_SIZE_LIMIT_VAR = 'querySizeLimit';
    private static final String QUERY_SIZE_LIMIT_FILTER = ' ORDER BY MA_DS_Acquisition_Contact__c ASC LIMIT :{0}';

    private static final String APPLIED_RULE_AGG_QUERY_STRING = 'SELECT {0}, {1}, {2} FROM MA_DS_Applied_Rule__c WHERE {3}';

    private static final String PD_APPLIED_RULE = Label.MA_DS_PD_Type_Applied_Rule;
    private static final String IUT_APPLIED_RULE = Label.MA_DS_IUT_Type_Applied_Rule;

    private static final String RULES_SYNCED_STATUS = Label.MA_DS_Rules_Synced_Status;
    private static final String DOCUMENT_TYPE_PACKAGE = Label.MA_DS_Document_Type_Package;
    private static final String DOCUMENT_TYPE_SUMMARY = Label.MA_DS_Document_Type_Manager_Summary;

    private static final String STATUS_IN_DEFINITION = Label.MA_DS_PD_Status_In_Definition;
    private static final String STATUS_READY_FOR_SUMMARY = Label.MA_DS_PD_Status_Ready_For_Summary;
    private static final String STATUS_SUMMARY_REGEN = Label.MA_DS_PD_Status_Requires_Summary_Regeneration;

    private static final String STATUS_SUMMARY_NOT_REQUIRED = Label.MA_DS_PD_Status_Summary_Not_Required;
    private static final String STATUS_PACKAGE_REGEN = Label.MA_DS_PD_Status_Requires_Package_Regeneration;

    private static final String MESSAGING_CONFIG = Label.MA_DS_Messaging_Config_Rules_Synced;
    private static final String NOTIFICATION_BODY= Label.MA_DS_Rules_Synced_Notification_Body;
    private static final String NOTIFICATION_TITLE = Label.MA_DS_Rules_Synced_Notification_Title;

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the RuleAppliedWrapper instance containing Applied Rule records of type Package Distribution after setting flags for "Package Rule Applied" & "Manager Summary Rule Applied".
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	            DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    lastRecordId                    DESCRIPTION (Data Type Id, Last Record Id of the Acquisition Contact processed in the previous query)
    * @param    querySizeLimit                  DESCRIPTION (Data Type Integer, Maximum number of records allowed to fetch for the AppliedRuleJob)
    * @return   RuleAppliedWrapper              DESCRIPTION (return the RuleAppliedWrapper instance containing Applied Rules with Flags set & lastRecordId)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static RuleAppliedWrapper getRuleAppliedWrapper(Id pkgDistributionId, Id lastRecordId, Integer querySizeLimit) {
        List<AggregateResult> aggregatedAppliedRules = getAggregatedAppliedRules(pkgDistributionId, lastRecordId, querySizeLimit);
        Map<String, MA_DS_Applied_Rule__c> appliedRuleMap = new Map<String, MA_DS_Applied_Rule__c>();
        
        Id acqContactId = null;

        for(AggregateResult aggregatedAppliedRule : aggregatedAppliedRules) {
            acqContactId = (Id)aggregatedAppliedRule.get(AGG_FIELD_ACQ_CONTACT);
            String documentType = (String)aggregatedAppliedRule.get(AGG_FIELD_DOCUMENT_TYPE_ALIAS);
            String concatenatedId = String.valueOf(pkgDistributionId) + String.valueOf(acqContactId);

            MA_DS_Applied_Rule__c appliedRule = appliedRuleMap.containsKey(concatenatedId) ? appliedRuleMap.get(concatenatedId) : new MA_DS_Applied_Rule__c();
            appliedRule.MA_DS_Concatenated_Id__c = concatenatedId;
            
            if(documentType.equalsIgnoreCase(DOCUMENT_TYPE_PACKAGE)) {
                appliedRule.MA_DS_Package_Rule_Applied__c = true;
            }else if(documentType.equalsIgnoreCase(DOCUMENT_TYPE_SUMMARY)) {
                appliedRule.MA_DS_Manager_Summary_Rule_Applied__c = true;
            }

            appliedRuleMap.put(concatenatedId, appliedRule);
        }

        return new RuleAppliedWrapper(acqContactId, appliedRuleMap.values());
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Applied Rule records to set the "Package Rule Applied" & "Manager Summary Rule Applied" flags on Package Distribution type Applied Rules.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	                DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    lastRecordId                        DESCRIPTION (Data Type Id, Last Record Id of the Acquisition Contact processed in the previous query)
    * @param    querySizeLimit	                    DESCRIPTION (Data Type Integer, Maximum number of records that are allowed to fetch in a single query)
    * @return   List<AggregateResult>               DESCRIPTION (return List of Aggregated Applied Rules with applied rule count for each Template Document type)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<AggregateResult> getAggregatedAppliedRules(Id pkgDistributionId, Id lastRecordId, Integer querySizeLimit) {
        String filters = getAppliedRuleQueryFilters(pkgDistributionId, lastRecordId, querySizeLimit);
        String queryString = String.format(APPLIED_RULE_AGG_QUERY_STRING, new String[] {AGG_FIELD_ACQ_CONTACT, AGG_FIELD_DOCUMENT_TYPE, APPLIED_RULE_AGG_FUNC, filters});
        Map<String, Object> bindMap = getAppliedRuleQueryBindMap(pkgDistributionId, lastRecordId, querySizeLimit);
        return getAggregatedAppliedRules(queryString, bindMap);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the Filters string, to be used to form the Applied Rule queryString (to fetch records dynamically using Database.queryWithBinds() method).
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	            DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    lastRecordId                    DESCRIPTION (Data Type Id, Last Record Id of the Acquisition Contact processed in the previous query)
    * @param    querySizeLimit                  DESCRIPTION (Data Type Integer, Maximum number of records allowed to fetch for the AppliedRuleJob)
    * @return   String                          DESCRIPTION (return Filters string, used to form the Applied Rule queryString)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getAppliedRuleQueryFilters(Id pkgDistributionId, Id lastRecordId, Integer querySizeLimit) {
        String filters = String.format(PKG_DIST_FILTER, new String[] {PKG_DIST_VAR});
        filters += String.format(RULE_TYPE_FILTER, new String[] {IUT_RULE_TYPE_VAR});
        filters += (lastRecordId == null) ? '' : String.format(LAST_RECORD_ID_FILTER, new String[] {LAST_RECORD_ID_VAR});
        filters += ' GROUP BY ' + GROUP_BY_AGG_FIELDS;
        filters += ' HAVING ' + String.format(COUNT_ID_FILTER, new String[] {COUNT_ID_VAR});
        filters += String.format(QUERY_SIZE_LIMIT_FILTER, new String[] {QUERY_SIZE_LIMIT_VAR});
        return filters;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the bindMap for the Applied Rule queryString, sets value for all the Bind Variables used in the queryString.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	            DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    lastRecordId                    DESCRIPTION (Data Type Id, Last Record Id of the Acquisition Contact processed in the previous query)
    * @param    querySizeLimit                  DESCRIPTION (Data Type Integer, Maximum number of records allowed to fetch for the AppliedRuleJob)
    * @return   Map<String, Object>             DESCRIPTION (return bindMap for the Applied Rule queryString)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, Object> getAppliedRuleQueryBindMap(Id pkgDistributionId, Id lastRecordId, Integer querySizeLimit) {
        Map<String, Object> bindMap = new Map<String, Object>();
        bindMap.put(PKG_DIST_VAR, pkgDistributionId);
        bindMap.put(IUT_RULE_TYPE_VAR, IUT_APPLIED_RULE);
        bindMap.put(LAST_RECORD_ID_VAR, lastRecordId);
        bindMap.put(COUNT_ID_VAR, 0);
        bindMap.put(QUERY_SIZE_LIMIT_VAR, querySizeLimit);
        return bindMap;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to execute the Database.queryWithBinds() & return the Aggregated List of Applied Rules retrieved by the dynamic query string.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    queryString                         DESCRIPTION (Data Type String, Query String to use in Database.queryWithBinds() method)
    * @param    bindMap                             DESCRIPTION (Data Type Map<String, Object>, bindMap wrapped in the QueryWrapper instance)
    * @return   List<AggregateResult>               DESCRIPTION (return List of Aggregated Applied Rules)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @TestVisible
    private static List<AggregateResult> getAggregatedAppliedRules(String queryString, Map<String, Object> bindMap) {
        List<AggregateResult> aggregatedAppliedRules = new List<AggregateResult>();

        try {
            aggregatedAppliedRules.addAll((List<AggregateResult>)Database.queryWithBinds(queryString, bindMap, AccessLevel.SYSTEM_MODE));
        }catch(QueryException exType) {
            MA_AbstractLogger.logException(exType, MA_DS_RuleAppliedSyncUtility.class.getName());
        }

        return aggregatedAppliedRules;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to bulk upsert Package Distribution type Applied Rule records using MA_DS_Concatenated_Id__c as the external Id.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    appliedRules 	    DESCRIPTION (Data type List<MA_DS_Applied_Rule__c>, List of Package Distribution type Applied Rule records)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void bulkUpsertAppliedRules(List<MA_DS_Applied_Rule__c> appliedRules) {
        Acquisition_Contacts_Trigger_Handler.triggerDisabled = true;
        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = true;
        List<Database.UpsertResult> appliedRuleURList = Database.upsert(appliedRules, MA_DS_Applied_Rule__c.MA_DS_Concatenated_Id__c, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(appliedRuleURList, MA_AbstractLogger.BulkLoggerType.UPSERT_RESULT);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the Rules Sync Status, Status & the Sync state of the Package Distribution to indicate that rules have been synced.
    * Notifies user of the completion of the Rules Syncing process.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	            DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    summaryDocRuleSync	            DESCRIPTION (Data Type Boolean, True if Rules are synced for Manager Summary Document template)
    * @param    packageDocRuleSync	            DESCRIPTION (Data Type Boolean, True if Rules are synced for atleast one Package Document template)
    * @param    originExecJob	                DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionJob, ExecutionJob enum type of the first Job that initiated the Rule Sync process)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updatePackageDistributionAndNotifyUser(Id pkgDistributionId, Boolean summaryDocRuleSync, Boolean packageDocRuleSync, MA_DS_AppliedRulesService.ExecutionJob originExecJob) {
        List<MA_DS_Package_Distribution__c> pkgDistributionList = [SELECT Id, MA_DS_Summary_Required__c, MA_DS_Status__c, MA_DS_Rules_Sync_Status__c, MA_DS_Rules_Criteria_JSON__c, MA_DS_Rules_Criteria_Query__c, 
                                                                   MA_DS_Manager_Summary_Rules_Sync_Date__c, MA_DS_Package_Rules_Sync_Date__c, MA_DS_Manager_Summaries_Prep_Date__c, MA_DS_Package_Prep_Date__c, 
                                                                   MA_DS_Last_Synced_Criteria_Query__c, MA_DS_Last_Synced_Rules_Criteria_JSON__c 
                                                                   FROM MA_DS_Package_Distribution__c
                                                                   WHERE Id = :pkgDistributionId LIMIT 1];
        if(pkgDistributionList.size() > 0) {
            MA_DS_Package_Distribution__c pkgDistribution = pkgDistributionList[0];
            pkgDistribution.MA_DS_Rules_Sync_Status__c = RULES_SYNCED_STATUS;

            saveRuleSyncStateIfNeeded(pkgDistribution, originExecJob);
            updateRuleSyncDatesIfNeeded(pkgDistribution, summaryDocRuleSync, packageDocRuleSync);
            updateStatusIfNeeded(pkgDistribution, summaryDocRuleSync, packageDocRuleSync);

            MA_DS_PackageDistributionTriggerHandler.triggerDisabled = true;
            List<Database.SaveResult> pkgDistSRList = Database.update(pkgDistributionList, false);
            MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(pkgDistSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);

            notifyTarget(pkgDistribution);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to store the Sync state of the Package Distribution, to be used during auto application of Rules (on update of Acq Contact & Compensation records).
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	            DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    originExecJob	                DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionJob, ExecutionJob enum type of the first Job that initiated the Rule Sync process)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void saveRuleSyncStateIfNeeded(MA_DS_Package_Distribution__c pkgDistribution, MA_DS_AppliedRulesService.ExecutionJob originExecJob) {
        Boolean packageOriginJob = (originExecJob == MA_DS_AppliedRulesService.ExecutionJob.PACKAGE_RULE_SYNC);
        pkgDistribution.MA_DS_Last_Synced_Criteria_Query__c = packageOriginJob ? pkgDistribution.MA_DS_Rules_Criteria_Query__c : pkgDistribution.MA_DS_Last_Synced_Criteria_Query__c;
        pkgDistribution.MA_DS_Last_Synced_Rules_Criteria_JSON__c = packageOriginJob ? pkgDistribution.MA_DS_Rules_Criteria_JSON__c : pkgDistribution.MA_DS_Last_Synced_Rules_Criteria_JSON__c;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the Rules Sync Status on the Package Distribution to indicate that rules have been synced.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	            DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    summaryDocRuleSync	            DESCRIPTION (Data Type Boolean, True if Rules are synced for Manager Summary Document template)
    * @param    packageDocRuleSync	            DESCRIPTION (Data Type Boolean, True if Rules are synced for atleast one Package Document template)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateRuleSyncDatesIfNeeded(MA_DS_Package_Distribution__c pkgDistribution, Boolean summaryDocRuleSync, Boolean packageDocRuleSync) {
        pkgDistribution.MA_DS_Package_Rules_Sync_Date__c = packageDocRuleSync ? Datetime.now() : pkgDistribution.MA_DS_Package_Rules_Sync_Date__c;
        pkgDistribution.MA_DS_Manager_Summary_Rules_Sync_Date__c = summaryDocRuleSync ? Datetime.now() : pkgDistribution.MA_DS_Manager_Summary_Rules_Sync_Date__c;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the Package Distribution status based on its current status and whether it is in Manager Summary Distribution lifecycle or Package Distribution lifecycle.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	            DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    summaryDocRuleSync	            DESCRIPTION (Data Type Boolean, True if Rules are synced for Manager Summary Document template)
    * @param    packageDocRuleSync	            DESCRIPTION (Data Type Boolean, True if Rules are synced for atleast one Package Document template)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateStatusIfNeeded(MA_DS_Package_Distribution__c pkgDistribution, Boolean summaryDocRuleSync, Boolean packageDocRuleSync) {
        if(summaryDocRuleSync) {
            updateSummaryLifecycleStatusIfNeeded(pkgDistribution);
        }else if(packageDocRuleSync) {
            updatePackageLifecycleStatusIfNeeded(pkgDistribution);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the Package Distribution Status when it is in Manager Summary Distribution lifecycle.
    * Resets "Regen Offer Communicator Ids" field, to set Summary Prep / Regen for all.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistribution	            DESCRIPTION (Data Type MA_DS_Package_Distribution__c, Package Distribution record)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateSummaryLifecycleStatusIfNeeded(MA_DS_Package_Distribution__c pkgDistribution) {
        String status = pkgDistribution.MA_DS_Status__c;
        Datetime summaryPrepDate = pkgDistribution.MA_DS_Manager_Summaries_Prep_Date__c;
        pkgDistribution.MA_DS_Status__c = status.equalsIgnoreCase(STATUS_IN_DEFINITION) ? STATUS_READY_FOR_SUMMARY : (summaryPrepDate != null) ? STATUS_SUMMARY_REGEN : status;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the Package Distribution status when it is in Package Distribution lifecycle.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistribution	            DESCRIPTION (Data Type MA_DS_Package_Distribution__c, Package Distribution record)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updatePackageLifecycleStatusIfNeeded(MA_DS_Package_Distribution__c pkgDistribution) {
        String status = pkgDistribution.MA_DS_Status__c;
        Datetime packagePrepDate = pkgDistribution.MA_DS_Package_Prep_Date__c;
        pkgDistribution.MA_DS_Status__c = (packagePrepDate == null && !pkgDistribution.MA_DS_Summary_Required__c) ? STATUS_SUMMARY_NOT_REQUIRED : (packagePrepDate != null) ? STATUS_PACKAGE_REGEN : status;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to notify user of the completion of the Rules Syncing process.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistribution	            DESCRIPTION (Data Type MA_DS_Package_Distribution__c, Package Distribution record)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void notifyTarget(MA_DS_Package_Distribution__c pkgDistribution) {
        Set<String> userIds = new Set<String> {String.valueOf(UserInfo.getUserId())};
        String notificationBody = String.format(NOTIFICATION_BODY, new String[] {pkgDistribution.MA_DS_Rules_Sync_Status__c, pkgDistribution.MA_DS_Status__c});
        MA_MessageProcessing.initNotificationMessaging(MESSAGING_CONFIG, NOTIFICATION_TITLE, notificationBody, String.valueOf(pkgDistribution.Id), userIds, MA_Messaging.NotificationTargetType.RECORD_ID_TYPE);
        MA_MessageProcessing.processMessages(MA_MessageProcessing.ExecutionType.NOTIFICATION_JOB);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold Applied Rules with flags set for "Package Rule Applied" & "Manager Summary Rule Applied" and the lastRecordId (Acquisition Contact Id) processed.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class RuleAppliedWrapper {
        public Id lastRecordId {get; private set;}
        public List<MA_DS_Applied_Rule__c> appliedRules {get; private set;}

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the RuleAppliedWrapper class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    lastRecordId	        DESCRIPTION (Data Type Id, Last Acquisition Contact Id processed in the Aggregated List of Applied Rules)
        * @param    appliedRules	        DESCRIPTION (Data Type List<MA_DS_Applied_Rule__c>, List of Package Distribution type Applied Rules with flags set)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public RuleAppliedWrapper(Id lastRecordId, List<MA_DS_Applied_Rule__c> appliedRules) {
            this.lastRecordId = lastRecordId;
            this.appliedRules = appliedRules ?? new List<MA_DS_Applied_Rule__c>();
        }
    }
}