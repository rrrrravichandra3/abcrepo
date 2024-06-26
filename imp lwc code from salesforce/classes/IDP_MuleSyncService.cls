global class IDP_MuleSyncService implements Database.Batchable<sObject>,Database.AllowsCallouts,System.Schedulable,Database.Stateful {
    //schedulable class execute method
    global void execute(System.SchedulableContext SC) { 
        Database.executeBatch(new IDP_MuleSyncService(), IDP_MuleSyncService_Util.getBatchSize());
    }

    global Final Datetime batchStartTime = Datetime.now();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(IDP_MuleSyncService_Util.getQueryLocatorString());
    }
    
    global void execute(Database.BatchableContext BC, List<IDP_Action__c> records) {
        IDP_MuleSyncService_Util.processIDPActions(records, batchStartTime);
    }
    
    global void finish(Database.BatchableContext BC) { }
}