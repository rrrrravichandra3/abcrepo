/**
 * W-12578130
 * Controller class of madsDeliverManagerSummaries (LWC Headless Quick Action) to deliver Manager Summaries.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         20/04/2023      Chakshu Malhotra        W-12578130 - Adds controller logic for LWC to Deliver Manager Summaries.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class MA_DS_DeliverManagerSummaries {
    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to look for the eligible Package Distribution records and initiate the Manager Summary Delivery for them.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    recordId 	   	                DESCRIPTION (Data type Id, Acquisition Company record Id)
    * @return   ResponseWrapper                 DESCRIPTION (return ResponseWrapper instance)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static ResponseWrapper deliverManagerSummaries(Id recordId) {
        ResponseWrapper responseWrapper = new ResponseWrapper();

        try {
            Boolean acqCompanyType = sObjectTypeAcquisitionCompany(recordId);
            responseWrapper.statusMessage = acqCompanyType ? MA_DS_ManagerSummariesDeliveryHelper.deliverManagerSummaries(recordId) : 
                                            MA_DS_ManagerSummariesDeliveryHelper.deliverManagerSummaries(recordId, getAcquisitionCompanyId(recordId), new Set<Id> {recordId});
        }catch(MA_DS_ManagerSummariesDeliveryHelper.IneligibleIntegrationStatusException exType) {
            responseWrapper.errorMessage = exType.getMessage();
        }catch(MA_DS_ManagerSummariesDeliveryHelper.NoEligiblePackageDistributionException exType) {
            responseWrapper.errorMessage = exType.getMessage();
        }catch(MA_DS_ManagerSummariesDeliveryHelper.NotReadyForSummaryDeliveryException exType) {
            responseWrapper.errorMessage = exType.getMessage();
        }catch(MA_DS_ManagerSummariesDeliveryHelper.NoSummaryDeliveryRulesException exType) {
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
    * Method to check if recordId from where the Manager Summary Delivery is initiated, is contained within Acquisition Company record detail page.
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
    * Method to get the Acquisition Company record Id, when Manager Summary Delivery is initiated from the Package Distribution record detail page.
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
    * Wrapper class to hold Response for the @AuraEnabled methods of MA_DS_DeliverManagerSummaries class.
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