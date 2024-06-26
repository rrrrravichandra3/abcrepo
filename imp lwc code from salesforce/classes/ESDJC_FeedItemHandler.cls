public with sharing class ESDJC_FeedItemHandler {
	public static void createArticleFeedback (List<FeedItem> newFeedItems) {
		List<User> users = [SELECT UserPermissionsKnowledgeUser,UserPermissionsSupportUser FROM User WHERE UserName =: UserInfo.getUserName()];
		if(users == null || users.size() == 0){
			return; //We will not be able to identify the user
		}
		User thisUser = users.get(0);
		if(thisUser != null && thisUser.UserPermissionsKnowledgeUser == false){
			return; //Return if the user is not a Knowledge User
		}
		
		if(Schema.Sobjecttype.KnowledgeArticleVersion.isQueryable()){
			Map<String,FeedItem> parentId2FeedItemMap = new Map<String,FeedItem>();
	
			String parentId;
		    for (FeedItem feedItem : newFeedItems) {
		    	parentId = feedItem.parentId;
			    if (parentID.startsWith('kA')  && feedItem.type == 'TextPost') {
			    	parentId2FeedItemMap.put(parentId, feedItem);
			    }
		    }
		
			//Retrieve KnowledgeArticleVersion
			List<KnowledgeArticleVersion> kavs = [select id,Language, KnowledgeArticleId, articleNumber, title from KnowledgeArticleVersion where PublishStatus =:'online' and KnowledgeArticleId IN :parentId2FeedItemMap.keySet()];
			   
	        //if(Schema.Sobjecttype.PKB_Article_Feedback_Deflection__c.isCreateable()){
	        if ((thisUser.UserPermissionsSupportUser!=null)&&(thisUser.UserPermissionsSupportUser)){
				List<PKB_Article_Feedback_Deflection__c> afds = new List<PKB_Article_Feedback_Deflection__c> ();   
			   	
			   	ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
			   	for(KnowledgeArticleVersion kav : kavs){     
			   		String urls = URL.getSalesforceBaseUrl().toExternalForm()+'/'+kav.KnowledgeArticleId;//settings.SSO_URL__c+'/apex/ESDJC_Communities?id='+kav.KnowledgeArticleId;
			   		
			        PKB_Article_Feedback_Deflection__c afd = new PKB_Article_Feedback_Deflection__c (
			            Article_ID__c = kav.KnowledgeArticleId,
			            Language__c=kav.Language,
			            Article_Number__c = kav.articleNumber,
			            Article_Title__c = kav.title,
			            Article_URL__c = urls,
			            Feedback_Source__c = 'Internal',
			            Comments__c = parentId2FeedItemMap.get(kav.KnowledgeArticleId).Body,
			            Session_ID__c = '',
			            Deflection__c = false,
			            Keyword_Searched__c = ''            
			       	);
		        	afds.add(afd);
		        }
	        	insert afds;
			} else {
				ESDJC_Util.displayAccessPrivilegeError('Create PKB_Article_Feedback_Deflection__c');
	        }
		} else {
			ESDJC_Util.displayAccessPrivilegeError('Query KnowledgeArticleVersion');
		}
	}
	
}