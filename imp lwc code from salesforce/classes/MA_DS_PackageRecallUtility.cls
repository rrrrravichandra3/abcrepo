/**
 * W-13484430 & W-13576017
 * Utility class to help inititate the Package Recall process for the Package Distribution record(s).
 * 
 * Version      Date            Author                  Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         20/06/2023      Chakshu Malhotra        W-13484430 & W-13576017 - Adds logic to help inititate the Package Recall process for the Package Distribution record(s).
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_PackageRecallUtility {
    
    private static final String PACKAGE_RECALL_ELIGIBLE_STATUS = Label.MA_DS_Eligible_Status_For_Package_Recall;
    private static final String INTEGRATION_STATUS_PACKAGE_RECALL = Label.MA_DS_Integration_Status_Package_Recall;

    private static final String PD_STATUS_VAR = 'pdStatus';
    private static final String PD_STATUS_FILTER = 'MA_DS_Status__c IN :{0}';

    private static final String ACQ_COMPANY_ID_VAR = 'acqCompanyId';
    private static final String ACQ_COMPANY_ID_FILTER = ' AND MA_DS_Package__r.MA_DS_Acquisition_Company__c = :{0}';

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
    * Property to hold the set of status values that makes a Package Distribution eligible for Package Recall process.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Set<String> packageRecallEligibleStatusSet {
        get {
            if(packageRecallEligibleStatusSet == null) {
                packageRecallEligibleStatusSet = new Set<String>((List<String>)JSON.deserialize(PACKAGE_RECALL_ELIGIBLE_STATUS, List<String>.class));
            }
            return packageRecallEligibleStatusSet;
        }set;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the Package Distribution records, either all (by Acquisition Company record Id) or the Selected Ones on the UI.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId                            DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    pkgDistributionIds	                    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @return   List<MA_DS_Package_Distribution__c>     DESCRIPTION (return Package Distribution records for the given Acquisition Company)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<MA_DS_Package_Distribution__c> getPackageDistributions(Id acqCompanyId, Set<Id> pkgDistributionIds) {
        String filters = getPkgDistributionQueryFilters(pkgDistributionIds);
        Map<String, Object> bindMap = getPkgDistributionQueryBindMap(acqCompanyId, pkgDistributionIds);
        String queryString = String.format(PKG_DISTRIBUTION_QUERY_STR, new String[] {String.join(pkgDistributionQueryFields, ', '), filters});
        return getPackageDistributions(queryString, bindMap);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the Filters string, to be used to form the Package Distributions queryString (to fetch records dynamically using Database.queryWithBinds() method).
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionIds	                DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @return   String                              DESCRIPTION (return Filters string, used to form the Package Distributions queryString)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getPkgDistributionQueryFilters(Set<Id> pkgDistributionIds) {
        String filters = String.format(PD_STATUS_FILTER, new String[] {PD_STATUS_VAR});
        filters += String.format(ACQ_COMPANY_ID_FILTER, new String[] {ACQ_COMPANY_ID_VAR});
        filters += (pkgDistributionIds != null && pkgDistributionIds.size() > 0) ? String.format(PD_IDS_FILTER, new String[] {PD_IDS_VAR}) : '';        
        return filters;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the bindMap for the Package Distributions queryString, sets value for all the Bind Variables used in the queryString.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId                        DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    pkgDistributionIds	                DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @return   Map<String, Object>                 DESCRIPTION (return bindMap for the Aggregated Offer Communicators queryString)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, Object> getPkgDistributionQueryBindMap(Id acqCompanyId, Set<Id> pkgDistributionIds) {
        Map<String, Object> bindMap = new Map<String, Object>();
        bindMap.put(PD_STATUS_VAR, packageRecallEligibleStatusSet);
        bindMap.put(ACQ_COMPANY_ID_VAR, acqCompanyId);
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
            MA_AbstractLogger.logException(exType, MA_DS_PackageRecallUtility.class.getName());
        }

        return pkgDistributions;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the Integration Status on all eligible Package Distributions to "Recalling Packages", for the Package Recall process.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributions	        DESCRIPTION (Data Type List<MA_DS_Package_Distribution__c>, List of Package Distribution records)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updatePkgDistributionsIntegrationStatus(List<MA_DS_Package_Distribution__c> pkgDistributions) {
        for(MA_DS_Package_Distribution__c pkgDistribution : pkgDistributions) {
            pkgDistribution.MA_DS_Integration_Status__c = INTEGRATION_STATUS_PACKAGE_RECALL;
        }

        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = true;
        Database.SaveResult[] packageDistSRList = Database.update(pkgDistributions, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(packageDistSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
    }
}