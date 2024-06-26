/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestPF_MyProfile_Unit {
	public static User u = new User();
	
	static testMethod void testOne() {
		try{
       		GenerateEnvironmentTest4.genScorecardMetricEducation();
       		GenerateEnvironmentTest4.PRIndividual.ownerId = GenerateEnvironmentTest4.PRIndividual.Employee__c;
       		update GenerateEnvironmentTest4.PRIndividual;	
		}catch(Exception e){
       		System.debug(e);
		}
    }
    
	static testMethod void testFour(){
		try{
			GenerateEnvironmentTest4.genScorecardMetricEducation();	
		}catch(Exception e){
			System.debug(e);
		}
       
       //System.runAs(GenerateEnvironmentTest4.employeeStandard)
       //{
       	  MyProfileController controller = new MyProfileController();
	      controller.getMyPerformanceReview();
       //}
    }
    
	static testMethod void testTwo(){
		User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
		System.runAs ( thisUser ) {
			u = GenerateEnvironmentTest3.getEmployeeStandard();
			u.Street = 'Street';
			u.Title = 'Title';
			u.City = 'City';
			u.Phone = 'Phone';
			u.Fax = 'Fax';
			u.Department = 'Department';
			u.FirstName= 'FirstName';
			u.LastName= 'LastName';
			u.Division='Division';
			u.EmployeeNumber='432343';
			u.ReviewManager__c= userInfo.getUserId();
			u.Manager__c= userInfo.getUserId(); 
					
			/* The following code is not working because the test uses some users which are inactive in config3
			
			GenerateEnvironmentTest4.genScorecardMetricEducation();
				  
			GenerateEnvironmentTest4.employeeStandard.Street = 'Street';
			GenerateEnvironmentTest4.employeeStandard.Title = 'Title';
			GenerateEnvironmentTest4.employeeStandard.City = 'City';
			GenerateEnvironmentTest4.employeeStandard.Phone = 'Phone';
			GenerateEnvironmentTest4.employeeStandard.Fax = 'Phone';
			GenerateEnvironmentTest4.employeeStandard.Department = 'Department';
			GenerateEnvironmentTest4.employeeStandard.FirstName = 'First Name';
			GenerateEnvironmentTest4.employeeStandard.LastName = 'Last Name';
			GenerateEnvironmentTest4.employeeStandard.Division = 'Division';
			GenerateEnvironmentTest4.employeeStandard.EmployeeNumber = '432432';
			GenerateEnvironmentTest4.employeeStandard.ReviewManager__c = userInfo.getUserId();
			GenerateEnvironmentTest4.employeeStandard.Manager__c = userInfo.getUserId();
			  
			update  GenerateEnvironmentTest4.employeeStandard;
			*/
			update u;
			
			MyProfileController controller = new MyProfileController();
			controller.getMyPerformanceReview();
			controller.getPerformanceReviewWrapper();
			controller.getMyV2MOMS();
			controller.getCurrentUser();
      
			MyProfileController.UserInner userInner = controller.getUserInner();
      
			userInner.getTitle();
			userInner.getStreet();
			userInner.getCity();
			userInner.getPhone();
			userInner.getFax();
			userInner.getReviewManager();
			userInner.getDepartment();
			userInner.getEmployeeNumber();
			userInner.getDivision();
			userInner.getManager();
			userInner.getEmployeeName();
			userInner.getEmployeeLastName();
				      
		}
	}
    
     static testMethod void testThree(){
     	  User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
		  System.runAs ( thisUser ) {
	    	  /*
	    	  GenerateEnvironmentTest4.genScorecardMetricEducation();
	 
		      GenerateEnvironmentTest4.employeeStandard.ReviewManager__c = null; 
		      GenerateEnvironmentTest4.employeeStandard.Manager__c = null;
		      
		      update  GenerateEnvironmentTest4.employeeStandard;
		      
		      */
		  //}
		  
		  //u.ReviewManager__c = null;
		  //u.Manager__c = null;
		  
		  //update u;
		  
		  //}
		  
		  u = GenerateEnvironmentTest3.getEmployeeStandard();
			u.Street = 'Street';
			u.Title = 'Title';
			u.City = 'City';
			u.Phone = 'Phone';
			u.Fax = 'Fax';
			u.Department = 'Department';
			u.FirstName= 'FirstName';
			u.LastName= 'LastName';
			u.Division='Division';
			u.EmployeeNumber='432343';
			u.ReviewManager__c= null;
			u.Manager__c= null;
			
		  update u;
		  	      
	      ReviewRating__c reviewRating = new ReviewRating__c();
	      reviewRating.OverallRating__c = 1;
	      reviewRating.PerformanceReview__c = GenerateEnvironmentTest4.PRIndividual.Id;
	      //reviewRating.Reviewer__c = GenerateEnvironmentTest4.employeeStandard.Id;
	      reviewRating.Reviewer__c = u.Id;
	      reviewRating.OwnerId = u.Id;
	      insert reviewRating;
		  }
          
          //System.runAs(GenerateEnvironmentTest4.employeeStandard)
	      System.runAs(u)
	      {
	       	  MyProfileController controller = new MyProfileController();
		      controller.getMyPerformanceReview();
		      controller.getPerformanceReviewWrapper();
		      controller.getMyV2MOMS();
		     
		      MyProfileController.UserInner userInner = controller.getUserInner();
		      
		      userInner.getTitle();
		      userInner.getStreet();
		      userInner.getCity();
		      userInner.getPhone();
		      userInner.getFax();
		      userInner.getReviewManager();
		      userInner.getDepartment();
		      userInner.getEmployeeNumber();
		      userInner.getDivision();
		      userInner.getManager();
		      userInner.getEmployeeName();
		      userInner.getEmployeeLastName();
		      
		      List<MyProfileController.PerformanceReviewWrapper> prWrapper = controller.getPerformanceReviewWrapper();
	      	  //prWrapper[0].getPerformanceReview();
	      	  //prWrapper[0].getRating();
		   
	      }
	
    }
}