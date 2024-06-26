/**
 * W-12578130
 * Utility class to help inititate the Manager Summary Delivery process for all eligible / selected Package Distributions records.
 * Also helps initiating the scheduled Manager Summary Delivery process.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         20/04/2023      Chakshu Malhotra        W-12578130 - Adds logic to help inititate the Manager Summary Delivery process for all eligible / selected Package Distributions records.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class MA_DS_ManagerSummariesDeliveryUtility {

    private static final String SUMMARY_DELIVERY_ELIGIBLE_STATUS = Label.MA_DS_Eligible_Status_For_Summary_Delivery;
    private static final String PD_STAGE_READY_FOR_SUMMARY_DELIVERY = Label.MA_DS_PD_Stage_Ready_For_Summary_Delivery;

    private static final String PD_TYPE_APPLIED_RULE = Label.MA_DS_PD_Type_Applied_Rule;
    private static final String IUT_TYPE_APPLIED_RULE = Label.MA_DS_IUT_Type_Applied_Rule;
    private static final String DOCUMENT_TYPE_MANAGER_SUMMARY = Label.MA_DS_Document_Type_Manager_Summary;
    private static final String INTEGRATION_STATUS_SUMMARY_DELIVERY = Label.MA_DS_Integration_Status_Summary_Delivery;

    private static final String AGG_FIELD_RULE_COUNT = 'ruleCount';
    private static final String AGG_FIELD_PKG_DIST_ID = 'pkgDistId';

    private static final String SUMMARY_REQUIRED_VAR = 'summaryRequired';
    private static final String SUMMARY_REQUIRED_FILTER = 'MA_DS_Summary_Required__c = :{0}';

    private static final String PD_STATUS_VAR = 'pdStatus';
    private static final String PD_STATUS_FILTER = ' AND MA_DS_Status__c IN :{0}';

    private static final String PD_STAGE_VAR = 'pdStage';
    private static final String PD_STAGE_FILTER = ' AND MA_DS_Package_Distribution_Stage__c = :{0}';

    private static final String ACQ_COMPANY_ID_VAR = 'acqCompanyId';
    private static final String ACQ_COMPANY_ID_FILTER = ' AND MA_DS_Package__r.MA_DS_Acquisition_Company__c = :{0}';

    private static final String SCHEDULED_DELIVERY_VAR = 'scheduledDelivery';
    private static final String SCHEDULED_DELIVERY_FILTER = ' AND MA_DS_Schedule_Summary_Delivery__c = :{0}';

    private static final String TOTAL_NEED_TO_DELIVER_COUNT_VAR = 'needDeliverCount';
    private static final String TOTAL_NEED_TO_DELIVER_COUNT_FILTER = ' AND MA_DS_Total_In_Need_To_Deliver_Summary__c > :{0}';

    private static final String PD_IDS_VAR = 'pdIds';
    private static final String PD_IDS_FILTER = ' AND Id IN :{0}';

    private static final String PKG_DISTRIBUTION_QUERY_STR = 'SELECT {0} FROM MA_DS_Package_Distribution__c WHERE {1}';
    
    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the List of Query fields for the Package Distributions query.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<String> pkgDistributionQueryFields {
        get {
            if(pkgDistributionQueryFields == null) {
                pkgDistributionQueryFields = new List<String> {'Id', 'Name', 'MA_DS_Status__c', 'MA_DS_Integration_Status__c'};
            }
            return pkgDistributionQueryFields;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the set of status values that makes a Package Distribution eligible for Manager Summary Delivery process.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Set<String> summaryDeliveryEligibleStatusSet {
        get {
            if(summaryDeliveryEligibleStatusSet == null) {
                summaryDeliveryEligibleStatusSet = new Set<String>((List<String>)JSON.deserialize(SUMMARY_DELIVERY_ELIGIBLE_STATUS, List<String>.class));
            }
            return summaryDeliveryEligibleStatusSet;
        }set;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the Package Distribution records, either all (by Acquisition Company record Id) or the Selected Ones on the UI.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    scheduledDelivery                       DESCRIPTION (Data Type Boolean, True if the processed initiated due to scheduled delivery)
    * @param    acqCompanyId                            DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    pkgDistributionIds	                    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @return   List<MA_DS_Package_Distribution__c>     DESCRIPTION (return Package Distribution records for the given Acquisition Company)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<MA_DS_Package_Distribution__c> getPackageDistributions(Boolean scheduledDelivery, Id acqCompanyId, Set<Id> pkgDistributionIds) {
        String filters = getPkgDistributionQueryFilters(acqCompanyId, pkgDistributionIds);
        Map<String, Object> bindMap = getPkgDistributionQueryBindMap(scheduledDelivery, acqCompanyId, pkgDistributionIds);
        String queryString = String.format(PKG_DISTRIBUTION_QUERY_STR, new String[] {String.join(pkgDistributionQueryFields, ', '), filters});
        return getPackageDistributions(queryString, bindMap);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the Filters string, to be used to form the Package Distributions queryString (to fetch records dynamically using Database.queryWithBinds() method).
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId                        DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    pkgDistributionIds	                DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @return   String                              DESCRIPTION (return Filters string, used to form the Package Distributions queryString)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getPkgDistributionQueryFilters(Id acqCompanyId, Set<Id> pkgDistributionIds) {
        String filters = String.format(SUMMARY_REQUIRED_FILTER, new String[] {SUMMARY_REQUIRED_VAR});
        filters += String.format(PD_STATUS_FILTER, new String[] {PD_STATUS_VAR});
        filters += String.format(PD_STAGE_FILTER, new String[] {PD_STAGE_VAR});
        filters += (acqCompanyId == null) ? '' : String.format(ACQ_COMPANY_ID_FILTER, new String[] {ACQ_COMPANY_ID_VAR});
        filters += String.format(SCHEDULED_DELIVERY_FILTER, new String[] {SCHEDULED_DELIVERY_VAR});
        filters += String.format(TOTAL_NEED_TO_DELIVER_COUNT_FILTER, new String[] {TOTAL_NEED_TO_DELIVER_COUNT_VAR});
        filters += (pkgDistributionIds != null && pkgDistributionIds.size() > 0) ? String.format(PD_IDS_FILTER, new String[] {PD_IDS_VAR}) : '';        
        return filters;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the bindMap for the Package Distributions queryString, sets value for all the Bind Variables used in the queryString.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    scheduledDelivery                   DESCRIPTION (Data Type Boolean, True if the processed initiated due to scheduled delivery)
    * @param    acqCompanyId                        DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    pkgDistributionIds	                DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @return   Map<String, Object>                 DESCRIPTION (return bindMap for the Aggregated Offer Communicators queryString)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, Object> getPkgDistributionQueryBindMap(Boolean scheduledDelivery, Id acqCompanyId, Set<Id> pkgDistributionIds) {
        Map<String, Object> bindMap = new Map<String, Object>();
        bindMap.put(SUMMARY_REQUIRED_VAR, true);
        bindMap.put(PD_STATUS_VAR, summaryDeliveryEligibleStatusSet);
        bindMap.put(PD_STAGE_VAR, PD_STAGE_READY_FOR_SUMMARY_DELIVERY);
        bindMap.put(ACQ_COMPANY_ID_VAR, acqCompanyId);
        bindMap.put(SCHEDULED_DELIVERY_VAR, scheduledDelivery);
        bindMap.put(TOTAL_NEED_TO_DELIVER_COUNT_VAR, 0);
        bindMap.put(PD_IDS_VAR, pkgDistributionIds);
        return bindMap;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to execute the Database.queryWithBinds() & return the List of Package Distribution records retrieved by the dynamic query string.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    queryString                         DESCRIPTION (Data Type String, Query String to use in Database.queryWithBinds() method)
    * @param    bindMap                             DESCRIPTION (Data Type Map<String, Object>, bindMap wrapped in the QueryWrapper instance)
    * @return   List<AggregateResult>               DESCRIPTION (return List of Package Distribution records)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<MA_DS_Package_Distribution__c> getPackageDistributions(String queryString, Map<String, Object> bindMap) {
        List<MA_DS_Package_Distribution__c> pkgDistributions = new List<MA_DS_Package_Distribution__c>();
        
        try {
            pkgDistributions.addAll((List<MA_DS_Package_Distribution__c>)Database.queryWithBinds(queryString, bindMap, AccessLevel.SYSTEM_MODE));
        }catch(QueryException exType) {
            MA_AbstractLogger.logException(exType, MA_DS_ManagerSummariesDeliveryUtility.class.getName());
        }

        return pkgDistributions;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get Package Distribution Names if one or more Acquisition Contacts are not yet ready for Manager Summary Delivery.
    * Method checks "Ready For Summary Delivery" flag for each Acquisition Contact in the Package Distribution.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionMap	        DESCRIPTION (Data Type Map<Id, MA_DS_Package_Distribution__c>, Map of eligible Package Distribution records.
    * @return   Set<String>                 DESCRIPTION (return Set of Package Distribution Names with atleast one Acquisition Contact not ready for Manager Summary Delivery)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Set<String> getDistributionsNotReadyForSummaryDelivery(Map<Id, MA_DS_Package_Distribution__c> pkgDistributionMap) {
        List<AggregateResult> aggAppliedRules = [SELECT MA_DS_Package_Distribution__c pkgDistId, Count(Id)
                                                 FROM MA_DS_Applied_Rule__c
                                                 WHERE MA_DS_Rule_Type__c = :PD_TYPE_APPLIED_RULE AND
                                                 MA_DS_Package_Distribution__c IN :pkgDistributionMap.keySet() AND
                                                 MA_DS_Acquisition_Contact__r.MA_DS_No_Offer__c = false AND
                                                 MA_DS_Acquisition_Contact__r.MA_DS_Offer_Declined__c = false AND
                                                 MA_DS_Ready_For_Summary_Delivery__c = false
                                                 GROUP BY MA_DS_Package_Distribution__c
                                                 HAVING Count(Id) > 0];

        Set<String> pkgDistributionNames = new Set<String>();

        for(AggregateResult aggAppliedRule : aggAppliedRules) {
            Id pkgDistId = (Id)aggAppliedRule.get(AGG_FIELD_PKG_DIST_ID);
            pkgDistributionNames.add(pkgDistributionMap.get(pkgDistId)?.Name);
        }

        return pkgDistributionNames;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get Package Distribution Names if No IUT Type Manager Summary Applied Rule is marked as "Need To Deliver" for atleast one of the given Package Distributions.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionMap	        DESCRIPTION (Data Type Map<Id, MA_DS_Package_Distribution__c>, Map of eligible Package Distribution records.
    * @return   Set<String>                 DESCRIPTION (return Set of Package Distribution Names with No IUT Type Manager Summary Applied Rule marked as "Need To Deliver")
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Set<String> getDistributionsWithNoNeedForSummaryDelivery(Map<Id, MA_DS_Package_Distribution__c> pkgDistributionMap) {
        List<AggregateResult> aggAppliedRules = [SELECT MA_DS_Package_Distribution__c pkgDistId, Count(Id) ruleCount
                                                 FROM MA_DS_Applied_Rule__c
                                                 WHERE MA_DS_Rule_Type__c = :IUT_TYPE_APPLIED_RULE AND
                                                 MA_DS_Template__r.MA_DS_Template_Document_Type__c = :DOCUMENT_TYPE_MANAGER_SUMMARY AND
                                                 MA_DS_Package_Distribution__c IN :pkgDistributionMap.keySet() AND
                                                 MA_DS_Need_To_Deliver__c = true AND
                                                 MA_DS_Acquisition_Contact__r.MA_DS_No_Offer__c = false AND
                                                 MA_DS_Acquisition_Contact__r.MA_DS_Offer_Declined__c = false
                                                 GROUP BY MA_DS_Package_Distribution__c];

        Set<String> pkgDistributionNames = new Set<String>();

        for(AggregateResult aggAppliedRule : aggAppliedRules) {
            Id pkgDistId = (Id)aggAppliedRule.get(AGG_FIELD_PKG_DIST_ID);
            Integer ruleCount = (Integer)aggAppliedRule.get(AGG_FIELD_RULE_COUNT);

            if(ruleCount == 0) {
                pkgDistributionNames.add(pkgDistributionMap.get(pkgDistId)?.Name);
            }
        }

        return pkgDistributionNames;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the Integration Status on all eligible Package Distributions to "Sending Manager Summaries", for the Manager Summary Delivery.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributions	        DESCRIPTION (Data Type List<MA_DS_Package_Distribution__c>, List of Package Distribution records)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updatePkgDistributionsIntegrationStatus(List<MA_DS_Package_Distribution__c> pkgDistributions) {
        for(MA_DS_Package_Distribution__c pkgDistribution : pkgDistributions) {
            pkgDistribution.MA_DS_Integration_Status__c = INTEGRATION_STATUS_SUMMARY_DELIVERY;
        }

        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = true;
        Database.SaveResult[] packageDistSRList = Database.update(pkgDistributions, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(packageDistSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
    }
}