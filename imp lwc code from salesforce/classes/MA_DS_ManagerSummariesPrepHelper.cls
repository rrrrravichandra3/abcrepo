/**
 * W-12578116
 * Helper class to inititate the process to Prepare Manager Summaries for all eligible / selected Package Distribution records.
 * 
 * Version      Date            Author                  Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         26/03/2023      Chakshu Malhotra        W-12578116 - Adds logic to inititate the process to Prepare Manager Summaries for all eligible / selected Package Distribution records.
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_ManagerSummariesPrepHelper {

    private static final String NO_PD_FOR_SUMMARY_PREP_EXCEPTION = Label.MA_DS_No_PD_For_Summary_Prep;
    private static final String NO_OFFER_COMUNICATOR_EXCEPTION = Label.MA_DS_No_Offer_Communicator_Exception;
    private static final String NO_SUMMARY_PREP_RULES_EXCEPTION = Label.MA_DS_No_Summary_Prep_Rules_Exception;
    private static final String NO_MANAGER_SUMMARY_RULE_EXCEPTION = Label.MA_DS_No_Manager_Summary_Rule_Exception;

    private static final String ELIGIBLE_INTEGRATION_STATUS = Label.MA_DS_Eligible_Integration_Status;
    private static final String INELIGIBLE_INT_STATUS_EXCEPTION = Label.MA_DS_Ineligible_Int_Status_For_Summary_Prep;

    private static final String SYNCING_PACKAGE_RULES = Label.MA_DS_Syncing_Package_Rules_Status;
    private static final String SYNCING_TEMPLATE_RULES = Label.MA_DS_Syncing_Templates_Rules_Status;
    private static final String INELIGIBLE_RULES_SYNC_STATUS_EXCEPTION = Label.MA_DS_Ineligible_Rules_Sync_Status_For_Summary_Prep;

    private static final String AUDIT_STATUS_REGEN_ALL_CONTACTS_DOCS = Label.MA_DS_Audit_Status_Regen_All_Contacts_Docs;

    private static final String MANAGER_SUMMARY_PREP_MESSAGE = Label.MA_DS_Preparing_Manager_Summaries_Message;

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the set of Rules Sync Status values that makes a Package Distribution ineligible for Manager Summary Prep process.
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
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initiate the processing of Manager Summaries Prep for all Package Distribution and return Processing Status Message.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	        DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @return   String                  DESCRIPTION (return processStatus message for the "Prepare Manager Summaries" action)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static String prepareManagerSummaries(Id acqCompanyId) {
        List<MA_DS_Package_Distribution__c> pkgDistributions = MA_DS_ManagerSummariesPrepUtility.getPackageDistributions(false, acqCompanyId, null);
        Map<Id, MA_DS_Package_Distribution__c> eligiblePkgDistributionMap = throwExceptionsIfNeeded(acqCompanyId, pkgDistributions);
        return prepareManagerSummaries(acqCompanyId, acqCompanyId, eligiblePkgDistributionMap.values(), MA_DS_ManagerSummaryPrepService.ExecutionOrigin.PREP_REGEN_ALL);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initiate the processing of Manager Summaries Prep for selected Package Distributions on the UI and return Processing Status Message.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	            DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    acqCompanyId	        DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    pkgDistributionIds	    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @return   String                  DESCRIPTION (return processStatus message for the "Prepare Manager Summaries" action)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static String prepareManagerSummaries(Id srcRecordId, Id acqCompanyId, Set<Id> pkgDistributionIds) {
        List<MA_DS_Package_Distribution__c> pkgDistributions = MA_DS_ManagerSummariesPrepUtility.getPackageDistributions(false, acqCompanyId, pkgDistributionIds);
        Map<Id, MA_DS_Package_Distribution__c> eligiblePkgDistributionMap = throwExceptionsIfNeeded(acqCompanyId, pkgDistributions);
        return prepareManagerSummaries(srcRecordId, acqCompanyId, eligiblePkgDistributionMap.values(), MA_DS_ManagerSummaryPrepService.ExecutionOrigin.PREP_REGEN_SELECTED);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to auto-initiate the processing of Manager Summaries Prep for Failed Common Id / Offer Communicator Ids and return Processing Status Message.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	        DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    commonIdMap	            DESCRIPTION (Data Type Map<String, List<String>>, Map of Manager Summary Common Id to List of Offer Communicator Ids)
    * @param    auditStatus	            DESCRIPTION (Data Type String, Audit regen status value)
    * @return   String                  DESCRIPTION (return processStatus message for the "Prepare Manager Summaries" action)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static String prepareManagerSummaries(Id acqCompanyId, Map<String, List<String>> commonIdMap, String auditStatus) {
        Set<Id> pkgDistributionIds = MA_DS_ManagerSummariesPrepUtility.getPackageDistributionIds(acqCompanyId, commonIdMap.keySet());
        List<MA_DS_Package_Distribution__c> pkgDistributions = MA_DS_ManagerSummariesPrepUtility.getPackageDistributions(true, acqCompanyId, pkgDistributionIds);
        Map<Id, MA_DS_Package_Distribution__c> eligiblePkgDistributionMap = throwExceptionsIfNeeded(acqCompanyId, pkgDistributions);
        return prepareManagerSummaries(acqCompanyId, acqCompanyId, eligiblePkgDistributionMap.values(), commonIdMap, auditStatus, MA_DS_ManagerSummaryPrepService.ExecutionOrigin.AUDIT_FAILED_REGEN);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to throw exception if any of the Package Distribution record is ineligible to initiate the Manager Summary Prep process.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	                            DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    pkgDistributions	                        DESCRIPTION (Data Type List<MA_DS_Package_Distribution__c>, List of Package Distribution records)
    * @return   Map<Id, MA_DS_Package_Distribution__c>      DESCRIPTION (return Map of all Eligible Package Distribution records that can be processed for Manager Summary Prep process)
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
            throwExceptionIfNoManagerSummaryRules(eligiblePkgDistributionMap);
            throwExceptionIfNoOfferCommunicators(eligiblePkgDistributionMap);
            throwExceptionIfNoSummaryPrepRules(eligiblePkgDistributionMap);
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
    * Method to throw exception if Rules Sync Status is not eligible for initiating the Manager Summary Prep process.
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
    * Method to throw exception if No Manager Summary Rule found for atleast one of the Acquisition Contact in the eligible Package Distribution records.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionMap	        DESCRIPTION (Data Type Map<Id, MA_DS_Package_Distribution__c>, Map of eligible Package Distribution records.
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void throwExceptionIfNoManagerSummaryRules(Map<Id, MA_DS_Package_Distribution__c> pkgDistributionMap) {
        Set<String> pkgDistributionNames = MA_DS_ManagerSummariesPrepUtility.getDistributionsWithNoManagerSummaryRules(pkgDistributionMap);
        if(pkgDistributionNames.size() > 0) {
            throw new NoManagerSummaryRuleException(new String[] {JSON.serialize(pkgDistributionNames)});
        }
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to throw exception if No Offer Communicator(s) found on one or more eligible Package Distribution records.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionMap	        DESCRIPTION (Data Type Map<Id, MA_DS_Package_Distribution__c>, Map of eligible Package Distribution records.
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void throwExceptionIfNoOfferCommunicators(Map<Id, MA_DS_Package_Distribution__c> pkgDistributionMap) {
        Set<String> pkgDistributionNames = MA_DS_ManagerSummariesPrepUtility.getDistributionsWithNoOfferCommunicators(pkgDistributionMap);
        if(pkgDistributionNames.size() > 0) {
            throw new NoOfferCommunicatorsException(new String[] {JSON.serialize(pkgDistributionNames)});
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to throw exception if No Manager Summary Applied Rules found with "Need To Generate" for one or more Package Distribution records.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionMap	        DESCRIPTION (Data Type Map<Id, MA_DS_Package_Distribution__c>, Map of eligible Package Distribution records.
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void throwExceptionIfNoSummaryPrepRules(Map<Id, MA_DS_Package_Distribution__c> pkgDistributionMap) {
        Set<String> pkgDistributionNames = MA_DS_ManagerSummariesPrepUtility.getDistributionsWithNoNeedForSummaryPrep(pkgDistributionMap);
        if(pkgDistributionNames.size() > 0) {
            throw new NoSummaryPrepRulesException(new String[] {JSON.serialize(pkgDistributionNames)});
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to inititate the process of Manager Summaries Prep for the eligible / selected Package Distribution records and returns the Processing Status Message.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    acqCompanyId	            DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    pkgDistributions	        DESCRIPTION (Data Type List<MA_DS_Package_Distribution__c>, List of Package Distribution records)
    * @param    executionOriginType	        DESCRIPTION (Data Type MA_DS_ManagerSummaryPrepService.ExecutionOrigin, MA_DS_ManagerSummaryPrepService.ExecutionOrigin enum type)
    * @return   String                      DESCRIPTION (return Processing Status Message)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String prepareManagerSummaries(Id srcRecordId, Id acqCompanyId, List<MA_DS_Package_Distribution__c> pkgDistributions, MA_DS_ManagerSummaryPrepService.ExecutionOrigin executionOriginType) {
        return initPrepareManagerSummaries(srcRecordId, acqCompanyId, pkgDistributions, null, null, executionOriginType);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to inititate the process of Manager Summaries Prep for the Audit Regen Manager Summary Common Id and returns the Processing Status Message.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                        DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    acqCompanyId	                    DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    pkgDistributions	                DESCRIPTION (Data Type List<MA_DS_Package_Distribution__c>, List of Package Distribution records)
    * @param    commonIdMap	                        DESCRIPTION (Data Type Map<String, List<String>>, Map of Manager Summary Common Id to List of Offer Communicator Ids)
    * @param    auditStatus	                        DESCRIPTION (Data Type String, Audit regen status value)
    * @param    executionOriginType	                DESCRIPTION (Data Type MA_DS_ManagerSummaryPrepService.ExecutionOrigin, MA_DS_ManagerSummaryPrepService.ExecutionOrigin enum type)
    * @return   String                              DESCRIPTION (return Processing Status Message)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String prepareManagerSummaries(Id srcRecordId, Id acqCompanyId, List<MA_DS_Package_Distribution__c> pkgDistributions, Map<String, List<String>> commonIdMap, String auditStatus, MA_DS_ManagerSummaryPrepService.ExecutionOrigin executionOriginType) {
        Set<String> commonIds = commonIdMap.keySet();
        String commonId = new List<String>(commonIds)?.get(0);
        Set<String> offerCommunicatorIds = auditStatus.equalsIgnoreCase(AUDIT_STATUS_REGEN_ALL_CONTACTS_DOCS) ? new Set<String>(commonIdMap.get(commonId)) : null;
        return initPrepareManagerSummaries(srcRecordId, acqCompanyId, pkgDistributions, commonIds, offerCommunicatorIds, executionOriginType);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to inititate the process of Manager Summaries Prep for the eligible / selected Package Distribution records and returns the Processing Status Message.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                        DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    acqCompanyId	                    DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    pkgDistributions	                DESCRIPTION (Data Type List<MA_DS_Package_Distribution__c>, List of Package Distribution records)
    * @param    commonIds	                        DESCRIPTION (Data Type Set<String>, Set of Manager Summary Common Id)
    * @param    offerCommunicatorIds	            DESCRIPTION (Data Type Set<String>, Set of Offer Communicator Ids processed for Manager Summary Prep)
    * @param    executionOriginType	                DESCRIPTION (Data Type MA_DS_ManagerSummaryPrepService.ExecutionOrigin, MA_DS_ManagerSummaryPrepService.ExecutionOrigin enum type)
    * @return   String                              DESCRIPTION (return Processing Status Message)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String initPrepareManagerSummaries(Id srcRecordId, Id acqCompanyId, List<MA_DS_Package_Distribution__c> pkgDistributions, Set<String> commonIds, Set<String> offerCommunicatorIds, MA_DS_ManagerSummaryPrepService.ExecutionOrigin executionOriginType) {
        Set<Id> summaryPrepPDIds = new Set<Id>();
        Set<String> pkgDistributionNames = new Set<String>();

        for(MA_DS_Package_Distribution__c pkgDistribution : pkgDistributions) {
            summaryPrepPDIds.add(pkgDistribution.Id);
            pkgDistributionNames.add(pkgDistribution.Name);
        }

        if(pkgDistributions.size() > 0) {
            MA_DS_ManagerSummariesPrepUtility.updatePkgDistributionsIntegrationStatus(pkgDistributions);
            initPrepareManagerSummaries(srcRecordId, acqCompanyId, summaryPrepPDIds, commonIds, offerCommunicatorIds, executionOriginType);
        }

        return (pkgDistributions.size() > 0) ? String.format(MANAGER_SUMMARY_PREP_MESSAGE, new String[] {JSON.serialize(pkgDistributionNames)}) : '';
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to inititate the process of Manager Summaries Prep for the eligible / selected Package Distribution / Failed Common Id.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                        DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    acqCompanyId	                    DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    summaryPrepPDIds	                DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to be processed for Manager Summary Prep or Regeneration)
    * @param    commonIds	                        DESCRIPTION (Data Type Set<String>, Set of Manager Summary Common Ids)
    * @param    offerCommunicatorIds	            DESCRIPTION (Data Type Set<String>, Set of Offer Communicator Ids processed for Manager Summary Prep)
    * @param    executionOriginType	                DESCRIPTION (Data Type MA_DS_ManagerSummaryPrepService.ExecutionOrigin, MA_DS_ManagerSummaryPrepService.ExecutionOrigin enum type)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void initPrepareManagerSummaries(Id srcRecordId, Id acqCompanyId, Set<Id> summaryPrepPDIds, Set<String> commonIds, Set<String> offerCommunicatorIds, MA_DS_ManagerSummaryPrepService.ExecutionOrigin executionOriginType) {
        MA_DS_ManagerSummaryPrepService.strategyInstance.setSrcRecordId(srcRecordId)
                                                        .setAcqCompanyId(acqCompanyId)
                                                        .setSummaryTemplateId(MA_DS_ManagerSummariesPrepUtility.getManagerSummaryTemplateId(acqCompanyId))
                                                        .setSummaryPrepPDIds(summaryPrepPDIds)
                                                        .setAuditFailedCommonIds(commonIds)
                                                        .setOfferCommunicatorIds(offerCommunicatorIds)
                                                        .setExecutionJobType(MA_DS_ManagerSummaryPrepService.ExecutionJob.PREP_OFFER_COMMUNICATORS)
                                                        .setExecutionJobOriginType(executionOriginType)
                                                        .initPrepService()
                                                        .initSummaryPrepJob()
                                                        .execute();
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to throw exception when Integration Status is ineligible for initiating Manager Summary Prep process.
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
            this.exceptionMsgParams = new List<String> {MA_DS_ManagerSummariesPrepHelper.IneligibleIntegrationStatusException.class.getName()};
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
    * Custom Exception class to throw exception when Rules Sync Status is ineligible for initiating Manager Summary Prep process.
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
            this.exceptionMsgParams = new List<String> {MA_DS_ManagerSummariesPrepHelper.IneligibleRulesSyncStatusException.class.getName()};
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
    * Custom Exception class to throw exception when there are no eligible Package Distribution records to initiate the Manager Summary Prep process.
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
            this.exceptionMsgParams = new List<String> {MA_DS_ManagerSummariesPrepHelper.NoEligiblePackageDistributionException.class.getName()};
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
            return String.format(NO_PD_FOR_SUMMARY_PREP_EXCEPTION, exceptionMsgParams);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to throw exception when one or more Package Distribution Acquisition Contacts doesn't have a Manager Summary Rule.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class NoManagerSummaryRuleException extends Exception {
        private List<String> exceptionMsgParams;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the NoManagerSummaryRuleException class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public NoManagerSummaryRuleException(List<String> exceptionMsgParams) {
            this.exceptionMsgParams = new List<String> {MA_DS_ManagerSummariesPrepHelper.NoManagerSummaryRuleException.class.getName()};
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
            return String.format(NO_MANAGER_SUMMARY_RULE_EXCEPTION, exceptionMsgParams);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to throw exception when one or more Package Distribution Acquisition Contacts doesn't have an Offer Communicator.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class NoOfferCommunicatorsException extends Exception {
        private List<String> exceptionMsgParams;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the NoOfferCommunicatorsException class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public NoOfferCommunicatorsException(List<String> exceptionMsgParams) {
            this.exceptionMsgParams = new List<String> {MA_DS_ManagerSummariesPrepHelper.NoOfferCommunicatorsException.class.getName()};
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
            return String.format(NO_OFFER_COMUNICATOR_EXCEPTION, exceptionMsgParams);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to throw exception when one or more Package Distributions doesn't have any Applied Rules with "Need To Generate".
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class NoSummaryPrepRulesException extends Exception {
        private List<String> exceptionMsgParams;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the NoSummaryPrepRulesException class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public NoSummaryPrepRulesException(List<String> exceptionMsgParams) {
            this.exceptionMsgParams = new List<String> {MA_DS_ManagerSummariesPrepHelper.NoSummaryPrepRulesException.class.getName()};
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
            return String.format(NO_SUMMARY_PREP_RULES_EXCEPTION, exceptionMsgParams);
        }
    }
}