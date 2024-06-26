/**
 * W-12578130
 * Helper class to inititate the process to Deliver Manager Summaries for all eligible / selected Package Distribution records.
 * 
 * Version      Date            Author                  Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         20/04/2023      Chakshu Malhotra        W-12578130 - Adds logic to inititate the process to Deliver Manager Summaries for all eligible / selected Package Distribution records.
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_ManagerSummariesDeliveryHelper {
    
    private static final String ELIGIBLE_INTEGRATION_STATUS = Label.MA_DS_Eligible_Integration_Status;
    private static final String INELIGIBLE_INT_STATUS_EXCEPTION = Label.MA_DS_Ineligible_Int_Status_For_Summary_Delivery;

    private static final String NO_PD_FOR_SUMMARY_DELIVERY_EXCEPTION = Label.MA_DS_No_PD_For_Summary_Delivery;
    private static final String NO_SUMMARY_DELIVERY_RULES_EXCEPTION = Label.MA_DS_No_Summary_Delivery_Rules_Exception;
    private static final String NOT_READY_FOR_SUMMARY_DELIVERY_EXCEPTION = Label.MA_DS_Not_Ready_For_Summary_Delivery_Exception;

    private static final String MANAGER_SUMMARY_DELIVERY_MESSAGE = Label.MA_DS_Delivering_Manager_Summaries_Message;

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initiate the processing of Manager Summaries Delivery for all Package Distribution and return Processing Status Message.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	        DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @return   String                  DESCRIPTION (return processStatus message for the "Deliver Manager Summaries" action)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static String deliverManagerSummaries(Id acqCompanyId) {
        List<MA_DS_Package_Distribution__c> pkgDistributions = MA_DS_ManagerSummariesDeliveryUtility.getPackageDistributions(false, acqCompanyId, null);
        Map<Id, MA_DS_Package_Distribution__c> eligiblePkgDistributionMap = throwExceptionsIfNeeded(acqCompanyId, pkgDistributions);
        return initDeliverManagerSummaries(acqCompanyId, acqCompanyId, eligiblePkgDistributionMap.values(), MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin.DELIVER_ALL);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initiate the processing of Manager Summaries Delivery for selected Package Distributions on the UI and return Processing Status Message.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	            DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    acqCompanyId	        DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    pkgDistributionIds	    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @return   String                  DESCRIPTION (return processStatus message for the "Deliver Manager Summaries" action)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static String deliverManagerSummaries(Id srcRecordId, Id acqCompanyId, Set<Id> pkgDistributionIds) {
        List<MA_DS_Package_Distribution__c> pkgDistributions = MA_DS_ManagerSummariesDeliveryUtility.getPackageDistributions(false, acqCompanyId, pkgDistributionIds);
        Map<Id, MA_DS_Package_Distribution__c> eligiblePkgDistributionMap = throwExceptionsIfNeeded(acqCompanyId, pkgDistributions);
        return initDeliverManagerSummaries(srcRecordId, acqCompanyId, eligiblePkgDistributionMap.values(), MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin.DELIVER_SELECTED);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to kick-off scheduled processing of Manager Summary Delivery for the Package Distribution records.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionIds	    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @return   String                  DESCRIPTION (return processStatus message for the "Deliver Manager Summaries" action)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static String deliverManagerSummaries(Set<Id> pkgDistributionIds) {
        List<MA_DS_Package_Distribution__c> pkgDistributions = MA_DS_ManagerSummariesDeliveryUtility.getPackageDistributions(true, null, pkgDistributionIds);
        Map<Id, MA_DS_Package_Distribution__c> eligiblePkgDistributionMap = throwExceptionsIfNeeded(null, pkgDistributions);
        return initDeliverManagerSummaries(null, null, eligiblePkgDistributionMap.values(), MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin.SCHEDULED_DELIVERY);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to throw exception if any of the Package Distribution record is ineligible to initiate the Manager Summary Delivery process.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	                            DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    pkgDistributions	                        DESCRIPTION (Data Type List<MA_DS_Package_Distribution__c>, List of Package Distribution records)
    * @return   Map<Id, MA_DS_Package_Distribution__c>      DESCRIPTION (return Map of all Eligible Package Distribution records that can be processed for Manager Summary Delivery process)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<Id, MA_DS_Package_Distribution__c> throwExceptionsIfNeeded(Id acqCompanyId, List<MA_DS_Package_Distribution__c> pkgDistributions) {
        Map<Id, MA_DS_Package_Distribution__c> eligiblePkgDistributionMap = new Map<Id, MA_DS_Package_Distribution__c>();

        for(MA_DS_Package_Distribution__c pkgDistribution : pkgDistributions) {
            throwExceptionIfIneligibleIntegrationStatus(pkgDistribution.MA_DS_Integration_Status__c);
            eligiblePkgDistributionMap.put(pkgDistribution.Id, pkgDistribution);
        }

        if(eligiblePkgDistributionMap.size() == 0) {
            throw new NoEligiblePackageDistributionException(new String[] {String.valueOf(acqCompanyId)});
        }

        if(eligiblePkgDistributionMap.size() > 0) {
            throwExceptionIfNotReadyForSummaryDelivery(eligiblePkgDistributionMap);
            throwExceptionIfNoSummaryDeliveryRules(eligiblePkgDistributionMap);
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
    * Method to throw exception if one or more Acquisition Contacts are not yet ready for Manager Summary Delivery.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionMap	        DESCRIPTION (Data Type Map<Id, MA_DS_Package_Distribution__c>, Map of eligible Package Distribution records.
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void throwExceptionIfNotReadyForSummaryDelivery(Map<Id, MA_DS_Package_Distribution__c> pkgDistributionMap) {
        Set<String> pkgDistributionNames = MA_DS_ManagerSummariesDeliveryUtility.getDistributionsNotReadyForSummaryDelivery(pkgDistributionMap);
        if(pkgDistributionNames.size() > 0) {
            throw new NotReadyForSummaryDeliveryException(new String[] {JSON.serialize(pkgDistributionNames)});
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to throw exception if No Manager Summary Applied Rules found with "Need To Deliver" for one or more Package Distribution records.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionMap	        DESCRIPTION (Data Type Map<Id, MA_DS_Package_Distribution__c>, Map of eligible Package Distribution records.
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void throwExceptionIfNoSummaryDeliveryRules(Map<Id, MA_DS_Package_Distribution__c> pkgDistributionMap) {
        Set<String> pkgDistributionNames = MA_DS_ManagerSummariesDeliveryUtility.getDistributionsWithNoNeedForSummaryDelivery(pkgDistributionMap);
        if(pkgDistributionNames.size() > 0) {
            throw new NoSummaryDeliveryRulesException(new String[] {JSON.serialize(pkgDistributionNames)});
        }
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to inititate the process of Manager Summaries Delivery for the eligible / selected / scheduled Package Distribution records and returns the Processing Status Message.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                        DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    acqCompanyId	                    DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    pkgDistributions	                DESCRIPTION (Data Type List<MA_DS_Package_Distribution__c>, List of Package Distribution records)
    * @param    executionOriginType	                DESCRIPTION (Data Type MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin, MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin enum type)
    * @return   String                              DESCRIPTION (return Processing Status Message)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String initDeliverManagerSummaries(Id srcRecordId, Id acqCompanyId, List<MA_DS_Package_Distribution__c> pkgDistributions, MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin executionOriginType) {
        Set<Id> summaryDeliveryPDIds = new Set<Id>();
        Set<String> pkgDistributionNames = new Set<String>();

        for(MA_DS_Package_Distribution__c pkgDistribution : pkgDistributions) {
            summaryDeliveryPDIds.add(pkgDistribution.Id);
            pkgDistributionNames.add(pkgDistribution.Name);
        }

        if(pkgDistributions.size() > 0) {
            MA_DS_ManagerSummariesDeliveryUtility.updatePkgDistributionsIntegrationStatus(pkgDistributions);
            initDeliverManagerSummaries(srcRecordId, acqCompanyId, summaryDeliveryPDIds, executionOriginType);
        }

        return (pkgDistributions.size() > 0) ? String.format(MANAGER_SUMMARY_DELIVERY_MESSAGE, new String[] {JSON.serialize(pkgDistributionNames)}) : '';
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to inititate the process of Manager Summaries Delivery for the eligible / selected / scheduled Package Distribution records and returns the Processing Status Message.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                        DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    acqCompanyId	                    DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    summaryDeliveryPDIds	            DESCRIPTION (Data Type List<Id>, Set of Package Distribution Ids to be processed for Manager Summary Delivery)
    * @param    executionOriginType	                DESCRIPTION (Data Type MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin, MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin enum type)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void initDeliverManagerSummaries(Id srcRecordId, Id acqCompanyId, Set<Id> summaryDeliveryPDIds, MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin executionOriginType) {
        MA_DS_ManagerSummaryDeliveryService.strategyInstance.setSrcRecordId(srcRecordId)
                                                            .setAcqCompanyId(acqCompanyId)
                                                            .setSummaryDeliveryPDIds(summaryDeliveryPDIds)
                                                            .setExecutionJobType(MA_DS_ManagerSummaryDeliveryService.ExecutionJob.DELIVER_PACKAGE_DISTRIBUTION)
                                                            .setExecutionJobOriginType(executionOriginType)
                                                            .initDeliveryService()
                                                            .initSummaryDeliveryJob()
                                                            .execute();
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to throw exception when Integration Status is ineligible for initiating Manager Summary Delivery process.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class IneligibleIntegrationStatusException extends Exception {
        private List<String> exceptionMsgParams;

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the IneligibleIntegrationStatusException class.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public IneligibleIntegrationStatusException(List<String> exceptionMsgParams) {
            this.exceptionMsgParams = new List<String> {MA_DS_ManagerSummariesDeliveryHelper.IneligibleIntegrationStatusException.class.getName()};
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
    * Custom Exception class to throw exception when there are no eligible Package Distribution records to initiate the Manager Summary Delivery process.
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
            this.exceptionMsgParams = new List<String> {MA_DS_ManagerSummariesDeliveryHelper.NoEligiblePackageDistributionException.class.getName()};
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
            return String.format(NO_PD_FOR_SUMMARY_DELIVERY_EXCEPTION, exceptionMsgParams);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to throw exception when one or more Package Distribution Acquisition Contacts are not yet ready for Manager Summary Delivery.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class NotReadyForSummaryDeliveryException extends Exception {
        private List<String> exceptionMsgParams;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the NotReadyForSummaryDeliveryException class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public NotReadyForSummaryDeliveryException(List<String> exceptionMsgParams) {
            this.exceptionMsgParams = new List<String> {MA_DS_ManagerSummariesDeliveryHelper.NotReadyForSummaryDeliveryException.class.getName()};
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
            return String.format(NOT_READY_FOR_SUMMARY_DELIVERY_EXCEPTION, exceptionMsgParams);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to throw exception when one or more Package Distributions doesn't have any Applied Rules with "Need To Deliver".
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class NoSummaryDeliveryRulesException extends Exception {
        private List<String> exceptionMsgParams;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the NoSummaryDeliveryRulesException class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public NoSummaryDeliveryRulesException(List<String> exceptionMsgParams) {
            this.exceptionMsgParams = new List<String> {MA_DS_ManagerSummariesDeliveryHelper.NoSummaryDeliveryRulesException.class.getName()};
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
            return String.format(NO_SUMMARY_DELIVERY_RULES_EXCEPTION, exceptionMsgParams);
        }
    }
}