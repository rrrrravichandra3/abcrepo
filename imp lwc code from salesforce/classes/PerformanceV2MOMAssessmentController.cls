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
public with sharing class PerformanceV2MOMAssessmentController {
    
    PerformanceReview__c    		performanceReview;
    list<Method>            		methods;
    list<Method>            		methodsAlone;
    list<Method>            		allMethods;
    List<Value>             		values; 
    String 							v2momType = '';
    String 							v2momEffectiveDate = '';
    boolean 						isPCOMMLikeViewProfile;
    User 							currentUser;
    User 							scorecardTypeProfile;
    String 							userInf;
    ScorecardStep1 					scorecardReview;
    List<ScorecardSupportReview__c> scorecardSupportReviews;
    List<ScorecardSupportReview__c> listScorecard;
	ScorecardUtil 					scorecardUtil = new ScorecardUtil();
    MethodUtil 						util = new MethodUtil(); // class with sharing functions
    public PerformanceAccessUtil 	accessUtil;
	List<ScorecardSupportComment__c> scorecardComments;
	boolean 						isScorecardProfile;
	boolean							isSaving = false; // to avoid double comments
	  
    public class SharingException extends Exception {} // This needs to be refactored into external class as soon
    // they get this Apex thing right and let me extend an exception the right way

    boolean                 showCustomerSatisfaction = false;
    boolean                 showRenewals = false;
    boolean                 showSI = false;
    boolean                 showWMCases = false;
    boolean                 showWMSMES = false;
    boolean                 showWMHC = false;
    boolean                 showWMPA = false;
    boolean					showForecastAccuracy;
    boolean					showTimeOnPlatform;
    boolean					showSalesImpact;
    boolean					showCSM;
    boolean					showCSMOE;
    boolean					showCSMSTI;
    boolean					showCsmSalesImpact;
    boolean                 showNewCustomerSatisfaction = false;
    boolean					showWMCCP = false;
    boolean					showWMSO = false;
    boolean					showWMCAA = false;
    boolean					showWMBA = false;
    /*
     * Constructor
     */
    public PerformanceV2MOMAssessmentController (){
    	//List<Obstacle__c> obs = [select id, Test__c from Obstacle__c limit 1];
		userInf = UserInfo.getUserId();
    	constructor();
    }

    public PerformanceV2MOMAssessmentController (String userId){
		userInf = userId;
    	constructor();
    }
	public void RefreshSidebar()
	{
		userInf = UserInfo.getUserId();
		constructor();
	}
	public void a(){
		
	}
	private void constructor()
	{    	 
        Id performanceRevId = System.currentPageReference().getParameters().get('id');
    	// checks the id of the performance is not null
        if(performanceRevId != null) {			
			// checks the profile of the user
	        currentUser = [Select Id, u.Profile.Name, u.ProfileId From User u where id = :userInf];   		
			// gets the performance review completely
	        performanceReview = getPerformanceReviewWithoutSharing(performanceRevId);
			
	        if(performanceReview == null) 
	        	throw new SharingException(Label.PerformanceV2MOMAssessmentController_exception1);

			if ((performanceReview.V2MOM__r != null) && (performanceReview.V2MOM__r.V2MOM_Type__c != null)){
				v2momType = performanceReview.V2MOM__r.V2MOM_Type__c;
				v2momEffectiveDate = performanceReview.V2MOM__r.Effective_Date__c;
			}

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

            values = new list<Value>();
            methods = new list<Method>();
            methodsAlone = new list<Method>();
            allMethods = new list<Method>();
            list<Value__c> tempValues;
            list<Method__c> methodsc;
            list<Method__c> methodscAlone;          
           	tempValues = [SELECT Name, (SELECT Id FROM Methods__r) FROM Value__c WHERE V2MOM__c=:performanceReview.V2MOM__c ORDER BY Priority__c];                                     
          	methodsc = [SELECT Name, Value__c, Value__r.Name, V2MOM__c, V2MOM__r.Locked__c, V2MOM__r.V2MOM_Type__c, Description__c,
                        (Select name, description__c From Obstacles__r Order By Priority__c),
                        (Select name, description__c From Measures__r Order By Priority__c)
                        FROM Method__c
                        WHERE Value__c IN : tempValues ORDER BY Priority__c];
            
            methodscAlone = [SELECT  Name, Value__c, Value__r.Name, V2MOM__c, V2MOM__r.Locked__c, V2MOM__r.V2MOM_Type__c, Description__c,
                                     (Select name, description__c From Obstacles__r Order By Priority__c),
                                     (Select name, description__c From Measures__r Order By Priority__c)
                             FROM Method__c
                             WHERE V2MOM__c = :performanceReview.V2MOM__c and Value__c NOT IN : tempValues
                             ORDER BY Priority__c];                
                                        
            map<Id, MethodReview__c> mrs;
            list<MethodReview__c> methodReviewsComments;
            
            // gets data and comments of the methods within values
            if (isPCOMMLikeViewProfile || (performanceReview.Status__c == 'Employee Self Assessment' && performanceReview.Manager__c == userInfo.getUserId())){
            	mrs = getPerformanceReviewDataWithoutSharing(performanceReview, methodsc);
                
            	methodReviewsComments = getPerformanceReviewCommentWithoutSharing(performanceReview, methodsc);
            	
            }else{
            	mrs = util.getPerformanceReviewDataWithSharing(performanceReview, methodsc);
	           
	            methodReviewsComments = util.getPerformanceReviewCommentWithSharing(performanceReview, methodsc);
            }
            
           // methodReviewsComments = orderMethodReviewList(methodReviewsComments);          
            for(Value__c v: tempValues) {
                list<Method> valueMethods = new list<Method>();
                for(Method__c methodc: methodsc){
                    if(methodc.Value__c == v.Id){
                        Method method = addMethods(methodc, mrs, methodReviewsComments);   
                        methods.add(method);    
                        allMethods.add(method);
                        valueMethods.add(method);   
                    }
                }
                values.add( new Value(v, valueMethods));    
            }   
    
    		map<Id, MethodReview__c> mrsAlone;
            list<MethodReview__c> methodReviewsCommentsAlone = new list<MethodReview__c>();    		 		
            // gets data and comments of the methods alone
             if (isPCOMMLikeViewProfile || (performanceReview.Status__c == 'Employee Self Assessment' && performanceReview.Manager__c == userInfo.getUserId())){
            	mrsAlone = getPerformanceReviewDataWithoutSharing(performanceReview, methodscAlone);
            	methodReviewsCommentsAlone = getPerformanceReviewCommentWithoutSharing(performanceReview, methodscAlone);
            }else{
            	mrsAlone = util.getPerformanceReviewDataWithSharing(performanceReview, methodscAlone);
            	methodReviewsCommentsAlone = util.getPerformanceReviewCommentWithSharing(performanceReview, methodscAlone);            
            }    
            
           // methodReviewsCommentsAlone = orderMethodReviewList(methodReviewsCommentsAlone);
            
            for(Method__c methodc: methodscAlone){                   
                Method method = addMethods(methodc, mrsAlone, methodReviewsCommentsAlone);
                methodsAlone.add(method);
                allMethods.add(method);
            }     
     
            // gets the V2MOM Type
	        if ((v2momType != '') || (v2momType == null) || (v2momEffectiveDate != '') || (v2momEffectiveDate == null)){
	 	        List<V2MOM__c> v2momaux = [Select v.V2MOM_Type__c, v.Effective_Date__c
		                 	From V2MOM__c v
		                 	Where v.id=:performanceReview.V2MOM__c];
		        
		        if (v2momaux.size() > 0)
		        {
		        	v2momType = v2momaux.get(0).V2MOM_Type__c;
		        	v2momEffectiveDate = v2momaux.get(0).Effective_Date__c;
		        }
	        }	        
	        isScorecardProfile = accessUtil.getIsScorecardProfile();	        
	        if (isScorecardProfile){
		        //SCORECARDS
	            if (!isPCOMMLikeViewProfile){
			        // gets the data of the scorecards filtered with sharing
		    		scorecardSupportReviews =  ScorecardUtil.getScorecardSupportWithSharing(performanceReview);	    		
					// checks if there is no more than one scorecard per quarter
		    		if (!checkScorecards(scorecardSupportReviews))
		    			throw new SharingException(Label.PerformanceV2MOMAssessmentController_exception3);
		    		
			        scorecardReview = new ScorecardStep1(scorecardSupportReviews, performanceReview);
	            }else{
			        // gets the data of the scorecards filtered without sharing
		    		scorecardSupportReviews =  getScorecardSupportWithoutSharing(performanceReview);
		    		
					// checks if there is no more than one scorecard per quarter
		    		if (!checkScorecards(scorecardSupportReviews))
		    			throw new SharingException(Label.PerformanceV2MOMAssessmentController_exception4);
		    		
			        scorecardReview = new ScorecardStep1(scorecardSupportReviews, performanceReview, accessUtil.getStatusRO3() || (!accessUtil.getIsSysAdminProfile() && performanceReview.Status__c.equals('Manager Assessment')));
	            }	            
	            scorecardReview.setPerformanceAccessUtil(accessUtil);
	            
	             if ((performanceReview.Status__c ==  '3rd Party Assessment' && performanceReview.Manager__c == Userinfo.getUserId())
				 	|| performanceReview.Status__c ==  '3rd Party Assessment' && performanceReview.SecondManager__c == Userinfo.getUserId() )
				 	{
				 					scorecardComments = [SELECT Id, CommentCS__c, CommentRenewals__c,
	         						 CommentWMSMES__c, CommentWMHC__c, CommentWMCases__c,
	         						 CommentWMPA__c, CommentWMCCP__c, CommentWMCAA__c, CommentSupportInitiatives__c, CommentForecastAccuracy__c,
	         						 CommentSalesImpact__c, CommentTimeOnPlatform__c, CommentRenewalExcellence__c, CommentOperationalExcellence__c, CommentStrategicInitiatives__c, CommentCSMSalesImpact__c,
	         						 Reviewer__c FROM ScorecardSupportComment__c WHERE PerformanceReview__c =: performanceReview.Id AND Reviewer__c =: Userinfo.getUserId() ];	
				 	}
				 	else
				 	{
						 // retrieve the scorecards comments by the current user
					  	         	scorecardComments = [SELECT Id, CommentCS__c, CommentRenewals__c,
	         						 CommentWMSMES__c, CommentWMHC__c, CommentWMCases__c,
	         						 CommentWMPA__c, CommentWMCCP__c, CommentWMCAA__c, CommentSupportInitiatives__c, CommentForecastAccuracy__c,
	         						 CommentSalesImpact__c, CommentTimeOnPlatform__c, CommentRenewalExcellence__c, CommentOperationalExcellence__c, CommentStrategicInitiatives__c, CommentCSMSalesImpact__c,
	         						 Reviewer__c FROM ScorecardSupportComment__c WHERE PerformanceReview__c =: performanceReview.Id AND Reviewer__c =: userInf AND Locked__c = false ]; 		
				 	}
	           
	            // gets data of the metrics
	             listScorecard = [Select Id, FiscalQuarter__c 
	                       FROM ScorecardSupportReview__c  
	                       WHERE PerformanceReview__c =: performanceReview.Id ];
	        }else{
	        	listScorecard = new List<ScorecardSupportReview__c>();
	        }		        
		    isScorecardProfile = isScorecardProfile && (listScorecard.size() > 0);
        }       
        else 
        {
        	throw new SharingException(Label.PerformanceV2MOMAssessmentController_exception5);	
        }

	}	
	public boolean getIsScorecardProfile(){
		return isScorecardProfile;
	}
	
	public boolean getIsOldPerformanceReview(){ 
		if(performanceReview.PerformanceReviewPeriod__r.Effective_Date__c == 'FY08' || performanceReview.PerformanceReviewPeriod__r.Effective_Date__c == 'FY09'){
			return true;
		}
		
		return false;
	}
	
	public boolean getIsV2MOMLocked()
	{
		return ! performanceReview.V2MOM__r.locked__c; 
	}
	public ScorecardStep1 getScorecardReview(){		
		return scorecardReview;	
	}
	
	// returns true if there are methods within values to expand
	public boolean getShowExpandAllLink(){
		return (methods.size() > 0);
	}
	
	// checks if there is no more than one scorecard per quarter
	public boolean checkScorecards(List<ScorecardSupportReview__c> s){
		Integer checkQ1 = 0;
		Integer checkQ2 = 0;
		Integer checkQ3 = 0;
		Integer checkQ4 = 0;	
        for(ScorecardSupportReview__c scorecardReview: s) {
            if (scorecardReview.FiscalQuarter__c == 'Q1')
            {
                checkQ1 = checkQ1 + 1;
            }
            if (scorecardReview.FiscalQuarter__c == 'Q2')
            {
                checkQ2 = checkQ2 + 1;
            }
            if (scorecardReview.FiscalQuarter__c == 'Q3')
            {
                checkQ3 = checkQ3 + 1;
            }
            if (scorecardReview.FiscalQuarter__c == 'Q4')
            {
                checkQ4 = checkQ4 + 1;
            }
        }       
        if (v2momType == 'Individual Q1/Q2'){
        	if ((checkQ1 > 1) || (checkQ2 > 1))
        		return false;
        }
        if (v2momType == 'Individual Q3/Q4'){
        	if ((checkQ3 > 1) || (checkQ4 > 1))
        		return false;
        }      
		return true;
	}
		/*
		* BEGIN FUNCTIONS WITHOUT SHARING **************
		*/

		// gets the performance review without sharing
         public PerformanceReview__c getPerformanceReviewWithoutSharing(Id id) {

             list<PerformanceReview__c> performanceReview = [Select  id, name, Employee__c, Manager__c, SecondManager__c, PCOMM__c, ThirdPartyReviewer__c, PerformanceReviewPeriod__c, PerformanceReviewPeriod__r.name, PerformanceReviewPeriod__r.Effective_Date__c,
                                                             V2MOM__c, V2MOM__r.Vision__c, V2MOM__r.V2MOM_Type__c, V2MOM__r.Effective_Date__c, V2MOM__r.Locked__c, V2MOM__r.Name,
                                                             Status__c, PreviousStatus__c, ReviewFormTemplate__c, PremierUser__c
                                                             From PerformanceReview__c
                                                             Where Id = :id];
             if(performanceReview.size() == 0) return new PerformanceReview__c();
             return performanceReview.get(0);
         }

		// gets the data of the methods without sharing
		// and filters the data according to the logged user and the status of the performance review.
         public map<Id, MethodReview__c> getPerformanceReviewDataWithoutSharing(PerformanceReview__c p, list<Method__c> m){
             map<Id, MethodReview__c> tempmap = new map<Id, MethodReview__c>();
	             String reviewUser;
	             
	             if (p.Status__c.equals('Employee Self Assessment'))
	             	reviewUser = p.Employee__c;
	             else
	             	reviewUser = p.Manager__c;           
                 for(MethodReview__c mr: [Select r.Name, r.Comment__c, r.Method__c, r.CreatedDate, r.CreatedBy.Name, r.LastModifiedDate, r.Reviewer__c,  r.Reviewer__r.Name, r.Status__c, r.Weight__c, r.Rating__c 
                                          From MethodReview__c r 
                                          Where PerformanceReview__c =: p.Id 
                                          AND r.Reviewer__c =: reviewUser
                                          and Method__c IN : m]) {
                                          	
	                    if(p.PCOMM__c != userInfo.getUserId()){
		                    if (isPCOMMLikeViewProfile 
		                    && !(accessUtil.getIsSysAdminProfile() && p.Status__c.equals('Manager Assessment'))
		                    && (accessUtil.getStatusRO3() || p.Status__c.equals('Manager Assessment'))){
			                    mr.Weight__c = null;
			                    mr.Rating__c = null;
		                    }
	                    }
	                    
	                    if (isPCOMMLikeViewProfile && !accessUtil.getIsSysAdminProfile() 
	                    && (accessUtil.getStatusRO3()))
	                    	mr.Status__c = null;
	                    	
                     	tempmap.put(mr.Method__c, mr);
                 }
             return tempmap;
         }

		// gets the comments of the methods without sharing
		// and filters the comments according to the logged user and the status of the performance review.
         public list<MethodReview__c> getPerformanceReviewCommentWithoutSharing(PerformanceReview__c p, list<Method__c> m){
             list<MethodReview__c> tempmap = new list<MethodReview__c>();          
		    	Profile profile = [select Id, Name from Profile where Id =: userInfo.getProfileId()];	
		    	
		    	if(profile.ID == PerformanceAccessUtil.getSystem_Administrator_Id() || profile.Name=='systemadministrator'){
                 	for(MethodReview__c mr: [Select Name, CreatedBy.Name, CreatedDate, LastModifiedDate, Method__c, Comment__c, Rating__c, Reviewer__c, Reviewer__r.Name, Weight__c, Status__c 
					                         From MethodReview__c
					                         Where PerformanceReview__c =: p.id 
					                         and Method__c IN :m
					                         ORDER BY CreatedDate ASC]) {
				                        
                      tempmap.add(mr); 
                                             
	               }	
	               return tempmap;
                 }
		    	if (isPCOMMLikeViewProfile){
		    		if (!accessUtil.getStatusRO3()){
			    		if (!p.Status__c.equals('Manager Assessment')){
				    		if (!p.Status__c.equals('2nd Level Manager Assessment')){
								// any status except created, empl self assmnt, mngr assmnt 
								// or 2nd level mngr assmnt retrieve all
				                 
				                 for(MethodReview__c mr: [Select Name, CreatedBy.Name, CreatedDate, LastModifiedDate, Method__c, Comment__c, Rating__c, Reviewer__c, Reviewer__r.Name, Weight__c, Status__c 
										                         From MethodReview__c
										                         Where PerformanceReview__c =: p.id  and Method__c IN :m
										                         ORDER BY CreatedDate ASC]){
				                        
				                          tempmap.add(mr);
				            	}
				    		}else{
								// status 2nd level mngr assmnt retrieve all except the 2nd Manager comments								
				                 for(MethodReview__c mr: [Select Name, CreatedBy.Name, CreatedDate, LastModifiedDate, Method__c, Comment__c, Rating__c, Reviewer__c, Reviewer__r.Name, Weight__c, Status__c 
										                         From MethodReview__c
										                         Where PerformanceReview__c =: p.id and Locked__c = true and (Reviewer__c <>: p.SecondManager__c) and Method__c IN :m
										                         ORDER BY CreatedDate ASC]) {
				                        
				                          tempmap.add(mr);                        
				               }				                 
				    		}
			    		}else{
							// status mngr assmnt retrieve all except the Manager and 2nd Manager comments
			                 for(MethodReview__c mr: [Select Name, CreatedBy.Name, CreatedDate, Method__c, LastModifiedDate, Comment__c, Rating__c, Reviewer__c, Reviewer__r.Name, Weight__c, Status__c 
									                         From MethodReview__c
									                         Where PerformanceReview__c =: p.id and Locked__c = true and (Reviewer__c <>: p.SecondManager__c and Reviewer__c <>: p.Manager__c) and Method__c IN :m
									                         ORDER BY CreatedDate ASC]) {		                        
			                          tempmap.add(mr);
				               }
			    		}
		    		}
		    	}
		    	
				return tempmap;
         }     

		// gets the scorecard values without sharing
        public list<ScorecardSupportReview__c> getScorecardSupportWithoutSharing(PerformanceReview__c p){

            return [Select FiscalQuarter__c , WeightCS__c, AdjustedRatingCS__c, CalculatedRatingCS__c,
                                                        WeightRenewals__c, AdjustedRatingRenewals__c, CalculatedRatingRenewals__c,
                                                        WeightSI__c, AdjustedRatingSI__c, CalculatedRatingSI__c,
                                                        WeightWMCases__c, AdjustedRatingWMCases__c, CalculatedRatingWMCases__c,
                                                        WeightWMSMES__c, AdjustedRatingWMSMES__c, CalculatedRatingWMSMES__c,
                                                        WeightWMHC__c, AdjustedRatingWMHC__c, CalculatedRatingWMHC__c,                                                        
                                                        WeightWMPA__c, AdjustedRatingWMPA__c,
                                                        ForecastAccuracyActual__c, ForecastAccuracyTarget__c, ForecastAccuracyWeight__c, ForecastAccuracyRating__c ,
                                                        SalesImpactActual__c, SalesImpactWeight__c, SalesImpactTarget__c, SalesImpactRating__c,
                                                        TimeOnPlatformActual__c, TimeOnPlatformTarget__c, TimeOnPlatformWeight__c, TimeOnPlatformRating__c,   
                                                        RenewalExcellenceActual__c, RenewalExcellenceTarget__c, RenewalExcellenceRating__c, RenewalExcellenceWeight__c,
                                                        OperationalExcellenceActual__c, OperationalExcellenceWeight__c, OperationalExcellenceTarget__c, OperationalExcellenceRating__c,
                                                        StrategicInitiativesRating__c, StrategicInitiativesWeight__c,
                                                        CSMSalesImpactActual__c, CSMSalesImpactWeight__c, CSMSalesImpactTarget__c, CSMSalesImpactRating__c,
                                                        CustomerSatisfactionActual__c, CustomerSatisfactionTarget__c, RatingCustomerSatisfaction__c, WeightCustomerSatisfaction__c,
                                                        WMCCPActual__c, WMCCPWeight__c, WMCCPTarget__c, WMCCPRating__c,
                                                        WMCAAActual__c, WMCAAWeight__c, WMCAATarget__c, WMCAARating__c                                                                                                         
                                                   FROM ScorecardSupportReview__c  
                                                   WHERE PerformanceReview__c =: p.Id ];         
        }     

	/*
	* END FUNCTIONS WITHOUT SHARING **************
	*/
    // returns the values for the adjusted rating combo box
     public List<SelectOption> getRatingSelectOptions() {
         return PAMUtil.getRatingSelectOptionsToMethods();
     }
    // returns the values for the status combo box
     public List<SelectOption> getStatusSelectOptions() {
         return PAMUtil.getStatusSelectOptions();
     }
    
    // gets the Id of the current user
    public String getUserId(){
        return currentUser.Id;
    }
     
    // sets the current user
     public static void setUserInf (String userInf) {
        userInf = userInf;
     }
    
    // gets the profile of the current user
     public String getUserProfile(){
         return currentUser.Profile.Name;    
     }

    // gets the Id of the current user
    public String getCurrentUser(){
        return currentUser.Id;
    }
    
    // gets the V2MOM Type of the performance review
    public String getv2momType(){
        return v2momType;
    }
    
    public boolean getIsPremierUser(){
    	return performanceReview.PremierUser__c;
    }
    
    // gets the V2MOM Type of the performance review to show
    public String getv2momTypeToShow(){
        if (v2momType.equals('Individual Q1/Q2'))
        	return Label.IndividualQ1_Q2V2MOMType;
        if (v2momType.equals('Individual Q3/Q4'))
        	return Label.IndividualQ3_Q4V2MOMType;
        if (v2momType.equals('Individual'))
        	return Label.IndividualV2MOMType;
        if (v2momType.equals('Organization'))
        	return Label.OrganizationV2MOMType;
        if (v2momType.equals('Onboarding'))
        	return Label.Onboarding_label;
        if (v2momType.equals('Department'))
        	return Label.DepartmentV2MOMType;
        if (v2momType.equals('Ad Hoc'))
        	return Label.MyTeamController_AdHocType;
        return '';
    }
    
    // gets the Effective Date of the performance review
    public String getv2momEffectiveDate(){
        return v2momEffectiveDate;
    }
    
    // returns true if the quarter is Q1/Q2
    public boolean getIsQ1Q2(){
        return (getv2momType() == 'Individual Q1/Q2');
    }
    
    public boolean getShowEditCellQ1Q2(){
    	return getIsQ1Q2() && accessUtil.getIsMngrInAssmnt();
    }
    public boolean getShowEditCellQ3Q4(){
    	return (getv2momType() == 'Individual Q3/Q4') && accessUtil.getIsMngrInAssmnt();
    }
    
    // Returns the PerformanceReview
    public PerformanceReview__c getPerformanceReview(){
        return performanceReview;
    }
     
    // Returns values of performance review
    public list<Value> getValues() {
        return values;
    }
    
    // gets the label of the button for previous method
    public String getLabelPreviousMethod(){
        return '< ' + Label.Previous_Method_label;
    }

	// gets the label of the button for next method
    public String getLabelNextMethod(){
        return Label.Next_Method_label + ' >';
    }

	/*
	* BEGIN FUNCTIONS FOR METHODS **************
	*/
    
    // gets the weight of the method and metric section from the performance review template
    public String getMethodWeight() {
        ReviewFormTemplate__c rft = [Select MethodWeight__c 
                                     From ReviewFormTemplate__c r
                                     Where Id = :performanceReview.ReviewFormTemplate__c];
         return rft.MethodWeight__c + '';
    }

    // Return all methods with value
    public List<Method> getMethods() {
        return methods;
    }

    // Return all methods (with value and without value)
    public List<Method> getAllMethods() {
        return allMethods;
    }

    // Return all methods without value of performance review
    public List<Method> getMethodsAlone() {
        return methodsAlone;
    }

	// return the method review
    private Method addMethods(Method__c methodc, Map<Id, MethodReview__c> mrs, List<MethodReview__c> methodReviewsComments) {
        list<MethodReview__c> temp = new list<MethodReview__c>(); 
        Method method = new Method(methodc,  performanceReview);    
        MethodReview__c review = mrs.get(methodc.Id);
		
        if (review != null) {
            method.setReview(review);
            method.setRating(review.Rating__c);
            method.setWeight(review.Weight__c);
	        method.setUserProfile(getUserProfile()); 
	        method.setStatus(review.Status__c);
	        
	       
	        
            if ((accessUtil.getIs3PtInAssmnt() && performanceReview.PreviousStatus__c.equals('Manager Assessment'))
            || (accessUtil.getIsEmpl() && !(performanceReview.Status__c.equals('Complete') || performanceReview.Status__c.equals('Employee Approval')))
            || (accessUtil.getIsMngr2ndMngrOrPCOMM() && performanceReview.Status__c.equals('Employee Self Assessment'))
            || ((accessUtil.getIs2ndMngr() || accessUtil.getIsPCOMM()) && performanceReview.Status__c.equals('Manager Assessment')))
			{
				if(accessUtil.getIsPCOMM() && !accessUtil.getIsMngr()){		
		            method.setWeight(null);
		            review.Weight__c = null;
	            	method.setRating(null);
		            review.Rating__c = null;
				}
            }
            if(PerformanceReview.Status__c.equals('Employee Self Assessment') && performanceReview.Manager__c == userInfo.getUserId()){
            	method.setWeight(null);
            	review.Weight__c = null;
            	method.setRating(null);
	            review.Rating__c = null;
            }
        }
        else {
        	
            MethodReview__c tempReview = new MethodReview__c(Method__c = methodc.Id, Weight__c = null);
            tempReview.performanceReview__c = performanceReview.id;
            tempReview.Reviewer__c = userInf;
            method.setReview(tempReview);
	        method.setUserProfile(getUserProfile());
        }
        if (methodReviewsComments.size() > 0) {
            temp = getMethodReview(methodReviewsComments, methodc);
            method.setHistory(temp);        
	        method.setUserProfile(getUserProfile());
        }      

        return method;         
    }

	// gets the review for each method
    public list<MethodReview__c> getMethodReview(list<MethodReview__c> mrs, Method__c m) {      
        list<MethodReview__c> tempMe = new list<MethodReview__c>();

        for(MethodReview__c mr: mrs) {              
            if (mr.Method__c == m.Id){
                tempMe.add(mr);
            }               
        }

        return tempMe;
    }

     // Return the total of weight of all methods (format XX.XX)
     public Double getSumMethodsWeight(){            
         Double ret = 100;
         // sum method weights
         for(Method m: allMethods){              
             MethodReview__c newReview = m.getReview();

             if(newReview.Weight__c != null){  
                 ret = ret - newReview.Weight__c;
             }
         }    
         
         // if the performance is for an education employee and has scorecards
         // the weight of the education metrics should be added to the methods
	    if (scorecardTypeProfile.Profile.Name.equals('Education Employee') || scorecardTypeProfile.Profile.Name.equals('Education Manager')){
	    	if (getShowSupportScorecard()){
	    		if (scorecardReview.getSalesImpactWeight() != '-')
         			ret = ret - Double.valueOf(scorecardReview.getSalesImpactWeight());
	    		if (scorecardReview.getForecastAccuracyWeight() != '-')
	         		ret = ret - Double.valueOf(scorecardReview.getForecastAccuracyWeight());
	    		if (scorecardReview.getTimeOnPlatformWeight() != '-')
	         		ret = ret - Double.valueOf(scorecardReview.getTimeOnPlatformWeight());
	    	}
	    }
	    
	    if (scorecardTypeProfile.Profile.Name.equals('CSM Employee') || scorecardTypeProfile.Profile.Name.equals('CSM Manager')){
	    	if (getShowSupportScorecard()){
	    		if (scorecardReview.getCSMSalesImpactWeight() != '-')
         			ret = ret - Double.valueOf(scorecardReview.getCSMSalesImpactWeight());
	    		if (scorecardReview.getRenewalExcellenceWeight() != '-')
	         		ret = ret - Double.valueOf(scorecardReview.getRenewalExcellenceWeight());
	         	if (scorecardReview.getOperationalExcellenceWeight() != '-')
	         		ret = ret - Double.valueOf(scorecardReview.getOperationalExcellenceWeight());
         		if (scorecardReview.getStrategicInitiativesWeight() != '-')
	         		ret = ret - Double.valueOf(scorecardReview.getStrategicInitiativesWeight());	
	    	}
	    }
	    
	    if ((scorecardTypeProfile.Profile.Name.equals('Support Employee') && !scorecardReview.getIsOld() && !getIsPremierUser()) || (scorecardTypeProfile.Profile.Name.equals('Support Manager') && !scorecardReview.getIsOld() && !getIsPremierUser())){
	    	if (getShowSupportScorecard()){
	    		if (scorecardReview.getCustomerSatisfactionWeight() != '-')
         			ret = ret - Double.valueOf(scorecardReview.getCustomerSatisfactionWeight());
	    		if (scorecardReview.getWMCCPWeight() != '-')
	         		ret = ret - Double.valueOf(scorecardReview.getWMCCPWeight());
         		if (scorecardReview.getWMCAAWeight() != '-')
	         		ret = ret - Double.valueOf(scorecardReview.getWMCAAWeight());
	    	}
	    }
	    if ((scorecardTypeProfile.Profile.Name.equals('Support Employee') && !scorecardReview.getIsOld() && getIsPremierUser()) || (scorecardTypeProfile.Profile.Name.equals('Support Manager') && !scorecardReview.getIsOld() && getIsPremierUser())){
	    	if (getShowSupportScorecard()){
	    		if (scorecardReview.getCustomerSatisfactionWeight() != '-')
         			ret = ret - Double.valueOf(scorecardReview.getCustomerSatisfactionWeight());
	    		if (scorecardReview.getWMCCPWeight() != '-')
	         		ret = ret - Double.valueOf(scorecardReview.getWMCCPWeight());
	    	}
	    }
	    
         ret = ret * 100;
         ret = Math.round(ret);
         ret = ret / 100;   
         return ret;        
     }

     // Insert or update all MethodReview of methods
     public PageReference saveMethods(){
    	
    	PageReference page = null;
    	PerformanceReview__c perf = [select Id, PremierUser__c, Employee__c, Manager__c, ThirdPartyReviewer__c, PCOMM__c, SecondManager__c, Status__c, PreviousStatus__c
									from PerformanceReview__c where Id =: performanceReview.Id];

		PerformanceAccessUtil pau = new PerformanceAccessUtil(perf, currentUser, scorecardTypeProfile);
    		
		if (!isSaving){
			
    		isSaving = true;
    		
	         List<MethodReview__c> reviews = new List<MethodReview__c>();
	
	         for(Method m: allMethods) {
	             MethodReview__c newReview = m.getReview();
	
	             if ((newReview.Comment__c != null &&
	                     newReview.Comment__c != '') ||
	                     newReview.Rating__c != null ||
	                     newReview.Weight__c != null ||
	                     newReview.Status__c != null)
	             	{
	             	 
		             	 if (newReview.Status__c == null)
		             	 {
		             	 	newReview.Status__c = '-';	
		             	 }
		                 reviews.add(newReview);
	             }
	         }
	       
	         if(getShowReviewEdit()){
	         	 if(pau.getIsEmplMngr2ndMngrOr3PtInAssmnt()){       
	             	upsert reviews;
	             	isSaving = false;
	             	return page;
	         	 }
	         	 else{

	            	page = cannotSave();
	            	return page;
	            }            
	         }else{
	             throw new SharingException(Label.PerformanceV2MOMAssessmentController_exception6);
	         }	         
    		isSaving = false; 		
		}
		return page;
     }
 
	 public PageReference cannotSave(){
        	PageReference introPage = Page.PerformanceIntro;
        	introPage.getParameters().put('id', performanceReview.id);
            introPage.setRedirect(true);
            return introPage;	
    }
	/*
	* END FUNCTIONS FOR METHODS **************
	*/
	
	/*
	* BEGIN FUNCTIONS FOR METRIC WEIGHT PER QUARTER **************
	*/   
    // gets the sum of all metric weights for the quarter Q1
    public double getQ1ScorecardWeightSum(){
        return getQXScorecardWeightSum('Q1');
   }     

    // gets the sum of all metric weights for the quarter Q2
    public double getQ2ScorecardWeightSum(){
        return getQXScorecardWeightSum('Q2');
   }     

    // gets the sum of all metric weights for the quarter Q3
    public double getQ3ScorecardWeightSum(){
        return getQXScorecardWeightSum('Q3');
   }     

    // gets the sum of all metric weights for the quarter Q4
    public double getQ4ScorecardWeightSum(){
        return getQXScorecardWeightSum('Q4');
   }     

    // gets the sum of all metric weights for the quarter
    public double getQXScorecardWeightSum(String quarter){
        double sum = 0;
        if (scorecardSupportReviews != null) {
	        if (scorecardSupportReviews.size() > 0){                                               
	            for (ScorecardSupportReview__c sc: scorecardSupportReviews){
	                if (sc.FiscalQuarter__c == quarter){
	                    if (sc.WeightCS__c != null)
	                        sum = sum + sc.WeightCS__c;
	                    if (sc.WeightRenewals__c != null)
	                        sum = sum + sc.WeightRenewals__c;
	                    if (sc.WeightSI__c != null)
	                        sum = sum + sc.WeightSI__c;
	                    if (sc.WeightWMCases__c != null)
	                        sum = sum + sc.WeightWMCases__c;
	                    if (sc.WeightWMSMES__c != null)
	                        sum = sum + sc.WeightWMSMES__c;
	                    if (sc.WeightWMHC__c != null)
	                        sum = sum + sc.WeightWMHC__c;
	                    if (sc.WeightWMPA__c != null)
	                        sum = sum + sc.WeightWMPA__c;
	                }
	            }
	        }
        }
        return sum;
   }     

	/*
	* END FUNCTIONS FOR METRIC WEIGHT PER QUARTER **************
	*/	
	/*
	* BEGIN FUNCTIONS TO SHOW METRIC TABS **************
	*/
    
    public boolean getShowCustomerSatisfaction(){
        return showCustomerSatisfaction;    
    }
    
    public void ShowCustomerSatisfaction(){
        showCustomerSatisfaction = true;
    }
    
    public boolean getShowNewCustomerSatisfaction(){
        return showNewCustomerSatisfaction;    
    }
    
    public void ShowNewCustomerSatisfaction(){
        showNewCustomerSatisfaction = true;
    }
    public boolean getShowRenewals(){
        return showRenewals;    
    }
    
    public void ShowRenewals(){
        showRenewals = true;
    }
    
    public boolean getShowSI(){
        return showSI;  
    }
    
    public void ShowSI(){
        showSI = true;
    }
    
    public boolean getShowWMCases(){
        return showWMCases; 
    }
    
    public void ShowWMCases(){
        showWMCases = true;
    }
    
    public boolean getShowWMSMES(){
        return showWMSMES;  
    }
    
    public void ShowWMSMES(){
        showWMSMES = true;
    }
    
    public boolean getShowWMHC(){
        return showWMHC;    
    }
    
    public void ShowWMHC(){
        showWMHC = true;
    }
    
    public boolean getShowWMPA(){
        return showWMHC;    
    }
    
    public void ShowWMPA(){
        showWMHC = true;
    }
    
    public boolean getShowWMCCP(){
        return showWMCCP;    
    }
    
    public void ShowWMCCP(){
        showWMCCP = true;
    }
    
    public boolean getShowWMSO(){
        return showWMSO;    
    }
    
    public void ShowWMSO(){
        showWMSO = true;
    }
    
    public boolean getShowWMBA(){
        return showWMBA;    
    }
    
    public void ShowWMBA(){
        showWMBA = true;
    }
    public boolean getShowWMCAA(){
        return showWMCAA;    
    }
    
    public void ShowWMCAA(){
        showWMCAA = true;
    }
    
    public Boolean getShowForecastAccuracy(){
    	return showForecastAccuracy;
    }
    
    public Boolean getShowTimeOnPlatform(){
    	return showTimeOnPlatform;
    }
    
    public Boolean getShowSalesImpact(){
    	return showSalesImpact;
    }
    
    public Boolean getShowCSM(){
    	return showCSM;
    }
    
    public Boolean getShowCSMOE(){
    	return showCSMOE;
    }
    
    public Boolean getShowCSMSTI(){
    	return showCSMSTI;
    }
     
    public Boolean getShowCSMSalesImpact()
    {
    	return showCsmSalesImpact;
    }
    
    public void ShowCSM(){
    	showCSM = true;
    }
     
     public void ShowCSMOE(){
    	showCSMOE = true;
    }
    
    public void ShowCSMSTI(){
    	showCSMSTI = true;
    }
   public void ShowCsmSalesImpact()
   {
   	 showCsmSalesImpact = true;
   }
     public void ShowForecastAccuracy(){
    	showForecastAccuracy = true;
     }
    
    public void ShowTimeOnPlatform(){
    	showTimeOnPlatform = true;
    }
    
    public void ShowSalesImpact(){
    	showSalesImpact = true;
    }   
	/*
	* END FUNCTIONS TO SHOW METRIC TABS **************
	*/	  
	/*
	* BEGIN FUNCTIONS TO SHOW VALUES - ACCESS DESIGN **************
	*/
	// returns true if the performance review has scorecards
     public Boolean getShowSupportScorecard()
     {
         if ((v2momType != 'Individual Q1/Q2') && (v2momType != 'Individual Q3/Q4'))
         	return false;
         
         if (listScorecard.size() > 0)
         {
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
         else
         {
             return false;
         }
     }
 	// checks if it is assessment of metrics. This is used in the JavaScripts
    public boolean getShowReviewScorecard(){
		return accessUtil.getShowReviewScorecard();
    }   
    // checks if it is assessment of methods. This is used in the JavaScripts
     public boolean getShowReviewEdit() {
		return accessUtil.getShowReviewEdit();
     } 
	// returns true if it's the SysAdmin in the Manager Assessment status
	// Used to filter this condition for the gray background in metrics 
	public boolean getIsSysAdminInMngrAssmnt(){
		return accessUtil.getIsSysAdminInMngrAssmnt();
	}
     // Return true if the logged user is the manager of performance review or a SysAdmin
     // in the manager assessment status (can edit elements)
     public boolean getIsManager() {
		return accessUtil.getIsManager();
     }
	
	public boolean getIsEmplInAssmntOnly(){
     	return accessUtil.getIsEmplInAssmntOnly();
     }
     // Return true if the logged user is the employee of performance review no matter the status
     public boolean getIsEmployee() {
		return accessUtil.getIsEmployee();
     }
     
     // checks the logged user is the manager of the performance review or a SysAdmin no matter the status
    public boolean getIsManagerOrSecondManager()
    {
		return accessUtil.getIsManagerOrSecondManager();
    }
     // checks the logged user is the manager, 2nd manager or 3rd party
     // of the performance review or a SysAdmin no matter the status
    public boolean getIsManagerOrSecondManager3P()
    {
		return accessUtil.getIsManagerOrSecondManager3P();
    }
    //-----------------  USER PROFILES ----------------------------------------------------------------
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
    
    public boolean getNotShowCSMTo3rdParty(){
    	if(getIsCSMProfile() && !getIs3PtInAssmnt()){
    		return true;
    	}
    	return false;
    }
    // Return true if the logged user is of System Administrator profile
    public boolean getIsSysAdminProfile(){
		return accessUtil.getIsSysAdminProfile();
    }
    
    // checks all the profiles that can view the scorecards if there are scorecards
    public boolean getScorecardViewProfile(){
        if (! getShowSupportScorecard()){
            return false;   
        }  
		return accessUtil.getScorecardViewProfile();
    }
    
    //--------------------- USER ACCESS FUNCTIONS -------------------------------------------------
     // Return true if the logged user is the employee of performance review no matter the status
     public boolean getIsEmpl() {
		return accessUtil.getIsEmpl();
     }

     // Return true if the logged user is the manager of performance review no matter the status
     public boolean getIsMngr() {
		return accessUtil.getIsMngr();
     }
           
    // Employee in Assessment - Write permission
     public boolean getIsEmplInAssmnt() {
		return accessUtil.getIsEmplInAssmnt();
     }   
     
    // Manager in Assessment - Write permission
     public boolean getIsMngrInAssmnt() {
		return accessUtil.getIsMngrInAssmnt();
     }   
     
     // 3rd Party in Assessment - Write permission
     public boolean getIs3PtInAssmnt() {
		return accessUtil.getIs3PtInAssmnt();
     }   
      
    // Employee, Manager, 2nd Manager or 3rd Party in Assessment - Write permission
     public boolean getIsEmplMngr2ndMngrOr3PtInAssmnt() {
		return accessUtil.getIsEmplMngr2ndMngrOr3PtInAssmnt();
     }     
      // Manager, 2nd Manager or 3rd Party in Assessment - Write permission in scorecard object
     public boolean getIsMngr2ndMngrOr3PtInAssmnt() {
		return accessUtil.getIsMngr2ndMngrOr3PtInAssmnt();
     } 
	
	 public boolean getIsEmplMngr2ndMngr(){
         return accessUtil.getIsEmplMngr2ndMngr();
     } 
     
     // shows save buttons for users that are in assessment status and have NO scorecards
     public boolean getIsSaveMode(){
		return accessUtil.getIsSaveMode();
     }
     
     // shows save buttons for users that are in assessment status and have scorecards
     public boolean getIsSaveScorecardMode(){
		return (accessUtil.getIsSaveScorecardMode() && (listScorecard.size() > 0)) || (accessUtil.getIsCSMProfile() && accessUtil.getIsEmplInAssmntOnly());
     }
	/*
	* END FUNCTIONS TO SHOW VALUES - ACCESS DESIGN **************
	*/	
	/*
	 * BEGIN FUNCTIONS TO GET METRIC COMMENTS *********************
	*/

     // Return comment for current user from scorecard comment in table customer satisfaction
     public String getCommentCS(){
         if (scorecardComments.size() > 0){
             return scorecardComments[0].CommentCS__c;
         }
         else{
             return '';
         }   
     }

     // Return comment for current user from scorecard comment in table renewals
     public String getCommentRenewals(){
         if (scorecardComments.size() > 0){
             return scorecardComments[0].CommentRenewals__c;
         }
         else{
             return '';
         }  
     }

     // Return comment for current user from scorecard comment in table health checks
     public String getCommentWMHC(){
         if (scorecardComments.size() > 0){
             return scorecardComments[0].CommentWMHC__c;
         }
         else{
             return '';
         }  
     }
     
     public String getCommentWMCCP(){
         if (scorecardComments.size() > 0){
             return scorecardComments[0].CommentWMCCP__c;
         }
         else{
             return ''; 
         }  
     }
     
     public String getCommentWMCAA(){
         if (scorecardComments.size() > 0){
             return scorecardComments[0].CommentWMCAA__c;
         }
         else{
             return ''; 
         }  
     }

     // Return comment for current user from scorecard comment in table support initiatives
     public String getCommentSupportInitiatives(){
         if (scorecardComments.size() > 0){
             return scorecardComments[0].CommentSupportInitiatives__c;
         }
         else{
             return '';
         }   
     }

     // Return comment for current user from scorecard comment in table sme
     public String getCommentWMSMES(){
         if (scorecardComments.size() > 0){
             return scorecardComments[0].CommentWMSMES__c;
         }
         else{
             return '';
         }   
     }

     // Return comment for current user from scorecard comment in table procedure adherence
     public String getCommentWMPA(){
         if (scorecardComments.size() > 0){
             return scorecardComments[0].CommentWMPA__c;
         }
         else{
             return '';
         }   
     }
     
     // Return comment for current user from scorecard comment in table cases
     public String getCommentWMCases(){
         if (scorecardComments.size() > 0){
             return scorecardComments[0].CommentWMCases__c;
         }
         else{
             return '';
         }   
     }
     
     // Return comment for current user from scorecard comment in table customer satisfaction
     public String getCommentForecastAccuracy(){
         if (scorecardComments.size() > 0){
             return scorecardComments[0].CommentForecastAccuracy__c;
         }
         else{
             return '';
         }   
     }
     
     // Return comment for current user from scorecard comment in table customer satisfaction
     public String getCommentTimeOnPlatform(){
         if (scorecardComments.size() > 0){
             return scorecardComments[0].CommentTimeOnPlatform__c;
         }
         else{
             return '';
         }   
     }

     // Return comment for current user from scorecard comment in table customer satisfaction
     public String getCommentSalesImpact(){
         if (scorecardComments.size() > 0){
             return scorecardComments[0].CommentSalesImpact__c;
         }
         else{
             return '';
         }   
     }
     
     // Return comment for current user from scorecard comment in table CSM
     public String getCommentRenewalExcellence(){
         if (scorecardComments.size() > 0){
             return scorecardComments[0].CommentRenewalExcellence__c;
         }
         else{
             return '';
         }   
     }
     
     public String getCommentOperationalExcellence(){
         if (scorecardComments.size() > 0){
             return scorecardComments[0].CommentOperationalExcellence__c;
         }
         else{
             return '';
         }   
     }
     public String getCommentStrategicInitiatives(){
         if (scorecardComments.size() > 0){
             return scorecardComments[0].CommentStrategicInitiatives__c;
         }
         else{
             return '';
         }   
     }
     
     public String getCommentCSMSalesImpact(){
         if (scorecardComments.size() > 0){
             return scorecardComments[0].CommentCSMSalesImpact__c;
         }
         else{
             return '';
         }   
     }

	/*
	 * END FUNCTIONS TO GET METRIC COMMENTS *********************
	*/
	
	/*
	 * BEGIN FUNCTIONS TO CHECK IF THE METRIC IS COMPLETE *********************
	*/

     // Returns true if comment had been saved in table customer satisfaction
     
     public boolean getIsCompleteCS() {
         string comment = getCommentCS();
         return getIsComplete(comment);
     }
	
     // Returns true if comment had been saved in table renewals 
     public boolean getIsCompleteRenewals() {
         string comment = getCommentRenewals();
         return getIsComplete(comment);
     }

     // Returns true if comment had been saved in table health checks 
     public boolean getIsCompleteWMHC() {
         string comment = getCommentWMHC();
         return getIsComplete(comment);
     }

     // Returns true if comment had been saved in table sme 
     public boolean getIsCompleteWMSMES() {
         string comment = getCommentWMSMES();
         return getIsComplete(comment);
     }
     
     // Returns true if comment had been saved in table cases 
     public boolean getIsCompleteWMCases() {
         string comment = getCommentWMCases();
         return getIsComplete(comment);
     }

     // Returns true if comment had been saved in table procedure adherence 
     public boolean getIsCompleteWMPA() {
         string comment = getCommentWMPA();
         return getIsComplete(comment);
     }

     // Returns true if comment had been saved in table support initiatives 
     public boolean getIsCompleteSupportInitiatives() {
         string comment = getCommentSupportInitiatives();
         return getIsComplete(comment);
     }
     
     // Returns true if data had been saved in table forecast accuracy 
     public boolean getIsCompleteForecastAccuracy() {
         if(accessUtil.getIsMngrInAssmnt()){
	     	 if ((scorecardReview.getForecastAccuracyWeight() == null) || (scorecardReview.getForecastAccuracyWeight() == '') 
	     	  || (scorecardReview.getForecastAccuracyRating() == null) || (scorecardReview.getForecastAccuracyRating() == null)
	     	   || scorecardReview.getForecastAccuracyRating() == '-' )
	     	 	return false;
         }
         
         string comment = getCommentForecastAccuracy();
         return getIsComplete(comment);
     }
     
     // Returns true if data had been saved in table time on platform 
     public boolean getIsCompleteTimeOnPlatform() {
         if(accessUtil.getIsMngrInAssmnt()){
	     	 if ((scorecardReview.getTimeOnPlatformWeight() == null) || (scorecardReview.getTimeOnPlatformWeight() == '') 
	     	  || (scorecardReview.getTimeOnPlatformRating() == null) || (scorecardReview.getTimeOnPlatformRating() == null)
	     	  || scorecardReview.getTimeOnPlatformRating() == '-' )
	     	 	return false;
         }
         
         string comment = getCommentTimeOnPlatform();
         return getIsComplete(comment);
     }
     
     // Returns true if data had been saved in table sales impact 
     public boolean getIsCompleteSalesImpact() {
         if(accessUtil.getIsMngrInAssmnt()){
	     	 if ((scorecardReview.getSalesImpactWeight() == null) || (scorecardReview.getSalesImpactWeight() == '') 
	     	  || (scorecardReview.getSalesImpactRating() == null) || (scorecardReview.getSalesImpactRating() == null)
	     	   || scorecardReview.getSalesImpactRating() == '-')
	     	 	return false;
         }
         
         string comment = getCommentSalesImpact();
         return getIsComplete(comment);
     }

     // Returns true if comment had been saved
     public boolean getIsComplete(String comment) {
     	 if ((comment == '') || (comment == null))
     	 	return false;

         if(userInf.equals(performanceReview.Employee__c) &&
                 performanceReview.Status__c.equals('Employee Self Assessment'))
             return true;     	   

         if(userInf.equals(performanceReview.Manager__c) &&
                 performanceReview.Status__c.equals('Manager Assessment'))
             return true;

         if(accessUtil.getIs2ndMngrInAssmnt())
             return true;

         if(accessUtil.getIs3PtInAssmnt())
             return true;

         return false;
     }
     
     // Returns true if data had been saved in table CSM 
     public boolean getIsCompleteRenewalExcellence() {
         if(currentUser.Profile.Name == Label.System_Administrator_label && performanceReview.Status__c.equals('Employee Self Assessment')
         	|| currentUser.Profile.Name == Label.System_Administrator_label && performanceReview.Status__c.equals('3rd Party Assessment')){
   			return false;
   		 }
         if(accessUtil.getIsMngrInAssmnt() && currentUser.Profile.Name != Label.System_Administrator_label ){
	     	 if ((scorecardReview.getRenewalExcellenceWeight() == null) || (scorecardReview.getRenewalExcellenceWeight() == '') 
	     	  || (scorecardReview.getRenewalExcellenceRating() == null)
	     	  || scorecardReview.getRenewalExcellenceRating() == '-' )
	     	 	return false;
         }
         else
         {
         	if (currentUser.Profile.Name == Label.System_Administrator_label)
         	{
         		if ((scorecardReview.getRenewalExcellenceWeight() == null) || (scorecardReview.getRenewalExcellenceWeight() == '') 
	     	  || (scorecardReview.getRenewalExcellenceRating() == null)
	     	  || scorecardReview.getRenewalExcellenceRating() == '-' )
		     	  {
		     	 	return false;
		     	  }
		     	  else
		     	  {
		     	  	return true;
		     	  }
         	}
         }
         string comment = getCommentRenewalExcellence();
         return getIsComplete(comment);
     }
     
     public boolean getIsCompleteOperationalExcellence() {
        if(currentUser.Profile.Name == Label.System_Administrator_label && performanceReview.Status__c.equals('Employee Self Assessment')
         	|| currentUser.Profile.Name == Label.System_Administrator_label && performanceReview.Status__c.equals('3rd Party Assessment')){
   			return false;
   		 }
         if(accessUtil.getIsMngrInAssmnt() && currentUser.Profile.Name != Label.System_Administrator_label ){
	     	 if ((scorecardReview.getOperationalExcellenceWeight() == null) || (scorecardReview.getOperationalExcellenceWeight() == '') 
	     	  || (scorecardReview.getOperationalExcellenceRating() == null)
	     	  || scorecardReview.getOperationalExcellenceRating() == '-' )
	     	 	return false;
         }
         else
         {
         	if (currentUser.Profile.Name == Label.System_Administrator_label)
         	{
         		if ((scorecardReview.getOperationalExcellenceWeight() == null) || (scorecardReview.getOperationalExcellenceWeight() == '') 
	     	  || (scorecardReview.getOperationalExcellenceRating() == null)
	     	  || scorecardReview.getOperationalExcellenceRating() == '-' )
		     	  {
		     	 	return false;
		     	  }
		     	  else
		     	  {
		     	  	return true;
		     	  }
         	}
         }
         string comment = getCommentOperationalExcellence();
         return getIsComplete(comment);
     }
     
     public boolean getIsCompleteStrategicInitiatives() {
         if(currentUser.Profile.Name == Label.System_Administrator_label && performanceReview.Status__c.equals('Employee Self Assessment')
         	|| currentUser.Profile.Name == Label.System_Administrator_label && performanceReview.Status__c.equals('3rd Party Assessment')){
   			return false;
   		 }
         if(accessUtil.getIsMngrInAssmnt() && currentUser.Profile.Name != Label.System_Administrator_label ){
	     	 if ((scorecardReview.getStrategicInitiativesWeight() == null) || (scorecardReview.getStrategicInitiativesWeight() == '') 
	     	  || (scorecardReview.getStrategicInitiativesRating() == null)
	     	  || scorecardReview.getStrategicInitiativesRating() == '-' )
	     	 	return false;
         }
         else
         {
         	if (currentUser.Profile.Name == Label.System_Administrator_label)
         	{
         		if ((scorecardReview.getStrategicInitiativesWeight() == null) || (scorecardReview.getStrategicInitiativesWeight() == '') 
	     	  || (scorecardReview.getStrategicInitiativesRating() == null)
	     	  || scorecardReview.getStrategicInitiativesRating() == '-' )
		     	  {
		     	 	return false;
		     	  }
		     	  else
		     	  {
		     	  	return true;
		     	  }
         	}
         }
         string comment = getCommentStrategicInitiatives();
         return getIsComplete(comment);
     }
     
     public boolean getIsCompleteCSMSalesImpact() {
         if(currentUser.Profile.Name == Label.System_Administrator_label && performanceReview.Status__c.equals('Employee Self Assessment')
         	|| currentUser.Profile.Name == Label.System_Administrator_label && performanceReview.Status__c.equals('3rd Party Assessment')){
   			return false;
   		 }
         if(accessUtil.getIsMngrInAssmnt() && currentUser.Profile.Name != Label.System_Administrator_label ){
	     	 if ((scorecardReview.getCSMSalesImpactWeight() == null) || (scorecardReview.getCSMSalesImpactWeight() == '') 
	     	  || (scorecardReview.getCSMSalesImpactRating() == null) 
	     	  || scorecardReview.getCSMSalesImpactRating() == '-' ) 
	     	 	return false;
         }
         else
         {
         	
         	if (currentUser.Profile.Name == Label.System_Administrator_label)
         	{
	         	if ((scorecardReview.getCSMSalesImpactWeight() == null) || (scorecardReview.getCSMSalesImpactWeight() == '') 
		     	  || (scorecardReview.getCSMSalesImpactRating() == null) 
		     	  || scorecardReview.getCSMSalesImpactRating() == '-' ) 
		     	  {
		     	 	return false;
		     	  }
		     	  else
		     	  {
		     	  	return true;
		     	  }
         	}
         }
         
         string comment = getCommentCSMSalesImpact();
         return getIsComplete(comment);
     } 
     
     public boolean getIsCompleteWMCCP() {
     	if(performanceReview.Status__c.equals('Employee Approval'))
     	 	return false;	
   		if(currentUser.Profile.Name == Label.System_Administrator_label && performanceReview.Status__c.equals('Employee Self Assessment')
         	|| currentUser.Profile.Name == Label.System_Administrator_label && performanceReview.Status__c.equals('3rd Party Assessment')){
   			return false;
   		 }
         if(accessUtil.getIsMngrInAssmnt() && currentUser.Profile.Name != Label.System_Administrator_label ){
	     	 if ((scorecardReview.getWMCCPWeight() == null) || (scorecardReview.getWMCCPWeight() == '') 
	     	  || (scorecardReview.getWMCCPRating() == null) 
	     	  || scorecardReview.getWMCCPRating() == '-' ) 
	     	 	return false;
         }
         else
         {
         	
         	if (currentUser.Profile.Name == Label.System_Administrator_label)
         	{
	         	if ((scorecardReview.getWMCCPWeight() == null) || (scorecardReview.getWMCCPWeight() == '') 
		     	  || (scorecardReview.getWMCCPRating() == null) 
		     	  || scorecardReview.getWMCCPRating() == '-' ) 
		     	  {
		     	 	return false;
		     	  } 
		     	  else   
		     	  {
		     	  	return true;
		     	  }
         	}
         }
         
         string comment = getCommentWMCCP();
         return getIsComplete(comment);
     }
     
     public boolean getIsCompleteWMCAA() {
     	if(performanceReview.Status__c.equals('Employee Approval'))
     	 	return false;	
         if(currentUser.Profile.Name == Label.System_Administrator_label && performanceReview.Status__c.equals('Employee Self Assessment')
         	|| currentUser.Profile.Name == Label.System_Administrator_label && performanceReview.Status__c.equals('3rd Party Assessment')){
   			return false;
   		 }
         if(accessUtil.getIsMngrInAssmnt() && currentUser.Profile.Name != Label.System_Administrator_label ){
	     	 if ((scorecardReview.getWMCAAWeight() == null) || (scorecardReview.getWMCAAWeight() == '') 
	     	  || (scorecardReview.getWMCAARating() == null) 
	     	  || scorecardReview.getWMCAARating() == '-' ) 
	     	 	return false;
         }
         else 
         {
         	
         	if (currentUser.Profile.Name == Label.System_Administrator_label)
         	{
	         	if ((scorecardReview.getWMCAAWeight() == null) || (scorecardReview.getWMCAAWeight() == '') 
		     	  || (scorecardReview.getWMCAARating() == null) 
		     	  || scorecardReview.getWMCAARating() == '-' ) 
		     	  {
		     	 	return false;
		     	  } 
		     	  else   
		     	  {
		     	  	return true;
		     	  }
         	}
         }
         
         string comment = getCommentWMCAA();
         return getIsComplete(comment);
     }
     
     public boolean getIsCompleteNewCS() {
     	if(performanceReview.Status__c.equals('Employee Approval'))
     	 	return false;	
         if(currentUser.Profile.Name == Label.System_Administrator_label && performanceReview.Status__c.equals('Employee Self Assessment')
         	|| currentUser.Profile.Name == Label.System_Administrator_label && performanceReview.Status__c.equals('3rd Party Assessment')){
   			return false;
   		 }
         if(accessUtil.getIsMngrInAssmnt() && currentUser.Profile.Name != Label.System_Administrator_label ){
	     	 if ((scorecardReview.getCustomerSatisfactionWeight() == null) || (scorecardReview.getCustomerSatisfactionWeight() == '') 
	     	  || (scorecardReview.getCustomerSatisfactionRating() == null) 
	     	  || scorecardReview.getCustomerSatisfactionRating() == '-' ) 
	     	 	return false;
         }
         else
         {
         	
         	if (currentUser.Profile.Name == Label.System_Administrator_label)
         	{
	         	if ((scorecardReview.getCustomerSatisfactionWeight() == null) || (scorecardReview.getCustomerSatisfactionWeight() == '') 
		     	  || (scorecardReview.getCustomerSatisfactionRating() == null) 
		     	  || scorecardReview.getCustomerSatisfactionRating() == '-' ) 
		     	  {
		     	 	return false;
		     	  }
		     	  else
		     	  {
		     	  	return true;
		     	  }
         	}
         }
         
         string comment = getCommentCS();
         return getIsComplete(comment);
     }

	/*
	 * END FUNCTIONS TO CHECK IF THE METRIC IS COMPLETE *********************
	*/
	
	/*
	 * BEGIN SAVE FUNCTIONS *********************
	*/
     // Implement action of button Save
     // @return PageReference 
     public PageReference save() {
         return saveMethods();
         /** PageReference newPeopleforceStep1 = Page.NewPeopleForceStep1;
         newPeopleforceStep1.getParameters().put('id', performanceReview.id);
         newPeopleforceStep1.setRedirect(true);
         return newPeopleforceStep1;
         */
     }

     // Implement action of button Save
     public PageReference saveNew() {
         return saveMethods();
     }

     // Implement action of button Save and Continue
     public PageReference saveContinue() {
         saveMethods();

         PageReference newPeopleforceStep2 = Page.NewPeopleForceStep2;
         newPeopleforceStep2.getParameters().put('id', performanceReview.id);
         newPeopleforceStep2.setRedirect(true);
         return newPeopleforceStep2;
     }

     // Implement action of button Save and Continue
     public void saveContinueNew() {
         saveMethods();
     }

	/*
	 * END SAVE FUNCTIONS *********************
	*/

     /*
      * Inner class
      * value - one value of performance review
      * methods - all methods of performance review within value 
      */
     public class Value {

         Value__c value;
         list<Method> methods;

         public Value(Value__c v, list<Method> m) {
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

         public list<Method> getMethods() {
         	
             return methods;
         }

         public Integer getMethodCount() {
             return methods.size();
         }

         public String getTextMethod(){
             Integer sizelist = getMethodCount();
             if(sizelist == 1){
                 return Label.method_requires_label + ' ';
             }
             return Label.method_requires_label + ' ';
         }
     }


	public class MethodReviewDate{
		String createdDate;
		MethodReview__c methodReview;
		String lastModifiedDate;
		String reviewerName;
		
		public MethodReviewDate(MethodReview__c c){
			createdDate = c.CreatedDate.format();
			methodReview = c;
			reviewerName = c.Reviewer__r.Name;
			lastModifiedDate = c.LastModifiedDate.format();
		}
		
		public MethodReview__c getMethodReview(){
			return methodReview;
		}
		
		public void setMethodReview(MethodReview__c c){
			methodReview = c;
		}
		
		public String getReviewerName(){
			return reviewerName;
		}
		
		public String getCreatedDate(){
			return createdDate;
		}
		
		public String getLastModifiedDate(){
			return lastModifiedDate;
		}
		
		public void setCreatedDate(String s){
		}
		
	}

     /*
      * Inner class
      * method - one method or performance review
      * review - methodreview of method
      */
     public class Method{

         Method__c method;
         public MethodReview__c review;

         double rating;
         String ratingReview;
         double weight;
         String status;
         
         String userId = userInfo.getUserId();
         String userProfile;

         list<MethodReview__c> history;
         list<Obstacle__c> obstacles;
         list<Measure__c> metrics;
         PerformanceReview__c performance;

         public Method(Method__c m, PerformanceReview__c p){
             method = m;
             obstacles = m.Obstacles__r;
             metrics = m.Measures__r;
             performance = p;
         }

	     public void setUserProfile(String profile){
	         userProfile = profile;    
	     }

         public Method__c getMethod(){
             return method;
         }

         public void setMethod(Method__c m){
             method = m;
         }

         public String getRatingReview(){
         	if(((performance.PreviousStatus__c == 'Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
				||((performance.PreviousStatus__c == '2nd Level Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
				|| ((performance.Status__c == '3rd Party Assessment') && (performance.PCOMM__c == userInfo.getUserId()))){
					return '-';
			}
			
			 if(performance.Status__c != 'Manager Assessment'){
             	if (rating != null){
             		if(rating == -1) return 'N/A';
             	  return String.valueOf(rating);
			 	}
			 }
             if (review == null){
             	  return '-';
             }
             if (review.Rating__c == null){
              	return '-';
             }
			 if (review.Rating__c == -1) return 'N/A'; 	
			 
             return String.valueOf(review.Rating__c.intValue());
         }

         public void setRating(double r){
             if(review != null){
                 if(r != null){
                     review.Rating__c = r;
                 }
             }                    
         }

         public Integer getRating(){
             if(review == null) return 0;
             if(review.Rating__c == null) return 0;

             return review.Rating__c.intValue();
         }

         public String getStatus(){
             if(status != null) return status;
             if(review == null) return '-';
             if(review.status__c == null) return '-';
			 	 
			 if(review.Status__c == 'Completed'){
	           return Label.Status_Completed_Label;
	         }
	         if(review.Status__c == 'In Progress'){
	           return Label.Status_In_Progress_Label;
	         }
	         if(review.Status__c == 'N/A'){
	           return Label.Status_NA_Label;
	         }
	         
             return '-';
         }

         public void setStatus(String s){
            
             if(review != null){
                 review.status__c= s;
             }
         }

         public boolean getShowHistory(){
             if(history != null){
                 return (history.size() > 0);
             }
             return false;    
         }

         public String getWeight(){
         	if(((performance.PreviousStatus__c == 'Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
				||((performance.PreviousStatus__c == '2nd Level Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
				|| ((performance.Status__c == '3rd Party Assessment') && (performance.PCOMM__c == userInfo.getUserId()))){
					return '-';
			}
             if (weight != null) return (String.valueOf(weight));
             if (review == null) return '';
             if (review.weight__c == null) return '';

             return (String.valueOf(review.weight__c));
         }

		
		 public String getWeightShow()
		 {
			if(((performance.PreviousStatus__c == 'Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
				||((performance.PreviousStatus__c == '2nd Level Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
				|| ((performance.Status__c == '3rd Party Assessment') && (performance.PCOMM__c == userInfo.getUserId()))){
					return '-';
			}
		 	 if (UserInfo.getUserId() == performance.Employee__c)
		 	 {
	
		 	 	if (performance.Status__c != 'Complete' && performance.Status__c != 'Employee Approval')
		 	 	{
		 	 		return '-';
		 	 	}
		 	 }
		 	 
		 	 if (weight != null) return (String.valueOf(weight) + '%');
		 	  
             if (review == null) return '-';
             if (review.weight__c == null) return '-';

             return (String.valueOf(review.weight__c) + '%');
		 }
         public void setWeight(double w){
             if(review != null){
                 review.weight__c = w;
             }
         }

         public MethodReview__c getReview() {
             return review;
         }

         public void setReview(MethodReview__c m) {                  
             review = m;
         }

         public list<MethodReview__c> getHistory() {
             return history;
         }

        public List<MethodReviewDate> getHistoryFormatted() {
        	
        	List<MethodReviewDate> result = new List<MethodReviewDate>();
        	
        	if ((history != null) && (history.size() > 0)){
	        	for (MethodReview__c c : history) {
	        		result.add(new MethodReviewDate(c));
	        	}
        	}
        	
            return result;
        }
		
		/*
		public boolean isSysAdminPartOfHierarchy(){
			if(userProfile == 'System Administrator'){
				if(userId == performance.Employee__c || userId == performance.Manager__c || userId == performance.SecondManager__c || userId == performance.PCOMM__c){
					return true;
				}
			}
			return false;
		}	
		*/
         public void setHistory(list<MethodReview__c> h) {                   
             history = new list<MethodReview__c>();

             // process history
             for(MethodReview__c m: h) {
             	
                 if(m.Reviewer__c == performance.Manager__c) {
                 	if (!(UserInfo.getUserId().equals(performance.Employee__c) 
                 	&& !(performance.Status__c.equals('Complete') 
                 	|| performance.Status__c.equals('Employee Approval')))) {
                     rating = m.Rating__c;
                     weight = m.Weight__c;
                 	}
                 }

                 if(m.Reviewer__c == performance.Employee__c) {
                     status = m.Status__c;
                 }
				
			
                 //Do not show all the comments in 3rd party assessment
                 if(((performance.PreviousStatus__c == 'Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
					||((performance.PreviousStatus__c == '2nd Level Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
				 	|| ((performance.Status__c == '3rd Party Assessment') && (performance.PCOMM__c == userInfo.getUserId())))
				 {
					
						if(m.Reviewer__c == performance.Employee__c){
							history.add(m);
						}
				 }
				 else{
				 	 // Do not show any comments in the comment list that are empty
	                
	                 if(m.Comment__c != null && m.Comment__c != '')
	                     history.add(m);
				 }
             }
         }

         public list<Obstacle__c> getObstacles(){
             return obstacles;
         }

         public void setObstacles(list<Obstacle__c> o){
             obstacles = o;
         }

         public list<Measure__c> getMetrics(){
             return metrics;
         }

         public void setMetrics(list<Measure__c> m){
             metrics = m;
         }

         public boolean getIsComplete() {
	     	
             if((userId.equals(performance.Employee__c) || (userProfile == Label.System_Administrator_label)) &&
                         performance.Status__c.equals('Employee Self Assessment') &&
                     review.Status__c != null){
		     	 if (review != null && (review.Comment__c == '' || review.Comment__c == null || review.Status__c == null || review.Status__c == '-' ))
		     	 {
		     	 	return false;
		     	 }
		     	 else
			     	return true;
	     	 }

             if((userId.equals(performance.Manager__c) || (userProfile == Label.System_Administrator_label)) &&
                       performance.Status__c.equals('Manager Assessment') &&
                       review.Rating__c != null){
                       	
				     	 if (userId.equals(performance.Manager__c) && review != null && ((review.Comment__c == '') || (review.Comment__c == null) || review.Rating__c == 0 ))
				     	 {
				     	 	return false;
				     	 }
				     	 else
				     	 {
				     	 	if (((review.Comment__c == '') || (review.Comment__c == null) || review.Rating__c == 0 ))
				     	 	{
                         		return false;
				     	 	}
				     	 	else
				     	 	{
				     	 		return true;
				     	 	}
				     	 }
		     	 	}

             if (userId.equals(performance.SecondManager__c) &&
                         performance.Status__c.equals('2nd Level Manager Assessment')){
		     	 if (review != null && (review.Comment__c == '' || review.Comment__c == null))
		     	 	return false;
		     	 else
			     	return true;
	     	 }

            if (performance.ThirdPartyReviewer__c != null){
                 if (userId.equals(performance.ThirdPartyReviewer__c) &&
                         performance.Status__c.equals('3rd Party Assessment')){
			     	 if (review != null && (review.Comment__c == '' || review.Comment__c == null))
			     	 	return false;
			     	 else
				     	return true;
                 }
	     	 }

             return false;
         }

         public String getNameEllipsis() {
             if(method.Name.length() > 30){
                 return method.Name.substring(0,20) + '...';              
             }
             else{
                 return method.Name;
             }
         }  
         
         public void setUserId(String id){
            userId = id;    
        }
     }


         // Return true if user have privileges for modify value or is system admin
         public boolean getWithPrivileges() {
             // if the current user has privileges
             list<Id> group_member_list = new list<Id>();
             for (GroupMember share_group : [select Id
                                             from GroupMember 
                                             where UserOrGroupId =:userInfo.getUserId()]) {
                 group_member_list.add(share_group.Id);
             }

             V2MOM__Share[] shares = [select Id, AccessLevel 
                                      from V2MOM__Share 
                                      where ParentId = :performanceReview.V2MOM__c 
                                      and (UserOrGroupId = :userInfo.getUserId()
                                              or UserOrGroupId in :group_member_list)];

             //If is the 2nd manager or de 3rd party assessor return false b/c they don't have access in 
             //edit mode. 
             if (performanceReview.SecondManager__c == currentUser.Id || performanceReview.ThirdPartyReviewer__c == currentUser.Id)
             	return false;
             if (shares.size() > 0){
                 return (!shares[0].AccessLevel.equals('Read') && !performanceReview.V2MOM__r.Locked__c);
             }

             if (accessUtil.getIsSysAdminProfile() && !performanceReview.V2MOM__r.Locked__c)
                 return true;

             return false;
         }

	/*
	 * Inner class: utility class to obtain data with sharing rules
     */
    public with sharing class MethodUtil { 
        
        public String userId = userInfo.getUserId();
        
        public void setUserId(String id){
            userId = id;    
        }
         
        // returns the performance review if the logged user is allowed to access it
         public PerformanceReview__c getPerformanceReviewWithSharing(Id id) {

             list<PerformanceReview__c> performanceReview = [Select  id,
		                                                             name,
		                                                             Employee__c,
		                                                             Manager__c,
		                                                             SecondManager__c,
		                                                             PCOMM__c,
		                                                             ThirdPartyReviewer__c,
		                                                             PerformanceReviewPeriod__c,
		                                                             PerformanceReviewPeriod__r.name,
		                                                             PerformanceReviewPeriod__r.Effective_Date__c,
		                                                             V2MOM__c,
		                                                             V2MOM__r.Vision__c, V2MOM__r.V2MOM_Type__c,
		                                                             V2MOM__r.Effective_Date__c,
		                                                             V2MOM__r.Locked__c,
		                                                             V2MOM__r.Name,
		                                                             Status__c,
                                                             		 PreviousStatus__c,
                                                             		 PremierUser__c,
		                                                             ReviewFormTemplate__c
                                                             From PerformanceReview__c
                                                             Where Id = :id];

             if(performanceReview.size() == 0) return new PerformanceReview__c();

             return performanceReview.get(0);
         }

        // returns the data of the methods if the logged user is allowed to access it
        public map<Id, MethodReview__c> getPerformanceReviewDataWithSharing(PerformanceReview__c p, list<Method__c> m){
             map<Id, MethodReview__c> tempmap = new map<Id, MethodReview__c>();
             
                 for(MethodReview__c mr: [Select r.Name,
                                          r.Comment__c, 
                                          r.Method__c, 
                                          r.CreatedDate, 
                                          r.CreatedBy.Name,  
                                          r.LastModifiedDate,
                                          r.Reviewer__c,
                                          r.Reviewer__r.Name,
                                          r.Status__c,
                                          r.Weight__c, 
                                          r.Rating__c 
                                          From MethodReview__c r 
                                          Where PerformanceReview__c =: p.Id 
                                          AND r.Reviewer__c =: userId
                                          and Method__c IN : m]) {
    
                     tempmap.put(mr.Method__c, mr);
                 }
             return tempmap;
         }

		// returns the comments of the methods if the logged user is allowed to access it
        public list<MethodReview__c> getPerformanceReviewCommentWithSharing(PerformanceReview__c p, list<Method__c> m){
             list<MethodReview__c> tempmap = new list<MethodReview__c>();
                
                 if ((p.Status__c ==  '3rd Party Assessment' && p.Manager__c == Userinfo.getUserId())
				 	|| p.Status__c ==  '3rd Party Assessment' && p.SecondManager__c == Userinfo.getUserId() )
				 	{
				 		 tempmap = [Select Name,
	                         CreatedBy.Name,
	                         CreatedDate,
	                         LastModifiedDate,
	                         Method__c,
	                         Comment__c,
	                         Rating__c,
	                         Reviewer__c,
	                         Reviewer__r.Name,
	                         Weight__c,
	                         Status__c
	                         From MethodReview__c
	                         Where PerformanceReview__c =: p.id
	                         and Method__c IN :m
	                         ORDER BY CreatedDate ASC]; 	
				 	}
				 	else
				 	{
	                tempmap = [Select Name,
	                         CreatedBy.Name,
	                         CreatedDate,
	                         LastModifiedDate,
	                         Method__c,
	                         Comment__c,
	                         Rating__c,
	                         Reviewer__c,
	                         Reviewer__r.Name,
	                         Weight__c,
	                         Status__c
	                         From MethodReview__c
	                         Where PerformanceReview__c =: p.id
	                         and Locked__c = true
	                         and Method__c IN :m
	                         ORDER BY CreatedDate ASC]; 
				 	}     
                 return tempmap;
         }     
     }
    
    public with sharing class ScorecardUtil { 

        public list<ScorecardSupportReview__c> getScorecardSupportWithSharing(PerformanceReview__c p){
            return [Select FiscalQuarter__c , WeightCS__c, AdjustedRatingCS__c, CalculatedRatingCS__c,
                                                        WeightRenewals__c, AdjustedRatingRenewals__c, CalculatedRatingRenewals__c,
                                                        WeightSI__c, AdjustedRatingSI__c, CalculatedRatingSI__c,
                                                        WeightWMCases__c, AdjustedRatingWMCases__c, CalculatedRatingWMCases__c,
                                                        WeightWMSMES__c, AdjustedRatingWMSMES__c, CalculatedRatingWMSMES__c,
                                                        WeightWMHC__c, AdjustedRatingWMHC__c, CalculatedRatingWMHC__c,                                                        
                                                        WeightWMPA__c, AdjustedRatingWMPA__c,
                                                        ForecastAccuracyActual__c, ForecastAccuracyTarget__c, ForecastAccuracyWeight__c, ForecastAccuracyRating__c ,
                                                        SalesImpactActual__c, SalesImpactWeight__c, SalesImpactTarget__c, SalesImpactRating__c,
                                                        TimeOnPlatformActual__c, TimeOnPlatformTarget__c, TimeOnPlatformWeight__c, TimeOnPlatformRating__c,
                                                        RenewalExcellenceActual__c, RenewalExcellenceWeight__c, RenewalExcellenceTarget__c, RenewalExcellenceRating__c,
                                                        OperationalExcellenceActual__c, OperationalExcellenceWeight__c, OperationalExcellenceTarget__c, OperationalExcellenceRating__c, 
                                                        StrategicInitiativesRating__c, StrategicInitiativesWeight__c,
                                                        CSMSalesImpactActual__c, CSMSalesImpactWeight__c, CSMSalesImpactTarget__c, CSMSalesImpactRating__c,
                                                        CustomerSatisfactionActual__c, CustomerSatisfactionTarget__c, RatingCustomerSatisfaction__c, WeightCustomerSatisfaction__c,
                                                        WMCCPActual__c, WMCCPWeight__c, WMCCPTarget__c, WMCCPRating__c,
                                                        WMCAAActual__c, WMCAAWeight__c, WMCAATarget__c, WMCAARating__c                                                                                                            
                                                   FROM ScorecardSupportReview__c  
                                                   WHERE PerformanceReview__c =: p.Id ];         
        }     
    }  
    
}