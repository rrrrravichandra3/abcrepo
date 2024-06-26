global with sharing class te_InsertJobsIntoMySQLDB implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {
    global void execute(SchedulableContext SC) {
        Database.executeBatch(this, 10);
      }

    global database.queryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Job_Description__c FROM te_job__c WHERE embedding_complete__c = true and inserted_in_db__c = false AND Region__c != \'Japan\' LIMIT 500');
    }

    global void execute(Database.BatchableContext bc, list<te_job__c> records) {        
        for(te_job__c job: records){
            String response = te_EinsteinRecommendationsService.insertJobtoMySQLDB(job.id);

            if(response.contains('Job Upserted')){
                job.inserted_in_db__c = true;
            }
        }

        update records;

    }
    
    global void finish(Database.BatchableContext BC) {

    }
}