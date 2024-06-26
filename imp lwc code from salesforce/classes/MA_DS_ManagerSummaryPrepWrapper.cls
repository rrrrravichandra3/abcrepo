/**
 * W-12578116
 * Abstract Wrapper class to hold JobParams, used while processing Package Distributions for Manager Summary Prep / Regenration.
 * Holds JobParams type used while identifying eligible Offer Communicator Ids, that need to be processed for Manager Summary Prep.
 * Holds JobParams type used to get Offer Communicator & Summarized Contacts details to prepare and send payload for Manager Summary Prep API callout.
 * 
 * Version      Date            Author                  Description
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         27/03/2023      Chakshu Malhotra        W-12578116 - Adds logic to hold JobParams, used while processing Package Distributions for Manager Summary Prep / Regenration.
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_ManagerSummaryPrepWrapper {
    
    private static final Integer OFFER_COMMUNICATOR_PREP_MAX_QUERY_COUNT = 20;
    private static final Integer OFFER_COMMUNICATOR_PREP_QUERY_SIZE_LIMIT = 200;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold serialized state of properties used while identifying eligible Offer Communicator Ids to prepare them for Manager Summary Prep API callout.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class OfferCommunicatorsPrepParams implements MA_DS_ManagerSummaryPrepService.JobParams {
        public Integer maxQueryCount = OFFER_COMMUNICATOR_PREP_MAX_QUERY_COUNT;
        public Integer querySizeLimit = OFFER_COMMUNICATOR_PREP_QUERY_SIZE_LIMIT;

        public Boolean isAuditFailedRegen;
        public Boolean isAuditFailedRegenAll;

        public Id commonId {get; set;}
        public Id lastRecordId {get; set;}
        
        public Id srcRecordId {get; set;}
        public Id acqCompanyId {get; set;}
        public Id summaryTemplateId {get; set;}

        public MA_DS_ManagerSummaryPrepService.ExecutionOrigin executionOriginType {get; set;}

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Manager Summary Common Ids, used by SummaryPrepJob in case of ExecutionOrigin.AUDIT_FAILED_REGEN to identify the Offer Communicator Ids to process them for Manager Summary Regeneration.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Set<String> auditFailedCommonIds {
            get {
                if(auditFailedCommonIds == null) {
                    auditFailedCommonIds = new Set<String>();
                }
                return auditFailedCommonIds;
            }set;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Package Distribution Ids, used by SummaryPrepJob to identify the Offer Communicator Ids to process them for Manager Summary Prep or Regenration.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Set<Id> summaryPrepPDIds {
            get {
                if(summaryPrepPDIds == null) {
                    summaryPrepPDIds = new Set<Id>();
                }
                return summaryPrepPDIds;
            }set;
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Offer Communicator Ids, used by SummaryPrepJob to prepare & send payload for Manager Summary Prep callout to DocuSign CLM.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Set<String> offerCommunicatorIds {
            get {
                if(offerCommunicatorIds == null) {
                    offerCommunicatorIds = new Set<String>();
                }
                return offerCommunicatorIds;
            }set;
        }
    }

    private static final Integer DEFAULT_ZERO = 0;
    private static final Integer MANAGER_SUMMARY_PREP_CALLOUT_COUNT = 5;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold serialized state of properties used to get Offer Communicator & Summarized Contacts details to prepare and send payload for Manager Summary Prep API callout.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class SummarizedContactsPrepParams implements MA_DS_ManagerSummaryPrepService.JobParams {
        public Integer totalBatches = DEFAULT_ZERO;
        public Integer currentIndex = DEFAULT_ZERO;
        public Integer successCount = DEFAULT_ZERO;
        public Integer maxAPICalloutCount = MANAGER_SUMMARY_PREP_CALLOUT_COUNT;

        public Boolean isAuditFailedRegen;

        public Id commonId {get; set;}
        public Id srcRecordId {get; set;}
        public Id acqCompanyId {get; set;}
        public Id summaryTemplateId {get; set;}

        public MA_DS_ManagerSummaryPrepService.ExecutionOrigin executionOriginType {get; set;}

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Package Distribution Ids, used by SummaryPrepJob to identify the Offer Communicator Ids to process them for Manager Summary Prep or Regenration.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Set<Id> summaryPrepPDIds {
            get {
                if(summaryPrepPDIds == null) {
                    summaryPrepPDIds = new Set<Id>();
                }
                return summaryPrepPDIds;
            }set;
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the List of Offer Communicator Ids, used by SummaryPrepJob to prepare & send payload for Manager Summary Prep callout to DocuSign CLM.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public List<String> offerCommunicatorIds {
            get {
                if(offerCommunicatorIds == null) {
                    offerCommunicatorIds = new List<String>();
                }
                return offerCommunicatorIds;
            }set;
        }
    }
    
    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the Params for Manager Summary Prep API callout to send Offer Communicator & Summarized Contact details to the DocuSign CLM.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class ManagerSummaryPrepParams implements MA_DS_CalloutFramework.RequestParams {
        public Id commonId {get; set;}
        public Id asyncApexId {get; set;}

        public Id acqCompanyId {get; set;}
        public Id summaryTemplateId {get; set;}

        public String acqCompanyName {get; set;}

        public Integer totalBatches {get; set;}
        public Integer currentBatchNumber {get; set;}

        public Boolean successResponse {get; private set;}

        public Acquisition_Contacts__c offerCommunicator {get; set;}

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Package Distribution Ids, used by SummaryPrepJob to identify the Offer Communicator Ids to process them for Manager Summary Prep or Regenration.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Set<Id> primaryPDIds {
            get {
                if(primaryPDIds == null) {
                    primaryPDIds = new Set<Id>();
                }
                return primaryPDIds;
            }set;
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the List of Acquisition Contacts (Summarized Contacts), used in the Manager Summary Prep API payload.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public List<Acquisition_Contacts__c> summarizedContacts {
            get {
                if(summarizedContacts == null) {
                    summarizedContacts = new List<Acquisition_Contacts__c>();
                }
                return summarizedContacts;
            }set;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the successResponse property of the ManagerSummaryPrepParams. 
        * Method is called from the ResponseCallback implementation used to send Http API Request for the Manager Summary Prep.
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