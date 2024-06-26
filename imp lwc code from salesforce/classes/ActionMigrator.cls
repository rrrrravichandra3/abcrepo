global class ActionMigrator implements Database.Batchable<sObject>, Database.Stateful{

    String language;
    
    global ActionMigrator(String language) {
        this.language = language;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, KnowledgeArticleId, Title, PublishStatus, IsMasterLanguage, Primary_Action__c, Other_Actions__c, Answers_Article_Action_1__c, Answers_Article_Action_2__c, Answers_Article_Action_3__c FROM Knowledge__kav WHERE RecordType.DeveloperName = \'How_To\' AND Language = \'' + language + '\' AND PublishStatus = \'Online\' AND IsLatestVersion = true';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Knowledge__kav> articles) {
        System.debug('Processing ' + articles.size() + ' ' + language + ' articles');
        
        Map<String, String> actionIds = new Map<String, String>();

        for (Answers_Article_Action__c a : [SELECT Id, Name FROM Answers_Article_Action__c WHERE Active__c = true]) {
            actionIds.put(a.Name, a.Id);
        }

        integer updated = 0;
        integer skipped = 0;
        integer errored = 0;

        Map<Id, List<String>> articleIdToActions = new Map<Id, List<String>>();

        for (Knowledge__kav article : articles) {
            List<String> foundIds = new List<String>();
            
            System.debug('Evaluating article version: ' + article.Id + ' with title "' + article.Title + '"');

            String primary = article.Primary_Action__c;
            if (primary != null) {
                String primaryId = actionIds.get(primary);

                if (primaryId == null) {
                    System.debug('Unable to find action for "' + primary + '" on article version ' + article.Id + ' with title "' + article.Title + '"');
                } else {
                    foundIds.add(primaryId);
                }
            }

            String[] others = new String[] {};
            if (article.Other_Actions__c != null) {
                others = article.Other_Actions__c.split(';');
            }

            for (String other : others) {
                String otherId = actionIds.get(other);

                if (otherId == null) {
                    System.debug('Unable to find action for "' + other + '" on article version ' + article.Id + ' with title "' + article.Title + '"');
                } else {
                    foundIds.add(otherId);
                }
            }

            if (foundIds.size() == 0) {
                System.debug('Knowledge Article has no actions found to migrate on article version ' + article.Id + ' with title "' + article.Title + '"');
                skipped++;
                continue;
            }

            if (foundIds.size() > 3) {
                System.debug('Knowledge Article has too many actions to migrate on article version ' + article.Id + ' with title "' + article.Title + '"');
                skipped++;
                continue;
            }

            String action1 = foundIds.get(0);
            String action2 = foundIds.size() > 1 ? foundIds.get(1) : null;
            String action3 = foundIds.size() > 2 ? foundIds.get(2) : null;

            if (article.Answers_Article_Action_1__c == action1 &&
                    article.Answers_Article_Action_2__c == action2 &&
                    article.Answers_Article_Action_3__c == action3) {
                System.debug('Knowledge Article version ' + article.Id + ' with title "' + article.Title + '" up-to-date');
                skipped++;
                continue;
            }

            try {
                Id articleId = article.KnowledgeArticleId;

                if (article.IsMasterLanguage) {
                    KbManagement.PublishingService.editOnlineArticle(articleId, false);
                } else {
                    KbManagement.PublishingService.submitForTranslation(articleId, language, null, Datetime.now());
                }
                 
                System.debug('Created a draft of article version ' + article.Id + ' with title "' + article.Title + '"');

                articleIdToActions.put(articleId, foundIds);
            } catch (Exception e) {
                System.debug('Error creating draft of article version ' + article.Id + ' with title "' + article.Title + '", cause: ' + e);
                errored++;
                continue;
            }
        }

        Set<Id> articleIds = articleIdToActions.keySet();
        
        List<Knowledge__kav> drafts = Database.query('SELECT Id, KnowledgeArticleId, IsMasterLanguage, Answers_Article_Action_1__c, Answers_Article_Action_2__c, Answers_Article_Action_3__c, Title FROM Knowledge__kav WHERE RecordType.DeveloperName = \'How_To\' AND Language = \'' + language + '\' AND PublishStatus = \'Draft\' AND KnowledgeArticleId IN :articleIds');
        
        for (Knowledge__kav draft : drafts) {
            Id articleId = Id.valueOf(draft.KnowledgeArticleId);

            List<String> draftActions = articleIdToActions.get(articleId);

            if (draftActions == null) {
                System.debug('************ ERROR: No draft actions for article version ' + draft.Id + ' with title "' + draft.Title + '"');
                continue;
            }

            draft.Answers_Article_Action_1__c = draftActions.get(0);
            draft.Answers_Article_Action_2__c = draftActions.size() > 1 ? draftActions.get(1) : null;
            draft.Answers_Article_Action_3__c = draftActions.size() > 2 ? draftActions.get(2) : null;
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

    }
}