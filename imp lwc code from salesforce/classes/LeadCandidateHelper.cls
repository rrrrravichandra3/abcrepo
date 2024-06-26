/* Lead Candidate helper file ( without sharing class )
 * This will only get calls from trigger to avoid the following error when copying chatter Feed.
 * Implementation restriction: FeedItem requires a filter by Id
*/

public without sharing class LeadCandidateHelper {

	public static void ConvertChatterFeed( Id covertLeadId, Id convertCandidateId ){

		//query feed item with lead id
		List<LeadFeed> leadFeedList = [ select Id from LeadFeed where ParentId =: covertLeadId];

		List<FeedItem> ExistingFeedItemList = [select body,Id,InsertedById,LikeCount,LinkUrl,ParentId,Title,Type from FeedItem where parentId =: covertLeadId and Type != 'TrackedChange' limit 1000 ];
		Set<Id> FeedItemIdSet = new Set<Id>();
		List<FeedItem> FeedItemList = new List<FeedItem>();
		List<FeedComment> FeedCommentList = new List<FeedComment>();
		Map<Id, Id> ItemIDMap = new Map<Id, Id>();

		if ( ExistingFeedItemList != null && ExistingFeedItemList.size() > 0 ){
			for (  FeedItem fitem : ExistingFeedItemList ){
				//adding into list
				FeedItemIdSet.add( fitem.Id );
				//cloning for insert
				FeedItem fi = fitem.Clone(false,true,true,false);
				fi.parentId = convertCandidateId;
				FeedItemList.add( fi );
				ItemIDMap.put( fitem.Id, null );
			}
		}

		if ( FeedItemList.size() > 0 )
			insert FeedItemList;

		for ( integer i = 0; i < FeedItemList.size(); i++ ){
			ItemIDMap.put( ExistingFeedItemList[i].Id, FeedItemList[i].Id );
		}
		
		//query feed comment with feed item
		if ( FeedItemIdSet.size() > 0 ){	
			List<FeedComment> ExistingFeedCommentList = [ select CommentBody,CommentType,CreatedById,CreatedDate,FeedItemId,Id,InsertedById,ParentId  from FeedComment where FeedItemId in : FeedItemIdSet ];

			if ( ExistingFeedCommentList != null && ExistingFeedCommentList.size() > 0 ){
				for ( FeedComment fcomment : ExistingFeedCommentList ){
					FeedComment fc = fcomment.Clone(false,true,true,false);
					fc.FeedItemId = ItemIDMap.get( fcomment.FeedItemId );
					FeedCommentList.add( fc );
				}
			}

			if ( FeedCommentList.size() > 0 )
				insert FeedCommentList;
    	}

	}
}