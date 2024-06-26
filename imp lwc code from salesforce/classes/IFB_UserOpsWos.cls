public without sharing class IFB_UserOpsWos {
	
	private static Map<Id, IFB_UserInfo> userInfoMap;
	private static Map<Id, User> userMap;

	public class IFB_UserInfo {
		public User user;
		public Boolean itHasInterviewerPermissionSet;
		public Boolean itHasHiringOrganizationPermissionSet;

		public IFB_UserInfo(User user) {
			this.user = user;
		}
	}

	// Get information for a pariticular set of User ids
	// Eg. We query if the user have the 'SIFT - Interviewer' and/or the 'SIFT - Hiring Organization' permission set.
	public static Map<Id, IFB_UserInfo> getUserInfo(Set<Id> userIds) {
		if (userInfoMap == null) {
			userInfoMap = new Map<Id, IFB_UserInfo>();
		}

		// We only query for the users that we haven't queried before (same transaction)
		Set<Id> userIdsToQuery = new Set<Id>();
		if (userInfoMap.keySet().containsAll(userIds) == false){
			for (Id userId: userIds) {
				if (userInfoMap.keySet().contains(userId) == false) {
					userIdsToQuery.add(userId);
					userInfoMap.put(userId, new IFB_UserInfo(new User(Id = userId)));
				}
			}
		
			// These are the permissions sets we want to know if the users have been assigned to.
			Set<Id> permissionSetIdsToQuery = new Set<Id>();
			permissionSetIdsToQuery.add(IFB_Metadata_PermissionSet.getPermissionSet(IFB_Metadata_PermissionSet.Option.SIFT_INTERVIEWER).Id);
			permissionSetIdsToQuery.add(IFB_Metadata_PermissionSet.getPermissionSet(IFB_Metadata_PermissionSet.Option.SIFT_HIRING_ORGANIZATION).Id);
			
			// We group permission set assignments by AssigneeId
			Map<Id, Set<Id>> permissionSetsByUserId = new Map<Id, Set<Id>>();
			for (Id userId : userIdsToQuery) {
				permissionSetsByUserId.put(userId, new Set<Id>());
			}

			for (PermissionSetAssignment psa : [select AssigneeId, PermissionSetId 
												from PermissionSetAssignment 
												where PermissionSetId in :permissionSetIdsToQuery
												and AssigneeId in :userIdsToQuery]) {
				permissionSetsByUserId.get(psa.AssigneeId).add(psa.PermissionSetId);
			}

			// We set the flags in their corresponding IFB_UserInfo instances
			for(Id userId : permissionSetsByUserId.keySet()){
				if (permissionSetsByUserId.get(userId).contains(IFB_Metadata_PermissionSet.getPermissionSet(IFB_Metadata_PermissionSet.Option.SIFT_INTERVIEWER).Id)) {
					userInfoMap.get(userId).itHasInterviewerPermissionSet = true;
				} else {
					userInfoMap.get(userId).itHasInterviewerPermissionSet = false;
				}

				if (permissionSetsByUserId.get(userId).contains(IFB_Metadata_PermissionSet.getPermissionSet(IFB_Metadata_PermissionSet.Option.SIFT_HIRING_ORGANIZATION).Id)) {
					userInfoMap.get(userId).itHasHiringOrganizationPermissionSet = true;
				} else {
					userInfoMap.get(userId).itHasHiringOrganizationPermissionSet = false;
				}
			}
		}		
		return userInfoMap;	
	}

	// Get information from User object. Information is cached.
	public static Map<Id, User> getUser(Set<Id> userIds) {
		if (userMap == null) {
			userMap = new Map<Id, User>();
		}

		// We only query for the users that we haven't queried before (same transaction)
		if (userMap.keySet().containsAll(userIds) == false) {
			Set<Id> userIdsToQuery = new Set<Id>();
			for (Id userId: userIds) {
				if (userMap.keySet().contains(userId) == false) {
					userIdsToQuery.add(userId);
				}
			}

			for (User u : [select Id, isActive from User where Id in :userIdsToQuery]) {
				userMap.put(u.Id, u);
			}
		}
		return userMap;
	}
}