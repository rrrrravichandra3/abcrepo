/**
 * W-13484430 & W-13576017
 * Abstract Wrapper class to hold JobParams, used while post-processing of Package Distribution Status update.
 * Holds JobParams type used to process Status updates of Enum Type MA_DS_PackageStatusHandlerService.PackageStatus.
 * 
 * Version      Date            Author                  Description
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         23/06/2023      Chakshu Malhotra        W-13484430 & W-13576017 - Adds logic to hold JobParams, used while post-processing of Package Distribution Status update.
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_PackageStatusHandlerWrapper {
    
    private static final Integer RECALLED_STATUS_MAX_QUERY_COUNT = 20;
    private static final Integer RECALLED_STATUS_QUERY_SIZE_LIMIT = 200;

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold serialized state of properties used to identify & process Applied Rules to set "Need To Generate" & reset "Need To Deliver", using recursively instantiated queueable jobs.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class PackageRecalledStatusParams implements MA_DS_PackageStatusHandlerService.JobParams {
        public Integer maxQueryCount = RECALLED_STATUS_MAX_QUERY_COUNT;
        public Integer querySizeLimit = RECALLED_STATUS_QUERY_SIZE_LIMIT;
        
        public Id lastRecordId {get; set;}
        public Set<Id> pkgDistributionIds {get; set;}
    }
}