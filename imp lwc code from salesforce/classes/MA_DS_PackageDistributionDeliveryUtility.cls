/**
 * W-12578130
 * Utility class for SummaryDeliveryJob & SummaryDeliveryJobFinalizer implementations within MA_DS_PackageDistributionDeliveryService.
 * Processes Aggregated Applied Rule records to identify Offer Communicators that need to be processed for Manager Summary Delivery API callout.
 * 
 * Version      Date            Author                  Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         21/04/2023      Chakshu Malhotra        W-12578130 - Provides utility methods to process Aggregated Applied Rule records to identify Offer Communicators, for Manager Summary Delivery API callout.
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_PackageDistributionDeliveryUtility {

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

    private static final String PKG_DISTRIBUTION_ID_VAR = 'pkgDistributionId';
    private static final String PKG_DISTRIBUTION_ID_FILTER = ' AND MA_DS_Package_Distribution__c = :{0}';

    private static final String NEED_DELIVER_VAR = 'needDeliver';
    private static final String NEED_DELIVER_FILTER = ' AND MA_DS_Need_To_Deliver__c = :{0}';

    private static final String LAST_RECORD_ID_VAR = 'lastRecordId';
    private static final String LAST_RECORD_ID_FILTER = ' AND MA_DS_Acquisition_Contact__r.Offer_Communicator__c  > :{0}';

    private static final String COUNT_ID_VAR = 'appliedRuleCount';
    private static final String COUNT_ID_FILTER = 'Count(Id) > :{0}';

    private static final String QUERY_SIZE_LIMIT_VAR = 'querySizeLimit';
    private static final String QUERY_SIZE_LIMIT_FILTER = ' ORDER BY MA_DS_Acquisition_Contact__r.Offer_Communicator__c ASC LIMIT :{0}';

    private static final String APPLIED_RULE_AGG_QUERY_STR = 'SELECT {0} {1}, {2} FROM MA_DS_Applied_Rule__c WHERE {3}';

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Package Distribution record details, when Scheduled Summary Delivery is initiated from an update on Package Distribution record.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionIds	                    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @return   MA_DS_Package_Distribution__c           DESCRIPTION (return Package Distribution record)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static MA_DS_Package_Distribution__c getScheduledDeliveryPkgDistribution(Set<Id> pkgDistributionIds) {
        return [SELECT Id, CreatedById, MA_DS_Package__r.MA_DS_Acquisition_Company__c 
                FROM MA_DS_Package_Distribution__c 
                WHERE Id IN :pkgDistributionIds LIMIT 1];
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the List of Offer Communicator Ids eligible to be processed for Manager Summary Delivery API callout.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    summaryDeliveryPDId	            DESCRIPTION (Data Type Id, Package Distribution Id to be processed for Manager Summary Delivery)
    * @param    lastRecordId                    DESCRIPTION (Data Type Id, Last Record Id of the Offer Communicator processed in the previous query)
    * @param    querySizeLimit                  DESCRIPTION (Data Type Integer, Maximum number of records allowed to fetch for the SummaryDeliveryJob)
    * @return   List<Id>                        DESCRIPTION (return List of Offer Communicator Ids)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Id> getSummaryDeliveryOfferCommunicatorIds(Id summaryDeliveryPDId, Id lastRecordId, Integer querySizeLimit) {
        List<Id> offerCommunicatorIds = new List<Id>();
        for(AggregateResult aggAppliedRule : getAggregatedAppliedRules(summaryDeliveryPDId, lastRecordId, querySizeLimit)) {
            Id offerCommunicatorId = (Id)aggAppliedRule.get(AGG_FIELD_OFFER_COMMUNICATOR_ALIAS);
            offerCommunicatorIds.add(String.valueOf(offerCommunicatorId));
        }
        return offerCommunicatorIds;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the List of Aggregated Applied Rules to extract the Offer Communicator Ids, to be processed for Manager Summary Delivery API callout.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    summaryDeliveryPDId	            DESCRIPTION (Data Type Id, Package Distribution Id to be processed for Manager Summary Delivery)
    * @param    lastRecordId                    DESCRIPTION (Data Type Id, Last Record Id of the Offer Communicator processed in the previous query)
    * @param    querySizeLimit                  DESCRIPTION (Data Type Integer, Maximum number of records allowed to fetch for the SummaryDeliveryJob)
    * @return   List<AggregateResult>           DESCRIPTION (return List of Aggregated Applied Rules)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<AggregateResult> getAggregatedAppliedRules(Id summaryDeliveryPDId, Id lastRecordId, Integer querySizeLimit) {
        String filters = getAggregatedQueryFilters(lastRecordId);
        String queryString = String.format(APPLIED_RULE_AGG_QUERY_STR, new String[] {AGG_FIELD_OFFER_COMMUNICATOR, AGG_FIELD_OFFER_COMMUNICATOR_ALIAS, AGG_FUNCTION_COUNT, filters});
        Map<String, Object> bindMap = getAggregatedQueryBindMap(summaryDeliveryPDId, lastRecordId, querySizeLimit);
        return getAggregatedAppliedRules(queryString, bindMap);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the Filters string, to be used to form the Aggregated Offer Communicators queryString (to fetch records dynamically using Database.queryWithBinds() method).
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    lastRecordId                    DESCRIPTION (Data Type Id, Last Record Id of the Offer Communicator processed in the previous query)
    * @return   String                          DESCRIPTION (return Filters string, used to form the Aggregated Offer Communicators queryString)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getAggregatedQueryFilters(Id lastRecordId) {
        String filters = String.format(RULE_TYPE_FILTER, new String[] {RULE_TYPE_VAR});
        filters += String.format(DOC_TYPE_FILTER, new String[] {DOC_TYPE_VAR});
        filters += String.format(OFFER_COMMUNICATOR_FILTER, new String[] {OFFER_COMMUNICATOR_VAR});
        filters += String.format(NO_OFFER_FILTER, new String[] {NO_OFFER_VAR});
        filters += String.format(OFFER_DECLINED_FILTER, new String[] {OFFER_DECLINED_VAR});
        filters += String.format(PKG_DISTRIBUTION_ID_FILTER, new String[] {PKG_DISTRIBUTION_ID_VAR});
        filters += String.format(NEED_DELIVER_FILTER, new String[] {NEED_DELIVER_VAR});
        filters += (lastRecordId == null) ? '' : String.format(LAST_RECORD_ID_FILTER, new String[] {LAST_RECORD_ID_VAR});
        filters += ' GROUP BY ' + AGG_FIELD_OFFER_COMMUNICATOR;
        filters += ' HAVING ' + String.format(COUNT_ID_FILTER, new String[] {COUNT_ID_VAR});
        filters += String.format(QUERY_SIZE_LIMIT_FILTER, new String[] {QUERY_SIZE_LIMIT_VAR});
        return filters;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the bindMap for the Aggregated Offer Communicators queryString, sets value for all the Bind Variables used in the queryString.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    summaryDeliveryPDId	            DESCRIPTION (Data Type Id, Package Distribution Id to be processed for Manager Summary Delivery)
    * @param    lastRecordId                    DESCRIPTION (Data Type Id, Last Record Id of the Offer Communicator processed in the previous query)
    * @param    querySizeLimit                  DESCRIPTION (Data Type Integer, Maximum number of records allowed to fetch for the SummaryDeliveryJob)
    * @return   Map<String, Object>             DESCRIPTION (return bindMap for the Aggregated Offer Communicators queryString)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, Object> getAggregatedQueryBindMap(Id summaryDeliveryPDId, Id lastRecordId, Integer querySizeLimit) {
        Map<String, Object> bindMap = new Map<String, Object>();
        bindMap.put(RULE_TYPE_VAR, IUT_TYPE_APPLIED_RULE);
        bindMap.put(DOC_TYPE_VAR, IUT_DOCUMENT_TYPE_SUMMARY);
        bindMap.put(OFFER_COMMUNICATOR_VAR, null);
        bindMap.put(NO_OFFER_VAR, false);
        bindMap.put(OFFER_DECLINED_VAR, false);
        bindMap.put(PKG_DISTRIBUTION_ID_VAR, summaryDeliveryPDId);
        bindMap.put(NEED_DELIVER_VAR, true);
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
            MA_AbstractLogger.logException(exType, MA_DS_PackageDistributionDeliveryUtility.class.getName());
        }

        return aggAppliedRules;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch Acquisition Company record details containing Manager Summary Email Subject & Body, for the given Acquisition Company record Id.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	                    DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @return   List<Acquisition_Company__c>        DESCRIPTION (return List of Acquisition Company records)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Acquisition_Company__c> getAcquisitionCompanyWithSummaryEmail(Id acqCompanyId) {
        return [SELECT Id, MA_DS_Manager_Summary_Email_Subject__c, MA_DS_Manager_Summary_Email_Body__c
                FROM Acquisition_Company__c
                WHERE Id = :acqCompanyId LIMIT 1];
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Map of Package Distribution record Id to the "Custom Manager Summary Email" flag value.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionIds	                DESCRIPTION (Data Type Set<Id>, Set of Package Distribution record Ids)
    * @return   Map<Id, Boolean>                    DESCRIPTION (return Map of Package Distribution Id to "Custom Manager Summary Email" flag)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Map<Id, Boolean> getCustomSummaryEmailMap(Set<Id> pkgDistributionIds) {
        Map<Id, Boolean> customSummaryEmailMap = new Map<Id, Boolean>();

        List<MA_DS_Package_Distribution__c> pkgDistributions = [SELECT Id, MA_DS_Custom_Manager_Summary_Email__c
                                                                FROM MA_DS_Package_Distribution__c
                                                                WHERE Id IN :pkgDistributionIds];

        for(MA_DS_Package_Distribution__c pkgDistribution : pkgDistributions) {
            customSummaryEmailMap.put(pkgDistribution.Id, pkgDistribution.MA_DS_Custom_Manager_Summary_Email__c);
        }

        return customSummaryEmailMap;
    }
}