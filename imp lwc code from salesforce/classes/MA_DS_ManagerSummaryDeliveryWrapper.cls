/**
 * W-12578130
 * Abstract Wrapper class to hold JobParams, used while processing Package Distributions for Manager Summary Delivery.
 * Holds JobParams type used while identifying eligible Offer Communicator Ids, that need to be processed for Manager Summary Delivery.
 * Holds JobParams type used to get Offer Communicator details to prepare and send payload for Manager Summary Delivery API callout.
 * 
 * Version      Date            Author                  Description
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         21/04/2023      Chakshu Malhotra        W-12578130 - Adds logic to hold JobParams, used while processing Package Distributions for Manager Summary Delivery.
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_ManagerSummaryDeliveryWrapper {

    private static final Integer DEFAULT_ZERO = 0;
    private static final Integer PKG_DISTRIBUTION_DELIVERY_MAX_QUERY_COUNT = 20;
    private static final Integer PKG_DISTRIBUTION_DELIVERY_QUERY_SIZE_LIMIT = 200;
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold serialized state of properties used while preparing Offer Communicator Map for Manager Summary Delivery API callout.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class PackageDistributionDeliveryParams implements MA_DS_ManagerSummaryDeliveryService.JobParams {
        public Integer currentIndex = DEFAULT_ZERO;
        public Integer totalPkgDistributions = DEFAULT_ZERO;
        public Integer maxQueryCount = PKG_DISTRIBUTION_DELIVERY_MAX_QUERY_COUNT;
        public Integer querySizeLimit = PKG_DISTRIBUTION_DELIVERY_QUERY_SIZE_LIMIT;

        public Id lastRecordId {get; set;}
        
        public Id srcRecordId {get; set;}
        public Id targetUserId {get; set;}
        public Id acqCompanyId {get; set;}

        public MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin executionOriginType {get; set;}

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the List of Package Distribution Ids, used by SummaryDeliveryJob to identify the Offer Communicator Ids to process them for Manager Summary Delivery.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public List<Id> summaryDeliveryPDIds {
            get {
                if(summaryDeliveryPDIds == null) {
                    summaryDeliveryPDIds = new List<Id>();
                }
                return summaryDeliveryPDIds;
            }set;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Offer Communicator Ids, used by SummaryDeliveryJob to prepare & send payload for Manager Summary Delivery API callout to DocuSign CLM.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Set<Id> offerCommunicatorIds {
            get {
                if(offerCommunicatorIds == null) {
                    offerCommunicatorIds = new Set<Id>();
                }
                return offerCommunicatorIds;
            }set;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Map of Package Distribution Id to List of Offer Communicator Ids, used by SummaryDeliveryJob to prepare & send payload for Manager Summary Delivery API callout to DocuSign CLM.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Map<Id, List<Id>> offerCommunicatorMap {
            get {
                if(offerCommunicatorMap == null) {
                    offerCommunicatorMap = new Map<Id, List<Id>>();
                }
                return offerCommunicatorMap;
            }set;
        }
    }

    private static final Integer DEFAULT_NEGATIVE_ONE = -1;
    private static final Integer MANAGER_SUMMARY_DELIVERY_CALLOUT_COUNT = 1;
    private static final Integer OFFER_COMMUNICATORS_DELIVERY_QUERY_SIZE_LIMIT = 50;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold serialized state of properties used dor preparing payload for the Manager Summary Delivery API request.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class OfferCommunicatorsDeliveryParams implements MA_DS_ManagerSummaryDeliveryService.JobParams {
        public Integer totalBatches = DEFAULT_ZERO;
        public Integer currentIndex = DEFAULT_ZERO;
        public Integer successCount = DEFAULT_ZERO;
        public Integer currentBatchNumber = DEFAULT_ZERO;
        public Integer totalPkgDistributions = DEFAULT_ZERO;
        public Integer totalOfferCommunicators = DEFAULT_ZERO;
        public Integer currentIndexOfferCommunicatorsCount = DEFAULT_ZERO;
        public Integer maxAPICalloutCount = MANAGER_SUMMARY_DELIVERY_CALLOUT_COUNT;
        public Integer querySizeLimit = OFFER_COMMUNICATORS_DELIVERY_QUERY_SIZE_LIMIT;
        
        public Integer lastIndex = DEFAULT_NEGATIVE_ONE;

        public Id commonId {get; set;}
        public Id srcRecordId {get; set;}
        public Id targetUserId {get; set;}
        public Acquisition_Company__c acqCompany {get; set;}
        public MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin executionOriginType {get; set;}

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Package Distribution Ids, that initiated the MAnager Summary Delivery process.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Set<Id> summaryDeliveryPDIds {
            get {
                if(summaryDeliveryPDIds == null) {
                    summaryDeliveryPDIds = new Set<Id>();
                }
                return summaryDeliveryPDIds;
            }set;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the List of Package Distribution Ids, used by SummaryDeliveryJob to identify the Offer Communicator Ids to process them for Manager Summary Delivery.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public List<Id> offerCommunicatorPDIds {
            get {
                if(offerCommunicatorPDIds == null) {
                    offerCommunicatorPDIds = new List<Id>();
                }
                return offerCommunicatorPDIds;
            }set;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Map of Package Distribution Id to List of Offer Communicator Ids, used by SummaryDeliveryJob to prepare & send payload for Manager Summary Delivery API callout to DocuSign CLM.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Map<Id, List<Id>> offerCommunicatorMap {
            get {
                if(offerCommunicatorMap == null) {
                    offerCommunicatorMap = new Map<Id, List<Id>>();
                }
                return offerCommunicatorMap;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Map of Package Distribution Id to "Custom Manager Summary Email" flag value, used by SummaryDeliveryJob to prepare & send payload for Manager Summary Delivery API callout to DocuSign CLM.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Map<Id, Boolean> customSummaryEmailMap {
            get {
                if(customSummaryEmailMap == null) {
                    customSummaryEmailMap = new Map<Id, Boolean>();
                }
                return customSummaryEmailMap;
            }set;
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the Params for Manager Summary Delivery API callout to send the Offer Communicator details to inititate the Workflow in the DocuSign CLM.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class ManagerSummaryDeliveryParams implements MA_DS_CalloutFramework.RequestParams {
        public Id commonId {get; set;}
        public Id pkgDistributionId {get; set;}

        public Boolean customSummaryEmail {get; set;}
        public Boolean successResponse {get; private set;}

        public Integer totalBatches {get; set;}
        public Integer currentBatchNumber {get; set;}

        public Set<Id> offerCommunicatorIds {get; set;}
        
        public Acquisition_Company__c acqCompany {get; set;}
        public List<Acquisition_Contacts__c> offerCommunicators {get; set;}

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the successResponse property of the ManagerSummaryDeliveryParams. 
        * Method is called from the ResponseCallback implementation used to send Http API Request for the Manager Summary Delivery.
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