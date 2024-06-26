public without sharing class knowledgeMigratorHelper{

	private static Id howToRecTypeId = [Select Id from RecordType where DeveloperName = 'How_To' limit 1].Id;
	
	//Data Structure to hold outcome for each article
	public class migrationResult{
		public String articleId;
		public String initialStatus;
		public Boolean success;
		public String additionalInfo;
		public String articleNumber;
		public String knowledgeArticleId;

		public migrationResult(String articleId, String initialStatus, Boolean success, String additionalInfo, String articleNumber, String knowledgeArticleId){
			this.articleId = articleId;
			this.initialStatus = initialStatus;
			this.success = success;
			this.additionalInfo = additionalInfo;
			this.articleNumber = articleNumber;
			this.knowledgeArticleId = knowledgeArticleId;
		}
	}

	/*
	* Method called by Batch class pf_knowledgeMigrator when current Article kav is a draft
	* It requires 3 steps - 
	* Step 1 - Unpublish the article, which archives it and creates a new draft version. Id of draft version is in rest response
	* Step 2 - Edit the recordtype on the draft version
	* Step 3 - Publish the draft version 
	*/
	public static migrationResult processPublishedArticle(Knowledge__kav article, String sessionInfo){
		String howToRecordTypeIdString = String.ValueOf(howToRecTypeId);
		//unpublish the article
		String articleId = String.ValueOf(article.Id);
		HttpResponse httpResponse = changePublishStatus(articleId, 'draft',sessionInfo);
		if(httpResponse.getStatusCode() == 200){
			//get the Id of draft version from the response
			Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
			String newDraftVersionId = String.valueOf(responseMap.get('id'));
			//change recordtype of this draft
			HttpResponse httpResponseDraftUpdate = changeRecordType(newDraftVersionId,howToRecordTypeIdString,sessionInfo);
			if(httpResponseDraftUpdate.getStatusCode() == 204){
				//publish the draft
				HttpResponse httpResponseRepublishUpdatedDraft = changePublishStatus(newDraftVersionId, 'Online',sessionInfo);
				if(httpResponseRepublishUpdatedDraft.getStatusCode() == 204){
					return (new migrationResult(articleId,'Published',True,'New Published Version is '+newDraftVersionId,article.ArticleNumber, String.ValueOf(article.KnowledgeArticleId)));
				}else{
					return (new migrationResult(articleId,'Published',False,'Published Article '+articleId+' converted to draft version '+newDraftVersionId +' with new RT, but republishing failed',article.ArticleNumber,String.ValueOf(article.KnowledgeArticleId)));
				}

			}else{
				//publish the draft version again without recordtype, as a revert process
				//this again can lead to two possible outcomes
				HttpResponse httpResponseRevertPublish = changePublishStatus(newDraftVersionId, 'Online',sessionInfo);
				if(httpResponseRevertPublish.getStatusCode() == 204){
					return (new migrationResult(articleId,'Published',False, 'Published Article '+articleId+' has a new published version '+newDraftVersionId +' but recordtype change failed',article.ArticleNumber, String.ValueOf(article.KnowledgeArticleId)));
				}else{
					return (new migrationResult(articleId,'Published',False, 'Published Article '+articleId+' converted to draft version '+newDraftVersionId +' but recordtype change failed',article.ArticleNumber, String.ValueOf(article.KnowledgeArticleId)));
				}
			}

		}else{
			String response = '';
			if(httpResponse.getBody() != null){
				response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
			}else{
				response = 'Unknown Error. Error Code '+httpResponse.getStatusCode();
			}
			return (new migrationResult(articleId,'Published',False, 'Article Could Not Be Archived :'+response,article.ArticleNumber, String.ValueOf(article.KnowledgeArticleId)));
		}
	}

	/*
	* Method called by Batch class pf_knowledgeMigrator when current Article kav is a draft
	* It changes the recordType of the draft to "How To"
	* Call to Utility method changeRecordType will do the job
	*/
	public static migrationResult processDraftArticle(Knowledge__kav article, String sessionInfo){

		String articleId = String.ValueOf(article.Id);
		String howToRecordTypeIdString = String.ValueOf(howToRecTypeId);
		HttpResponse httpResponse = changeRecordType(articleId,howToRecordTypeIdString,sessionInfo);
		if(httpResponse.getStatusCode() == 204){
			return (new migrationResult(articleId,'Draft',True, 'Draft Updated',article.ArticleNumber, String.ValueOf(article.KnowledgeArticleId)));
		}else{
			String response = '';
			if(httpResponse.getBody() != null){
				response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
			}else{
				response = 'Unknown Error. Error Code '+httpResponse.getStatusCode();
			}
			return (new migrationResult(articleId,'Draft',False, 'Draft Could Not Be Updated :'+response,article.ArticleNumber, String.ValueOf(article.KnowledgeArticleId)));
		}
	}

	/*
	* Utility Method to change recordType of a draft version of an article
	*/
	public static HttpResponse changeRecordType(String articleId, String recTypeId, String sessionInfo){
		String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
		String restAPIURL = sfdcURL + '/services/data/v43.0/sobjects/Knowledge__kav/'+articleId+'?_HttpMethod=PATCH';
		HttpRequest httpRequest = new HttpRequest(); 
		httpRequest.setMethod('POST');
		httpRequest.setHeader('Authorization', 'OAuth ' + sessionInfo); 
		httpRequest.setHeader('Authorization', 'Bearer ' + sessionInfo);
		httpRequest.setHeader('Content-Type', 'application/json');
		httpRequest.setEndpoint(restAPIURL);
		httpRequest.setBody('{ "RecordTypeId": "' + recTypeId + '"}'); 
		Http http = new Http();
		HttpResponse httpResponse = http.send(httpRequest);
		return httpResponse;
	}

	/*
	* Utility method to publish/unpublish articles
	*/
	public static HttpResponse changePublishStatus(String articleId, String publishStatus, String sessionInfo){
		String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
		String restAPIURL = sfdcURL + '/services/data/v43.0/knowledgeManagement/articleVersions/masterVersions/'+articleId+'?_HttpMethod=PATCH';
		HttpRequest httpRequest = new HttpRequest(); 
		httpRequest.setMethod('POST');
		httpRequest.setHeader('Authorization', 'OAuth ' + sessionInfo); 
		httpRequest.setHeader('Authorization', 'Bearer ' + sessionInfo);
		httpRequest.setHeader('Content-Type', 'application/json');
		httpRequest.setEndpoint(restAPIURL);
		httpRequest.setBody('{ "publishStatus":"'+publishStatus+'" }'); 
		Http http = new Http();
		HttpResponse httpResponse = http.send(httpRequest);
		return httpResponse;
	}
}