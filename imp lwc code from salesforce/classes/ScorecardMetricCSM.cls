/*
 * RelEng Perforce/RCS Header - Do not remove!
 *
 * $Author: gmalik $Fabritzio Calvetti
 * $Change: 1975622 $
 * $DateTime: 2011/09/23 12:18:30 $
 * $File: //it/applications/peopleforce/prod/src/classes/ScorecardMetricCSM.cls $
 * $Id: //it/applications/peopleforce/prod/src/classes/ScorecardMetricCSM.cls#4 $
 * $Revision: #4 $
 */

/*
 * this class will take an account and assign it to a user.
*/
public with sharing class ScorecardMetricCSM {
           
    String          tableType;    
    PerformanceReview__c performanceR;
    List<ScorecardSupportReview__c> scorecardSupportReviews;
    boolean isQ1Q2;
    boolean isQ3Q4;
    public boolean isPCOMMLikeViewProfile;
    ScoreCardReviewSupport scorecardReview;
    ScorecardUtil scorecardUtil = new ScorecardUtil();
    List<ScorecardSupportComment__c> historyMethods;
    List<ScorecardSupportComment__c> historyMethodsAux = new List<ScorecardSupportComment__c>();
    ScorecardSupportComment__c currentUserComment = null;
    public boolean hasCommentRenewalExcellence;
    public boolean hasCommentOperationalExcellence;
    public boolean hasCommentStrategicInitiatives;
    public boolean hasCommentCSMSalesImpact;
    String currentUserProfile;
    String currentUserId;
    public String userId = UserInfo.getUserId();
    User scorecardTypeProfile;
    PerformanceAccessUtil accessUtil;
    List<ProjectReview__c> projectReviews;
    ProjectReview__c projectReview = new ProjectReview__c();

    public ScorecardMetricCSM()
    {
        constructor();
    }

    public ScorecardMetricCSM (Id i)
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
        performanceR = [SELECT Id, Manager__c, ThirdPartyReviewer__c, PCOMM__c, Name, SecondManager__c, Employee__c, Status__c, PerformanceReviewPeriod__c, PerformanceReviewPeriod__r.Effective_Date__c, PreviousStatus__c, V2MOM__r.V2MOM_Type__c  
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
                                                        TimeOnPlatformActual__c, TimeOnPlatformTarget__c, TimeOnPlatformWeight__c, TimeOnPlatformRating__c,
                                                        RenewalExcellenceActual__c, RenewalExcellenceTarget__c, RenewalExcellenceRating__c, RenewalExcellenceWeight__c,
                                                        OperationalExcellenceActual__c, OperationalExcellenceTarget__c, OperationalExcellenceRating__c, OperationalExcellenceWeight__c,
                                                        StrategicInitiativesRating__c, StrategicInitiativesWeight__c,
                                                        CSMSalesImpactActual__c, CSMSalesImpactTarget__c, CSMSalesImpactRating__c, CSMSalesImpactWeight__c ,
                                                        SIPipeLineContributionActual__c, SIPipeLineContributionTraningActual__c, SIPipeLineContributionConsultingActual__c,
                                                        SIPipeLineContributionConsultingTarget__c, SIPipeLineContributionTarget__c, SIPipeLineContributionTraningTarget__c,
                                                        ExecutiveRelationshipsActual__c, ExecutiveRelationshipsTarget__c,
                                                        CSEAmountActual__c, CSEAmountTarget__c,
                                                        ACVGrowthActual__c, ACVGrowthTarget__c, PipelineContributionActual__c, PipelineContributionTarget__c
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
               // }
            }
            
            historyMethods = historyMethodsAux;
            
            scorecardReview = new ScoreCardReviewSupport(scorecardSupportReviews, performanceR, currentUserComment);
        }
        
        
        //load the performance Review ProjectReview
        
        if(performanceR != null){
        	projectReviews = [Select Id, Name, Description__c from ProjectReview__c where PerformanceReview__c =: performanceR.Id Order by CreatedDate];	
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
    
    public boolean getIsQ1Q2Only(){
        return isQ1Q2;
    }
    
    public boolean getIsQ3Q4Only(){
        return isQ3Q4;
    }
    
    public boolean getIsQ3Q4(){
        return isQ3Q4 && accessUtil.getIsMngrInAssmnt();
    }
    
    public boolean getIsOldCSM(){
		if(performanceR.PerformanceReviewPeriod__r.Effective_Date__c == 'FY08' || performanceR.PerformanceReviewPeriod__r.Effective_Date__c == 'FY09'){
			return true;
		}
    	
    	return false;
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
	
	//PROJECT REVIEWS CODE
	public List<ProjectReview__c> getProjectReviews(){
		return projectReviews;	
	}
	public ProjectReview__c getProjectReview(){
		return projectReview;
	}
	public void setProjectReview(ProjectReview__c p){
		projectReview = p;
	}
	public void saveProjectsReview(){
		if(projectReview != null){
			projectReview.PerformanceReview__c = performanceR.Id;
			insert projectReview;	
		}	
		projectReview = new ProjectReview__c();
		projectReviews = [Select Id, Name, Description__c from ProjectReview__c where PerformanceReview__c =: performanceR.Id Order by CreatedDate];	
	}
	
	public void saveProjectsReviewWithHideLoading(){
		if(projectReview != null){
			projectReview.PerformanceReview__c = performanceR.Id;
			insert projectReview;	
		}	
		projectReview = new ProjectReview__c();
		projectReviews = [Select Id, Name, Description__c from ProjectReview__c where PerformanceReview__c =: performanceR.Id Order by CreatedDate];	
	}
	public void deleteProjectReview(){
		String projectId = System.currentPageReference().getParameters().get('projectId');
		
		if(projectId != null){
			ProjectReview__c project = [Select Id, Name, Description__c from ProjectReview__c where Id =: projectId];
			if(project != null){
				delete project;	
			}
		}
		projectReviews = [Select Id, Name, Description__c from ProjectReview__c where PerformanceReview__c =: performanceR.Id Order by CreatedDate];	
	}
	
	public void updateProjectReview(){
		if(projectReviews != null){
			update 	projectReviews;
		}
		projectReviews = [Select Id, Name, Description__c from ProjectReview__c where PerformanceReview__c =: performanceR.Id Order by CreatedDate];
	}
    // gets the V2MOM Type of the performance review
    public String getv2momType(){
        return performanceR.V2MOM__r.V2MOM_Type__c;   
    }
    
    // sets the parameter of the component
    
    public void setTableType(String tableType){
        this.tableType = tableType;
    }
    
    public String getTableType(){
        return this.tableType;
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
     
     public boolean getIsMngr2ndMngrOrEmplInAssmnt(){
     	return true;
     }
     
     public boolean getIsEmployeeInAssmnt(){
     	return accessUtil.getIsEmplInAssmnt();
     }
     
     public boolean getIsEmplInAssmntOnly(){
     	return true;
     }
     
     public boolean getIsEmplMngr2ndMngrOr3PtInAssmnt() {
		return accessUtil.getIsEmplMngr2ndMngrOr3PtInAssmnt();
     }
     
      public boolean getIsEmplMngr2ndMngr(){
         return accessUtil.getIsEmplMngr2ndMngr();
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
                                        s.CommentRenewalExcellence__c,
                                        s.CommentStrategicInitiatives__c,
                                        s.CommentOperationalExcellence__c,
                                        s.CommentCSMSalesImpact__c,
                                        s.CreatedDate, s.Locked__c
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
                                        s.CommentRenewalExcellence__c,
                                        s.CommentOperationalExcellence__c,
                                        s.CommentStrategicInitiatives__c,
                                        s.CommentCSMSalesImpact__c,
                                        s.CreatedDate, Locked__c
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
                                            s.CommentRenewalExcellence__c,
                                            s.CommentOperationalExcellence__c,
                                            s.CommentStrategicInitiatives__c,
                                            s.CommentCSMSalesImpact__c,
                                            s.CreatedDate , Locked__c
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
        
    public List<HistoryComments> getHistoryCommentRenewalExcellence()
    {
        List<HistoryComments> commentList = new List<HistoryComments>();

        for (ScorecardSupportComment__c sr:historyMethods)
        {
            if (sr.CommentRenewalExcellence__c != null && sr.CommentRenewalExcellence__c != '')
            {   
                if(accessUtil.showRatingAndWeightIn3rdPartyAssmnt() && sr.Locked__c == true){
	                HistoryComments hc = new HistoryComments(sr); 
	                commentList.add(hc);   
            	}     
            }   
        } 

        if (commentList.size() > 0)
        {
            hasCommentRenewalExcellence = true;
        }
        else
        {
            hasCommentRenewalExcellence = false;
        }

        return commentList;
    }
    
     public List<HistoryComments> getHistoryCommentOperationalExcellence()
    {
        List<HistoryComments> commentList = new List<HistoryComments>();

        for (ScorecardSupportComment__c sr:historyMethods)
        {
            if (sr.CommentOperationalExcellence__c != null && sr.CommentOperationalExcellence__c != '')
            {   
            	if(accessUtil.showRatingAndWeightIn3rdPartyAssmnt() && sr.Locked__c == true){
	                HistoryComments hc = new HistoryComments(sr); 
	                commentList.add(hc);   
            	} 
            }   
        } 

        if (commentList.size() > 0)
        {
            hasCommentOperationalExcellence = true;
        }
        else
        {
            hasCommentOperationalExcellence = false;
        }

        return commentList;
    } 
    
    public List<HistoryComments> getHistoryCommentStrategicInitiatives()
    {
        List<HistoryComments> commentList = new List<HistoryComments>();

        for (ScorecardSupportComment__c sr:historyMethods)
        {
            if (sr.CommentStrategicInitiatives__c != null && sr.CommentStrategicInitiatives__c != '')
            {   
                if(performanceR.Status__c == 'Employee Approval' || performanceR.Status__c == 'Complete' ){
                	HistoryComments hc = new HistoryComments(sr); 
	                commentList.add(hc); 
                }
                else{
	                if(accessUtil.showRatingAndWeightIn3rdPartyAssmnt() && sr.Locked__c == true){	               
		                HistoryComments hc = new HistoryComments(sr); 
		                commentList.add(hc);  	                 
	            	}
                }     
            }   
        } 

        if (commentList.size() > 0)
        {
            hasCommentStrategicInitiatives = true;
        }
        else
        {
            hasCommentStrategicInitiatives = false;
        }

        return commentList;
    } 
    
    public List<HistoryComments> getHistoryCommentCSMSalesImpact()
    {
        List<HistoryComments> commentList = new List<HistoryComments>();

        for (ScorecardSupportComment__c sr:historyMethods)
        {
            if (sr.CommentCSMSalesImpact__c != null && sr.CommentCSMSalesImpact__c != '')
            {   
                if(accessUtil.showRatingAndWeightIn3rdPartyAssmnt() && sr.Locked__c == true){ 
	                HistoryComments hc = new HistoryComments(sr); 
	                commentList.add(hc);   
            	}  
            }   
        } 

        if (commentList.size() > 0)
        {
            hasCommentCSMSalesImpact = true;
        }
        else
        {
            hasCommentCSMSalesImpact = false;
        }

        return commentList;
    }
    
    
    public Boolean getHasCommentOperationalExcellence(){
        return hasCommentOperationalExcellence;
    }  
    
    public Boolean getHasCommentStrategicInitiatives(){
        return hasCommentStrategicInitiatives;
    }  
    
    public Boolean getHasCommentRenewalExcellence(){
        return hasCommentRenewalExcellence;
    } 
    
    public Boolean getHasCommentCSMSalesImpact(){
        return hasCommentCSMSalesImpact;   
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
                s.RenewalExcellenceWeight__c = null;
                s.RenewalExcellenceRating__c = null;
                s.OperationalExcellenceWeight__c = null;
                s.OperationalExcellenceRating__c = null;
                s.StrategicInitiativesWeight__c = null;
                s.StrategicInitiativesRating__c = null;               
                s.CSMSalesImpactRating__c = null;
                s.CSMSalesImpactWeight__c = null;
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
        
        // -------------------------------- Here start getters for Renewal Excellence fields
        public Long getRenewalExcellenceActualQ1()
        {
            
            if (scorecardQ1 != null && scorecardQ1.RenewalExcellenceActual__c != null)
            {
                
                return  Math.roundToLong(scorecardQ1.RenewalExcellenceActual__c);
            }
            else
            {
                return 0;   
            } 
        }
        
        public Long getRenewalExcellenceActualQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.RenewalExcellenceActual__c != null)
            {
            
                return  Math.roundToLong(scorecardQ2.RenewalExcellenceActual__c);
            }
            else
            {
                return 0;   
            } 
        }
        
        public Long getRenewalExcellenceActualQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.RenewalExcellenceActual__c != null)
            {
                
                
                return  Math.roundToLong(scorecardQ3.RenewalExcellenceActual__c);
            }
            else
            {
                return 0;   
            } 
        }
        
        public Long getRenewalExcellenceActualQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.RenewalExcellenceActual__c != null)
            {
                return  Math.roundToLong(scorecardQ4.RenewalExcellenceActual__c);
            }
            else
            {
                return 0;   
            } 
        }
        
        public Long getRenewalExcellenceTargetQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.RenewalExcellenceTarget__c != null)
            {
                return  Math.roundToLong(scorecardQ1.RenewalExcellenceTarget__c);
            }
            else
            {
                return 0;   
            }   
        }
        
        public Long getRenewalExcellenceTargetQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.RenewalExcellenceTarget__c != null)
            {
                return  Math.roundToLong(scorecardQ2.RenewalExcellenceTarget__c);
            }
            else
            {
                return 0;   
            }   
        }
        
        public Long getRenewalExcellenceTargetQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.RenewalExcellenceTarget__c != null)
            {
                return  Math.roundToLong(scorecardQ3.RenewalExcellenceTarget__c);
            }
            else
            {
                return 0;   
            }   
        }
        
        public Long getRenewalExcellenceTargetQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.RenewalExcellenceTarget__c != null)
            {
                return  Math.roundToLong(scorecardQ4.RenewalExcellenceTarget__c);
            }
            else
            {
                return 0;   
            }       
        }
        
        public Long getRenewalExcellenceAttainmentQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.RenewalExcellenceActual__c != null && scorecardQ1.RenewalExcellenceTarget__c != null)
            {
                if (scorecardQ1.RenewalExcellenceTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ1.RenewalExcellenceActual__c / scorecardQ1.RenewalExcellenceTarget__c) * 100);
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
        
        public Long getRenewalExcellenceAttainmentQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.RenewalExcellenceActual__c != null && scorecardQ2.RenewalExcellenceTarget__c != null)
            {
                if (scorecardQ2.RenewalExcellenceTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ2.RenewalExcellenceActual__c / scorecardQ2.RenewalExcellenceTarget__c) * 100);
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
        
        public Long getRenewalExcellenceAttainmentQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.RenewalExcellenceActual__c != null && scorecardQ3.RenewalExcellenceTarget__c != null)
            {
                if (scorecardQ3.RenewalExcellenceTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ3.RenewalExcellenceActual__c / scorecardQ3.RenewalExcellenceTarget__c) * 100);
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
        
        public Long getRenewalExcellenceAttainmentQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.RenewalExcellenceActual__c != null && scorecardQ4.RenewalExcellenceTarget__c != null)
            {
                if (scorecardQ4.RenewalExcellenceTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ4.RenewalExcellenceActual__c / scorecardQ4.RenewalExcellenceTarget__c) * 100);
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
            Double ytd;
            Double Q1;
            Double Q2;
            Double Q3;
            Double Q4;
            
            if (scorecardQ1 != null && scorecardQ1.RenewalExcellenceActual__c != null)
            {
                total  = total + scorecardQ1.RenewalExcellenceActual__c;
                Q1 = scorecardQ1.RenewalExcellenceActual__c;
            }
            
            if (scorecardQ2 != null && scorecardQ2.RenewalExcellenceActual__c != null)
            {
                total = total + scorecardQ2.RenewalExcellenceActual__c;
                Q2 = scorecardQ2.RenewalExcellenceActual__c;
            }
            
            if (scorecardQ3 != null && scorecardQ3.RenewalExcellenceActual__c != null)
            {
                total = total +  scorecardQ3.RenewalExcellenceActual__c;
                Q3 = scorecardQ3.RenewalExcellenceActual__c;
            }
            
            if (scorecardQ4 != null && scorecardQ4.RenewalExcellenceActual__c != null)
            {
                total = total + scorecardQ4.RenewalExcellenceActual__c;
                Q4 = scorecardQ4.RenewalExcellenceActual__c;
            }
            
            if(performanceReview.V2MOM__r.V2MOM_Type__c == 'Individual Q1/Q2'){
            	if(Q1 == 0 && Q2 != 0){
					ytd = Q2;
				}
				else{
					if(Q1 != 0 && Q2 == 0){
						ytd = Q1;
					}
					else{
						ytd = (total / 2);
					}
				}	    
            }
            else{
            	if(Q3 == 0 && Q4 != 0){
					ytd = Q4;
				}
				else{
					if(Q3 != 0 && Q4 == 0){
						ytd = Q3;
					}
					else{
						ytd = (total / 2);
					}
				}	 
            }
           
            return Math.roundToLong(ytd);
        }
        
        
        public Long getYTDTarget()
        {
            Double total = 0;
            Double ytd;
            Double Q1;
            Double Q2;
            Double Q3;
            Double Q4;
            
            if (scorecardQ1 != null && scorecardQ1.RenewalExcellenceTarget__c != null)
            {
                total = total + scorecardQ1.RenewalExcellenceTarget__c;
                Q1 = scorecardQ1.RenewalExcellenceTarget__c;
            }
            
            if (scorecardQ2 != null && scorecardQ2.RenewalExcellenceTarget__c != null)
            {
                total = total +  scorecardQ2.RenewalExcellenceTarget__c;
                Q2 = scorecardQ2.RenewalExcellenceTarget__c;
            }
            
            if (scorecardQ3 != null && scorecardQ3.RenewalExcellenceTarget__c != null)
            {
                total = total + scorecardQ3.RenewalExcellenceTarget__c;
                Q3 = scorecardQ3.RenewalExcellenceTarget__c;
            }
            
            if (scorecardQ4 != null && scorecardQ4.RenewalExcellenceTarget__c != null)
            {
                total = total +  scorecardQ4.RenewalExcellenceTarget__c;
                Q4 = scorecardQ4.RenewalExcellenceTarget__c;
            }
                
            if(performanceReview.V2MOM__r.V2MOM_Type__c == 'Individual Q1/Q2'){
            	if(Q1 == 0 && Q2 != 0){
					ytd = Q2;
				}
				else{
					if(Q1 != 0 && Q2 == 0){
						ytd = Q1;
					}
					else{
						ytd = (total / 2);
					}
				}	    
            }
            else{
            	if(Q3 == 0 && Q4 != 0){
					ytd = Q4;
				}
				else{
					if(Q3 != 0 && Q4 == 0){
						ytd = Q3;
					}
					else{
						ytd = (total / 2);
					}
				}	 
            }
           
            return Math.roundToLong(ytd);
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
        
        public String getCommentRenewalExcellence()
        {
            if (currentUserComment != null)
            {
                return currentUserComment.CommentRenewalExcellence__c;
            }
            else
            {
                return '';
            }   
        }
        
        public String getRenewalExcellenceRating()
        {
             if (scorecardQ1 != null && scorecardQ1.RenewalExcellenceRating__c != null)
             {
                if(scorecardQ1.RenewalExcellenceRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ1.RenewalExcellenceRating__c.intValue());
             }
             
             if (scorecardQ2 != null && scorecardQ2.RenewalExcellenceRating__c != null)
             {
                if(scorecardQ2.RenewalExcellenceRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ2.RenewalExcellenceRating__c.intValue());
             }
             
             if (scorecardQ3 != null && scorecardQ3.RenewalExcellenceRating__c != null)
             {
                if(scorecardQ3.RenewalExcellenceRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ3.RenewalExcellenceRating__c.intValue());
             }
             
             if (scorecardQ4 != null && scorecardQ4.RenewalExcellenceRating__c != null)
             {
                if(scorecardQ4.RenewalExcellenceRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ4.RenewalExcellenceRating__c.intValue());
             }
             
             return '--None--';
        }
       
        public String getRatingDescription(Integer value)
        {
            return PAMUtil.getRatingLabel(value);
        }
        
        public Double getRenewalExcellenceWeight()
        {    
             if (scorecardQ1 != null && scorecardQ1.RenewalExcellenceWeight__c != null)
             {
                return  scorecardQ1.RenewalExcellenceWeight__c;
             }
             
             if (scorecardQ2 != null && scorecardQ2.RenewalExcellenceWeight__c != null)
             {
                return  scorecardQ2.RenewalExcellenceWeight__c;
             }
             
             if (scorecardQ3 != null && scorecardQ3.RenewalExcellenceWeight__c != null)
             {
                return  scorecardQ3.RenewalExcellenceWeight__c;
             }
             
             if (scorecardQ4 != null && scorecardQ4.RenewalExcellenceWeight__c != null)
             {
                return  scorecardQ4.RenewalExcellenceWeight__c;
             }
             
            return 0;
        }
        
        
        // -------------------------------- Here start getters for Operational Excellence fields
        public Double getOperationalExcellenceActualQ1()
        {
            
            if (scorecardQ1 != null && scorecardQ1.OperationalExcellenceActual__c != null)
            {
                
                return  scorecardQ1.OperationalExcellenceActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getOperationalExcellenceActualQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.OperationalExcellenceActual__c != null)
            {
            
                return  scorecardQ2.OperationalExcellenceActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getOperationalExcellenceActualQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.OperationalExcellenceActual__c != null)
            {
                
                
                return  scorecardQ3.OperationalExcellenceActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getOperationalExcellenceActualQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.OperationalExcellenceActual__c != null)
            {
                return  scorecardQ4.OperationalExcellenceActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getOperationalExcellenceTargetQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.OperationalExcellenceTarget__c != null)
            {
                return  scorecardQ1.OperationalExcellenceTarget__c;
            }
            else
            {
                return 0;   
            }   
        }
        
        public Double getOperationalExcellenceTargetQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.OperationalExcellenceTarget__c != null)
            {
                return  scorecardQ2.OperationalExcellenceTarget__c;
            }
            else
            {
                return 0;   
            }   
        }
        
        public Double getOperationalExcellenceTargetQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.OperationalExcellenceTarget__c != null)
            {
                return  scorecardQ3.OperationalExcellenceTarget__c;
            }
            else
            {
                return 0;   
            }   
        }
        
        public Double getOperationalExcellenceTargetQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.OperationalExcellenceTarget__c != null)
            {
                return  scorecardQ4.OperationalExcellenceTarget__c;
            }
            else
            {
                return 0;   
            }       
        }
        
        public Long getOperationalExcellenceAttainmentQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.OperationalExcellenceActual__c != null && scorecardQ1.OperationalExcellenceTarget__c != null)
            {
                if (scorecardQ1.OperationalExcellenceTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ1.OperationalExcellenceActual__c / scorecardQ1.OperationalExcellenceTarget__c) * 100);
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
        
        public Long getOperationalExcellenceAttainmentQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.OperationalExcellenceActual__c != null && scorecardQ2.OperationalExcellenceTarget__c != null)
            {
                if (scorecardQ2.OperationalExcellenceTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ2.OperationalExcellenceActual__c / scorecardQ2.OperationalExcellenceTarget__c) * 100);
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
        
        public Long getOperationalExcellenceAttainmentQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.OperationalExcellenceActual__c != null && scorecardQ3.OperationalExcellenceTarget__c != null)
            {
                if (scorecardQ3.OperationalExcellenceTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ3.OperationalExcellenceActual__c / scorecardQ3.OperationalExcellenceTarget__c) * 100);
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
        
        public Long getOperationalExcellenceAttainmentQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.OperationalExcellenceActual__c != null && scorecardQ4.OperationalExcellenceTarget__c != null)
            {
                if (scorecardQ4.OperationalExcellenceTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ4.OperationalExcellenceActual__c / scorecardQ4.OperationalExcellenceTarget__c) * 100);
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
        
        public String getCommentOperationalExcellence()
        {
            if (currentUserComment != null)
            {
                return currentUserComment.CommentOperationalExcellence__c;
            }
            else
            {
                return '';
            }   
        }
        
        public String getOperationalExcellenceRating()
        {
             if (scorecardQ1 != null && scorecardQ1.OperationalExcellenceRating__c != null)
             {
                if(scorecardQ1.OperationalExcellenceRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ1.OperationalExcellenceRating__c.intValue());
             }
             
             if (scorecardQ2 != null && scorecardQ2.OperationalExcellenceRating__c != null)
             {
                if(scorecardQ2.OperationalExcellenceRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ2.OperationalExcellenceRating__c.intValue());
             }
             
             if (scorecardQ3 != null && scorecardQ3.OperationalExcellenceRating__c != null)
             {
                if(scorecardQ3.OperationalExcellenceRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ3.OperationalExcellenceRating__c.intValue());
             }
             
             if (scorecardQ4 != null && scorecardQ4.OperationalExcellenceRating__c != null)
             {
                if(scorecardQ4.OperationalExcellenceRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ4.OperationalExcellenceRating__c.intValue());
             }
             
             return '--None--';
        }
        
         public Double getOperationalExcellenceWeight()
        {    
             if (scorecardQ1 != null && scorecardQ1.OperationalExcellenceWeight__c != null)
             {
                return  scorecardQ1.OperationalExcellenceWeight__c;
             }
             
             if (scorecardQ2 != null && scorecardQ2.OperationalExcellenceWeight__c != null)
             {
                return  scorecardQ2.OperationalExcellenceWeight__c;
             }
             
             if (scorecardQ3 != null && scorecardQ3.OperationalExcellenceWeight__c != null)
             {
                return  scorecardQ3.OperationalExcellenceWeight__c;
             }
             
             if (scorecardQ4 != null && scorecardQ4.OperationalExcellenceWeight__c != null)
             {
                return  scorecardQ4.OperationalExcellenceWeight__c;
             }
             
            return 0;
        }
        // ---------- Here start getters for Strategic Initiatives fields
        
        public String getCommentStrategicInitiatives()
        {
            if (currentUserComment != null)
            {
                return currentUserComment.CommentStrategicInitiatives__c;
            }
            else
            {
                return '';
            }   
        }
        
        public String getStrategicInitiativesRating()
        {
             if (scorecardQ1 != null && scorecardQ1.StrategicInitiativesRating__c != null)
             {
                if(scorecardQ1.StrategicInitiativesRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ1.StrategicInitiativesRating__c.intValue());
             }
             
             if (scorecardQ2 != null && scorecardQ2.StrategicInitiativesRating__c != null)
             {
                if(scorecardQ2.StrategicInitiativesRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ2.StrategicInitiativesRating__c.intValue());
             }
             
             if (scorecardQ3 != null && scorecardQ3.StrategicInitiativesRating__c != null)
             {
                if(scorecardQ3.StrategicInitiativesRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ3.StrategicInitiativesRating__c.intValue());
             }
             
             if (scorecardQ4 != null && scorecardQ4.StrategicInitiativesRating__c != null)
             {
                if(scorecardQ4.StrategicInitiativesRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ4.StrategicInitiativesRating__c.intValue());
             }
             
             return '--None--';
        }
        
         public Double getStrategicInitiativesWeight()
        {    
             if (scorecardQ1 != null && scorecardQ1.StrategicInitiativesWeight__c != null)
             {
                return  scorecardQ1.StrategicInitiativesWeight__c;
             }
             
             if (scorecardQ2 != null && scorecardQ2.StrategicInitiativesWeight__c != null)
             {
                return  scorecardQ2.StrategicInitiativesWeight__c;
             }
             
             if (scorecardQ3 != null && scorecardQ3.StrategicInitiativesWeight__c != null)
             {
                return  scorecardQ3.StrategicInitiativesWeight__c;
             }
             
             if (scorecardQ4 != null && scorecardQ4.StrategicInitiativesWeight__c != null)
             {
                return  scorecardQ4.StrategicInitiativesWeight__c;
             }
             
            return 0;
        }
        // --------------------------- Here start getters for CSM Sales Impact fields
      	
      	
      	public Double getACVGrowthActualQ1()
        {
            
            if (scorecardQ1 != null && scorecardQ1.ACVGrowthActual__c != null)
            {
                
                return  scorecardQ1.ACVGrowthActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getACVGrowthActualQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.ACVGrowthActual__c != null)
            {
            
                return  scorecardQ2.ACVGrowthActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getACVGrowthActualQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.ACVGrowthActual__c != null)
            {
                
                
                return  scorecardQ3.ACVGrowthActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getACVGrowthActualQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.ACVGrowthActual__c != null)
            {
                return  scorecardQ4.ACVGrowthActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getACVGrowthTargetQ1()
        {
            
            if (scorecardQ1 != null && scorecardQ1.ACVGrowthTarget__c != null)
            {
                
                return  scorecardQ1.ACVGrowthTarget__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getACVGrowthTargetQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.ACVGrowthTarget__c != null)
            {
            
                return scorecardQ2.ACVGrowthTarget__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getACVGrowthTargetQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.ACVGrowthTarget__c != null)
            {
                
                
                return scorecardQ3.ACVGrowthTarget__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getACVGrowthTargetQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.ACVGrowthTarget__c != null)
            {
                return scorecardQ4.ACVGrowthTarget__c;
            }
            else
            {
                return 0;   
            } 
        }
        
         public Double getYTDACVGrowthActual()
        {
            Double total = 0;
            Double ytd = 0;
            Double Q1;
            Double Q2;
            Double Q3;
            Double Q4;
            
            if (scorecardQ1 != null && scorecardQ1.ACVGrowthActual__c != null)
            {
                total  = total + scorecardQ1.ACVGrowthActual__c;
                Q1 = scorecardQ1.ACVGrowthActual__c;
            }
            
            if (scorecardQ2 != null && scorecardQ2.ACVGrowthActual__c != null)
            {
                total = total + scorecardQ2.ACVGrowthActual__c;
                Q2 = scorecardQ2.ACVGrowthActual__c;
            }
            
            if (scorecardQ3 != null && scorecardQ3.ACVGrowthActual__c != null)
            {
                total = total +  scorecardQ3.ACVGrowthActual__c;
                Q3 = scorecardQ3.ACVGrowthActual__c;
            }
            
            if (scorecardQ4 != null && scorecardQ4.ACVGrowthActual__c != null)
            {
                total = total + scorecardQ4.ACVGrowthActual__c;
                Q4 = scorecardQ4.ACVGrowthActual__c;
            }
                
            if(performanceReview.V2MOM__r.V2MOM_Type__c == 'Individual Q1/Q2'){
            	if((Q1 == 0 || Q1 == null) && Q2 != 0){
            		System.debug('Enter HEREE');
					ytd = Q2;
				}
				else{
					if(Q1 != 0 && (Q2 == 0 || Q2 == null)){
						ytd = Q1;
					}
					else{
						ytd = (total / 2);
					}
				}	    
            }
            else{
            	if((Q3 == 0 || Q3 ==  null) && Q4 != 0){
					ytd = Q4;
				}
				else{
					if(Q3 != 0 && (Q4 == 0 || Q4 == null)) {
						ytd = Q3;
					}
					else{
						ytd = (total / 2);
					}
				}	 
            }
           if(ytd == null){
           	ytd = 0;
           }
           return ytd;
        }
        
        public Double getYTDACVGrowthTarget()
        {
            Double total = 0;
            Double ytd = 0;
            Double Q1;
            Double Q2;
            Double Q3;
            Double Q4;
            
            if (scorecardQ1 != null && scorecardQ1.ACVGrowthTarget__c != null)
            {
                total  = total + scorecardQ1.ACVGrowthTarget__c;
                Q1 = scorecardQ1.ACVGrowthTarget__c;
            }
            
            if (scorecardQ2 != null && scorecardQ2.ACVGrowthTarget__c != null)
            {
                total = total + scorecardQ2.ACVGrowthTarget__c;
                Q2 = scorecardQ2.ACVGrowthTarget__c;
            }
            
            if (scorecardQ3 != null && scorecardQ3.ACVGrowthTarget__c != null)
            {
                total = total +  scorecardQ3.ACVGrowthTarget__c;
                Q3 = scorecardQ3.ACVGrowthTarget__c;
            }
            
            if (scorecardQ4 != null && scorecardQ4.ACVGrowthTarget__c != null)
            {
                total = total + scorecardQ4.ACVGrowthTarget__c;
                Q4 = scorecardQ4.ACVGrowthTarget__c;
            }
                
            if(performanceReview.V2MOM__r.V2MOM_Type__c == 'Individual Q1/Q2'){
            	if((Q1 == 0 || Q1 == null) && Q2 != 0){
					ytd = Q2;
				}
				else{
					if(Q1 != 0 && (Q2 == 0 || Q2 == null)){
						ytd = Q1;
					}
					else{
						ytd = (total / 2);
					}
				}	    
            }
            else{
            	if((Q3 == 0 || Q3 == null) && Q4 != 0){
					ytd = Q4;
				}
				else{
					if(Q3 != 0 && (Q4 == 0 || Q4 == null)){
						ytd = Q3;
					}
					else{
						ytd = (total / 2);
					}
				}	 
            }
           if(ytd == null){
       			ytd = 0;
           }
            return ytd;
        }
        
         public Long getACVGrowthAttainmentQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.ACVGrowthActual__c != null && scorecardQ1.ACVGrowthTarget__c != null)
            {
                if (scorecardQ1.ACVGrowthTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ1.ACVGrowthActual__c / scorecardQ1.ACVGrowthTarget__c) * 100);
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
        
        public Long getACVGrowthAttainmentQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.ACVGrowthActual__c != null && scorecardQ2.ACVGrowthTarget__c != null)
            {
                if (scorecardQ2.ACVGrowthTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ2.ACVGrowthActual__c / scorecardQ2.ACVGrowthTarget__c) * 100);
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
        
        public Long getACVGrowthAttainmentQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.ACVGrowthActual__c != null && scorecardQ3.ACVGrowthTarget__c != null)
            {
                if (scorecardQ3.ACVGrowthTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ3.ACVGrowthActual__c / scorecardQ3.ACVGrowthTarget__c) * 100);
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
        
        public Long getACVGrowthAttainmentQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.ACVGrowthActual__c != null && scorecardQ4.ACVGrowthTarget__c != null)
            {
                if (scorecardQ4.ACVGrowthTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ4.ACVGrowthActual__c / scorecardQ4.ACVGrowthTarget__c) * 100);
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
        
        public Long getYTDACVGrowthAttainment()
        {
            Double target = 0;
            Double actual = 0;
            Double result = 0;
            
            target = getYTDACVGrowthTarget();
            actual = getYTDACVGrowthActual();
            
            if (target != 0)
            {
                if (actual != null && target != null)
                {
                	  result = (actual / target) * 100;
                	  return Math.roundToLong(result);     
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
        
        
        public Double getPipelineContributionActualQ1()
        {
            
            if (scorecardQ1 != null && scorecardQ1.PipelineContributionActual__c != null)
            {
                
                return  scorecardQ1.PipelineContributionActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getPipelineContributionActualQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.PipelineContributionActual__c != null)
            {
            
                return  scorecardQ2.PipelineContributionActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getPipelineContributionActualQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.PipelineContributionActual__c != null)
            {
                
                
                return  scorecardQ3.PipelineContributionActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getPipelineContributionActualQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.PipelineContributionActual__c != null)
            {
                return  scorecardQ4.PipelineContributionActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getPipelineContributionTargetQ1()
        {
            
            if (scorecardQ1 != null && scorecardQ1.PipelineContributionTarget__c != null)
            {
                
                return  scorecardQ1.PipelineContributionTarget__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getPipelineContributionTargetQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.PipelineContributionTarget__c != null)
            {
            
                return scorecardQ2.PipelineContributionTarget__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getPipelineContributionTargetQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.PipelineContributionTarget__c != null)
            {
                
                
                return  scorecardQ3.PipelineContributionTarget__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getPipelineContributionTargetQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.PipelineContributionTarget__c != null)
            {
                return scorecardQ4.PipelineContributionTarget__c;
            }
            else
            {
                return 0;   
            } 
        }
          
        public Double getYTDPipelineContributionActual()
        {
            Double total = 0;
            Double ytd;
            Double Q1;
            Double Q2;
            Double Q3;
            Double Q4;
            
            if (scorecardQ1 != null && scorecardQ1.PipelineContributionActual__c != null)
            {
                total  = total + scorecardQ1.PipelineContributionActual__c;
                Q1 = scorecardQ1.PipelineContributionActual__c;
            }
            
            if (scorecardQ2 != null && scorecardQ2.PipelineContributionActual__c != null)
            {
                total = total + scorecardQ2.PipelineContributionActual__c;
                Q2 = scorecardQ2.PipelineContributionActual__c;
            }
            
            if (scorecardQ3 != null && scorecardQ3.PipelineContributionActual__c != null)
            {
                total = total +  scorecardQ3.PipelineContributionActual__c;
                Q3 = scorecardQ3.PipelineContributionActual__c;
            }
            
            if (scorecardQ4 != null && scorecardQ4.PipelineContributionActual__c != null)
            {
                total = total + scorecardQ4.PipelineContributionActual__c;
                Q4 = scorecardQ4.PipelineContributionActual__c;
            }
                
            if(performanceReview.V2MOM__r.V2MOM_Type__c == 'Individual Q1/Q2'){
            	if((Q1 == 0 || Q1 == null) && Q2 != 0){
					ytd = Q2;
				}
				else{
					if(Q1 != 0 && (Q2 == 0 || Q2 == null)) {
						ytd = Q1;
					}
					else{
						ytd = (total / 2);
					}
				}	    
            }
            else{
            	if((Q3 == 0 || Q3 == null) && Q4 != 0){
					ytd = Q4;
				}
				else{
					if(Q3 != 0 && (Q4 == 0 || Q4 == null)){
						ytd = Q3;
					}
					else{
						ytd = (total / 2);
					}
				}	 
            }
           
            return ytd;
        }
        
        public Double getYTDPipelineContributionTarget()
        {
            Double total = 0;
            Double ytd;
            Double Q1;
            Double Q2;
            Double Q3;
            Double Q4;
            
            if (scorecardQ1 != null && scorecardQ1.PipelineContributionTarget__c != null)
            {
                total  = total + scorecardQ1.PipelineContributionTarget__c;
                Q1 = scorecardQ1.PipelineContributionTarget__c;
            }
            
            if (scorecardQ2 != null && scorecardQ2.PipelineContributionTarget__c != null)
            {
                total = total + scorecardQ2.PipelineContributionTarget__c;
                Q2 = scorecardQ2.PipelineContributionTarget__c;
            }
            
            if (scorecardQ3 != null && scorecardQ3.PipelineContributionTarget__c != null)
            {
                total = total +  scorecardQ3.PipelineContributionTarget__c;
                Q3 = scorecardQ3.PipelineContributionTarget__c;
            }
            
            if (scorecardQ4 != null && scorecardQ4.PipelineContributionTarget__c != null)
            {
                total = total + scorecardQ4.PipelineContributionTarget__c;
                Q4 = scorecardQ4.PipelineContributionTarget__c;
            }
                
            if(performanceReview.V2MOM__r.V2MOM_Type__c == 'Individual Q1/Q2'){
            	if((Q1 == 0 || Q1 == null) && Q2 != 0){
					ytd = Q2;
				}
				else{
					if(Q1 != 0 && (Q2 == 0 || Q2 == null)){
						ytd = Q1;
					}
					else{
						ytd = (total / 2);
					}
				}	    
            }
            else{
            	if((Q3 == 0 || Q3 == null) && Q4 != 0){
					ytd = Q4;
				}
				else{
					if(Q3 != 0 && (Q4 == 0 || Q4 == null)){
						ytd = Q3;
					}
					else{
						ytd = (total / 2);
					}
				}	 
            }
           
            return ytd;
        }
        
        public Long getPipelineContributionAttainmentQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.PipelineContributionActual__c != null && scorecardQ1.PipelineContributionTarget__c != null)
            {
                if (scorecardQ1.PipelineContributionTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ1.PipelineContributionActual__c / scorecardQ1.PipelineContributionTarget__c) * 100);
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
        
        public Long getPipelineContributionAttainmentQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.ACVGrowthActual__c != null && scorecardQ2.PipelineContributionTarget__c != null)
            {
                if (scorecardQ2.PipelineContributionTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ2.PipelineContributionActual__c / scorecardQ2.PipelineContributionTarget__c) * 100);
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
        
        public Long getPipelineContributionAttainmentQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.PipelineContributionActual__c != null && scorecardQ3.PipelineContributionTarget__c != null)
            {
                if (scorecardQ3.PipelineContributionTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ3.PipelineContributionActual__c / scorecardQ3.PipelineContributionTarget__c) * 100);
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
        
        public Long getPipelineContributionAttainmentQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.PipelineContributionActual__c != null && scorecardQ4.PipelineContributionTarget__c != null)
            {
                if (scorecardQ4.PipelineContributionTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ4.PipelineContributionActual__c / scorecardQ4.PipelineContributionTarget__c) * 100);
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
        
        public Long getYTDPipelineContributionAttainment()
        {
            Double target = 0;
            Double actual = 0;
            Double result = 0;
            
            target = getYTDPipelineContributionTarget();
            actual = getYTDPipelineContributionActual();
            
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
        
        public Double getCSMSIPipeLineContributionActual()
        {
            if (scorecardQ1 != null && scorecardQ1.SIPipeLineContributionActual__c != null)
            {
                return  scorecardQ1.SIPipeLineContributionActual__c;
            }
            if (scorecardQ2 != null && scorecardQ2.SIPipeLineContributionActual__c != null)
            {
                return  scorecardQ2.SIPipeLineContributionActual__c;
            }
            if (scorecardQ3 != null && scorecardQ3.SIPipeLineContributionActual__c != null)
            {
                return  scorecardQ3.SIPipeLineContributionActual__c;
            }
            if (scorecardQ4 != null && scorecardQ4.SIPipeLineContributionActual__c != null)
            {
                return  scorecardQ4.SIPipeLineContributionActual__c;
            }
            
            return 0;
        }
        
        
         public Double getCSMSIPipeLineContributionTraningActual()
        {
            if (scorecardQ1 != null && scorecardQ1.SIPipeLineContributionTraningActual__c != null)
            {
                return  scorecardQ1.SIPipeLineContributionTraningActual__c;
            }
            if (scorecardQ2 != null && scorecardQ2.SIPipeLineContributionTraningActual__c != null)
            {
                return  scorecardQ2.SIPipeLineContributionTraningActual__c;
            }
            if (scorecardQ3 != null && scorecardQ3.SIPipeLineContributionTraningActual__c != null)
            {
                return  Math.roundToLong(scorecardQ3.SIPipeLineContributionTraningActual__c);
            }
            if (scorecardQ4 != null && scorecardQ4.SIPipeLineContributionTraningActual__c != null)
            {
                return  scorecardQ4.SIPipeLineContributionTraningActual__c;
            }
            
            return 0;
        }
        
        public Double getCSMSIPipeLineContributionConsultingActual()
        {
            if (scorecardQ1 != null && scorecardQ1.SIPipeLineContributionConsultingActual__c != null)
            {
                return  scorecardQ1.SIPipeLineContributionConsultingActual__c;
            }
            if (scorecardQ2 != null && scorecardQ2.SIPipeLineContributionConsultingActual__c != null)
            {
                return  scorecardQ2.SIPipeLineContributionConsultingActual__c;
            }
            if (scorecardQ3 != null && scorecardQ3.SIPipeLineContributionConsultingActual__c != null)
            {
                return  scorecardQ3.SIPipeLineContributionConsultingActual__c;
            }
            if (scorecardQ4 != null && scorecardQ4.SIPipeLineContributionConsultingActual__c != null)
            {
                return  scorecardQ4.SIPipeLineContributionConsultingActual__c;
            }
            
            return 0;
        }
        
        public Double getCSMSICSEAmountActual()
        {
            if (scorecardQ1 != null && scorecardQ1.CSEAmountActual__c != null)
            {
                return scorecardQ1.CSEAmountActual__c;
            }
            if (scorecardQ2 != null && scorecardQ2.CSEAmountActual__c != null)
            {
                return scorecardQ2.CSEAmountActual__c;
            }
            if (scorecardQ3 != null && scorecardQ3.CSEAmountActual__c != null)
            {
                return  scorecardQ3.CSEAmountActual__c;
            }
            if (scorecardQ4 != null && scorecardQ4.CSEAmountActual__c != null)
            {
                return  scorecardQ4.CSEAmountActual__c;
            }
            
            return 0;
        }
        
        
        
        public Long getExecutiveRelationshipsActualQ1()
        {
            
            if (scorecardQ1 != null && scorecardQ1.ExecutiveRelationshipsActual__c != null)
            {
                
                return  Math.roundToLong(scorecardQ1.ExecutiveRelationshipsActual__c);
            }
            else
            {
                return 0;   
            } 
        }
        
        public Long getExecutiveRelationshipsActualQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.ExecutiveRelationshipsActual__c != null)
            {
            
                return  Math.roundToLong(scorecardQ2.ExecutiveRelationshipsActual__c);
            }
            else
            {
                return 0;   
            } 
        }
        
        public Long getExecutiveRelationshipsActualQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.ExecutiveRelationshipsActual__c != null)
            {
                
                
                return  Math.roundToLong(scorecardQ3.ExecutiveRelationshipsActual__c);
            }
            else
            {
                return 0;   
            } 
        }
        
        public Long getExecutiveRelationshipsActualQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.ExecutiveRelationshipsActual__c != null)
            {
                return  Math.roundToLong(scorecardQ4.ExecutiveRelationshipsActual__c);
            }
            else
            {
                return 0;   
            } 
        }
        
        public Long getExecutiveRelationshipsTargetQ1()
        {
            
            if (scorecardQ1 != null && scorecardQ1.ExecutiveRelationshipsTarget__c != null)
            {
                
                return  Math.roundToLong(scorecardQ1.ExecutiveRelationshipsTarget__c);
            }
            else
            {
                return 0;   
            } 
        }
        
        public Long getExecutiveRelationshipsTargetQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.ExecutiveRelationshipsTarget__c != null)
            {
            
                return Math.roundToLong(scorecardQ2.ExecutiveRelationshipsTarget__c);
            }
            else
            {
                return 0;   
            } 
        }
        
        public Long getExecutiveRelationshipsTargetQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.ExecutiveRelationshipsTarget__c != null)
            {
                
                
                return  Math.roundToLong(scorecardQ3.ExecutiveRelationshipsTarget__c);
            }
            else
            {
                return 0;   
            } 
        }
        
        public Long getExecutiveRelationshipsTargetQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.ExecutiveRelationshipsTarget__c != null)
            {
                return Math.roundToLong(scorecardQ4.ExecutiveRelationshipsTarget__c);
            }
            else
            {
                return 0;   
            } 
        }
        
        public Long getExecutiveRelationshipsAttainmentQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.ExecutiveRelationshipsActual__c != null && scorecardQ1.ExecutiveRelationshipsTarget__c != null)
            {
                if (scorecardQ1.ExecutiveRelationshipsTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ1.ExecutiveRelationshipsActual__c / scorecardQ1.ExecutiveRelationshipsTarget__c) * 100);
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
        
        public Long getExecutiveRelationshipsAttainmentQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.ExecutiveRelationshipsActual__c != null && scorecardQ2.ExecutiveRelationshipsTarget__c != null)
            {
                if (scorecardQ2.ExecutiveRelationshipsTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ2.ExecutiveRelationshipsActual__c / scorecardQ2.ExecutiveRelationshipsTarget__c) * 100);
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
        
        public Long getExecutiveRelationshipsAttainmentQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.ExecutiveRelationshipsActual__c != null && scorecardQ3.ExecutiveRelationshipsTarget__c != null)
            {
                if (scorecardQ3.ExecutiveRelationshipsTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ3.ExecutiveRelationshipsActual__c / scorecardQ3.ExecutiveRelationshipsTarget__c) * 100);
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
        
        public Long getExecutiveRelationshipsAttainmentQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.ExecutiveRelationshipsActual__c != null && scorecardQ4.PipelineContributionTarget__c != null)
            {
                if (scorecardQ4.ExecutiveRelationshipsTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ4.ExecutiveRelationshipsActual__c / scorecardQ4.ExecutiveRelationshipsTarget__c) * 100);
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
        
         public String getCSMSalesImpactRating()
        {
             if (scorecardQ1 != null && scorecardQ1.CSMSalesImpactRating__c != null)
             {
              
                if(scorecardQ1.CSMSalesImpactRating__c == -1){
                	
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ1.CSMSalesImpactRating__c.intValue());
             }
             
             if (scorecardQ2 != null && scorecardQ2.CSMSalesImpactRating__c != null)
             {
                
                if(scorecardQ2.CSMSalesImpactRating__c == -1){
                	
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ2.CSMSalesImpactRating__c.intValue());
             }
             
             if (scorecardQ3 != null && scorecardQ3.CSMSalesImpactRating__c != null)
             {
                if(scorecardQ3.CSMSalesImpactRating__c == -1){ 
                	return 'N/A'; 
                }
                return  getRatingDescription(scorecardQ3.CSMSalesImpactRating__c.intValue());
             }    
              
             if (scorecardQ4 != null && scorecardQ4.CSMSalesImpactRating__c != null)
             {
                if(scorecardQ4.CSMSalesImpactRating__c == -1){
                	 
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ4.CSMSalesImpactRating__c.intValue());
             }
             
             return '--None--'; 
        }
        
        public Double getCSMSalesImpactWeight()
        {    
             if (scorecardQ1 != null && scorecardQ1.CSMSalesImpactWeight__c != null)
             {
                return  scorecardQ1.CSMSalesImpactWeight__c;
             }
             
             if (scorecardQ2 != null && scorecardQ2.CSMSalesImpactWeight__c != null)
             {
                return  scorecardQ2.CSMSalesImpactWeight__c;
             }
             
             if (scorecardQ3 != null && scorecardQ3.CSMSalesImpactWeight__c != null)
             {
                return  scorecardQ3.CSMSalesImpactWeight__c;
             }
             
             if (scorecardQ4 != null && scorecardQ4.CSMSalesImpactWeight__c != null)
             {
                return  scorecardQ4.CSMSalesImpactWeight__c;
             }
             
            return 0;
        }
        
        public String getCommentCSMSalesImpact()
        {
            if (currentUserComment != null)
            {
                return currentUserComment.CommentCSMSalesImpact__c;
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
                            s.CommentRenewalExcellence__c,
                            s.CommentOperationalExcellence__c,
                            s.CommentStrategicInitiatives__c,                           
                            s.CommentCSMSalesImpact__c,
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