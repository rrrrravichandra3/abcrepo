/**
 * ******************************************** W-12578108 : RULE ENGINE ********************************************
 * 
 * Helper class to process Package / Template Applied Rules for a given Package Distribution.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         17/03/2023      Chakshu Malhotra        W-12578108 - Adds logic to process Package / Template Applied Rules for a given Package Distribution.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_AppliedRulesHelper {

    private static final String RULES_SYNCED_STATUS = Label.MA_DS_Rules_Synced_Status;
    private static final String ELIGIBLE_RULES_SYNC_STATUS = Label.MA_DS_Eligible_Rules_Sync_Status;
    private static final String ELIGIBLE_INTEGRATION_STATUS = Label.MA_DS_Eligible_Integration_Status;
    private static final String ELIGIBLE_STATUS = Label.MA_DS_Eligible_Status_For_Template_Rules_Update;
    private static final String TEMPLATE_RULES_SYNC_STATUS = Label.MA_DS_Need_Sync_Template_Rules_Status;
    private static final String PACKAGE_TEMPLATE_RULES_SYNC_STATUS = Label.MA_DS_Need_Sync_Package_Template_Rules_Status;
    private static final String ELIGIBLE_PACKAGE_RULES_SYNC_STATUS = Label.MA_DS_Eligible_Package_Status_For_Rules_Update;

    private static final String SYNCING_PACKAGE_RULES = Label.MA_DS_Syncing_Package_Rules_Status;
    private static final String SYNCING_TEMPLATE_RULES = Label.MA_DS_Syncing_Templates_Rules_Status;

    private static final String TEMPLATES = Label.MA_DS_Template_Records;
    private static final String PACKAGE_TEMPLATES = Label.MA_DS_Package_Template_Records;
    private static final String APPLYING_RULES_MESSAGE = Label.MA_DS_Applying_Rules_Message;
    private static final String INELIGIBLE_STATUS_APPLYING_RULES_MESSAGE = Label.MA_DS_Ineligible_Status_Applying_Rules_Message;

    private static final String NO_RULES_CRITERIA_EXCEPTION_MSG = Label.MA_DS_No_Rules_Criteria_Error;
    private static final String INELIGIBLE_STATUS_EXCEPTION_MSG = Label.MA_DS_Ineligible_Status_Exception;
    private static final String INELIGIBLE_RULES_SYNC_STATUS_EXCEPTION_MSG = Label.MA_DS_Invalid_Rules_Sync_Status_Exception;
    private static final String INELIGIBLE_INTEGRATION_STATUS_EXCEPTION_MSG = Label.MA_DS_Ineligible_Integration_Status_On_Rule_Sync;

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the set of Rules Sync Status values that makes a Package Distribution eligible for Rules syncing.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Set<String> eligibleRulesSyncStatusSet {
        get {
            if(eligibleRulesSyncStatusSet == null) {
                eligibleRulesSyncStatusSet = new Set<String>((List<String>)JSON.deserialize(ELIGIBLE_RULES_SYNC_STATUS, List<String>.class));
            }
            return eligibleRulesSyncStatusSet;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the set of status values that makes a Package Distribution eligible for Rules syncing.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Set<String> eligibleStatusSet {
        get {
            if(eligibleStatusSet == null) {
                eligibleStatusSet = new Set<String>((List<String>)JSON.deserialize(ELIGIBLE_STATUS, List<String>.class));
            }
            return eligibleStatusSet;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the set of status values that makes a Package Distribution eligible for Package Distribution Rules syncing.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Set<String> eligiblePackageRulesStatusSet {
        get {
            if(eligiblePackageRulesStatusSet == null) {
                eligiblePackageRulesStatusSet = new Set<String>((List<String>)JSON.deserialize(ELIGIBLE_PACKAGE_RULES_SYNC_STATUS, List<String>.class));
            }
            return eligiblePackageRulesStatusSet;
        }set;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initiate the processing of Applied Rules and return Processing Status Message.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    recordId	            DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @return   String                  DESCRIPTION (return processStatus message for the Apply Rules action)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static String processAppliedRules(Id recordId) {
        MA_DS_Package_Distribution__c pkgDistribution = getPackageDistribution(recordId);
        throwExceptionsIfNeeded(pkgDistribution);
        return processAppliedRules(pkgDistribution);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the Package Distribution record details based on the recordId.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    recordId	                        DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @return   MA_DS_Package_Distribution__c       DESCRIPTION (return Package Distribution record)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static MA_DS_Package_Distribution__c getPackageDistribution(Id recordId) {
        return [SELECT Id, MA_DS_Package__c, MA_DS_Package__r.MA_DS_Acquisition_Company__c, MA_DS_Status__c, MA_DS_Rules_Sync_Status__c, MA_DS_Rules_Criteria_JSON__c, 
                MA_DS_Rules_Criteria_Query__c, MA_DS_Last_Synced_Rules_Criteria_JSON__c, MA_DS_Last_Synced_Criteria_Query__c, MA_DS_Integration_Status__c
                FROM MA_DS_Package_Distribution__c
                WHERE Id = :recordId LIMIT 1];
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to throw exception if Status is ineligible, or Rules Sync Status is ineligible or Rules Criteria Query is blank.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistribution	                    DESCRIPTION (Data Type MA_DS_Package_Distribution__c, Package Distribution record)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void throwExceptionsIfNeeded(MA_DS_Package_Distribution__c pkgDistribution) {
        throwExceptionIfIneligibleIntegrationStatus(pkgDistribution.MA_DS_Integration_Status__c);
        throwExceptionIfIneligibleRulesSyncStatus(pkgDistribution.MA_DS_Rules_Sync_Status__c);
        throwExceptionIfBlankRulesCriteriaQuery(pkgDistribution.MA_DS_Rules_Criteria_Query__c);
        throwExceptionIfIneligibleStatus(pkgDistribution);
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
            throw new IneligibleIntegrationStatusException(new String[] {MA_DS_AppliedRulesHelper.IneligibleIntegrationStatusException.class.getName(), integrationStatus});
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to throw exception if Rules Sync Status is not eligible for syncing the Applied Rules.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    rulesSyncStatus	                    DESCRIPTION (Data Type String, Rules Sync Status of the Package Distribution)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void throwExceptionIfIneligibleRulesSyncStatus(String rulesSyncStatus) {
        if(!eligibleRulesSyncStatusSet.contains(rulesSyncStatus)) {
            throw new IneligibleRulesSyncStatusException(new String[] {MA_DS_AppliedRulesHelper.IneligibleRulesSyncStatusException.class.getName(), rulesSyncStatus});
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to throw exception if Rules Criteria Query blank.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    rulesCriteriaQuery	                    DESCRIPTION (Data Type String, Rules Criteria Query of the Package Distribution)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void throwExceptionIfBlankRulesCriteriaQuery(String rulesCriteriaQuery) {
        if(String.isBlank(rulesCriteriaQuery)) {
            String exMsg = MA_DS_AppliedRulesHelper.NoRulesCriteriaQueryException.class.getName() + ': ' + NO_RULES_CRITERIA_EXCEPTION_MSG;
            throw new NoRulesCriteriaQueryException(exMsg);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to throw exception if Package Distribution Status is not eligible for syncing the Applied Rules.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistribution	         DESCRIPTION (Data Type MA_DS_Package_Distribution__c, Package Distribution record)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void throwExceptionIfIneligibleStatus(MA_DS_Package_Distribution__c pkgDistribution) {
        String status = pkgDistribution.MA_DS_Status__c;
        
        if(!eligibleStatusSet.contains(status)) {
            updatePackageDistributionIfNeeded(pkgDistribution);
            throw new IneligibleStatusException(new String[] {MA_DS_AppliedRulesHelper.IneligibleStatusException.class.getName(), status});
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the Package Distribution if no longer eligible for syncing rules.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistribution	         DESCRIPTION (Data Type MA_DS_Package_Distribution__c, Package Distribution record)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updatePackageDistributionIfNeeded(MA_DS_Package_Distribution__c pkgDistribution) {
        String rulesSyncStatus = pkgDistribution.MA_DS_Rules_Sync_Status__c;

        if(eligibleRulesSyncStatusSet.contains(rulesSyncStatus)) {
            updateRulesCriteriaToLastSyncedState(pkgDistribution);
            updatePackageDistribution(pkgDistribution, RULES_SYNCED_STATUS);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the Rules Query & JSON to last synced state if Package Distribution is no longer eligible for syncing rules.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistribution	         DESCRIPTION (Data Type MA_DS_Package_Distribution__c, Package Distribution record)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateRulesCriteriaToLastSyncedState(MA_DS_Package_Distribution__c pkgDistribution) {
        String rulesQuery = pkgDistribution.MA_DS_Rules_Criteria_Query__c;
        String rulesJSON = pkgDistribution.MA_DS_Rules_Criteria_JSON__c;
        String lastSyncedRulesQuery = pkgDistribution.MA_DS_Last_Synced_Criteria_Query__c;
        String lastSyncedRulesJSON = pkgDistribution.MA_DS_Last_Synced_Rules_Criteria_JSON__c;

        pkgDistribution.MA_DS_Rules_Criteria_JSON__c = String.isBlank(lastSyncedRulesJSON) ? rulesJSON : lastSyncedRulesJSON;
        pkgDistribution.MA_DS_Rules_Criteria_Query__c = String.isBlank(lastSyncedRulesQuery) ? rulesQuery : lastSyncedRulesQuery;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the Rules Sync Status on the Package Distribution record.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistribution	         DESCRIPTION (Data Type MA_DS_Package_Distribution__c, Package Distribution record)
    * @param    rulesSyncStatus	         DESCRIPTION (Data Type String, Rules Sync Status value)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updatePackageDistribution(MA_DS_Package_Distribution__c pkgDistribution, String rulesSyncStatus) {
        pkgDistribution.MA_DS_Rules_Sync_Status__c = rulesSyncStatus;
        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = true;
        Database.SaveResult[] packageDistSRList = Database.update(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(packageDistSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to inititate the process of Applying Rules and returns the Processing Status Message.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistribution	            DESCRIPTION (Data Type MA_DS_Package_Distribution__c, Package Distribution record)
    * @return   String                      DESCRIPTION (return Processing Status Message)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String processAppliedRules(MA_DS_Package_Distribution__c pkgDistribution) {
        String status = pkgDistribution.MA_DS_Status__c;
        String rulesSyncStatus = pkgDistribution.MA_DS_Rules_Sync_Status__c;
        
        if(eligibleRulesSyncStatusSet.contains(rulesSyncStatus)) {
            updateToLastSyncedStateIfNeeded(pkgDistribution);
            updatePackageDistribution(pkgDistribution, getNewRulesSyncStatus(status, rulesSyncStatus));
            MA_DS_AppliedRulesService.strategyInstance.setExecutionModeEnum(MA_DS_AppliedRulesService.ExecutionMode.SYNC_RULE)
                                                      .setExecutionJobEnum(getAppliedRulesServiceExecutionJob(status, rulesSyncStatus))
                                                      .setAcquisitionCompanyId(pkgDistribution.MA_DS_Package__r.MA_DS_Acquisition_Company__c)
                                                      .setPackageId(pkgDistribution.MA_DS_Package__c)
                                                      .setPackageDistributionId(pkgDistribution.Id)
                                                      .initAppliedRuleJob()
                                                      .execute();
        }

        return eligibleRulesSyncStatusSet.contains(rulesSyncStatus) ? getProcessStatus(status, rulesSyncStatus) : '';
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to return the updated Rules Sync Status value based on current value of Rules Sync Status & Package Distribution Status.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    status	                    DESCRIPTION (Data Type String, Package Distribution Status value)
    * @param    rulesSyncStatus	            DESCRIPTION (Data Type String, Rules Sync Status value)
    * @return   String                      DESCRIPTION (return Updated Rules Sync Status value)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getNewRulesSyncStatus(String status, String rulesSyncStatus) {
        return (rulesSyncStatus.equalsIgnoreCase(PACKAGE_TEMPLATE_RULES_SYNC_STATUS) && eligiblePackageRulesStatusSet.contains(status)) ? 
                SYNCING_PACKAGE_RULES : SYNCING_TEMPLATE_RULES;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Rules Query & JSON on Package Distribution record to Last synced state if no longer eligible for Syncing Package Rules.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistribution	            DESCRIPTION (Data Type MA_DS_Package_Distribution__c, Package Distribution record)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateToLastSyncedStateIfNeeded(MA_DS_Package_Distribution__c pkgDistribution) {
        String status = pkgDistribution.MA_DS_Status__c;
        String rulesSyncStatus = pkgDistribution.MA_DS_Rules_Sync_Status__c;

        if(rulesSyncStatus.equalsIgnoreCase(PACKAGE_TEMPLATE_RULES_SYNC_STATUS) && !eligiblePackageRulesStatusSet.contains(status)) {
            updateRulesCriteriaToLastSyncedState(pkgDistribution);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to return the MA_DS_AppliedRulesService.ExecutionJob enum type based on current value of Rules Sync Status & Package Distribution Status.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    status	                                    DESCRIPTION (Data Type String, Package Distribution Status value)
    * @param    rulesSyncStatus	                            DESCRIPTION (Data Type String, Rules Sync Status value)
    * @return   MA_DS_AppliedRulesService.ExecutionJob      DESCRIPTION (return MA_DS_AppliedRulesService.ExecutionJob enum type)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static MA_DS_AppliedRulesService.ExecutionJob getAppliedRulesServiceExecutionJob(String status, String rulesSyncStatus) {
        return (rulesSyncStatus.equalsIgnoreCase(PACKAGE_TEMPLATE_RULES_SYNC_STATUS) && eligiblePackageRulesStatusSet.contains(status)) ? 
                MA_DS_AppliedRulesService.ExecutionJob.PACKAGE_RULE_SYNC : MA_DS_AppliedRulesService.ExecutionJob.TEMPLATE_RULE_SYNC;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to return the Applied Rules Processing status message for the given Package Distribution Status & Rules Sync Status.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    status	                    DESCRIPTION (Data Type String, Package Distribution Status value)
    * @param    rulesSyncStatus	            DESCRIPTION (Data Type String, Rules Sync Status value)
    * @return   String                      DESCRIPTION (return Processing Status Message)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getProcessStatus(String status, String rulesSyncStatus) {
        return rulesSyncStatus.equalsIgnoreCase(PACKAGE_TEMPLATE_RULES_SYNC_STATUS) ? (eligiblePackageRulesStatusSet.contains(status) ? 
               getPackageTemplatesProcessStatus() : getTemplatesProcessStatus(false, status)) : getTemplatesProcessStatus(true, status);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to return the Applied Rules Processing status message for syncing In Use Template type Applied Rules.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   String                      DESCRIPTION (return Processing Status Message)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getPackageTemplatesProcessStatus() {
        return String.format(APPLYING_RULES_MESSAGE, new String[] {PACKAGE_TEMPLATES});
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to return the Applied Rules Processing status message for syncing Package Distribution type Applied Rules (if valid status) or else for In Use Template type Applied Rules.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    validStatus	                DESCRIPTION (Data Type Boolean, Checks if Status is valid to sync Package Distribution type Applied Rules)
    * @param    status	                    DESCRIPTION (Data Type String, Package Distribution Status value)
    * @return   String                      DESCRIPTION (return Processing Status Message)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getTemplatesProcessStatus(Boolean validStatus, String status) {
        String applyingRulesMessage = String.format(APPLYING_RULES_MESSAGE, new String[] {TEMPLATES});
        String processStatus = validStatus ? '' : String.format(INELIGIBLE_STATUS_APPLYING_RULES_MESSAGE, new String[] {status});
        processStatus += String.isBlank(processStatus) ? applyingRulesMessage : (' ' + applyingRulesMessage);
        return processStatus;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception to be thrown if User tries to Apply Rules but Rules Criteria Query is blank.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class NoRulesCriteriaQueryException extends Exception {}

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to throw exception when Integration Status is ineligible for applying rules.
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
            this.exceptionMsgParams = exceptionMsgParams;
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method overrides the getMessage() method of the Exception class to return the custom exception message.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getMessage() {
            return String.format(INELIGIBLE_INTEGRATION_STATUS_EXCEPTION_MSG, exceptionMsgParams);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to throw exception when Rules Sync Status is ineligible for applying rules.
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
            this.exceptionMsgParams = exceptionMsgParams;
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method overrides the getMessage() method of the Exception class to return the custom exception message.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getMessage() {
            return String.format(INELIGIBLE_RULES_SYNC_STATUS_EXCEPTION_MSG, exceptionMsgParams);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to throw exception when Package Distribution Status is ineligible for applying rules.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class IneligibleStatusException extends Exception {
        private List<String> exceptionMsgParams;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the IneligibleStatusException class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public IneligibleStatusException(List<String> exceptionMsgParams) {
            this.exceptionMsgParams = exceptionMsgParams;
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method overrides the getMessage() method of the Exception class to return the custom exception message.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getMessage() {
            return String.format(INELIGIBLE_STATUS_EXCEPTION_MSG, exceptionMsgParams);
        }
    }
}