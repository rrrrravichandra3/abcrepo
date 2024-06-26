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
 * @author 
*/ 
 
public with sharing class PerformanceOverallController {
    
    PerformanceReview__c    		performanceReview;
    list<Method>            		methods;
    list<Competency>        		competencies;
    AdditionalComment__c    		currentComment;
    ReviewRating__c         		reviewRating;
    V2MOM__c                		v2mom;
    list<Value>             		values;
    list<Method>            		methods_withoutvalue; 
    list<Method>            		allMethods;
    ScorecardSupportReview__c 		customerSatisfaction;
    ScorecardSupport 				scorecardSupport;
    List<ScorecardSupportReview__c> listScorecard;
    User 							currentUser;
    User 							scorecardTypeProfile;
    String 							userInf = UserInfo.getUserId();
    String 							v2momType = '';
    boolean 						isPCOMMLikeViewProfile;
    PerformanceAccessUtil 			accessUtil;
    Id	 							performanceRevId;
    OverallUtil 					util;
	boolean 						isScorecardProfile;
	boolean		 					isSaving = false; // to avoid double comments
    
    public class SharingException extends Exception {}

    /*
     * Constructor
     */
    public PerformanceOverallController(){
    	constructor();
    }
    
    public PerformanceOverallController(String uId){
    	userInf = uId;
    	constructor();
    }
    	
    public void constructor(){
    	performanceRevId = System.currentPageReference().getParameters().get('id');
		
    	// checks the id of the performance is not null
        if(performanceRevId != null) {
			util = new OverallUtil();  	
			// checks the profile of the user
	        currentUser = [Select Id, u.Profile.Name, u.ProfileId From User u where id = :userInf];   	
			// gets the performance review completely
	        performanceReview = getPerformanceReviewWithoutSharing(performanceRevId);			
	        if(performanceReview == null) 
	        	throw new SharingException(Label.PerformanceV2MOMAssessmentController_exception1);

			if ((performanceReview.V2MOM__r != null) && (performanceReview.V2MOM__r.V2MOM_Type__c != null))
				v2momType = performanceReview.V2MOM__r.V2MOM_Type__c;

			// gets the profile of the employee to see what kind of scorecard it might have
        	scorecardTypeProfile = [Select u.Profile.Name, u.ProfileId From User u where id = :performanceReview.Employee__c];   
    		
    		// access class for permissions
            accessUtil = new PerformanceAccessUtil(performanceReview, currentUser, scorecardTypeProfile);	
			// uses the information of the performance review to check if the profile of the
			// current user should see data filtered by sharing rules or filtered manually
			isPCOMMLikeViewProfile = accessUtil.getPCOMMLikeViewProfile();
			
			if (!isPCOMMLikeViewProfile)			
	        	performanceReview = util.getPerformanceReviewWithSharing(performanceRevId);
			
	        if(performanceReview == null) 
	        	throw new SharingException(Label.PerformanceV2MOMAssessmentController_exception2);
	
			// checks the v2mom of the performance review
	        if (performanceReview.V2MOM__c != null)
	            v2mom = [Select Locked__c, parentId__c From V2MOM__c Where id=:performanceReview.V2MOM__c];
	        else
	            v2mom = new V2MOM__c();
			
	        // gets overall data of the performance
	        if(performanceReview.ReviewRating__c != null){
	        	if (isPCOMMLikeViewProfile){
	        		// retrieve data without sharing in these statuses for these profiles
		            List<ReviewRating__c> reviewRatingList = [SELECT OverallRating__c, CalculatedRating__c FROM ReviewRating__c WHERE Id =: performanceReview.ReviewRating__c];
		            if(reviewRatingList.size() == 0)		            	
		                reviewRating = null;
		        	else{
		                reviewRating = reviewRatingList[0];
		                if(!accessUtil.getIsOnlySysAdminProfile()){
			                if (accessUtil.getStatusRO3() || (!getIsSysAdminProfile() && performanceReview.Status__c.equals('Manager Assessment'))){
				                if(performanceReview.Manager__c != userInfo.getUserId()){
					                reviewRating.OverallRating__c = null;
					                reviewRating.CalculatedRating__c = null;
				                }
			                }
		                }
		        	}
	        	}
	        	else         	
	            	reviewRating = util.getReviewRatingWithSharing(performanceReview);
	        }
	        else
	            reviewRating = new ReviewRating__c(PerformanceReview__c = performanceReview.Id);
			
			// gets the values, their methods and methods without values
	        list<Method> methods2 = new List<Method>(); 
	        values = new List<Value>();
	        methods_withoutvalue = new list<Method>();
	        allMethods = new list<Method>();
	
	        List<Value__c> tempValues = [SELECT Name,(SELECT Id FROM Methods__r) FROM Value__c WHERE V2MOM__c=:performanceReview.V2MOM__c ORDER BY Priority__c]; 
	        List<Method__c> methodsc = [SELECT  Name,Value__c,Value__r.Name,V2MOM__c,V2MOM__r.Locked__c,Description__c,(Select name, description__c From Obstacles__r),(Select name, description__c From Measures__r )
	                                    FROM Method__c
	                                    WHERE Value__c IN : tempValues
	                                    ORDER BY Priority__c];
	
	        List<Method__c> methodsc_withoutvalue = [SELECT  Name,Value__c, Value__r.Name,V2MOM__c,V2MOM__r.Locked__c,Description__c,(Select name, description__c From Obstacles__r),(Select name, description__c From Measures__r )
	                                                 FROM Method__c
	                                                 WHERE V2MOM__c = :performanceReview.V2MOM__c
	                                                 AND Value__c NOT IN : tempValues
	                                                 ORDER BY Priority__c];
	
	        List<MethodReview__c> historyMethods = new List <MethodReview__c>(); 
	        
	        Map<Id, MethodReview__c> mrs;
	        Map<Id, MethodReview__c> mrs_withoutvalue;
	        
            // gets data of the methods within and without values
	        if (isPCOMMLikeViewProfile){	        	
	        	// retrieve data without sharing       
	        	mrs = getMethodReviewsWithoutSharing(performanceReview, methodsc);
	        	mrs_withoutvalue = getMethodReviewsWithoutSharing(performanceReview, methodsc_withoutvalue);
	        }else{	        	
	        	mrs = util.getMethodReviewsWithSharing(performanceReview, methodsc);        	
	        	mrs_withoutvalue = util.getMethodReviewsWithSharing(performanceReview, methodsc_withoutvalue);
	        }
	        
	        for(Value__c v: tempValues) {
	            List<Method> valueMethods = new List<Method>();
	            for(Method__c methodc: methodsc){
	                if(methodc.Value__c == v.Id){
	                    List<MethodReview__c> temp = new List<MethodReview__c>(); 
	                    Method method = new Method(methodc, performanceReview); 
	                    MethodReview__c review = mrs.get(methodc.Id);
						
	                    if (review != null)
	                    {
		                    // filter values for profiles that are not allowed
		                    // after retrieved with the condition without sharing
		                    
			                if ((accessUtil.getIs3PtInAssmnt() && performanceReview.PreviousStatus__c.equals('Manager Assessment'))
            					|| ((accessUtil.getIsEmpl() && !(performanceReview.Status__c.equals('Complete') || performanceReview.Status__c.equals('Employee Approval')))) 
					            || (accessUtil.getIsMngr2ndMngrOrPCOMM() && performanceReview.Status__c.equals('Employee Self Assessment'))
					            || ((accessUtil.getIs2ndMngr() || accessUtil.getIsPCOMM()) && performanceReview.Status__c.equals('Manager Assessment'))
			                	|| (isPCOMMLikeViewProfile && (accessUtil.getStatusRO3() || (!getIsSysAdminProfile() && performanceReview.Status__c.equals('Manager Assessment'))))){
			                   
			                    method.setRating(null);
				                method.setWeight(null);   
		                    }
		                    else{
			                    method.setRating(review.Rating__c);
			                    method.setWeight(review.Weight__c);
		                    }
		                    
		                    if((accessUtil.getIsPCOMM() && accessUtil.getIsMngr()) || (accessUtil.getIsPCOMM())){	 
			                    if(performanceReview.Status__c != 'Employee Self Assessment'){
			                    	method.setRating(review.Rating__c);
		                    		method.setWeight(review.Weight__c);
			                    }
		                    }
		                    
		                    if(userInf.equals(performanceReview.ThirdPartyReviewer__c) && performanceReview.PreviousStatus__c.equals('Manager Assessment')){
		                    	method.setRating(null);
				                method.setWeight(null);
		                    }	
		                    
							if(accessUtil.getUserProfile() == 'System Administrator'||accessUtil.getUserProfile() == 'systemadministrator'){ 
								method.setRating(review.Rating__c);
		                    	method.setWeight(review.Weight__c);
							}							
	                    }
	                    else
	                    {
	                        MethodReview__c tempReview = new MethodReview__c(Method__c = methodc.Id);
	                        tempReview.performanceReview__c = performanceReview.id;
	                        tempReview.Reviewer__c = userInf;
	                    }
	
	                    methods2.add(method); 
	                    allMethods.add(method);
	                    valueMethods.add(method);   
	                }
	            }
	            if(valueMethods.size() > 0)
	                values.add( new Value(v, valueMethods));       
	        }   
	
	        for(Method__c methodc: methodsc_withoutvalue){
	            List<MethodReview__c> temp = new List<MethodReview__c>(); 
	            Method method = new Method(methodc, performanceReview); 
	            MethodReview__c review = mrs_withoutvalue.get(methodc.Id);
	
	            if (review != null) {
	                    // filter values for profiles that are not allowed
	                    // after retrieved with the condition without sharing
		                if ((accessUtil.getIs3PtInAssmnt() && performanceReview.PreviousStatus__c.equals('Manager Assessment'))
            			|| ((accessUtil.getIsEmpl() && !(performanceReview.Status__c.equals('Complete') || performanceReview.Status__c.equals('Employee Approval')))) 
			            || (accessUtil.getIsMngr2ndMngrOrPCOMM() && performanceReview.Status__c.equals('Employee Self Assessment'))
			            || ((accessUtil.getIs2ndMngr() || accessUtil.getIsPCOMM()) && performanceReview.Status__c.equals('Manager Assessment'))
		                || (isPCOMMLikeViewProfile && (accessUtil.getStatusRO3() || (!getIsSysAdminProfile() && performanceReview.Status__c.equals('Manager Assessment'))))){        
		                    method.setRating(null);
		                    method.setWeight(null);
          		
	                    }else{
		                    method.setRating(review.Rating__c);
		                    method.setWeight(review.Weight__c);
	                    }
	                    if(accessUtil.getIsPCOMM() && accessUtil.getIsMngr()){	 
			                if(performanceReview.Status__c != 'Employee Self Assessment'){    
			                    method.setRating(review.Rating__c);
		                    	method.setWeight(review.Weight__c);
			                }
	                    	
	                    }
	                    
	                    if(userInf.equals(performanceReview.ThirdPartyReviewer__c) && performanceReview.PreviousStatus__c.equals('Manager Assessment')){
	                    	method.setRating(null);
			                method.setWeight(null);
	                    }	
	                    
	                    if(accessUtil.getUserProfile() == 'System Administrator'|| accessUtil.getUserProfile()=='systemadministrator'){ 
							method.setRating(review.Rating__c);
	                    	method.setWeight(review.Weight__c);
						}	
	            }
	            else {
	                MethodReview__c tempReview = new MethodReview__c(Method__c = methodc.Id);
	                tempReview.performanceReview__c = performanceReview.id;
	                tempReview.Reviewer__c = userInf;
	            }
	
	            methods_withoutvalue.add(method);
	            allMethods.add(method);
	        } 
	
            // gets data of the metrics
            scorecardSupport = new ScorecardSupport();	                                
        	isScorecardProfile = accessUtil.getIsScorecardProfile();
        	
	        if (isScorecardProfile){
		    	if ((isPCOMMLikeViewProfile) || accessUtil.getIsEmpl()){
		    		if (accessUtil.getIsEmpl())	    			
		        		scorecardSupport = new ScorecardSupport(performanceReview, !(performanceReview.Status__c.equals('Complete') || performanceReview.Status__c.equals('Employee Approval')));
					else 
			        	scorecardSupport = new ScorecardSupport(performanceReview, accessUtil.getStatusRO3() || (!getIsSysAdminProfile() && performanceReview.Status__c.equals('Manager Assessment'))); 
		    	}
		    	else
		        	scorecardSupport = new ScorecardSupport(performanceReview);   		    		
				// checks if there is no more than one scorecard per quarter
	    		if (!scorecardSupport.checkScorecards())
	    			throw new SharingException(Label.PerformanceV2MOMAssessmentController_exception4);
	
	            // gets data of the metrics
	            listScorecard = [Select Id, FiscalQuarter__c FROM ScorecardSupportReview__c  WHERE PerformanceReview__c =: performanceReview.Id ];
	        }else
	        	listScorecard = new List<ScorecardSupportReview__c>();
		        
		    isScorecardProfile = isScorecardProfile && (listScorecard.size() > 0);
	        
            // gets the V2MOM Type
	        if ((v2momType != '') || (v2momType == null)){
		        List<V2MOM__c> v2momaux = [Select v.V2MOM_Type__c From V2MOM__c v Where v.id=:performanceReview.V2MOM__c];		        
			    if (v2momaux.size() > 0)
		        	v2momType = v2momaux.get(0).V2MOM_Type__c;
	        }
	        
	        if(scorecardSupport != null){ 
	        	scorecardSupport.setPerformanceAccessUtil(accessUtil);
	        	scorecardSupport.csmController.setPerformanceAccessUtil(accessUtil);
	        	scorecardSupport.educationController.setPerformanceAccessUtil(accessUtil);
	        	scorecardSupport.supportController.setPerformanceAccessUtil(accessUtil);
	        }
        } 
        else 
        	throw new SharingException(Label.PerformanceV2MOMAssessmentController_exception5);
    }
	
		public boolean getIsScorecardProfile(){
			return isScorecardProfile;
		}

	/*
	* BEGIN FUNCTIONS WITHOUT SHARING *******
	*/	
	public boolean getIsPremierUser(){
		return performanceReview.PremierUser__c;	
	}
	// gets the performance review without sharing
    public PerformanceReview__c getPerformanceReviewWithoutSharing(Id id) {
        List<PerformanceReview__c> performanceReview = [Select  id,name,Employee__c,Employee__r.Name,Manager__c,Manager__r.Name,SecondManager__c,SecondManager__r.Name,
	                                                            PCOMM__c,PCOMM__r.Name,ThirdPartyReviewer__c,CompetencyGroup__c,CompetencyGroup__r.Name,PerformanceReviewPeriod__r.name,
	                                                            PerformanceReviewPeriod__r.Effective_Date__c,ReviewFormTemplate__r.MethodWeight__c,ReviewFormTemplate__r.CompetencyWeight__c,
	                                                            V2MOM__c,V2MOM__r.V2MOM_Type__c,V2MOM__r.Vision__c,OwnerId,Status__c,PreviousStatus__c, EmailComment__c,ReviewRating__c,PremierUser__c
                                                        From PerformanceReview__c
                                                        Where Id=:id];  
        if(performanceReview.size() == 0) return null;
        return performanceReview.get(0);
    }

	// gets the data of the methods without sharing
    public Map<Id, MethodReview__c> getMethodReviewsWithoutSharing(PerformanceReview__c p, List<Method__c> m) {
        Map<Id, MethodReview__c> tempmap = new Map<Id, MethodReview__c>();                               
        for(MethodReview__c mr: [SELECT  Rating__c,Status__c, Weight__c, Method__c
                                 FROM MethodReview__c WHERE PerformanceReview__c =: p.id AND Reviewer__c =: p.Manager__c AND Method__c IN: m]) {
            tempmap.put(mr.Method__c, mr);
        }
        return tempmap;
    }
		
	public boolean getIsOldPerformanceReview(){ 
		if(performanceReview.PerformanceReviewPeriod__r.Effective_Date__c == 'FY08' || performanceReview.PerformanceReviewPeriod__r.Effective_Date__c == 'FY09')
			return true;	
		return false;
	}
	
    // Return the list of all summary comments of performance review
    public List<additionalCommentDate> getCommentsHistory() {
    	List<AdditionalComment__c> originalList = new List<AdditionalComment__c>();
    	List<additionalCommentDate> resultList = new List<additionalCommentDate>();
    	Profile profile = [select Id, Name from Profile where Id =: userInfo.getProfileId()];	
    	if((profile.ID == PerformanceAccessUtil.getSystem_Administrator_Id() || profile.Name == 'systemadministrator')){
    		originalList = [Select  id,Comment__c,Reviewer__c,PerformanceReview__c,CreatedBy.Name,CreatedDate,LastModifiedDate
                    		From AdditionalComment__c Where PerformanceReview__c =: performanceReview.id ORDER BY CreatedDate ASC];
    	}
    	else{
	    	if (isPCOMMLikeViewProfile){
	    		if (!accessUtil.getStatusRO3()){
		    		if (!performanceReview.Status__c.equals('Manager Assessment')){
			    		if (!performanceReview.Status__c.equals('2nd Level Manager Assessment')){
							// any status except created, empl self assmnt, mngr assmnt 
							// or 2nd level mngr assmnt retrieve all							
				    		originalList = [Select  id,Comment__c,Reviewer__c,PerformanceReview__c,CreatedBy.Name,CreatedDate,LastModifiedDate
				                    		From AdditionalComment__c Where PerformanceReview__c =: performanceReview.id ORDER BY CreatedDate ASC];			                    
			    		}else{			    			
							// status 2nd level mngr assmnt retrieve all except the 2nd Manager comments
				    		originalList = [Select  id,Comment__c,Reviewer__c,PerformanceReview__c,CreatedBy.Name,CreatedDate,LastModifiedDate
				                    		From AdditionalComment__c Where PerformanceReview__c =: performanceReview.id and Locked__c = true
					                    	and (Reviewer__c <>: performanceReview.SecondManager__c) ORDER BY CreatedDate ASC];
			    		}
		    		}else{		    			
						// status mngr assmnt retrieve all except the Manager and 2nd Manager comments
			    		originalList = [Select  id, Comment__c,Reviewer__c, PerformanceReview__c, CreatedBy.Name,CreatedDate, LastModifiedDate
			                    		From AdditionalComment__c Where PerformanceReview__c =: performanceReview.id and Locked__c = true
				                    	and (Reviewer__c <>: performanceReview.Manager__c and Reviewer__c <>: performanceReview.SecondManager__c)ORDER BY CreatedDate ASC];
		    		}
	    		}
	    		else 
	    			originalList = new List<AdditionalComment__c>();
	    	}else	        	
	        	originalList = util.getCommentsHistoryWithSharing(performanceReview);
    	}             
        // originalList = orderOverallReviewList(originalList); 	            
         for (AdditionalComment__c c : originalList) {      	
         		if (performanceReview.Status__c == 'Employee Self Assessment' && 
         			performanceReview.Employee__c == Userinfo.getUserId())
     			{
     				if (c.Reviewer__c != Userinfo.getUserId() )
     					resultList.add(new additionalCommentDate(c));
     			}
     			else{
     				if(((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
						||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
						|| ((performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.PCOMM__c == userInfo.getUserId()))){
							if(c.Reviewer__c == performanceReview.Employee__c)
								resultList.add(new additionalCommentDate(c));
					 }	
					 else
	         			resultList.add(new additionalCommentDate(c)); 	
     			}       
         }   
         return resultList;
    }
       
    public Id HaveSameDate(List<AdditionalComment__c> repeatedComment, DateTime d)
    {   	
    	for (AdditionalComment__c c : repeatedComment)
    	{
    		if (c.CreatedDate == d)
    			return c.Id;	
    	}    	
    	return null;	
    }
    
    public boolean getIsMngrSecondMngrAssessment()
    {
    	if (performanceReview.Status__c == 'Manager Assessment' || performanceReview.Status__c == '2nd Level Manager Assessment')
    		return true;	    	
    	return false;
    }
    
    public boolean getShowRejectDefaultButton()
    {
    	return (getIsMngrSecondMngrAssessment() && getIsOnlySysAdminProfile()) || (getIsMngrSecondMngrAssessment() && getIsOnlyJuniorAdminProfile() );   
    }
    
    public boolean getShowReject3Party()
    {
    	return (performanceReview.Status__c.equals('3rd Party Assessment') && getIsOnlySysAdminProfile() );
    }
    
    // Function to show the Change to incomplete button; only Sys admin can see it
    public boolean getShowIncomplete()
    {
    	return !accessUtil.getIsIncompleteStatus() && getIsOnlySysAdminProfile();
    }
     
      
    // Return comment of login user
    public AdditionalComment__c getCurrentComment() {    
         if(currentComment != null) return currentComment;
         List<AdditionalComment__c> comments = [Select  id,Comment__c,Reviewer__c,PerformanceReview__c,CreatedBy.Name,CreatedDate, LastModifiedDate
                                                From AdditionalComment__c
                                                Where PerformanceReview__c =: performanceReview.id
                                                and Reviewer__c =: userInf and Locked__c = false
                                                ORDER BY CreatedDate ASC];
 		 
 		 if (comments.size() == 0) {
             currentComment = new AdditionalComment__c(PerformanceReview__c = performanceReview.id);
             currentComment.Reviewer__c = userInf;
         } 
         else 
             currentComment = comments[0];
    	
         return currentComment;
    }
      
    // sets the summary comment for the logged user
    public void setCurrentComment(String comment) {    
        if (currentComment != null) 
            currentComment.Comment__c = comment;
    }

	/*
	* END FUNCTIONS WITHOUT SHARING *******
	*/

    // returns the values for the adjusted rating
    public List<SelectOption> getRatingSelectOptions() {
        return PAMUtil.getRatingSelectOptions();
    }

    // Return the PerformanceReview
    public PerformanceReview__c getPerformanceReview(){
        return performanceReview;
    }

    // gets the profile of the current user
    public String getUserProfile(){
        return currentUser.Profile.Name;    
    }

    // sets the current user
    public void setUserInf (String userInf) {
        this.userInf = userInf;
    }
    
    // gets the data of the scorecards
    public ScorecardSupport getScorecardSupport(){
        if(scorecardSupport != null)
            return scorecardSupport;
        else
            return scorecardSupport = new ScorecardSupport();   
    } 
        
    // returns true if the performance review is of type support (Q1/Q2 or Q3/Q4)
    public boolean getIsQuarterV2MOM(){
        if(v2momType == 'Individual Q1/Q2' || v2momType == 'Individual Q3/Q4')
            return true;
        return false;   
    }

	/*
	* BEGIN FUNCTIONS FOR METHODS *******
	*/
	// gets the methods that are not within values
    public List<Method> getMethodsWithoutValue() {
        return methods_withoutvalue;
    }

	// gets the values of methods
    public List<Value> getValues() {
        return values;
    }
	
	// returns true if there are no methods outside of values
    public boolean getShowMethodsWithoutValue() {
        if (methods_withoutvalue == NULL || methods_withoutvalue.size() == 0)
            return false;
        return true;    
    }
	/*
	* END FUNCTIONS FOR METHODS *******
	*/

	/*
	* BEGIN FUNCTIONS FOR COMPETENCIES ********
	*/
	// gets the data of the competencies without sharing
    public List<Competency> getCompetencies(){
        competencies = new List<Competency>();

        List<CompetencyGroupMember__c> competenciesGroupMember = [Select Id, Name,Competency__r.Name,Weight__c,Competency__c
                                                                  From CompetencyGroupMember__c Where CompetencyGroup__c =: performanceReview.CompetencyGroup__c];

		Map<Id, CompetencyReview__c> competenciesReview;
		
        if (isPCOMMLikeViewProfile){
        	// retrieve the rating of the competencies
            competenciesReview = new Map<Id, CompetencyReview__c>();
    
    		List<CompetencyReview__c> competencyReviewList = [SELECT Rating__c,
                                         CompetencyGroupMember__r.Competency__c, 
                                         CompetencyGroupMember__c
                                         FROM CompetencyReview__c
                                         WHERE PerformanceReview__c =: performanceReview.id
                                         AND Reviewer__c =: performanceReview.Manager__c
                                         AND CompetencyGroupMember__c IN: competenciesGroupMember];
            
            for(CompetencyReview__c cr: competencyReviewList) {
                competenciesReview.put(cr.CompetencyGroupMember__r.Competency__c, cr);
            }
        }
        else
        	competenciesReview = util.getCompetencyReviewWithSharingMap(performanceReview, competenciesGroupMember);

        for(CompetencyGroupMember__c competencyGroup: competenciesGroupMember) {
            Competency competency = new Competency(competencyGroup, performanceReview);
            CompetencyReview__c review = competenciesReview.get(competencyGroup.Competency__c);
            competency.setWeight(competencyGroup.Weight__c);
            if (review != null) {
	                if ((accessUtil.getIs3PtInAssmnt() && performanceReview.PreviousStatus__c.equals('Manager Assessment'))
            		|| ((accessUtil.getIsEmpl() && !(performanceReview.Status__c.equals('Complete') || performanceReview.Status__c.equals('Employee Approval')))) 
		            || (accessUtil.getIsMngr2ndMngrOrPCOMM() && performanceReview.Status__c.equals('Employee Self Assessment'))
		            || ((accessUtil.getIs2ndMngr() || accessUtil.getIsPCOMM()) && performanceReview.Status__c.equals('Manager Assessment'))
	                || (isPCOMMLikeViewProfile && (accessUtil.getStatusRO3() || (!getIsSysAdminProfile() && performanceReview.Status__c.equals('Manager Assessment'))))){
	                	competency.setRating(null);   
                    }
                    else{
		                competency.setRating(review.Rating__c);
                    }                  
                    if(accessUtil.getIsPCOMM() && accessUtil.getIsMngr()){	               
	                    if(performanceReview.Status__c != 'Employee Self Assessment'){
	                    	competency.setRating(review.Rating__c);
	                    }
                    }
                    
                    if(userInf.equals(performanceReview.ThirdPartyReviewer__c) && performanceReview.PreviousStatus__c.equals('Manager Assessment')){
                    	competency.setRating(null); 
                    }	                 
                    if(accessUtil.getUserProfile() == 'System Administrator'||accessUtil.getUserProfile()=='systemadministrator'){ 
						competency.setRating(review.Rating__c);
					}	
	        }

            competencies.add(competency);
        }       
        return competencies;
    }




    
    
     // -------------- BEGIN FLAGS --------------
     private boolean approve = false;
     private boolean reject = false;
     private boolean thirdsubmit = false;
     private boolean thirdrequest = false;
     private boolean showError = false;
     private String  msgError = '';
    
     public boolean getApproveFlag() {    
         return approve;
     }
    
     public boolean getRejectFlag() {    
         return reject;
     }
    
     public boolean getThirdSubmitFlag() {    
         return thirdsubmit;
     }
    
     public boolean getThirdRequestFlag() {    
         return thirdrequest;
     }
    
     public Boolean getShowError() {    
         return showError;
     }
    
     public String getMsgError() {    
         return  msgError;
     }

     // -------------- END FLAGS --------------
    
    


    
     // checks the manager filled all the data
     private void checkManagerDataEntryRequirements() {    
         showError = false;
         msgError = '';
    
         /* If User is Manager are required all Comments and ratings */
         if (userInf.equals(performanceReview.Manager__c)
                 && performanceReview.Status__c.equals('Manager Assessment')){
    
             double sumWeight = 0;
             MethodReview__c method;
    			    
             Map<Id, MethodReview__c> methodsReview = new Map<Id, MethodReview__c>();

			for(MethodReview__c mr : [SELECT Rating__c,
	                                            Status__c,
	                                            Weight__c,
	                                            Comment__c,
	                                            Method__c
	                                        FROM MethodReview__c
	                                        WHERE PerformanceReview__c =: performanceReview.id
	                                            AND Reviewer__c =: performanceReview.Manager__c]){
				methodsReview.put(mr.Method__c, mr);
			}
             
             for(Method__c m: [Select id, name
                               From Method__c
                               Where V2MOM__c=:performanceReview.V2MOM__c]){
             	    
                 if(methodsReview.size() == 0) {
                     msgError = Label.PerformanceOverallController_Exception2;
                     showError = true;
                     continue;
                 } 
                 else {
                     method = methodsReview.get(m.Id);
              	 	
	                 if (method.Comment__c == null || method.Comment__c.Trim().length()==0) {
	                     msgError = Label.PerformanceOverallController_Exception3;
	                     showError = true;
	                 }   			
	    			 
	                 if (method.Rating__c == null || method.Rating__c ==0) {
	                     msgError = Label.PerformanceOverallController_Exception4;
	                     showError = true;
	                 }
    			 
	                 if (method.Weight__c == null) {
	                     msgError = Label.PerformanceOverallController_Exception5;
	                     showError = true;
	                 }
	                 else {
	                     sumWeight += method.Weight__c;
	                 }

                 }
             }
    
             if(!showError && (sumWeight > 100) && (getShowSupportScorecard())){
                 msgError = Label.PerformanceOverallController_Exception6;
                 showError = true;
             }
    
             if(!showError && (sumWeight > 100) && (!getShowSupportScorecard())){
                 msgError = Label.PerformanceOverallController_Exception7;
                 showError = true;
             }
    
             if((!showError) && (sumWeight < 100) && (!getShowSupportScorecard())){
                 msgError = Label.PerformanceOverallController_Exception7;
                 showError = true;
             }
             
			// check all data of metrics was filled out
            if ((!showError) && (scorecardTypeProfile.Profile.Name.equals('Support Employee')) && (getShowSupportScorecard()) && scorecardSupport.getIsOld()){
	            msgError = scorecardSupport.checkManagerSupportDataEntryRequirements();
				if ((!showError) && (!msgError.equals(''))){
	                 showError = true;
				}				
            }

            if ((!showError) && (scorecardTypeProfile.Profile.Name.equals('Education Employee')) && (getShowSupportScorecard())){
	            msgError = scorecardSupport.checkManagerEducationDataEntryRequirements(sumWeight);
				if ((!showError) && (!msgError.equals(''))){
	                 showError = true; 
				}				
            }
            
            if ((!showError) && (scorecardTypeProfile.Profile.Name.equals('CSM Employee')) && (getShowSupportScorecard())){
	            msgError = scorecardSupport.checkManagerCSMDataEntryRequirements(sumWeight);
				if ((!showError) && (!msgError.equals(''))){
	                 showError = true; 
				}				
            }
 
             if ((!showError) && (scorecardTypeProfile.Profile.Name.equals('Support Employee')) && (getShowSupportScorecard()) && !scorecardSupport.getIsOld()){
	            msgError = scorecardSupport.checkManagerNewSupportDataEntryRequirements(sumWeight);
				if ((!showError) && (!msgError.equals(''))){
	                 showError = true; 
				}				
            }
    
           Map<Id, CompetencyReview__c> competenciesReview = new Map<Id, CompetencyReview__c>();
            	
        	for (CompetencyReview__c cr : [SELECT id, Comment__c, Rating__c, CompetencyGroupMember__c
                                                             FROM CompetencyReview__c
                                                             WHERE Reviewer__c =: performanceReview.Manager__c
                                                             AND PerformanceReview__c =: performanceReview.Id]){
       			competenciesReview.put(cr.CompetencyGroupMember__c, cr);
        	}
            
            // Check competencies are checked
            for(CompetencyGroupMember__c competencyGroup: [Select   Id,
		                                                            Name,
		                                                            Weight__c
                                                            From CompetencyGroupMember__c
                                                            Where CompetencyGroup__c =: performanceReview.CompetencyGroup__c]) {
    
                 CompetencyReview__c competency;
    
                 if (competenciesReview.size() == 0) {
                     msgError = Label.PerformanceOverallController_Exception8;
                     showError = true;
                     continue;
                 } 
                 else {
                     competency = competenciesReview.get(competencyGroup.Id);
					
	                 if (competency.Comment__c == null){
	                     msgError = Label.PerformanceOverallController_Exception9;
	                     showError = true;
	                 }
	                 else{
	                 	if(competency.Comment__c.Trim().length()==0){
	                 	   msgError = Label.PerformanceOverallController_Exception9;
	                       showError = true;
	                 	}
	                 }          
    			
	                 if (competency.Rating__c == null || competency.Rating__c ==0){
	                     msgError = Label.PerformanceOverallController_Exception10;
	                     showError = true;
	                 }
                 }   
             }
                		
             if ((reviewRating.OverallRating__c == null) || (reviewRating.OverallRating__c == 0)) {
                 msgError = Label.PerformanceOverallController_Exception11;
                 showError = true;
             }
    
             // Check Required Summary Comment
             if(currentComment == null || currentComment.Comment__c == null || currentComment.Comment__c == '') {
                 msgError = Label.PerformanceOverallController_Exception12;
                 showError = true;
             }
    
             if (currentComment.Comment__c.length() > 32000) {
                 msgError = Label.PerformanceOverallController_Exception1;
                 showError = true;
             }
         }
     }
    
     // Cancel Reject
     public void cancelButton() {
          /* reset variables so that buttons show next time */
         approve = false;
         reject = false;
         thirdsubmit = false;
         thirdrequest = false;
         showError = false;
         msgError = '';
     }
    
    
     // Return a value for Submit button
     public String getValueSubmit(){
         if (userInf.equals(performanceReview.Employee__c))
             return  Label.Save_and_Submit_to_Manager_label;
         if (userInf.equals(performanceReview.Manager__c) &&
                 performanceReview.SecondManager__c != null)
             return  Label.Save_and_Submit_to_2nd_Manager_label;
         return Label.Submit_btn;
     }
    
     // Return true if show submit button
     public boolean getShowSubmit(){
         return (((userInf.equals(performanceReview.Employee__c) || getIsSysAdminProfile())
                 && performanceReview.Status__c.equals('Employee Self Assessment'))
                 || (userInf.equals(performanceReview.Manager__c)
                         && performanceReview.Status__c.equals('Manager Assessment'))
                         && performanceReview.SecondManager__c != null);
     }
    
     // Return true if show submit to PCOMM button
     public boolean getShowSubmitPCOMM(){
         return (((userInf.equals(performanceReview.SecondManager__c) || getIsSysAdminProfile())
                 && performanceReview.Status__c.equals('2nd Level Manager Assessment'))
                 || (userInf.equals(performanceReview.Manager__c)
                         && performanceReview.SecondManager__c == null
                         && performanceReview.Status__c.equals('Manager Assessment')));
     }
    
     // Return a value for Reject button
     public String getValueReject(){
     	 if (getIsSysAdminProfile()) return 'Reject';
         if (userInf.equals(performanceReview.Manager__c))
             return  Label.Save_and_Reject_to_Employee_label;
         if (userInf.equals(performanceReview.SecondManager__c))
             return  Label.Save_and_Reject_to_Manager_label;
         return Label.Save_and_Reject_label;
     }
    
     // Return true if show reject button
     public boolean getShowReject(){
         return ((this.getIsSysAdminProfile() && performanceReview.Status__c.equals('PCOMM Review'))
                 || (userInf.equals(performanceReview.Manager__c)&& performanceReview.Status__c.equals('Manager Assessment'))
                         || (userInf.equals(performanceReview.SecondManager__c)&& performanceReview.Status__c.equals('2nd Level Manager Assessment')));
     }
    
 
     public boolean getIsCompleteBack(){
     	return performanceReview.Status__c == 'Complete' && performanceReview.PreviousStatus__c == 'Employee Approval' && (accessUtil.getUserProfile() == 'System Administrator'||accessUtil.getUserProfile() == 'systemadministrator');	     
     }
    
    
     // --------------------------
     // 3rd Party Logic
     // --------------------------
     public boolean getShow3rdPartySubmitButton() {
         return ((userInf.equals(performanceReview.Manager__c)
                 && performanceReview.Status__c.equals('Manager Assessment'))
                 || (userInf.equals(performanceReview.SecondManager__c)
                         && performanceReview.Status__c.equals('2nd Level Manager Assessment')));
     }
    

    
     public boolean notBelongsPerformaceReview(String thirdPartyId){
         if(thirdPartyId != performanceReview.Employee__c && thirdPartyId != performanceReview.Manager__c && thirdPartyId != performanceReview.SecondManager__c && thirdPartyId != performanceReview.PCOMM__C){
             return true;
         }
         return false;
     }
     
     public boolean getShow3rdPartyButton() {
         return ((userInf.equals(performanceReview.ThirdPartyReviewer__c)
                 && performanceReview.Status__c.equals('3rd Party Assessment')));
     }
    
    
 	

   	

    
    // Return value for Save & Approve Button
    public String getValueApprove(){
        if ((userInf.equals(performanceReview.Manager__c) && performanceReview.Status__c.equals('Manager Approval')) || (this.getIsSysAdminProfile() && performanceReview.Status__c.equals('Manager Approval')))
            return  ' ' + Label.Route_to_Employee_label;
    
        return Label.Save_and_Approve_label;
    }
    
    // Return true if must show Save & Approve button
    public boolean getShowApprove(){
        return ((this.getIsSysAdminProfile()
                && performanceReview.Status__c.equals('PCOMM Review')) || (this.getIsSysAdminProfile()
                && performanceReview.Status__c.equals('Manager Approval'))
                || (userInf.equals(performanceReview.Manager__c)
                        && performanceReview.Status__c.equals('Manager Approval'))
                        || (this.getIsSysAdminProfile() && performanceReview.Status__c.equals('Manager Approval'))
                       /* || (userInf.equals(performanceReview.SecondManager__c)
                                && performanceReview.Status__c.equals('2nd Level Manager Approval'))*/);
    }
    
    public boolean getShowMessage (){
        if (getCommentsHistory().size()== 0){
            return true;
        }
        return false;   
    }   

	/*
	 * END SAVE & SUBMIT FUNCTIONS ********
	*/
	
	/*
	* BEGIN FUNCTIONS TO SHOW VALUES - ACCESS DESIGN ******
	*/
	/////////////// functions to check which elements should be shown, hidden or editable

    // checks if it is assessment of review. This is used in the JavaScripts
    public boolean getShowReviewEdit() {
		return (accessUtil.getIsEmplMngr2ndMngrOr3PtInAssmnt() && !(accessUtil.getIsSysAdminProfile() && accessUtil.getStatusRO3())) || this.isEmployeeInApprove();   	
    }
    
    
    
    // Return true if Overall Rating permision is read
    public boolean getShowOverallRatingRead() {
        if (accessUtil.getIsMngrInAssmnt()){
            return false;
        }

        if(reviewRating != null) return true;

        return false;
    }

    // Return true if Overall Rating permission is write
    public boolean getShowOverallRatingWrite() {
        return (accessUtil.getIsMngrInAssmnt());
    }

    // Return true if Overall Rating permision is read
    public boolean getShowOverallRating() {
        return !(userInf.equals(performanceReview.Employee__c)
                && (performanceReview.Status__c.equals('Employee Self Assessment')
                        || performanceReview.Status__c.equals('Manager Assessment')
                        || performanceReview.Status__c.equals('2nd Level Manager Assessment')
                        || performanceReview.Status__c.equals('3rd Party Assessment')
                        || performanceReview.Status__c.equals('2nd Level Manager Approval')
                        || performanceReview.Status__c.equals('Manager Approval')));
    }

    // Return true if the logged user is the manager of performance review no matter the status
    public boolean getIsManager() {
		return accessUtil.getIsMngr();
    }

    // Return true if the logged user is the employee of performance review no matter the status
    public boolean getIsEmployee() {
		return accessUtil.getIsEmployee();
    }
         
    // checks the logged user is the manager of the performance review or a SysAdmin no matter the status
    public boolean getIsManagerOrSecondManager()
    {
		return accessUtil.getIsMngr();
    }

    //-----------------  USER PROFILES ---------------------------------
	// returns true if the performance review has scorecards
     public Boolean getShowSupportScorecard() {
         if(performanceReview.ThirdPartyReviewer__c == userInfo.getUserId()){
         	return false;        	
         }
         if ((v2momType != 'Individual Q1/Q2') && (v2momType != 'Individual Q3/Q4'))
         	return false;
         
         if (listScorecard.size()>0) {
         	for(ScorecardSupportReview__c s : listScorecard){
         		if ((v2momType == 'Individual Q1/Q2') 
         		&& (s.FiscalQuarter__c.equals('Q1') || s.FiscalQuarter__c.equals('Q2')))
         			return true;
         		if ((v2momType == 'Individual Q3/Q4') 
         		&& (s.FiscalQuarter__c.equals('Q3') || s.FiscalQuarter__c.equals('Q4')))
         			return true;
         	}
         	return false;
         }
         else {
             return false;
         }
     }

	// returns true if is has scorecards and if the logged is a education profile
    public boolean getIsEducationProfile(){
    
        if (! getShowSupportScorecard()){
            return false;   
        }       
		return accessUtil.getIsEducationProfile();
    }
        
	// returns true if is has scorecards and if the logged is a support profile
    public boolean getIsSupportProfile(){    
        if (! getShowSupportScorecard()){
            return false;   
        }        
		return accessUtil.getIsSupportProfile();
    }
    
	// returns true if is has scorecards and if the logged is a consulting profile
    public boolean getIsConsultingProfile(){    
        if (! getShowSupportScorecard()){
            return false;   
        }       
		return accessUtil.getIsConsultingProfile();
    }
    
	// returns true if is has scorecards and if the logged is a CSM profile
    public boolean getIsCSMProfile(){    
        if (! getShowSupportScorecard()){
            return false;   
        }       
		return accessUtil.getIsCSMProfile();
    }

    // Return true if the logged user is of System Administrator profile
    public boolean getIsSysAdminProfile(){
		return accessUtil.getIsSysAdminProfile();
    }
     
    public boolean getIsOnlySysAdminProfile()
    {   	
    	 return accessUtil.getIsOnlySysAdminProfile();
    }
    
    public boolean getIsOnlyJuniorAdminProfile()
    {
    	return accessUtil.getIsOnlyJuniorSysAdminProfile();
    }
    
    // checks all the profiles that can view the scorecards if there are scorecards
    public boolean getScorecardViewProfile(){
        if (! getShowSupportScorecard()){
            return false;   
        }
    
		return accessUtil.getScorecardViewProfile();
    }
        
    // returns true if it is not a profile that should see scorecards
    public boolean getHaveProfile(){
		return accessUtil.getHaveProfile();
    }
    
    //--------------------- END OF USER PROFILES ------------------------
 
     // Return true if the logged user is the manager of performance review no matter the status
     public boolean getIsMngr() {
		return accessUtil.getIsMngr();
     }
     
    // Manager in Assessment - Write permission
     public boolean getIsMngrInAssmnt() {
		return accessUtil.getIsMngrInAssmnt();
     }   
      
    // Employee, Manager, 2nd Manager or 3rd Party in Assessment - Write permission
     public boolean getIsEmplMngr2ndMngrOr3PtInAssmnt() {
		return accessUtil.getIsEmplMngr2ndMngrOr3PtInAssmnt();
     } 
	
	public boolean getShowTextAreaSummaryComment(){
		return this.getIsEmplMngr2ndMngrOr3PtInAssmnt() || isEmployeeInApprove();
	}
	
	public boolean isEmployeeInApprove(){	
		if(performanceReview.Employee__c == userInfo.getUserId() && performanceReview.Status__c == 'Employee Approval'){
			return true;
		}
		return false;
	}
	
	// determines the users and statuses in which the overall calculated method rating can be shown
	public boolean getOverallCalcMethodRatingView(){
		return accessUtil.getOverallCalcMethodRatingView();
	}

	// determines the users and statuses in which the overall calculated metric rating can be shown
	public boolean getOverallCalcMetricRatingView(){
		return accessUtil.getOverallCalcMetricRatingView();
	}

	// determines the users and statuses in which the overall calculated competency rating can be shown
	public boolean getOverallCalcCompRatingView(){
		return accessUtil.getOverallCalcCompRatingView();
	}

	// determines the users and statuses in which the overall calculated rating can be shown
	public boolean getOverallRatingView(){
		return accessUtil.getOverallRatingView();
	}
	
	// ----------------------- FUNCTIONS FOR DISPLAY

    // Return Competency Calculated Rating formated for display
    public String getDisplayCompetencyCalculatedRating(){
    	if(getIsOnlySysAdminProfile()){
    		Decimal decimalValue = Decimal.valueOf(getCompetencyCalculatedRating());
	        String subStr = String.valueOf(decimalValue.setScale(2, System.RoundingMode.UP));
	    	return subStr;	
    	}
    	if(((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			|| ((performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.PCOMM__c == userInfo.getUserId()))){
				return '-';
		}
    	if (getOverallCalcCompRatingView()){
	    
			 Decimal decimalValue = Decimal.valueOf(getCompetencyCalculatedRating());
	         String subStr = String.valueOf(decimalValue.setScale(2, System.RoundingMode.UP));
	    	 return subStr;		   
    	}
    	return '-';
    }

    // Return Method Calculated Weight formated for display
    public String getDisplayMethodCalculatedWeight(){
    	if(getIsOnlySysAdminProfile()){
    		String subStr = String.valueOf(getMethodAndMetricWeight()); 	    
     		if( subStr.length() > 4)
        		return subStr.substring(0,5);
     		return subStr + '%';
    	}
    	if(((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			|| ((performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.PCOMM__c == userInfo.getUserId()))
			|| performanceReview.Status__c == 'Employee Self Assessment'){
				return '-';
		}
    	if (!getShowSupportScorecard()){	    		
	         String subStr = String.valueOf(getMethodAndMetricWeight()); 	    
	         if( subStr.length() > 4)
	             return subStr.substring(0,5);
	         return subStr + '%';
    	}else{
    		if (((accessUtil.getIsMngr2ndMngrOrPCOMM() || accessUtil.getPCOMMLikeViewProfile()) && accessUtil.getStatusRO1()) 
			|| ((accessUtil.getIsEmplMngr2ndMngrOrPCOMM() || accessUtil.getPCOMMLikeViewProfile()) && accessUtil.getStatusRO2() && !accessUtil.getIsEmplIn3PtAssmnt())
			|| getIsMngrInAssmnt() || accessUtil.getIs3rdManager()){
	         String subStr = String.valueOf(getAllMethodWeightSum());
	    
	         if( subStr.length() > 4)
	             return subStr.substring(0,5);
	         return subStr + '%';
    		}
    	}
    	return '-';
    }
    
    // Return Method Calculated Rating formated for display
    public String getDisplayMethodCalculatedRating(){
    	if(getIsOnlySysAdminProfile()){
    		Decimal decimalValue = Decimal.valueOf(getMethodCalculatedRatingWithinMethods());
	        String subStr = String.valueOf(decimalValue.setScale(2, System.RoundingMode.UP));
	    	return subStr;
    	}
    	if(((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			|| ((performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.PCOMM__c == userInfo.getUserId()))){
				return '-';
		}
    	if (getOverallCalcMethodRatingView()){
	    		
	        Decimal decimalValue = Decimal.valueOf(getMethodCalculatedRatingWithinMethods());
	        String subStr = String.valueOf(decimalValue.setScale(2, System.RoundingMode.UP));
	    	return subStr;
    	}
    	return '-';
    }

    // Return Metric Calculated Weight formated for display
    public String getDisplayMetricCalculatedWeight(){
    	if(getIsOnlySysAdminProfile()){
    		String subStr = String.valueOf(getMetricWeight());	    
	         if( subStr.length() > 4)
	             return subStr.substring(0,5) + '%';
	         return subStr + '%';
    	}
    	if(((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			|| ((performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.PCOMM__c == userInfo.getUserId()))){
				return '-';
		}
    	if (getShowSupportScorecard() && 
    		(((accessUtil.getIsMngr2ndMngrOrPCOMM() || accessUtil.getPCOMMLikeViewProfile()) && accessUtil.getStatusRO1()) 
			|| ((accessUtil.getIsEmplMngr2ndMngrOrPCOMM() || accessUtil.getPCOMMLikeViewProfile()) && accessUtil.getStatusRO2() && !accessUtil.getIsEmplIn3PtAssmnt())
			|| getIsMngrInAssmnt()) || accessUtil.getIs3rdManager()){
	         String subStr = String.valueOf(getMetricWeight());
	    
	         if( subStr.length() > 4)
	             return subStr.substring(0,5) + '%';
	         return subStr + '%';
    	}
    	return '-';
     }

     // Return Metric Calculated Rating formated for display
     public String getDisplayMetricCalculatedRating(){
     	if(getIsOnlySysAdminProfile()){
    		Decimal decimalValue = Decimal.valueOf(getMetricCalculatedRating());
	         String subStr = String.valueOf(decimalValue.setScale(2, System.RoundingMode.UP));
	         return subStr;
    	}
    	if(((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			|| ((performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.PCOMM__c == userInfo.getUserId()))){
				return '-';
		}
    	if (getOverallCalcMetricRatingView()){
	         
	         Decimal decimalValue = Decimal.valueOf(getMetricCalculatedRating());
	         String subStr = String.valueOf(decimalValue.setScale(2, System.RoundingMode.UP));
	         return subStr;
    	}
    	return '-';
     }
    
     // Return Overall Calculated Rating formated for display
     public String getDisplayOverallCalculatedRating(){
     	if(getIsOnlySysAdminProfile()){
    		Decimal decimalValue = Decimal.valueOf(getOverallCalculatedRating());
	         String subStr = String.valueOf(decimalValue.setScale(2, System.RoundingMode.UP));
	         return subStr;
    	}
     	if(((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			|| ((performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.PCOMM__c == userInfo.getUserId()))){
				return '-';
		}
     	if (getOverallRatingView()){
     	
	    	 Decimal decimalValue = Decimal.valueOf(getOverallCalculatedRating());
	         String subStr = String.valueOf(decimalValue.setScale(2, System.RoundingMode.UP));
	         return subStr;
     	}
    	return '-';
     }

     // Return Final Overall Calculated Rating formated for display
    public String getDisplayOverallRating() {
		if(getIsOnlySysAdminProfile()){
    		
    		if(reviewRating != null && reviewRating.OverallRating__c != null){
    			return PAMUtil.getRatingLabel(reviewRating.OverallRating__c.intValue());
    		}	
    	}
		if(((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			|| ((performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.PCOMM__c == userInfo.getUserId()))){
				return '-';
		}
        if(reviewRating == null) return '-';

        if(reviewRating.OverallRating__c == null) return '-';
        
        if (!getOverallRatingView())
			return '-';
        
        return PAMUtil.getRatingLabel(reviewRating.OverallRating__c.intValue());
    }

	// ------------------------ END FUNCTIONS FOR DISPLAY
	
	/*
	* END FUNCTIONS TO SHOW VALUES - ACCESS DESIGN ********
	*/
	
	/*
	* BEGIN FUNCTIONS FOR CALCULATIONS *******
	*/
	// returns the overall rating of the performance review
    public String getOverallRating() {
		
		System.debug('aaaaaaaaa    ' + reviewRating);
        if(reviewRating == null) return null;

        if(reviewRating.OverallRating__c == null) return null;

        return String.valueOf(reviewRating.OverallRating__c.intValue());
    }

	// sets the overall rating of the performance review
    public void setOverallRating(String r) {

        if(r==null) return;

        if(reviewRating == null) return;

        reviewRating.OverallRating__c = Integer.valueOf(r);
    }

     //Returns the sum of all weights for all methods
     public double getAllMethodWeightSum(){
         double methodWeightSum = 0;
         
         if (methods == null) methods = allMethods;
         for(Method method: methods){
             if (method.weight != null)
                 methodWeightSum = methodWeightSum + method.weight;
         }
         
         return methodWeightSum;
     }
    
     //Returns the weight for Methods & Metrics from the review template
     public double getMethodAndMetricWeight(){
         double mw = 1;
         if (performanceReview.ReviewFormTemplate__r.MethodWeight__c != null) 
            mw = performanceReview.ReviewFormTemplate__r.MethodWeight__c;
         return mw;
     }

     //Returns the weight for Metrics according to the sum of weights for Methods
     public double getMetricWeight(){
         double methodWeights = getAllMethodWeightSum();
         return (100 - methodWeights);
     }
    
     //Returns the weight for Competencies from the review template
     public double getCompetencyWeight(){
         double cw = 1;
         if (performanceReview.ReviewFormTemplate__r.CompetencyWeight__c != null) 
            cw = performanceReview.ReviewFormTemplate__r.CompetencyWeight__c;
         return cw;
     }
        
     // Returns Method Calculated Rating for all methods
     // Calculated Method Rating = SUM(Rate * (Weight/100))
     public Double getMethodCalculatedRating(){
         double methodCalculatedRating = 0;
         if (methods == null) methods = allMethods;
         for(Method method: methods){
             if (method.weight != null && method.rating != null &&  method.rating != -1)
                 methodCalculatedRating = methodCalculatedRating + (method.rating * (method.weight / 100));
         }
         return methodCalculatedRating;
     }

     // Returns Average of Method Calculated Rating for all methods within the Method section
     // Average Calculated Method Calculated Rating = SUM(Rate * (Weight/100) * (Weight/methodWeightSum))
     public Double getMethodCalculatedRatingWithinMethods(){
         double methodCalculatedRatingWithinMethods = 0;
         double methodWeightSum = getAllMethodWeightSum();
         if (methods == null) methods = allMethods;
         for(Method method: methods){
             if ((method.weight != null) && (method.rating != null) && (methodWeightSum != 0) && method.rating != -1)
                 methodCalculatedRatingWithinMethods = methodCalculatedRatingWithinMethods + method.rating*(method.weight/methodWeightSum);
         }        
         return methodCalculatedRatingWithinMethods;
     }

    // Returns Metric Calculated Rating for all metrics
    public Double getMetricCalculatedRating(){
    	// Metric Calculated Rating = SUM((Rate * (Weight/100))/2)  		
         if ((scorecardTypeProfile.Profile.Name.equals('Support Employee') && scorecardSupport.getIsOld())|| (scorecardTypeProfile.Profile.Name.equals('Support Manager')&& scorecardSupport.getIsOld()))
         {
         	
         	return scorecardSupport.getAvgRatingCSAT() + scorecardSupport.getAvgRatingRenewals() 
         			+ scorecardSupport.getAvgRatingWMCases() 
         			+ scorecardSupport.getAvgRatingWMSMES() + scorecardSupport.getAvgRatingWMHC() 
         			+ scorecardSupport.getAvgRatingWMPA() + scorecardSupport.getAvgRatingSI();
         }
         			
    	// Metric Calculated Rating = SUM(Rate * (Weight/100)/(SumMetricWeight/100))
    	if ((scorecardTypeProfile.Profile.Name.equals('Education Employee') || scorecardTypeProfile.Profile.Name.equals('Education Manager')  )&& (getMetricWeight() != 0))
    	{	
    		return scorecardSupport.getAvgRatingEducationMetrics() / getMetricWeight() * 100;
    	}
    			
    	 // Metric Calculated Rating = SUM(Rate * (Weight/100)/(SumMetricWeight/100))
    	if ((scorecardTypeProfile.Profile.Name.equals('CSM Employee') || scorecardTypeProfile.Profile.Name.equals('CSM Manager')  )&& (getMetricWeight() != 0))
    	{
    		return scorecardSupport.getAvgRatingCSMMetrics() / getMetricWeight() * 100;	
    	}
    	
    	if ((scorecardTypeProfile.Profile.Name.equals('Support Employee') || scorecardTypeProfile.Profile.Name.equals('Support Manager')  )&& (getMetricWeight() != 0))
    	{   	
    		return scorecardSupport.getAvgRatingSupportMetrics() / getMetricWeight() * 100;	
    	} 	
         return 0;
     }

    // Returns Average Metric Calculated Rating for all metrics within the Metric section
    // Average Metric Calculated Rating = (SUM((Rate * (Weight/100))/2))*(MeW / 100)
    public Double getMetricCalculatedRatingWithinMetrics(){
         double metricCalculatedRatingWithinMetrics = getMetricCalculatedRating();   
         return metricCalculatedRatingWithinMetrics * getMetricWeight() / 100;
     }

     // Returns Average Method & Metric Calculated Rating
     // Average Method & Metric Calculated Rating = (MethodCalculatedRating + MetricCalculatedRatingWithinMetrics)* MethodAndMetricWeight
     public Double getMethodsAndMetricsCalculatedRating(){  	 
         return (getMethodCalculatedRating() + getMetricCalculatedRatingWithinMetrics()) * getMethodAndMetricWeight() / 100;
     }
    
     // Returns Competency Calculated Rating for all competencies
     // Competency Calculated Rating = SUM(Rate * (Weight/100))
     public Double getCompetencyCalculatedRating() {
         double competencyCalculatedRating = 0;
    
         if (competencies == null) competencies = getCompetencies();
         for(Competency competency: competencies){
             if (competency.weight != null && competency.Rating != null){
                 competencyCalculatedRating = competencyCalculatedRating + (competency.Rating * (competency.weight / 100));
             }
         }
            
         return competencyCalculatedRating;
     }

     // Returns Average Competency Calculated Rating for all competencies within the competency section
     // Average Competency Calculated Rating = (SUM(Rate * (Weight/100))) * (CompetencyWeight/100)
     public Double getCompetencyCalculatedRatingWithinCompetencies() {
         double competencyCalculatedRating = getCompetencyCalculatedRating();          
         double cw = getCompetencyWeight();   
         return competencyCalculatedRating * cw / 100;
     }
    
     // Returns Overall Calculated Rating
     // Overall Calculated Rating = MethodsAndMetricsCalculatedRating + getCompetencyCalculatedRatingWithinCompetencies
     public double getOverallCalculatedRating(){        
         return getMethodsAndMetricsCalculatedRating() + getCompetencyCalculatedRatingWithinCompetencies();
     }
        
	/*
	* END FUNCTIONS FOR CALCULATIONS ******
	*/

     /*
      * Inner class
      * keeps the data of the methods
      */
    public class Method{
        String methodName;
        String weightShow;
        String ratingShow;
        double rating;
        double weight;
    
        Method__c method;
        MethodReview__c review;
        List<MethodReview__c> history;
        PerformanceReview__c performance;
    
        public Method(String name){
            methodName = name;
        }
    
        public Method(Method__c m, PerformanceReview__c p){
            method = m;
            performance = p;
        }           
    
        public Method__c getMethod(){
            return method;
        }
    
        public void setMethod(Method__c m){
            method = m;
        }
    
        public String getMethodName(){
            return methodName;
        }
    
        public void setMethodName(String name){
            methodName = name;
        }
    
        public String getRating(){
        	if(((performance.PreviousStatus__c == 'Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
				||((performance.PreviousStatus__c == '2nd Level Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
				|| ((performance.Status__c == '3rd Party Assessment') && (performance.PCOMM__c == userInfo.getUserId()))){
					return '-';
			}
            if(rating == null){
            	 return '-';
            }
    		
			return '-';
        }
    	
    	public String getRatingShow()
    	{	
    		
    		if(((performance.PreviousStatus__c == 'Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
				||((performance.PreviousStatus__c == '2nd Level Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
				|| ((performance.Status__c == '3rd Party Assessment') && (performance.PCOMM__c == userInfo.getUserId()))){
					return '-';			
				
			}
    		if(rating == null)return '-';
    		if(rating.intValue() == -1)
            	return 'N/A';

    		String value =  PAMUtil.getRatingLabel(rating.intValue());
    		
    		if (value == '--None--')
    		{
    			return '-';
    			
    		}
    		else
    		{
    			return value;
    		}    		
    	}
    	
    
    	public void setRatingShow(String s)
    	{
    		s = ratingShow;
    	}
    	
    	public void setWeightShow(String s)
    	{
    		weightShow = s;	
    	}
    	public boolean getShowNullRating(){
    		
    		if(rating == null){
    			return true;	
    		}
    		return false;
    	}
        public void setRating(double r){
            rating = r;
        }
    
    
        public String getWeightShow(){
            if(((performance.PreviousStatus__c == 'Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
				||((performance.PreviousStatus__c == '2nd Level Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
				|| ((performance.Status__c == '3rd Party Assessment') && (performance.PCOMM__c == userInfo.getUserId()))){
					return '-';
			}
            if (weight == null) return '-';
            return (String.valueOf(weight)) + '%';
        }
    	
    	public boolean getShowPercent(){ 
			 if (weight != null){
			 	 return true;
			 }
			 return false;
    	}
    	 
        public void setWeight(double w){
            weight = w;
        }
    
        public String getNameEllipsis() {
    
            return method.Name;                 
        }  
    }

     /*
      * Inner class
      * keeps the data of the competencies
      */
    public class Competency{
        String competencyName;
        double rating;
        double weight;
        CompetencyGroupMember__c competency;
        PerformanceReview__c performance;
    
        public Competency(CompetencyGroupMember__c c, PerformanceReview__c perf){
	        competency = c;
	        performance = perf;
                      
       }
    
        public String getCompetencyName(){
            return competency.Competency__r.Name;
        }
     
        public void setCompetencyName(String name){
            competencyName = name;
        }
    
        public String getRating(){
    		if(((performance.PreviousStatus__c == 'Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
				||((performance.PreviousStatus__c == '2nd Level Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
				|| ((performance.Status__c == '3rd Party Assessment') && (performance.PCOMM__c == userInfo.getUserId()))){
					return '-';
			}
            if(rating == null) return '-';
            
            return '-';
        }
    	
    	public String getRatingShow()
    	{		
    		if(((performance.PreviousStatus__c == 'Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
				||((performance.PreviousStatus__c == '2nd Level Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
				|| ((performance.Status__c == '3rd Party Assessment') && (performance.PCOMM__c == userInfo.getUserId()))){
					return '-';
			}
    		if(rating == null)return '-';
    		
    		String value = PAMUtil.getRatingLabel(rating.intValue());
    		
    		if (value == '--None--')
    		{
    			return '-';
    		} 		
    		return value;
    	}
    	
    	public boolean getShowNullRating(){
    		if(rating == null){
    			return true;	
    		}
    		return false;
    	}
    	
        public void setRating(double r){
           
            rating = r;
        }
    
        public String getWeight(){
	        if (weight == null) return '-';
	
	        return (String.valueOf(weight)) + '%';
	    }
	                
		public String getWeigthShow(){
		    if (weight == null) return '-';
	
	        return ('' + weight+ '%');
	    }  
    	
    	public boolean getShowPercent(){ 
			 if (weight != null){
			 	 return true;
			 }
			 return false;
    	}
    	
        public void setWeight(double w){
            weight = w;
        } 
    }
    
    public class AdditionalCommentDate{
		String createdDate;
		AdditionalComment__c additionalComment;
		
		public AdditionalCommentDate(AdditionalComment__c c){
			createdDate = c.LastModifiedDate.format();
			additionalComment = c;
		}
		
		public AdditionalComment__c getAdditionalComment(){
			return additionalComment;
		}
		
		public void setAdditionalComment(AdditionalComment__c c){
			additionalComment = c;
		}
		
		public String getCreatedDate(){
			return createdDate;
		}
		
		public void setCreatedDate(String s){
		}
		
	}
       
     /*
      * Inner class
      * contains utilities to keep the data of the method values 
      */
    public class Value {
    
        Value__c value;
        List<Method> methods;
    
        public Value(Value__c v, List<Method> m) {
            value = v;
            methods = m;
        }
    
        public String getId() {
            return value.Id;
        }
    
        public String getName() {
            if(value.Name.length() > 30){
                return value.Name.substring(0,25) + '...';               
            }else{
                return value.Name;
            }
        }  
    
        public String getFullName(){
            return value.Name;  
        }
    
        public List<Method> getMethods() {
            return methods;
        }
    
        public Integer getMethodCount() {
            return methods.size();
        }
    
        public String getTextMethod(){
            Integer sizeList = getMethodCount();
            if(sizeList == 1){
                return Label.method_requires_label + ' ';
            }
            return Label.method_requires_label + ' ';
        }
    }
    
	/*
	 * Inner class: utility class to obtain data with sharing rules
     */
    public with sharing class OverallUtil {
    
        List<User>             usersProfiles;
    
        // returns the performance review if the logged user is allowed to access it
        public PerformanceReview__c getPerformanceReviewWithSharing(Id id) {
    
            List<PerformanceReview__c> performanceReview = [Select  id,name,Employee__c,Employee__r.Name,Manager__c,Manager__r.Name,SecondManager__c,SecondManager__r.Name,PCOMM__c,
		                                                            PCOMM__r.Name,ThirdPartyReviewer__c,CompetencyGroup__c,CompetencyGroup__r.Name,PerformanceReviewPeriod__r.name,
		                                                            PerformanceReviewPeriod__r.Effective_Date__c,
		                                                            ReviewFormTemplate__r.MethodWeight__c,ReviewFormTemplate__r.CompetencyWeight__c,V2MOM__c,V2MOM__r.V2MOM_Type__c,
		                                                            V2MOM__r.Vision__c,OwnerId,Status__c,PreviousStatus__c,EmailComment__c,ReviewRating__c,PremierUser__c
                                                            From PerformanceReview__c Where Id=:id];
    
            if(performanceReview.size() == 0) return null;
    
            return performanceReview.get(0);
        }
    
        // returns the data of a method if the logged user is allowed to access it
        public List<MethodReview__c> getMethodReviewWithSharing(PerformanceReview__c p, Method__c m) {
            return [SELECT Rating__c, Status__c, Weight__c
                    FROM MethodReview__c WHERE PerformanceReview__c =: p.id
                    AND Reviewer__c =: p.Manager__c AND Method__c =: m.id];
        }
    
        // returns the data of the methods if the logged user is allowed to access it
        public Map<Id, MethodReview__c> getMethodReviewsWithSharing(PerformanceReview__c p, List<Method__c> m) {
    
            Map<Id, MethodReview__c> tempmap = new Map<Id, MethodReview__c>();
    
            for(MethodReview__c mr: [SELECT  Rating__c,Status__c,Weight__c, Method__c
                                     FROM MethodReview__c
                                     WHERE PerformanceReview__c =: p.id
                                     AND Reviewer__c =: p.Manager__c
                                     AND Method__c IN: m]) {
    
                tempmap.put(mr.Method__c, mr);
            }
    
            return tempmap;
        }
    
        // returns the data of the competencies if the logged user is allowed to access it
        public Map<Id, CompetencyReview__c> getCompetencyReviewWithSharingMap(PerformanceReview__c p, List<CompetencyGroupMember__c> c) {
    
            Map<Id, CompetencyReview__c> tempmap = new Map<Id, CompetencyReview__c>();
    
            for(CompetencyReview__c cr: [SELECT  Rating__c, CompetencyGroupMember__r.Competency__c, CompetencyGroupMember__c
                                         FROM CompetencyReview__c
                                         WHERE PerformanceReview__c =: p.id
                                         AND Reviewer__c =: p.Manager__c
                                         AND CompetencyGroupMember__c IN: c]) {
    
                tempmap.put(cr.CompetencyGroupMember__r.Competency__c, cr);
            }
            return tempmap;
        }
    
        // returns the data of the competency comments if the logged user is allowed to access it
        public List<AdditionalComment__c> getCommentsHistoryWithSharing(PerformanceReview__c p) {
        
            	 if ((p.Status__c ==  '3rd Party Assessment' && p.Manager__c == Userinfo.getUserId())
				 	|| p.Status__c ==  '3rd Party Assessment' && p.SecondManager__c == Userinfo.getUserId() )
				 	{
			            return [Select  id,Comment__c,Reviewer__c,PerformanceReview__c,CreatedBy.Name,CreatedDate,LastModifiedDate
			                    From AdditionalComment__c  
			                    Where PerformanceReview__c =: p.id
			                    ORDER BY CreatedDate ASC];
				 	}
				 	else
				 	{
				 		 return [Select  id,Comment__c,Reviewer__c,PerformanceReview__c,CreatedBy.Name,CreatedDate,LastModifiedDate
			                    From AdditionalComment__c  
			                    Where PerformanceReview__c =: p.id and locked__c =: true
			                    ORDER BY CreatedDate ASC];
				 	} 
        }
    
        // returns the data of the overall performance if the logged user is allowed to access it
        public ReviewRating__c getReviewRatingWithSharing(PerformanceReview__c p) {
    
            List<ReviewRating__c> reviewRating = [SELECT OverallRating__c,CalculatedRating__c FROM ReviewRating__c WHERE Id =: p.ReviewRating__c];
    
            if(reviewRating.size() == 0)
                return null;
            else
                return reviewRating[0];
        }   
    }
    
}