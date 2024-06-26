/**
 * W-13484430 & W-13576017
 * Utility class for PackageStatusHandlerJob & PackageStatusHandlerJobFinalizer implementations within MA_DS_PackageStatusHandlerService.PackageStatusHandlerService.
 * Helps with post-processing logic of Package Distribution Status update.
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         24/06/2023      Chakshu Malhotra        W-13484430 & W-13576017 - Provides utility methods that helps with post-processing logic of Package Distribution Status update.
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_PackageStatusHandlerUtility {

    private static final String IUT_TYPE_APPLIED_RULE = Label.MA_DS_IUT_Type_Applied_Rule;
    private static final String IUT_DOCUMENT_TYPE_PACKAGE = Label.MA_DS_Document_Type_Package;

    private static final String RULE_TYPE_VAR = 'ruleType';
    private static final String RULE_TYPE_FILTER = 'MA_DS_Rule_Type__c = :{0}';

    private static final String DOC_TYPE_VAR = 'docType';
    private static final String DOC_TYPE_FILTER = ' AND MA_DS_Template__r.MA_DS_Template_Document_Type__c = :{0}';

    private static final String NO_OFFER_VAR = 'noOffer';
    private static final String NO_OFFER_FILTER = ' AND MA_DS_Acquisition_Contact__r.MA_DS_No_Offer__c = :{0}';

    private static final String OFFER_DECLINED_VAR = 'offerDeclined';
    private static final String OFFER_DECLINED_FILTER = ' AND MA_DS_Acquisition_Contact__r.MA_DS_Offer_Declined__c = :{0}';

    private static final String PKG_DISTRIBUTION_IDS_VAR = 'pkgDistributionIds';
    private static final String PKG_DISTRIBUTION_IDS_FILTER = ' AND MA_DS_Package_Distribution__c IN :{0}';

    private static final String LAST_RECORD_ID_VAR = 'lastRecordId';
    private static final String LAST_RECORD_ID_FILTER = ' AND Id > :{0}';

    private static final String QUERY_SIZE_LIMIT_VAR = 'querySizeLimit';
    private static final String QUERY_SIZE_LIMIT_FILTER = ' ORDER BY Id ASC LIMIT :{0}';

    private static final String APPLIED_RULE_QUERY_STR = 'SELECT {0} FROM MA_DS_Applied_Rule__c WHERE {1}';

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the List of Query fields for the Applied Rules query.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<String> appliedRuleQueryFields {
        get {
            if(appliedRuleQueryFields == null) {
                appliedRuleQueryFields = new List<String> {'Id', 'MA_DS_Need_To_Generate__c', 'MA_DS_Need_To_Deliver__c'};
            }
            return appliedRuleQueryFields;
        }set;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the List of Applied Rules to mark them as "Need To Generate" or "Need To Delivery", to handle post-processing logic for Package Distribution Status update.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to identify the Applied Rule records to mark them as "Need To Generate" or "Need To Delivery")
    * @param    lastRecordId                    DESCRIPTION (Data Type Id, Last Record Id of the Applied Rule processed in the previous query)
    * @param    querySizeLimit                  DESCRIPTION (Data Type Integer, Maximum number of records allowed to fetch for the PackageStatusHandlerJob)
    * @return   List<MA_DS_Applied_Rule__c>     DESCRIPTION (return List of Applied Rules)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<MA_DS_Applied_Rule__c> getAppliedRules(Set<Id> pkgDistributionIds, Id lastRecordId, Integer querySizeLimit) {
        String filters = getAppliedRulesQueryFilters(lastRecordId);
        String queryString = String.format(APPLIED_RULE_QUERY_STR, new String[] {String.join(appliedRuleQueryFields, ', '), filters});
        Map<String, Object> bindMap = getAppliedRulesQueryBindMap(pkgDistributionIds, lastRecordId, querySizeLimit);
        return getAppliedRules(queryString, bindMap);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the Filters string, to be used to form the Applied Rules queryString (to fetch records dynamically using Database.queryWithBinds() method).
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    lastRecordId                    DESCRIPTION (Data Type Id, Last Record Id of the Applied Rule processed in the previous query)
    * @return   String                          DESCRIPTION (return Filters string, used to form the Applied Rules queryString)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getAppliedRulesQueryFilters(Id lastRecordId) {
        String filters = String.format(RULE_TYPE_FILTER, new String[] {RULE_TYPE_VAR});
        filters += String.format(DOC_TYPE_FILTER, new String[] {DOC_TYPE_VAR});
        filters += String.format(NO_OFFER_FILTER, new String[] {NO_OFFER_VAR});
        filters += String.format(OFFER_DECLINED_FILTER, new String[] {OFFER_DECLINED_VAR});
        filters += String.format(PKG_DISTRIBUTION_IDS_FILTER, new String[] {PKG_DISTRIBUTION_IDS_VAR});
        filters += (lastRecordId == null) ? '' : String.format(LAST_RECORD_ID_FILTER, new String[] {LAST_RECORD_ID_VAR});
        filters += String.format(QUERY_SIZE_LIMIT_FILTER, new String[] {QUERY_SIZE_LIMIT_VAR});
        return filters;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the bindMap for the Applied Rules queryString, sets value for all the Bind Variables used in the queryString.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to identify the Applied Rule records to mark them as "Need To Generate" or "Need To Delivery")
    * @param    lastRecordId                    DESCRIPTION (Data Type Id, Last Record Id of the Applied Rule processed in the previous query)
    * @param    querySizeLimit                  DESCRIPTION (Data Type Integer, Maximum number of records allowed to fetch for the PackageStatusHandlerJob)
    * @return   Map<String, Object>             DESCRIPTION (return bindMap for the Applied Rules queryString)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, Object> getAppliedRulesQueryBindMap(Set<Id> pkgDistributionIds, Id lastRecordId, Integer querySizeLimit) {
        Map<String, Object> bindMap = new Map<String, Object>();
        bindMap.put(RULE_TYPE_VAR, IUT_TYPE_APPLIED_RULE);
        bindMap.put(DOC_TYPE_VAR, IUT_DOCUMENT_TYPE_PACKAGE);
        bindMap.put(NO_OFFER_VAR, false);
        bindMap.put(OFFER_DECLINED_VAR, false);
        bindMap.put(PKG_DISTRIBUTION_IDS_VAR, pkgDistributionIds);
        bindMap.put(LAST_RECORD_ID_VAR, lastRecordId);
        bindMap.put(QUERY_SIZE_LIMIT_VAR, querySizeLimit);
        return bindMap;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to execute the Database.queryWithBinds() & return the List of Applied Rules retrieved by the dynamic query string.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    queryString                         DESCRIPTION (Data Type String, Query String to use in Database.queryWithBinds() method)
    * @param    bindMap                             DESCRIPTION (Data Type Map<String, Object>, bindMap wrapped in the QueryWrapper instance)
    * @return   List<MA_DS_Applied_Rule__c>         DESCRIPTION (return List of Applied Rules)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<MA_DS_Applied_Rule__c> getAppliedRules(String queryString, Map<String, Object> bindMap) {
        List<MA_DS_Applied_Rule__c> appliedRules = new List<MA_DS_Applied_Rule__c>();

        try {
            appliedRules.addAll((List<MA_DS_Applied_Rule__c>)Database.queryWithBinds(queryString, bindMap, AccessLevel.SYSTEM_MODE));
        }catch(QueryException exType) {
            MA_AbstractLogger.logException(exType, MA_DS_PackageStatusHandlerUtility.class.getName());
        }

        return appliedRules;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the Applied Rule records to mark them as "Need To Generate" / "Need To Deliver", based on the PackageStatus type.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    appliedRules	                DESCRIPTION (Data Type List<MA_DS_Applied_Rule__c>, List of Applied Rule records)
    * @param    packageStatusType	            DESCRIPTION (Data Type MA_DS_PackageStatusHandlerService.PackageStatus, PackageStatus type for Package Distribution Status)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updateAppliedRules(List<MA_DS_Applied_Rule__c> appliedRules, MA_DS_PackageStatusHandlerService.PackageStatus packageStatusType) {
        for(MA_DS_Applied_Rule__c appliedRule : appliedRules) {
            switch on packageStatusType {
                when RECALLED {
                    appliedRule.MA_DS_Need_To_Generate__c = true;
                    appliedRule.MA_DS_Need_To_Deliver__c = false;
                }
            }
        }

        if(appliedRules.size() > 0) {
            updatePackageAppliedRules(appliedRules);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Package Document IUT type Applied Rules with "Need To Deliver" / "Need To Generate" as true / false.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    appliedRules	            DESCRIPTION (Data Type List<MA_DS_Applied_Rule__c>, List of IUT type Applied Rule records)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updatePackageAppliedRules(List<MA_DS_Applied_Rule__c> appliedRules) {
        Acquisition_Contacts_Trigger_Handler.triggerDisabled = true;
        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = true;
        Database.SaveResult[] appliedRulesSRList = Database.update(appliedRules, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(appliedRulesSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
    }
}