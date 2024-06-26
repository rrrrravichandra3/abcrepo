global class BatchableRoleHierarchyLinker implements Database.Batchable<sObject> {

	global final String query;
	
	global BatchableRoleHierarchyLinker(String q) {
		query = q;	
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		/*
			Get a set of role id's to query all the roles in question
		*/
		Set<Id>roleIds = new Set<Id>();
		Set<Id>managerIds = new Set<Id>();
		for (sObject cur : scope) {
			User curUser = (User)cur;	
			roleIds.add(curUser.UserRoleId);
			managerIds.add(curUser.Manager__c);
		}
		/* Get managers */
		List<User>managers = [select id, UserRoleId from User where Id in :managerIds];
		Map<Id, Id>managerMap = new Map<Id, Id>();
		
		for (User cur : managers) {
			managerMap.put(cur.Id, cur.UserRoleId);
		}
		
		/* Get all the roles in a list to start linking */
		List<UserRole>roleList = [select id, Name, ParentRoleId from UserRole where Id in :roleIds];
		Map<Id, UserRole>roleMap = new Map<Id, UserRole>();
		for (UserRole cur : roleList) {
			roleMap.put(cur.Id, cur);
		}
		
		/* Go through users again and link their roles to the manager's role. */
		List<UserRole>rolesToUpdate = new List<UserRole>();
		for (sObject cur : scope) {
			User curUser = (User)cur;
			if (managerMap.containsKey(curUser.Manager__c)) {
				if (roleMap.containsKey(curUser.UserRoleId)) {
					UserRole temp = roleMap.get(curUser.UserRoleId);
					temp.ParentRoleId = managerMap.get(curUser.Manager__c);
					rolesToUpdate.add(temp);
				}
			}
		}
		update rolesToUpdate;
	}
	
	global void finish(Database.BatchableContext BC){
   		System.debug('******* Role Hierarchy Batch done. *******');
	}
	   
}