global class BatchableRoleHierarchyCreator implements Database.Batchable<sObject> {
	global final String query;
	
	global BatchableRoleHierarchyCreator(String q) {
		query = q;	
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
	
	
		List<UserRole>rolesToInsert = new List<UserRole>();
		
		/*
			Go through top level users (which is what we received in the batch).
		*/
	
		for (sObject cur : scope) {
			User curUser = (User)cur; 
			UserRole tempRole = new UserRole();
			String nameString = curUser.FirstName + curUser.LastName;
			if (nameString.length() > 34) {
				nameString = nameString.substring(0,34);
			}
			tempRole.Name = nameString + curUser.EmployeeNumber;
			rolesToInsert.add(tempRole);
		
		}
		insert rolesToInsert;
		
		
	}
	
	global void finish(Database.BatchableContext BC){
   		System.debug('******* Role Hierarchy Batch done. *******');
	}

   
}