global class  BatchRoleHierarcySupervisor implements Database.Batchable<sObject>{
	
	private String queryString=null; 
	
	global BatchRoleHierarcySupervisor(){
	
	}
	
	global BatchRoleHierarcySupervisor(String query){
		queryString=query;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		
		if(queryString==null){
			queryString='Select Id,UserRoleId,FirstName,LastName,EmployeeNumber,UserRole.Name,Manager__c,Manager__r.UserRoleId,Manager__r.Name,Manager__r.EmployeeNumber from User where userName like \'%peopleforce.com%\' and UserType !=\'Guest\' and LastModifiedDate=LAST_N_DAYS:2 and isActive=True';	
		}		 
		
		return Database.getQueryLocator(queryString);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
	
		List<UserRole> userRoleList = new List<UserRole>();
		Map<Id,User> newUserMap=new Map<Id,User>();
		List<User> updatedUserList= new List<User>();
		Map<Id,User> roleIdUserMap = new Map<Id,User>();
		List<String> managerNameList = new List<String>();

	    //create managerNameList and seperate new users from old users
		for(SObject obj:scope){ 
			User user = (User)obj;
			if(user.Manager__c!=null){
				managerNameList.add(user.Manager__r.Name.replaceAll(' ','')+user.Manager__r.EmployeeNumber);
			}
			
			if(user.UserRoleId==null){ 
				newUserMap.put(user.Id,user);
			}else{
				String roleName=user.UserRole.Name;
				Boolean isPeopleforceRole = Pattern.matches('.+([0-9]{5,})', roleName);
				//update roles only for talenforce users. talentforce 
				//users have roles as fName+LastName+EmpNumber. EmployeeNumber for contractors are CTRCT
				if(isPeopleforceRole){
					
					roleIdUserMap.put(user.UserRoleId,user);
				
				 }
			}	
		}
		
		Map<String,UserRole> managerNameUserRoleMap =new Map<String,UserRole>();
		
		List<UserRole> managerUserRoleList =[Select id, Name,ParentRoleId from UserRole where Name in: managerNameList];		
		for(UserRole ur:managerUserRoleList){			
			managerNameUserRoleMap.put(ur.Name,ur);		
		}		
		
		if(newUserMap.size()>0){
			//create new role and make managers role as its parent
			RoleHierarcyCreator.createNewRole(newUserMap, managerNameUserRoleMap);		
		}
		
		
		if(roleIdUserMap.size()>0){
		    //update existing role if needed
			RoleHierarcyCreator.updateRoles(roleIdUserMap, managerNameUserRoleMap);		
		}
	}
	
	global void finish(Database.BatchableContext BC){
		System.debug('************* Role Hierarchy Batch done. *******');
	}

}