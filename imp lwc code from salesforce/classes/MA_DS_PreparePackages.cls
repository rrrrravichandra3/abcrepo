/**
 * W-13011399
 * Controller class of madsPreparePackages (LWC Headless Quick Action) to prepare Package Documents.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         28/04/2023      Chakshu Malhotra        W-13011399 - Adds controller logic for LWC to Prepare Package Documents.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class MA_DS_PreparePackages {
    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initiate Package Prep process for all eligible / selected Package Distributions.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    recordId	 	                DESCRIPTION (Data Type Id, Record Id from the Record Detail Page of the sObject where the component is added)
    * @return   ResponseWrapper                 DESCRIPTION (return ResponseWrapper instance)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static ResponseWrapper preparePackages(Id recordId) {
        ResponseWrapper responseWrapper = new ResponseWrapper();

        try {
            Boolean acqCompanyType = sObjectTypeAcquisitionCompany(recordId);
            responseWrapper.statusMessage = acqCompanyType ? MA_DS_PackagePrepHelper.preparePackages(recordId) : 
                                            MA_DS_PackagePrepHelper.preparePackages(recordId, getAcquisitionCompanyId(recordId), new Set<Id> {recordId});
        }catch(MA_DS_PackagePrepHelper.IneligibleIntegrationStatusException exType) {
            responseWrapper.errorMessage = exType.getMessage();
        }catch(MA_DS_PackagePrepHelper.IneligibleRulesSyncStatusException exType) {
            responseWrapper.errorMessage = exType.getMessage();
        }catch(MA_DS_PackagePrepHelper.NoEligiblePackageDistributionException exType) {
            responseWrapper.errorMessage = exType.getMessage();
        }catch(MA_DS_PackagePrepHelper.NotReadyForPackagePrepException exType) {
            responseWrapper.errorMessage = exType.getMessage();
        }catch(MA_DS_PackagePrepHelper.NoPackageRuleException exType) {
            responseWrapper.errorMessage = exType.getMessage();
        }catch(MA_DS_PackagePrepHelper.NoPackagePrepRulesException exType) {
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
    * Method to check if recordId from where the Package Prep is initiated, is contained within Acquisition Company record detail page.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    recordId	 	                DESCRIPTION (Data Type Id, Record Id from the Record Detail Page of the sObject where the component is added)
    * @return   Boolean                         DESCRIPTION (return True if recordId is of Acquisition_Company__c sObjectType)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean sObjectTypeAcquisitionCompany(Id recordId) {
        return Schema.Acquisition_Company__c.getSObjectType() == recordId.getSobjectType();
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Acquisition Company record Id, when Package Prep is initiated from the Package Distribution record detail page.
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
    * Wrapper class to hold Response for the @AuraEnabled methods of MA_DS_PreparePackages class.
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