global class pf_knowledgeMigrator implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{

    global final String pubStatus;
    global String sessionInfo;

    global pf_knowledgeMigrator(String status){
        pubStatus = status;
        sessionInfo = System.UserInfo.getSessionId();
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
    String query = 'Select Id, PublishStatus, articleNumber, knowledgeArticleId from Knowledge__kav where PublishStatus=\''+pubStatus+'\' and IsLatestVersion= True and RecordTypeId=null';
        return Database.getQueryLocator(query);
    }


    global void execute(Database.BatchableContext BC, List<Knowledge__kav> articles){
        for(Knowledge__kav currentArticle : articles){
            knowledgeMigratorHelper.migrationResult currentArticleMigrationResult;
            if((currentArticle.PublishStatus).equalsIgnoreCase('Online')){
                currentArticleMigrationResult = knowledgeMigratorHelper.processPublishedArticle(currentArticle,sessionInfo);
            }else if((currentArticle.PublishStatus).equalsIgnoreCase('Draft')){
                currentArticleMigrationResult = knowledgeMigratorHelper.processDraftArticle(currentArticle,sessionInfo);
            }
            PF_KnowledgeArticleMigrationResult__c result = new PF_KnowledgeArticleMigrationResult__c();
            result.Name = currentArticleMigrationResult.articleId;
            result.Initial_Status__c = currentArticleMigrationResult.initialStatus;
            result.Result__c = (currentArticleMigrationResult.success?'Success':'Error');
            result.Info__c = currentArticleMigrationResult.additionalInfo;
            result.Article_Number__c = currentArticleMigrationResult.articleNumber;
            result.Parent_Knowledge_Article_Id__c = currentArticleMigrationResult.knowledgeArticleId;

            PF_KnowledgeArticleMigrationResult__c existingCSrecord = PF_KnowledgeArticleMigrationResult__c.getValues(result.Name);
            if(existingCSrecord != null){
                result.Id = existingCSrecord.Id;
            }
            upsert result;
            
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}