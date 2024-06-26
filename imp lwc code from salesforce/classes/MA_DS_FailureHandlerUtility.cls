/**
 * W-13465433
 * Utility class for FailureHandlerJob & FailureHandlerJobFinalizer implementations within MA_DS_FailureHandlerService.FailureHandlerService.
 * Processes Applied Rule records to mark them for Document Generate / Delivery need during failures that may happen during Prep, Audit & Delivery phases.
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         23/05/2023      Chakshu Malhotra        W-13465433 - Provides utility methods that processes Applied Rule records to mark them for Document Generate / Delivery need.
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_FailureHandlerUtility {

    private static final String IUT_TYPE_APPLIED_RULE = Label.MA_DS_IUT_Type_Applied_Rule;
    private static final String IUT_DOCUMENT_TYPE_PACKAGE = Label.MA_DS_Document_Type_Package;
    private static final String IUT_DOCUMENT_TYPE_SUMMARY = Label.MA_DS_Document_Type_Manager_Summary;

    private static final String STAGE_FAILED_TO_DELIVER = Label.MA_DS_Stage_Failed_To_Deliver;
    private static final String STAGE_FAILED_TO_GENERATE = Label.MA_DS_Stage_Failed_To_Generate;
    private static final String STAGE_FAILED_AUDIT_REGENERATE = Label.MA_DS_Stage_Failed_Audit_Regenerate;

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

    private static final String SUMMARY_COMMON_IDS_VAR = 'summaryCommonIds';
    private static final String SUMMARY_COMMON_IDS_FILTER = ' AND MA_DS_Acquisition_Contact__r.MA_DS_Manager_Summary_Common_Id__c IN :{0}';

    private static final String PACKAGE_COMMON_IDS_VAR = 'packageCommonIds';
    private static final String PACKAGE_COMMON_IDS_FILTER = ' AND MA_DS_Acquisition_Contact__r.MA_DS_Package_Common_Id__c IN :{0}';

    private static final String OFFER_COMM_IDS_VAR = 'offerCommIds';
    private static final String OFFER_COMM_IDS_FILTER = ' AND MA_DS_Acquisition_Contact__r.Offer_Communicator__c IN :{0}';

    private static final String ACQ_CONTACT_IDS_VAR = 'acqContactIds';
    private static final String ACQ_CONTACT_IDS_FILTER = ' AND MA_DS_Acquisition_Contact__c IN :{0}';

    private static final String TEMPLATE_IDS_VAR = 'templateIds';
    private static final String TEMPLATE_IDS_FILTER = ' AND MA_DS_Template__c IN :{0}';

    private static final String APPLIED_RULE_IDS_VAR = 'appliedRuleIds';
    private static final String APPLIED_RULE_IDS_FILTER = ' AND Id IN :{0}';

    private static final String LAST_RECORD_ID_VAR = 'lastRecordId';
    private static final String LAST_RECORD_ID_FILTER = ' AND Id > :{0}';

    private static final String QUERY_SIZE_LIMIT_VAR = 'querySizeLimit';
    private static final String QUERY_SIZE_LIMIT_FILTER = ' ORDER BY Id ASC LIMIT :{0}';

    private static final String APPLIED_RULE_QUERY_STR = 'SELECT {0} FROM MA_DS_Applied_Rule__c WHERE {1}';

    private static final String PKG_DIST_IDS_VAR = 'pkgDistributionIds';
    private static final String PKG_DIST_IDS_FILTER = 'Id IN :{0}';

    private static final String PKG_DIST_SUMMARY_COMMON_IDS_VAR = 'summaryCommonIds';
    private static final String PKG_DIST_SUMMARY_COMMON_IDS_FILTER = 'MA_DS_Manager_Summary_Common_Id__c IN :{0}';

    private static final String PKG_DISTRIBUTION_QUERY_STR = 'SELECT {0} FROM MA_DS_Package_Distribution__c WHERE {1}';

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the List of Query fields for the Applied Rules query.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<String> appliedRuleQueryFields {
        get {
            if(appliedRuleQueryFields == null) {
                appliedRuleQueryFields = new List<String> {'Id', 'MA_DS_Acquisition_Contact__c', 'MA_DS_Acquisition_Contact__r.Offer_Communicator__c', 
                    'MA_DS_Acquisition_Contact__r.MA_DS_Package_Stage__c', 'MA_DS_Acquisition_Contact__r.Offer_Communicator__r.MA_DS_Manager_Summary_Stage__c', 
                    'MA_DS_Need_To_Generate__c', 'MA_DS_Need_To_Deliver__c'};
            }
            return appliedRuleQueryFields;
        }set;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the List of Query fields for the Package Distributions query.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<String> pkgDistributionQueryFields {
        get {
            if(pkgDistributionQueryFields == null) {
                pkgDistributionQueryFields = new List<String> {'Id', 'MA_DS_Manager_Summary_Common_Id__c', 'MA_DS_Package_Common_Id__c', 
                    'MA_DS_Failed_Offer_Communicator_Ids__c', 'MA_DS_Failed_Package_Contact_Ids__c'};
            }
            return pkgDistributionQueryFields;
        }set;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the List of Applied Rules to mark them as "Need To Generate" or "Need To Delivery", to handle Prep / Audit & Delivery failure scenarios.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    summaryFailure	                DESCRIPTION (Data Type Boolean, True if the FailureHandlerJob is handling Summary Prep / Audit / Delivery failure)
    * @param    commonIds	                    DESCRIPTION (Data Type Set<String>, Set of Manager Summary / Package Common Ids to identify the Applied Rule records to mark them for "Need To Generate" or "Need To Delivery")
    * @param    pkgDistributionIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to identify the Applied Rule records to mark them for "Need To Generate" or "Need To Delivery")
    * @param    acqContactIds	                DESCRIPTION (Data Type Set<String>, Set of Acquisition Contact Ids to identify the Applied Rule records to mark them for "Need To Generate" or "Need To Delivery")
    * @param    templateIds	                    DESCRIPTION (Data Type Set<String>, Set of Template Ids to identify the Applied Rule records to mark them for "Need To Generate")
    * @param    appliedRuleIds	                DESCRIPTION (Data Type Set<String>, Set of Applied Rule Ids to identify the Applied Rule records to mark them for "Need To Generate")
    * @param    lastRecordId                    DESCRIPTION (Data Type Id, Last Record Id of the Applied Rule processed in the previous query)
    * @param    querySizeLimit                  DESCRIPTION (Data Type Integer, Maximum number of records allowed to fetch for the FailureHandlerJob)
    * @return   List<MA_DS_Applied_Rule__c>     DESCRIPTION (return List of Applied Rules)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<MA_DS_Applied_Rule__c> getAppliedRules(Boolean summaryFailure, Set<String> commonIds, Set<Id> pkgDistributionIds, Set<String> acqContactIds, Set<String> templateIds, Set<String> appliedRuleIds, Id lastRecordId, Integer querySizeLimit) {
        String filters = getAppliedRulesQueryFilters(summaryFailure, commonIds, pkgDistributionIds, acqContactIds, templateIds, appliedRuleIds, lastRecordId);
        String queryString = String.format(APPLIED_RULE_QUERY_STR, new String[] {String.join(appliedRuleQueryFields, ', '), filters});
        Map<String, Object> bindMap = getAppliedRulesQueryBindMap(summaryFailure, commonIds, pkgDistributionIds, acqContactIds, templateIds, appliedRuleIds, lastRecordId, querySizeLimit);
        return getAppliedRules(queryString, bindMap);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the Filters string, to be used to form the Applied Rules queryString (to fetch records dynamically using Database.queryWithBinds() method).
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    summaryFailure	                DESCRIPTION (Data Type Boolean, True if the FailureHandlerJob is handling Summary Prep / Audit / Delivery failure)
    * @param    commonIds	                    DESCRIPTION (Data Type Set<String>, Set of Manager Summary / Package Common Ids to identify the Applied Rule records to mark them for "Need To Generate" or "Need To Delivery")
    * @param    pkgDistributionIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to identify the Applied Rule records to mark them for "Need To Generate" or "Need To Delivery")
    * @param    acqContactIds	                DESCRIPTION (Data Type Set<String>, Set of Acquisition Contact Ids to identify the Applied Rule records to mark them for "Need To Generate" or "Need To Delivery")
    * @param    templateIds	                    DESCRIPTION (Data Type Set<String>, Set of Template Ids to identify the Applied Rule records to mark them for "Need To Generate")
    * @param    appliedRuleIds	                DESCRIPTION (Data Type Set<String>, Set of Applied Rule Ids to identify the Applied Rule records to mark them for "Need To Generate")
    * @param    lastRecordId                    DESCRIPTION (Data Type Id, Last Record Id of the Applied Rule processed in the previous query)
    * @return   String                          DESCRIPTION (return Filters string, used to form the Applied Rules queryString)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getAppliedRulesQueryFilters(Boolean summaryFailure, Set<String> commonIds, Set<Id> pkgDistributionIds, Set<String> acqContactIds, Set<String> templateIds, Set<String> appliedRuleIds, Id lastRecordId) {
        String filters = String.format(RULE_TYPE_FILTER, new String[] {RULE_TYPE_VAR});
        filters += String.format(DOC_TYPE_FILTER, new String[] {DOC_TYPE_VAR});
        filters += String.format(NO_OFFER_FILTER, new String[] {NO_OFFER_VAR});
        filters += String.format(OFFER_DECLINED_FILTER, new String[] {OFFER_DECLINED_VAR});
        filters += (pkgDistributionIds != null && pkgDistributionIds.size() > 0) ? String.format(PKG_DISTRIBUTION_IDS_FILTER, new String[] {PKG_DISTRIBUTION_IDS_VAR}) : '';
        filters += (commonIds != null && commonIds.size() > 0) ? String.format(summaryFailure ? SUMMARY_COMMON_IDS_FILTER : PACKAGE_COMMON_IDS_FILTER, new String[] {summaryFailure ? SUMMARY_COMMON_IDS_VAR : PACKAGE_COMMON_IDS_VAR}) : '';
        filters += (acqContactIds != null && acqContactIds.size() > 0) ? String.format(summaryFailure ? OFFER_COMM_IDS_FILTER : ACQ_CONTACT_IDS_FILTER, new String[] {summaryFailure ? OFFER_COMM_IDS_VAR : ACQ_CONTACT_IDS_VAR}) : '';
        filters += (templateIds != null && templateIds.size() > 0) ? String.format(TEMPLATE_IDS_FILTER, new String[] {TEMPLATE_IDS_VAR}) : '';
        filters += (appliedRuleIds != null && appliedRuleIds.size() > 0) ? String.format(APPLIED_RULE_IDS_FILTER, new String[] {APPLIED_RULE_IDS_VAR}) : '';
        filters += (lastRecordId == null) ? '' : String.format(LAST_RECORD_ID_FILTER, new String[] {LAST_RECORD_ID_VAR});
        filters += String.format(QUERY_SIZE_LIMIT_FILTER, new String[] {QUERY_SIZE_LIMIT_VAR});
        return filters;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the bindMap for the Applied Rules queryString, sets value for all the Bind Variables used in the queryString.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    summaryFailure	                DESCRIPTION (Data Type Boolean, True if the FailureHandlerJob is handling Summary Prep / Audit / Delivery failure)
    * @param    commonIds	                    DESCRIPTION (Data Type Set<String>, Set of Manager Summary / Package Common Ids to identify the Applied Rule records to mark them for "Need To Generate" or "Need To Delivery")
    * @param    pkgDistributionIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to identify the Applied Rule records to mark them for "Need To Generate" or "Need To Delivery")
    * @param    acqContactIds	                DESCRIPTION (Data Type Set<String>, Set of Acquisition Contact Ids to identify the Applied Rule records to mark them for "Need To Generate" or "Need To Delivery")
    * @param    templateIds	                    DESCRIPTION (Data Type Set<String>, Set of Template Ids to identify the Applied Rule records to mark them for "Need To Generate")
    * @param    appliedRuleIds	                DESCRIPTION (Data Type Set<String>, Set of Applied Rule Ids to identify the Applied Rule records to mark them for "Need To Generate")
    * @param    lastRecordId                    DESCRIPTION (Data Type Id, Last Record Id of the Applied Rule processed in the previous query)
    * @param    querySizeLimit                  DESCRIPTION (Data Type Integer, Maximum number of records allowed to fetch for the FailureHandlerJob)
    * @return   Map<String, Object>             DESCRIPTION (return bindMap for the Applied Rules queryString)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, Object> getAppliedRulesQueryBindMap(Boolean summaryFailure, Set<String> commonIds, Set<Id> pkgDistributionIds, Set<String> acqContactIds, Set<String> templateIds, Set<String> appliedRuleIds, Id lastRecordId, Integer querySizeLimit) {
        Map<String, Object> bindMap = new Map<String, Object>();
        bindMap.put(RULE_TYPE_VAR, IUT_TYPE_APPLIED_RULE);
        bindMap.put(DOC_TYPE_VAR, summaryFailure ? IUT_DOCUMENT_TYPE_SUMMARY : IUT_DOCUMENT_TYPE_PACKAGE);
        bindMap.put(NO_OFFER_VAR, false);
        bindMap.put(OFFER_DECLINED_VAR, false);
        bindMap.put(PKG_DISTRIBUTION_IDS_VAR, pkgDistributionIds);
        bindMap.put(summaryFailure ? SUMMARY_COMMON_IDS_VAR : PACKAGE_COMMON_IDS_VAR, commonIds);
        bindMap.put(summaryFailure ? OFFER_COMM_IDS_VAR : ACQ_CONTACT_IDS_VAR, acqContactIds);
        bindMap.put(TEMPLATE_IDS_VAR, templateIds);
        bindMap.put(APPLIED_RULE_IDS_VAR, appliedRuleIds);
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
            MA_AbstractLogger.logException(exType, MA_DS_FailureHandlerUtility.class.getName());
        }

        return appliedRules;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the Applied Rule records to mark them as "Need To Generate" / "Need To Deliver", based on the Failure type.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    summaryFailure	                DESCRIPTION (Data Type Boolean, True if the FailureHandlerJob is handling Summary Prep / Audit / Delivery failure)
    * @param    appliedRules	                DESCRIPTION (Data Type List<MA_DS_Applied_Rule__c>, List of Applied Rule records)
    * @param    failureType	                    DESCRIPTION (Data Type MA_DS_FailureHandlerService.Failure, Failure type for Summaries / Packages)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updateAppliedRules(Boolean summaryFailure, List<MA_DS_Applied_Rule__c> appliedRules, MA_DS_FailureHandlerService.Failure failureType) {
        Set<Id> acqContactIds = new Set<Id>();

        for(MA_DS_Applied_Rule__c appliedRule : appliedRules) {
            switch on failureType {
                when SUMMARY_PREP, SUMMARY_AUDIT, PACKAGE_PREP, PACKAGE_AUDIT {
                    appliedRule.MA_DS_Need_To_Generate__c = true;
                    appliedRule.MA_DS_Need_To_Deliver__c = false;
                }when SUMMARY_DELIVERY, PACKAGE_DELIVERY {
                    appliedRule.MA_DS_Need_To_Deliver__c = true;
                }
            }

            if(updateAcquisitionContact(summaryFailure, appliedRule, failureType)) {
                if(summaryFailure) {
                    acqContactIds.add(appliedRule.MA_DS_Acquisition_Contact__r.Offer_Communicator__c);
                }else {
                    acqContactIds.add(appliedRule.MA_DS_Acquisition_Contact__c);
                }
            }
        }

        Acquisition_Contacts_Trigger_Handler.triggerDisabled = true;

        if(appliedRules.size() > 0) {
            updatePackageAppliedRules(appliedRules);
        }

        if(acqContactIds.size() > 0) {
            updateAcquisitionContacts(acqContactIds, failureType);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check if Acquisition Contact need to be updated with "Failed to Generate" / "Failed Audit Regenerate" / "Failed to Deliver" Stage.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    summaryFailure	            DESCRIPTION (Data Type Boolean, True if the FailureHandlerJob is handling Summary Prep / Audit / Delivery failure)
    * @param    appliedRule	                DESCRIPTION (Data Type MA_DS_Applied_Rule__c, IUT type Applied Rule recorda)
    * @param    failureType	                DESCRIPTION (Data Type MA_DS_FailureHandlerService.Failure, Failure type for Summaries / Packages)
    * @return   Boolean                     DESCRIPTION (return True if need to update the Acquisition Contact to mark the failure)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean updateAcquisitionContact(Boolean summaryFailure, MA_DS_Applied_Rule__c appliedRule, MA_DS_FailureHandlerService.Failure failureType) {
        Boolean updateAcqContact = false;
        
        String packageStage = (appliedRule.MA_DS_Acquisition_Contact__r.MA_DS_Package_Stage__c == null) ? '' : appliedRule.MA_DS_Acquisition_Contact__r.MA_DS_Package_Stage__c;
        String managerSummaryStage = (appliedRule.MA_DS_Acquisition_Contact__r.Offer_Communicator__r.MA_DS_Manager_Summary_Stage__c == null) ? '' : appliedRule.MA_DS_Acquisition_Contact__r.Offer_Communicator__r.MA_DS_Manager_Summary_Stage__c;

        if(failureType == MA_DS_FailureHandlerService.Failure.SUMMARY_PREP || failureType == MA_DS_FailureHandlerService.Failure.PACKAGE_PREP) {
            updateAcqContact = summaryFailure ? !managerSummaryStage.equalsIgnoreCase(STAGE_FAILED_TO_GENERATE) : !packageStage.equalsIgnoreCase(STAGE_FAILED_TO_GENERATE);
        }else if(failureType == MA_DS_FailureHandlerService.Failure.SUMMARY_AUDIT || failureType == MA_DS_FailureHandlerService.Failure.PACKAGE_AUDIT) {
            updateAcqContact = summaryFailure ? !managerSummaryStage.equalsIgnoreCase(STAGE_FAILED_AUDIT_REGENERATE) : !packageStage.equalsIgnoreCase(STAGE_FAILED_AUDIT_REGENERATE);
        }else if(failureType == MA_DS_FailureHandlerService.Failure.SUMMARY_DELIVERY || failureType == MA_DS_FailureHandlerService.Failure.PACKAGE_DELIVERY) {
            updateAcqContact = summaryFailure ? !managerSummaryStage.equalsIgnoreCase(STAGE_FAILED_TO_DELIVER) : !packageStage.equalsIgnoreCase(STAGE_FAILED_TO_DELIVER);
        }

        return updateAcqContact;
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
        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = true;
        Database.SaveResult[] appliedRulesSRList = Database.update(appliedRules, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(appliedRulesSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the Manager Summary Stage / Package Stage field on Acquisition Contact record to denote failure.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqContactIds	            DESCRIPTION (Data Type Set<Id>, Set of Acquisition Contact Ids to update)
    * @param    failureType	                DESCRIPTION (Data Type MA_DS_FailureHandlerService.Failure, Failure type for Summaries / Packages)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateAcquisitionContacts(Set<Id> acqContactIds, MA_DS_FailureHandlerService.Failure failureType) {
        List<Acquisition_Contacts__c> acqContacts = [SELECT Id, MA_DS_Package_Stage__c, MA_DS_Manager_Summary_Stage__c
                                                     FROM Acquisition_Contacts__c
                                                     WHERE Id IN :acqContactIds];

        for(Acquisition_Contacts__c acqContact : acqContacts) {
            switch on failureType {
                when SUMMARY_PREP {
                    acqContact.MA_DS_Manager_Summary_Stage__c = STAGE_FAILED_TO_GENERATE;
                }when SUMMARY_AUDIT {
                    acqContact.MA_DS_Manager_Summary_Stage__c = STAGE_FAILED_AUDIT_REGENERATE;
                }when SUMMARY_DELIVERY {
                    acqContact.MA_DS_Manager_Summary_Stage__c = STAGE_FAILED_TO_DELIVER;
                }when PACKAGE_PREP {
                    acqContact.MA_DS_Package_Stage__c = STAGE_FAILED_TO_GENERATE;
                }when PACKAGE_AUDIT {
                    acqContact.MA_DS_Package_Stage__c = STAGE_FAILED_AUDIT_REGENERATE;
                }when PACKAGE_DELIVERY {
                    acqContact.MA_DS_Package_Stage__c = STAGE_FAILED_TO_DELIVER;
                }
            }
        }

        Database.SaveResult[] acqContactSRList = Database.update(acqContacts, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(acqContactSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the Package Distribution records to clear "Manager Summary Common Id" / "Package Common Id" / "Failed Offer Communicator Ids" / "Failed Package Contact Ids" during Summary or Package Delivery failure.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    summaryFailure	                        DESCRIPTION (Data Type Boolean, True if the FailureHandlerJob is handling Summary Prep / Audit / Delivery failure)
    * @param    commonIds	                            DESCRIPTION (Data Type Set<String>, Set of Manager Summary / Package Common Ids to identify the Package Distributions)
    * @param    pkgDistributionIds	                    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @param    failureType	                            DESCRIPTION (Data Type MA_DS_FailureHandlerService.Failure, Failure type for Summaries / Packages)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updatePackageDistributions(Boolean summaryFailure, Set<String> commonIds, Set<Id> pkgDistributionIds, MA_DS_FailureHandlerService.Failure failureType) {
        List<MA_DS_Package_Distribution__c> pkgDistributions = getPackageDistributions(summaryFailure, commonIds, pkgDistributionIds);
        
        for(MA_DS_Package_Distribution__c pkgDistribution : pkgDistributions) {
            switch on failureType {
                when SUMMARY_PREP {
                    pkgDistribution.MA_DS_Manager_Summary_Common_Id__c = null;
                }when SUMMARY_DELIVERY {
                    pkgDistribution.MA_DS_Failed_Offer_Communicator_Ids__c = null;
                }when PACKAGE_PREP {
                    pkgDistribution.MA_DS_Package_Common_Id__c = null;
                }when PACKAGE_DELIVERY {
                    pkgDistribution.MA_DS_Failed_Package_Contact_Ids__c = null;
                }
            }
        }
        
        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = true;
        List<Database.SaveResult> pkgDistributionSRList = Database.update(pkgDistributions, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(pkgDistributionSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the List of Package Distributions to clear Manager Summary Common Id / Package Common Id / Failed Offer Communicator Ids / Failed Package Contact Ids.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    summaryFailure	                        DESCRIPTION (Data Type Boolean, True if the FailureHandlerJob is handling Summary Prep / Audit / Delivery failure)
    * @param    commonIds	                            DESCRIPTION (Data Type Set<String>, Set of Manager Summary / Package Common Ids to identify the Package Distributions)
    * @param    pkgDistributionIds	                    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @return   List<MA_DS_Package_Distribution__c>     DESCRIPTION (return List of Package Distributions)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<MA_DS_Package_Distribution__c> getPackageDistributions(Boolean summaryFailure, Set<String> commonIds, Set<Id> pkgDistributionIds) {
        String filters = getPackageDistributionsQueryFilters(summaryFailure, commonIds, pkgDistributionIds);
        String queryString = String.format(PKG_DISTRIBUTION_QUERY_STR, new String[] {String.join(pkgDistributionQueryFields, ', '), filters});
        Map<String, Object> bindMap = getPackageDistributionsQueryBindMap(commonIds, pkgDistributionIds);
        return getPackageDistributions(queryString, bindMap);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the Filters string, to be used to form the Package Distributions queryString (to fetch records dynamically using Database.queryWithBinds() method).
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    summaryFailure	                DESCRIPTION (Data Type Boolean, True if the FailureHandlerJob is handling Summary Prep / Audit / Delivery failure)
    * @param    commonIds	                    DESCRIPTION (Data Type Set<String>, Set of Manager Summary / Package Common Ids to identify the Package Distributions)
    * @param    pkgDistributionIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @return   String                          DESCRIPTION (return Filters string, used to form the Package Distributions queryString)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getPackageDistributionsQueryFilters(Boolean summaryFailure, Set<String> commonIds, Set<Id> pkgDistributionIds) {
        return (pkgDistributionIds != null && pkgDistributionIds.size() > 0) ? String.format(PKG_DIST_IDS_FILTER, new String[] {PKG_DIST_IDS_VAR}) : 
               (summaryFailure && commonIds != null && commonIds.size() > 0) ? String.format(PKG_DIST_SUMMARY_COMMON_IDS_FILTER, new String[] {PKG_DIST_SUMMARY_COMMON_IDS_VAR}) : '';
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the bindMap for the Package Distributions queryString, sets value for all the Bind Variables used in the queryString.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    commonIds	                    DESCRIPTION (Data Type Set<String>, Set of Manager Summary / Package Common Ids to identify the Package Distributions)
    * @param    pkgDistributionIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @return   Map<String, Object>             DESCRIPTION (return bindMap for the Package Distributions queryString)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, Object> getPackageDistributionsQueryBindMap(Set<String> commonIds, Set<Id> pkgDistributionIds) {
        Map<String, Object> bindMap = new Map<String, Object>();
        bindMap.put(PKG_DIST_IDS_VAR, pkgDistributionIds);
        bindMap.put(PKG_DIST_SUMMARY_COMMON_IDS_VAR, commonIds);
        return bindMap;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to execute the Database.queryWithBinds() & return the List of Package Distributions retrieved by the dynamic query string.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    queryString                                 DESCRIPTION (Data Type String, Query String to use in Database.queryWithBinds() method)
    * @param    bindMap                                     DESCRIPTION (Data Type Map<String, Object>, bindMap wrapped in the QueryWrapper instance)
    * @return   List<MA_DS_Package_Distribution__c>         DESCRIPTION (return List of Package Distributions)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<MA_DS_Package_Distribution__c> getPackageDistributions(String queryString, Map<String, Object> bindMap) {
        List<MA_DS_Package_Distribution__c> pkgDistributions = new List<MA_DS_Package_Distribution__c>();

        try {
            pkgDistributions.addAll((List<MA_DS_Package_Distribution__c>)Database.queryWithBinds(queryString, bindMap, AccessLevel.SYSTEM_MODE));
        }catch(QueryException exType) {
            MA_AbstractLogger.logException(exType, MA_DS_FailureHandlerUtility.class.getName());
        }

        return pkgDistributions;
    }
}