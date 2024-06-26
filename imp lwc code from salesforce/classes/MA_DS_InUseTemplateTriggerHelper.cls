/**
 * W-12612799
 * Trigger helper class for MA_DS_InUseTemplateTriggerHandler
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         14/03/2023      Chakshu Malhotra        Trigger helper logic for MA_DS_InUseTemplateTriggerHandler.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class MA_DS_InUseTemplateTriggerHelper {

    private static final String DOCUMENT_TYPE_MANAGER_SUMMARY = Label.MA_DS_Document_Type_Manager_Summary;
    private static final String IN_USE_TEMPLATES_WITH_RULES_STR = Label.MA_DS_In_Use_Templates_With_Rules_String;
    private static final String ELIGIBLE_SUMMARY_SYNC_STATUS = Label.MA_DS_Eligible_Package_Status_For_Rules_Update;
    private static final String ELIGIBLE_PACKAGE_SYNC_STATUS = Label.MA_DS_Eligible_Status_For_Template_Rules_Update;
    
    private static final String NA_STATUS = Label.MA_DS_Rule_Sync_Status_NA;
    private static final String RULES_SYNCED_STATUS = Label.MA_DS_Rules_Synced_Status;
    private static final String SYNCING_PACKAGE_RULES_STATUS = Label.MA_DS_Syncing_Package_Rules_Status;
    private static final String SYNCING_TEMPLATE_RULES_STATUS = Label.MA_DS_Syncing_Templates_Rules_Status;
    private static final String NEED_SYNC_TEMPLATE_RULES_STATUS = Label.MA_DS_Need_Sync_Template_Rules_Status;
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the singleton instance of the MA_DS_InUseTemplateTriggerHelper class.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static final MA_DS_InUseTemplateTriggerHelper helperInstance {
        get {
            if(helperInstance == null) {
                helperInstance = new MA_DS_InUseTemplateTriggerHelper();
            }
            return helperInstance;
        }private set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Private default constructor of the MA_DS_InUseTemplateTriggerHelper class.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private MA_DS_InUseTemplateTriggerHelper() {
        // to enforce singleton design
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the set of Template reference of the In Use Templates.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Set<Id> templateIds {
        get {
            if(templateIds == null) {
                templateIds = new Set<Id>();
                for(MA_DS_In_Use_Template__c newRec : (List<MA_DS_In_Use_Template__c>)Trigger.new) {
                    templateIds.add(newRec.MA_DS_Template_Being_Used__c);
                }
            }
            return templateIds;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the set of Template references where Document Type is Manager Summary.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Set<Id> summaryDocTemplateIds {
        get {
            if(summaryDocTemplateIds == null) {
                summaryDocTemplateIds = new Set<Id>();
                for(MA_DS_Template__c template : [SELECT Id FROM MA_DS_Template__c WHERE Id IN :templateIds AND 
                                                  MA_DS_Template_Document_Type__c = :DOCUMENT_TYPE_MANAGER_SUMMARY]) {
                    summaryDocTemplateIds.add(template.Id);
                }
            }
            return summaryDocTemplateIds;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the set of Package reference of the In Use Templates.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Set<Id> packageIds {
        get {
            if(packageIds == null) {
                packageIds = new Set<Id>();
                for(MA_DS_In_Use_Template__c newRec : (List<MA_DS_In_Use_Template__c>)Trigger.new) {
                    packageIds.add(newRec.MA_DS_Package_Using__c);
                }
            }
            return packageIds;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the Set of Rules Syncing status when Package or Template Rules are syncing.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Set<String> rulesSyncingStatus {
        get {
            if(rulesSyncingStatus == null) {
                rulesSyncingStatus = new Set<String> {SYNCING_PACKAGE_RULES_STATUS.toLowerCase(), SYNCING_TEMPLATE_RULES_STATUS.toLowerCase()};
            }
            return rulesSyncingStatus;
        }set;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the map of Package Id to the Rule Sync Status (Syncing Package Rules / Syncing Template Rules) of the Package Distributions.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Map<Id, String> pkgIdsWithRuleSyncingStatusMap {
        get {
            if(pkgIdsWithRuleSyncingStatusMap == null) {
                pkgIdsWithRuleSyncingStatusMap = new Map<Id, String>();
                List<MA_DS_Package_Distribution__c> packageDistributions = [SELECT Id, MA_DS_Package__c, MA_DS_Status__c, MA_DS_Rules_Sync_Status__c, MA_DS_Summary_Required__c
                                                                            FROM MA_DS_Package_Distribution__c
                                                                            WHERE MA_DS_Package__c IN :packageIds];
                
                for(MA_DS_Package_Distribution__c packageDistribution : packageDistributions) {
                    Id packageId = packageDistribution.MA_DS_Package__c;

                    if(rulesSyncingStatus.contains(packageDistribution.MA_DS_Rules_Sync_Status__c.toLowerCase())) {
                        pkgIdsWithRuleSyncingStatusMap.put(packageId, packageDistribution.MA_DS_Rules_Sync_Status__c);
                    }else if(!pkgIdsWithRuleSyncingStatusMap.containsKey(packageId) && 
                             packageSyncStatusSet.contains(packageDistribution.MA_DS_Status__c) && 
                             !packageDistribution.MA_DS_Rules_Sync_Status__c.equalsIgnoreCase(NA_STATUS)) {

                        Boolean containsPkgId = pkgIdToNeedSyncPDIdsMap.containsKey(packageId);
                        
                        Set<String> needSyncPDIds = containsPkgId ? pkgIdToNeedSyncPDIdsMap.get(packageId) : new Set<String>();
                        needSyncPDIds.add(String.valueOf(packageDistribution.Id));
                        pkgIdToNeedSyncPDIdsMap.put(packageId, needSyncPDIds);

                        needSyncPackageDistributions.add(packageDistribution);

                        if(summarySyncStatusSet.contains(packageDistribution.MA_DS_Status__c) && packageDistribution.MA_DS_Summary_Required__c) {
                            pdsEligibleForSummarySync.add(String.valueOf(packageDistribution.Id));
                        }
                    }
                }
            }
            return pkgIdsWithRuleSyncingStatusMap;
        }set;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the set of Package Distributions that are eligible for Manager Summary Document (Template type) rules syncing.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Set<String> pdsEligibleForSummarySync {
        get {
            if(pdsEligibleForSummarySync == null) {
                pdsEligibleForSummarySync = new Set<String>();
            }
            return pdsEligibleForSummarySync;
        }set;
    }

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
    private Set<String> packageSyncStatusSet {
        get {
            if(packageSyncStatusSet == null) {
                packageSyncStatusSet = new Set<String>((List<String>)JSON.deserialize(ELIGIBLE_PACKAGE_SYNC_STATUS, List<String>.class));
            }
            return packageSyncStatusSet;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the map of Package Id to the set of Package Distribution Ids that require resycning of template rules.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Map<Id, Set<String>> pkgIdToNeedSyncPDIdsMap {
        get {
            if(pkgIdToNeedSyncPDIdsMap == null) {
                pkgIdToNeedSyncPDIdsMap = new Map<Id, Set<String>>();
            }
            return pkgIdToNeedSyncPDIdsMap;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the list of Package Distributions that require resyncing of template rules.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private List<MA_DS_Package_Distribution__c> needSyncPackageDistributions {
        get {
            if(needSyncPackageDistributions == null) {
                needSyncPackageDistributions = new List<MA_DS_Package_Distribution__c>();
            }
            return needSyncPackageDistributions;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the set of Package Distribution Ids to find that need resycning of template rules.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Set<String> needSyncPkgDistributionIds {
        get {
            if(needSyncPkgDistributionIds == null) {
                needSyncPkgDistributionIds = new Set<String>();
            }
            return needSyncPkgDistributionIds;
        }set;
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method updates the Suppress Rules Criteria Flag if the Template document type is Manager Summary.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	DESCRIPTION (Data type MA_DS_In_Use_Template__c, The new In Use Template record)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void updateSuppressRulesCriteria(MA_DS_In_Use_Template__c newRec) {
        if(summaryDocTemplateIds.contains(newRec.MA_DS_Template_Being_Used__c)) {
            newRec.MA_DS_Suppress_Rules_Criteria__c	 = true;
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method updates the Need Sync On PD Ids with serialized list of Package Distribution Ids that require resyncing of Template rules.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	DESCRIPTION (Data type MA_DS_In_Use_Template__c, The new In Use Template record)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void updateNeedSyncOnPDIds(MA_DS_In_Use_Template__c newRec) {
        if(isEligibleInUseTemplate(newRec)) {
            updateSyncRulesOnPDIds(newRec);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method updates the "Concatenated Id" for the In Use Template whenever the record is inserted / updated.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	DESCRIPTION (Data type MA_DS_In_Use_Template__c, The new In Use Template record)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void updateConcatenatedId(MA_DS_In_Use_Template__c newRec) {
        String concatenatedId = String.valueOf(newRec.MA_DS_Package_Using__c) + String.valueOf(newRec.MA_DS_Template_Being_Used__c);
        if(newRec.MA_DS_Concatenated_Id__c != concatenatedId) {
            newRec.MA_DS_Concatenated_Id__c = concatenatedId;
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check whether a given In Use Template record is eligible based on Suppress checks on Rules & Audit Flags.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	            DESCRIPTION (Data type MA_DS_In_Use_Template__c, The new In Use Template record)
    * @return   Boolean                 DESCRIPTION (return True if In Use Template record is eligible)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isEligibleInUseTemplate(MA_DS_In_Use_Template__c newRec) {
        String flagsJSON = newRec.MA_DS_Audit_Flags_JSON__c;
        String rulesQuery = newRec.MA_DS_Rules_Criteria_Query__c;
        Boolean suppressRules = newRec.MA_DS_Suppress_Rules_Criteria__c;
        Boolean suppressFlags = (newRec.MA_DS_Audit_All__c || newRec.MA_DS_Suppress_Audit_Flags__c);
        return (suppressFlags && suppressRules) || 
               (suppressFlags && !suppressRules && rulesQuery != null) || 
               (suppressRules && !suppressFlags && flagsJSON != null) || 
               (!suppressRules && !suppressFlags && rulesQuery != null && flagsJSON != null);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method updates the Need Sync On PD Ids with serialized list of Package Distribution Ids that require resyncing of Template rules.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	DESCRIPTION (Data type MA_DS_In_Use_Template__c, The new In Use Template record)
    * @param    oldRec 	   	DESCRIPTION (Data type MA_DS_In_Use_Template__c, The old In Use Template record)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void updateNeedSyncOnPDIds(MA_DS_In_Use_Template__c newRec, MA_DS_In_Use_Template__c oldRec) {
        if(isEligibleForNeedSync(newRec, oldRec)) {
            updateSyncRulesOnPDIds(newRec);
            updateIfAuditFlagsSuppressed(newRec, oldRec);
            updateIfRulesCriteriaSuppressed(newRec, oldRec);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method checks if an In Use Template is eligible for resyncing its rules.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	DESCRIPTION (Data type MA_DS_In_Use_Template__c, The new In Use Template record)
    * @param    oldRec 	   	DESCRIPTION (Data type MA_DS_In_Use_Template__c, The old In Use Template record)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Boolean isEligibleForNeedSync(MA_DS_In_Use_Template__c newRec, MA_DS_In_Use_Template__c oldRec) {
        Boolean suppressFlags = (newRec.MA_DS_Audit_All__c || newRec.MA_DS_Suppress_Audit_Flags__c);
        Boolean oldSuppressFlags = (oldRec.MA_DS_Audit_All__c || oldRec.MA_DS_Suppress_Audit_Flags__c);

        return (newRec.MA_DS_Rules_Criteria_Query__c != oldRec.MA_DS_Rules_Criteria_Query__c && !newRec.MA_DS_Suppress_Rules_Criteria__c) || 
        (newRec.MA_DS_Audit_Flags_JSON__c != oldRec.MA_DS_Audit_Flags_JSON__c && !suppressFlags) || 
        (newRec.MA_DS_Suppress_Rules_Criteria__c != oldRec.MA_DS_Suppress_Rules_Criteria__c) || 
        (suppressFlags != oldSuppressFlags);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method updates Need Sync On PD Ids with with serialized list of Package Distribution Ids.
    * The method also adds an error to In Use Template record if any of the related Package Distribution is currently syncing rules.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	DESCRIPTION (Data type MA_DS_In_Use_Template__c, The new In Use Template record)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void updateSyncRulesOnPDIds(MA_DS_In_Use_Template__c newRec) {
        Id pkgId = newRec.MA_DS_Package_Using__c;

        if(pkgIdsWithRuleSyncingStatusMap.containsKey(pkgId)) {
            String[] exceptionMsgParams = new String[] {MA_DS_PackageDistributionTriggerHelper.MA_DS_IneligibleRulesSyncStatusException.class.getName(), IN_USE_TEMPLATES_WITH_RULES_STR, pkgIdsWithRuleSyncingStatusMap.get(pkgId)};
            newRec.addError(new MA_DS_PackageDistributionTriggerHelper.MA_DS_IneligibleRulesSyncStatusException(exceptionMsgParams));
        }else if(pkgIdToNeedSyncPDIdsMap.containsKey(pkgId)) {
            String syncRulesOnPDIds = newRec.MA_DS_Sync_Rules_On_PD_Ids__c;
            Set<String> packageDistributionIds = pkgIdToNeedSyncPDIdsMap.get(pkgId);
            Set<String> pdIds = String.isBlank(syncRulesOnPDIds) ? new Set<String>() : getPDIdSet(syncRulesOnPDIds);

            packageDistributionIds.addAll(pdIds);
            Set<String> clonedPackageDistributionIds = packageDistributionIds.clone();

            if(summaryDocTemplateIds.contains(newRec.MA_DS_Template_Being_Used__c)) {
                clonedPackageDistributionIds.retainAll(pdsEligibleForSummarySync);
            }
            if(clonedPackageDistributionIds.size() > 0) {
                needSyncPkgDistributionIds.addAll(clonedPackageDistributionIds);
                newRec.MA_DS_Sync_Rules_On_PD_Ids__c = JSON.serialize(clonedPackageDistributionIds);
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method deseralizes MA_DS_Sync_Rules_On_PD_Ids__c on In Use Templates into Set of Package Distribution Ids.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    syncRulesOnPDIds 	   	DESCRIPTION (Data type String, Serialized Sync Rules on PD Ids)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Set<String> getPDIdSet(String syncRulesOnPDIds) {
        return new Set<String>((List<String>)JSON.deserialize(syncRulesOnPDIds, List<String>.class));
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method sets MA_DS_Audit_Flags_JSON__c to null if MA_DS_Suppress_Audit_Flags__c is changed and checked.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	DESCRIPTION (Data type MA_DS_In_Use_Template__c, The new In Use Template record)
    * @param    oldRec 	   	DESCRIPTION (Data type MA_DS_In_Use_Template__c, The old In Use Template record)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void updateIfAuditFlagsSuppressed(MA_DS_In_Use_Template__c newRec, MA_DS_In_Use_Template__c oldRec) {
        Boolean suppressFlags = (newRec.MA_DS_Audit_All__c || newRec.MA_DS_Suppress_Audit_Flags__c);
        Boolean oldSuppressFlags = (oldRec.MA_DS_Audit_All__c || oldRec.MA_DS_Suppress_Audit_Flags__c);

        if(suppressFlags != oldSuppressFlags && suppressFlags && newRec.MA_DS_Audit_Flags_JSON__c != null) {
            newRec.MA_DS_Audit_Flags_JSON__c = null;
            newRec.MA_DS_Audit_Flags_Added__c = false;
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method sets MA_DS_Rules_Criteria_JSON__c & MA_DS_Rules_Criteria_Query__c to null if MA_DS_Suppress_Rules_Criteria__c is changed and checked.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	DESCRIPTION (Data type MA_DS_In_Use_Template__c, The new In Use Template record)
    * @param    oldRec 	   	DESCRIPTION (Data type MA_DS_In_Use_Template__c, The old In Use Template record)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void updateIfRulesCriteriaSuppressed(MA_DS_In_Use_Template__c newRec, MA_DS_In_Use_Template__c oldRec) {
        Boolean isSuppressedFlagUpdated = (newRec.MA_DS_Suppress_Rules_Criteria__c != oldRec.MA_DS_Suppress_Rules_Criteria__c);
        if(isSuppressedFlagUpdated && newRec.MA_DS_Suppress_Rules_Criteria__c && newRec.MA_DS_Rules_Criteria_Query__c != null) {
            newRec.MA_DS_Rules_Criteria_JSON__c = null;
            newRec.MA_DS_Rules_Criteria_Query__c = null;
            newRec.MA_DS_Rules_Criteria_Added__c = false;
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method updates Rules Sync Status on Package Distributions that require resyncing of template rules.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void updatePackageDistributionsWithNeedSyncStatus() {
        List<MA_DS_Package_Distribution__c> updatedPackageDistributions = new List<MA_DS_Package_Distribution__c>();

        for(MA_DS_Package_Distribution__c packageDistribution : needSyncPackageDistributions) {
            if(needSyncPkgDistributionIds.contains(String.valueOf(packageDistribution.Id))) {
                packageDistribution.MA_DS_Rules_Sync_Status__c = getUpdatedRuleSyncStatus(packageDistribution.MA_DS_Rules_Sync_Status__c);
                updatedPackageDistributions.add(packageDistribution);
            }
        }

        if(updatedPackageDistributions.size() > 0) {
            MA_DS_PackageDistributionTriggerHandler.triggerDisabled = true;
            Database.SaveResult[] packageDistSRList = Database.update(updatedPackageDistributions, false);
            MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(packageDistSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method returns the updated value of the Rules Sync Status on the Package Distribution record.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    rulesSyncStatus 	   	DESCRIPTION (Data type String, The old Package Distribution record)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private String getUpdatedRuleSyncStatus(String rulesSyncStatus) {
        return rulesSyncStatus.equalsIgnoreCase(RULES_SYNCED_STATUS) ? NEED_SYNC_TEMPLATE_RULES_STATUS : rulesSyncStatus;
    }
}