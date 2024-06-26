global class ManagerOnlyMigrator implements Database.Batchable<sObject>, Database.Stateful{

    String language;
    
    global ManagerOnlyMigrator(String language) {
        this.language = language;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, KnowledgeArticleId, IsMasterLanguage, Managers_Only__c, Title FROM Knowledge__kav WHERE Managers_Only__c = false AND RecordType.DeveloperName = \'How_To\' AND Language = \'' + language + '\' AND PublishStatus = \'Online\' AND IsLatestVersion = true WITH DATA CATEGORY Topic__c BELOW Manager_Resources__c';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Knowledge__kav> articles) {
        System.debug('Processing ' + articles.size() + ' articles');
        
        integer updated = 0;
        integer skipped = 0;
        integer errored = 0;
        
        Set<Id> articleIds = new Set<Id>();

        for (Knowledge__kav article : articles) {
            Id articleId = article.KnowledgeArticleId;

            try {
                if (article.IsMasterLanguage) {
                    KbManagement.PublishingService.editOnlineArticle(articleId, false);
                } else {
                    KbManagement.PublishingService.submitForTranslation(articleId, language, null, Datetime.now());
                }
                
                System.debug('Created a draft of article version ' + article.Id + ' with title "' + article.Title + '"');

                articleIds.add(articleId);
            } catch (Exception e) {
                System.debug('Error creating a draft of article version ' + article.Id + ' with title "' + article.Title + '", cause: ' + e);
                errored++;
                continue;
            }
        }

        List<Knowledge__kav> drafts = Database.query('SELECT Id, KnowledgeArticleId, IsMasterLanguage, Managers_Only__c, Title FROM Knowledge__kav WHERE RecordType.DeveloperName = \'How_To\' AND Language = \'' + language + '\' AND PublishStatus = \'Draft\' AND KnowledgeArticleId IN :articleIds');

        for (Knowledge__kav draft : drafts) {
            draft.Managers_Only__c = true;
        }

        update drafts;
        
        Set<Id> publishedIds = new Set<Id>();

        for (Knowledge__kav draft : drafts) {
            Id articleId = draft.KnowledgeArticleId;
            
            // Don't publish a master/translation article repeatedly if more than one exists in the same batch.
            // Publishing operates on all drafts of the master article, including translations.
            if (!publishedIds.contains(articleId)) {
                try {
                    if (draft.isMasterLanguage) {
                        KbManagement.PublishingService.publishArticle(articleId, true);
                    } else {
                        KbManagement.PublishingService.completeTranslation(draft.Id);
                    }

                    System.debug('Published article version ' + draft.Id + ' with title "' + draft.Title + '"');
                    
                    publishedIds.add(articleId);
                } catch (Exception e) {
                    System.debug('Error publishing article version ' + draft.Id + ' with title "' + draft.Title + '", cause: ' + e);
                    continue;          
                }
                publishedIds.add(articleId);
            }
            
            updated++;
        }

        System.debug('Articles updated: ' + updated + ', skipped: ' + skipped + ', errored: ' + errored + ', total: ' + articles.size());
    }

    global void finish(Database.BatchableContext BC) {

    }
}