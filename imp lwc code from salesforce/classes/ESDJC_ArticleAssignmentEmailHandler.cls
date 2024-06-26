public with sharing class ESDJC_ArticleAssignmentEmailHandler implements Messaging.InboundEmailHandler {

	public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope)
	{
		Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
    	if(Schema.sObjectType.KnowledgeArticleVersion.isUpdateable()){
	
			String articleId = email.plainTextBody;
	
			//get the article
			List<SObject> articles = null;
			
			//try get the HOWTO article
			articles = [SELECT Id, OwnerId, CreatedById, PublishStatus FROM KnowledgeArticleVersion 
											   WHERE IsLatestVersion = true 
											   		AND Id = :articleId];
	
			if (articles.size() == 1)
			{
	
				for (SObject article: articles)
				{
					//article.put('OwnerId', article.get('CreatedById'));
					article.put('IsVisibleInApp', false);
				}
				update articles;
	
			}
	
			result.success = true;
	
        } else {
        	ESDJC_Util.displayAccessPrivilegeError('Update KnowledgeArticleVersion');
        }
	    return result;
	}
	
}