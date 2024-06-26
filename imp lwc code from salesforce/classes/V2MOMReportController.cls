/*
 * RelEng Perforce/RCS Header - Do not remove!
 *
 * $Author: gmalik $
 * $Change: 1798735 $
 * $DateTime: 2011/06/06 10:48:26 $
 * $File: //it/applications/peopleforce/prod/src/classes/V2MOMReportController.cls $
 * $Id: //it/applications/peopleforce/prod/src/classes/V2MOMReportController.cls#3 $
 * $Revision: #3 $
 */

/*
 * This class will list all v2mom filter by effective date and "My Entire Team" or "My Directs Reports".
 * @author Joaquin Arcardini
*/
    
public with sharing class V2MOMReportController {


	private String effectiveDate = '';
	private String hierarchy = '';
	private String v2momType = '';
	public User currentUser{get;set;}
	private List<User> allManagerByPcomm;
	private String pcomm;
	private List<Id> idUsersWithV2MOM = new List<Id>();
	private List<User> usersWithNOV2MOM = new List<User>();
	private List<User> usersInHirarchy = new List<User>();
	private List<CustomV2MOM> customV2MOMs = new List<CustomV2MOM>();
	private Map<Id, User> employeeMap = new Map<Id, User>();
	private String isInESBP;
	private String manager;
	private String sortedBy;
	private Id lastManager;
	private Set<Id> allUsers = new Set<Id>();
	private List<User> userToAdd = new List<User>();
	private Integer currentProccessItem = 0;
	private List<User> managerCurrentUsers;
	private String allEmployessHidden;
	private String allEmployessHiddenTwo;
	private String userId;
	
	
	//constructor
	public V2MOMReportController()
	{ 
		effectiveDate = System.currentPageReference().getParameters().get('effectiveDate');
		hierarchy = System.currentPageReference().getParameters().get('hierarchy');
		v2momType = System.currentPageReference().getParameters().get('v2momType');
		isInESBP = System.currentPageReference().getParameters().get('isInESBP');
		manager = System.currentPageReference().getParameters().get('manager');
		sortedBy = System.currentPageReference().getParameters().get('sortedBy');
		pcomm = System.currentPageReference().getParameters().get('pcomm');
		allEmployessHidden = System.currentPageReference().getParameters().get('allEmployessHidden');
		allEmployessHiddenTwo =  System.currentPageReference().getParameters().get('allEmployessHiddenTwo');
		//userId = System.currentPageReference().getParameters().get('userId');
		if (manager == null  || manager  == '')
		{
			currentUser = [Select Id, ReviewManager__c, Name, Manager__c , Profile.Name, PCOMM__c , Manager__r.Name, Department, Division from User where Id =: userInfo.getUserId()];
			managerCurrentUsers = [Select ReviewManager__c, Name, Manager__c , PCOMM__c , Manager__r.Name, Department, Division from User where Manager__c =: userInfo.getUserId()];	
		}
		else
		{
			
			if (manager != 'All')
			{
				currentUser = [Select Id, ReviewManager__c, Name, Manager__c , Profile.Name, PCOMM__c, Manager__r.Name, Department, Division  from User where Id =: manager];
			}
			else
			{
    			
		    	currentUser = [Select Id, ReviewManager__c, Name, Manager__c , Profile.Name, PCOMM__c, Manager__r.Name, Department, Division  from User where Id =: pcomm];
				
			}	
		}
	
	}
	
	public String getUserId(){
		return this.userId;
	}	
	public void setUserId(String value){
		this.userId = value;
	}
	public String getAllEmployessHidden()
	{
		return allEmployessHidden;
	}
	
	public void setAllEmployessHidden(String value)
	{
		allEmployessHidden = value;
	}
	
	public String getAllEmployessHiddenTwo()
	{
		return allEmployessHiddenTwo;
	}
	
	public void setAllEmployessHiddenTwo(String value)
	{
		allEmployessHiddenTwo = value;
	}
	
	public User getCurrentUser()
	{
		return currentUser;
	}  
	
	public String getManager()
	{
		return manager;
	}
	
	public String getPcomm()
	{
		return pcomm;
	}
	public String getSortedBy()
	{
		return sortedBy;
	}
	
	public String getHierarchy()
	{
		return hierarchy;
	}

	public List<User> getUsersWithNoV2MOM()
	{
		return usersWithNOV2MOM;
	} 
	
	public void setUsersWithNoV2MOM(List<User> value)
	{
		usersWithNOV2MOM = value;	
	}
	
	public String getEffectiveDate()
	{
		return effectiveDate;
	}
	
	public String getV2MOMType()
	{
		return v2momType;
	}
	public void setV2MOMType(String value)
	{
		v2momType = value;
	}
	
	/**
    * Return if the current user is a PCOMM or if it has as a manager someone with pcomm profile.
    */
	public Boolean getIsPCOMMOrFirstManager()
	{
		User manager;
		
		if (currentUser.Profile.Name == 'PCOMM')
		{
			return true;
		}
		
		if (currentUser.Manager__c != null)
		{
			manager = [Select Id, Profile.Name from User where id =: currentUser.Manager__c];
		}
		else
		{
			return false;
		}
		
		if (manager.Profile.Name == 'PCOMM')
		{
			return true;
		}
		
		return false;
	}
	/**
    * @return the percent of v2mom in not submited status
    */
	public Double getPercentNotSubmitted()
	{
		return getPercentV2MOMByStatus('Not Submitted');
	}
	
	/**
    * @return the percent of v2mom in approved status
    */
	public Double getPercentApproved()
	{
		return getPercentV2MOMByStatus('Approved');
	}
	
	/**
    * @return the percent of v2mom in Not Created status
    */
	public Double getPercentNotCreated()
	{
		return getPercentV2MOMByStatus('Not Created');
	}
	
	/**
    * @return the percent of v2mom in Pending Approval status
    */
	public Double getPercentPendingApproval()
	{
		return getPercentV2MOMByStatus('Pending Approval');
	}
	
	/**
    * @return the percent of v2mom in Rejected status
    */
	public Double getPercentRejected()
	{
		return getPercentV2MOMByStatus('Rejected');
	}
	
	/**
    * @return the percent of v2mom in Rejected status
    */
	public Double getPercentRequiresReApproval()
	{
		return getPercentV2MOMByStatus('Requires Re-Approval');
	}
	
	/**
	* @param status to filter the v2moms
    * @return the percent of v2mom in particular status
    */
	public Double getPercentV2MOMByStatus(String status)
	{
		Integer allV2MOM = customV2MOMs.size() + usersWithNOV2MOM.size();
		Double v2momNumberByStatus = getNumberV2MOMByStatus(status);
		
		if (status == 'Not Created')
		{
			v2momNumberByStatus = usersWithNOV2MOM.size();
		}
		
		if (allV2MOM != 0)
		{
			Decimal temp = (v2momNumberByStatus * 100);
			return temp.divide(allV2MOM, 2 );
		}
		else
		{
			return 0;
		}
	}
	
	/**
    * @return the number v2mom in not submitted status
    */
	public Long getNumberV2MOMNotSubmitted()
	{
		return getNumberV2MOMByStatus('Not Submitted');
	}
	
	/**
    * @return the number v2mom in approved status
    */
	public Long getNumberV2MOMApproved()
	{
		return getNumberV2MOMByStatus('Approved');
	}
	
	/**
    * @return the number v2mom in not created status
    */
	public Long getNumberV2MOMNotCreated()
	{
		return usersWithNOV2MOM.size();
	}
	
	/**
    * @return the number v2mom in Pending Approval status
    */
	public Long getNumberV2MOMPendingApproval()
	{
		return getNumberV2MOMByStatus('Pending Approval');
	}
	
	/**
    * @return the number v2mom in Rejected status
    */
	public Long getNumberV2MOMRejected()
	{
		return getNumberV2MOMByStatus('Rejected');
	}
	
	/**
    * @return the number v2mom in Rejected status
    */
	public Long getNumberV2MOMRequiresReApproval()
	{
		return getNumberV2MOMByStatus('Requires Re-Approval');
	}
	
	/**
	* @param vType the type to filter v2moms
    * @return the number of v2mom of the one particular type
    */
	public Long getNumberV2MOMByStatus(String status)
	{
		Long v2momNumber = 0;
		
		for (CustomV2MOM cv: customV2MOMs )
		{
			
			if (cv.getV2MOM().Status__c == status)
			{
				v2momNumber++;
			}	
			
		}	
		
		return v2momNumber;
	}
	/**
    * @return all V2MOM filter by effectiveDate and hierarchy
    */
	public List<CustomV2MOM> getAllV2MOMByFYAndHierarchy()
	{
		List<V2MOM__c> v2moms;
		V2MOM__c v2mom;
		User v2momOwner;
		List<CustomV2MOM> customV2MOMs = new List<CustomV2MOM>();
		List<CustomV2MOM> customV2MOMsToRet = new List<CustomV2MOM>();
		List<V2MOM__c> v2momOrder = new List<V2MOM__c>();
		
		idUsersWithV2MOM = new List<Id>();
		
		if (v2momType == 'All')
		{
			
			if (sortedBy == '' || sortedBy == null)
			{
				v2moms = [Select Id, Name, Status__c, Owner.Name, V2MOM_Type__c From V2MOM__c where OwnerId in :usersInHirarchy 
							and Effective_Date__c =: effectiveDate order by Owner.Id, Name limit 999  ];
			}
		}			
		else
		{
			v2moms = [Select Id, Name, Status__c, Owner.Name, V2MOM_Type__c From V2MOM__c where OwnerId in :usersInHirarchy 
						and Effective_Date__c =: effectiveDate and V2MOM_Type__c =: v2momType order by Owner.Id, Name limit 999 ];	
		}

		
		for (Integer i=0 ; i < v2moms.size() ; i++ )
		{  
			if (i != 0) 
			{
				v2mom = v2moms[i];
				v2momOwner = employeeMap.get(v2moms[i].OwnerId);
			
				CustomV2MOM customV2MOM = new CustomV2MOM(v2mom,v2momOwner);
				
				if (v2moms[i - 1].OwnerId == v2moms[i].OwnerId)
				{
					customV2MOM.setFirstInEmployee(false);
					
				}
				
				idUsersWithV2MOM.add(v2mom.OwnerId);
				customV2MOMs.add(customV2MOM);
			}
			else
			{
				v2mom = v2moms[i];
				v2momOwner = employeeMap.get(v2mom.OwnerId);
				CustomV2MOM customV2MOM = new CustomV2MOM(v2mom,v2momOwner );
				
				customV2MOMs.add(customV2MOM);
				
				idUsersWithV2MOM.add(v2mom.OwnerId);
			}
		}
		
		return customV2MOMs; 
	}
	
	public List<User> getEmployeesAux(){
		String logUserId = currentUser.Id;
		List<User> employees = new List<User>();
		getEmployeesAux2(logUserId, employees);
		User u = new User();
		integer i = 0;
		getEmployeesAux3(u,employees, i); 
		return employees;
	}
	
	public void getEmployeesAux2(String logUserId, List<User> employees){
		List<User> aux = [Select Name, Id, Manager__c From User Where Manager__c =: logUserId And Employee_Type__c Not in ('Intern', 'Test', 'Contractor') limit 4];
		for (User u : aux ){
			employees.add(u);
		}
				 
	}
	public void getEmployeesAux3(User u, List<User> employees, integer i){
		try{
			if (i < employees.size()){
				u = employees[i];
				if(u.Manager__c != null && u.Manager__c != ''){
				
						if (u.Id != null && u.Id != ''){
							getEmployeesAux2(u.Id, employees);	
						}
										
				
				
				}
				if(employees.size() > 0){
					u = new User();
					getEmployeesAux3(u, employees, i++);
							
				}
				
			}
		}catch(Exception e){
			System.debug(e);
		}
		
	}
	
	
	public List<User> getEmployeesFirstLevel()
	{
		return [Select Id, Name from User where PCOMM__c =: Pcomm  and (Profile.Name = 'Support Manager' or Profile.Name = 'CSM Manager' or Profile.Name = 'Education Manager' or Profile.Name = 'Manager')	order by Name ];
	}
	
	/**
	* set the var to order v2mmoms by department
	**/
	public void orderByDepartment()
	{
		
		if (sortedBy == 'Department')
		{
			sortedBy = 'DepartmentDESC';
		}
		else
		{
			sortedBy = 'Department';
		}
		
		usersWithNOV2MOM = getUserNotWithV2MOM(idUsersWithV2MOM,usersInHirarchy);
	}
	
	/**
	* set the var to order v2mmoms by status
	**/
	public void orderByStatus()
	{
		
		if (sortedBy == 'Status')
		{
			sortedBy = 'StatusDESC';
		}
		else
		{
			sortedBy = 'Status';
		}
		
		usersWithNOV2MOM = getUserNotWithV2MOM(idUsersWithV2MOM,usersInHirarchy);
	}
	
	/**
	* set the var to order v2mmoms by Manager
	**/
	public void orderByManager()
	{
		if (sortedBy == 'Manager')
		{
			sortedBy = 'ManagerDESC';
		}
		else
		{
			sortedBy = 'Manager';
		}
		
		usersWithNOV2MOM = getUserNotWithV2MOM(idUsersWithV2MOM,usersInHirarchy);
	}
	/**
    * @return User that not have a v2mom for the effective date
    * @param userWithV2MOM users with a v2mom
    * @param userInHirarchy all users in hirarchy
    **/
	public List<User> getUserNotWithV2MOM(List<Id> usersWithV2MOM, List<User> userInHirarchy)
	{
		Boolean exist = false;
		List<User> usersWithNoV2MOM = new List<User>();
		Map<Id, Id> idsMap = new Map<Id, Id>();
		
		for (Id id: usersWithV2MOM)
		{
			idsMap.put(id , id);
		}
		
		for (User u : userInHirarchy)
		{
			if (idsMap.get(u.Id) == null)
			{
				usersWithNoV2MOM.add(u);	
			}
			
			exist = false;
		}
		
		return usersWithNoV2MOM;
	}
	 
   
     
  

	/**
    * @return all the users in the hierarchy page parameter
    */
	public List<User> getUserInHierarchy()
	{
		List<User> userInHierarchy = new List<User>();
		List<User> userInHierarchyUnique = new List<User>();
		Set<Id> userInHierarchySet = new Set<Id>();
		Set<Id> managers = new Set<Id>();
		List<User> directsReports = new List<User>();
		User secondManager;
		User thirdManager;
		
		if (manager == null || manager == '')
		{
			if (manager == 'All')
			{
				directsReports = [Select Id, Name, Manager__r.Name, Manager__c,  Department, Division from User Where Employee_type__c  not in ('Intern', 'Contractor', 'Test') and Manager__c in :allManagerByPcomm ];				
			}
			else
			{
				directsReports = [Select Id, Name, Manager__r.Name, Manager__c,  Department, Division from User Where Employee_type__c  not in ('Intern', 'Contractor', 'Test') and Manager__c =: currentUser.Id];		
				
			}	
		}
		else
		{
			if (manager == 'All')
			{
				directsReports = [Select Id, Name, Manager__r.Name, Manager__c,  Department, Division from User Where Employee_type__c  not in ('Intern', 'Contractor', 'Test') and Manager__c in :allManagerByPcomm];
			
			}
			else
			{
				directsReports = [Select Id, Name, Manager__r.Name, Manager__c,  Department, Division from User Where Employee_type__c  not in ('Intern', 'Contractor', 'Test')and Manager__c =: currentUser.Id];
			}
		
		}
		
		
		
		if (hierarchy == 'MyEntireTeam')
		{
			if (manager == 'All')
			{ 
				for (User u : allManagerByPcomm)
				{
					List<User> tempList = new List<User>();
					
					//List<User> usersTemp = getEmployeeBelow(u,tempList,managers);
					List<User> usersTemp = new List<User>();
					
					userInHierarchy.addAll(usersTemp);
					
				}
			}
			else
			{
				userInHierarchySet = getEmployeeBelow(currentUser);
				userInHierarchy = [Select Id, Manager__r.Name, Department, Division, Name from User Where id in: userInHierarchySet];	
			}
			
		}
		
		for (Integer i = 0 ; i < userInHierarchy.size() ; i++)
		{
			User u = userInHierarchy[i];
			
			if (i != 0)
			{
				if (u.Id != userInHierarchy[i-1].Id )
				{
					employeeMap.put(u.Id, u);
					userInHierarchyUnique.add(u);
				}
			}
			else
			{
					employeeMap.put(u.Id, u);
					userInHierarchyUnique.add(u);
			}
		}
			
		if (hierarchy == 'MyDirectReports')
		{
			return directsReports;
		}
	
		return userInHierarchy; 
	}
	
     
 	
     public PageReference showReport()
     {
     	PageReference report = Page.V2MOMReportToExcel;
	
		report.getParameters().put('effectiveDate', effectiveDate);
		report.getParameters().put('hierarchy', hierarchy);
		report.getParameters().put('v2momType', v2momType);
		report.getParameters().put('isInESBP', isInESBP);
		report.getParameters().put('manager', manager);
		report.getParameters().put('sortedBy', sortedBy);
		report.getParameters().put('pcomm', pcomm);
		
		if (hierarchy == 'MyEntireTeam')
		{
			report.getParameters().put('allEmployessHidden', allEmployessHidden);
			report.getParameters().put('allEmployessHiddenTwo', allEmployessHiddenTwo);	
		}
		
		return report;
     }
     
	/**
	* @param user the manager
	* @param List<User> allUser in hirarchy
    * @return all the users in the hierarchy below the manager
    */
	public Set<Id> getEmployeeBelow(User user)
	{
		
		List<User> employees;
		employees = [select Id, Name, Manager__c From User Where Employee_type__c  not in ('Intern', 'Contractor', 'Test') and  Manager__c =: user.Id];	
			
		for (User u:employees)
		{
			if (u.Manager__c != null)
			{
				
				for (User us:employees)
				{
					allUsers.add(us.Id);
				}
					
				getEmployeeBelow(u);
			}
		}
	
		return allUsers;
	}
	
	public Integer getManagerCurrentUsersCount()
	{
		return managerCurrentUsers.size();
	}
	
	public void processDirectReports()
	{
		List<String> ids = allEmployessHidden.split(';');
		List<String> idsTwo = allEmployessHiddenTwo.split(';');
		
		Set<String> userInHierarchySet = new Set<String>();
		
		for (String s: ids)
		{
			if (userInHierarchySet.size() < 999 )
			{ 
				if (s != null && s != '')
				{
					userInHierarchySet.add(s);
				}
			}
		
		}
	
		for (String s: idsTwo)
		{
			if (userInHierarchySet.size() < 999 )
			{
				if (s != null && s != '')
				{
					userInHierarchySet.add(s);
				}
			}

		}
		
		usersInHirarchy = [Select Id, Manager__r.Name, Department, Division, Name from User Where Employee_type__c  not in ('Intern', 'Contractor', 'Test') and id in: userInHierarchySet and isActive = true];
		
		for (Integer i = 0 ; i < usersInHirarchy.size() ; i++)
		{
			User u = usersInHirarchy[i];
			
			if (i != 0)
			{
				if (u.Id != usersInHirarchy[i-1].Id )
				{
					employeeMap.put(u.Id, u);
				}
			}
			else
			{
					employeeMap.put(u.Id, u);
			}
		}
		
		customV2MOMs = getAllV2MOMByFYAndHierarchy();
		usersWithNOV2MOM = getUserNotWithV2MOM(idUsersWithV2MOM,usersInHirarchy);
	}
    
    public void processOnlyDirectReports()
    {
    	if (manager == 'All')
    	{
    		
			List<String> ids = allEmployessHidden.split(';');
			List<String> idsTwo = allEmployessHiddenTwo.split(';');
			
			Set<Id> userInHierarchySet = new Set<Id>();
			
			for (String s: ids)
			{
				if (userInHierarchySet.size() < 999 )
				{ 
					if (s != '')
					{
						userInHierarchySet.add(s);
					}
				}
			
			}
		
			for (String s: idsTwo)
			{
				if (userInHierarchySet.size() < 999 )
				{
					if (s != '')
					{
						userInHierarchySet.add(s);
					}
				}
	
			}
			
			usersInHirarchy = [Select Id, Manager__r.Name, Department, Division, Name from User Where Employee_type__c  not in ('Intern', 'Contractor', 'Test') and id in: userInHierarchySet and isActive = true];
			
			for (Integer i = 0 ; i < usersInHirarchy.size() ; i++)
			{
				User u = usersInHirarchy[i];
				
				if (i != 0)
				{
					if (u.Id != usersInHirarchy[i-1].Id )
					{
						employeeMap.put(u.Id, u);
					}
				}
				else
				{
						employeeMap.put(u.Id, u);
				}
			}
			
			customV2MOMs = getAllV2MOMByFYAndHierarchy();
			
    	}
    	else
    	{
    		usersInHirarchy = [Select Id, Manager__r.Name, Department, Division, Name from User Where Employee_type__c  not in ('Intern', 'Contractor', 'Test') and Manager__c =: currentUser.Id and isActive = true];
    		
    		
			for (Integer i = 0 ; i < usersInHirarchy.size() ; i++)
			{
				User u = usersInHirarchy[i];
				
				if (i != 0)
				{
					if (u.Id != usersInHirarchy[i-1].Id )
					{
						employeeMap.put(u.Id, u);
					}
				}
				else
				{
						employeeMap.put(u.Id, u);
				}
			}
			
				customV2MOMs = getAllV2MOMByFYAndHierarchy();
				usersWithNOV2MOM = getUserNotWithV2MOM(idUsersWithV2MOM,usersInHirarchy);	
			
    	}
    	
		
    }
    
    
    public void processUsersWithoutV2MOM()
    {
    	usersWithNOV2MOM = getUserNotWithV2MOM(idUsersWithV2MOM,usersInHirarchy);
    }
    
    public Integer getCurrentProccessItem()
    {
    	return currentProccessItem;
    }
/*
 * This class will hold v2mom custom object to list only first employee name if there is more than 
 * one v2mom per employee listed.
 * @author Joaquin Arcardini
*/	
	public with sharing class CustomV2MOM
	{
		private V2MOM__c v2mom;
		private Boolean firstInEmployee;
		private User V2MOMOwner;
		
		//Constructor
		public CustomV2MOM(V2MOM__c  value, User owner)
		{
			v2mom = value;
			v2momOwner = owner ;
			firstInEmployee = true;
		}
		
		public User getV2MOMOwner()
		{
			return V2MOMOwner;
		}
		public V2MOM__c getV2MOM()
		{
			return v2mom;
		}
		
		public void setV2MOM(V2MOM__c value)
		{
			v2mom = value;
		}
		
		public Boolean getFirstInEmployee()
		{
			return firstInEmployee;	
		}
		
		public void setFirstInEmployee(Boolean value)
		{
			firstInEmployee = value;
		}
	}
}