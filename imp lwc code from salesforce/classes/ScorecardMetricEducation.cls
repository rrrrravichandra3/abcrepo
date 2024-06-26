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

public with sharing class ScorecardMetricEducation {
          
    PerformanceReview__c performanceR;
    List<ScorecardSupportReview__c> scorecardSupportReviews;
    boolean isQ1Q2;
    boolean isQ3Q4;
    boolean isPCOMMLikeViewProfile;
    ScoreCardReviewSupport scorecardReview;
    ScorecardUtil scorecardUtil = new ScorecardUtil();
    List<ScorecardSupportComment__c> historyMethods;
    List<ScorecardSupportComment__c> historyMethodsAux = new List<ScorecardSupportComment__c>();
    ScorecardSupportComment__c currentUserComment = null;
    public boolean hasCommentForecastAccuracy;
    public boolean hasCommentTimeOnPlatform;
    public boolean hasCommentSalesImpact;
    String currentUserProfile;
    String currentUserId;
    public String userId = UserInfo.getUserId();
    User scorecardTypeProfile;
    PerformanceAccessUtil accessUtil;

    public ScorecardMetricEducation()
    {
    	constructor();
    }

    public ScorecardMetricEducation (Id i)
    {
    	currentUserId = i;
    	userId = i;
    	constructor();
    }
    
    public void constructor()
    {
   		// checks the user and the profile
    	
        User currentUser = [Select Id, EmployeeNumber, Profile.Name FROM  User WHERE id =: userId];
        String employeeNumber = currentUser.EmployeeNumber;
        currentUserProfile = currentUser.Profile.Name;
        currentUserId = userId;
        
        // gets the performance review
        performanceR = [SELECT Id, Manager__c, ThirdPartyReviewer__c, PCOMM__c, Name, SecondManager__c, Employee__c, Status__c, PreviousStatus__c, V2MOM__r.V2MOM_Type__c  
                        FROM PerformanceReview__c 
                        WHERE Id =: System.currentPageReference().getParameters().get('id')];

		// gets the profile of the employee to see what kind of scorecard it might have
    	scorecardTypeProfile = [Select u.Profile.Name, u.ProfileId From User u where id = :performanceR.Employee__c];   
    		
		// access class for permissions
        accessUtil = new PerformanceAccessUtil(performanceR, currentUser, scorecardTypeProfile);

        // uses the information of the performance review to check if the profile of the
        // current user should see data filtered by sharing rules or filtered manually
        isPCOMMLikeViewProfile = accessUtil.getPCOMMLikeViewProfile();

        // gets the scorecards of the performance review
        List <ScorecardSupportReview__c> lists =  [Select FiscalQuarter__c , WeightCS__c, AdjustedRatingCS__c, CalculatedRatingCS__c,
                                                        WeightRenewals__c, AdjustedRatingRenewals__c, CalculatedRatingRenewals__c,
                                                        WeightSI__c, AdjustedRatingSI__c, CalculatedRatingSI__c,
                                                        WeightWMCases__c, AdjustedRatingWMCases__c, CalculatedRatingWMCases__c,
                                                        WeightWMSMES__c, AdjustedRatingWMSMES__c, CalculatedRatingWMSMES__c,
                                                        WeightWMHC__c, AdjustedRatingWMHC__c, CalculatedRatingWMHC__c,                                                        
                                                        WeightWMPA__c, AdjustedRatingWMPA__c,
                                                        ForecastAccuracyActual__c, ForecastAccuracyTarget__c, ForecastAccuracyWeight__c, ForecastAccuracyRating__c ,
                                                        SalesImpactActual__c, SalesImpactWeight__c, SalesImpactTarget__c, SalesImpactRating__c,
                                                        TimeOnPlatformActual__c, TimeOnPlatformTarget__c, TimeOnPlatformWeight__c, TimeOnPlatformRating__c                                                                                                          
                                                   FROM ScorecardSupportReview__c  
                                                   WHERE PerformanceReview__c =: performanceR.Id ];

        scorecardSupportReviews = lists;                  

		if (isPCOMMLikeViewProfile){
			// gets the data of the scorecards filtered without sharing
	        historyMethods = getScorecardCommentWithoutSharing(performanceR);
        	historyMethods = orderScorecardReviewList(historyMethods);
	        
	        for(ScorecardSupportComment__c c: historyMethods){
	        	if(c.Reviewer__c == currentUserId){
	        		currentUserComment = c;
	        	}
	        }
	        
	        scorecardReview = new ScoreCardReviewSupport(scorecardSupportReviews, performanceR, currentUserComment, !accessUtil.getAdjustedRatingView());
		}else{
			// gets the data of the scorecards filtered with sharing
	        historyMethods = scorecardUtil.getScorecardCommentWithSharing(performanceR);
        	historyMethods = orderScorecardReviewList(historyMethods);
        
	        for(ScorecardSupportComment__c c: historyMethods){
	        	if(c.Reviewer__c == currentUserId){
	        		currentUserComment = c;
	        	} 
	        	//if(c.Locked__c == true){
	        		historyMethodsAux.add(c);
	        	//}
	        }
	        
	        historyMethods = historyMethodsAux;
	        
	        scorecardReview = new ScoreCardReviewSupport(scorecardSupportReviews, performanceR, currentUserComment);
		}
        
        // checks of which quarter is the performance review
        if (performanceR.V2MOM__r.V2MOM_Type__c  == 'Individual Q1/Q2')
            isQ1Q2 = true;
        else
            isQ1Q2 = false;	
        
        if(performanceR.V2MOM__r.V2MOM_Type__c == 'Individual Q3/Q4')
        	isQ3Q4 = true;
     	else
	        isQ3Q4 = false;    
	}
    	
    public String userId(){
    	return userId;	
    }
    
    public void setUserId(String value){
    	userId = value;	
    }
    
    // returns true if the quarter is Q1/Q2
    public boolean getIsQ1Q2(){
    	return isQ1Q2 && accessUtil.getIsMngrInAssmnt();
    }
    public boolean getIsQ3Q4(){
        return isQ3Q4 && accessUtil.getIsMngrInAssmnt();
    }
    public boolean getIsQ1Q2Q3Q4InMgrAssmnt(){
    	return (isQ1Q2 && accessUtil.getIsMngrInAssmnt()) || (isQ3Q4 && accessUtil.getIsMngrInAssmnt());
    }
    
    public ScorecardSupportComment__c getCurrentUserComment() {
    	return currentUserComment;
    }

    // gets the Id of the current user
    public String getCurrentUserId(){
        return currentUserId;
    }

    // returns the values for the adjusted rating combo box
     public List<SelectOption> getRatingSelectOptions() {
         return PAMUtil.getRatingSelectOptions();
     }

    // Returns the PerformanceReview
    public PerformanceReview__c getperformanceR(){
        return  performanceR;   
    }

    // gets the V2MOM Type of the performance review
    public String getv2momType(){
        return performanceR.V2MOM__r.V2MOM_Type__c;   
    }

    // gets the scorecards of the performance review
    public ScoreCardReviewSupport getScorecardSupportReview(){
        return scorecardReview;
    }

    public ScoreCard__c getScorecard(){
        //Remove this thing later
        return new Scorecard__c();  
    }

    // gets the profile of the current user
     public String getUserProfile(){
         return currentUserProfile;    
     }

    // gets the label of the button for previous metric
    public String getLabelPreviousMetric(){
        return Label.Scorecards_Previous_Metric_Label;
    }

    // gets the label of the button for previous metric
    public String getLabelNextMetric(){
        return Label.Scorecards_Next_Metric_Label;
    }

    // gets the label of the row for % of metric weight available for the quarter
    public String getLabelMetricAvail(){
        return Label.Scorecards_Metric_Avail_Label;
    }

    // gets the label of the metric comment
    public String getLabelMetricComment(){
        return Label.Scorecards_Metric_Comment_Label;
    }
         
/*
* BEGIN FUNCTIONS TO SHOW METRIC VALUES - ACCESS DESIGN **************
*/

    //-----------------  USER PROFILES ----------------------------------------------------------------
    
    // Return true if the logged user is of System Administrator profile
    public boolean getIsSysAdminProfile(){
		return accessUtil.getIsSysAdminProfile();
    }
    
    //--------------------- USER ACCESS FUNCTIONS -------------------------------------------------

     // Return true if the logged user is the manager of performance review no matter the status
     public boolean getIsMngr() {
		return accessUtil.getIsMngr();
     }
     
    // Manager in Assessment - Write permission
     public boolean getIsMngrInAssmnt() {
		return accessUtil.getIsMngrInAssmnt();
     }   
     
     // 3rd Party in Assessment - Write permission
     public boolean getIs3PtInAssmnt() {
		return accessUtil.getIs3PtInAssmnt();
     }   
     
      // Manager, 2nd Manager or 3rd Party in Assessment - Write permission in scorecard object
     public boolean getIsMngr2ndMngrOr3PtInAssmnt() {
		return accessUtil.getIsMngr2ndMngrOr3PtInAssmnt();
     } 

/*
* END FUNCTIONS TO SHOW METRIC VALUES - ACCESS DESIGN **************
*/

/*
* BEGIN FUNCTIONS TO GET METRIC COMMENTS **************
*/

        // gets the comments of the scorecard without sharing rules
        // according to the logged user and the status of the performance review.
        public list<ScorecardSupportComment__c> getScorecardCommentWithoutSharing(PerformanceReview__c p){
        	
                if (isPCOMMLikeViewProfile){
                    if (!accessUtil.getStatusRO3()){
                        if (!p.Status__c.equals('Manager Assessment')){
                            if (!p.Status__c.equals('2nd Level Manager Assessment')){
                                // any status except created, empl self assmnt, mngr assmnt 
                                // or 2nd level mngr assmnt retrieve all
                                return [select  s.Reviewer__r.Name, 
                                        s.Reviewer__c, 
                                        s.CommentCS__c, 
                                        s.CommentRenewals__c,
                                        s.CommentSupportInitiatives__c,
                                        s.CommentWMCases__c,
                                        s.CommentWMSMES__c,
                                        s.CommentWMPA__c,
                                        s.CommentWMHC__c,
                                        s.CommentTimeOnPlatform__c,
                                        s.CommentForecastAccuracy__c,
                                        s.CommentSalesImpact__c,
                                        s.CreatedDate, 
                                        s.Locked__c
                                        from ScorecardSupportComment__c s 
                                        where  PerformanceReview__c  =: p.Id
                                        order by CreatedDate ASC];
                            }else{
                                // status 2nd level mngr assmnt retrieve all except the 2nd Manager comments
                                return [select  s.Reviewer__r.Name, 
                                        s.Reviewer__c, 
                                        s.CommentCS__c, 
                                        s.CommentRenewals__c,
                                        s.CommentSupportInitiatives__c,
                                        s.CommentWMCases__c,
                                        s.CommentWMSMES__c,
                                        s.CommentWMPA__c,
                                        s.CommentWMHC__c,
                                        s.CommentTimeOnPlatform__c,
                                        s.CommentForecastAccuracy__c,
                                        s.CommentSalesImpact__c,
                                        s.CreatedDate,
                                        s.Locked__c 
                                        from ScorecardSupportComment__c s 
                                        where  PerformanceReview__c  =: p.Id
                                        and Locked__c = true 
                                        and (Reviewer__c <>: p.SecondManager__c)
                                        order by CreatedDate ASC];
                            }          
                        }
                        else{
                            // status mngr assmnt retrieve all except the Manager and 2nd Manager comments
                            return [select  s.Reviewer__r.Name, 
		                                    s.Reviewer__c, 
		                                    s.CommentCS__c, 
		                                    s.CommentRenewals__c,
		                                    s.CommentSupportInitiatives__c,
		                                    s.CommentWMCases__c,
		                                    s.CommentWMSMES__c,
		                                    s.CommentWMPA__c,
		                                    s.CommentWMHC__c,
		                                    s.CommentTimeOnPlatform__c,
		                                    s.CommentForecastAccuracy__c,
		                                    s.CommentSalesImpact__c,
		                                    s.CreatedDate,
		                                    s.Locked__c 
                                    from ScorecardSupportComment__c s 
                                    where  PerformanceReview__c  =: p.Id
	                                    and Locked__c = true 
	                                    and (Reviewer__c <>: p.Manager__c 
	                                    and Reviewer__c <>: p.SecondManager__c)
                                    order by CreatedDate ASC];
                        }
                    }
                }
            return new list<ScorecardSupportComment__c>();
        }     


        public List<ScorecardSupportComment__c> orderScorecardReviewList(List<ScorecardSupportComment__c> originalList) {
        	
	        List<ScorecardSupportComment__c> scorecardReviewComments = new List<ScorecardSupportComment__c>();
	        
	        for(ScorecardSupportComment__c src : originalList){
	        	if (src.Reviewer__c == performanceR.Employee__c)
	        		scorecardReviewComments.add(src);
	        }
	        
	        for(ScorecardSupportComment__c src : originalList){
	        	if (src.Reviewer__c == performanceR.Manager__c)
	        		scorecardReviewComments.add(src);
	        }
	        
	        for(ScorecardSupportComment__c src : originalList){
	        	if (src.Reviewer__c == performanceR.SecondManager__c)
	        		scorecardReviewComments.add(src);
	        }
	        
	        for(ScorecardSupportComment__c src : originalList){
	        	if ((src.Reviewer__c != performanceR.Employee__c)
	        	&& (src.Reviewer__c != performanceR.Manager__c)
	        	&& (src.Reviewer__c != performanceR.SecondManager__c)
	        	&& (performanceR.Status__c != 'Employee Self Assessment'))
	        		scorecardReviewComments.add(src);
	        }
	        
	        return scorecardReviewComments;
        }
        
    public List<HistoryComments> getHistoryCommentForecastAccurancy()
    {
        List<HistoryComments> commentList = new List<HistoryComments>();

        for (ScorecardSupportComment__c sr:historyMethods)
        {
            if (sr.CommentForecastAccuracy__c != null && sr.CommentForecastAccuracy__c != '')
            {   
                 if(accessUtil.showRatingAndWeightIn3rdPartyAssmnt() && sr.Locked__c == true){
	                HistoryComments hc = new HistoryComments(sr); 
	                commentList.add(hc);   
            	}  
            }   
        } 

        if (commentList.size() > 0)
        {
            hasCommentForecastAccuracy = true;
        }
        else
        {
            hasCommentForecastAccuracy = false;
        }

        return commentList;
    }
     
     public List<HistoryComments> getHistoryCommentTimeOnPlatform()
    {
        List<HistoryComments> commentList = new List<HistoryComments>();

        for (ScorecardSupportComment__c sr:historyMethods)
        {
            if (sr.CommentTimeOnPlatform__c != null && sr.CommentTimeOnPlatform__c != '')
            {   
                if(accessUtil.showRatingAndWeightIn3rdPartyAssmnt() && sr.Locked__c == true){
	                HistoryComments hc = new HistoryComments(sr); 
	                commentList.add(hc);   
            	}    
            }   
        } 

        if (commentList.size() > 0)
        {
            hasCommentTimeOnPlatform = true;
        }
        else
        {
            hasCommentTimeOnPlatform = false;
        }

        return commentList;
    }
    
    public List<HistoryComments> getHistoryCommentSalesImpact()
    {
        List<HistoryComments> commentList = new List<HistoryComments>();

        for (ScorecardSupportComment__c sr:historyMethods)
        {
            if (sr.CommentSalesImpact__c != null && sr.CommentSalesImpact__c != '')
            {   
                if(accessUtil.showRatingAndWeightIn3rdPartyAssmnt() && sr.Locked__c == true){
	                HistoryComments hc = new HistoryComments(sr); 
	                commentList.add(hc);   
            	}    
            }   
        } 

        if (commentList.size() > 0)
        {
            hasCommentSalesImpact = true;
        }
        else
        {
            hasCommentSalesImpact = false;
        }

        return commentList;
    }
    
    public Boolean getHasCommentTimeOnPlatform(){
        return  hasCommentTimeOnPlatform;
    }
    
    public Boolean getHasCommentForecastAccuracy(){
        return hasCommentForecastAccuracy;
    }   
    
    public Boolean getHasCommentSalesImpact(){
        return hasCommentSalesImpact;   
    }
	/*
	* END FUNCTIONS TO GET METRIC COMMENTS **************
	*/
	
	/*
	* Inner Class
	* values of the scorecards
	*/
    //Inner class just to hold integer values.... no way arround this.
    public class ScoreCardReviewSupport 
    {
        //List for all q1 q2 q3 q4
        List<ScorecardSupportReview__c> scorecardSupportReviews;

        ScorecardSupportReview__c scorecardQ1;
        ScorecardSupportReview__c scorecardQ2;
        ScorecardSupportReview__c scorecardQ3;
        ScorecardSupportReview__c scorecardQ4;
        PerformanceReview__c performanceReview;
		ScorecardSupportComment__c currentUserComment;

        //Not sure why doesn't works without this local variables in setters.
        Long adjustedRatingQ1 = 0;
        Long adjustedRatingQ2 = 0;
        Long adjustedRatingQ3 = 0;
        Long adjustedRatingQ4 = 0;
        String id;
		Id userId;
		
        // constructor without filtering any value
        public ScoreCardReviewSupport(List<ScorecardSupportReview__c> scorecardReview, PerformanceReview__c pR, ScorecardSupportComment__c CUComment)
        {
        	userId =  UserInfo.getUserId();
        	
            scorecardSupportReviews = scorecardReview;
            performanceReview = pR;
			currentUserComment = CUComment;

            scorecardQ1 =  getQuarter('Q1');
            scorecardQ2 =  getQuarter('Q2');
            scorecardQ3 =  getQuarter('Q3');
            scorecardQ4 =  getQuarter('Q4');
        }

        // constructor filtering values according to filter condition
        public ScoreCardReviewSupport(List<ScorecardSupportReview__c> scorecardReview, PerformanceReview__c pR, ScorecardSupportComment__c CUComment, boolean filter)
        {
        	userId =  UserInfo.getUserId();
        		
            scorecardSupportReviews = scorecardReview;
            performanceReview = pR;
			currentUserComment = CUComment;

            scorecardQ1 =  getQuarter('Q1');
            scorecardQ2 =  getQuarter('Q2');
            scorecardQ3 =  getQuarter('Q3');
            scorecardQ4 =  getQuarter('Q4');
            
            if (filter){
				scorecardQ1 = filterValues(scorecardQ1);
				scorecardQ2 = filterValues(scorecardQ2);
				scorecardQ3 = filterValues(scorecardQ3);
				scorecardQ4 = filterValues(scorecardQ4);
            }
        }
        
        public ScorecardSupportReview__c filterValues(ScorecardSupportReview__c s){
        	if (s != null){
                s.AdjustedRatingCS__c = null;
                s.AdjustedRatingRenewals__c = null; 
                s.AdjustedRatingWMCases__c = null;
                s.AdjustedRatingWMSMES__c = null;
                s.AdjustedRatingWMHC__c = null;
                s.AdjustedRatingWMPA__c = null;
                s.AdjustedRatingSI__c = null;
                s.SalesImpactWeight__c = null;
                s.SalesImpactRating__c = null;
                s.ForecastAccuracyWeight__c = null;
                s.ForecastAccuracyRating__c = null;
                s.TimeOnPlatformWeight__c = null;
                s.TimeOnPlatformRating__c = null;
        	}
        	return s;
        }

		public Id getUserId()
		{
			return userId;	
		}
		
		public void setUserId(Id value)
		{
			userId = value;	
		}
		
        public String getId()
        {
           return '';
        }

        public List<ScorecardSupportReview__c> getScorecardSupportReview()
        {
            if (scorecardSupportReviews != null)
            {
                return scorecardSupportReviews;
            }
            else
            {
                return null;    
            }
        }
        
        public ScorecardSupportReview__c getQuarter(String quarter)
        {
            ScorecardSupportReview__c sR = null;

            for(ScorecardSupportReview__c scorecardReview: scorecardSupportReviews) {
                if (scorecardReview.FiscalQuarter__c == quarter)
                {
                    sR = scorecardReview;
                }
            }

            if (sR != null)
            {
                return sR;
            }
            else
            {
                return new ScorecardSupportReview__c();
            }
        }
        
        // -------------------------------- Here start getters for Forecast Accuracy fields
        public Long getForecastAccuracyActualQ1()
        {
        	//System.debug('EnterGetter');
        	
        	//System.debug(scorecardQ1);
        	//System.debug(scorecardQ1.ForecastAccuracyActual__c);
        	
            if (scorecardQ1 != null && scorecardQ1.ForecastAccuracyActual__c != null)
            {
            	//System.debug('EnterHERE');
                return  Math.roundToLong(scorecardQ1.ForecastAccuracyActual__c);
            }
            else
            {
                return 0;   
            } 
        }
        
        public Long getForecastAccuracyActualQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.ForecastAccuracyActual__c != null)
            {
            	//System.debug('EntergetForecastAccuracyActualQ2');
                return  Math.roundToLong(scorecardQ2.ForecastAccuracyActual__c);
            }
            else
            {
                return 0;   
            } 
        }
        
        public Long getForecastAccuracyActualQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.ForecastAccuracyActual__c != null)
            {
            	//System.debug('EntergetForecastAccuracyActualQ3Q');
            	
                return  Math.roundToLong(scorecardQ3.ForecastAccuracyActual__c);
            }
            else
            {
                return 0;   
            } 
        }
        
        public Long getForecastAccuracyActualQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.ForecastAccuracyActual__c != null)
            {
                return  Math.roundToLong(scorecardQ4.ForecastAccuracyActual__c);
            }
            else
            {
                return 0;   
            } 
        }
        
        public Long getForecastAccuracyTargetQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.ForecastAccuracyTarget__c != null)
            {
                return  Math.roundToLong(scorecardQ1.ForecastAccuracyTarget__c);
            }
            else
            {
                return 0;   
            }   
        }
        
        public Long getForecastAccuracyTargetQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.ForecastAccuracyTarget__c != null)
            {
                return  Math.roundToLong(scorecardQ2.ForecastAccuracyTarget__c);
            }
            else
            {
                return 0;   
            }   
        }
        
        public Long getForecastAccuracyTargetQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.ForecastAccuracyTarget__c != null)
            {
                return  Math.roundToLong(scorecardQ3.ForecastAccuracyTarget__c);
            }
            else
            {
                return 0;   
            }   
        }
        
        public Long getForecastAccuracyTargetQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.ForecastAccuracyTarget__c != null)
            {
                return  Math.roundToLong(scorecardQ4.ForecastAccuracyTarget__c);
            }
            else
            {
                return 0;   
            }       
        }
        
        public Long getForecastAccuracyAttainmentQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.ForecastAccuracyActual__c != null && scorecardQ1.ForecastAccuracyTarget__c != null)
            {
                if (scorecardQ1.ForecastAccuracyTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ1.ForecastAccuracyActual__c / scorecardQ1.ForecastAccuracyTarget__c) * 100);
                    return shortDouble;      
                }
                else
                {
                    return 0;   
                }
                        
            }
            else
            {
                return 0;   
            }
        }
        
        public Long getForecastAccuracyAttainmentQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.ForecastAccuracyActual__c != null && scorecardQ2.ForecastAccuracyTarget__c != null)
            {
                if (scorecardQ2.ForecastAccuracyTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ2.ForecastAccuracyActual__c / scorecardQ2.ForecastAccuracyTarget__c) * 100);
                    return shortDouble;      
                }
                else
                {
                    return 0;   
                }
            }
            else
            {
                return 0;   
            }
        }
        
        public Long getForecastAccuracyAttainmentQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.ForecastAccuracyActual__c != null && scorecardQ3.ForecastAccuracyTarget__c != null)
            {
                if (scorecardQ3.ForecastAccuracyTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ3.ForecastAccuracyActual__c / scorecardQ3.ForecastAccuracyTarget__c) * 100);
                    return shortDouble;      
                }
                else
                {
                    return 0;   
                }
            }
            else
            {
                return 0;   
            }
        }
        
        public Long getForecastAccuracyAttainmentQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.ForecastAccuracyActual__c != null && scorecardQ4.ForecastAccuracyTarget__c != null)
            {
                if (scorecardQ4.ForecastAccuracyTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ4.ForecastAccuracyActual__c / scorecardQ4.ForecastAccuracyTarget__c) * 100);
                    return shortDouble;      
                }
                else
                {
                    return 0;   
                }
            }
            else
            {
                return 0;   
            }
        }
        
        public Long getYTDActual()
        {
            Double total = 0;
            
            if (scorecardQ1 != null && scorecardQ1.ForecastAccuracyActual__c != null)
            {
                total  = total + scorecardQ1.ForecastAccuracyActual__c;
            }
            
            if (scorecardQ2 != null && scorecardQ2.ForecastAccuracyActual__c != null)
            {
                total = total + scorecardQ2.ForecastAccuracyActual__c;
            }
            
            if (scorecardQ3 != null && scorecardQ3.ForecastAccuracyActual__c != null)
            {
                total = total +  scorecardQ3.ForecastAccuracyActual__c;
            }
            
            if (scorecardQ4 != null && scorecardQ4.ForecastAccuracyActual__c != null)
            {
                total = total + scorecardQ4.ForecastAccuracyActual__c;
            }
                
            return Math.roundToLong(total);
        }
        
        public Long getYTDTarget()
        {
            Double total = 0;
            
            if (scorecardQ1 != null && scorecardQ1.ForecastAccuracyTarget__c != null)
            {
                total = total + scorecardQ1.ForecastAccuracyTarget__c;
            }
            
            if (scorecardQ2 != null && scorecardQ2.ForecastAccuracyTarget__c != null)
            {
                total = total +  scorecardQ2.ForecastAccuracyTarget__c;
            }
            
            if (scorecardQ3 != null && scorecardQ3.ForecastAccuracyTarget__c != null)
            {
                total = total + scorecardQ3.ForecastAccuracyTarget__c;
            }
            
            if (scorecardQ4 != null && scorecardQ4.ForecastAccuracyTarget__c != null)
            {
                total = total +  scorecardQ4.ForecastAccuracyTarget__c;
            }
                
            return Math.roundToLong(total);
        }
        
        public Long getYTDAttainment()
        {
            Double target = 0;
            Double actual = 0;
            Double result = 0;
            
            target = getYTDTarget();
            actual = getYTDActual();
            
            if (target != 0)
            {
                result = (actual / target) * 100;
                return Math.roundToLong(result);      
            }
            else
            {
                return 0;   
            }
        }
        
        public String getCommentForecastAccuracy()
        {
            if (currentUserComment != null)
            {
                return currentUserComment.CommentForecastAccuracy__c;
            }
            else
            {
                return '';
            }   
        }
        
        public String getForecastAccuracyRating()
        {
             if (scorecardQ1 != null && scorecardQ1.ForecastAccuracyRating__c != null)
             {
                if(scorecardQ1.ForecastAccuracyRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ1.ForecastAccuracyRating__c.intValue());
             }
             
             if (scorecardQ2 != null && scorecardQ2.ForecastAccuracyRating__c != null)
             {
                if(scorecardQ2.ForecastAccuracyRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ2.ForecastAccuracyRating__c.intValue());
             }
             
             if (scorecardQ3 != null && scorecardQ3.ForecastAccuracyRating__c != null)
             {
                if(scorecardQ3.ForecastAccuracyRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ3.ForecastAccuracyRating__c.intValue());
             }
             
             if (scorecardQ4 != null && scorecardQ4.ForecastAccuracyRating__c != null)
             {
                if(scorecardQ4.ForecastAccuracyRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ4.ForecastAccuracyRating__c.intValue());
             }
             
             return '--None--';
        }
       
        public String getRatingDescription(Integer value)
        {
			return PAMUtil.getRatingLabel(value);
        }
        
        public Double getForecastAccuracyWeight()
        {    
             if (scorecardQ1 != null && scorecardQ1.ForecastAccuracyWeight__c != null)
             {
                return  scorecardQ1.ForecastAccuracyWeight__c;
             }
             
             if (scorecardQ2 != null && scorecardQ2.ForecastAccuracyWeight__c != null)
             {
                return  scorecardQ2.ForecastAccuracyWeight__c;
             }
             
             if (scorecardQ3 != null && scorecardQ3.ForecastAccuracyWeight__c != null)
             {
                return  scorecardQ3.ForecastAccuracyWeight__c;
             }
             
             if (scorecardQ4 != null && scorecardQ4.ForecastAccuracyWeight__c != null)
             {
                return  scorecardQ4.ForecastAccuracyWeight__c;
             }
             
            return 0;
        }
        
        // ------------------------------- Here start getters for Time on Platform fields
        public Long getTimeOnPlatformActualQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.TimeOnPlatformActual__c != null)
            {
                return  Math.roundToLong(scorecardQ1.TimeOnPlatformActual__c);
            }
            else
            {
                return 0;   
            } 
        }
        
        public Long getTimeOnPlatformActualQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.TimeOnPlatformActual__c != null)
            {
                return  Math.roundToLong(scorecardQ2.TimeOnPlatformActual__c);
            }
            else
            {
                return 0;   
            } 
        }
        
        public Long getTimeOnPlatformActualQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.TimeOnPlatformActual__c != null)
            {
                return  Math.roundToLong(scorecardQ3.TimeOnPlatformActual__c);
            }
            else
            {
                return 0;   
            } 
        }
        
        public Long getTimeOnPlatformActualQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.TimeOnPlatformActual__c != null)
            {
                return  Math.roundToLong(scorecardQ4.TimeOnPlatformActual__c);
            }
            else
            {
                return 0;   
            } 
        }
       
        public Long getTimeOnPlatformTargetQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.TimeOnPlatformTarget__c != null)
            {
                return  Math.roundToLong(scorecardQ1.TimeOnPlatformTarget__c);
            }
            else
            {
                return 0;   
            }   
        }
        
        public Long getTimeOnPlatformTargetQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.TimeOnPlatformTarget__c != null)
            {
                return  Math.roundToLong(scorecardQ2.TimeOnPlatformTarget__c);
            }
            else
            {
                return 0;   
            }   
        }
        
        public Long getTimeOnPlatformTargetQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.TimeOnPlatformTarget__c != null)
            {
                return  Math.roundToLong(scorecardQ3.TimeOnPlatformTarget__c);
            }
            else
            {
                return 0;   
            }   
        }
        
        public Long getTimeOnPlatformTargetQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.TimeOnPlatformTarget__c != null)
            {
                return  Math.roundToLong(scorecardQ4.TimeOnPlatformTarget__c);
            }
            else
            {
                return 0;   
            }   
        }
        
        public Long getTimeOnPlatformAttainmentQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.TimeOnPlatformActual__c != null && scorecardQ1.TimeOnPlatformTarget__c != null)
            {
                if (scorecardQ1.TimeOnPlatformTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ1.TimeOnPlatformActual__c / scorecardQ1.TimeOnPlatformTarget__c) * 100);
                    return shortDouble;      
                }
                else
                {
                    return 0;   
                }
                        
            }
            else
            {
                return 0;   
            }
        }
        
        public Long getTimeOnPlatformAttainmentQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.TimeOnPlatformActual__c != null && scorecardQ2.TimeOnPlatformTarget__c != null)
            {
                if (scorecardQ2.TimeOnPlatformTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ2.TimeOnPlatformActual__c / scorecardQ2.TimeOnPlatformTarget__c) * 100);
                    return shortDouble;      
                }
                else
                {
                    return 0;   
                }
                        
            }
            else
            {
                return 0;   
            }
        }
        
        public Long getTimeOnPlatformAttainmentQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.TimeOnPlatformActual__c != null && scorecardQ3.TimeOnPlatformTarget__c != null)
            {
                if (scorecardQ3.TimeOnPlatformTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ3.TimeOnPlatformActual__c / scorecardQ3.TimeOnPlatformTarget__c) * 100);
                    return shortDouble;     
                }
                else
                {
                    return 0;   
                }  
            }
            else
            {
                return 0;   
            }
        }
        
        public Long getTimeOnPlatformAttainmentQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.TimeOnPlatformActual__c != null && scorecardQ4.TimeOnPlatformTarget__c != null)
            {
                if (scorecardQ4.TimeOnPlatformTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ4.TimeOnPlatformActual__c / scorecardQ4.TimeOnPlatformTarget__c) * 100);
                    return shortDouble;      
                }
                else
                {
                    return 0;   
                }
                        
            }
            else
            {
                return 0;   
            }
        }
        
        public Long getYTDActualTimeOnPlatform()
        {
            Double total = 0;
            
            if (scorecardQ1 != null && scorecardQ1.TimeOnPlatformActual__c != null)
            {
                total  = total + scorecardQ1.TimeOnPlatformActual__c;
            }
            
            if (scorecardQ2 != null && scorecardQ2.TimeOnPlatformActual__c != null)
            {
                total = total + scorecardQ2.TimeOnPlatformActual__c;
            }
            
            if (scorecardQ3 != null && scorecardQ3.TimeOnPlatformActual__c != null)
            {
                total = total +  scorecardQ3.TimeOnPlatformActual__c;
            }
            
            if (scorecardQ4 != null && scorecardQ4.TimeOnPlatformActual__c != null)
            {
                total = total + scorecardQ4.TimeOnPlatformActual__c;
            }
                
            return Math.roundToLong(total);
        }
        
        public Long getYTDTargetTimeOnPlatform()
        {
            Double total = 0;
            
            if (scorecardQ1 != null && scorecardQ1.TimeOnPlatformTarget__c != null)
            {
                total = total + scorecardQ1.TimeOnPlatformTarget__c;
            }
            
            if (scorecardQ2 != null && scorecardQ2.TimeOnPlatformTarget__c != null)
            {
                total = total +  scorecardQ2.TimeOnPlatformTarget__c;
            }
            
            if (scorecardQ3 != null && scorecardQ3.TimeOnPlatformTarget__c != null)
            {
                total = total + scorecardQ3.TimeOnPlatformTarget__c;
            }
            
            if (scorecardQ4 != null && scorecardQ4.TimeOnPlatformTarget__c != null)
            {
                total = total +  scorecardQ4.TimeOnPlatformTarget__c;
            }
                
            return Math.roundToLong(total);
        }
        
        public Long getYTDAttainmentTimeOnPlatform()
        {
            Double target = 0;
            Double actual = 0;
            Double result = 0;
            
            target = getYTDTargetTimeOnPlatform();
            actual = getYTDActualTimeOnPlatform();
            
            if (target != 0)
            {
                result = (actual/target) * 100;
                return Math.roundToLong(result);      
            }
            else
            {
                return 0;   
            }
        }
        
        public String getCommentTimeOnPlatform()
        {
            if (currentUserComment != null)
            {
                return currentUserComment.CommentTimeOnPlatform__c;
            }
            else
            {
                return '';
            }   
        }
        
        public String getTimeOnPlatformRating()
        {
             if (scorecardQ1 != null && scorecardQ1.TimeOnPlatformRating__c != null)
             {
                if(scorecardQ1.TimeOnPlatformRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ1.TimeOnPlatformRating__c.intValue());
             }
             
             if (scorecardQ2 != null && scorecardQ2.TimeOnPlatformRating__c != null)
             {
                if(scorecardQ2.TimeOnPlatformRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ2.TimeOnPlatformRating__c.intValue());
             }
             
             if (scorecardQ3 != null && scorecardQ3.TimeOnPlatformRating__c != null)
             {
                if(scorecardQ3.TimeOnPlatformRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ3.TimeOnPlatformRating__c.intValue());
             }
             
             if (scorecardQ4 != null && scorecardQ4.TimeOnPlatformRating__c != null)
             {
                if(scorecardQ4.TimeOnPlatformRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ4.TimeOnPlatformRating__c.intValue());
             }
             
             return '--None--';
        }
        
        public Double getTimeOnPlatformWeight()
        {    
             if (scorecardQ1 != null && scorecardQ1.TimeOnPlatformWeight__c != null)
             {
                return  scorecardQ1.TimeOnPlatformWeight__c;
             }
             
             if (scorecardQ2 != null && scorecardQ2.TimeOnPlatformWeight__c != null)
             {
                return  scorecardQ2.TimeOnPlatformWeight__c;
             }
             
             if (scorecardQ3 != null && scorecardQ3.TimeOnPlatformWeight__c != null)
             {
                return  scorecardQ3.TimeOnPlatformWeight__c;
             }
             
             if (scorecardQ4 != null && scorecardQ4.TimeOnPlatformWeight__c != null)
             {
                return  scorecardQ4.TimeOnPlatformWeight__c;
             }
             
            return 0;
        }
        
        // --------------------------- Here start getters for Sales Impact fields
        public Long getSalesImpactActual()
        {
            if (scorecardQ1 != null && scorecardQ1.SalesImpactActual__c != null)
            {
                return  Math.roundToLong(scorecardQ1.SalesImpactActual__c);
            }
            if (scorecardQ2 != null && scorecardQ2.SalesImpactActual__c != null)
            {
                return  Math.roundToLong(scorecardQ2.SalesImpactActual__c);
            }
            if (scorecardQ3 != null && scorecardQ3.SalesImpactActual__c != null)
            {
                return  Math.roundToLong(scorecardQ3.SalesImpactActual__c);
            }
            if (scorecardQ4 != null && scorecardQ4.SalesImpactActual__c != null)
            {
                return  Math.roundToLong(scorecardQ4.SalesImpactActual__c);
            }
            
            return 0;
        }
        
        public Long getSalesImpactTarget()
        {
            if (scorecardQ1 != null && scorecardQ1.SalesImpactTarget__c != null)
            {
                return  Math.roundToLong(scorecardQ1.SalesImpactTarget__c);
            }
            if (scorecardQ2 != null && scorecardQ2.SalesImpactTarget__c != null)
            {
                return  Math.roundToLong(scorecardQ2.SalesImpactTarget__c);
            }
            if (scorecardQ3 != null && scorecardQ3.SalesImpactTarget__c != null)
            {
                return  Math.roundToLong(scorecardQ3.SalesImpactTarget__c);
            }
            if (scorecardQ4 != null && scorecardQ4.SalesImpactTarget__c != null)
            {
                return  Math.roundToLong(scorecardQ4.SalesImpactTarget__c);
            }
            
            return 0;
        }
        
        public Long getSalesImpactDifference()
        {
            return getSalesImpactActual() - getSalesImpactTarget();
        }
        
         public String getSalesImpactRating()
        {
             if (scorecardQ1 != null && scorecardQ1.SalesImpactRating__c != null)
             {
                if(scorecardQ1.SalesImpactRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ1.SalesImpactRating__c.intValue());
             }
             
             if (scorecardQ2 != null && scorecardQ2.SalesImpactRating__c != null)
             {
                if(scorecardQ2.SalesImpactRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ2.SalesImpactRating__c.intValue());
             }
             
             if (scorecardQ3 != null && scorecardQ3.SalesImpactRating__c != null)
             {
                if(scorecardQ3.SalesImpactRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ3.SalesImpactRating__c.intValue());
             }
             
             if (scorecardQ4 != null && scorecardQ4.SalesImpactRating__c != null)
             {
                if(scorecardQ4.SalesImpactRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ4.SalesImpactRating__c.intValue());
             }
             
             return '--None--';
        }
        
        public Double getSalesImpactWeight()
        {    
             if (scorecardQ1 != null && scorecardQ1.SalesImpactWeight__c != null)
             {            
                return  scorecardQ1.SalesImpactWeight__c;
             }
             
             if (scorecardQ2 != null && scorecardQ2.SalesImpactWeight__c != null)
             {             	
                return  scorecardQ2.SalesImpactWeight__c;
             }
             
             if (scorecardQ3 != null && scorecardQ3.SalesImpactWeight__c != null)
             {               
                return  scorecardQ3.SalesImpactWeight__c;
             }
             
             if (scorecardQ4 != null && scorecardQ4.SalesImpactWeight__c != null)
             {             
                return  scorecardQ4.SalesImpactWeight__c;
             }
             
            return 0;
        }
        
        public String getCommentSalesImpact()
        {
            if (currentUserComment != null)
            {
                return currentUserComment.CommentSalesImpact__c;
            }
            else
            {
                return '';
            }   
        }
    }
    
    
