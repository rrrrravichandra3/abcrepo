/**
 * W-12578116
 * Utility class for SummaryPrepJob & SummaryPrepJobFinalizer implementations within MA_DS_OfferCommunicatorsPrepService.
 * Processes Aggregated Applied Rule records to identify Offer Communicators that need to be processed for Manager Summary Prep API callout.
 * 
 * Version      Date            Author                  Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         28/03/2023      Chakshu Malhotra        W-12578116 - Provides utility methods to process Aggregated Applied Rule records to identify Offer Communicators, for Manager Summary Prep API callout.
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_OfferCommunicatorsPrepUtility {

    private static final String IUT_TYPE_APPLIED_RULE = Label.MA_DS_IUT_Type_Applied_Rule;
    private static final String IUT_DOCUMENT_TYPE_SUMMARY = Label.MA_DS_Document_Type_Manager_Summary;
    
    private static final String AGG_FUNCTION_COUNT = 'Count(Id)';
    private static final String AGG_FIELD_OFFER_COMMUNICATOR_ALIAS = 'offerCommunicator';
    private static final String AGG_FIELD_OFFER_COMMUNICATOR = 'MA_DS_Acquisition_Contact__r.Offer_Communicator__c';

    private static final String RULE_TYPE_VAR = 'ruleType';
    private static final String RULE_TYPE_FILTER = 'MA_DS_Rule_Type__c = :{0}';

    private static final String DOC_TYPE_VAR = 'docType';
    private static final String DOC_TYPE_FILTER = ' AND MA_DS_Template__r.MA_DS_Template_Document_Type__c = :{0}';

    private static final String OFFER_COMMUNICATOR_VAR = 'offerComm';
    private static final String OFFER_COMMUNICATOR_FILTER = ' AND MA_DS_Acquisition_Contact__r.Offer_Communicator__c != :{0}';

    private static final String NO_OFFER_VAR = 'noOffer';
    private static final String NO_OFFER_FILTER = ' AND MA_DS_Acquisition_Contact__r.MA_DS_No_Offer__c = :{0}';

    private static final String OFFER_DECLINED_VAR = 'offerDeclined';
    private static final String OFFER_DECLINED_FILTER = ' AND MA_DS_Acquisition_Contact__r.MA_DS_Offer_Declined__c = :{0}';

    private static final String PKG_DISTRIBUTION_IDS_VAR = 'pkgDistributionIds';
    private static final String PKG_DISTRIBUTION_IDS_FILTER = ' AND MA_DS_Package_Distribution__c IN :{0}';

    private static final String NEED_GENERATE_VAR = 'needGenerate';
    private static final String NEED_GENERATE_FILTER = ' AND MA_DS_Need_To_Generate__c = :{0}';

    private static final String COMMON_IDS_VAR = 'commonIds';
    private static final String COMMON_IDS_FILTER = ' AND MA_DS_Acquisition_Contact__r.MA_DS_Manager_Summary_Common_Id__c IN :{0}';

    private static final String LAST_RECORD_ID_VAR = 'lastRecordId';
    private static final String LAST_RECORD_ID_FILTER = ' AND MA_DS_Acquisition_Contact__r.Offer_Communicator__c  > :{0}';

    private static final String COUNT_ID_VAR = 'appliedRuleCount';
    private static final String COUNT_ID_FILTER = 'Count(Id) > :{0}';

    private static final String QUERY_SIZE_LIMIT_VAR = 'querySizeLimit';
    private static final String QUERY_SIZE_LIMIT_FILTER = ' ORDER BY MA_DS_Acquisition_Contact__r.Offer_Communicator__c ASC LIMIT :{0}';

    private static final String APPLIED_RULE_AGG_QUERY_STR = 'SELECT {0} {1}, {2} FROM MA_DS_Applied_Rule__c WHERE {3}';

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the List of Offer Communicator Ids eligible to be processed for Manager Summary Prep API callout.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    isAuditFailedRegen	            DESCRIPTION (Data Type Boolean, True if executionOriginType is MA_DS_ManagerSummaryPrepService.ExecutionOrigin.AUDIT_FAILED_REGEN)
    * @param    auditFailedCommonIds	        DESCRIPTION (Data Type Set<String>, Set of Common Ids to be processed for Manager Summary Prep or Regeneration when ExecutionOrigin is AUDIT_FAILED_REGEN)
    * @param    summaryPrepPDIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to process them for Manager Summary Prep or Regeneration)
    * @param    lastRecordId                    DESCRIPTION (Data Type Id, Last Record Id of the Offer Communicator processed in the previous query)
    * @param    querySizeLimit                  DESCRIPTION (Data Type Integer, Maximum number of records allowed to fetch for the SummaryPrepJob)
    * @return   List<String>                    DESCRIPTION (return List of Offer Communicator Ids)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<String> getSummaryPrepOfferCommunicatorIds(Boolean isAuditFailedRegen, Set<String> auditFailedCommonIds, Set<Id> summaryPrepPDIds, Id lastRecordId, Integer querySizeLimit) {
        List<String> offerCommunicatorIds = new List<String>();
        for(AggregateResult aggAppliedRule : getAggregatedAppliedRules(isAuditFailedRegen, auditFailedCommonIds, summaryPrepPDIds, lastRecordId, querySizeLimit)) {
            Id offerCommunicatorId = (Id)aggAppliedRule.get(AGG_FIELD_OFFER_COMMUNICATOR_ALIAS);
            offerCommunicatorIds.add(String.valueOf(offerCommunicatorId));
        }
        return offerCommunicatorIds;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the List of Aggregated Applied Rules to extract the Offer Communicator Ids, to be processed for Manager Summary Prep API callout.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    isAuditFailedRegen	            DESCRIPTION (Data Type Boolean, True if executionOriginType is MA_DS_ManagerSummaryPrepService.ExecutionOrigin.AUDIT_FAILED_REGEN)
    * @param    auditFailedCommonIds	        DESCRIPTION (Data Type Set<String>, Set of Common Ids to be processed for Manager Summary Prep or Regeneration when ExecutionOrigin is AUDIT_FAILED_REGEN)
    * @param    summaryPrepPDIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to process them for Manager Summary Prep or Regeneration)
    * @param    lastRecordId                    DESCRIPTION (Data Type Id, Last Record Id of the Offer Communicator processed in the previous query)
    * @param    querySizeLimit                  DESCRIPTION (Data Type Integer, Maximum number of records allowed to fetch for the SummaryPrepJob)
    * @return   List<AggregateResult>           DESCRIPTION (return List of Aggregated Applied Rules)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<AggregateResult> getAggregatedAppliedRules(Boolean isAuditFailedRegen, Set<String> auditFailedCommonIds, Set<Id> summaryPrepPDIds, Id lastRecordId, Integer querySizeLimit) {
        String filters = getAggregatedQueryFilters(isAuditFailedRegen, auditFailedCommonIds, lastRecordId);
        String queryString = String.format(APPLIED_RULE_AGG_QUERY_STR, new String[] {AGG_FIELD_OFFER_COMMUNICATOR, AGG_FIELD_OFFER_COMMUNICATOR_ALIAS, AGG_FUNCTION_COUNT, filters});
        Map<String, Object> bindMap = getAggregatedQueryBindMap(auditFailedCommonIds, summaryPrepPDIds, lastRecordId, querySizeLimit);
        return getAggregatedAppliedRules(queryString, bindMap);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the Filters string, to be used to form the Aggregated Offer Communicators queryString (to fetch records dynamically using Database.queryWithBinds() method).
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    isAuditFailedRegen	            DESCRIPTION (Data Type Boolean, True if executionOriginType is MA_DS_ManagerSummaryPrepService.ExecutionOrigin.AUDIT_FAILED_REGEN)
    * @param    auditFailedCommonIds	        DESCRIPTION (Data Type Set<String>, Set of Common Ids to be processed for Manager Summary Prep or Regeneration when ExecutionOrigin is AUDIT_FAILED_REGEN)
    * @param    lastRecordId                    DESCRIPTION (Data Type Id, Last Record Id of the Offer Communicator processed in the previous query)
    * @return   String                          DESCRIPTION (return Filters string, used to form the Aggregated Offer Communicators queryString)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getAggregatedQueryFilters(Boolean isAuditFailedRegen, Set<String> auditFailedCommonIds, Id lastRecordId) {
        String filters = String.format(RULE_TYPE_FILTER, new String[] {RULE_TYPE_VAR});
        filters += String.format(DOC_TYPE_FILTER, new String[] {DOC_TYPE_VAR});
        filters += String.format(OFFER_COMMUNICATOR_FILTER, new String[] {OFFER_COMMUNICATOR_VAR});
        filters += String.format(NO_OFFER_FILTER, new String[] {NO_OFFER_VAR});
        filters += String.format(OFFER_DECLINED_FILTER, new String[] {OFFER_DECLINED_VAR});
        filters += String.format(PKG_DISTRIBUTION_IDS_FILTER, new String[] {PKG_DISTRIBUTION_IDS_VAR});
        filters += isAuditFailedRegen ? '' : String.format(NEED_GENERATE_FILTER, new String[] {NEED_GENERATE_VAR});
        filters += (isAuditFailedRegen && auditFailedCommonIds.size() > 0) ? String.format(COMMON_IDS_FILTER, new String[] {COMMON_IDS_VAR}) : '';
        filters += (lastRecordId == null) ? '' : String.format(LAST_RECORD_ID_FILTER, new String[] {LAST_RECORD_ID_VAR});
        filters += ' GROUP BY ' + AGG_FIELD_OFFER_COMMUNICATOR;
        filters += ' HAVING ' + String.format(COUNT_ID_FILTER, new String[] {COUNT_ID_VAR});
        filters += String.format(QUERY_SIZE_LIMIT_FILTER, new String[] {QUERY_SIZE_LIMIT_VAR});
        return filters;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the bindMap for the Aggregated Offer Communicators queryString, sets value for all the Bind Variables used in the queryString.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    auditFailedCommonIds	        DESCRIPTION (Data Type Set<String>, Set of Common Ids to be processed for Manager Summary Prep or Regeneration when ExecutionOrigin is AUDIT_FAILED_REGEN)
    * @param    summaryPrepPDIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to process them for Manager Summary Prep or Regeneration)
    * @param    lastRecordId                    DESCRIPTION (Data Type Id, Last Record Id of the Offer Communicator processed in the previous query)
    * @param    querySizeLimit                  DESCRIPTION (Data Type Integer, Maximum number of records allowed to fetch for the SummaryPrepJob)
    * @return   Map<String, Object>             DESCRIPTION (return bindMap for the Aggregated Offer Communicators queryString)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, Object> getAggregatedQueryBindMap(Set<String> auditFailedCommonIds, Set<Id> summaryPrepPDIds, Id lastRecordId, Integer querySizeLimit) {
        Map<String, Object> bindMap = new Map<String, Object>();
        bindMap.put(RULE_TYPE_VAR, IUT_TYPE_APPLIED_RULE);
        bindMap.put(DOC_TYPE_VAR, IUT_DOCUMENT_TYPE_SUMMARY);
        bindMap.put(OFFER_COMMUNICATOR_VAR, null);
        bindMap.put(NO_OFFER_VAR, false);
        bindMap.put(OFFER_DECLINED_VAR, false);
        bindMap.put(PKG_DISTRIBUTION_IDS_VAR, summaryPrepPDIds);
        bindMap.put(NEED_GENERATE_VAR, true);
        bindMap.put(COMMON_IDS_VAR, auditFailedCommonIds);
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
    private static List<AggregateResult> getAggregatedAppliedRules(String queryString, Map<String, Object> bindMap) {
        List<AggregateResult> aggAppliedRules = new List<AggregateResult>();

        try {
            aggAppliedRules.addAll((List<AggregateResult>)Database.queryWithBinds(queryString, bindMap, AccessLevel.SYSTEM_MODE));
        }catch(QueryException exType) {
            MA_AbstractLogger.logException(exType, MA_DS_OfferCommunicatorsPrepUtility.class.getName());
        }

        return aggAppliedRules;
    }
}