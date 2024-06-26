/**
 * W-13484430 & W-13576017
 * Helper class to inititate the process to Recall Packages for the selected Package Distribution record(s).
 * 
 * Version      Date            Author                  Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         20/06/2023      Chakshu Malhotra        W-13484430 & W-13576017 - Adds logic to inititate the process to Package Recall for the selected Package Distribution record(s).
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_PackageRecallHelper {
    
    private static final String ELIGIBLE_INTEGRATION_STATUS = Label.MA_DS_Eligible_Integration_Status;
    private static final String CALLOUT_CONFIG_PACKAGE_MASS_RECALL = Label.MA_DS_Callout_Config_Package_Mass_Recall;

    private static final String INELIGIBLE_INT_STATUS_EXCEPTION = Label.MA_DS_Ineligible_Int_Status_For_Package_Recall;
    private static final String NO_PD_FOR_PACKAGE_RECALL_EXCEPTION = Label.MA_DS_No_PD_For_Package_Recall;

    private static final String PACKAGE_RECALL_MESSAGE = Label.MA_DS_Recalling_Packages_Message;

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initiate the processing of Package Recall for the selected Package Distribution record(s) and return Processing Status Message.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	            DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    acqCompanyId	        DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    pkgDistributionIds	    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @return   String                  DESCRIPTION (return processStatus message for the "Recall Packages" action)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static String recallPackages(Id srcRecordId, Id acqCompanyId, Set<Id> pkgDistributionIds) {
        List<MA_DS_Package_Distribution__c> pkgDistributions = MA_DS_PackageRecallUtility.getPackageDistributions(acqCompanyId, pkgDistributionIds);
        Map<Id, MA_DS_Package_Distribution__c> eligiblePkgDistributionMap = throwExceptionsIfNeeded(acqCompanyId, pkgDistributions);
        return initRecallPackages(srcRecordId, acqCompanyId, eligiblePkgDistributionMap.values());
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to throw exception if any of the Package Distribution record is ineligible to initiate the Package Recall process.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	                            DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    pkgDistributions	                        DESCRIPTION (Data Type List<MA_DS_Package_Distribution__c>, List of Package Distribution records)
    * @return   Map<Id, MA_DS_Package_Distribution__c>      DESCRIPTION (return Map of all Eligible Package Distribution records that can be processed for Package Recall process)
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
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to inititate the process of Mass Package Recall for the eligible / selected Package Distribution record(s) and returns the Processing Status Message.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                        DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    acqCompanyId	                    DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    pkgDistributions	                DESCRIPTION (Data Type List<MA_DS_Package_Distribution__c>, List of Package Distribution records)
    * @return   String                              DESCRIPTION (return Processing Status Message)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String initRecallPackages(Id srcRecordId, Id acqCompanyId, List<MA_DS_Package_Distribution__c> pkgDistributions) {
        Set<Id> packageRecallPDIds = new Set<Id>();
        Set<String> pkgDistributionNames = new Set<String>();

        for(MA_DS_Package_Distribution__c pkgDistribution : pkgDistributions) {
            packageRecallPDIds.add(pkgDistribution.Id);
            pkgDistributionNames.add(pkgDistribution.Name);
        }

        if(pkgDistributions.size() > 0) {
            MA_DS_PackageRecallUtility.updatePkgDistributionsIntegrationStatus(pkgDistributions);
            initRecallPackages(srcRecordId, acqCompanyId, new List<Id>(packageRecallPDIds));
        }

        return (pkgDistributions.size() > 0) ? String.format(PACKAGE_RECALL_MESSAGE, new String[] {JSON.serialize(pkgDistributionNames)}) : '';
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to inititate the process of Mass Package Recall for the eligible / selected Package Distribution record(s) and returns the Processing Status Message.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                        DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    acqCompanyId	                    DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    packageRecallPDIds  	            DESCRIPTION (Data Type List<Id>, List of Package Distribution Ids to be processed for Package Recall)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void initRecallPackages(Id srcRecordId, Id acqCompanyId, List<Id> packageRecallPDIds) {
        if(packageRecallPDIds.size() > 0) {
            MA_DS_CalloutFramework.calloutStrategy.setCalloutConfig(CALLOUT_CONFIG_PACKAGE_MASS_RECALL)
                                                  .setCalloutRequestParams(packageRecallPDIds[0])
                                                  .setCalloutRequest()
                                                  .setResponseCallback()
                                                  .initAsyncCallout(srcRecordId);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to throw exception when Integration Status is ineligible for initiating Package Recall process.
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
            this.exceptionMsgParams = new List<String> {MA_DS_PackageRecallHelper.IneligibleIntegrationStatusException.class.getName()};
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
    * Custom Exception class to throw exception when there are no eligible Package Distribution records to initiate the Package Recall process.
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
            this.exceptionMsgParams = new List<String> {MA_DS_PackageRecallHelper.NoEligiblePackageDistributionException.class.getName()};
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
            return String.format(NO_PD_FOR_PACKAGE_RECALL_EXCEPTION, exceptionMsgParams);
        }
    }
}