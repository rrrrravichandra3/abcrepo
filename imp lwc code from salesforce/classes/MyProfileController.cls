/*
 * RelEng Perforce/RCS Header - Do not remove!
 *
 * $Author: Joaquin Arcardini  $
 * $Change:  $
 * $DateTime: 14/10/2002 $
 * $File: MyProfileController.cls $
 * $Id:  $
 * $Revision:  $
 */

/*
 * This class will list all v2mom by user and performanceReview. Also will list user profile information
 * @author Joaquin Arcardini
*/
    
public with sharing class MyProfileController 
{
	private List<V2MOM__c> myV2moms;
	private List<PerformanceReview__c> myPerfromanceReviews;
	private User currentUser;
	private UserInner userInner = new UserInner();
	private List<PerformanceReviewWrapper> performanceReviewWrapper = new List<PerformanceReviewWrapper>();
	
	//constructor
	public MyProfileController()
	{
		currentUser = [select Id, Name, LastName, Profile.Name, Street, FirstName, City, Title, Phone, 
							Department, Fax, Email, ReviewManager__r.Name, EmployeeNumber, Division, Manager__r.Name  from User where id =: userInfo.getUserId()];
		myV2moms = [select Name, Effective_Date__c, V2MOM_Type__c, Vision__c, Status__c From V2MOM__c Where OwnerId =: userInfo.getUserId() order by Effective_Date__c desc, Name limit 1000] ;
		myPerfromanceReviews = [select Name, Status__c, PerformanceReviewPeriod__c, PerformanceReview__c.PerformanceReviewPeriod__r.Name, ReviewRating__r.CalculatedRating__c, ReviewRating__r.OverallRating__c  from PerformanceReview__c Where Employee__c =: userInfo.getUserId() Order By CreatedDate DESC, Name limit 1000];
		
		for (PerformanceReview__c pr:myPerfromanceReviews)
		{
			PerformanceReviewWrapper prw = new PerformanceReviewWrapper(pr);
			performanceReviewWrapper.add(prw);
		} 
		
		if (currentUser.Street != null && currentUser.Street != '' )
		{
			userInner.setStreet(currentUser.Street);
		}
		else
		{
			userInner.setStreet('-');	
		}
		
		if (currentUser.Title != null)
		{
			userInner.setTitle(currentUser.Title);
		}
		else
		{
			userInner.setTitle('-');	
		}
		
		if (currentUser.City != null)
		{
			userInner.setCity(currentUser.City);	
		}
		else
		{
			userInner.setCity('-');
		}
		
		if (currentUser.Phone != null)
		{
			userInner.setPhone(currentUser.Phone);
		}
		else
		{
			userInner.setPhone('-');
		}
		
		if (currentUser.Fax != null)
		{
			userInner.setFax(currentUser.Fax);
		}
		else
		{
			userInner.setFax('-');
		}
		
		if (currentUser.ReviewManager__r.Name != null)
		{
			userInner.setReviewManager(currentUser.ReviewManager__r.Name);
		}
		else
		{
			userInner.setReviewManager('-');
		}
		
		if (currentUser.Department != null)
		{
			userInner.setDepartment(currentUser.Department);
		}
		else
		{
			userInner.setDepartment('-');
		}
		
		if (currentUser.FirstName != null)
		{
			userInner.setEmployeeName(currentUser.FirstName);
		}
		else
		{
			userInner.setEmployeeName('-');
		}
		
		if (currentUser.LastName != null)
		{
			userInner.setEmployeeLastName(currentUser.LastName);
		}
		else
		{
			userInner.setEmployeeLastName('-');
		}
		
		if (currentUser.Manager__r.Name != null)
		{
			userInner.setManager(currentUser.Manager__r.Name);	
		}
		else
		{
			userInner.setManager('-');
		}
		
		if (currentUser.Division != null)
		{
			userInner.setDivision(currentUser.Division);
		}
		else
		{
			userInner.setDivision('-');
		}
		
		if (currentUser.EmployeeNumber != null)
		{
			userInner.setEmployeeNumber(currentUser.EmployeeNumber);
		}
		else
		{
			userInner.setEmployeeNumber('-');
		}
	} 
	
	public UserInner getUserInner()
	{
		return userInner;
	}
	
	public List<PerformanceReviewWrapper> getPerformanceReviewWrapper()
	{
		return performanceReviewWrapper;	
	}
	
	//return list of my v2mom
	public List<V2MOM__c> getMyV2MOMS()
	{
		return myV2moms;
	}
	
	//return list of my performance review
	public List<PerformanceReview__c> getMyPerformanceReview()
	{
		return myPerfromanceReviews;
	} 
	
	public User getCurrentUser()
	{
		return currentUser;
	}
	
	public class PerformanceReviewWrapper
	{
		private PerformanceReview__c performanceReview;
		private String rating = '';
		private Double reviewRating;
		public PerformanceReviewWrapper(PerformanceReview__c per)
		{
			performanceReview = per;	
			if (performanceReview.ReviewRating__r.OverallRating__c != null)
			{
				rating = PAMUtil.getRatingLabel(performanceReview.ReviewRating__r.OverallRating__c.intValue());
				decimal check = performanceReview.ReviewRating__r.CalculatedRating__c;
				reviewRating=check.divide(1,2, System.RoundingMode.HALF_UP);
			
			}
			else
			{
				rating = '';
			}
			
			
		}
		
		public PerformanceReview__c getPerformanceReview()
		{
			return performanceReview;
		}
		
		public String  getRating()
		{
			return rating;
		}
		
		public Double getReviewRating(){
			return reviewRating;
		}
		
		public boolean getIsRatingNull(){
			return rating=='';
		}
		
	}
	
	public class UserInner
	{
		
		private String title;
		private String street;
		private String city;
		private String phone;
		private String fax;
		private String reviewManager;
		private String department;
		private String employeeNumber;
		private String division;
		private String manager;
		private String employeeName;
		private String employeeLastName;
		
		public String getTitle()
		{
			return title;
		}
		
		public void setTitle(String value)
		{
			title = value;			
		}
		
		public String getStreet()
		{
			return street;
		}
		
		public void setStreet(String value)
		{
			street = value;
		}
		
		public String getCity()
		{
			return city;
		}
		
		public void setCity(String value)
		{
			city = value;
		}
		
		public String getPhone()
		{
			return phone;
		}
		
		public void setPhone(String value)
		{
			phone = value;	
		}
		
		public String getFax()
		{
			return fax;
		}
		
		public void setFax(String value)
		{
			fax = value;	
		}
		
		public String getReviewManager()
		{
			return reviewManager;
		}
		
		public void setReviewManager(String value)
		{
			reviewManager = value;	
		}
		
		public String getDepartment()
		{
			return department;
		}
		
		public void setDepartment(String value)
		{
			department = value;	
		}
		
		public String getEmployeeNumber()
		{
			return employeeNumber;	
		}
		
		public void setEmployeeNumber(String value)
		{
			employeeNumber = value;
		}
		
		public String getDivision()
		{
			return division;
		}
		
		public void setDivision(String value)
		{
			division = value;
		}
		
		public String getManager()
		{
			return manager;
		}
		
		public void setManager(String value)
		{
			manager = value;
		}
		
		public String getEmployeeName()
		{
			return employeeName;
		}
		
		public void setEmployeeName(String value)
		{
			employeeName = value;	
		}
		
		public String getEmployeeLastName()
		{
			return employeeLastName;
		}
		
		public void setEmployeeLastName(String value)
		{
			employeeLastName = value;	
		}
	}
}