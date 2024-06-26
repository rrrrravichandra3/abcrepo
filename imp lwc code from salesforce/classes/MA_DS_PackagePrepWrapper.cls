/**
 * W-13011399
 * Abstract Wrapper class to hold JobParams, used while processing Package Distributions for Package Prep / Regenration.
 * Holds JobParams type used while identifying eligible Acquisition Contacts, that need to be processed for Package Prep.
 * Holds JobParams type used to get Acquisition Contacts & Package Documents (Template Ids) details to prepare and send payload for Package Prep API callout.
 * 
 * Version      Date            Author                  Description
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         29/04/2023      Chakshu Malhotra        W-13011399 - Adds logic to hold JobParams, used while processing Package Distributions for Package Prep / Regenration.
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_PackagePrepWrapper {
    
    private static final Integer DEFAULT_ZERO = 0;
    private static final Integer PACKAGE_PREP_CALLOUT_COUNT = 4;
    private static final Integer ACQ_CONTACTS_PREP_QUERY_SIZE_LIMIT = 16;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold serialized state of properties used while identifying eligible Acquisition Contacts to prepare them for Package Prep API callout.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class AcqContactsPackagePrepParams implements MA_DS_PackagePrepService.JobParams {
        public Integer successCount = DEFAULT_ZERO;
        public Integer totalContacts = DEFAULT_ZERO;
        public Integer maxAPICalloutCount = PACKAGE_PREP_CALLOUT_COUNT;
        public Integer querySizeLimit = ACQ_CONTACTS_PREP_QUERY_SIZE_LIMIT;

        public Boolean isAuditFailedRegen;

        public Boolean firstBatch = false;
        public Boolean finalBatch = false;

        public Id commonId {get; set;}
        public Id srcRecordId {get; set;}
        public Id acqCompanyId {get; set;}
        public Id lastRecordId {get; set;}

        public MA_DS_PackagePrepService.ExecutionOrigin executionOriginType {get; set;}

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Package Distribution Ids, used by PackagePrepJob to identify the Acquisition Contacts to process them for Package Prep or Regenration.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Set<Id> packagePrepPDIds {
            get {
                if(packagePrepPDIds == null) {
                    packagePrepPDIds = new Set<Id>();
                }
                return packagePrepPDIds;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Package Common Ids, used by PackagePrepJob in case of ExecutionOrigin.AUDIT_FAILED_REGEN to identify the Applied Rules based on Package Common Id on Acquisition Contacts to process them for Package Regeneration.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
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
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Template Ids, used by PackagePrepJob in case of ExecutionOrigin.AUDIT_FAILED_REGEN to identify the Applied Rules based on Template Ids to process them for Package Regeneration.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Set<String> templateIds {
            get {
                if(templateIds == null) {
                    templateIds = new Set<String>();
                }
                return templateIds;
            }set;
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Acquisition Contact Ids, used by PackagePrepJob in case of ExecutionOrigin.AUDIT_FAILED_REGEN to identify the Applied Rules based on Acquisition Contact Ids to process them for Package Regeneration.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Set<String> acqContactIds {
            get {
                if(acqContactIds == null) {
                    acqContactIds = new Set<String>();
                }
                return acqContactIds;
            }set;
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Applied Rule Ids, used by PackagePrepJob in case of ExecutionOrigin.AUDIT_FAILED_REGEN to identify the Applied Rules based on Applied Rule Ids to process them for Package Regeneration.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Set<String> appliedRuleIds {
            get {
                if(appliedRuleIds == null) {
                    appliedRuleIds = new Set<String>();
                }
                return appliedRuleIds;
            }set;
        }
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the Params for Package Prep API callout to send Package Document (Template Ids) details for each Acquisition Contact to the DocuSign CLM.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class PackagePrepParams implements MA_DS_CalloutFramework.RequestParams {
        public Id commonId {get; set;}
        public Id asyncApexId {get; set;}

        public Id acqCompanyId {get; set;}
        public String acqCompanyName {get; set;}

        public Boolean firstBatch {get; set;}
        public Boolean finalBatch {get; set;}

        public Boolean successResponse {get; private set;}

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the List of Acquisition Contacts, used in the Package Prep API payload.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public List<Acquisition_Contacts__c> acqContacts {
            get {
                if(acqContacts == null) {
                    acqContacts = new List<Acquisition_Contacts__c>();
                }
                return acqContacts;
            }set;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the successResponse property of the PackagePrepParams. 
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