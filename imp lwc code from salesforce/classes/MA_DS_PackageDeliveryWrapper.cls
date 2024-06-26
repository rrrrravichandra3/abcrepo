/**
 * W-13465459
 * Abstract Wrapper class to hold JobParams, used while processing Package Distributions for PAckage Delivery.
 * Holds JobParams type used to get Acquisition Contacts & Package Documents (Template Ids) details to prepare and send payload for Package Delivery API callout.
 * 
 * Version      Date            Author                  Description
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         25/05/2023      Chakshu Malhotra        W-13465459 - Adds logic to hold JobParams, used while processing Package Distributions for Package Delivery.
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_PackageDeliveryWrapper {
    
    private static final Integer DEFAULT_ZERO = 0;
    private static final Integer PACKAGE_DELIVERY_CALLOUT_COUNT = 4;
    private static final Integer ACQ_CONTACTS_DELIVERY_QUERY_SIZE_LIMIT = 16;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold serialized state of properties used while identifying eligible Acquisition Contacts to prepare them for Package Delivery API callout.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class AcqContactsPackageDeliveryParams implements MA_DS_PackageDeliveryService.JobParams {
        public Integer successCount = DEFAULT_ZERO;
        public Integer totalContacts = DEFAULT_ZERO;
        public Integer maxAPICalloutCount = PACKAGE_DELIVERY_CALLOUT_COUNT;
        public Integer querySizeLimit = ACQ_CONTACTS_DELIVERY_QUERY_SIZE_LIMIT;

        public Boolean firstBatch = false;
        public Boolean finalBatch = false;
        public Boolean singleContactDelivery = false;

        public Id commonId {get; set;}
        public Id srcRecordId {get; set;}
        public Id acqContactId {get; set;}
        public Id targetUserId {get; set;}
        public Id lastRecordId {get; set;}

        public Acquisition_Company__c acqCompany {get; set;}
        public MA_DS_PackageDeliveryService.ExecutionOrigin executionOriginType {get; set;}

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Package Distribution Ids, used by PackageDeliveryJob to identify the Acquisition Contacts to process them for Package Delivery.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Set<Id> packageDeliveryPDIds {
            get {
                if(packageDeliveryPDIds == null) {
                    packageDeliveryPDIds = new Set<Id>();
                }
                return packageDeliveryPDIds;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Map of Concatenated Id (Package Id + Template Id) to "Sort Order" value, used by PackageDeliveryJob to prepare & send payload for Package Delivery API callout to DocuSign CLM.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Map<String, Integer> sortOrderMap {
            get {
                if(sortOrderMap == null) {
                    sortOrderMap = new Map<String, Integer>();
                }
                return sortOrderMap;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Map of Package Distribution Id to "Custom Package Envelope Email" flag value, used by PackageDeliveryJob to prepare & send payload for Package Delivery API callout to DocuSign CLM.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Map<Id, Boolean> customDeliveryEmailMap {
            get {
                if(customDeliveryEmailMap == null) {
                    customDeliveryEmailMap = new Map<Id, Boolean>();
                }
                return customDeliveryEmailMap;
            }set;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Map of Background Check Region to the the Background Check type Template record details.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Map<String, MA_DS_Template__c> bgcEmailTemplateMap {
            get {
                if(bgcEmailTemplateMap == null) {
                    bgcEmailTemplateMap = new Map<String, MA_DS_Template__c>();
                }
                return bgcEmailTemplateMap;
            }set;
        }
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the Params for Package Delivery API callout to send Package Documents (Template Ids) details for each Acquisition Contact to the DocuSign CLM.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class PackageDeliveryParams implements MA_DS_CalloutFramework.RequestParams {
        public Id commonId {get; set;}

        public Boolean firstBatch {get; set;}
        public Boolean finalBatch {get; set;}
        public Boolean singleContactDelivery {get; set;}

        public Boolean successResponse {get; private set;}

        public Acquisition_Company__c acqCompany {get; set;}
        public List<Acquisition_Contacts__c> acqContacts {get; set;}

        public Map<String, Integer> sortOrderMap {get; set;}
        public Map<Id, Boolean> customDeliveryEmailMap {get; set;}
        public List<MA_DS_Template__c> bgcEmailTemplates {get; set;}

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the successResponse property of the PackageDeliveryParams. 
        * Method is called from the ResponseCallback implementation used to send Http API Request for the Package Prep.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    successResponse	                DESCRIPTION (Data Type Boolean, True if API response returned no errors)
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void setSuccessResponse(Boolean successResponse) {
            this.successResponse = successResponse;
        }
    }
}