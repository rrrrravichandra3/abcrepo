global class BatchableRoleHierarchyAssignment implements Database.Batchable<sObject> {

	global final String query;
	
	global BatchableRoleHierarchyAssignment(String q) {
		query = q;	
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		/*
			Go through all users and assign roles.
		*/
		
		List<User>uList = new List<User>();
		List<UserRole>roleList = [select id, Name from UserRole];
		Map<String, Id>userRoleMap = new Map<String, Id>();
		for (UserRole curRole : roleList) {
			userRoleMap.put(curRole.name, curRole.Id);
		}
		
		for (sObject cur : scope) {
			User curUser = (User)cur;	
			String nameString = curUser.FirstName + curUser.LastName;
			if (nameString.length() > 34) {
				nameString = nameString.substring(0,34);
			}
			String roleName = nameString + curUser.EmployeeNumber;
			if (userRoleMap.containsKey(roleName)) {
				curUser.UserRoleId = userRoleMap.get(roleName);
				uList.add(curUser);
			}
			
		}
		update uList;
		
	}
	
	global void finish(Database.BatchableContext BC){
   		System.debug('******* Role Hierarchy Batch done. *******');
	}
	   
}