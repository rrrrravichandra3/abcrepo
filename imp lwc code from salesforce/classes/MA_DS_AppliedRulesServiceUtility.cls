/**
 * ******************************************** W-12578108 : RULE ENGINE ********************************************
 * 
 * Abstract Utility class to handle MA_DS_PackageAppliedRuleSyncService.JobParams of the MA_DS_PackageAppliedRuleSyncService.AppliedRuleJob.
 * Provides utility methods to initialize the MA_DS_AppliedRulesService.JobParams for a given implementation of the AppliedRuleJob.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         18/03/2023      Chakshu Malhotra        W-12578108 - Provides utility methods that handles MA_DS_PackageAppliedRuleSyncService.JobParams of the AppliedRuleJob.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_AppliedRulesServiceUtility {

    private static final String ACQ_COMPANY_VAR = 'acqCompany';
    private static final String ACQ_COMPANY_FILTER = 'Acquisition_Company__c = :{0}';

    private static final String NO_OFFER_VAR = 'noOffer';
    private static final String NO_OFFER_FILTER = ' AND MA_DS_No_Offer__c = :{0}';

    private static final String OFFER_DECLINED_VAR = 'offerDeclined';
    private static final String OFFER_DECLINED_FILTER = ' AND MA_DS_Offer_Declined__c = :{0}';

    private static final String SOBJECT_TYPE_IUT = Label.MA_DS_SObject_Type_In_Use_Template;
    private static final String SOBJECT_TYPE_PD = Label.MA_DS_SObject_Type_Package_Distribution;

    private static final String DOCUMENT_TYPE_SUMMARY = Label.MA_DS_Document_Type_Manager_Summary;
    private static final String ELIGIBLE_SUMMARY_SYNC_STATUS = Label.MA_DS_Eligible_Package_Status_For_Rules_Update;
    private static final String ELIGIBLE_PACKAGE_SYNC_STATUS = Label.MA_DS_Eligible_Status_For_Template_Rules_Update;

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the set of status values that makes a Package Distribution eligible for Manager Summary Document (Template type) rules syncing.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Set<String> summarySyncStatusSet {
        get {
            if(summarySyncStatusSet == null) {
                summarySyncStatusSet = new Set<String>((List<String>)JSON.deserialize(ELIGIBLE_SUMMARY_SYNC_STATUS, List<String>.class));
            }
            return summarySyncStatusSet;
        }set;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the set of status values that makes a Package Distribution eligible for Package Document (Template type) rules syncing.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Set<String> packageSyncStatusSet {
        get {
            if(packageSyncStatusSet == null) {
                packageSyncStatusSet = new Set<String>((List<String>)JSON.deserialize(ELIGIBLE_PACKAGE_SYNC_STATUS, List<String>.class));
            }
            return packageSyncStatusSet;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the PackageAppliedRuleParams (JobParams) for the AppliedRuleJob to sync Package Distribution type Applied Rules.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	                                        DESCRIPTION (Data Type Id, Acquisition Company record Id of the Package record)
    * @param    pkgId	                                                DESCRIPTION (Data Type Id, Package record Id of the Package Distribution record)
    * @param    pkgDistributionId	                                    DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    originExecMode	                                        DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionMode, ExecutionMode enum type)
    * @return   MA_DS_AppliedRulesWrapper.PackageAppliedRuleParams      DESCRIPTION (return JobParams for the AppliedRuleJob)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static MA_DS_AppliedRulesWrapper.PackageAppliedRuleParams getPackageAppliedRulesParams(Id acqCompanyId, Id pkgId, Id pkgDistributionId, MA_DS_AppliedRulesService.ExecutionMode originExecMode) {
        MA_DS_AppliedRulesWrapper.PackageAppliedRuleParams jobParams = new MA_DS_AppliedRulesWrapper.PackageAppliedRuleParams();
        List<MA_DS_Rule_Criteria_Config__mdt> criteriaConfigList = getRuleCriteriaConfigList(SOBJECT_TYPE_PD);
        
        MA_DS_Package_Distribution__c pkgDistribution = getPackageDistribution(pkgDistributionId);
        jobParams.pkgId = pkgId;
        jobParams.acqCompanyId = acqCompanyId;
        jobParams.originExecMode = originExecMode;
        jobParams.pkgDistributionId = pkgDistributionId;
        jobParams.originExecJob = MA_DS_AppliedRulesService.ExecutionJob.PACKAGE_RULE_SYNC;
        jobParams.parentSObject = (criteriaConfigList.size() > 0) ? criteriaConfigList[0].MA_DS_Parent_SObject__c : null;

        Boolean defaultParentQuery = !(hasFiltersOnParentSObject(jobParams.parentSObject, pkgDistribution.MA_DS_Rules_Criteria_JSON__c));
        jobParams.rulesQueryWrapper = getRulesQueryWrapper(acqCompanyId, pkgDistributionId, pkgDistribution.MA_DS_Rules_Criteria_Query__c, defaultParentQuery);
        return jobParams;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the Package Distribution record details based on the recordId.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	                    DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @return   MA_DS_Package_Distribution__c           DESCRIPTION (return Package Distribution record)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static MA_DS_Package_Distribution__c getPackageDistribution(Id pkgDistributionId) {
        return [SELECT Id, MA_DS_Rules_Criteria_Query__c, MA_DS_Rules_Criteria_JSON__c, MA_DS_Summary_Required__c, MA_DS_Status__c
                FROM MA_DS_Package_Distribution__c
                WHERE Id = :pkgDistributionId LIMIT 1];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check whether the ParentSObject in the Query String has filters added.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    parentSObject	            DESCRIPTION (Data Type String, Parent SObject name based on the Rules Criteria Config)
    * @param    serializedRulesJSON	        DESCRIPTION (Data Type String, Serialized Rules Criteria JSON)
    * @return   Boolean                     DESCRIPTION (return True if ParentSobject has filters in the Query String)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Boolean hasFiltersOnParentSObject(String parentSObject, String serializedRulesJSON) {
        Type rulesWrapperApexType = MA_DS_AddRulesCriteriaWrapper.RulesCriteriaWrapper.class;
        MA_DS_AddRulesCriteriaWrapper.RulesCriteriaWrapper rulesWrapper = (MA_DS_AddRulesCriteriaWrapper.RulesCriteriaWrapper)JSON.deserializeStrict(serializedRulesJSON, rulesWrapperApexType);
        Map<String, List<String>> ruleLogicMap = rulesWrapper.ruleLogicMap;
        Boolean containsParentSObject = ruleLogicMap.containsKey(parentSObject);
        return containsParentSObject && (ruleLogicMap.get(parentSObject).size() > 0);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the MA_DS_RulesCriteriaQueryParser.QueryWrapper instance based on the Rules Criteria Query.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	                                DESCRIPTION (Data Type Id, Acquisition Company record Id of the Package record)
    * @param    recordId	                                    DESCRIPTION (Data Type Id, Record Id of the sObject on which Rules are being applied)
    * @param    serializedQueryWrapper	                        DESCRIPTION (Data Type String, Serialized string stored in the Rules Criteria Query)
    * @param    defaultQueryString	                            DESCRIPTION (Data Type String, True if serializedQueryWrapper contains default queryString)
    * @return   MA_DS_RulesCriteriaQueryParser.QueryWrapper     DESCRIPTION (return QueryWrapper instance containing Query String and Bind Map)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static MA_DS_RulesCriteriaQueryParser.QueryWrapper getRulesQueryWrapper(Id acqCompanyId, Id recordId, String serializedQueryWrapper, Boolean defaultQueryString) {
        MA_DS_RulesCriteriaQueryParser.QueryWrapper rulesQueryWrapper = MA_DS_RulesCriteriaQueryParser.instance.getQueryWrapper(recordId, serializedQueryWrapper);
        updateQueryWrapperWithAcqCompanyFilter(defaultQueryString, acqCompanyId, rulesQueryWrapper);
        updateQueryWrapperWithNoOfferFilter(rulesQueryWrapper);
        updateQueryWrapperWithDeclinedOfferFilter(rulesQueryWrapper);
        return rulesQueryWrapper;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the MA_DS_RulesCriteriaQueryParser.QueryWrapper with a Filter on "Acquisition Company" field.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    defaultQueryString	    DESCRIPTION (Data Type Boolean, True if serializedQueryWrapper contains default queryString)
    * @param    acqCompanyId	        DESCRIPTION (Data Type Id, Acquisition Company record Id of the Package record)
    * @param    rulesQueryWrapper	    DESCRIPTION (Data Type MA_DS_RulesCriteriaQueryParser.QueryWrapper, QueryWrapper instance containing Query String and Bind Map)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateQueryWrapperWithAcqCompanyFilter(Boolean defaultQueryString, Id acqCompanyId, MA_DS_RulesCriteriaQueryParser.QueryWrapper rulesQueryWrapper) {
        rulesQueryWrapper.queryString += defaultQueryString ? ' WHERE ' : ' AND ';
        rulesQueryWrapper.queryString += String.format(ACQ_COMPANY_FILTER, new String[] {ACQ_COMPANY_VAR});
        rulesQueryWrapper.bindMap.put(ACQ_COMPANY_VAR, acqCompanyId);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the MA_DS_RulesCriteriaQueryParser.QueryWrapper with a Filter on "No Offer" field.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    rulesQueryWrapper	    DESCRIPTION (Data Type MA_DS_RulesCriteriaQueryParser.QueryWrapper, QueryWrapper instance containing Query String and Bind Map)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateQueryWrapperWithNoOfferFilter(MA_DS_RulesCriteriaQueryParser.QueryWrapper rulesQueryWrapper) {
        rulesQueryWrapper.queryString += String.format(NO_OFFER_FILTER, new String[] {NO_OFFER_VAR});
        rulesQueryWrapper.bindMap.put(NO_OFFER_VAR, false);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the MA_DS_RulesCriteriaQueryParser.QueryWrapper with a Filter on "Acquisition Company" field.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    rulesQueryWrapper	    DESCRIPTION (Data Type MA_DS_RulesCriteriaQueryParser.QueryWrapper, QueryWrapper instance containing Query String and Bind Map)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateQueryWrapperWithDeclinedOfferFilter(MA_DS_RulesCriteriaQueryParser.QueryWrapper rulesQueryWrapper) {
        rulesQueryWrapper.queryString += String.format(OFFER_DECLINED_FILTER, new String[] {OFFER_DECLINED_VAR});
        rulesQueryWrapper.bindMap.put(OFFER_DECLINED_VAR, false);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the TemplateAppliedRuleParams (JobParams) for the AppliedRuleJob to sync In Use Template type Applied Rules.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	                                        DESCRIPTION (Data Type Id, Acquisition Company record Id of the Package record)
    * @param    pkgId	                                                DESCRIPTION (Data Type Id, Package record Id of the Package Distribution record)
    * @param    pkgDistributionId	                                    DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    originExecMode	                                        DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionMode, ExecutionMode enum type)
    * @return   MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams     DESCRIPTION (return JobParams for the AppliedRuleJob)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams getTemplateAppliedRulesParams(Id acqCompanyId, Id pkgId, Id pkgDistributionId, MA_DS_AppliedRulesService.ExecutionMode originExecMode) {
        MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams jobParams = initTemplateAppliedRulesParams(acqCompanyId, pkgId, pkgDistributionId, originExecMode);
        jobParams.originExecJob = MA_DS_AppliedRulesService.ExecutionJob.TEMPLATE_RULE_SYNC;
        jobParams.inUseTemplateIds = getEligibleInUseTemplateIds(pkgId, pkgDistributionId, false, jobParams);
        return jobParams;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize & fetch the TemplateAppliedRuleParams (JobParams) for the AppliedRuleJob to sync In Use Template type Applied Rules.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	                                        DESCRIPTION (Data Type Id, Acquisition Company record Id of the Package record)
    * @param    pkgId	                                                DESCRIPTION (Data Type Id, Package record Id of the Package Distribution record)
    * @param    pkgDistributionId	                                    DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    originExecMode	                                        DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionMode, ExecutionMode enum type)
    * @return   MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams     DESCRIPTION (return JobParams for the AppliedRuleJob)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams initTemplateAppliedRulesParams(Id acqCompanyId, Id pkgId, Id pkgDistributionId, MA_DS_AppliedRulesService.ExecutionMode originExecMode) {
        MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams jobParams = new MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams();
        List<MA_DS_Rule_Criteria_Config__mdt> criteriaConfigList = getRuleCriteriaConfigList(SOBJECT_TYPE_IUT);
        jobParams.pkgId = pkgId;
        jobParams.acqCompanyId = acqCompanyId;
        jobParams.originExecMode = originExecMode;
        jobParams.pkgDistributionId = pkgDistributionId;
        jobParams.parentSObject = (criteriaConfigList.size() > 0) ? criteriaConfigList[0].MA_DS_Parent_SObject__c : null;
        jobParams.childRelationshipMap = (criteriaConfigList.size() > 0) ? (Map<String, String>)JSON.deserialize(criteriaConfigList[0].MA_DS_Child_Relationships__c, Map<String, String>.class) : new Map<String, String>();
        return jobParams;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Rule Criteria Config based on the given sObjectType.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    sObjectType	                            DESCRIPTION (Data Type String, Object API Name of the sObject used, used to fetch the Rule Criteria Config Metadata)
    * @return   List<MA_DS_Rule_Criteria_Config__mdt>   DESCRIPTION (return List of MA_DS_Rule_Criteria_Config__mdt)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<MA_DS_Rule_Criteria_Config__mdt> getRuleCriteriaConfigList(String sObjectType) {
        return [SELECT Id, MA_DS_Parent_SObject__c, MA_DS_Child_Relationships__c 
                FROM MA_DS_Rule_Criteria_Config__mdt
                WHERE MA_DS_SObject_Type__c = :sObjectType];
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Eligible In Use Template Ids that need to be processed for Applied Rules.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgId	                        DESCRIPTION (Data Type Id, Package record Id of the Package Distribution record)
    * @param    pkgDistributionId	            DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    syncPackageTemplateRules	    DESCRIPTION (Data Type Boolean, True if both Package & Templates Rules syncing is in process)
    * @param    jobParams	                    DESCRIPTION (Data Type MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams, JobParams instance of the AppliedRuleJob)
    * @return   List<Id>                        DESCRIPTION (return List of In Use Template record Ids)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<Id> getEligibleInUseTemplateIds(Id pkgId, Id pkgDistributionId, Boolean syncPackageTemplateRules, MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams jobParams) {
        MA_DS_Package_Distribution__c pkgDistribution = getPackageDistribution(pkgDistributionId);
        String status = pkgDistribution.MA_DS_Status__c;
        Boolean summaryRequired = pkgDistribution.MA_DS_Summary_Required__c;
        Set<Id> inUseTemplateIds = new Set<Id>();

        for(MA_DS_In_Use_Template__c inUseTemplate : getInUseTemplates(pkgId)) {
            Boolean managerSummaryDoc = inUseTemplate.MA_DS_Template_Being_Used__r?.MA_DS_Template_Document_Type__c?.equalsIgnoreCase(DOCUMENT_TYPE_SUMMARY);
            Boolean validTemplateRuleSync = managerSummaryDoc ? (summaryRequired && summarySyncStatusSet.contains(status)) : packageSyncStatusSet.contains(status);
            Boolean isEligibleInUseTemplate = validTemplateRuleSync && isEligibleInUseTemplate(inUseTemplate);

            if(isEligibleInUseTemplate && isEligibleForRulesSync(inUseTemplate, pkgDistributionId, syncPackageTemplateRules)) {
                inUseTemplateIds.add(inUseTemplate.Id);
                jobParams.summaryDocRuleSync = jobParams.summaryDocRuleSync || managerSummaryDoc;
                jobParams.packageDocRuleSync = jobParams.packageDocRuleSync || !managerSummaryDoc;
            }
        }

        return new List<Id>(inUseTemplateIds);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the In Use Template records based on the Package Id.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgId	                            DESCRIPTION (Data Type Id, Package record Id of the Package Distribution record)
    * @return   List<MA_DS_In_Use_Template__c>      DESCRIPTION (return List of In Use Template records)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<MA_DS_In_Use_Template__c> getInUseTemplates(Id pkgId) {
        return [SELECT Id, MA_DS_Audit_All__c, MA_DS_Sync_Rules_On_PD_Ids__c, MA_DS_Suppress_Rules_Criteria__c, MA_DS_Suppress_Audit_Flags__c, 
                MA_DS_Rules_Criteria_Query__c, MA_DS_Audit_Flags_JSON__c, MA_DS_Template_Being_Used__r.MA_DS_Template_Document_Type__c
                FROM MA_DS_In_Use_Template__c
                WHERE MA_DS_Package_Using__c = :pkgId];
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check whether a given In Use Template record is eligible based on Suppress checks on Rules & Audit Flags.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    inUseTemplate	        DESCRIPTION (Data Type MA_DS_In_Use_Template__c, In Use Template record)
    * @return   Boolean                 DESCRIPTION (return True if In Use Template record is eligible)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isEligibleInUseTemplate(MA_DS_In_Use_Template__c inUseTemplate) {
        String flagsJSON = inUseTemplate.MA_DS_Audit_Flags_JSON__c;
        String rulesQuery = inUseTemplate.MA_DS_Rules_Criteria_Query__c;
        Boolean suppressRules = inUseTemplate.MA_DS_Suppress_Rules_Criteria__c;
        Boolean suppressFlags = (inUseTemplate.MA_DS_Audit_All__c || inUseTemplate.MA_DS_Suppress_Audit_Flags__c);
        return (suppressFlags && suppressRules) || 
               (suppressFlags && !suppressRules && rulesQuery != null) || 
               (suppressRules && !suppressFlags && flagsJSON != null) || 
               (!suppressRules && !suppressFlags && rulesQuery != null && flagsJSON != null);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check whether a given In Use Template record is eligible for rules syncing process.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    inUseTemplate	                DESCRIPTION (Data Type MA_DS_In_Use_Template__c, In Use Template record)
    * @param    pkgDistributionId	            DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    syncPackageTemplateRules	    DESCRIPTION (Data Type Boolean, True if both Package & Templates Rules syncing is in process)
    * @return   Boolean                         DESCRIPTION (return True if In Use Template record is eligible for rules syncing process)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isEligibleForRulesSync(MA_DS_In_Use_Template__c inUseTemplate, Id pkgDistributionId, Boolean syncPackageTemplateRules) {
        String syncRulesOnPDIds = inUseTemplate.MA_DS_Sync_Rules_On_PD_Ids__c;
        Set<String> pdIds = String.isBlank(syncRulesOnPDIds) ? new Set<String>() : getPDIdSet(syncRulesOnPDIds);
        return syncPackageTemplateRules ? true : pdIds.contains(String.valueOf(pkgDistributionId));
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method deseralizes MA_DS_Sync_Rules_On_PD_Ids__c on In Use Templates into Set of Package Distribution Ids.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    syncRulesOnPDIds 	   	DESCRIPTION (Data type String, The old Package Distribution record)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Set<String> getPDIdSet(String syncRulesOnPDIds) {
        return new Set<String>((List<String>)JSON.deserialize(syncRulesOnPDIds, List<String>.class));
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the TemplateAppliedRuleParams (JobParams) for the AppliedRuleJob to sync In Use Template type Applied Rules.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	                                        DESCRIPTION (Data Type Id, Acquisition Company record Id of the Package record)
    * @param    pkgId	                                                DESCRIPTION (Data Type Id, Package record Id of the Package Distribution record)
    * @param    pkgDistributionId	                                    DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    originExecMode	                                        DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionMode, ExecutionMode enum type)
    * @param    asyncApexJobIds	                                        DESCRIPTION (Data Type Set<Id>, AsyncApexJob Ids of the Queueable Jobs that processed Package Distribution type Applied Rules)
    * @return   MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams     DESCRIPTION (return JobParams for the AppliedRuleJob)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams getTemplateAppliedRulesParams(Id acqCompanyId, Id pkgId, Id pkgDistributionId, MA_DS_AppliedRulesService.ExecutionMode originExecMode, Set<Id> asyncApexIds) {
        MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams jobParams = initTemplateAppliedRulesParams(acqCompanyId, pkgId, pkgDistributionId, originExecMode);
        jobParams.packageRulesAsyncApexJobIds.addAll(asyncApexIds);
        jobParams.originExecJob = MA_DS_AppliedRulesService.ExecutionJob.PACKAGE_RULE_SYNC;
        jobParams.inUseTemplateIds = getEligibleInUseTemplateIds(pkgId, pkgDistributionId, true, jobParams);
        return jobParams;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the PackageAppliedRuleParams (JobParams) for the AppliedRuleJob to sync Package Distribution type Applied Rules.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	                                DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    summaryDocRuleSync	                                DESCRIPTION (Data Type Boolean, True if Rules are synced for Manager Summary Document template)
    * @param    packageDocRuleSync	                                DESCRIPTION (Data Type Boolean, True if Rules are synced for atleast one Package Document template)
    * @param    originExecJob	                                    DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionJob, ExecutionJob enum type of the first Job that initiated the Rule Sync process)
    * @param    originExecMode	                                    DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionMode, ExecutionMode enum type)
    * @param    asyncApexJobIds	                                    DESCRIPTION (Data Type Set<Id>, AsyncApexJob Ids of the Queueable Jobs that processed the Applied Rules)
    * @param    templateIds	                                        DESCRIPTION (Data Type List<Id>, List of referenced Template Ids of the In Use Templates)
    * @return   MA_DS_AppliedRulesWrapper.PurgeAppliedRuleParams    DESCRIPTION (return JobParams for the AppliedRuleJob)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static MA_DS_AppliedRulesWrapper.PurgeAppliedRuleParams getPurgeAppliedRulesParams(Id pkgDistributionId, Boolean summaryDocRuleSync, Boolean packageDocRuleSync, MA_DS_AppliedRulesService.ExecutionJob originExecJob, MA_DS_AppliedRulesService.ExecutionMode originExecMode, Set<Id> asyncApexJobIds, List<Id> templateIds) {
        MA_DS_AppliedRulesWrapper.PurgeAppliedRuleParams jobParams = new MA_DS_AppliedRulesWrapper.PurgeAppliedRuleParams();
        jobParams.pkgDistributionId = pkgDistributionId;
        jobParams.originExecJob = originExecJob;
        jobParams.originExecMode = originExecMode;
        jobParams.summaryDocRuleSync = summaryDocRuleSync;
        jobParams.packageDocRuleSync = packageDocRuleSync;
        jobParams.templateIds.addAll(templateIds);
        jobParams.asyncApexJobIds.addAll(asyncApexJobIds);
        return jobParams;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the RuleAppliedParams (JobParams) for the AppliedRuleJob to update Rule Applied Flags on Package Distribution type Applied Rules.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	                                DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    summaryDocRuleSync	                                DESCRIPTION (Data Type Boolean, True if Rules are synced for Manager Summary Document template)
    * @param    packageDocRuleSync	                                DESCRIPTION (Data Type Boolean, True if Rules are synced for atleast one Package Document template)
    * @param    originExecJob	                                    DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionJob, ExecutionJob enum type of the first Job that initiated the Rule Sync process)
    * @param    originExecMode	                                    DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionMode, ExecutionMode enum type)
    * @return   MA_DS_AppliedRulesWrapper.RuleAppliedParams         DESCRIPTION (return JobParams for the AppliedRuleJob)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static MA_DS_AppliedRulesWrapper.RuleAppliedParams getRuleAppliedParams(Id pkgDistributionId, Boolean summaryDocRuleSync, Boolean packageDocRuleSync, MA_DS_AppliedRulesService.ExecutionJob originExecJob, MA_DS_AppliedRulesService.ExecutionMode originExecMode) {
        MA_DS_AppliedRulesWrapper.RuleAppliedParams jobParams = new MA_DS_AppliedRulesWrapper.RuleAppliedParams();
        jobParams.pkgDistributionId = pkgDistributionId;
        jobParams.originExecJob = originExecJob;
        jobParams.originExecMode = originExecMode;
        jobParams.summaryDocRuleSync = summaryDocRuleSync;
        jobParams.packageDocRuleSync = packageDocRuleSync;
        return jobParams;
    }
}