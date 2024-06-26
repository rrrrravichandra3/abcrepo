/**
 * W-13484430 & W-13576017
 * Controller class of madsRecallPackages (LWC Headless Quick Action) to mass recall Package Documents.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         20/06/2023      Chakshu Malhotra        W-13484430 & W-13576017 - Adds controller logic for LWC to Mass Recall Package Documents.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class MA_DS_RecallPackages {
    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initiate Mass Package Recall process for all eligible / selected Package Distribution(s).
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    recordId	 	                DESCRIPTION (Data Type Id, Record Id from the Record Detail Page of the sObject where the component is added)
    * @return   ResponseWrapper                 DESCRIPTION (return ResponseWrapper instance)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static ResponseWrapper recallPackages(Id recordId) {
        ResponseWrapper responseWrapper = new ResponseWrapper();

        try {
            responseWrapper.statusMessage = MA_DS_PackageRecallHelper.recallPackages(recordId, getAcquisitionCompanyId(recordId), new Set<Id> {recordId});
        }catch(MA_DS_PackageRecallHelper.IneligibleIntegrationStatusException exType) {
            responseWrapper.errorMessage = exType.getMessage();
        }catch(MA_DS_PackageRecallHelper.NoEligiblePackageDistributionException exType) {
            responseWrapper.errorMessage = exType.getMessage();
        }catch(Exception exType) {
            throw new AuraHandledException(exType.getMessage());
        }

        if(String.isNotBlank(responseWrapper.errorMessage)) {
            responseWrapper.isError = true;
        }

        return responseWrapper;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Acquisition Company record Id, when Mass Package Recall is initiated from the Package Distribution record detail page.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	 	        DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @return   Id                              DESCRIPTION (return Acquisition Company record Id for the Package Distribution record)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Id getAcquisitionCompanyId(Id pkgDistributionId) {
        return [SELECT Id, MA_DS_Package__r.MA_DS_Acquisition_Company__c 
                FROM MA_DS_Package_Distribution__c 
                WHERE Id = :pkgDistributionId LIMIT 1]?.MA_DS_Package__r.MA_DS_Acquisition_Company__c;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold Response for the @AuraEnabled methods of MA_DS_RecallPackages class.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class ResponseWrapper {
        @AuraEnabled public Boolean isError {get; set;}
        @AuraEnabled public String errorMessage {get; set;}
        @AuraEnabled public String statusMessage {get; set;}

        public ResponseWrapper() {
            this.isError = false;
            this.errorMessage = null;
            this.statusMessage = null;
        }
    }
}