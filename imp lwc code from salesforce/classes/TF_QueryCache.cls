public class TF_QueryCache {
	
	private static Map<Id, User> cacheMapUsers = new Map<Id, User>();

	// Queries User records and save them in an "static variable" cache for future use.
	// User should provide a set User Ids and get a map that includes those Ids and their corresponding user records.
	// If refresh == true: Records are queried from the database and cache is updated regardless if the records exist
	// in the cache or not.
	// If returnAllCache == true : Along with the requested userIds, the returned map include all Users that haven been 
	// cached.
	public static Map<Id, User> getUsers(Set<Id> userIds, Boolean refresh, Boolean returnAllCache) {
		Map<Id, User> mapUsersToReturn = new Map<Id, User>();

		if (cacheMapUsers == null) {
			cacheMapUsers = new Map<Id, User>();
		}
		
		Set<Id> userIdsToQuery;
		if (userIds != null) {
			userIdsToQuery = userIds.clone();
		} else {
			userIdsToQuery = new Set<Id>();
		}
		
		// Logic to determine if we need to query the User object or not.
		// Don't query if the User record is already cached (unless we want to refresh cache for the userIds that were passed)
		if ((refresh == null || refresh == false) && userIdsToQuery.isEmpty() == false && cacheMapUsers.keySet().containsAll(userIdsToQuery) == false) {
			userIdsToQuery.removeAll(cacheMapUsers.keySet());
		}

		if (userIdsToQuery.isEmpty() == false) {
			for (User u : [select Id, Name,
						   Mgmt_Chain_Level_02__c,
						   Mgmt_Chain_Level_03__c
					   	   from User 
					   	   where Id in :userIdsToQuery]) {
				cacheMapUsers.put(u.Id, u);
			}
		}

		if (returnAllCache == true) {
			mapUsersToReturn = cacheMapUsers.deepClone();
		} else {
			for (Id userId : userIds) {
				if (cacheMapUsers.containsKey(userId) && cacheMapUsers.get(userId) != null) {
					mapUsersToReturn.put(userId, cacheMapUsers.get(userId));
				}
			}
		}
		
		return mapUsersToReturn; 
	}
}