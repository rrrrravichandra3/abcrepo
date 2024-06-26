global with sharing class te_jobSkillExtractionBatch implements Database.Batchable<sObject>, Schedulable {
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(this, 10);
      }

    global database.queryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, Job_Description__c, Job_Title__c FROM te_job__c WHERE skill_extraction_complete__c = false AND Region__c != \'Japan\'');
    }

    global void execute(Database.BatchableContext BC, list<te_job__c> records) {
        String instructions = 'You have extensive knowledge of Professional Skill Taxonomies. Take into consideration the Job Description and Job Title from the following context: ' ;
        String prompt = 'Given the above job, extract and return a comma-separated array of concise professional skills, each consisting of a maximum of two words and in Proper Case. Limit the totally number of skills returned to be the top 30 skills.';
        
        for(te_job__c job: records){
            String context = ' --- context --- ' + System.JSON.serialize(job) + ' --- context --- ';
            String final_prompt = instructions + context + prompt ;
            String response =  einstein_GPT_Service.returnGPTResponse(final_prompt);
            job.skills__c = response;
            job.skill_extraction_complete__c = true;
        }

    update records;

    }
    
    global void finish(Database.BatchableContext BC) {
        Database.executeBatch(new te_EmbeddJobDescriptionBatch(),10);
    }
}