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
 

public with sharing class ScorecardReviewSupportCSController {
    
    PerformanceReview__c performanceR;
    List<ScorecardSupportReview__c> scorecardSupportReviews;
    ScoreCardReviewSupport scorecardReview;
    Boolean showSupportScorecard;
    ScorecardUtil scorecardUtil = new ScorecardUtil();
    List<ScorecardSupportComment__c> historyMethods;
    List<ScorecardSupportComment__c> historyMethodsAux = new List<ScorecardSupportComment__c>();
    ScorecardSupportComment__c currentUserComment = null;
    public boolean hasCommentCS;
    public boolean hasCommentRenewals;
    public boolean hasCommentSI;    
    public boolean hasCommentWMCases;
    public boolean hasCommentWMSMES;
    public boolean hasCommentWMHC;
    public boolean hasCommentWMPA;
    boolean isQ1Q2;
    boolean isQ3Q4;
    String currentUserProfile;
    User scorecardTypeProfile;
 	String userId;
    String currentUserId;
    PerformanceAccessUtil accessUtil;
 	
    boolean isPCOMMLikeViewProfile;

    /*
     * Constructor
     */
    public ScorecardReviewSupportCSController()
    {  
    	userId = UserInfo.getUserId();
    	constructor();
    }
      	
    public ScorecardReviewSupportCSController(String uId)
    {  
    	userId = uId;
    	constructor();
    	accessUtil.setUserInf(uId);
    }
      	
    public void constructor()
    {    	
		// checks the user and the profile
        User currentUser = [Select Id, EmployeeNumber, Profile.Name FROM  User WHERE id =: userId ];
        String employeeNumber = currentUser.EmployeeNumber;
        currentUserProfile = currentUser.Profile.Name;
        currentUserId = userId;
        
		// gets the performance review
        performanceR = [SELECT Id, PremierUser__c, Manager__c, ThirdPartyReviewer__c, PCOMM__C, Name, SecondManager__c, Employee__c, Status__c, PreviousStatus__c, V2MOM__r.V2MOM_Type__c  
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
                                                        WeightWMPA__c, AdjustedRatingWMPA__c, CustomerSatisfactionActual__c, CustomerSatisfactionTarget__c,
                                                        RatingCustomerSatisfaction__c, WeightCustomerSatisfaction__c, TSRActual__c, TSRTarget__c                                                         
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
	        
	        scorecardReview = new ScoreCardReviewSupport(scorecardSupportReviews, performanceR, currentUserComment, !getAdjustedRatingView());
		}else{
			// gets the data of the scorecards filtered with sharing
	        historyMethods = scorecardUtil.getScorecardCommentWithSharing(performanceR);
        	historyMethods = orderScorecardReviewList(historyMethods);
        
	        for(ScorecardSupportComment__c c: historyMethods){
	        	 if ((performanceR.Status__c ==  '3rd Party Assessment' && performanceR.Manager__c == Userinfo.getUserId())
				 	|| performanceR.Status__c ==  '3rd Party Assessment' && performanceR.SecondManager__c == Userinfo.getUserId() )
				 	{
				 		if(c.Reviewer__c == currentUserId){
		        		currentUserComment = c;
			        	} 
			        
			        		historyMethodsAux.add(c);
			        		
				 	}
				 	else
				 	{
				 		
				 		if(c.Reviewer__c == currentUserId){
		        		currentUserComment = c;
			        	} 
			        	//if(c.Locked__c == true){
			        		historyMethodsAux.add(c);
			        	//}		
				 	}
		        	
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

    // gets the Id of the current user
    public Id getUserId(){
    	return userId;
    }

    // gets the Id of the current user
    public String getCurrentUserId(){
        return currentUserId;
    }
    
    // sets the Id of the current user
    public void setUserId(String value){
    	userId = value;
    }
    
    // returns the values for the adjusted rating combo box
    public List<SelectOption> getAdjustedRatingSelectOptions(){
        return PAMUtil.getAdjustedRatingSelectOptions();
    }

    // returns true if the quarter is Q1/Q2
    public boolean getIsQ1Q2(){
    	return isQ1Q2;
    }
	
	public boolean getIsQ1Q2InMgrAssmnt(){
    	return isQ1Q2 && accessUtil.getIsMngrInAssmnt();
    }
	public boolean getIsQ3Q4(){
        return isQ3Q4 && accessUtil.getIsMngrInAssmnt();
    }
    // Returns the PerformanceReview
    public PerformanceReview__c getperformanceR(){
        return  performanceR;   
    }
	//is basic or premier
	public boolean getIsPremierUser(){
    	return performanceR.PremierUser__c;
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
     
      // Manager, 2nd Manager or 3rd Party in Assessment - Write permission in scorecard object
     public boolean getIsMngr2ndMngrOr3PtInAssmnt() {
		return accessUtil.getIsMngr2ndMngrOr3PtInAssmnt();
     } 

	// determines the users and statuses in which the difference can be shown
	public boolean getDifferenceView(){
		return accessUtil.getDifferenceView();
	}
	
	// determines the users and statuses in which the adjusted rating can be shown
	public boolean getAdjustedRatingView(){
		return accessUtil.getAdjustedRatingView();
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
					                    s.CreatedDate,
					                    s.Locked__c 
					                    from ScorecardSupportComment__c s 
					                    where  PerformanceReview__c  =: p.Id
					                    and Locked__c = true 
					                    and (Reviewer__c <>: p.SecondManager__c)
					                    order by CreatedDate ASC];
				    		}          
			    		}else{
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
    
    public List<HistoryComments> getHistoryCommentSupport()
    {
        List<HistoryComments> commentList = new List<HistoryComments>();

        for (ScorecardSupportComment__c sr:historyMethods)
        {
            if (sr.CommentCS__c != null && sr.CommentCS__c != '')
            {   
                if(accessUtil.showRatingAndWeightIn3rdPartyAssmnt() && sr.Locked__c == true){
	                HistoryComments hc = new HistoryComments(sr); 
	                commentList.add(hc);   
            	}    
            }   
        }

        if (commentList.size() > 0)
        {
            hasCommentCS = true;
        }
        else
        {
            hasCommentCS = false;
        }

        return commentList;
    }

    public List<HistoryComments> getHistoryCommentSupportRenewals()
    {
        List<HistoryComments> commentList = new List<HistoryComments>();

        for (ScorecardSupportComment__c sr:historyMethods)
        {
            if (sr.CommentRenewals__c != null && sr.CommentRenewals__c != '')
            {   
                if(accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
	                HistoryComments hc = new HistoryComments(sr); 
	                commentList.add(hc);   
            	}   
            }   
        }

        if (commentList.size() > 0)
        {
            hasCommentRenewals = true;
        }
        else
        {
            hasCommentRenewals = false;
        }

        return commentList;
    }
	
	public List<HistoryComments> getHistoryCommentSupportInitiatives()
    {
        List<HistoryComments> commentList = new List<HistoryComments>();

        for (ScorecardSupportComment__c sr:historyMethods)
        {
            if (sr.CommentSupportInitiatives__c != null && sr.CommentSupportInitiatives__c != '')
            {   
                if(accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
	                HistoryComments hc = new HistoryComments(sr); 
	                commentList.add(hc);   
            	}    
            }   
        }

        if (commentList.size() > 0)
        {
            hasCommentSI = true;
        }
        else
        {
            hasCommentSI = false;
        }

        return commentList;
    }
    
    public List<HistoryComments> getHistoryCommentSupportWMCases()
    {
        List<HistoryComments> commentList = new List<HistoryComments>();

        for (ScorecardSupportComment__c sr: historyMethods)
        {
            if (sr.CommentWMCases__c != null && sr.CommentWMCases__c != '')
            {   
                if(accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
	                HistoryComments hc = new HistoryComments(sr); 
	                commentList.add(hc);   
            	}     
            }   
        }

        if (commentList.size() > 0)
        {
            hasCommentWMCases = true;
        }
        else
        {
            hasCommentWMCases = false;
        }

        return commentList;
    }

    public List<HistoryComments> getHistoryCommentSupportWMSMES()
    {
        List<HistoryComments> commentList = new List<HistoryComments>();

        for (ScorecardSupportComment__c sr: historyMethods)
        {
            if (sr.CommentWMSMES__c != null && sr.CommentWMSMES__c != '')
            {   
               if(accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
	                HistoryComments hc = new HistoryComments(sr); 
	                commentList.add(hc);   
            	}     
            }   
        }

        if (commentList.size() > 0)
        {
            hasCommentWMSMES = true;
        }
        else
        {
            hasCommentWMSMES = false;
        }

        return commentList;
    }
 
     public List<HistoryComments> getHistoryCommentSupportWMPA()
    {
        List<HistoryComments> commentList = new List<HistoryComments>();

        for (ScorecardSupportComment__c sr: historyMethods)
        {
            if (sr.CommentWMPA__c != null && sr.CommentWMPA__c != '')
            {   
                if(accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
	                HistoryComments hc = new HistoryComments(sr); 
	                commentList.add(hc);   
            	}     
            }   
        }

        if (commentList.size() > 0)
        {
            hasCommentWMPA = true;
        }
        else
        {
            hasCommentWMPA = false;
        }

        return commentList;
    }    
    
    public List<HistoryComments> getHistoryCommentSupportWMHC()
    {
        List<HistoryComments> commentList = new List<HistoryComments>();

        for (ScorecardSupportComment__c sr: historyMethods)
        {
            if (sr.CommentWMHC__c != null && sr.CommentWMHC__c != '')
            {   
               if(accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
	                HistoryComments hc = new HistoryComments(sr); 
	                commentList.add(hc);   
            	}     
            }   
        }

        if (commentList.size() > 0)
        {
            hasCommentWMHC = true;
        }
        else
        {
            hasCommentWMHC = false;
        }

        return commentList;
    }    
/*
* END FUNCTIONS TO GET METRIC COMMENTS **************
*/

/*
* BEGIN FUNCTIONS TO GET METRIC HAS COMMENTS **************
*/
	
    public boolean getHasCommentCS(){
        return hasCommentCS;
    }

    public boolean getHasCommentRenewals(){
        return hasCommentRenewals;
    }

	public boolean getHasCommentSI(){
		return hasCommentSI;
	}
	
	public boolean getHasCommentWMCases(){
        return hasCommentWMCases;
    }
	
	public boolean getHasCommentWMSMES(){
        return hasCommentWMSMES;
    }
	
	public boolean getHasCommentWMPA(){
        return hasCommentWMPA;
    }

	public boolean getHasCommentWMHC(){
        return hasCommentWMHC;
    }
/*
* END FUNCTIONS TO GET METRIC HAS COMMENTS **************
*/
	// 3rd Party in Assessment - Write permission
     public boolean getIs3PtInAssmnt() {
        return accessUtil.getIs3PtInAssmnt();
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
        String userId;

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
	    
	    public void setUserId(String value)
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

        // ----------------------- Here Start getters for customer support fields
        public Long getWeightQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.WeightCS__c != null)
            {
                return Math.roundToLong(scorecardQ1.WeightCS__c);  
            }
            else
            {
                return 0;   
            }  
        } 

        public Long getWeightQ2()
        { 

            if (scorecardQ2 != null && scorecardQ2.WeightCS__c != null)
            {
                return Math.roundToLong(scorecardQ2.WeightCS__c);
            }
            else
            {
                return 0;   
            }   
        } 

        public Long getWeightQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.WeightCS__c != null)
            {
                return Math.roundToLong(scorecardQ3.WeightCS__c);
            }
            else
            {
                return 0;   
            }
        } 

        public Long getWeightQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.WeightCS__c != null )
            {
                return Math.roundToLong(scorecardQ4.WeightCS__c);
            }
            else
            {
                return 0;   
            } 
        } 

        public Long getAdjustedRatingQ1()
        {

            if (scorecardQ1 != null && scorecardQ1.AdjustedRatingCS__c != null )
            {
                return Long.valueOf(scorecardQ1.AdjustedRatingCS__c);
            }
            else
            {
                return 0;   
            } 
        } 


        public Long getAdjustedRatingQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.AdjustedRatingCS__c != null)
            {
                return Long.valueOf(scorecardQ2.AdjustedRatingCS__c); 
            }
            else
            {
                return 0;   
            } 
        } 

       

        public Long getAdjustedRatingQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.AdjustedRatingCS__c != null)
            {
                return Long.valueOf(scorecardQ3.AdjustedRatingCS__c); 
            }
            else
            {
                return 0;   
            } 
        } 

        public Long getAdjustedRatingQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.AdjustedRatingCS__c != null)
            {
                return Long.valueOf(scorecardQ4.AdjustedRatingCS__c); 
            }
            else
            {
                return 0;   
            } 
        } 

        public Double getCalculatedRatingQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.CalculatedRatingCS__c != null )
            {
                Decimal shortDouble = scorecardQ1.CalculatedRatingCS__c;
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP);
            }
            else
            {
                return 0;   
            }
        }

        public Double getCalculatedRatingQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.CalculatedRatingCS__c != null )
            {
                Decimal shortDouble = scorecardQ2.CalculatedRatingCS__c;
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP);
            }
            else
            {
                return 0;   
            }
        }

        public Double getCalculatedRatingQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.CalculatedRatingCS__c != null )
            {
                Decimal shortDouble = scorecardQ3.CalculatedRatingCS__c;
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP);
            }
            else
            {
                return 0;   
            }
        }

        public Double getCalculatedRatingQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.CalculatedRatingCS__c != null )
            {
                Decimal shortDouble = scorecardQ4.CalculatedRatingCS__c;
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP);
            }
            else
            {
                return 0;   
            }
        }

        public Double getRatingDifferenceQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.AdjustedRatingCS__c != null)
            {
                Decimal shortDouble = Decimal.valueOf(scorecardQ1.AdjustedRatingCS__c) -  getCalculatedRatingQ1();
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP); 
            }
            else
            {
                return 0;   
            }
        }

        public Double getRatingDifferenceQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.AdjustedRatingCS__c != null)
            {
                Decimal shortDouble = Decimal.valueOf(scorecardQ2.AdjustedRatingCS__c) -  getCalculatedRatingQ2();
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP); 
            }
            else
            {
                return 0;   
            }
        }

        public Double getRatingDifferenceQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.AdjustedRatingCS__c != null)
            {
                Decimal shortDouble = Decimal.valueOf(scorecardQ3.AdjustedRatingCS__c) -  getCalculatedRatingQ3();
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP); 
            }
            else
            {
                return 0;   
            }
        }

        public Double getRatingDifferenceQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.AdjustedRatingCS__c != null)
            {
                Decimal shortDouble = Decimal.valueOf(scorecardQ4.AdjustedRatingCS__c) -  getCalculatedRatingQ4();
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP); 
            }
            else
            {
                return 0;   
            }
        }

        public String getComment()
        {
            if (currentUserComment != null)
            {
                return currentUserComment.CommentCS__c;
            }
            else
            {
                return '';
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

        // ----------------------- Here Start getters for renewals fields
        public Long getWeightQ1Renewals()
        {
            if (scorecardQ1 != null && scorecardQ1.WeightRenewals__c != null)
            {
                return Math.roundToLong(scorecardQ1.WeightRenewals__c);  
            }
            else
            {
                return 0;   
            }  
        } 

        public Long getWeightQ2Renewals()
        { 
            if (scorecardQ2 != null && scorecardQ2.WeightRenewals__c != null)
            {
                return Math.roundToLong(scorecardQ2.WeightRenewals__c);
            }
            else
            {
                return 0;   
            }   
        } 

        public Long getWeightQ3Renewals()
        {
            if (scorecardQ3 != null && scorecardQ3.WeightRenewals__c != null)
            {
                return Math.roundToLong(scorecardQ3.WeightRenewals__c);
            }
            else
            {
                return 0;   
            }
        } 

        public Long getWeightQ4Renewals()
        {
            if (scorecardQ4 != null && scorecardQ4.WeightRenewals__c != null )
            {
                return Math.roundToLong(scorecardQ4.WeightRenewals__c);
            }
            else
            {
                return 0;   
            } 
        } 

        public Long getAdjustedRatingQ1Renewals()
        {
            if (scorecardQ1 != null && scorecardQ1.AdjustedRatingRenewals__c != null )
            {
                return Long.valueOf(scorecardQ1.AdjustedRatingRenewals__c);
            }
            else
            {
                return 0;   
            } 
        } 

       

        public Long getAdjustedRatingQ2Renewals()
        {
            if (scorecardQ2 != null && scorecardQ2.AdjustedRatingRenewals__c != null)
            {
                return Long.valueOf(scorecardQ2.AdjustedRatingRenewals__c); 
            }
            else
            {
                return 0;   
            } 
        } 

        public Long getAdjustedRatingQ3Renewals()
        {
            if (scorecardQ3 != null && scorecardQ3.AdjustedRatingRenewals__c != null)
            {
                return Long.valueOf(scorecardQ3.AdjustedRatingRenewals__c); 
            }
            else
            {
                return 0;   
            } 
        } 

        public Long getAdjustedRatingQ4Renewals()
        {
            if (scorecardQ4 != null && scorecardQ4.AdjustedRatingRenewals__c != null)
            {
                return Long.valueOf(scorecardQ4.AdjustedRatingRenewals__c); 
            }
            else
            {
                return 0;   
            } 
        } 

        public Double getCalculatedRatingQ1Renewals()
        {
            if (scorecardQ1 != null && scorecardQ1.CalculatedRatingRenewals__c != null )
            {
                Decimal shortDouble = scorecardQ1.CalculatedRatingRenewals__c;
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP);
            }
            else
            {
                return 0;   
            }
        }

        public Double getCalculatedRatingQ2Renewals()
        {
            if (scorecardQ2 != null && scorecardQ2.CalculatedRatingRenewals__c != null )
            {
                Decimal shortDouble = scorecardQ2.CalculatedRatingRenewals__c;
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP);
            }
            else
            {
                return 0;   
            }
        }

        public Double getCalculatedRatingQ3Renewals()
        {
            if (scorecardQ3 != null && scorecardQ3.CalculatedRatingRenewals__c != null )
            {
                Decimal shortDouble = scorecardQ3.CalculatedRatingRenewals__c;
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP);
            }
            else
            {
                return 0;   
            }
        }

        public Double getCalculatedRatingQ4Renewals()
        {
            if (scorecardQ4 != null && scorecardQ4.CalculatedRatingRenewals__c != null )
            {
                Decimal shortDouble = scorecardQ4.CalculatedRatingRenewals__c;
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP);
            }
            else
            {
                return 0;   
            }
        }

        public Double getRatingDifferenceQ1Renewals()
        {
            if (scorecardQ1 != null && scorecardQ1.AdjustedRatingRenewals__c != null)
            {
                Decimal shortDouble = Decimal.valueOf(scorecardQ1.AdjustedRatingRenewals__c) -  getCalculatedRatingQ1Renewals();
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP); 
            }
            else
            {
                return 0;   
            }
        }

        public Double getRatingDifferenceQ2Renewals()
        {
            if (scorecardQ2 != null && scorecardQ2.AdjustedRatingRenewals__c != null)
            {
                Decimal shortDouble = Decimal.valueOf(scorecardQ2.AdjustedRatingRenewals__c) -  getCalculatedRatingQ2Renewals();
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP); 
            }
            else
            {
                return 0;   
            }
        }

        public Double getRatingDifferenceQ3Renewals()
        {
            if (scorecardQ3 != null && scorecardQ3.AdjustedRatingRenewals__c != null)
            {
                Decimal shortDouble = Decimal.valueOf(scorecardQ3.AdjustedRatingRenewals__c) -  getCalculatedRatingQ3Renewals();
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP); 
            }
            else
            {
                return 0;   
            }
        }

        public Double getRatingDifferenceQ4Renewals()
        {
            if (scorecardQ4 != null && scorecardQ4.AdjustedRatingRenewals__c != null)
            {
                Decimal shortDouble = Decimal.valueOf(scorecardQ4.AdjustedRatingRenewals__c) -  getCalculatedRatingQ4Renewals();
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP); 
            }
            else
            {
                return 0;   
            }
        }

        public String getCommentRenewals()
        {
            if (currentUserComment != null)
            {
                return currentUserComment.CommentRenewals__c;
            }
            else
            {
                return '';
            }   
        }
        
        // ----------------------- Here Start getters for Support initiatives fields
        public Long getWeightQ1SI()
        {
            if (scorecardQ1 != null && scorecardQ1.WeightSI__c != null)
            {
                return Math.roundToLong(scorecardQ1.WeightSI__c);  
            }
            else
            {
                return 0;   
            }  
        } 

        public Long getWeightQ2SI()
        { 
            if (scorecardQ2 != null && scorecardQ2.WeightSI__c != null)
            {
                return Math.roundToLong(scorecardQ2.WeightSI__c);
            }
            else
            {
                return 0;   
            }   
        } 

        public Long getWeightQ3SI()
        {
            if (scorecardQ3 != null && scorecardQ3.WeightSI__c != null)
            {
                return Math.roundToLong(scorecardQ3.WeightSI__c);
            }
            else
            {
                return 0;   
            }
        } 

        public Long getWeightQ4SI()
        {
            if (scorecardQ4 != null && scorecardQ4.WeightSI__c != null )
            {
                return Math.roundToLong(scorecardQ4.WeightSI__c);
            }
            else
            {
                return 0;   
            } 
        } 

        public Long getAdjustedRatingQ1SI()
        {
            if (scorecardQ1 != null && scorecardQ1.AdjustedRatingSI__c != null )
            {
                return Long.valueOf(scorecardQ1.AdjustedRatingSI__c);
            }
            else
            {
                return 0;   
            } 
        } 
        
        public Long getAdjustedRatingQ2SI()
        {
            if (scorecardQ2 != null && scorecardQ2.AdjustedRatingSI__c != null)
            {
                return Long.valueOf(scorecardQ2.AdjustedRatingSI__c); 
            }
            else
            {
                return 0;   
            } 
        }

        public Long getAdjustedRatingQ3SI()
        {
            if (scorecardQ3 != null && scorecardQ3.AdjustedRatingSI__c != null)
            {
                return Long.valueOf(scorecardQ3.AdjustedRatingSI__c); 
            }
            else
            {
                return 0;   
            } 
        } 


        public Long getAdjustedRatingQ4SI()
        {
            if (scorecardQ4 != null && scorecardQ4.AdjustedRatingSI__c != null)
            {
                return Long.valueOf(scorecardQ4.AdjustedRatingSI__c); 
            }
            else
            {
                return 0;   
            } 
        } 

        public Double getCalculatedRatingQ1SI()
        {
            if (scorecardQ1 != null && scorecardQ1.CalculatedRatingSI__c != null )
            {
                Decimal shortDouble = scorecardQ1.CalculatedRatingSI__c;
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP);
            }
            else
            {
                return 0;   
            }
        }

        public Double getCalculatedRatingQ2SI()
        {
            if (scorecardQ2 != null && scorecardQ2.CalculatedRatingSI__c != null )
            {
                Decimal shortDouble = scorecardQ2.CalculatedRatingSI__c;
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP);
            }
            else
            {
                return 0;   
            }
        }

        public Double getCalculatedRatingQ3SI()
        {
            if (scorecardQ3 != null && scorecardQ3.CalculatedRatingSI__c != null )
            {
                Decimal shortDouble = scorecardQ3.CalculatedRatingSI__c;
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP);
            }
            else
            {
                return 0;   
            }
        }

        public Double getCalculatedRatingQ4SI()
        {
            if (scorecardQ4 != null && scorecardQ4.CalculatedRatingSI__c != null )
            {
                Decimal shortDouble = scorecardQ4.CalculatedRatingSI__c;
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP);
            }
            else
            {
                return 0;   
            }
        }

        public Double getRatingDifferenceQ1SI()
        {
            if (scorecardQ1 != null && scorecardQ1.AdjustedRatingSI__c != null)
            {
                Decimal shortDouble = Decimal.valueOf(scorecardQ1.AdjustedRatingSI__c) -  getCalculatedRatingQ1SI();
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP); 
            }
            else
            {
                return 0;   
            }
        }

        public Double getRatingDifferenceQ2SI()
        {
            if (scorecardQ2 != null && scorecardQ2.AdjustedRatingSI__c != null)
            {
                Decimal shortDouble = Decimal.valueOf(scorecardQ2.AdjustedRatingSI__c) -  getCalculatedRatingQ2SI();
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP); 
            }
            else
            {
                return 0;   
            }
        }

        public Double getRatingDifferenceQ3SI()
        {
            if (scorecardQ3 != null && scorecardQ3.AdjustedRatingSI__c != null)
            {
                Decimal shortDouble = Decimal.valueOf(scorecardQ3.AdjustedRatingSI__c) -  getCalculatedRatingQ3SI();
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP); 
            }
            else
            {
                return 0;   
            }
        }

        public Double getRatingDifferenceQ4SI()
        {
            if (scorecardQ4 != null && scorecardQ4.AdjustedRatingSI__c != null)
            {
                Decimal shortDouble = Decimal.valueOf(scorecardQ4.AdjustedRatingSI__c) -  getCalculatedRatingQ4SI();
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP); 
            }
            else
            {
                return 0;   
            }
        }

        public String getCommentSI()
        {
            if (currentUserComment != null)
            {
                return currentUserComment.CommentSupportInitiatives__c;
            }
            else
            {
                return '';
            }   
        }
        
        // ----------------------- Here Start getters for Workload Management Cases fields
        public Long getWeightQ1WMCases()
        {
            if (scorecardQ1 != null && scorecardQ1.WeightWMCases__c != null)
            {
                return Math.roundToLong(scorecardQ1.WeightWMCases__c);  
            }
            else
            {
                return 0;   
            }  
        } 

        public Long getWeightQ2WMCases()
        { 
            if (scorecardQ2 != null && scorecardQ2.WeightWMCases__c != null)
            {
                return Math.roundToLong(scorecardQ2.WeightWMCases__c);
            }
            else
            {
                return 0;   
            }   
        } 

        public Long getWeightQ3WMCases()
        {
            if (scorecardQ3 != null && scorecardQ3.WeightWMCases__c != null)
            {
                return Math.roundToLong(scorecardQ3.WeightWMCases__c);
            }
            else
            {
                return 0;   
            }
        } 

        public Long getWeightQ4WMCases()
        {
            if (scorecardQ4 != null && scorecardQ4.WeightWMCases__c != null )
            {
                return Math.roundToLong(scorecardQ4.WeightWMCases__c);
            }
            else
            {
                return 0;   
            } 
        } 

        public Long getAdjustedRatingQ1WMCases()
        {
            if (scorecardQ1 != null && scorecardQ1.AdjustedRatingWMCases__c != null )
            {
                return Long.valueOf(scorecardQ1.AdjustedRatingWMCases__c);
            }
            else
            {
                return 0;   
            } 
        } 

        public Long getAdjustedRatingQ2WMCases()
        {
            if (scorecardQ2 != null && scorecardQ2.AdjustedRatingWMCases__c != null)
            {
                return Long.valueOf(scorecardQ2.AdjustedRatingWMCases__c); 
            }
            else
            {
                return 0;   
            } 
        }

        public Long getAdjustedRatingQ3WMCases()
        {
            if (scorecardQ3 != null && scorecardQ3.AdjustedRatingWMCases__c != null)
            {
                return Long.valueOf(scorecardQ3.AdjustedRatingWMCases__c); 
            }
            else
            {
                return 0;   
            } 
        } 

        public Long getAdjustedRatingQ4WMCases()
        {
            if (scorecardQ4 != null && scorecardQ4.AdjustedRatingWMCases__c != null)
            {
                return Long.valueOf(scorecardQ4.AdjustedRatingWMCases__c); 
            }
            else
            {
                return 0;   
            } 
        } 

        public Double getCalculatedRatingQ1WMCases()
        {
            if (scorecardQ1 != null && scorecardQ1.CalculatedRatingWMCases__c != null )
            {
                Decimal shortDouble = scorecardQ1.CalculatedRatingWMCases__c;
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP);
            }
            else
            {
                return 0;   
            }
        }

        public Double getCalculatedRatingQ2WMCases()
        {
            if (scorecardQ2 != null && scorecardQ2.CalculatedRatingWMCases__c != null )
            {
                Decimal shortDouble = scorecardQ2.CalculatedRatingWMCases__c;
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP);
            }
            else
            {
                return 0;   
            }
        }

        public Double getCalculatedRatingQ3WMCases()
        {
            if (scorecardQ3 != null && scorecardQ3.CalculatedRatingWMCases__c != null )
            {
                Decimal shortDouble = scorecardQ3.CalculatedRatingWMCases__c;
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP);
            }
            else
            {
                return 0;   
            }
        }

        public Double getCalculatedRatingQ4WMCases()
        {
            if (scorecardQ4 != null && scorecardQ4.CalculatedRatingWMCases__c != null )
            {
                Decimal shortDouble = scorecardQ4.CalculatedRatingWMCases__c;
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP);
            }
            else
            {
                return 0;   
            }
        }

        public Double getRatingDifferenceQ1WMCases()
        {
            if (scorecardQ1 != null && scorecardQ1.AdjustedRatingWMCases__c != null)
            {
                Decimal shortDouble = Decimal.valueOf(scorecardQ1.AdjustedRatingWMCases__c) -  getCalculatedRatingQ1WMCases();
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP); 
            }
            else
            {
                return 0;   
            }
        }

        public Double getRatingDifferenceQ2WMCases()
        {
            if (scorecardQ2 != null && scorecardQ2.AdjustedRatingWMCases__c != null)
            {
                Decimal shortDouble = Decimal.valueOf(scorecardQ2.AdjustedRatingWMCases__c) -  getCalculatedRatingQ2WMCases();
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP); 
            }
            else
            {
                return 0;   
            }
        }

        public Double getRatingDifferenceQ3WMCases()
        {
            if (scorecardQ3 != null && scorecardQ3.AdjustedRatingWMCases__c != null)
            {
                Decimal shortDouble = Decimal.valueOf(scorecardQ3.AdjustedRatingWMCases__c) -  getCalculatedRatingQ3WMCases();
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP); 
            }
            else
            {
                return 0;   
            }
        }

        public Double getRatingDifferenceQ4WMCases()
        {
            if (scorecardQ4 != null && scorecardQ4.AdjustedRatingWMCases__c != null)
            {
                Decimal shortDouble = Decimal.valueOf(scorecardQ4.AdjustedRatingWMCases__c) -  getCalculatedRatingQ4WMCases();
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP); 
            }
            else
            {
                return 0;   
            }
        }

        public String getCommentWMCases()
        {
            if (currentUserComment != null)
            {
                return currentUserComment.CommentWMCases__c;
            }
            else
            {
                return '';
            }   
        }

        // ----------------------- Here Start getters for Workload Management SME + Solutions fields
        public Long getWeightQ1WMSMES()
        {
            if (scorecardQ1 != null && scorecardQ1.WeightWMSMES__c != null)
            {
                return Math.roundToLong(scorecardQ1.WeightWMSMES__c);  
            }
            else
            {
                return 0;   
            }  
        } 

        public Long getWeightQ2WMSMES()
        { 
            if (scorecardQ2 != null && scorecardQ2.WeightWMSMES__c != null)
            {
                return Math.roundToLong(scorecardQ2.WeightWMSMES__c);
            }
            else
            {
                return 0;   
            }   
        } 

        public Long getWeightQ3WMSMES()
        {
            if (scorecardQ3 != null && scorecardQ3.WeightWMSMES__c != null)
            {
                return Math.roundToLong(scorecardQ3.WeightWMSMES__c);
            }
            else
            {
                return 0;   
            }
        } 

        public Long getWeightQ4WMSMES()
        {
            if (scorecardQ4 != null && scorecardQ4.WeightWMSMES__c != null )
            {
                return Math.roundToLong(scorecardQ4.WeightWMSMES__c);
            }
            else
            {
                return 0;   
            } 
        } 

        public Long getAdjustedRatingQ1WMSMES()
        {
            if (scorecardQ1 != null && scorecardQ1.AdjustedRatingWMSMES__c != null )
            {
                return Long.valueOf(scorecardQ1.AdjustedRatingWMSMES__c);
            }
            else
            {
                return 0;   
            } 
        } 

        public Long getAdjustedRatingQ2WMSMES()
        {
            if (scorecardQ2 != null && scorecardQ2.AdjustedRatingWMSMES__c != null)
            {
                return Long.valueOf(scorecardQ2.AdjustedRatingWMSMES__c); 
            }
            else
            {
                return 0;   
            } 
        } 

        public Long getAdjustedRatingQ3WMSMES()
        {
            if (scorecardQ3 != null && scorecardQ3.AdjustedRatingWMSMES__c != null)
            {
                return Long.valueOf(scorecardQ3.AdjustedRatingWMSMES__c); 
            }
            else
            {
                return 0;   
            } 
        }

        public Long getAdjustedRatingQ4WMSMES()
        {
            if (scorecardQ4 != null && scorecardQ4.AdjustedRatingWMSMES__c != null)
            {
                return Long.valueOf(scorecardQ4.AdjustedRatingWMSMES__c); 
            }
            else
            {
                return 0;   
            } 
        } 

        public Double getCalculatedRatingQ1WMSMES()
        {
            if (scorecardQ1 != null && scorecardQ1.CalculatedRatingWMSMES__c != null )
            {
                Decimal shortDouble = scorecardQ1.CalculatedRatingWMSMES__c;
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP);
            }
            else
            {
                return 0;   
            }
        }

        public Double getCalculatedRatingQ2WMSMES()
        {
            if (scorecardQ2 != null && scorecardQ2.CalculatedRatingWMSMES__c != null )
            {
                Decimal shortDouble = scorecardQ2.CalculatedRatingWMSMES__c;
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP);
            }
            else
            {
                return 0;   
            }
        }

        public Double getCalculatedRatingQ3WMSMES()
        {
            if (scorecardQ3 != null && scorecardQ3.CalculatedRatingWMSMES__c != null )
            {
                Decimal shortDouble = scorecardQ3.CalculatedRatingWMSMES__c;
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP);
            }
            else
            {
                return 0;   
            }
        }

        public Double getCalculatedRatingQ4WMSMES()
        {
            if (scorecardQ4 != null && scorecardQ4.CalculatedRatingWMSMES__c != null )
            {
                Decimal shortDouble = scorecardQ4.CalculatedRatingWMSMES__c;
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP);
            }
            else
            {
                return 0;   
            }
        }

        public Double getRatingDifferenceQ1WMSMES()
        {
            if (scorecardQ1 != null && scorecardQ1.AdjustedRatingWMSMES__c != null)
            {
                Decimal shortDouble = Decimal.valueOf(scorecardQ1.AdjustedRatingWMSMES__c) -  getCalculatedRatingQ1WMSMES();
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP); 
            }
            else
            {
                return 0;   
            }
        }

        public Double getRatingDifferenceQ2WMSMES()
        {
            if (scorecardQ2 != null && scorecardQ2.AdjustedRatingWMSMES__c != null)
            {
                Decimal shortDouble = Decimal.valueOf(scorecardQ2.AdjustedRatingWMSMES__c) -  getCalculatedRatingQ2WMSMES();
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP); 
            }
            else
            {
                return 0;   
            }
        }

        public Double getRatingDifferenceQ3WMSMES()
        {
            if (scorecardQ3 != null && scorecardQ3.AdjustedRatingWMSMES__c != null)
            {
                Decimal shortDouble = Decimal.valueOf(scorecardQ3.AdjustedRatingWMSMES__c) -  getCalculatedRatingQ3WMSMES();
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP); 
            }
            else
            {
                return 0;   
            }
        }

        public Double getRatingDifferenceQ4WMSMES()
        {
            if (scorecardQ4 != null && scorecardQ4.AdjustedRatingWMSMES__c != null)
            {
                Decimal shortDouble = Decimal.valueOf(scorecardQ4.AdjustedRatingWMSMES__c) -  getCalculatedRatingQ4WMSMES();
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP); 
            }
            else
            {
                return 0;   
            }
        }

        public String getCommentWMSMES()
        {
            if (currentUserComment != null)
            {
                return currentUserComment.CommentWMSMES__c;
            }
            else
            {
                return '';
            }   
        }
  
        // ----------------------- Here Start getters for Workload Management Procedure Adherence fields
        public Long getWeightQ1WMPA()
        {
            if (scorecardQ1 != null && scorecardQ1.WeightWMPA__c != null)
            {
                return Math.roundToLong(scorecardQ1.WeightWMPA__c);  
            }
            else
            {
                return 0;   
            }  
        } 

        public Long getWeightQ2WMPA()
        { 
            if (scorecardQ2 != null && scorecardQ2.WeightWMPA__c != null)
            {
                return Math.roundToLong(scorecardQ2.WeightWMPA__c);
            }
            else
            {
                return 0;   
            }   
        } 

        public Long getWeightQ3WMPA()
        {
            if (scorecardQ3 != null && scorecardQ3.WeightWMPA__c != null)
            {
                return Math.roundToLong(scorecardQ3.WeightWMPA__c);
            }
            else
            {
                return 0;   
            }
        } 

        public Long getWeightQ4WMPA()
        {
            if (scorecardQ4 != null && scorecardQ4.WeightWMPA__c != null )
            {
                return Math.roundToLong(scorecardQ4.WeightWMPA__c);
            }
            else
            {
                return 0;   
            } 
        } 

        public Long getAdjustedRatingQ1WMPA()
        {
            if (scorecardQ1 != null && scorecardQ1.AdjustedRatingWMPA__c != null )
            {
                return Long.valueOf(scorecardQ1.AdjustedRatingWMPA__c);
            }
            else
            {
                return 0;   
            } 
        } 

        public Long getAdjustedRatingQ2WMPA()
        {
            if (scorecardQ2 != null && scorecardQ2.AdjustedRatingWMPA__c != null)
            {
                return Long.valueOf(scorecardQ2.AdjustedRatingWMPA__c); 
            }
            else
            {
                return 0;   
            } 
        } 

 
        public Long getAdjustedRatingQ3WMPA()
        {
            if (scorecardQ3 != null && scorecardQ3.AdjustedRatingWMPA__c != null)
            {
                return Long.valueOf(scorecardQ3.AdjustedRatingWMPA__c); 
            }
            else
            {
                return 0;   
            } 
        } 


        public Long getAdjustedRatingQ4WMPA()
        {
            if (scorecardQ4 != null && scorecardQ4.AdjustedRatingWMPA__c != null)
            {
                return Long.valueOf(scorecardQ4.AdjustedRatingWMPA__c); 
            }
            else
            {
                return 0;   
            } 
        } 

    

        public String getCommentWMPA()
        {
            if (currentUserComment != null)
            {
                return currentUserComment.CommentWMPA__c;
            }
            else
            {
                return '';
            }   
        }
        
        // ----------------------- Here Start getters for Workload Management Health Checks fields
        public Long getWeightQ1WMHC()
        {
            if (scorecardQ1 != null && scorecardQ1.WeightWMHC__c != null)
            {
                return Math.roundToLong(scorecardQ1.WeightWMHC__c);  
            }
            else
            {
                return 0;   
            }  
        } 

        public Long getWeightQ2WMHC()
        { 
            if (scorecardQ2 != null && scorecardQ2.WeightWMHC__c != null)
            {
                return Math.roundToLong(scorecardQ2.WeightWMHC__c);
            }
            else
            {
                return 0;   
            }   
        } 

        public Long getWeightQ3WMHC()
        {
            if (scorecardQ3 != null && scorecardQ3.WeightWMHC__c != null)
            {
                return Math.roundToLong(scorecardQ3.WeightWMHC__c);
            }
            else
            {
                return 0;   
            }
        } 

        public Long getWeightQ4WMHC()
        {
            if (scorecardQ4 != null && scorecardQ4.WeightWMHC__c != null )
            {
                return Math.roundToLong(scorecardQ4.WeightWMHC__c);
            }
            else
            {
                return 0;   
            } 
        } 

        public Long getAdjustedRatingQ1WMHC()
        {
            if (scorecardQ1 != null && scorecardQ1.AdjustedRatingWMHC__c != null )
            {
                return Long.valueOf(scorecardQ1.AdjustedRatingWMHC__c);
            }
            else
            {
                return 0;   
            } 
        } 


        public Long getAdjustedRatingQ2WMHC()
        {
            if (scorecardQ2 != null && scorecardQ2.AdjustedRatingWMHC__c != null)
            {
                return Long.valueOf(scorecardQ2.AdjustedRatingWMHC__c); 
            }
            else
            {
                return 0;   
            } 
        } 

        public Long getAdjustedRatingQ3WMHC()
        {
            if (scorecardQ3 != null && scorecardQ3.AdjustedRatingWMHC__c != null)
            {
                return Long.valueOf(scorecardQ3.AdjustedRatingWMHC__c); 
            }
            else
            {
                return 0;   
            } 
        }

        public Long getAdjustedRatingQ4WMHC()
        {
            if (scorecardQ4 != null && scorecardQ4.AdjustedRatingWMHC__c != null)
            {
                return Long.valueOf(scorecardQ4.AdjustedRatingWMHC__c); 
            }
            else
            {
                return 0;   
            } 
        } 

      
        public Double getCalculatedRatingQ1WMHC()
        {
            if (scorecardQ1 != null && scorecardQ1.CalculatedRatingWMHC__c != null )
            {
                Decimal shortDouble = scorecardQ1.CalculatedRatingWMHC__c;
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP);
            }
            else
            {
                return 0;   
            }
        }

        public Double getCalculatedRatingQ2WMHC()
        {
            if (scorecardQ2 != null && scorecardQ2.CalculatedRatingWMHC__c != null )
            {
                Decimal shortDouble = scorecardQ2.CalculatedRatingWMHC__c;
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP);
            }
            else
            {
                return 0;   
            }
        }

        public Double getCalculatedRatingQ3WMHC()
        {
            if (scorecardQ3 != null && scorecardQ3.CalculatedRatingWMHC__c != null )
            {
                Decimal shortDouble = scorecardQ3.CalculatedRatingWMHC__c;
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP);
            }
            else
            {
                return 0;   
            }
        }

        public Double getCalculatedRatingQ4WMHC()
        {
            if (scorecardQ4 != null && scorecardQ4.CalculatedRatingWMHC__c != null )
            {
                Decimal shortDouble = scorecardQ4.CalculatedRatingWMHC__c;
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP);
            }
            else
            {
                return 0;   
            }
        }

        public Double getRatingDifferenceQ1WMHC()
        {
            if (scorecardQ1 != null && scorecardQ1.AdjustedRatingWMHC__c != null)
            {
                Decimal shortDouble = Decimal.valueOf(scorecardQ1.AdjustedRatingWMHC__c) -  getCalculatedRatingQ1WMHC();
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP); 
            }
            else
            {
                return 0;   
            }
        }

        public Double getRatingDifferenceQ2WMHC()
        {
            if (scorecardQ2 != null && scorecardQ2.AdjustedRatingWMHC__c != null)
            {
                Decimal shortDouble = Decimal.valueOf(scorecardQ2.AdjustedRatingWMHC__c) -  getCalculatedRatingQ2WMHC();
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP); 
            }
            else
            {
                return 0;   
            }
        }

        public Double getRatingDifferenceQ3WMHC()
        {
            if (scorecardQ3 != null && scorecardQ3.AdjustedRatingWMHC__c != null)
            {
                Decimal shortDouble = Decimal.valueOf(scorecardQ3.AdjustedRatingWMHC__c) -  getCalculatedRatingQ3WMHC();
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP); 
            }
            else
            {
                return 0;   
            }
        }

        public Double getRatingDifferenceQ4WMHC()
        {
            if (scorecardQ4 != null && scorecardQ4.AdjustedRatingWMHC__c != null)
            {
                Decimal shortDouble = Decimal.valueOf(scorecardQ4.AdjustedRatingWMHC__c) -  getCalculatedRatingQ4WMHC();
                return shortDouble.divide(1,2,System.RoundingMode.HALF_UP); 
            }
            else
            {
                return 0;   
            }
        }

        public String getCommentWMHC()
        {
            if (currentUserComment != null)
            {
                return currentUserComment.CommentWMHC__c;
            }
            else
            {
                return '';
            }   
        }
        
        
        
        
        // HERE STARTS THE ACTUAL/TARGET METHODS FOR THE NEW CUSTOMER SATISFACTION
        
        
        public boolean getIsOld(){
        	if((scorecardQ1 != null && scorecardQ1.CustomerSatisfactionActual__c == null && scorecardQ1.CustomerSatisfactionTarget__c == null
        	   && scorecardQ2 != null && scorecardQ2.CustomerSatisfactionActual__c == null && scorecardQ2.CustomerSatisfactionTarget__c == null)
        	   || (scorecardQ3 != null && scorecardQ3.CustomerSatisfactionActual__c == null && scorecardQ3.CustomerSatisfactionTarget__c == null
        	   && scorecardQ4 != null && scorecardQ4.CustomerSatisfactionActual__c == null && scorecardQ4.CustomerSatisfactionTarget__c == null)){
        		
        		return true;
        	}
        	return false;
        }
        
        public Double getCustomerSatisfactionActualQ1()
        {
        	
            if (scorecardQ1 != null && scorecardQ1.CustomerSatisfactionActual__c != null)
            {
                return  scorecardQ1.CustomerSatisfactionActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getCustomerSatisfactionActualQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.CustomerSatisfactionActual__c != null)
            {
                return  scorecardQ2.CustomerSatisfactionActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getCustomerSatisfactionActualQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.CustomerSatisfactionActual__c != null)
            {
            	
                return  scorecardQ3.CustomerSatisfactionActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getCustomerSatisfactionActualQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.CustomerSatisfactionActual__c != null)
            {
                return  scorecardQ4.CustomerSatisfactionActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getCustomerSatisfactionTargetQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.CustomerSatisfactionTarget__c != null)
            {
                return  scorecardQ1.CustomerSatisfactionTarget__c;
            }
            else
            {
                return 0;   
            }   
        }
        
        public Double getCustomerSatisfactionTargetQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.CustomerSatisfactionTarget__c != null)
            {
                return  scorecardQ2.CustomerSatisfactionTarget__c;
            }
            else
            {
                return 0;   
            }   
        }
        
        public Double getCustomerSatisfactionTargetQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.CustomerSatisfactionTarget__c != null)
            {
                return  scorecardQ3.CustomerSatisfactionTarget__c;
            }
            else
            {
                return 0;   
            }   
        }
        
        public Double getCustomerSatisfactionTargetQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.CustomerSatisfactionTarget__c != null)
            {
                return  scorecardQ4.CustomerSatisfactionTarget__c;
            }
            else
            {
                return 0;   
            }       
        }
        
        public Long getCustomerSatisfactionAttainmentQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.CustomerSatisfactionActual__c != null && scorecardQ1.CustomerSatisfactionTarget__c != null)
            {
                if (scorecardQ1.CustomerSatisfactionTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ1.CustomerSatisfactionActual__c / scorecardQ1.CustomerSatisfactionTarget__c) * 100);
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
        
        public Long getCustomerSatisfactionAttainmentQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.CustomerSatisfactionActual__c != null && scorecardQ2.CustomerSatisfactionTarget__c != null)
            {
                if (scorecardQ2.CustomerSatisfactionTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ2.CustomerSatisfactionActual__c / scorecardQ2.CustomerSatisfactionTarget__c) * 100);
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
        
        public Long getCustomerSatisfactionAttainmentQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.CustomerSatisfactionActual__c != null && scorecardQ3.CustomerSatisfactionTarget__c != null)
            {
                if (scorecardQ3.CustomerSatisfactionTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ3.CustomerSatisfactionActual__c / scorecardQ3.CustomerSatisfactionTarget__c) * 100);
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
        
        public Long getCustomerSatisfactionAttainmentQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.CustomerSatisfactionActual__c != null && scorecardQ4.CustomerSatisfactionTarget__c != null)
            {
                if (scorecardQ4.CustomerSatisfactionTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ4.CustomerSatisfactionActual__c / scorecardQ4.CustomerSatisfactionTarget__c) * 100);
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
        
        
        
        /*
        *  NEW TABLE *********************************************
        */
        
        public Double getTSRActualQ1()
        {
        	
            if (scorecardQ1 != null && scorecardQ1.TSRActual__c != null)
            {
                return  scorecardQ1.TSRActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getTSRActualQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.TSRActual__c != null)
            {
                return  scorecardQ2.TSRActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getTSRActualQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.TSRActual__c != null)
            {
            	
                return  scorecardQ3.TSRActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getTSRActualQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.TSRActual__c != null)
            {
                return  scorecardQ4.TSRActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getTSRTargetQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.TSRTarget__c != null)
            {
                return  scorecardQ1.TSRTarget__c;
            }
            else
            {
                return 0;   
            }   
        }
        
        public Double getTSRTargetQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.TSRTarget__c != null)
            {
                return  scorecardQ2.TSRTarget__c;
            }
            else
            {
                return 0;   
            }   
        }
        
        public Double getTSRTargetQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.TSRTarget__c != null)
            {
                return  scorecardQ3.TSRTarget__c;
            }
            else
            {
                return 0;   
            }   
        }
        
        public Double getTSRTargetQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.TSRTarget__c != null)
            {
                return  scorecardQ4.TSRTarget__c;
            }
            else
            {
                return 0;   
            }       
        }
        
        public Long getTSRAttainmentQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.TSRActual__c != null && scorecardQ1.TSRTarget__c != null)
            {
                if (scorecardQ1.TSRTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ1.TSRActual__c / scorecardQ1.TSRTarget__c) * 100);
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
        
        public Long getTSRAttainmentQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.TSRActual__c != null && scorecardQ2.TSRTarget__c != null)
            {
                if (scorecardQ2.TSRTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ2.TSRActual__c / scorecardQ2.TSRTarget__c) * 100);
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
        
        public Long getTSRAttainmentQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.TSRActual__c != null && scorecardQ3.TSRTarget__c != null)
            {
                if (scorecardQ3.TSRTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ3.TSRActual__c / scorecardQ3.TSRTarget__c) * 100);
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
        
        public Long getTSRAttainmentQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.TSRActual__c != null && scorecardQ4.TSRTarget__c != null)
            {
                if (scorecardQ4.TSRTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ4.TSRActual__c / scorecardQ4.TSRTarget__c) * 100);
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
        
        
  
        /**************************************************************/
        
        public String getCustomerSatisfactionRating()
        {
       	
             if (scorecardQ1 != null && scorecardQ1.RatingCustomerSatisfaction__c != null)
             {
            	if(scorecardQ1.RatingCustomerSatisfaction__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ1.RatingCustomerSatisfaction__c.intValue());
             }
           
             if (scorecardQ2 != null && scorecardQ2.RatingCustomerSatisfaction__c != null)
             {
				if(scorecardQ2.RatingCustomerSatisfaction__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ2.RatingCustomerSatisfaction__c.intValue());
             }
             
             if (scorecardQ3 != null && scorecardQ3.RatingCustomerSatisfaction__c != null)
             {
                if(scorecardQ3.RatingCustomerSatisfaction__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ3.RatingCustomerSatisfaction__c.intValue());
             }
             
             if (scorecardQ4 != null && scorecardQ4.RatingCustomerSatisfaction__c != null)
             {
                if(scorecardQ4.RatingCustomerSatisfaction__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ4.RatingCustomerSatisfaction__c.intValue());
             }
             
             return '--None--';
        }
       
        public String getRatingDescription(Integer value)
        {
            return PAMUtil.getRatingLabel(value);
        }
        
        public Double getCustomerSatisfactionWeight()
        {    
             if (scorecardQ1 != null && scorecardQ1.WeightCustomerSatisfaction__c != null)
             {
                return  scorecardQ1.WeightCustomerSatisfaction__c;
             }
             
             if (scorecardQ2 != null && scorecardQ2.WeightCustomerSatisfaction__c != null)
             {
                return  scorecardQ2.WeightCustomerSatisfaction__c;
             }
             
             if (scorecardQ3 != null && scorecardQ3.WeightCustomerSatisfaction__c != null)
             {
                return  scorecardQ3.WeightCustomerSatisfaction__c;
             }
             
             if (scorecardQ4 != null && scorecardQ4.WeightCustomerSatisfaction__c != null)
             {
                return  scorecardQ4.WeightCustomerSatisfaction__c;
             }
             
            return 0;
        }
        
        public Decimal getYTDActual()
        {
            Decimal total = 0;
            
            if (scorecardQ1 != null && scorecardQ1.CustomerSatisfactionActual__c != null)
            {
                total  = total + scorecardQ1.CustomerSatisfactionActual__c;
            }
            
            if (scorecardQ2 != null && scorecardQ2.CustomerSatisfactionActual__c != null)
            {
                total = total + scorecardQ2.CustomerSatisfactionActual__c;
            }
            
            if (scorecardQ3 != null && scorecardQ3.CustomerSatisfactionActual__c != null)
            {
                total = total +  scorecardQ3.CustomerSatisfactionActual__c;
            }
            
            if (scorecardQ4 != null && scorecardQ4.CustomerSatisfactionActual__c != null)
            {
                total = total + scorecardQ4.CustomerSatisfactionActual__c;
            }
            
            total = total.divide(1,4,System.RoundingMode.HALF_DOWN);     
            return (total);
        }
        
        public Decimal getYTDTarget()
        {
            Decimal total = 0;
            
            if (scorecardQ1 != null && scorecardQ1.CustomerSatisfactionTarget__c != null)
            {
                total = total + scorecardQ1.CustomerSatisfactionTarget__c;
            }
            
            if (scorecardQ2 != null && scorecardQ2.CustomerSatisfactionTarget__c != null)
            {
                total = total +  scorecardQ2.CustomerSatisfactionTarget__c;
            }
            
            if (scorecardQ3 != null && scorecardQ3.CustomerSatisfactionTarget__c != null)
            {
                total = total + scorecardQ3.CustomerSatisfactionTarget__c;
            }
            
            if (scorecardQ4 != null && scorecardQ4.CustomerSatisfactionTarget__c != null)
            {
                total = total +  scorecardQ4.CustomerSatisfactionTarget__c;
            }
            
            total = total.divide(1,4,System.RoundingMode.HALF_DOWN);     
            return (total);
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
        
        
        public Decimal getYTDActualTSR()
        {
            Decimal total = 0;
            
            if (scorecardQ1 != null && scorecardQ1.TSRActual__c != null)
            {
                total  = total + scorecardQ1.TSRActual__c;
            }
            
            if (scorecardQ2 != null && scorecardQ2.TSRActual__c != null)
            {
                total = total + scorecardQ2.TSRActual__c;
            }
            
            if (scorecardQ3 != null && scorecardQ3.TSRActual__c != null)
            {
                total = total +  scorecardQ3.TSRActual__c;
            }
            
            if (scorecardQ4 != null && scorecardQ4.TSRActual__c != null)
            {
                total = total + scorecardQ4.TSRActual__c;
            }
            
            total = total.divide(1,4,System.RoundingMode.HALF_DOWN);     
            return (total);
        }
        
        public Decimal getYTDTargetTSR()
        {
            Decimal total = 0;
            
            if (scorecardQ1 != null && scorecardQ1.TSRTarget__c != null)
            {
                total = total + scorecardQ1.TSRTarget__c;
            }
            
            if (scorecardQ2 != null && scorecardQ2.TSRTarget__c != null)
            {
                total = total +  scorecardQ2.TSRTarget__c;
            }
            
            if (scorecardQ3 != null && scorecardQ3.TSRTarget__c != null)
            {
                total = total + scorecardQ3.TSRTarget__c;
            }
            
            if (scorecardQ4 != null && scorecardQ4.TSRTarget__c != null)
            {
                total = total +  scorecardQ4.TSRTarget__c;
            }
            
            total = total.divide(1,4,System.RoundingMode.HALF_DOWN);     
            return (total);
        }
        
        public Long getYTDAttainmentTSR()
        {
            Double target = 0;
            Double actual = 0;
            Double result = 0;
            
            target = getYTDTargetTSR();
            actual = getYTDActualTSR();
            
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
                    s.CreatedDate, 
                    s.Locked__c 
                    from ScorecardSupportComment__c s 
                    where  PerformanceReview__c  =: p.Id
                    order by CreatedDate ASC];          
        }     
    }  

}