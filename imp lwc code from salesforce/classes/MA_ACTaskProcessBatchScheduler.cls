/**
* @description       : Schedular class for MA_ACTaskProcessBatch
* @author            : Satyam Kumar
* Modifications Log 
* Ver   Date         Author          Modification
* 1.0   22-06-2021   Satyam Kumar   Initial Version
* */
global class MA_ACTaskProcessBatchScheduler implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        MA_ACTaskProcessBatch batch = new MA_ACTaskProcessBatch();
        Database.executeBatch(batch, Integer.valueOf(MA_Util.getTaskManagementSettings().ACTaskProcessBatch_Size__c));
    }
    
}