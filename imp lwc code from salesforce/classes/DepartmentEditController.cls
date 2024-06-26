/*
 * RelEng Perforce/RCS Header - Do not remove!
 *
 * $Author:  $
 * $Change:  $
 * $DateTime:  $
 * $File:  $
 * $Id:  $
 * $Revision:  $
 */

/*
 * this class will take an account and assign it to a user.
 * @author Mike Fullmore - 4/2/2009
*/

public with sharing class DepartmentEditController {
	
	//Department__c department = new Department__c();
	 TF2_Department__c department = new TF2_Department__c();
	 
	 public DepartmentEditController (ApexPages.StandardController stdController) {
	 	  //Department__c departmentId;
	   	  TF2_Department__c departmentId;
	   	  //departmentId = (Department__c)stdController.getSubject();
	   	  departmentId = (TF2_Department__c)stdController.getSubject();
	   	  //department = [Select d.Name, d.Owner.Name, d.OwnerId, d.Id, d.ExcludeESBP__c From Department__c d where d.Id =:departmentId.Id];
	  		department = [Select d.Name, d.Owner.Name, d.OwnerId, d.Id, d.Exclude_ESBP__c From TF2_Department__c d where d.Id =:departmentId.Id];
	  }
	  
	  public TF2_Department__c getDepartment(){
	  	return department;
	  }
      
      
      public void save() {
		update department;
		
	  }
	  
	  
	  public void saveAndNew(){
	  	
	  	update department;
	  
	  }
	  
	  public String getIdPrefix()
	  {
	  	String idPrefix = department.id;
	  	return idPrefix.substring(0, 3);
	  }
	  
	  public List<User> getUsers(){
	  	List<User> users = new List<User>();
	  	//users = [Select Id, Name, Department from User where Department =: department.Name ];
	 	users = [Select Id, Name, Cost_Center__c from User where Cost_Center__c =: department.Name ];
	 	
	 	return users;
	  }
}