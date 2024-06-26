global with sharing class te_EmbeddJobDescriptionBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts{
    global void execute(SchedulableContext SC) {
        Database.executeBatch(this, 10);
      }

    global database.queryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id,skills__c, Job_Description__c,Job_Title__c,Compensation_Grade__c,embedding_complete__c FROM te_job__c WHERE embedding_complete__c = false AND Region__c != \'Japan\' LIMIT 500');
    }

    global void execute(Database.BatchableContext bc, list<te_job__c> records) {        
        for(te_job__c job: records){
            if(job.skills__c != null){
                job.jd_vector__c = einstein_GPT_Service.returnEmbedding(job.Job_Description__c);
                job.embedding_complete__c = true;
            }
        }

    update records;

    }
    
    global void finish(Database.BatchableContext BC) {
        Id BatchId = Database.executeBatch(new te_InsertJobsIntoMySQLDB(), 5);
    }
}