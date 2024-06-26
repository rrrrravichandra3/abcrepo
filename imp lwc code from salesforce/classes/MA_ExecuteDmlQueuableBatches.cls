/**
 * 
 * This class breaks the list of sobject records in chukns and initiate chaining
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         24/02/2022      Ashutosh Belwal        Holds Queueable chaining logic to auto-enrol acquisition contacts to data categories related permission sets.
 * 
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class MA_ExecuteDmlQueuableBatches implements Queueable {
    
    public enum ACTION_TYPE {DELETE_RECORDS, UPSERT_RECORDS}
    private Map<Integer, List<Sobject>>  records;
    private ACTION_TYPE action;      
    private Integer batchSize;
    private Integer currentBatch;
    private Integer successCount;    

    public MA_ExecuteDmlQueuableBatches(List<Sobject> recordsList, ACTION_TYPE action, Integer batchSize){
        
        this.records = batchOutDmls(recordsList, batchSize);
        this.action = action;
        this.batchSize = batchSize;
        this.currentBatch = 1;
        this.successCount = 0;
    }

    public MA_ExecuteDmlQueuableBatches(Map<Integer, List<Sobject>>  records, ACTION_TYPE action, Integer batchSize, Integer currentBatch, Integer successCount){
        this.records = records;
        this.action = action;
        this.batchSize = batchSize;
        this.currentBatch = currentBatch;
        this.successCount = successCount;        
    }

    public void execute(QueueableContext context) {
        if(this.records.containsKey(this.currentBatch)){
            Boolean success = false;
            Integer processedRecords = 0;
            try {
                List<Sobject> thisBatchRecords = this.records.get(this.currentBatch);
                processedRecords = thisBatchRecords.size();
                switch on action {
                    
                    when UPSERT_RECORDS {
                        upsertBatchRecords(thisBatchRecords);
                    }
                    when DELETE_RECORDS {
                        deleteBatchRecords(thisBatchRecords);
                    }
                }
                this.records.remove(this.currentBatch);
                success = true;
            } catch(Exception e){
                PF_Logger.log('MA','ERROR',e.getMessage(),null,'Error during chaning the data category Enrolloment batch : ' + e.getStackTraceString(), 'MA_ExecuteDmlQueuableBatches');
                PF_Logger.createLogs(PF_Logger.logs);           
            }
            
                    
            if(success) {
                if(this.successCount == null){
                    this.successCount = processedRecords;
                } else {
                    this.successCount += processedRecords;
                }
            }

            Integer nextBatch = this.currentBatch + 1;
            if(this.records.containsKey(nextBatch) && Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()){
                //Chain jobs
                System.enqueueJob(new MA_ExecuteDmlQueuableBatches(this.records, this.action, this.batchSize, nextBatch, this.successCount));
            } 
        } 
    }

    private Map<Integer, List<Sobject>> batchOutDmls(List<Sobject> recordsList, Integer batchSize){
        Map<Integer, List<Sobject>> batchMap = new Map<Integer, List<Sobject>>();
        if(batchSize <= 10000){
            Integer batchCurrSize = 0;
            Integer batchNumber = 1;
            List<Sobject> singleBatch = new List<Sobject>();    
            for (Integer i = 0; i < recordsList.size(); i++){
                if(batchCurrSize == batchSize){
                    batchMap.put(batchNumber, singleBatch);
                    singleBatch = new List<Sobject>();            
                    batchNumber++;
                    batchCurrSize = 0;
                }
                singleBatch.add(recordsList[i]);
                batchCurrSize++;
            }
            if(!singleBatch.isEmpty()){
                batchMap.put(batchNumber, singleBatch);
            } 
        } else {
            //throw new CustomException('BatchSize cannot be more than 10k');
        }
        return batchMap;
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method holds the logic for insertion of List of sObject records
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    recordsToUpsert					DESCRIPTION (Data type List<sObject>, List of permission set assignment)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void upsertBatchRecords(List<sObject> recordsToUpsert){
        Database.UpsertResult[] upsertResult = Database.upsert(recordsToUpsert, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(upsertResult, MA_AbstractLogger.BulkLoggerType.UPSERT_RESULT);
    }
   
     /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method holds the logic for deletion of List of sObject records
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    recordsToDelete					DESCRIPTION (Data type List<sObject>, List of sObject records )
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void deleteBatchRecords(List<sObject> recordsToDelete){
        Database.DeleteResult[] delteResults = Database.delete(recordsToDelete, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(delteResults, MA_AbstractLogger.BulkLoggerType.DELETE_RESULT);
    }
   
}