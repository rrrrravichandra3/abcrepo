/**
 * W-12578116, W-12578130 & W-13465433
 * Abstract Wrapper class to hold JobParams, used while processing Acquisition Contacts and/or Package Distribution record to denote Failures.
 * Holds JobParams type used to process failures of Enum Type MA_DS_FailureHandlerService.Failure.
 * 
 * Version      Date            Author                  Description
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         30/03/2023      Chakshu Malhotra        W-12578116 - Adds logic to hold JobParams, used while processing Acquisition Contacts and/or Package Distribution record to denote Failures.
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_FailureHandlerWrapper {
    
    private static final Integer SUMMARY_PREP_FAILURE_MAX_QUERY_COUNT = 20;
    private static final Integer SUMMARY_PREP_FAILURE_QUERY_SIZE_LIMIT = 200;

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold serialized state of properties used while updating Applied Rules with "Need To Generate" to denote Summary Prep Failure using recursively instantiated queueable jobs.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class SummaryPrepFailureParams implements MA_DS_FailureHandlerService.JobParams {
        public Integer maxQueryCount = SUMMARY_PREP_FAILURE_MAX_QUERY_COUNT;
        public Integer querySizeLimit = SUMMARY_PREP_FAILURE_QUERY_SIZE_LIMIT;
        
        public Id lastRecordId {get; set;}
        public Set<String> commonIds {get; set;}
    }

    private static final Integer SUMMARY_AUDIT_FAILURE_MAX_QUERY_COUNT = 20;
    private static final Integer SUMMARY_AUDIT_FAILURE_QUERY_SIZE_LIMIT = 200;

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold serialized state of properties used while updating Applied Rules with "Need To Generate" to denote Summary Audit Failure using recursively instantiated queueable jobs.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class SummaryAuditFailureParams implements MA_DS_FailureHandlerService.JobParams {
        public Integer maxQueryCount = SUMMARY_AUDIT_FAILURE_MAX_QUERY_COUNT;
        public Integer querySizeLimit = SUMMARY_AUDIT_FAILURE_QUERY_SIZE_LIMIT;
        
        public Id lastRecordId {get; set;}
        public Set<String> commonIds {get; set;}
        public Set<String> offerCommunicatorIds {get; set;}
    }

    private static final Integer SUMMARY_DELIVERY_FAILURE_MAX_QUERY_COUNT = 20;
    private static final Integer SUMMARY_DELIVERY_FAILURE_QUERY_SIZE_LIMIT = 200;

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold serialized state of properties used while updating Applied Rules with "Need To Deliver" to denote Summary Delivery Failure using recursively instantiated queueable jobs.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class SummaryDeliveryFailureParams implements MA_DS_FailureHandlerService.JobParams {
        public Integer maxQueryCount = SUMMARY_DELIVERY_FAILURE_MAX_QUERY_COUNT;
        public Integer querySizeLimit = SUMMARY_DELIVERY_FAILURE_QUERY_SIZE_LIMIT;
        
        public Id lastRecordId {get; set;}
        public Set<Id> pkgDistributionIds {get; set;}
        public Set<String> offerCommunicatorIds {get; set;}
    }

    private static final Integer PACKAGE_PREP_FAILURE_MAX_QUERY_COUNT = 20;
    private static final Integer PACKAGE_PREP_FAILURE_QUERY_SIZE_LIMIT = 200;

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold serialized state of properties used while updating Applied Rules with "Need To Generate" to denote Package Prep Failure using recursively instantiated queueable jobs.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class PackagePrepFailureParams implements MA_DS_FailureHandlerService.JobParams {
        public Integer maxQueryCount = PACKAGE_PREP_FAILURE_MAX_QUERY_COUNT;
        public Integer querySizeLimit = PACKAGE_PREP_FAILURE_QUERY_SIZE_LIMIT;
        
        public Id lastRecordId {get; set;}
        public Set<String> commonIds {get; set;}
        public Set<String> templateIds {get; set;}
        public Set<Id> pkgDistributionIds {get; set;}
    }
    
    private static final Integer PACKAGE_AUDIT_FAILURE_MAX_QUERY_COUNT = 20;
    private static final Integer PACKAGE_AUDIT_FAILURE_QUERY_SIZE_LIMIT = 200;

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold serialized state of properties used while updating Applied Rules with "Need To Generate" to denote Package Audit Failure using recursively instantiated queueable jobs.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class PackageAuditFailureParams implements MA_DS_FailureHandlerService.JobParams {
        public Integer maxQueryCount = PACKAGE_AUDIT_FAILURE_MAX_QUERY_COUNT;
        public Integer querySizeLimit = PACKAGE_AUDIT_FAILURE_QUERY_SIZE_LIMIT;
        
        public Id lastRecordId {get; set;}
        public Set<String> commonIds {get; set;}
        public Set<String> templateIds {get; set;}
        public Set<String> acqContactIds {get; set;}
        public Set<String> appliedRuleIds {get; set;}
    }

    private static final Integer PACKAGE_DELIVERY_FAILURE_MAX_QUERY_COUNT = 20;
    private static final Integer PACKAGE_DELIVERY_FAILURE_QUERY_SIZE_LIMIT = 200;

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold serialized state of properties used while updating Applied Rules with "Need To Deliver" to denote Package Delivery Failure using recursively instantiated queueable jobs.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class PackageDeliveryFailureParams implements MA_DS_FailureHandlerService.JobParams {
        public Integer maxQueryCount = PACKAGE_DELIVERY_FAILURE_MAX_QUERY_COUNT;
        public Integer querySizeLimit = PACKAGE_DELIVERY_FAILURE_QUERY_SIZE_LIMIT;
        
        public Id lastRecordId {get; set;}
        public Set<String> acqContactIds {get; set;}
        public Set<Id> pkgDistributionIds {get; set;}
    }
}