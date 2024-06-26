/**
 * ******************************************** W-12578108 : RULE ENGINE ********************************************
 * 
 * Utility class for AppliedRuleJob & AppliedRuleJobFinalizer implementations within MA_DS_TemplateAppliedRuleSyncService.
 * Processes In Use Template type Applied Rules, by finding the eligible Acquisition Contacts and Upserting the Applied Rules.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         20/03/2023      Chakshu Malhotra        W-12578108 - Adds utility methods to process In Use Template type Applied Rules.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_TemplateAppliedRuleSyncUtility {

    private static final String PARENT_QUERY_STRING = 'SELECT Id,';
    private static final String UPDATED_PARENT_QUERY_STRING = 'SELECT {0}';

    private static final String CHILD_QUERY_STRING = 'SELECT Id FROM {0}';
    private static final String UPDATED_CHILD_QUERY_STRING = 'SELECT {0} FROM {1}';

    private static final String RULE_TYPE_VAR = 'ruleType';
    private static final String PKG_DIST_VAR = 'pkgDistributionId';
    private static final String ASYNC_APEX_JOBS_VAR = 'asyncApexJobIds';
    private static final String LAST_RECORD_ID_VAR = 'lastRecordId';
    private static final String QUERY_SIZE_LIMIT_VAR = 'querySizeLimit';
    private static final String ACQ_CONTACT_IDS_VAR = 'acqContactIds';

    private static final String RULE_TYPE_FILTER = 'MA_DS_Rule_Type__c = :{0}';
    private static final String PKG_DIST_FILTER = ' AND MA_DS_Package_Distribution__c = :{0}';
    private static final String ASYNC_APEX_JOBS_FILTER = ' AND MA_DS_Async_Apex_Job_Id__c IN :{0}';
    private static final String LAST_RECORD_ID_FILTER = ' AND Id > :{0}';
    private static final String QUERY_SIZE_LIMIT_FILTER = ' ORDER BY Id ASC LIMIT :{0}';
    private static final String ACQ_CONTACT_IDS_FILTER = ' AND Id IN :{0}';

    private static final String APPLIED_RULE_QUERY_STRING = 'SELECT Id, MA_DS_Acquisition_Contact__c FROM MA_DS_Applied_Rule__c WHERE {0}';

    private static final String IN_USE_TEMPLATE_APPLIED_RULE = Label.MA_DS_IUT_Type_Applied_Rule;
    private static final String PACKAGE_DISTRIBUTION_APPLIED_RULE = Label.MA_DS_PD_Type_Applied_Rule;

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the RulesQueryWithFlagsWrapper instance to initialize AppliedRuleJob Params.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    inUseTemplateId	                    DESCRIPTION (Data Type Id, In Use Template record Id in process)
    * @param    acqCompanyId	                    DESCRIPTION (Data Type Id, Acquisition Company record Id of the Package record)
    * @param    parentSObject	                    DESCRIPTION (Data Type String, Parent SObject Name in the Rules Criteria Query string)
    * @param    childRelationshipMap	            DESCRIPTION (Data Type Map<String, String> Map of Child SObject to its Relationship Name)
    * @return   RulesQueryWithFlagsWrapper          DESCRIPTION (return RulesQueryWithFlagsWrapper instance)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static RulesQueryWithFlagsWrapper getRulesQueryWithFlagsWrapper(Id inUseTemplateId, Id acqCompanyId, String parentSObject, Map<String, String> childRelationshipMap) {
        MA_DS_In_Use_Template__c inUseTemplate = getInUseTemplate(inUseTemplateId);
        Boolean suppressRulesCriteria = inUseTemplate.MA_DS_Suppress_Rules_Criteria__c;

        String serializedRulesJSON = inUseTemplate.MA_DS_Rules_Criteria_JSON__c;
        String serializedRulesQuery = inUseTemplate.MA_DS_Rules_Criteria_Query__c;
        String serializedQueryWrapper = suppressRulesCriteria ? getDefaultSerializedQueryWrapper(parentSObject, childRelationshipMap) : serializedRulesQuery;
        
        Boolean defaultParentQuery = (suppressRulesCriteria || !(MA_DS_AppliedRulesServiceUtility.hasFiltersOnParentSObject(parentSObject, serializedRulesJSON)));
        MA_DS_RulesCriteriaQueryParser.QueryWrapper rulesQueryWrapper = MA_DS_AppliedRulesServiceUtility.getRulesQueryWrapper(acqCompanyId, inUseTemplateId, serializedQueryWrapper, defaultParentQuery);
        return getRulesQueryWithFlagsWrapper(inUseTemplate, parentSObject, childRelationshipMap, rulesQueryWrapper);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the In Use Template record.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    inUseTemplateId	                DESCRIPTION (Data Type Id, In Use Template record Id in process)
    * @return   MA_DS_In_Use_Template__c        DESCRIPTION (return In Use Template record)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static MA_DS_In_Use_Template__c getInUseTemplate(Id inUseTemplateId) {
        return [SELECT Id, MA_DS_Audit_All__c, MA_DS_Template_Being_Used__c, MA_DS_Suppress_Audit_Flags__c, MA_DS_Audit_Flags_JSON__c, MA_DS_Suppress_Rules_Criteria__c, MA_DS_Rules_Criteria_Query__c,
                MA_DS_Rules_Criteria_JSON__c, MA_DS_Template_Being_Used__r.MA_DS_Template_Document_Type__c 
                FROM MA_DS_In_Use_Template__c
                WHERE Id = :inUseTemplateId LIMIT 1];
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the default Serialized Query Wrapper when Rules Criteria is suppressed.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    parentSObject	                    DESCRIPTION (Data Type String, Parent SObject Name in the Rules Criteria Query string)
    * @param    childRelationshipMap	            DESCRIPTION (Data Type Map<String, String> Map of Child SObject to its Relationship Name)
    * @return   String                              DESCRIPTION (return Default Serialized QueryWrapper string)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getDefaultSerializedQueryWrapper(String parentSObject, Map<String, String> childRelationshipMap) {
        Map<String, Object> bindMap = new Map<String, Object>();
        Map<String, String> bindTypeMap = new Map<String, String>();
        String queryString = 'SELECT Id, ' + getDefaultChildQueriesString(childRelationshipMap) + ' FROM ' + parentSObject;
        return MA_DS_RulesCriteriaQueryParser.instance.setQueryWrapper(queryString, bindMap, bindTypeMap)
                                                      .validateQueryString()
                                                      .getSerializedQueryWrapper();
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & return the query string for the Child SObject based on the childRelationshipMap.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    childRelationshipMap	            DESCRIPTION (Data Type Map<String, String> Map of Child SObject to its Relationship Name)
    * @return   String                              DESCRIPTION (return Query string for the Child SObjects)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getDefaultChildQueriesString(Map<String, String> childRelationshipMap) {
        String childQueriesString = '';

        for(String childSObjectName : childRelationshipMap.keySet()) {
            childQueriesString += String.isBlank(childQueriesString) ? '' : ', ';
            childQueriesString += '(' + String.format(CHILD_QUERY_STRING, new String[] {childRelationshipMap.get(childSObjectName)}) + ' LIMIT 1)';
        }

        return childQueriesString;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the RulesQueryWithFlagsWrapper instance to initialize AppliedRuleJob Params, updates Rules QueryWrapper queryString with the Audit Field Flags.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    inUseTemplateId	                    DESCRIPTION (Data Type Id, In Use Template record Id in process)
    * @param    parentSObject	                    DESCRIPTION (Data Type String, Parent SObject Name in the Rules Criteria Query string)
    * @param    childRelationshipMap	            DESCRIPTION (Data Type Map<String, String> Map of Child SObject to its Relationship Name)
    * @param    rulesQueryWrapper	                DESCRIPTION (Data Type MA_DS_RulesCriteriaQueryParser.QueryWrapperMap Instance of QueryWrapper containing queryString & bindMap)
    * @return   RulesQueryWithFlagsWrapper          DESCRIPTION (return RulesQueryWithFlagsWrapper instance)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static RulesQueryWithFlagsWrapper getRulesQueryWithFlagsWrapper(MA_DS_In_Use_Template__c inUseTemplate, String parentSObject, Map<String, String> childRelationshipMap, MA_DS_RulesCriteriaQueryParser.QueryWrapper rulesQueryWrapper) {
        RulesQueryWithFlagsWrapper wrapperInstance = new RulesQueryWithFlagsWrapper();
        wrapperInstance.rulesQueryWrapper = rulesQueryWrapper;
        wrapperInstance.auditAll = inUseTemplate.MA_DS_Audit_All__c;
        wrapperInstance.templateId = inUseTemplate.MA_DS_Template_Being_Used__c;
        wrapperInstance.templateDocumentType = inUseTemplate.MA_DS_Template_Being_Used__r.MA_DS_Template_Document_Type__c;
        Boolean suppressFlags = (inUseTemplate.MA_DS_Audit_All__c || inUseTemplate.MA_DS_Suppress_Audit_Flags__c);
        
        if(!suppressFlags) {
            updateRulesQueryWithFlagsWrapper(wrapperInstance, inUseTemplate, parentSObject, childRelationshipMap);
        }

        return wrapperInstance;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the Rules QueryWrapper queryString with the Audit Field Flags and create auditFlagsTypeMap, auditFlagsSampleSizeMap & auditFlagsFieldMap to be used to initialize AppliedRuleJob Params for each IUT.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    wrapperInstance	                    DESCRIPTION (Data Type RulesQueryWithFlagsWrapper, RulesQueryWithFlagsWrapper instance containing Rules QueryWrapper with Audit Field Flags details)
    * @param    inUseTemplate	                    DESCRIPTION (Data Type MA_DS_In_Use_Template__c, In Use Template record in process)
    * @param    parentSObject	                    DESCRIPTION (Data Type String, Parent SObject Name in the Rules Criteria Query string)
    * @param    childRelationshipMap	            DESCRIPTION (Data Type Map<String, String> Map of Child SObject to its Relationship Name)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateRulesQueryWithFlagsWrapper(RulesQueryWithFlagsWrapper wrapperInstance, MA_DS_In_Use_Template__c inUseTemplate, String parentSObject, Map<String, String> childRelationshipMap) {
        Type auditFlagsJSONApexType = Map<String, Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper>>.class;
        Map<String, Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper>> auditFlagsMap = (Map<String, Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper>>)JSON.deserialize(inUseTemplate.MA_DS_Audit_Flags_JSON__c, auditFlagsJSONApexType);

        for(String sObjectName : auditFlagsMap.keySet()) {
            String sObjectKey = sObjectName.equalsIgnoreCase(parentSObject) ? sObjectName : childRelationshipMap.get(sObjectName);
            Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper> fieldMap = auditFlagsMap.get(sObjectName);

            for(String fieldKey : fieldMap.keySet()) {
                String concatenatedKey = sObjectKey + fieldKey;
                wrapperInstance.auditFlagsTypeMap.put(concatenatedKey, fieldMap.get(fieldKey).type);
                wrapperInstance.auditFlagsSampleSizeMap.put(concatenatedKey, fieldMap.get(fieldKey).sampleSize);
            }

            wrapperInstance.auditFlagsFieldMap.put(sObjectKey, new List<String>(fieldMap.keySet()));
        }

        updateRulesQueryWrapper(wrapperInstance, parentSObject);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the Rules QueryWrapper queryString with the Audit Field List (updates parent SObject as well child SObject queries in the queryString).
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    wrapperInstance	                    DESCRIPTION (Data Type RulesQueryWithFlagsWrapper, RulesQueryWithFlagsWrapper instance containing Rules QueryWrapper with Audit Field Flags details)
    * @param    parentSObject	                    DESCRIPTION (Data Type String, Parent SObject Name in the Rules Criteria Query string)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateRulesQueryWrapper(RulesQueryWithFlagsWrapper wrapperInstance, String parentSObject) {
        for(String sObjectKey : wrapperInstance.auditFlagsFieldMap.keySet()) {
            String queryString = wrapperInstance.rulesQueryWrapper.queryString;
            List<String> fieldList = wrapperInstance.auditFlagsFieldMap.get(sObjectKey);

            if(sObjectKey.equalsIgnoreCase(parentSObject)) {
                wrapperInstance.rulesQueryWrapper.queryString = getUpdatedParentQueryString(queryString, getFieldListString(fieldList, true));
            }else {
                wrapperInstance.rulesQueryWrapper.queryString = getUpdatedChildQueryString(queryString, getFieldListString(fieldList, false), sObjectKey);
            }
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the updated Field List string to be used as replacement for the old Field List of the queryString.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    fieldList	                    DESCRIPTION (Data Type List<String>, List of fields as received from the auditFlagsJSON map)
    * @param    isParentSObject	                DESCRIPTION (Data Type Boolean, True if the fieldListString is meant for the Parent SObject)
    * @return   String                          DESCRIPTION (return fieldListString to be used as replacement for the old Field List of the queryString)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getFieldListString(List<String> fieldList, Boolean isParentSObject) {
        String fieldListString = 'Id';

        for(String field : fieldList) {
            fieldListString += ', ' + field;
        }

        return isParentSObject ? (fieldListString + ',') : fieldListString;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the updated Parent SObject queryString by replacing the old Field List string with the new fieldListString.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    queryString	                    DESCRIPTION (Data Type String, The original queryString to replace the old Field List string)
    * @param    fieldListString	                DESCRIPTION (Data Type String, Comma-separated new Field List String for the SObject)
    * @return   String                          DESCRIPTION (return the updated queryString by replacing the old Field List String for the SObject)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getUpdatedParentQueryString(String queryString, String fieldListString) {
        String updatedParentQueryString = String.format(UPDATED_PARENT_QUERY_STRING, new String[] {fieldListString});
        return queryString.replace(PARENT_QUERY_STRING, updatedParentQueryString);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the updated Child SObject queryString by replacing the old Field List string with the new fieldListString.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    queryString	                    DESCRIPTION (Data Type String, The original queryString to replace the old Field List string)
    * @param    fieldListString	                DESCRIPTION (Data Type String, Comma-separated new Field List String for the SObject)
    * @param    childRelationshipNAme	        DESCRIPTION (Data Type String, Child SObject relationship name)
    * @return   String                          DESCRIPTION (return the updated queryString by replacing the old Field List String for the SObject)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getUpdatedChildQueryString(String queryString, String fieldListString, String childRelationshipName) {
        String childQueryReplacedString = String.format(CHILD_QUERY_STRING, new String[] {childRelationshipName});
        String updatedChildQueryString = String.format(UPDATED_CHILD_QUERY_STRING, new String[] {fieldListString, childRelationshipName});
        return queryString.replace(childQueryReplacedString, updatedChildQueryString);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get Package Distribution type Applied Rule records to be used to find eligible Acquisition Contacts for In Use Template type Applied Rules.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	                DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    asyncApexJobIds	                    DESCRIPTION (Data Type Set<Id>, AsyncApexJob Ids of the Package Distribution type Applied Rules)
    * @param    lastRecordId                        DESCRIPTION (Data Type Id, Last Record Id of the Applied Rule processed in the previous query)
    * @param    querySizeLimit	                    DESCRIPTION (Data Type Integer, Maximum number of records that are allowed to fetch in a single query)
    * @return   List<MA_DS_Applied_Rule__c>         DESCRIPTION (return Package Distribution type Applied Rule records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<MA_DS_Applied_Rule__c> getAppliedRules(Id pkgDistributionId, Set<Id> asyncApexJobIds, Id lastRecordId, Integer querySizeLimit) {
        String filters = getAppliedRuleQueryFilters(asyncApexJobIds, lastRecordId);
        String queryString = String.format(APPLIED_RULE_QUERY_STRING, new String[] {filters});
        Map<String, Object> bindMap = getAppliedRuleQueryBindMap(pkgDistributionId, asyncApexJobIds, lastRecordId, querySizeLimit);
        return getAppliedRules(queryString, bindMap);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the Filters string, to be used to form the Applied Rule queryString (to fetch records dynamically using Database.queryWithBinds() method).
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    asyncApexJobIds	                    DESCRIPTION (Data Type Set<Id>, AsyncApexJob Ids of the Package Distribution type Applied Rules)
    * @param    lastRecordId                        DESCRIPTION (Data Type Id, Last Record Id of the Applied Rule processed in the previous query)
    * @return   String                              DESCRIPTION (return Filters string, used to form the Applied Rule queryString)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getAppliedRuleQueryFilters(Set<Id> asyncApexJobIds, Id lastRecordId) {
        String filters = String.format(RULE_TYPE_FILTER, new String[] {RULE_TYPE_VAR});
        filters += String.format(PKG_DIST_FILTER, new String[] {PKG_DIST_VAR});
        filters += (asyncApexJobIds.size() > 0) ? String.format(ASYNC_APEX_JOBS_FILTER, new String[] {ASYNC_APEX_JOBS_VAR}) : '';
        filters += (lastRecordId != null) ? String.format(LAST_RECORD_ID_FILTER, new String[] {LAST_RECORD_ID_VAR}) : '';
        filters += String.format(QUERY_SIZE_LIMIT_FILTER, new String[] {QUERY_SIZE_LIMIT_VAR});
        return filters;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the bindMap for the Applied Rule queryString, sets value for all the Bind Variables used in the queryString.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	                DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    asyncApexJobIds	                    DESCRIPTION (Data Type Set<Id>, AsyncApexJob Ids of the Package Distribution type Applied Rules)
    * @param    lastRecordId                        DESCRIPTION (Data Type Id, Last Record Id of the Applied Rule processed in the previous query)
    * @param    querySizeLimit	                    DESCRIPTION (Data Type Integer, Maximum number of records that are allowed to fetch in a single query)
    * @return   Map<String, Object>                 DESCRIPTION (return bindMap for the Applied Rule queryString)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, Object> getAppliedRuleQueryBindMap(Id pkgDistributionId, Set<Id> asyncApexJobIds, Id lastRecordId, Integer querySizeLimit) {
        Map<String, Object> bindMap = new Map<String, Object>();
        bindMap.put(RULE_TYPE_VAR, PACKAGE_DISTRIBUTION_APPLIED_RULE);
        bindMap.put(PKG_DIST_VAR, pkgDistributionId);
        bindMap.put(ASYNC_APEX_JOBS_VAR, asyncApexJobIds);
        bindMap.put(LAST_RECORD_ID_VAR, lastRecordId);
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
    private static List<MA_DS_Applied_Rule__c> getAppliedRules(String queryString, Map<String, Object> bindMap) {
        List<MA_DS_Applied_Rule__c> appliedRules = new List<MA_DS_Applied_Rule__c>();

        try {
            appliedRules.addAll((List<MA_DS_Applied_Rule__c>)Database.queryWithBinds(queryString, bindMap, AccessLevel.SYSTEM_MODE));
        }catch(QueryException exType) {
            MA_AbstractLogger.logException(exType, MA_DS_TemplateAppliedRuleSyncUtility.class.getName());
        }

        return appliedRules;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch eligible Acquisition Contact records based on the Acquisition Contact Ids as extracted from the Package Distribution type Applied Rules.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqContactIds                           DESCRIPTION (Data Type Set<Id>, Set of Acquisition Contact record Ids)
    * @param    rulesQueryWrapper                       DESCRIPTION (Data Type MA_DS_RulesCriteriaQueryParser.QueryWrapper instance containing queryString and bindMap)
    * @return   List<Acquisition_Contacts__c>           DESCRIPTION (return List of Acquisition Contact records based on Acquisition Contact Ids from Applied Rules)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Acquisition_Contacts__c> getEligibleAcquisitionContacts(Set<Id> acqContactIds, MA_DS_RulesCriteriaQueryParser.QueryWrapper rulesQueryWrapper) {
        List<Acquisition_Contacts__c> acqContacts = new List<Acquisition_Contacts__c>();

        for(Acquisition_Contacts__c acqContact : getAcquisitionContacts(acqContactIds, rulesQueryWrapper.queryString, rulesQueryWrapper.bindMap)) {
            if(acqContact.Acquisition_Compensation__r != null && acqContact.Acquisition_Compensation__r.size() > 0) {
                acqContacts.add(acqContact);
            }
        }

        return acqContacts;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch eligible Acquisition Contact records based on the Acquisition Contact Ids & QueryWrapper instance formed out of Rules Criteria Query (or default Query if rules are suppressed).
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqContactIds                       DESCRIPTION (Data Type Set<Id>, Set of Acquisition Contact record Ids)
    * @param    queryString                         DESCRIPTION (Data Type String, Query String to use in Database.queryWithBinds() method)
    * @param    bindMap                             DESCRIPTION (Data Type Map<String, Object>, bindMap wrapped in the QueryWrapper instance)
    * @return   List<Acquisition_Contacts__c>       DESCRIPTION (return List of Acquisition Contact records based on Acquisition Contact Ids from Applied Rules)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<Acquisition_Contacts__c> getAcquisitionContacts(Set<Id> acqContactIds, String queryString, Map<String, Object> bindMap) {
        queryString += String.format(ACQ_CONTACT_IDS_FILTER, new String[] {ACQ_CONTACT_IDS_VAR});
        bindMap.put(ACQ_CONTACT_IDS_VAR, acqContactIds);
        return getAcquisitionContacts(queryString, bindMap);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to execute the Database.queryWithBinds() & return the Acquisition Contacts retrieved by the dynamic query string.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    queryString                         DESCRIPTION (Data Type String, Query String to use in Database.queryWithBinds() method)
    * @param    bindMap                             DESCRIPTION (Data Type Map<String, Object>, bindMap wrapped in the QueryWrapper instance)
    * @return   List<Acquisition_Contacts__c>       DESCRIPTION (return List of Acquisition Contact records based on Acquisition Contact Ids from Applied Rules)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<Acquisition_Contacts__c> getAcquisitionContacts(String queryString, Map<String, Object> bindMap) {
        List<Acquisition_Contacts__c> acqContacts = new List<Acquisition_Contacts__c>();

        try {
            acqContacts.addAll((List<Acquisition_Contacts__c>)Database.queryWithBinds(queryString, bindMap, AccessLevel.SYSTEM_MODE));
        }catch(QueryException exType) {
            MA_AbstractLogger.logException(exType, MA_DS_TemplateAppliedRuleSyncUtility.class.getName());
        }

        return acqContacts;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the List of Applied Audit Flag Keys, to be set on Applied Rule record (for Audit process).
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqContact                  DESCRIPTION (Data Acquisition_Contacts__c String, Acquisition Contact record to look for the Audit Field values)
    * @param    parentSObject               DESCRIPTION (Data Type String, Parent SObject Name in the queryString)
    * @param    auditFlagsFieldMap          DESCRIPTION (Data Type Map<String, List<String>>, Map of sObjectKey => List of Audit Field Flags as received from auditFlagsJSON)
    * @param    auditFlagsTypeMap           DESCRIPTION (Data Type Map<String, String>, Map of (sObjectKey + fieldKey) => Audit Field Type)
    * @param    auditFlagsSampleSizeMap     DESCRIPTION (Data Type Map<String, Integer>, Map of (sObjectKey + fieldKey) => Audit Field Sample Size)
    * @param    appliedAuditFlagsMap        DESCRIPTION (Data Type Map<String, Integer>, Map of (sObjectKey + fieldKey + Audit Flag Key) => Applied Sample Size)
    * @return   List<String>                DESCRIPTION (return List of Applied Audit Flag Keys)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<String> getAppliedAuditFlagKeys(Acquisition_Contacts__c acqContact, String parentSObject, Map<String, List<String>> auditFlagsFieldMap, Map<String, String> auditFlagsTypeMap, 
                                                       Map<String, Integer> auditFlagsSampleSizeMap, Map<String, Integer> appliedAuditFlagsMap) {
        Set<String> appliedAuditFlagKeys = new Set<String>();
        
        for(String sObjectKey : auditFlagsFieldMap.keySet()) {
            for(String fieldKey : auditFlagsFieldMap.get(sObjectKey)) {
                String concatenatedkey = sObjectKey + fieldKey;
                
                String fieldType = auditFlagsTypeMap.get(concatenatedkey);
                Integer maxSampleSize = auditFlagsSampleSizeMap.get(concatenatedkey);

                Object fieldValue = sObjectKey.equalsIgnoreCase(parentSObject) ? acqContact.get(fieldKey) : acqContact.getSObjects(sObjectKey)[0].get(fieldKey);
                String appliedAuditFlagKey = MA_DS_RulesCriteriaQueryFormatter.strategy.getAppliedAuditFlagKey(concatenatedKey, fieldValue, fieldType);

                if(updateAppliedAuditFlagsMap(appliedAuditFlagsMap, appliedAuditFlagKey, maxSampleSize)) {
                    appliedAuditFlagKeys.add(appliedAuditFlagKey);
                }
            }
        }

        return new List<String>(appliedAuditFlagKeys);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update appliedAuditFlagsMap to store the Applied Audit Field => Applied Sample Size and checks whether Acquisition Contact need to be Flagged for Audit for a given Field.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    appliedAuditFlagsMap        DESCRIPTION (Data Type Map<String, Integer>, Map of (sObjectKey + fieldKey + Audit Flag Key) => Applied Sample Size)
    * @param    appliedAuditFlagKey         DESCRIPTION (Data Type String, Applied Audit Flag Key as retrieved based on the fieldType & fieldValue (Flag Key: SObjectKey + fieldKey + fieldValue))
    * @param    maxSampleSize               DESCRIPTION (Data Type Integer, Maximum Sample Size to check for flagging Acquisition Contact for Audit)
    * @return   Boolean                     DESCRIPTION (return True if Acquisition Contact is to be flagged for Audit for a given Field)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean updateAppliedAuditFlagsMap(Map<String, Integer> appliedAuditFlagsMap, String appliedAuditFlagKey, Integer maxSampleSize) {
        Boolean updated = false;
        Boolean containsAppliedAuditFlagKey = appliedAuditFlagsMap.containsKey(appliedAuditFlagKey);
        Integer appliedSampleSize = containsAppliedAuditFlagKey ? appliedAuditFlagsMap.get(appliedAuditFlagKey) : 0;

        if(appliedSampleSize < maxSampleSize) {
            updated = true;
            appliedAuditFlagsMap.put(appliedAuditFlagKey, (appliedSampleSize + 1));
        }

        return updated;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get each updated Applied Rule record of type In Use Template, to be upserted by the AppliedRuleJob.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	            DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    templateId	                    DESCRIPTION (Data Type Id, Template being used by the In Use Template record)
    * @param    templateDocumentType	        DESCRIPTION (Data Type Id, Document type of the Template record)
    * @param    acqContactId	                DESCRIPTION (Data Type Id, Each eligible Acquisition Contact Id based on the Rules Critery Query)
    * @param    asyncApexJobId	                DESCRIPTION (Data Type Id, Current AsyncApexJob Id of the AppliedRuleJob that is processing the Applied Rule records)
    * @param    auditAll	                    DESCRIPTION (Data Type Boolean, True if Audit All field is checked on the In Use Template record)
    * @param    flaggedFields	                DESCRIPTION (Data Type List<String>, Flagged Audit Fields for the Audit process)
    * @return   MA_DS_Applied_Rule__c           DESCRIPTION (return the Applied Rule record to be upserted by the AppliedRuleJob)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static MA_DS_Applied_Rule__c getAppliedRule(Id pkgDistributionId, Id templateId, String templateDocumentType, Id acqContactId, Id asynApexJobId, Boolean auditAll, List<String> flaggedFields) {
        MA_DS_Applied_Rule__c appliedRule = new MA_DS_Applied_Rule__c();
        appliedRule.MA_DS_Template__c = templateId;
        appliedRule.MA_DS_Need_To_Generate__c = true;
        appliedRule.MA_DS_Async_Apex_Job_Id__c = asynApexJobId;
        appliedRule.MA_DS_Acquisition_Contact__c = acqContactId;
        appliedRule.MA_DS_Package_Distribution__c = pkgDistributionId;
        appliedRule.MA_DS_Rule_Type__c = IN_USE_TEMPLATE_APPLIED_RULE;
        appliedRule.MA_DS_Template_Document_Type__c = templateDocumentType;
        appliedRule.MA_DS_Flagged_Fields__c = JSON.serialize(flaggedFields);
        appliedRule.MA_DS_Flagged_For_Audit__c = (flaggedFields.size() > 0) || auditAll;
        appliedRule.MA_DS_Concatenated_Id__c = String.valueOf(pkgDistributionId) + String.valueOf(templateId) + String.valueOf(acqContactId);
        return appliedRule;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to bulk upsert In Use Template type Applied Rule records using MA_DS_Concatenated_Id__c as the external Id.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    appliedRules 	    DESCRIPTION (Data type List<MA_DS_Applied_Rule__c>, List of In Use Template type Applied Rule records)
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
    * Method to update the In Use Template record with Applied Audit Flags JSON & save the current sync state as well.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	            DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    inUseTemplateId	                DESCRIPTION (Data Type Id, In Use Template record Id)
    * @param    appliedAuditFlagsMap	        DESCRIPTION (Data Type Map<String, Integer>, Flagged fields map, used for Audit process)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updateInUseTemplate(Id pkgDistributionId, Id inUseTemplateId, Map<String, Integer> appliedAuditFlagsMap) {
        List<MA_DS_In_Use_Template__c> inUseTemplateList = [SELECT Id, MA_DS_Rules_Criteria_Query__c, MA_DS_Rules_Criteria_JSON__c, MA_DS_Audit_Flags_JSON__c, MA_DS_Applied_Audit_Flags_JSON__c, 
                                                            MA_DS_Last_Synced_Criteria_Query__c, MA_DS_Last_Synced_Audit_Flags_JSON__c, MA_DS_Last_Synced_Rules_Criteria_JSON__c, MA_DS_Sync_Rules_On_PD_Ids__c
                                                            FROM MA_DS_In_Use_Template__c
                                                            WHERE Id = :inUseTemplateId LIMIT 1];
        if(inUseTemplateList.size() > 0) {
            MA_DS_In_Use_Template__c inUseTemplate = inUseTemplateList[0];
            updateSyncRulesOnPDIdsIfNeeded(inUseTemplate, pkgDistributionId);
            updateAppliedAuditFlagsIfNeeded(pkgDistributionId, inUseTemplate, appliedAuditFlagsMap);
            inUseTemplate.MA_DS_Last_Synced_Audit_Flags_JSON__c = inUseTemplate.MA_DS_Audit_Flags_JSON__c;
            inUseTemplate.MA_DS_Last_Synced_Criteria_Query__c = inUseTemplate.MA_DS_Rules_Criteria_Query__c;
            inUseTemplate.MA_DS_Last_Synced_Rules_Criteria_JSON__c = inUseTemplate.MA_DS_Rules_Criteria_JSON__c;

            MA_DS_InUseTemplateTriggerHandler.triggerDisabled = true;
            List<Database.SaveResult> iutSRList = Database.update(inUseTemplateList, false);
            MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(iutSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the In Use Template record with Rules Sync On PD Ids, removes pkgDistributionId (if Job started as a result of syncing Template Rules)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    inUseTemplate	                DESCRIPTION (Data Type MA_DS_In_Use_Template__c, In Use Template record in process)
    * @param    pkgDistributionId	            DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateSyncRulesOnPDIdsIfNeeded(MA_DS_In_Use_Template__c inUseTemplate, Id pkgDistributionId) {
        String serializedPDIds = inUseTemplate.MA_DS_Sync_Rules_On_PD_Ids__c;

        if(serializedPDIds != null) {
            Set<String> pdIds = new Set<String>((List<String>)JSON.deserialize(serializedPDIds, List<String>.class));
            pdIds.remove(String.valueOf(pkgDistributionId));
            inUseTemplate.MA_DS_Sync_Rules_On_PD_Ids__c = JSON.serialize(new List<String>(pdIds));
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the In Use Template record with Applied Audit Flags Map for a given pkgDistributionId, if needed.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	            DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    inUseTemplate	                DESCRIPTION (Data Type MA_DS_In_Use_Template__c, In Use Template record in process)
    * @param    appliedAuditFlagsMap	        DESCRIPTION (Data Type Map<String, Integer>, Applied Audit Flags Map)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateAppliedAuditFlagsIfNeeded(Id pkgDistributionId, MA_DS_In_Use_Template__c inUseTemplate, Map<String, Integer> appliedAuditFlagsMap) {
        Map<String, Map<String, Integer>> appliedAuditFlagsJSON = getAppliedAuditFlagsJSON(inUseTemplate.MA_DS_Applied_Audit_Flags_JSON__c);

        if(appliedAuditFlagsMap.size() > 0) {
            appliedAuditFlagsJSON.put(pkgDistributionId, appliedAuditFlagsMap);
        }else {
            appliedAuditFlagsJSON.remove(pkgDistributionId);
        }

        inUseTemplate.MA_DS_Applied_Audit_Flags_JSON__c = (appliedAuditFlagsJSON.size() > 0) ? JSON.serialize(appliedAuditFlagsJSON) : null;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to de-serialize the MA_DS_Applied_Audit_Flags_JSON__c from the In Use Template record.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    appliedAuditFlagsJSON	                DESCRIPTION (Data Type Id, Serialized form of Applied Audit Flags JSON)
    * @return   Map<String, Map<String, Integer>>       DESCRIPTION (return the Map of pkgDistributionId => (appliedAuditFlagKey => appliedSampleSize))
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, Map<String, Integer>> getAppliedAuditFlagsJSON(String appliedAuditFlagsJSON) {
        Type appliedAuditFlagsJSONType = Map<String, Map<String, Integer>>.class;
        return (appliedAuditFlagsJSON == null) ? new Map<String, Map<String, Integer>>() : 
                (Map<String, Map<String, Integer>>)JSON.deserialize(appliedAuditFlagsJSON, appliedAuditFlagsJSONType);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize & enqueue the AppliedRuleJob to purge the Package Distribution & In Use Template type Applied Rules.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	                DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    summaryDocRuleSync	                DESCRIPTION (Data Type Boolean, True if Rules are synced for Manager Summary Document template)
    * @param    packageDocRuleSync	                DESCRIPTION (Data Type Boolean, True if Rules are synced for atleast one Package Document template)
    * @param    originExecJob	                    DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionJob, ExecutionJob enum type of the first Job that initiated the Rule Sync process)
    * @param    originExecMode	                    DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionMode, ExecutionMode enum type)
    * @param    asyncApexJobIds	                    DESCRIPTION (Data Type Set<Id>, AsyncApexJob Ids of the Queueable Jobs that processed the Applied Rules)
    * @param    templateIds	                        DESCRIPTION (Data Type List<Id>, List of referenced Template Ids of the In Use Templates)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void initPurgeAppliedRuleJob(Id pkgDistributionId, Boolean summaryDocRuleSync, Boolean packageDocRuleSync, MA_DS_AppliedRulesService.ExecutionJob originExecJob, MA_DS_AppliedRulesService.ExecutionMode originExecMode, Set<Id> asyncApexJobIds, List<Id> templateIds) {
        MA_DS_AppliedRulesService.strategyInstance.setExecutionModeEnum(originExecMode)
                                                  .setExecutionJobEnum(MA_DS_AppliedRulesService.ExecutionJob.PURGE_RULE_SYNC)
                                                  .setOriginExecutionJobEnum(originExecJob)
                                                  .setPackageDistributionId(pkgDistributionId)
                                                  .setSummaryDocRuleSync(summaryDocRuleSync)
                                                  .setPackageDocRuleSync(packageDocRuleSync)
                                                  .setTemplateIds(templateIds)
                                                  .setAsyncApexJobIds(asyncApexJobIds)
                                                  .initAppliedRuleJob()
                                                  .execute();
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the Rules Query Wrapper instance and Audit Flag details to initializer the IUT JobParams.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class RulesQueryWithFlagsWrapper {
        public Id templateId {get; set;}
        public Boolean auditAll {get; set;}
        public String templateDocumentType {get; set;}
        public MA_DS_RulesCriteriaQueryParser.QueryWrapper rulesQueryWrapper {get; set;}

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Map of sObjName (parentSObject / childRelationshipName) to List of Audit Fields.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Map<String, List<String>> auditFlagsFieldMap {
            get {
                if(auditFlagsFieldMap == null) {
                    auditFlagsFieldMap = new Map<String, List<String>>();
                }
                return auditFlagsFieldMap;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Map of sObjName (parentSObject / childRelationshipName) + fieldKey => fieldType.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Map<String, String> auditFlagsTypeMap {
            get {
                if(auditFlagsTypeMap == null) {
                    auditFlagsTypeMap = new Map<String, String>();
                }
                return auditFlagsTypeMap;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Map of sObjName (parentSObject / childRelationshipName) + fieldKey => sampleSize.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Map<String, Integer> auditFlagsSampleSizeMap {
            get {
                if(auditFlagsSampleSizeMap == null) {
                    auditFlagsSampleSizeMap = new Map<String, Integer>();
                }
                return auditFlagsSampleSizeMap;
            }set;
        }
    }
}