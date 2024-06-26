/**
 * W-10060856
 * Batchable & Schedulable class to Delete old debug logs
 * 
 * Version      Date            Author                 Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         11/38/2023      Ashutosh Belwal        Delete all the debug logs older than one year
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public class PF_LogPurgeBatch implements Database.Batchable<sObject>, Schedulable {
    
    private static final String QUERY_FILTER = Label.PF_DebugDeleteFilter;
    private static final String CLASS_NAME = 'PF_LogPurgeBatch';
    private static final String JOB_TYPE = 'BatchApex';
    private static final Integer BATCH_SIZE = Integer.valueOf(Label.PF_DebugDeleteBatchSize);
    public String query;
    
    
     /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Schedulable interface method to schedule PF_LogPurgeBatch batch class.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    schedulableContext    DESCRIPTION (Data type SchedulableContext, Schedulable context variable containing Scheduled Job Id.)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void execute(SchedulableContext ctx){
        if(!isJobRunning()){
           initiateJob();
        }
    }
    
    public PF_LogPurgeBatch(String query){
        this.query = query;
    }
    
    public PF_LogPurgeBatch(){
       
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Database.Batchable interface method to fetch all required event records using Database.QueryLocator.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    batchContext 	   	   DESCRIPTION (Data type Database.BatchableContext, Batch context variable containing Batch Job Id.)
    * @return   Database.QueryLocator  DESCRIPTION (return Database.QueryLocator)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public Database.QueryLocator start(Database.BatchableContext BC){
       
        return Database.getQueryLocator(query);
    }
    
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Database.Batchable interface method to publish event changes for each event.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    batchContext    DESCRIPTION (Data type Database.BatchableContext, Batch context variable containing Batch Job Id.)
    * @param    events 	   	    DESCRIPTION (Data type List<PF_Debug_Log__c>, List of Community Events based on batch chunk size.)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void execute(Database.BatchableContext BC, List<PF_Debug_Log__c> lstLogs){
        
        Database.deleteResult[] srList = Database.delete(lstLogs, false);
        Database.emptyRecycleBin(lstLogs); 
        
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Database.Batchable interface method to process post batch execution logic if any.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    batchContext    DESCRIPTION (Data type Database.BatchableContext, Batch context variable containing Batch Job Id.)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void finish(Database.BatchableContext BC) {
        // no post-batch execution logic needed.
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method checks the if instance of previous job is finished or not.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   Boolean
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isJobRunning(){
              
        AsyncApexJob[] jobs = [SELECT Id FROM AsyncApexJob 
                               WHERE Status = 'Processing' AND ApexClass.Name =: CLASS_NAME AND JobType =: JOB_TYPE ];
        
        return !jobs.isEmpty();
        
    }
    
    @TestVisible
    private static void initiateJob(){
        String soql = 'SELECT Id FROM PF_Debug_Log__c WHERE '+QUERY_FILTER;
        PF_LogPurgeBatch objBatch = new PF_LogPurgeBatch(soql);
        objBatch.query = soql;
        Database.executebatch(objBatch, BATCH_SIZE);
    }
}