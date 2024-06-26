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

public with sharing class EmployeeHandbookEditController {
 

	 Employee_Handbook__c employeeHandbook = new Employee_Handbook__c();
	 public EmployeeHandbookEditController (ApexPages.StandardController stdController) {
	 	  Employee_Handbook__c employeeHandbookId;
	   	  employeeHandbookId = (Employee_Handbook__c)stdController.getSubject();
	   	  employeeHandbook = [Select Id, Name, Status__c, Due_Date__c, Fiscal_Year__c From Employee_Handbook__c Where Id =: employeeHandbookId.Id];
	  }
	  
	  public Employee_Handbook__c getEmployeeHandbook(){
	  	return employeeHandbook;
	  }
       
       
      public PageReference save() {
      	V2MOM_Util.cancelUpdateInHandBook = false;
		update employeeHandbook;
		V2MOM_Util.cancelUpdateInHandBook = true;
		
		PageReference employeeHandbookPage = Page.EmployeeHandbookEdit;
        employeeHandbookPage.getParameters().put('id', employeeHandbook.id);
        employeeHandbookPage.setRedirect(true);
        return employeeHandbookPage;
        
	  }
	  
	  
	  public void saveAndNew(){
	  	
	  	update employeeHandbook;
	  
	  }
	  
	  public String getIdPrefix()
	  {
	  	String idPrefix = employeeHandbook.id;
	  	return idPrefix.substring(0, 3);
	  }
 
}