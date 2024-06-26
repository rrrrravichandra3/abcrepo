/**
 * ******************************************** W-12578108 : RULE ENGINE ********************************************
 * 
 * Utility class for AppliedRuleJob & AppliedRuleJobFinalizer implementations within MA_DS_PackageAppliedRuleSyncService.
 * Processes Package Distribution type Applied Rules, by finding the eligible Acquisition Contacts and Upserting the Applied Rules.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         19/03/2023      Chakshu Malhotra        W-12578108 - Adds utility methods to process Package Distribution type Applied Rules.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_PackageAppliedRuleSyncUtility {

    private static final String LAST_RECORD_ID_FILTER = ' AND Id > :{0}';
    private static final String QUERY_SIZE_LIMIT_FILTER = ' ORDER BY Id ASC LIMIT :{0}';

    private static final String LAST_RECORD_ID_BIND_VAR_NAME = 'lastRecordId';
    private static final String QUERY_SIZE_LIMIT_BIND_VAR_NAME = 'querySizeLimit';

    private static final String PACKAGE_DISTRIBUTION_APPLIED_RULE = Label.MA_DS_PD_Type_Applied_Rule;
    private static final String SYNCING_TEMPLATE_RULES_STATUS = Label.MA_DS_Syncing_Templates_Rules_Status;
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Acquisition Contact Ids that satifies the Rules Criteria Query.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    rulesQueryWrapper   DESCRIPTION (Data Type MA_DS_RulesCriteriaQueryParser.QueryWrapper, QueryWrapper instance containing Query String and Bind Map)
    * @param    lastRecordId        DESCRIPTION (Data Type Id, Last Record Id of the Acquisition Contact processed in the previous query)
    * @param    querySizeLimit      DESCRIPTION (Data Type Integer, Maximum number of records allowed to fetch for the AppliedRuleJob)
    * @return   List<Id>            DESCRIPTION (return List of Acquisition Contact Ids)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Id> getEligibleAcquisitionContactIds(MA_DS_RulesCriteriaQueryParser.QueryWrapper rulesQueryWrapper, Id lastRecordId, Integer querySizeLimit) {
        String queryString = getQueryStringWithOrderAndLimit(rulesQueryWrapper.queryString, lastRecordId);
        updateBindMapWithOrderAndLimit(rulesQueryWrapper.bindMap, lastRecordId, querySizeLimit);
        return getEligibleAcquisitionContactIds(queryString, rulesQueryWrapper.bindMap);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the updated queryString after adding ORDER BY clause & LIMIT.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    queryString         DESCRIPTION (Data Type String, Query String wrapped in QueryWrapper instance)
    * @param    lastRecordId        DESCRIPTION (Data Type Id, Last Record Id of the Acquisition Contact processed in the previous query)
    * @return   String              DESCRIPTION (return Updated queryString after adding ORDER BY clause & LIMIT)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getQueryStringWithOrderAndLimit(String queryString, Id lastRecordId) {
        queryString += (lastRecordId == null) ? '' : String.format(LAST_RECORD_ID_FILTER, new String[] {LAST_RECORD_ID_BIND_VAR_NAME});
        queryString += String.format(QUERY_SIZE_LIMIT_FILTER, new String[] {QUERY_SIZE_LIMIT_BIND_VAR_NAME});
        return queryString;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the update the bindMap wrapped in the QueryWrapper instance.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    bindMap             DESCRIPTION (Data Type Map<String, Object>, bindMap wrapped in the QueryWrapper instance)
    * @param    lastRecordId        DESCRIPTION (Data Type Id, Last Record Id of the Acquisition Contact processed in the previous query)
    * @param    querySizeLimit      DESCRIPTION (Data Type Integer, Maximum number of records allowed to fetch for the AppliedRuleJob)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateBindMapWithOrderAndLimit(Map<String, Object> bindMap, Id lastRecordId, Integer querySizeLimit) {
        bindMap.put(LAST_RECORD_ID_BIND_VAR_NAME, lastRecordId);
        bindMap.put(QUERY_SIZE_LIMIT_BIND_VAR_NAME, querySizeLimit);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Acquisition Contact Ids that are retrieved by queryString and has Compensation details as well.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    queryString         DESCRIPTION (Data Type String, Query String to use in Database.queryWithBinds() method)
    * @param    bindMap             DESCRIPTION (Data Type Map<String, Object>, bindMap wrapped in the QueryWrapper instance)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<Id> getEligibleAcquisitionContactIds(String queryString, Map<String, Object> bindMap) {
        List<Id> acqContactIds = new List<Id>();
        for(Acquisition_Contacts__c acqContact : getAcquisitionContacts(queryString, bindMap)) {
            if(acqContact.Acquisition_Compensation__r != null && acqContact.Acquisition_Compensation__r.size() > 0) {
                acqContactIds.add(acqContact.Id);
            }
        }
        return acqContactIds;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to execute the Database.queryWithBinds() & return the Acquisition Contacts retrieved by the dynamic query string.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    queryString         DESCRIPTION (Data Type String, Query String to use in Database.queryWithBinds() method)
    * @param    bindMap             DESCRIPTION (Data Type Map<String, Object>, bindMap wrapped in the QueryWrapper instance)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<Acquisition_Contacts__c> getAcquisitionContacts(String queryString, Map<String, Object> bindMap) {
        List<Acquisition_Contacts__c> acqContacts = new List<Acquisition_Contacts__c>();

        try {
            acqContacts.addAll((List<Acquisition_Contacts__c>)Database.queryWithBinds(queryString, bindMap, AccessLevel.SYSTEM_MODE));
        }catch(QueryException exType) {
            MA_AbstractLogger.logException(exType, MA_DS_PackageAppliedRuleSyncUtility.class.getName());
        }

        return acqContacts;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the updated Applied Rule records of type Package Distribution, to be upserted by the AppliedRuleJob.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	            DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    acqContactIds	                DESCRIPTION (Data Type List<Id>, Eligible Acquisition Contact Ids based on the Rules Critery Query)
    * @param    asyncApexJobId	                DESCRIPTION (Data Type Id, Current AsyncApexJob Id of the AppliedRuleJob that is processing the Applied Rule records)
    * @return   List<MA_DS_Applied_Rule__c>     DESCRIPTION (return the Applied Rule record list to be upserted by the AppliedRuleJob)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<MA_DS_Applied_Rule__c> getAppliedRules(Id pkgDistributionId, List<Id> acqContactIds, Id asynApexJobId) {
        List<MA_DS_Applied_Rule__c> appliedRules = new List<MA_DS_Applied_Rule__c>();
        for(Id acqContactId : acqContactIds) {
            appliedRules.add(getAppliedRule(pkgDistributionId, acqContactId, asynApexJobId));
        }
        return appliedRules;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get each updated Applied Rule record of type Package Distribution, to be upserted by the AppliedRuleJob.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	            DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    acqContactId	                DESCRIPTION (Data Type Id, Each eligible Acquisition Contact Id based on the Rules Critery Query)
    * @param    asyncApexJobId	                DESCRIPTION (Data Type Id, Current AsyncApexJob Id of the AppliedRuleJob that is processing the Applied Rule records)
    * @return   MA_DS_Applied_Rule__c           DESCRIPTION (return the Applied Rule record to be upserted by the AppliedRuleJob)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static MA_DS_Applied_Rule__c getAppliedRule(Id pkgDistributionId, Id acqContactId, Id asynApexJobId) {
        MA_DS_Applied_Rule__c appliedRule = new MA_DS_Applied_Rule__c();
        appliedRule.MA_DS_Package_Rule_Applied__c = false;
        appliedRule.MA_DS_Async_Apex_Job_Id__c = asynApexJobId;
        appliedRule.MA_DS_Acquisition_Contact__c = acqContactId;
        appliedRule.MA_DS_Manager_Summary_Rule_Applied__c = false;
        appliedRule.MA_DS_Package_Distribution__c = pkgDistributionId;
        appliedRule.MA_DS_Rule_Type__c = PACKAGE_DISTRIBUTION_APPLIED_RULE;
        appliedRule.MA_DS_Concatenated_Id__c = String.valueOf(pkgDistributionId) + String.valueOf(acqContactId);
        return appliedRule;
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
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the Rules Sync Status of the Package Disitribution to indicate Template Rules Syncing.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	            DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updateRulesSyncStatusForTemplates(Id pkgDistributionId) {
        List<MA_DS_Package_Distribution__c> pkgDistributionList = [SELECT Id, MA_DS_Rules_Sync_Status__c
                                                                   FROM MA_DS_Package_Distribution__c
                                                                   WHERE Id = :pkgDistributionId LIMIT 1];
        if(pkgDistributionList.size() > 0) {
            pkgDistributionList[0].MA_DS_Rules_Sync_Status__c = SYNCING_TEMPLATE_RULES_STATUS;
            
            MA_DS_PackageDistributionTriggerHandler.triggerDisabled = true;
            List<Database.SaveResult> pkgDistSRList = Database.update(pkgDistributionList, false);
            MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(pkgDistSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize & enqueue the AppliedRuleJob to process the In Use Template type Applied Rules.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    originExecMode	                            DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionMode, ExecutionMode enum type)
    * @param    acqCompanyId	                            DESCRIPTION (Data Type Id, Acquisition Company record Id of the Package record)
    * @param    pkgId	                                    DESCRIPTION (Data Type Id, Package record Id of the Package Distribution record)
    * @param    pkgDistributionId	                        DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    asyncApexJobIds	                            DESCRIPTION (Data Type Set<Id>, AsyncApexJob Ids of the Queueable Jobs that processed all Package Distribution type Applied Rules)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void initTemplateAppliedRuleJob(MA_DS_AppliedRulesService.ExecutionMode originExecMode, Id acqCompanyId, Id pkgId, Id pkgDistributionId, Set<Id> asyncApexJobIds) {
        MA_DS_AppliedRulesService.strategyInstance.setExecutionModeEnum(originExecMode)
                                                  .setExecutionJobEnum(MA_DS_AppliedRulesService.ExecutionJob.TEMPLATE_RULE_SYNC)
                                                  .setAcquisitionCompanyId(acqCompanyId)
                                                  .setPackageId(pkgId)
                                                  .setPackageDistributionId(pkgDistributionId)
                                                  .setAsyncApexJobIds(asyncApexJobIds)
                                                  .initAppliedRuleJob()
                                                  .execute();
    }
}