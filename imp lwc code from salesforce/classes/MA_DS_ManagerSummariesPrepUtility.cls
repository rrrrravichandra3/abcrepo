/**
 * W-12578116
 * Utility class to help inititate the Manager Summary Prep process for all eligible / selected Package Distributions records.
 * Also helps initiating the process on Audit auto-trigger, once remediator completes the action and closes the Audit remediation task.
 * 
 * Version      Date            Author                  Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         26/03/2023      Chakshu Malhotra        W-12578116 - Adds logic to help inititate the Manager Summary Prep process for all eligible / selected Package Distributions records.
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_ManagerSummariesPrepUtility {

    private static final String SUMMARY_PREP_ELIGIBLE_STATUS = Label.MA_DS_Eligible_Status_For_Summary_Prep;
    private static final String PD_STAGE_READY_FOR_SUMMARY_PREP = Label.MA_DS_PD_Stage_Ready_For_Summary_Prep;

    private static final String PD_TYPE_APPLIED_RULE = Label.MA_DS_PD_Type_Applied_Rule;
    private static final String IUT_TYPE_APPLIED_RULE = Label.MA_DS_IUT_Type_Applied_Rule;
    private static final String TEMPLATE_TYPE_ACQUISITION = Label.MA_DS_Template_Type_Acquisition;
    private static final String DOCUMENT_TYPE_MANAGER_SUMMARY = Label.MA_DS_Document_Type_Manager_Summary;
    private static final String INTEGRATION_STATUS_SUMMARY_PREP = Label.MA_DS_Integration_Status_Summary_Prep;

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

    private static final String TOTAL_NEED_TO_GENERATE_COUNT_VAR = 'needGenerateCount';
    private static final String TOTAL_NEED_TO_GENERATE_COUNT_FILTER = ' AND MA_DS_Total_In_Need_To_Generate_Summary__c > :{0}';

    private static final String PD_IDS_VAR = 'pdIds';
    private static final String PD_IDS_FILTER = ' AND Id IN :{0}';

    private static final String PKG_DISTRIBUTION_QUERY_STR = 'SELECT {0} FROM MA_DS_Package_Distribution__c WHERE {1}';

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the List of Query fields for the Package Distributions query.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<String> pkgDistributionQueryFields {
        get {
            if(pkgDistributionQueryFields == null) {
                pkgDistributionQueryFields = new List<String> {'Id', 'Name', 'MA_DS_Status__c', 'MA_DS_Integration_Status__c', 'MA_DS_Rules_Sync_Status__c'};
            }
            return pkgDistributionQueryFields;
        }set;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the set of status values that makes a Package Distribution eligible for Manager Summary Prep / Regen process.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Set<String> summaryPrepEligibleStatusSet {
        get {
            if(summaryPrepEligibleStatusSet == null) {
                summaryPrepEligibleStatusSet = new Set<String>((List<String>)JSON.deserialize(SUMMARY_PREP_ELIGIBLE_STATUS, List<String>.class));
            }
            return summaryPrepEligibleStatusSet;
        }set;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the Set of Package Distribution record Ids, that match the Manager Summary Common Id on the Summarized Contacts.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId                            DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    commonIds	                            DESCRIPTION (Data Type Set<String>, Set of Manager Summary Common Id)
    * @return   Set<Id>                                 DESCRIPTION (return Set of Package Distribution record Ids)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Set<Id> getPackageDistributionIds(Id acqCompanyId, Set<String> commonIds) {
        Set<Id> pkgDistributionIds = new Set<Id>();
        for(AggregateResult aggAppliedRule : getAggregatedAppliedRules(acqCompanyId, commonIds)) {
            Id pkgDistId = (Id)aggAppliedRule.get(AGG_FIELD_PKG_DIST_ID);
            pkgDistributionIds.add(pkgDistId);
        }
        return pkgDistributionIds;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the Aggregated Applied Rule records, to identify Package Distributions that match the Manager Summary Common Id on the Summarized Contacts.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId                            DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    commonIds	                            DESCRIPTION (Data Type Set<String>, Set of Manager Summary Common Id)
    * @return   List<AggregateResult>                   DESCRIPTION (return List of Aggregated Applied Rule records)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<AggregateResult> getAggregatedAppliedRules(Id acqCompanyId, Set<String> commonIds) {
        return [SELECT MA_DS_Package_Distribution__c pkgDistId, Count(Id)
                FROM MA_DS_Applied_Rule__c
                WHERE MA_DS_Rule_Type__c = :PD_TYPE_APPLIED_RULE AND
                MA_DS_Manager_Summary_Rule_Applied__c = true AND
                MA_DS_Package_Distribution__r.MA_DS_Package__r.MA_DS_Acquisition_Company__c = :acqCompanyId AND
                MA_DS_Package_Distribution__r.MA_DS_Summary_Required__c = true AND
                MA_DS_Package_Distribution__r.MA_DS_Package_Distribution_Stage__c = :PD_STAGE_READY_FOR_SUMMARY_PREP AND
                MA_DS_Package_Distribution__r.MA_DS_Status__c IN :summaryPrepEligibleStatusSet AND
                MA_DS_Package_Distribution__r.MA_DS_Manager_Summaries_Prep_Date__c != null AND
                MA_DS_Acquisition_Contact__r.Offer_Communicator__c != null AND
                MA_DS_Acquisition_Contact__r.MA_DS_Manager_Summary_Common_Id__c IN :commonIds
                GROUP BY MA_DS_Package_Distribution__c
                HAVING Count(Id) > 0];
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the Package Distribution records, either all (by Acquisition Company record Id) or the Selected Ones on the UI or by Manager Summary Common Id.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    auditFailedRegen                        DESCRIPTION (Data Type Boolean, True if Summary is being re-generated as part of Audit remediation tasks)
    * @param    acqCompanyId                            DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    pkgDistributionIds	                    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @return   List<MA_DS_Package_Distribution__c>     DESCRIPTION (return Package Distribution records for the given Acquisition Company)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<MA_DS_Package_Distribution__c> getPackageDistributions(Boolean auditFailedRegen, Id acqCompanyId, Set<Id> pkgDistributionIds) {
        String filters = getPkgDistributionQueryFilters(auditFailedRegen, pkgDistributionIds);
        Map<String, Object> bindMap = getPkgDistributionQueryBindMap(acqCompanyId, pkgDistributionIds);
        String queryString = String.format(PKG_DISTRIBUTION_QUERY_STR, new String[] {String.join(pkgDistributionQueryFields, ', '), filters});
        return getPackageDistributions(queryString, bindMap);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the Filters string, to be used to form the Package Distributions queryString (to fetch records dynamically using Database.queryWithBinds() method).
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    auditFailedRegen                DESCRIPTION (Data Type Boolean, True if Summary is being re-generated as part of Audit remediation tasks)
    * @param    pkgDistributionIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @return   String                          DESCRIPTION (return Filters string, used to form the Package Distributions queryString)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getPkgDistributionQueryFilters(Boolean auditFailedRegen, Set<Id> pkgDistributionIds) {
        String filters = String.format(SUMMARY_REQUIRED_FILTER, new String[] {SUMMARY_REQUIRED_VAR});
        filters += String.format(PD_STATUS_FILTER, new String[] {PD_STATUS_VAR});
        filters += String.format(PD_STAGE_FILTER, new String[] {PD_STAGE_VAR});
        filters += String.format(ACQ_COMPANY_ID_FILTER, new String[] {ACQ_COMPANY_ID_VAR});
        filters += auditFailedRegen ? '' : String.format(TOTAL_NEED_TO_GENERATE_COUNT_FILTER, new String[] {TOTAL_NEED_TO_GENERATE_COUNT_VAR});
        filters += (pkgDistributionIds != null && pkgDistributionIds.size() > 0) ? String.format(PD_IDS_FILTER, new String[] {PD_IDS_VAR}) : '';        
        return filters;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the bindMap for the Package Distributions queryString, sets value for all the Bind Variables used in the queryString.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId                    DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    pkgDistributionIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @return   Map<String, Object>             DESCRIPTION (return bindMap for the Aggregated Offer Communicators queryString)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, Object> getPkgDistributionQueryBindMap(Id acqCompanyId, Set<Id> pkgDistributionIds) {
        Map<String, Object> bindMap = new Map<String, Object>();
        bindMap.put(SUMMARY_REQUIRED_VAR, true);
        bindMap.put(PD_STATUS_VAR, summaryPrepEligibleStatusSet);
        bindMap.put(PD_STAGE_VAR, PD_STAGE_READY_FOR_SUMMARY_PREP);
        bindMap.put(ACQ_COMPANY_ID_VAR, acqCompanyId);
        bindMap.put(TOTAL_NEED_TO_GENERATE_COUNT_VAR, 0);
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
            MA_AbstractLogger.logException(exType, MA_DS_ManagerSummariesPrepUtility.class.getName());
        }

        return pkgDistributions;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get Package Distribution Names if No Manager Summary Rule found for atleast one of the Acquisition Contact added in the Distribution Applied Rules.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionMap	        DESCRIPTION (Data Type Map<Id, MA_DS_Package_Distribution__c>, Map of eligible Package Distribution records.
    * @return   Set<String>                 DESCRIPTION (return Set of Package Distribution Names with atleast one Acquisition Contact with no Manager Summary Rule)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Set<String> getDistributionsWithNoManagerSummaryRules(Map<Id, MA_DS_Package_Distribution__c> pkgDistributionMap) {
        List<AggregateResult> aggAppliedRules = [SELECT MA_DS_Package_Distribution__c pkgDistId, Count(Id)
                                                 FROM MA_DS_Applied_Rule__c
                                                 WHERE MA_DS_Rule_Type__c = :PD_TYPE_APPLIED_RULE AND
                                                 MA_DS_Package_Distribution__c IN :pkgDistributionMap.keySet() AND
                                                 MA_DS_Acquisition_Contact__r.MA_DS_No_Offer__c = false AND
                                                 MA_DS_Acquisition_Contact__r.MA_DS_Offer_Declined__c = false AND
                                                 MA_DS_Manager_Summary_Rule_Applied__c = false
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
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get Package Distribution Names if No Offer Communicator(s) found for atleast one of the Acquisition Contact added in the Distribution Applied Rules.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionMap	        DESCRIPTION (Data Type Map<Id, MA_DS_Package_Distribution__c>, Map of eligible Package Distribution records.
    * @return   Set<String>                 DESCRIPTION (return Set of Package Distribution Names with atleast one Acquisition Contact with no Offer Communicator)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Set<String> getDistributionsWithNoOfferCommunicators(Map<Id, MA_DS_Package_Distribution__c> pkgDistributionMap) {
        List<AggregateResult> aggAppliedRules = [SELECT MA_DS_Package_Distribution__c pkgDistId, Count(Id)
                                                 FROM MA_DS_Applied_Rule__c
                                                 WHERE MA_DS_Rule_Type__c = :PD_TYPE_APPLIED_RULE AND
                                                 MA_DS_Package_Distribution__c IN :pkgDistributionMap.keySet() AND
                                                 MA_DS_Acquisition_Contact__r.MA_DS_No_Offer__c = false AND
                                                 MA_DS_Acquisition_Contact__r.MA_DS_Offer_Declined__c = false AND
                                                 MA_DS_Acquisition_Contact__r.Offer_Communicator__c = null
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
    * Method to get Package Distribution Names if No IUT Type Manager Summary Applied Rule is marked as "Need To Generate" for atleast one of the given Package Distributions.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionMap	        DESCRIPTION (Data Type Map<Id, MA_DS_Package_Distribution__c>, Map of eligible Package Distribution records.
    * @return   Set<String>                 DESCRIPTION (return Set of Package Distribution Names with No IUT Type Manager Summary Applied Rule marked as "Need To Generate")
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Set<String> getDistributionsWithNoNeedForSummaryPrep(Map<Id, MA_DS_Package_Distribution__c> pkgDistributionMap) {
        List<AggregateResult> aggAppliedRules = [SELECT MA_DS_Package_Distribution__c pkgDistId, Count(Id) ruleCount
                                                 FROM MA_DS_Applied_Rule__c
                                                 WHERE MA_DS_Rule_Type__c = :IUT_TYPE_APPLIED_RULE AND
                                                 MA_DS_Template__r.MA_DS_Template_Document_Type__c = :DOCUMENT_TYPE_MANAGER_SUMMARY AND
                                                 MA_DS_Package_Distribution__c IN :pkgDistributionMap.keySet() AND
                                                 MA_DS_Need_To_Generate__c = true AND
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
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Template record Id of Document type Manager Summary, for the given Acquisition Company record Id.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	        DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @return   Id                      DESCRIPTION (return Template record Id of Document type Manager Summary)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Id getManagerSummaryTemplateId(Id acqCompanyId) {
        List<MA_DS_Template__c> templates = [SELECT Id FROM MA_DS_Template__c 
                                             WHERE MA_DS_Acquisition_Company__c = :acqCompanyId AND
                                             MA_DS_Template_Type__c = :TEMPLATE_TYPE_ACQUISITION AND
                                             MA_DS_Template_Document_Type__c = :DOCUMENT_TYPE_MANAGER_SUMMARY LIMIT 1];
        return (templates.size() > 0) ? templates[0].Id : null;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the Integration Status on all eligible Package Distributions to "Preparing Manager Summaries", for the Manager Summary Prep.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributions	        DESCRIPTION (Data Type List<MA_DS_Package_Distribution__c>, List of Package Distribution records)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updatePkgDistributionsIntegrationStatus(List<MA_DS_Package_Distribution__c> pkgDistributions) {
        for(MA_DS_Package_Distribution__c pkgDistribution : pkgDistributions) {
            pkgDistribution.MA_DS_Integration_Status__c = INTEGRATION_STATUS_SUMMARY_PREP;
        }

        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = true;
        Database.SaveResult[] packageDistSRList = Database.update(pkgDistributions, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(packageDistSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
    }
}