/*
* Inner Class 
* gets scorecard comments filtered by sharing rules
*/
    public with sharing class ScorecardUtil { 

        public list<ScorecardSupportComment__c> getScorecardCommentWithSharing(PerformanceReview__c p){

            return [select  s.Reviewer__r.Name, 
		                    s.Reviewer__c, 
		                    s.CommentCS__c, 
		                    s.CommentRenewals__c,
		                    s.CommentSupportInitiatives__c,
		                    s.CommentWMCases__c,
		                    s.CommentWMSMES__c,
		                    s.CommentWMPA__c,
		                    s.CommentWMHC__c,
		                    s.CommentForecastAccuracy__c,
		                    s.CommentTimeOnPlatform__c,
		                    s.CommentSalesImpact__c,
		                    s.CreatedDate, 
		                    s.Locked__c 
                    from ScorecardSupportComment__c s 
                    where  PerformanceReview__c  =: p.Id
                    order by CreatedDate ASC];          
        }     
    }  
    
    
	/*
	* Inner Class
	* comment - comment of the scorecard
	*/
    public class HistoryComments
    {
        ScorecardSupportComment__c comment;
		String createdDate;

        public  HistoryComments(ScorecardSupportComment__c c)
        {
            comment = c;   
			createdDate = c.CreatedDate.format();
        }

        public ScorecardSupportComment__c getComment()
        {
            return comment;
        }

        public void setComment(ScorecardSupportComment__c c)
        {
            comment = c;
        }

		public String getCreatedDate(){
			return createdDate;
		}
		
		public void setCreatedDate(String s){
		}
    }

}