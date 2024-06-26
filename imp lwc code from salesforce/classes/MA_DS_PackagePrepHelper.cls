/**
 * W-13011399
 * Helper class to inititate the process to Prepare Packages for all eligible / selected Package Distribution records.
 * 
 * Version      Date            Author                  Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         28/04/2023      Chakshu Malhotra        W-13011399 - Adds logic to inititate the process to Prepare Packages for all eligible / selected Package Distribution records.
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_PackagePrepHelper {
    
    private static final String NO_PACKAGE_RULE_EXCEPTION = Label.MA_DS_No_Package_Rule_Exception;
    private static final String NO_PACKAGE_PREP_RULES_EXCEPTION = Label.MA_DS_No_Package_Prep_Rules_Exception;

    private static final String NO_PD_FOR_PACKAGE_PREP_EXCEPTION = Label.MA_DS_No_PD_For_Package_Prep;

    private static final String ELIGIBLE_INTEGRATION_STATUS = Label.MA_DS_Eligible_Integration_Status;
    private static final String INELIGIBLE_INT_STATUS_EXCEPTION = Label.MA_DS_Ineligible_Int_Status_For_Package_Prep;

    private static final String SYNCING_PACKAGE_RULES = Label.MA_DS_Syncing_Package_Rules_Status;
    private static final String SYNCING_TEMPLATE_RULES = Label.MA_DS_Syncing_Templates_Rules_Status;

    private static final String NOT_READY_FOR_PACKAGE_PREP_EXCEPTION = Label.MA_DS_Not_Ready_For_Package_Prep_Exception;
    private static final String INELIGIBLE_RULES_SYNC_STATUS_EXCEPTION = Label.MA_DS_Ineligible_Rules_Sync_Status_For_Package_Prep;

    private static final String AUDIT_STATUS_REGEN_TEMPLATE_DOCS = Label.MA_DS_Audit_Status_Regen_Template_Docs;
    private static final String AUDIT_STATUS_REGEN_CONTACTS_DOCS = Label.MA_DS_Audit_Status_Regen_Contacts_Docs;
    private static final String AUDIT_STATUS_REGEN_ALL_CONTACTS_DOCS = Label.MA_DS_Audit_Status_Regen_All_Contacts_Docs;

    private static final String PACKAGE_PREP_MESSAGE = Label.MA_DS_Preparing_Packages_Message;

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the set of Rules Sync Status values that makes a Package Distribution ineligible for Package Prep process.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Set<String> ineligibleRulesSyncStatusSet {
        get {
            if(ineligibleRulesSyncStatusSet == null) {
                ineligibleRulesSyncStatusSet = new Set<String> {SYNCING_PACKAGE_RULES, SYNCING_TEMPLATE_RULES};
            }
            return ineligibleRulesSyncStatusSet;
        }set;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initiate the processing of Package Prep for all Package Distribution and return Processing Status Message.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	        DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @return   String                  DESCRIPTION (return processStatus message for the "Prepare Packages" action)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static String preparePackages(Id acqCompanyId) {
        List<MA_DS_Package_Distribution__c> pkgDistributions = MA_DS_PackagePrepUtility.getPackageDistributions(false, acqCompanyId, null);
        Map<Id, MA_DS_Package_Distribution__c> eligiblePkgDistributionMap = throwExceptionsIfNeeded(acqCompanyId, pkgDistributions);
        return preparePackages(acqCompanyId, acqCompanyId, eligiblePkgDistributionMap.values(), MA_DS_PackagePrepService.ExecutionOrigin.PREP_REGEN_ALL);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initiate the processing of Package Prep for selected Package Distributions on the UI and return Processing Status Message.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	            DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    acqCompanyId	        DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    pkgDistributionIds	    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @return   String                  DESCRIPTION (return processStatus message for the "Prepare Packages" action)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static String preparePackages(Id srcRecordId, Id acqCompanyId, Set<Id> pkgDistributionIds) {
        List<MA_DS_Package_Distribution__c> pkgDistributions = MA_DS_PackagePrepUtility.getPackageDistributions(false, acqCompanyId, pkgDistributionIds);
        Map<Id, MA_DS_Package_Distribution__c> eligiblePkgDistributionMap = throwExceptionsIfNeeded(acqCompanyId, pkgDistributions);
        return preparePackages(srcRecordId, acqCompanyId, eligiblePkgDistributionMap.values(), MA_DS_PackagePrepService.ExecutionOrigin.PREP_REGEN_SELECTED);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to auto-initiate the processing of Package Prep for Failed Common Id / Template Ids and return Processing Status Message.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	        DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    commonIdMap	            DESCRIPTION (Data Type Map<String, List<String>>, Map of Package Common Id to List of Template Ids)
    * @param    auditStatus	            DESCRIPTION (Data Type String, Audit regen status value)
    * @return   String                  DESCRIPTION (return processStatus message for the "Prepare Packages" action)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static String preparePackages(Id acqCompanyId, Map<String, List<String>> commonIdMap, String auditStatus) {
        Set<Id> pkgDistributionIds = MA_DS_PackagePrepUtility.getPackageDistributionIds(acqCompanyId, commonIdMap.keySet());
        List<MA_DS_Package_Distribution__c> pkgDistributions = MA_DS_PackagePrepUtility.getPackageDistributions(true, acqCompanyId, pkgDistributionIds);
        Map<Id, MA_DS_Package_Distribution__c> eligiblePkgDistributionMap = throwExceptionsIfNeeded(acqCompanyId, pkgDistributions);
        return preparePackages(acqCompanyId, acqCompanyId, eligiblePkgDistributionMap.values(), commonIdMap, auditStatus, MA_DS_PackagePrepService.ExecutionOrigin.AUDIT_FAILED_REGEN);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to throw exception if any of the Package Distribution record is ineligible to initiate the Package Prep process.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	                            DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    pkgDistributions	                        DESCRIPTION (Data Type List<MA_DS_Package_Distribution__c>, List of Package Distribution records)
    * @return   Map<Id, MA_DS_Package_Distribution__c>      DESCRIPTION (return Map of all Eligible Package Distribution records that can be processed for Package Prep process)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<Id, MA_DS_Package_Distribution__c> throwExceptionsIfNeeded(Id acqCompanyId, List<MA_DS_Package_Distribution__c> pkgDistributions) {
        Map<Id, MA_DS_Package_Distribution__c> eligiblePkgDistributionMap = new Map<Id, MA_DS_Package_Distribution__c>();

        for(MA_DS_Package_Distribution__c pkgDistribution : pkgDistributions) {
            throwExceptionIfIneligibleIntegrationStatus(pkgDistribution.MA_DS_Integration_Status__c);
            throwExceptionIfIneligibleRulesSyncStatus(pkgDistribution.MA_DS_Rules_Sync_Status__c);
            eligiblePkgDistributionMap.put(pkgDistribution.Id, pkgDistribution);
        }

        if(eligiblePkgDistributionMap.size() == 0) {
            throw new NoEligiblePackageDistributionException(new String[] {String.valueOf(acqCompanyId)});
        }

        if(eligiblePkgDistributionMap.size() > 0) {
            throwExceptionIfNotReadyForPackagePrep(eligiblePkgDistributionMap);
            throwExceptionIfNoPackageRules(eligiblePkgDistributionMap);
            throwExceptionIfNoPackagePrepRules(eligiblePkgDistributionMap);
        }

        return eligiblePkgDistributionMap;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to throw exception if Integration Status is not eligible i.e an Integration Job is running in the background for the Package Distribution.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    integrationStatus	                DESCRIPTION (Data Type String, Integration Status of the Package Distribution)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void throwExceptionIfIneligibleIntegrationStatus(String integrationStatus) {
        if(!integrationStatus.equalsIgnoreCase(ELIGIBLE_INTEGRATION_STATUS)) {
            throw new IneligibleIntegrationStatusException(new String[] {integrationStatus});
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to throw exception if Rules Sync Status is not eligible for initiating the Package Prep process.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    rulesSyncStatus	                    DESCRIPTION (Data Type String, Rules Sync Status of the Package Distribution)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void throwExceptionIfIneligibleRulesSyncStatus(String rulesSyncStatus) {
        if(ineligibleRulesSyncStatusSet.contains(rulesSyncStatus)) {
            throw new IneligibleRulesSyncStatusException(new String[] {rulesSyncStatus});
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to throw exception if one or more Acquisition Contacts are not yet ready for Package Prep process.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionMap	        DESCRIPTION (Data Type Map<Id, MA_DS_Package_Distribution__c>, Map of eligible Package Distribution records.
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void throwExceptionIfNotReadyForPackagePrep(Map<Id, MA_DS_Package_Distribution__c> pkgDistributionMap) {
        Set<String> pkgDistributionNames = MA_DS_PackagePrepUtility.getDistributionsNotReadyForPackagePrep(pkgDistributionMap);
        if(pkgDistributionNames.size() > 0) {
            throw new NotReadyForPackagePrepException(new String[] {JSON.serialize(pkgDistributionNames)});
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to throw exception if No Package Rule found for atleast one of the Acquisition Contact in the eligible Package Distribution records.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionMap	        DESCRIPTION (Data Type Map<Id, MA_DS_Package_Distribution__c>, Map of eligible Package Distribution records.
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void throwExceptionIfNoPackageRules(Map<Id, MA_DS_Package_Distribution__c> pkgDistributionMap) {
        Set<String> pkgDistributionNames = MA_DS_PackagePrepUtility.getDistributionsWithNoPackageRules(pkgDistributionMap);
        if(pkgDistributionNames.size() > 0) {
            throw new NoPackageRuleException(new String[] {JSON.serialize(pkgDistributionNames)});
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to throw exception if No Package Applied Rules found with "Need To Generate" for one or more Package Distribution records.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionMap	        DESCRIPTION (Data Type Map<Id, MA_DS_Package_Distribution__c>, Map of eligible Package Distribution records.
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void throwExceptionIfNoPackagePrepRules(Map<Id, MA_DS_Package_Distribution__c> pkgDistributionMap) {
        Set<String> pkgDistributionNames = MA_DS_PackagePrepUtility.getDistributionsWithNoNeedForPackagePrep(pkgDistributionMap);
        if(pkgDistributionNames.size() > 0) {
            throw new NoPackagePrepRulesException(new String[] {JSON.serialize(pkgDistributionNames)});
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to inititate the process of Package Prep for the eligible / selected Package Distribution records and returns the Processing Status Message.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    acqCompanyId	            DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    pkgDistributions	        DESCRIPTION (Data Type List<MA_DS_Package_Distribution__c>, List of Package Distribution records)
    * @param    executionOriginType	        DESCRIPTION (Data Type MA_DS_PackagePrepService.ExecutionOrigin, MA_DS_PackagePrepService.ExecutionOrigin enum type)
    * @return   String                      DESCRIPTION (return Processing Status Message)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String preparePackages(Id srcRecordId, Id acqCompanyId, List<MA_DS_Package_Distribution__c> pkgDistributions, MA_DS_PackagePrepService.ExecutionOrigin executionOriginType) {
        return initPreparePackages(srcRecordId, acqCompanyId, pkgDistributions, null, null, null, null, executionOriginType);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to inititate the process of Package Prep for the Audit Regen Package Common Ids and returns the Processing Status Message.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                        DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    acqCompanyId	                    DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    pkgDistributions	                DESCRIPTION (Data Type List<MA_DS_Package_Distribution__c>, List of Package Distribution records)
    * @param    commonIdMap	                        DESCRIPTION (Data Type Map<String, List<String>>, Map of Manager Summary Common Id to List of Offer Communicator Ids)
    * @param    auditStatus	                        DESCRIPTION (Data Type String, Audit regen status value)
    * @param    executionOriginType	                DESCRIPTION (Data Type MA_DS_PackagePrepService.ExecutionOrigin, MA_DS_PackagePrepService.ExecutionOrigin enum type)
    * @return   String                              DESCRIPTION (return Processing Status Message)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String preparePackages(Id srcRecordId, Id acqCompanyId, List<MA_DS_Package_Distribution__c> pkgDistributions, Map<String, List<String>> commonIdMap, String auditStatus, MA_DS_PackagePrepService.ExecutionOrigin executionOriginType) {
        Set<String> commonIds = commonIdMap.keySet();
        String commonId = new List<String>(commonIds)?.get(0);
        Set<String> templateIds = auditStatus.equalsIgnoreCase(AUDIT_STATUS_REGEN_TEMPLATE_DOCS) ? new Set<String>(commonIdMap.get(commonId)) : null;
        Set<String> acqContactIds = auditStatus.equalsIgnoreCase(AUDIT_STATUS_REGEN_ALL_CONTACTS_DOCS) ? new Set<String>(commonIdMap.get(commonId)) : null;
        Set<String> appliedRuleIds = auditStatus.equalsIgnoreCase(AUDIT_STATUS_REGEN_CONTACTS_DOCS) ? new Set<String>(commonIdMap.get(commonId)) : null;
        return initPreparePackages(srcRecordId, acqCompanyId, pkgDistributions, commonIds, templateIds, acqContactIds, appliedRuleIds, executionOriginType);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to inititate the process of Package Prep for the eligible / selected Package Distribution records and returns the Processing Status Message.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                        DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    acqCompanyId	                    DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    pkgDistributions	                DESCRIPTION (Data Type List<MA_DS_Package_Distribution__c>, List of Package Distribution records)
    * @param    commonIds	                        DESCRIPTION (Data Type Set<String>, Set of Package Common Ids for Audit Regen)
    * @param    templateIds	                        DESCRIPTION (Data Type Set<String>, Set of Template Common Ids for Audit Regen)
    * @param    acqContactIds	                    DESCRIPTION (Data Type Set<String>, Set of Acquisition Contact Ids for Audit Regen)
    * @param    appliedRuleIds	                    DESCRIPTION (Data Type Set<String>, Set of Applied Rule Ids for Audit Regen)
    * @param    executionOriginType	                DESCRIPTION (Data Type MA_DS_PackagePrepService.ExecutionOrigin, MA_DS_PackagePrepService.ExecutionOrigin enum type)
    * @return   String                              DESCRIPTION (return Processing Status Message)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String initPreparePackages(Id srcRecordId, Id acqCompanyId, List<MA_DS_Package_Distribution__c> pkgDistributions, Set<String> commonIds, Set<String> templateIds, Set<String> acqContactIds, Set<String> appliedRuleIds, MA_DS_PackagePrepService.ExecutionOrigin executionOriginType) {
        Set<Id> packagePrepPDIds = new Set<Id>();
        Set<String> pkgDistributionNames = new Set<String>();

        for(MA_DS_Package_Distribution__c pkgDistribution : pkgDistributions) {
            packagePrepPDIds.add(pkgDistribution.Id);
            pkgDistributionNames.add(pkgDistribution.Name);
        }
        
        if(pkgDistributions.size() > 0) {
            MA_DS_PackagePrepUtility.updatePkgDistributionsIntegrationStatus(pkgDistributions);
            initPreparePackages(srcRecordId, acqCompanyId, packagePrepPDIds, commonIds, templateIds, acqContactIds, appliedRuleIds, executionOriginType);
        }

        return (pkgDistributions.size() > 0) ? String.format(PACKAGE_PREP_MESSAGE, new String[] {JSON.serialize(pkgDistributionNames)}) : '';
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to inititate the process of Package Prep for the eligible / selected Package Distribution / Failed Common Id.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                        DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    acqCompanyId	                    DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    packagePrepPDIds	                DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to be processed for Package Prep or Regeneration)
    * @param    commonIds	                        DESCRIPTION (Data Type Set<String>, Set of Package Common Ids for Audit Regen)
    * @param    templateIds	                        DESCRIPTION (Data Type Set<String>, Set of Template Common Ids for Audit Regen)
    * @param    acqContactIds	                    DESCRIPTION (Data Type Set<String>, Set of Acquisition Contact Ids for Audit Regen)
    * @param    appliedRuleIds	                    DESCRIPTION (Data Type Set<String>, Set of Applied Rule Ids for Audit Regen)
    * @param    executionOriginType	                DESCRIPTION (Data Type MA_DS_PackagePrepService.ExecutionOrigin, MA_DS_PackagePrepService.ExecutionOrigin enum type)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void initPreparePackages(Id srcRecordId, Id acqCompanyId, Set<Id> packagePrepPDIds, Set<String> commonIds, Set<String> templateIds, Set<String> acqContactIds, Set<String> appliedRuleIds, MA_DS_PackagePrepService.ExecutionOrigin executionOriginType) {
        MA_DS_PackagePrepService.strategyInstance.setSrcRecordId(srcRecordId)
                                                 .setAcqCompanyId(acqCompanyId)
                                                 .setPackagePrepPDIds(packagePrepPDIds)
                                                 .setAuditFailedCommonIds(commonIds)
                                                 .setTemplateIds(templateIds)
                                                 .setAcqContactIds(acqContactIds)
                                                 .setAppliedRuleIds(appliedRuleIds)
                                                 .setExecutionJobType(MA_DS_PackagePrepService.ExecutionJob.PREP_ACQ_CONTACTS)
                                                 .setExecutionJobOriginType(executionOriginType)
                                                 .initPrepService()
                                                 .initPackagePrepJob()
                                                 .execute();
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to throw exception when Integration Status is ineligible for initiating Package Prep process.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class IneligibleIntegrationStatusException extends Exception {
        private List<String> exceptionMsgParams;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the IneligibleIntegrationStatusException class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public IneligibleIntegrationStatusException(List<String> exceptionMsgParams) {
            this.exceptionMsgParams = new List<String> {MA_DS_PackagePrepHelper.IneligibleIntegrationStatusException.class.getName()};
            this.exceptionMsgParams.addAll(exceptionMsgParams);
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method overrides the getMessage() method of the Exception class to return the custom exception message.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getMessage() {
            return String.format(INELIGIBLE_INT_STATUS_EXCEPTION, exceptionMsgParams);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to throw exception when Rules Sync Status is ineligible for initiating Package Prep process.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class IneligibleRulesSyncStatusException extends Exception {
        private List<String> exceptionMsgParams;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the IneligibleRulesSyncStatusException class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public IneligibleRulesSyncStatusException(List<String> exceptionMsgParams) {
            this.exceptionMsgParams = new List<String> {MA_DS_PackagePrepHelper.IneligibleRulesSyncStatusException.class.getName()};
            this.exceptionMsgParams.addAll(exceptionMsgParams);
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method overrides the getMessage() method of the Exception class to return the custom exception message.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getMessage() {
            return String.format(INELIGIBLE_RULES_SYNC_STATUS_EXCEPTION, exceptionMsgParams);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to throw exception when there are no eligible Package Distribution records to initiate the Package Prep process.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class NoEligiblePackageDistributionException extends Exception {
        private List<String> exceptionMsgParams;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the NoEligiblePackageDistributionException class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public NoEligiblePackageDistributionException(List<String> exceptionMsgParams) {
            this.exceptionMsgParams = new List<String> {MA_DS_PackagePrepHelper.NoEligiblePackageDistributionException.class.getName()};
            this.exceptionMsgParams.addAll(exceptionMsgParams);
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method overrides the getMessage() method of the Exception class to return the custom exception message.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getMessage() {
            return String.format(NO_PD_FOR_PACKAGE_PREP_EXCEPTION, exceptionMsgParams);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to throw exception when one or more Package Distribution Acquisition Contacts are not yet ready for Package Prep process.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class NotReadyForPackagePrepException extends Exception {
        private List<String> exceptionMsgParams;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the NotReadyForPackagePrepException class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public NotReadyForPackagePrepException(List<String> exceptionMsgParams) {
            this.exceptionMsgParams = new List<String> {MA_DS_PackagePrepHelper.NotReadyForPackagePrepException.class.getName()};
            this.exceptionMsgParams.addAll(exceptionMsgParams);
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method overrides the getMessage() method of the Exception class to return the custom exception message.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getMessage() {
            return String.format(NOT_READY_FOR_PACKAGE_PREP_EXCEPTION, exceptionMsgParams);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to throw exception when one or more Package Distribution Acquisition Contacts doesn't have a Package Rule.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class NoPackageRuleException extends Exception {
        private List<String> exceptionMsgParams;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the NoPackageRuleException class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public NoPackageRuleException(List<String> exceptionMsgParams) {
            this.exceptionMsgParams = new List<String> {MA_DS_PackagePrepHelper.NoPackageRuleException.class.getName()};
            this.exceptionMsgParams.addAll(exceptionMsgParams);
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method overrides the getMessage() method of the Exception class to return the custom exception message.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getMessage() {
            return String.format(NO_PACKAGE_RULE_EXCEPTION, exceptionMsgParams);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to throw exception when one or more Package Distributions doesn't have any Applied Rules with "Need To Generate".
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class NoPackagePrepRulesException extends Exception {
        private List<String> exceptionMsgParams;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the NoPackagePrepRulesException class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public NoPackagePrepRulesException(List<String> exceptionMsgParams) {
            this.exceptionMsgParams = new List<String> {MA_DS_PackagePrepHelper.NoPackagePrepRulesException.class.getName()};
            this.exceptionMsgParams.addAll(exceptionMsgParams);
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method overrides the getMessage() method of the Exception class to return the custom exception message.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getMessage() {
            return String.format(NO_PACKAGE_PREP_RULES_EXCEPTION, exceptionMsgParams);
        }
    }
}