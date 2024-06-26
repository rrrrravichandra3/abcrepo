public  class RoleHierarcyCreator {	
	
	/*Creates new roles and assignes the roleid to the userroleid in user object. 
    *@param userMap: map containing the new users id as key and the corresponding object as value
    *@param managerMap: map with key as a RoleName of the manager and value as User Role record of manager
    *return: void 
   */
	public static void createNewRole(Map<Id,User> userMap,Map<String,UserRole> managerMap){		
		Map<Id,UserRole> userIdUserRoleMap = new Map<Id,UserRole>();
		
		for(User user:userMap.values()){
			String roleName='';
			if (user.FirstName != null){
				 roleName =roleName+ user.FirstName;
			}
            roleName =roleName+ user.LastName; //lastName is a requiredfield
            if (user.EmployeeNumber != null) {
            	 roleName =roleName+ user.EmployeeNumber;
            }
            //an users ParentRoleid in the userrole object is his managers userRoleid
            if(user.Manager__c!=null){            	
            UserRole ur = new UserRole();
            ur.Name=roleName;
                String keyRoleName=user.Manager__r.Name.replaceAll(' ','')+user.Manager__r.EmployeeNumber; 
                UserRole managerUserRole=managerMap.get(keyRoleName);
                if(managerUserRole!=null){
                	ur.ParentRoleId=managerUserRole.Id;
            userIdUserRoleMap.put(user.Id,ur);
			
		}
            }
		}
		try{		
			if(userIdUserRoleMap.size()>0){				
			insert userIdUserRoleMap.values();
			}
			for(Id userId:userIdUserRoleMap.keySet()){
				userMap.get(userId).UserRoleId=userIdUserRoleMap.get(userId).Id;
			}
			if(userMap.size()>0){
			update userMap.values();
		}
		}
		catch (DMLException e){
     		for (UserRole ur : userIdUserRoleMap.values()) {
          			ur.addError('There was a problem inserting the userrole'+ur);
     		}
     		for (User user : userMap.values()) {
          			user.addError('There was a problem updating the user object'+user);
     		}
		}
	}
	
	/*Updates the UserParentRoleId of the user with that of the Managers userRoleId 
    *@param roleIdUserMap: map with key as id of userroleid and value as the user object 
    *@param managerMap: map with key as a RoleName of the manager and value as User Role record of manager
    *return: void 
    */
	public static void updateRoles(Map<Id,User> roleIdUserMap,Map<String,UserRole> managerMap){
		
		Map<Id,UserRole> userRoleMap = new Map<Id,UserRole>([Select id, Name,ParentRoleId from UserRole where id in:roleIdUserMap.keySet()]);
		
		List<UserRole> userRoleList = new List<UserRole>();
		for(Id id:roleIdUserMap.keySet()){
			UserRole userRole=userRoleMap.get(Id);
			User user= roleIdUserMap.get(Id);
			if(user.Manager__c!=null){				
				String keyRoleName=user.Manager__r.Name.replaceAll(' ','')+user.Manager__r.EmployeeNumber;				
			    UserRole managerUserRole=managerMap.get(keyRoleName);		
				//assuming that all the users are going to have a manager. Users without managers will not be processed.
				//The ParentRoleId of an userRole object is equal to the UserRoleId of the users Manager. So if they are not equal
				//then there has been a manager change.
			    if(managerUserRole!=null && userRole.ParentRoleId!=managerUserRole.Id){
					userRole.ParentRoleId=managerUserRole.Id;
					userRoleList.add(userRole);
				}
			}
		}
		try{
			if(userRoleList.size()>0){
			//update userRole object
				update userRoleList;	
			}
		}
		catch (DMLException e){
     		for (UserRole ur : userRoleList) {
          			ur.addError('There was a problem updating the user role object. The object details are:' +ur);
     		}
		}
	}
		
}