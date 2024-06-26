/*
 * RelEng Perforce/RCS Header - Do not remove!
 *
 * $Author: gmalik $
 * $Change: 8556381 $
 * $DateTime: 2014/02/10 17:45:40 $
 * $File: //it/applications/peopleforce/prod/src/classes/MyTeamController.cls $
 * $Id: //it/applications/peopleforce/prod/src/classes/MyTeamController.cls#10 $
 * $Revision: #10 $
 */

/*
 * this class will take an account and assign it to a user.
*/

public with sharing class MyTeamController {
 
    Id                          currentUser;    //id to user
    List<DirectReportWrapper>   reports;        //users direct report
    String                      effectiveDate;  //Effective Date Selected
    String						quarter;
    PerformanceReview__c		performanceReview = new PerformanceReview__c();
    List<DirectReportWrapper>   selects;        //users selected    
    String                      error;          //error message
    List<SetupInfo>             errors;         //list of errors to user
    List<SetupInfo>             warnings;       //list of warnings to user
    public list<PerformanceReview__c>  reviews {get; set;}        //list of performancereview
    PerformanceReviewPeriod__c  periodAH;         //performance review period of performancereviewAdHoc
    PerformanceReviewPeriod__c  periodYE;         //performance review period of performancereviewYearEnd
    boolean                     showErrors;     //boolean show errors 
    boolean                     showWarnings;
    boolean                     firstLaunch;    //boolean first page launch
    Map<Id, V2MOM__c>           newv2moms; 
    MyTeamUtil                  util;       
    map<Id, Integer>            userTypePerformanceReview;
    map<Id, String>             employeeNameEmployee;
    String                      V2MOM_Type;     // V2MOM Type Individual by employee                    
    User                        myTeam = new User();    
    User						loggedUser = new User();   
    boolean 					isBack = false;   
    String 						aux;
    Date						duedate;
    List<Id>					employees = new List<Id>();
    public  boolean				isYearEnd {get; set;}
    /**
    * Constructor
    */
 
    public MyTeamController(){
    	
        if( System.currentPageReference().getParameters().get('id') == null || System.currentPageReference().getParameters().get('id')=='')
            currentUser = UserInfo.getUserId();
        else
            currentUser = System.currentPageReference().getParameters().get('id');

        showErrors = false;
        showWarnings = false;
        firstLaunch = true;
        
        loggedUser = [select id, Name, Profile.name, lastName, firstName from User where id =:userInfo.getUserId()];
        util = new MyTeamUtil();
        /*
        myTeam = [Select id, Name,lastName, firstName, street, city, Division, title, phone, department,fax, Manager__r.Name, employeeNumber, Manager__c, ReviewManager__r.Name, ReviewManager__c,Email
                  From User
                  Where id=:currentUser];
       */
       myTeam = [Select id, Name,lastName, firstName, street, city, Division, title, phone, Cost_Center__c,fax, Manager__r.Name, employeeNumber, Manager__c, ReviewManager__r.Name, ReviewManager__c,Email
                  From User
                  Where id=:currentUser];
                            
    }
	public boolean getAccessValidation(){
		boolean validatedAccess = true;
		If(loggedUser.Profile.id != PerformanceAccessUtil.getSystem_Administrator_Id() && loggedUser.id != currentUser && loggedUser.id!=myTeam.Manager__c )
		{
			validatedAccess = false;
		}
		return validatedAccess;
	}
	
	
    public MyTeamUtil getMyTeamUtil() {
        return util;
    }
    /**
    * Return a list of PerformanceReview where user is employee
    */
    public List<PerformanceReviewWrapper> getPerformanceReviews() {

        List<PerformanceReviewWrapper> temp = new List<PerformanceReviewWrapper>();

        for(PerformanceReview__c pr: [Select id, 
                                             name,
                                             PerformanceReviewPeriod__r.Name,
                                             Status__c,
                                             Quarter__c,
                                             DueDate__c,
                                             ReviewRating__r.CalculatedRating__c,
                                             ReviewRating__r.OverallRating__c
                                        From PerformanceReview__c
                                        Where employee__c=:currentUser
                                        Order By CreatedDate DESC, Name limit 1000]) {

            temp.add(new PerformanceReviewWrapper(pr));
        }

        return temp;
    }

    /**
    * Set current user
    */
    public void setCurrentUserId(Id userId){
        currentUser = userId;
    }

    /**
    * Return a list of User with manager equals user
    */
    public list<DirectReportWrapper> getDirectReports() {

        reports = util.getDirectReports(currentUser);
        return reports;
       
    }

	/**
	* Return a list of direct's report v2mom's
	*/
	public List<V2MOM__c> getV2MOMsDirectsReport()
	{
		return [Select Id, Name, Owner.id, Effective_Date__c, V2MOM_Type__c, Vision__c, Status__c From V2MOM__c Where Owner.Id =: currentUser order by Effective_Date__c desc, Name limit 1000]; 
		
	}
	
    /**
    * Return details to User
    */
    public User getMyTeam() {
      
        return myTeam;
    }
    
    
    public String getAux(){
    	return aux;	
    }
    public void setAux(String a){
    	aux = a;	
    }
    public User getLoggedUser(){
    	
    	return loggedUser;	
    }
  
  
  	/**
    * Return if the current user is a PCOMM or if it has as a manager someone with pcomm profile.
    */
	public Boolean getIsPCOMMOrFirstManager()
	{
		User currentUserO = [Select id, Manager__c, Profile.Name from User Where Id =: userInfo.getUserId()];
		User manager;
		
		if (currentUserO.Profile.Name == 'PCOMM')
		{
			return true;
		}
		
		if (currentUserO.Manager__c != null)
		{
			manager = [Select Id, Profile.Name, Manager__c from User where id =: currentUserO.Manager__c];
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
	
    public String getToday(){
    	String dueDateMM_dd_yyyy;
		Date dueDate = System.today(); 
		dueDateMM_dd_yyyy = dueDate.month()+ '/' + dueDate.day() + '/' + dueDate.year();
		return dueDateMM_dd_yyyy;
    }
    public String getLastName(){
        if(myTeam.lastName == null || myTeam.lastName == ''){
            return '-';
        }
        return myTeam.lastName; 
    }
    public String getFirstName(){
        if(myTeam.firstName == null || myTeam.firstName == ''){
            return '-';
        }
        return myTeam.firstName;    
    }
    public String getTitle(){
        if(myTeam.title == null || myTeam.title == ''){
            return '-';
        }
        return myTeam.title;    
    }
    public String getStreet(){
        if(myTeam.street == null || myTeam.street == ''){
            return '-';
        }
        return myTeam.street;   
    }
    public String getCity(){
        if(myTeam.city == null || myTeam.city == ''){
            return '-';
        }
        return myTeam.city; 
    }
    public String getPhone(){
        if(myTeam.phone == null || myTeam.phone == ''){
            return '-';
        }
        return myTeam.phone;    
    }
    public String getDepartment(){
        /*
        if(myTeam.department == null || myTeam.department == ''){
            return '-';
        }
        return myTeam.department;
        */
        if(myTeam.Cost_Center__c == null || myTeam.Cost_Center__c == ''){
        	return '-';
        }
        return myTeam.Cost_Center__c;
    }
    public String getFax(){
        if(myTeam.fax == null || myTeam.fax == ''){
            return '-';
        }
        return myTeam.fax;  
    }
    public String getReviewManager(){
        if(myTeam.ReviewManager__r.Name == null || myTeam.ReviewManager__r.Name == ''){
            return '-';
        }
        return myTeam.ReviewManager__r.Name;    
    }
     public String getManager(){
        if(myTeam.Manager__r.Name == null || myTeam.Manager__r.Name == ''){
            return '-';
        }
        return myTeam.Manager__r.Name;    
    }
      public String getEmployeeNumber(){
        if(myTeam.EmployeeNumber == null || myTeam.EmployeeNumber == ''){
            return '-';
        }
        return myTeam.EmployeeNumber;    
    }
      public String getDivision(){
        if(myTeam.Division == null || myTeam.Division == ''){
            return '-';
        }
        return myTeam.Division;    
    }
    public String getEmail(){
        if(myTeam.email == null || myTeam.email == ''){
            return '-';
        }
        return myTeam.email;    
    }
    public Date getDueDate(){
    	return duedate;
    }
    public void setDueDate(Date d){
    	duedate = d;
    }
    
    public void setIsYearEndShort(boolean state){
    	isYearEnd = state;
    }
    
    
      public List<String> getDefaultEffectiveDate()
	{
		List<String> effectiveDates = new List<String>();
		Boolean showNext = false;
			
		Schema.DescribeFieldResult fieldResult = V2MOM__c.Effective_Date__c.getDescribe();

		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		
	  	for( Schema.PicklistEntry f : ple)
	   	{
	      if (f.isDefaultValue())
	      {
	      	showNext = true;
	      	effectiveDates.add(f.getLabel());
	 	
	      }      
	      
	      if (showNext)
	      {
	      	  effectiveDates.add(f.getLabel());
	      }
	   }   
	  
	  
	  return effectiveDates;
	}
	
	public Boolean isInList(List<String> effectiveDates, String effectiveDate)
	{
		for (String s : effectiveDates)
		{
			if (effectiveDate == s)
			{
				return true;
			}
		}
		
		return false;
	}

	

	
	
	
    public String getThisYear(){
    	String currentYear = 'FY';
    	String year = String.valueOf(System.Now().Year() + 1);
    	
    	currentYear += year.substring(year.length() - 2,year.length());   	
    	return currentYear;
    }

    
    /**
    * Inner Class util without sharing
    */
    public without sharing class MyTeamUtil {
        private map<Id, V2MOM__c> v2momsForCloneWithoutSharing(list<Id> idsEmployees, String effectiveDate) {
        
            map<Id, V2MOM__c> v2moms = new map<Id, V2MOM__c>();
            
            for(V2MOM__c v: [SELECT Id, OwnerId,
                                         Name,
                                         Effective_Date__c,
                                         V2MOM_Type__c, 
                                         Vision__c, 
                                         RecordTypeId,
                                         Status_image__c, 
                                         Status__c, 
                                         Date_Submitted__c, 
                                         Date_Approved__c, 
                                         Locked__c 
                                 FROM V2MOM__c
                                 WHERE OwnerId in :idsEmployees
                                    and Effective_Date__c = :effectiveDate limit 1000]) 
                               {
                    v2moms.put(v.Id, v);
            }
            
            return v2moms;
        }
        
        
         // gets the profile of the current user
     	public String getUserProfile(User currentUser){
         	return currentUser.Profile.Name;    
     	}
        public boolean getIsOnlySysAdminProfile(User currentUser)
    	{
    		
    		return (getUserProfile(currentUser) == 'System Administrator'|| getUserProfile(currentUser)=='systemadministrator');
    	}

        
        private list<DirectReportWrapper> getDirectReports(Id currentUser) {
 
                List<DirectReportWrapper> reports = new List<DirectReportWrapper>();
        
                for(User u: [Select id, 
                                    name,
                                    Cost_Center__c,
                                    email,
                                    phone,
                                    Profile.Name,
                                    CompetencyGroupCode__c,
                                    ReviewTemplateCode__c,
                                    Manager__c,
                                    PCOMM__c,
                                    Division,
                                    (Select Id, Name,
                                            Status__c,
                                            DueDate__c,
                                            PerformanceReviewPeriod__r.Name,
                                            ReviewRating__r.CalculatedRating__c,
                                            ReviewRating__r.OverallRating__c
                                    from Reviews__r
                                    Order By CreatedDate Desc Limit 1)
                                From User
                                Where (Manager__c=:currentUser)
                                    and isActive = true]) {
        
                    reports.add(new DirectReportWrapper(u));
                    
                }
                
                return reports;
            }
            
         private List<PerformanceReview__c> getPerformanceReviewsWithoutSharing(List<Id> idsEmployees){
         
             return [Select Id, employee__c, CreatedDate, Quarter__c, DueDate__c
                                             From PerformanceReview__c
                                             Where employee__c in :idsEmployees
                                             Order by CreatedDate Desc, Name];
         }
         
         private List<PerformanceReviewPeriod__c> getPerformanceReviewPeriodAdHoc(String  effectiveDate){
 		                return				[	Select   Id,
                                                         Name,
                                                         Status__c,
                                                         OwnerId, 
                                                         StartDate__c,
                                                         EndDate__c,
                                                         Effective_Date__c,
                                                         V2MOM_Type__c
                                                From PerformanceReviewPeriod__c 
                                                Where Effective_Date__c = :effectiveDate
                                                    and V2MOM_Type__c =: 'Ad Hoc' limit 1];
         }
         
         private List<PerformanceReviewPeriod__c> getPerformanceReviewPeriodYearEnd(String  effectiveDate){
	         				return[Select  Id,
		                             Name,
		                             Status__c,
		                             OwnerId, 
		                             StartDate__c,
		                             EndDate__c,
		                             Effective_Date__c,
		                             V2MOM_Type__c
		                    From PerformanceReviewPeriod__c 
		                    Where Effective_Date__c = :effectiveDate
		                        and V2MOM_Type__c =: 'Year End Short' order By StartDate__c desc limit 1];
         }
        
    }
    
    /**
    * Inner Class for direct reports
    */
    public class DirectReportWrapper {

        User user;
        List<Id> idsDirectEmployees = new List<Id>();
        PerformanceReview__c performanceReview = new PerformanceReview__c();
        boolean performanceReviewAdHoc;
        Integer performanceReviewType;
        String dueDate;
		
        public DirectReportWrapper(User u) {
            user = u;
            performanceReviewAdHoc = false;
            performanceReviewType = 0;
        }

        public User getUser() {
            return user;
        }

		public List<Id> getIdsDirectEmployees()
		{
			return idsDirectEmployees;
		}
        public PerformanceReview__c getLatestReview() {
            if(user.Reviews__r == null)
                performanceReview = new PerformanceReview__c();
            else
                if(user.Reviews__r.size() == 0)
                    performanceReview = new PerformanceReview__c();
                else
                    performanceReview = user.Reviews__r[0];
            return performanceReview;
        }

        public String getCalculatedRating() {
            if(performanceReview.ReviewRating__r.CalculatedRating__c == null) return '-';

            String calc = String.valueOf(performanceReview.ReviewRating__r.CalculatedRating__c);

            if(calc.length() > 3)
                return calc.substring(0,4);
            else
                return calc;
        }
        
        public PerformanceReview__c getPerformanceReview(){
        	return performanceReview;	
        }
        
                
        public void setPerformanceReview(PerformanceReview__c per){
        	
        	performanceReview = per;	
        }
        public String getDueDateFormated(){
        	String dueDateMM_dd_yyyy = '';
			Date dueDate = PerformanceReview.DueDate__c; 
			if(dueDate != null){
				dueDateMM_dd_yyyy = dueDate.month()+ '/' + dueDate.day() + '/' + dueDate.year();
			}
			return dueDateMM_dd_yyyy;
        }
        
        public boolean getPerformanceReviewAdHoc() {
            return performanceReviewAdHoc;
        }
        
        public void setPerformanceReviewAdHoc(boolean prAdHoc) {
            performanceReviewAdHoc = prAdHoc;
        }
        
        public Integer getPerformanceReviewType() {
            return performanceReviewType;
        }
        
        public void setPerformanceReviewType(Integer prType) {
            performanceReviewType = prType;
        }
        
        public String getPerformanceReviewTypeName() {
            if (performanceReviewType == 0){
            	return Label.MyTeamController_ShortForm + ' ';
            }else{
            	if (performanceReviewType == 1){
            		return Label.MyTeamController_LongForm + ' ';
            	}else{
            		return 'Year End Short ';
            	}
            }
                
            
        }
        
        public boolean getIsLatestReviewIdNull(){
        	if(performanceReview!=null){
        		return performanceReview.Id == null;
        	}
        	return false;
        }
    }

    /**
    * Inner class Performance Reviews to current user
    */
    public class PerformanceReviewWrapper {

        PerformanceReview__c performanceReview;

        public PerformanceReviewWrapper(PerformanceReview__c pr){
            performanceReview = pr;
        }

        public PerformanceReview__c getPerformanceReview(){
            return performanceReview;
        }

        public String getOverallRating() {

            if(performanceReview.ReviewRating__r.OverAllRating__c == null) return null;

            return PAMUtil.getRatingLabel(performanceReview.ReviewRating__r.OverAllRating__c.intValue());
        }

        public String getCalculatedRating() {

            if(performanceReview.ReviewRating__r.CalculatedRating__c == null) return '-';

            String calc = String.valueOf(performanceReview.ReviewRating__r.CalculatedRating__c);

            if(calc.length() > 3)
                return calc.substring(0,4);
            else
                return calc;
        }
    }
    
   
    /**
    * Inner Class Setup Info
    */
    public class SetupInfo {
        User user;
        String message;

        public SetupInfo(User u, String m) {
            user = u;
            message = m;
        }

        public User getUser() {
            return user;
        }

        public String getMessage() {
            return message;
        }
    }
}