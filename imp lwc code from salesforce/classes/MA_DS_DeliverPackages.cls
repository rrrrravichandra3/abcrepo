/**
 * W-13465459
 * Controller class of madsDeliverPackages (LWC Headless Quick Action) to deliver Package Documents.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         26/05/2023      Chakshu Malhotra        W-13465459 - Adds controller logic for LWC to Deliver Package Documents.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class MA_DS_DeliverPackages {
    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initiate Package Delivery process for all eligible / selected Package Distributions.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    recordId	 	                DESCRIPTION (Data Type Id, Record Id from the Record Detail Page of the sObject where the component is added)
    * @return   ResponseWrapper                 DESCRIPTION (return ResponseWrapper instance)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static ResponseWrapper deliverPackages(Id recordId) {
        ResponseWrapper responseWrapper = new ResponseWrapper();

        try {
            responseWrapper.statusMessage = sObjectTypeAcquisitionCompany(recordId) ? MA_DS_PackageDeliveryHelper.deliverPackages(recordId) : 
            sObjectTypeAcquisitionContact(recordId) ? MA_DS_PackageDeliveryHelper.deliverPackages(recordId, MA_DS_SinglePackageDeliveryHelper.getDistributionsForSingleContactPackageDelivery(recordId)) : 
            MA_DS_PackageDeliveryHelper.deliverPackages(recordId, getAcquisitionCompanyId(recordId), new Set<Id> {recordId});
        }catch(MA_DS_PackageDeliveryHelper.IneligibleIntegrationStatusException exType) {
            responseWrapper.errorMessage = exType.getMessage();
        }catch(MA_DS_PackageDeliveryHelper.NoEligiblePackageDistributionException exType) {
            responseWrapper.errorMessage = exType.getMessage();
        }catch(MA_DS_PackageDeliveryHelper.NotReadyForPackageDeliveryException exType) {
            responseWrapper.errorMessage = exType.getMessage();
        }catch(MA_DS_PackageDeliveryHelper.NoPackageDeliveryRulesException exType) {
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
    * Method to check if recordId from where the Package Delivery is initiated, is contained within Acquisition Company record detail page.
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
    * Method to check if recordId from where the Package Delivery is initiated, is contained within Acquisition Contact record detail page.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    recordId	 	                DESCRIPTION (Data Type Id, Record Id from the Record Detail Page of the sObject where the component is added)
    * @return   Boolean                         DESCRIPTION (return True if recordId is of Acquisition_Contacts__c sObjectType)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean sObjectTypeAcquisitionContact(Id recordId) {
        return Schema.Acquisition_Contacts__c.getSObjectType() == recordId.getSobjectType();
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Acquisition Company record Id, when Package Delivery is initiated from the Package Distribution record detail page.
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
    * Wrapper class to hold Response for the @AuraEnabled methods of MA_DS_DeliverPackages class.
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