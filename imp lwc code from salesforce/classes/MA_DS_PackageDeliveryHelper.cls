/**
 * W-13465459
 * Helper class to inititate the process to Deliver Packages for all eligible / selected Package Distribution records.
 * 
 * Version      Date            Author                  Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         24/05/2023      Chakshu Malhotra        W-13465459 - Adds logic to inititate the process to Package Deliveries for all eligible / selected Package Distribution records.
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_PackageDeliveryHelper {

    private static final String ELIGIBLE_INTEGRATION_STATUS = Label.MA_DS_Eligible_Integration_Status;
    private static final String NO_PACKAGE_DELIVERY_RULES_EXCEPTION = Label.MA_DS_No_Package_Delivery_Rules_Exception;
    private static final String INELIGIBLE_INT_STATUS_EXCEPTION = Label.MA_DS_Ineligible_Int_Status_For_Package_Delivery;

    private static final String NO_PD_FOR_PACKAGE_DELIVERY_EXCEPTION = Label.MA_DS_No_PD_For_Package_Delivery;
    private static final String NOT_READY_FOR_PACKAGE_DELIVERY_EXCEPTION = Label.MA_DS_Not_Ready_For_Package_Delivery_Exception;

    private static final String PACKAGE_DELIVERY_MESSAGE = Label.MA_DS_Delivering_Packages_Message;

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initiate the processing of Package Delivery for all Package Distribution and return Processing Status Message.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	        DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @return   String                  DESCRIPTION (return processStatus message for the "Deliver Packages" action)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static String deliverPackages(Id acqCompanyId) {
        List<MA_DS_Package_Distribution__c> pkgDistributions = MA_DS_PackageDeliveryUtility.getPackageDistributions(false, acqCompanyId, null);
        Map<Id, MA_DS_Package_Distribution__c> eligiblePkgDistributionMap = throwExceptionsIfNeeded(acqCompanyId, pkgDistributions);
        return initDeliverPackages(acqCompanyId, acqCompanyId, null, eligiblePkgDistributionMap.values(), MA_DS_PackageDeliveryService.ExecutionOrigin.DELIVER_ALL);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initiate the processing of Package Delivery for selected Package Distributions on the UI and return Processing Status Message.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	            DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    acqCompanyId	        DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    pkgDistributionIds	    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @return   String                  DESCRIPTION (return processStatus message for the "Deliver Packages" action)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static String deliverPackages(Id srcRecordId, Id acqCompanyId, Set<Id> pkgDistributionIds) {
        List<MA_DS_Package_Distribution__c> pkgDistributions = MA_DS_PackageDeliveryUtility.getPackageDistributions(false, acqCompanyId, pkgDistributionIds);
        Map<Id, MA_DS_Package_Distribution__c> eligiblePkgDistributionMap = throwExceptionsIfNeeded(acqCompanyId, pkgDistributions);
        return initDeliverPackages(srcRecordId, acqCompanyId, null, eligiblePkgDistributionMap.values(), MA_DS_PackageDeliveryService.ExecutionOrigin.DELIVER_SELECTED);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to kick-off scheduled processing of Package Delivery for the Package Distribution records.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionIds	    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @return   String                  DESCRIPTION (return processStatus message for the "Deliver Packages" action)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static String deliverPackages(Set<Id> pkgDistributionIds) {
        List<MA_DS_Package_Distribution__c> pkgDistributions = MA_DS_PackageDeliveryUtility.getPackageDistributions(true, null, pkgDistributionIds);
        Map<Id, MA_DS_Package_Distribution__c> eligiblePkgDistributionMap = throwExceptionsIfNeeded(null, pkgDistributions);
        return initDeliverPackages(null, null, null, eligiblePkgDistributionMap.values(), MA_DS_PackageDeliveryService.ExecutionOrigin.SCHEDULED_DELIVERY);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initiate the processing of Single Acquisition Contact Package Delivery for and return Processing Status Message.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqContactId	        DESCRIPTION (Data Type Id, Acquisition Contact record Id)
    * @param    pkgDistributionIds	    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @return   String                  DESCRIPTION (return processStatus message for the "Deliver Package" action)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static String deliverPackages(Id acqContactId, Set<Id> pkgDistributionIds) {
        List<MA_DS_Package_Distribution__c> pkgDistributions = MA_DS_PackageDeliveryUtility.getPackageDistributions(false, null, pkgDistributionIds);
        Map<Id, MA_DS_Package_Distribution__c> eligiblePkgDistributionMap = throwExceptionsIfNeeded(null, pkgDistributions);
        return initDeliverPackages(acqContactId, null, acqContactId, eligiblePkgDistributionMap.values(), MA_DS_PackageDeliveryService.ExecutionOrigin.SINGLE_CONTACT_DELIVERY);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to throw exception if any of the Package Distribution record is ineligible to initiate the Package Delivery process.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	                            DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    pkgDistributions	                        DESCRIPTION (Data Type List<MA_DS_Package_Distribution__c>, List of Package Distribution records)
    * @return   Map<Id, MA_DS_Package_Distribution__c>      DESCRIPTION (return Map of all Eligible Package Distribution records that can be processed for Package Delivery process)
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
            throwExceptionIfNotReadyForPackageDelivery(eligiblePkgDistributionMap);
            throwExceptionIfNoPackageDeliveryRules(eligiblePkgDistributionMap);
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
    * Method to throw exception if one or more Acquisition Contacts are not yet ready for Package Delivery.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionMap	        DESCRIPTION (Data Type Map<Id, MA_DS_Package_Distribution__c>, Map of eligible Package Distribution records.
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void throwExceptionIfNotReadyForPackageDelivery(Map<Id, MA_DS_Package_Distribution__c> pkgDistributionMap) {
        Set<String> pkgDistributionNames = MA_DS_PackageDeliveryUtility.getDistributionsNotReadyForPackageDelivery(pkgDistributionMap);
        if(pkgDistributionNames.size() > 0) {
            throw new NotReadyForPackageDeliveryException(new String[] {JSON.serialize(pkgDistributionNames)});
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to throw exception if No Package Applied Rules found with "Need To Deliver" for one or more Package Distribution records.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionMap	        DESCRIPTION (Data Type Map<Id, MA_DS_Package_Distribution__c>, Map of eligible Package Distribution records.
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void throwExceptionIfNoPackageDeliveryRules(Map<Id, MA_DS_Package_Distribution__c> pkgDistributionMap) {
        Set<String> pkgDistributionNames = MA_DS_PackageDeliveryUtility.getDistributionsWithNoNeedForPackageDelivery(pkgDistributionMap);
        if(pkgDistributionNames.size() > 0) {
            throw new NoPackageDeliveryRulesException(new String[] {JSON.serialize(pkgDistributionNames)});
        }
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to inititate the process of Package Delivery for the eligible / selected / scheduled Package Distribution records and returns the Processing Status Message.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                        DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    acqCompanyId	                    DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    acqContactId	                    DESCRIPTION (Data Type Id, Acquisition Contact record Id)
    * @param    pkgDistributions	                DESCRIPTION (Data Type List<MA_DS_Package_Distribution__c>, List of Package Distribution records)
    * @param    executionOriginType	                DESCRIPTION (Data Type MA_DS_PackageDeliveryService.ExecutionOrigin, MA_DS_PackageDeliveryService.ExecutionOrigin enum type)
    * @return   String                              DESCRIPTION (return Processing Status Message)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String initDeliverPackages(Id srcRecordId, Id acqCompanyId, Id acqContactId, List<MA_DS_Package_Distribution__c> pkgDistributions, MA_DS_PackageDeliveryService.ExecutionOrigin executionOriginType) {
        Set<Id> packageDeliveryPDIds = new Set<Id>();
        Set<String> pkgDistributionNames = new Set<String>();

        for(MA_DS_Package_Distribution__c pkgDistribution : pkgDistributions) {
            packageDeliveryPDIds.add(pkgDistribution.Id);
            pkgDistributionNames.add(pkgDistribution.Name);
        }

        if(pkgDistributions.size() > 0) {
            MA_DS_PackageDeliveryUtility.updatePkgDistributionsIntegrationStatus(pkgDistributions);
            initDeliverPackages(srcRecordId, acqCompanyId, acqContactId, packageDeliveryPDIds, executionOriginType);
        }

        return (pkgDistributions.size() > 0) ? String.format(PACKAGE_DELIVERY_MESSAGE, new String[] {JSON.serialize(pkgDistributionNames)}) : '';
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to inititate the process of Package Delivery for the eligible / selected / scheduled Package Distribution records and returns the Processing Status Message.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                        DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    acqCompanyId	                    DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    acqContactId	                    DESCRIPTION (Data Type Id, Acquisition Contact record Id)
    * @param    packageDeliveryPDIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to be processed for Package Delivery)
    * @param    executionOriginType	                DESCRIPTION (Data Type MA_DS_PackageDeliveryService.ExecutionOrigin, MA_DS_PackageDeliveryService.ExecutionOrigin enum type)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void initDeliverPackages(Id srcRecordId, Id acqCompanyId, Id acqContactId, Set<Id> packageDeliveryPDIds, MA_DS_PackageDeliveryService.ExecutionOrigin executionOriginType) {
        MA_DS_PackageDeliveryService.strategyInstance.setSrcRecordId(srcRecordId)
                                                     .setAcqCompanyId(acqCompanyId)
                                                     .setAcqContactId(acqContactId)
                                                     .setPackageDeliveryPDIds(packageDeliveryPDIds)
                                                     .setExecutionJobType(MA_DS_PackageDeliveryService.ExecutionJob.DELIVER_ACQ_CONTACTS)
                                                     .setExecutionJobOriginType(executionOriginType)
                                                     .initDeliveryService()
                                                     .initPackageDeliveryJob()
                                                     .execute();
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to throw exception when Integration Status is ineligible for initiating Package Delivery process.
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
            this.exceptionMsgParams = new List<String> {MA_DS_PackageDeliveryHelper.IneligibleIntegrationStatusException.class.getName()};
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
    * Custom Exception class to throw exception when there are no eligible Package Distribution records to initiate the Package Delivery process.
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
            this.exceptionMsgParams = new List<String> {MA_DS_PackageDeliveryHelper.NoEligiblePackageDistributionException.class.getName()};
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
            return String.format(NO_PD_FOR_PACKAGE_DELIVERY_EXCEPTION, exceptionMsgParams);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to throw exception when one or more Package Distribution Acquisition Contacts are not yet ready for Package Delivery.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class NotReadyForPackageDeliveryException extends Exception {
        private List<String> exceptionMsgParams;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the NotReadyForPackageDeliveryException class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public NotReadyForPackageDeliveryException(List<String> exceptionMsgParams) {
            this.exceptionMsgParams = new List<String> {MA_DS_PackageDeliveryHelper.NotReadyForPackageDeliveryException.class.getName()};
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
            return String.format(NOT_READY_FOR_PACKAGE_DELIVERY_EXCEPTION, exceptionMsgParams);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to throw exception when one or more Package Distributions doesn't have any Applied Rules with "Need To Deliver".
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class NoPackageDeliveryRulesException extends Exception {
        private List<String> exceptionMsgParams;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the NoPackageDeliveryRulesException class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public NoPackageDeliveryRulesException(List<String> exceptionMsgParams) {
            this.exceptionMsgParams = new List<String> {MA_DS_PackageDeliveryHelper.NoPackageDeliveryRulesException.class.getName()};
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
            return String.format(NO_PACKAGE_DELIVERY_RULES_EXCEPTION, exceptionMsgParams);
        }
    }
}