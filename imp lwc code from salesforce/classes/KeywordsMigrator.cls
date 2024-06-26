global class KeywordsMigrator implements Database.Batchable<sObject>, Database.Stateful{

    String language;

    global KeywordsMigrator(String language) {
        this.language = language;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, KnowledgeArticleId, Title, IsMasterLanguage, Question__c, Search_Keywords__c FROM Knowledge__kav WHERE RecordType.DeveloperName = \'How_To\' AND Language = \'' + language + '\' AND PublishStatus = \'Online\' AND IsLatestVersion = true';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Knowledge__kav> articles) {
        System.debug('Processing ' + articles.size() + ' ' + language + ' articles');

        integer updated = 0;
        integer skipped = 0;
        integer errored = 0;

        Set<Id> articleIds = new Set<Id>();
        for (Knowledge__kav article : articles) {

            try {
                Id articleId = article.KnowledgeArticleId;

                if (article.IsMasterLanguage) {
                    KbManagement.PublishingService.editOnlineArticle(articleId, false);
                } else {
                    KbManagement.PublishingService.submitForTranslation(articleId, language, null, Datetime.now());
                }

                System.debug('Created a draft of article version ' + article.Id + ' with title "' + article.Title + '"');

                articleIds.add(articleId);
            } catch (Exception e) {
                System.debug('Error creating draft of article version ' + article.Id + ' with title "' + article.Title + '", cause: ' + e);
                errored++;
                continue;
            }
        }

        List<Knowledge__kav> drafts = Database.query('SELECT Id, KnowledgeArticleId, IsMasterLanguage, Search_Keywords__c, Question__c, Title FROM Knowledge__kav WHERE RecordType.DeveloperName = \'How_To\' AND Language = \'' + language + '\' AND PublishStatus = \'Draft\' AND KnowledgeArticleId IN :articleIds');

        for (Knowledge__kav draft : drafts) {
            String updatedKeywords;

            if( draft.Question__c != null ) {
                updatedKeywords = draft.Question__c.replaceAll('<br>', ' ');
            }

            if (draft.Question__c == null || updatedKeywords.contains('<') || updatedKeywords.contains('&quot') || updatedKeywords.contains('&#39;') || updatedKeywords.contains('&amp;')) {
                System.debug('Question__c is either null or contains html elements or contains special characters.');
                skipped++;
                continue;
            }
            System.debug('Updating keywords to ' + updatedKeywords);
            draft.Search_Keywords__c = updatedKeywords;
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
            }

            updated++;
        }

        System.debug('Articles updated: ' + updated + ', skipped: ' + skipped + ', errored: ' + errored + ', total: ' + articles.size());
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Migration Complete.');
    }
}