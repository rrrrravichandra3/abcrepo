/*
 * RelEng Perforce/RCS Header - Do not remove!
 *
 * $Author: $Fabritzio Calvetti 
 * $Change:  $
 * $DateTime:  $
 * $File:  $
 * $Id:  $
 * $Revision:  $
 */

/*
 * this class will take an account and assign it to a user.
*/

public with sharing class ScorecardSupportReviewWM {
	 
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
    public boolean hasCommentWMCCP;
    public boolean hasCommentWMCAA;
    String currentUserProfile;
    String currentUserId;
    public String userId = UserInfo.getUserId();
    User scorecardTypeProfile;
    PerformanceAccessUtil accessUtil;
    User currentUser;

    public ScorecardSupportReviewWM()
    {
        constructor();
    }

    public ScorecardSupportReviewWM (Id i)
    {
        currentUserId = i;
        userId = i;
        constructor();
    }
    
    public void constructor()
    {
        // checks the user and the profile
        
        currentUser = [Select Id, EmployeeNumber, Division, Profile.Name FROM  User WHERE id =: userId];
        String employeeNumber = currentUser.EmployeeNumber;
        currentUserProfile = currentUser.Profile.Name;
        currentUserId = userId;
        
        // gets the performance review
        
        String performanceId = System.currentPageReference().getParameters().get('id');
        //Set id for Test Case
        if (performanceId == null){
        	performanceId = [SELECT Id FROM PerformanceReview__c][0].Id;
        }
        performanceR = [SELECT Id, Manager__c, ThirdPartyReviewer__c, PCOMM__c,Employee__r.Division, Name, SecondManager__c, Employee__c, Status__c, PreviousStatus__c, V2MOM__r.V2MOM_Type__c, PremierUser__c  
                        FROM PerformanceReview__c 
                        WHERE Id =: performanceId];

        // gets the profile of the employee to see what kind of scorecard it might have
        scorecardTypeProfile = [Select u.Profile.Name, u.ProfileId From User u where id = :performanceR.Employee__c];   
            
        // access class for permissions
        accessUtil = new PerformanceAccessUtil(performanceR, currentUser, scorecardTypeProfile);

        // uses the information of the performance review to check if the profile of the
        // current user should see data filtered by sharing rules or filtered manually
        isPCOMMLikeViewProfile = accessUtil.getPCOMMLikeViewProfile();

        // gets the scorecards of the performance review
        List <ScorecardSupportReview__c> lists =  [Select FiscalQuarter__c , 
                                                          WMCCPActual__c, 
                                                          WMCCPTarget__c, 
                                                          WMCCPRating__c, 
                                                          WMCCPWeight__c,
                                                          WMCAAActual__c, 
                                                          WMCAATarget__c, 
                                                          WMCAARating__c, 
                                                          WMCAAWeight__c,
                                                          WMSOActual__c, 
                                                          WMSOTarget__c,
                                                          WMBAActual__c, 
                                                          WMBATarget__c
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
            
            scorecardReview = new ScoreCardReviewSupport(scorecardSupportReviews, performanceR, currentUserComment);
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
    
    public ScorecardSupportComment__c getCurrentUserComment() {
        return currentUserComment;
    }
	
	public boolean getIsPremierUser(){
    	return performanceR.PremierUser__c;
    }
    
    public boolean getHaveEMEADivision(){
    	if(performanceR.Employee__r.Division == 'EMEA'){
    		return true;
    	}
    	return false;
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
                                        s.CommentWMCCP__c,
                                        s.CommentWMCAA__c,
                                        s.CreatedDate,
                                        s.Locked__c 
                                        from ScorecardSupportComment__c s 
                                        where  PerformanceReview__c  =: p.Id
                                        order by CreatedDate ASC];
                            }else{
                                // status 2nd level mngr assmnt retrieve all except the 2nd Manager comments
                                return [select  s.Reviewer__r.Name, 
                                        s.Reviewer__c, 
                                        s.CommentWMCCP__c, 
                                        s.CommentWMCAA__c,                                    
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
                                        	s.CommentWMCCP__c,
                                        	s.CommentWMCAA__c,                                     
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
       
    public List<HistoryComments> getHistoryCommentWMCCP()
    {
        List<HistoryComments> commentList = new List<HistoryComments>();

        for (ScorecardSupportComment__c sr:historyMethods)
        {
            if (sr.CommentWMCCP__c != null && sr.CommentWMCCP__c != '')
            {   
                if(accessUtil.showRatingAndWeightIn3rdPartyAssmnt() && sr.Locked__c == true){
	                HistoryComments hc = new HistoryComments(sr); 
	                commentList.add(hc);   
            	}     
            }   
        } 

        if (commentList.size() > 0)
        {
            hasCommentWMCCP = true;
        }
        else
        {
            hasCommentWMCCP = false;
        }

        return commentList;
    }
  
    public Boolean getHasCommentWMCCP(){
        return hasCommentWMCCP;
    }  
    
    public List<HistoryComments> getHistoryCommentWMCAA()
    {
        List<HistoryComments> commentList = new List<HistoryComments>();

        for (ScorecardSupportComment__c sr:historyMethods)
        {
            if (sr.CommentWMCAA__c != null && sr.CommentWMCAA__c != '')
            {   
                if(accessUtil.showRatingAndWeightIn3rdPartyAssmnt() && sr.Locked__c == true){
	                HistoryComments hc = new HistoryComments(sr); 
	                commentList.add(hc);   
            	}     
            }   
        } 

        if (commentList.size() > 0)
        {
            hasCommentWMCAA = true;
        }
        else
        {
            hasCommentWMCAA = false;
        }

        return commentList;
    }
  
    public Boolean getHasCommentWMCAA(){
        return hasCommentWMCAA;
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
                s.WMCCPRating__c = null;
                s.WMCCPWeight__c = null;
                s.WMCCPActual__c = null;
                s.WMCCPTarget__c = null;
                s.WMCAAActual__c = null;
                s.WMCAATarget__c = null;
                s.WMSOActual__c = null;
                s.WMSOTarget__c = null;
                s.WMBAActual__c = null;
                s.WMBATarget__c = null;
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
        
        
// -------------------------------- Here start getters for workload management: "Case Closure/Productivity"
        public Double getWMCCPActualQ1()
        {
            System.debug('Q1111    ' + scorecardQ1);
            System.debug('Q1111    ' + scorecardQ1.WMCCPActual__c);
            if (scorecardQ1 != null && scorecardQ1.WMCCPActual__c != null)
            {
                
                return  scorecardQ1.WMCCPActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getWMCCPActualQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.WMCCPActual__c != null)
            {
            
                return  scorecardQ2.WMCCPActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getWMCCPActualQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.WMCCPActual__c != null)
            {
                
                
                return  scorecardQ3.WMCCPActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getWMCCPActualQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.WMCCPActual__c != null)
            {
                return  scorecardQ4.WMCCPActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getWMCCPTargetQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.WMCCPTarget__c != null)
            {
                return  scorecardQ1.WMCCPTarget__c;
            }
            else
            {
                return 0;   
            }   
        }
        
        public Double getWMCCPTargetQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.WMCCPTarget__c != null)
            {
                return  scorecardQ2.WMCCPTarget__c;
            }
            else
            {
                return 0;   
            }   
        }
        
        public Double getWMCCPTargetQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.WMCCPTarget__c != null)
            {
                return  scorecardQ3.WMCCPTarget__c;
            }
            else
            {
                return 0;   
            }   
        }
        
        public Double getWMCCPTargetQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.WMCCPTarget__c != null)
            {
                return  scorecardQ4.WMCCPTarget__c;
            }
            else
            {
                return 0;   
            }       
        }
        
        public Long getWMCCPAttainmentQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.WMCCPActual__c != null && scorecardQ1.WMCCPTarget__c != null)
            {
                if (scorecardQ1.WMCCPTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ1.WMCCPActual__c / scorecardQ1.WMCCPTarget__c) * 100);
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
        
        public Long getWMCCPAttainmentQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.WMCCPActual__c != null && scorecardQ2.WMCCPTarget__c != null)
            {
                if (scorecardQ2.WMCCPTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ2.WMCCPActual__c / scorecardQ2.WMCCPTarget__c) * 100);
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
        
        public Long getWMCCPAttainmentQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.WMCCPActual__c != null && scorecardQ3.WMCCPTarget__c != null)
            {
                if (scorecardQ3.WMCCPTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ3.WMCCPActual__c / scorecardQ3.WMCCPTarget__c) * 100);
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
        
        public Long getWMCCPAttainmentQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.WMCCPActual__c != null && scorecardQ4.WMCCPTarget__c != null)
            {
                if (scorecardQ4.WMCCPTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ4.WMCCPActual__c / scorecardQ4.WMCCPTarget__c) * 100);
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
        
        public Decimal getWMCCPYTDActual()
        {
            Decimal total = 0;
            
            if (scorecardQ1 != null && scorecardQ1.WMCCPActual__c != null)
            {
                total  = total + scorecardQ1.WMCCPActual__c;
            }
            
            if (scorecardQ2 != null && scorecardQ2.WMCCPActual__c != null)
            {
                total = total + scorecardQ2.WMCCPActual__c;
            }
            
            if (scorecardQ3 != null && scorecardQ3.WMCCPActual__c != null)
            {
                total = total +  scorecardQ3.WMCCPActual__c;
            }
            
            if (scorecardQ4 != null && scorecardQ4.WMCCPActual__c != null)
            {
                total = total + scorecardQ4.WMCCPActual__c;
            }
            
            total = total.divide(1,4,System.RoundingMode.HALF_DOWN);     
            return total;
        }
        
        public Decimal getWMCCPYTDTarget()
        {
            Decimal total = 0;
            
            if (scorecardQ1 != null && scorecardQ1.WMCCPTarget__c != null)
            {
                total = total + scorecardQ1.WMCCPTarget__c;
            }
            
            if (scorecardQ2 != null && scorecardQ2.WMCCPTarget__c != null)
            {
                total = total +  scorecardQ2.WMCCPTarget__c;
            }
            
            if (scorecardQ3 != null && scorecardQ3.WMCCPTarget__c != null)
            {
                total = total + scorecardQ3.WMCCPTarget__c;
            }
            
            if (scorecardQ4 != null && scorecardQ4.WMCCPTarget__c != null)
            {
                total = total +  scorecardQ4.WMCCPTarget__c;
            }
            
            total = total.divide(1,4,System.RoundingMode.HALF_DOWN);  
            return total;
        }
        
        public Long getWMCCPYTDAttainment()
        {
            Double target = 0;
            Double actual = 0;
            Double result = 0;
            
            target = getWMCCPYTDTarget();
            actual = getWMCCPYTDActual();
            
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
        
        public String getCommentWMCCP()
        {
            if (currentUserComment != null)
            {
                return currentUserComment.CommentWMCCP__c;
            }
            else
            {
                return '';
            }   
        }
        
        public String getWMCCPRating()
        {
             if (scorecardQ1 != null && scorecardQ1.WMCCPRating__c != null)
             {
                if(scorecardQ1.WMCCPRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ1.WMCCPRating__c.intValue());
             }
             
             if (scorecardQ2 != null && scorecardQ2.WMCCPRating__c != null)
             {
                if(scorecardQ2.WMCCPRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ2.WMCCPRating__c.intValue());
             }
             
             if (scorecardQ3 != null && scorecardQ3.WMCCPRating__c != null)
             {
                if(scorecardQ3.WMCCPRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ3.WMCCPRating__c.intValue());
             }
             
             if (scorecardQ4 != null && scorecardQ4.WMCCPRating__c != null)
             {
                if(scorecardQ4.WMCCPRating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ4.WMCCPRating__c.intValue());
             }
             
             return '--None--';
        }
       
        public String getRatingDescription(Integer value)
        {
            return PAMUtil.getRatingLabel(value);
        }
        
        public Double getWMCCPWeight()
        {    
             if (scorecardQ1 != null && scorecardQ1.WMCCPWeight__c != null)
             {
                return  scorecardQ1.WMCCPWeight__c;
             }
             
             if (scorecardQ2 != null && scorecardQ2.WMCCPWeight__c != null)
             {
                return  scorecardQ2.WMCCPWeight__c;
             }
             
             if (scorecardQ3 != null && scorecardQ3.WMCCPWeight__c != null)
             {
                return  scorecardQ3.WMCCPWeight__c;
             }
             
             if (scorecardQ4 != null && scorecardQ4.WMCCPWeight__c != null)
             {
                return  scorecardQ4.WMCCPWeight__c;
             }
             
            return 0;
        }
        
        //------ END of Case Closure/Productivity TABLE
        
        
        
        
 // -------------------------------- Here start getters for workload management: "Case Age/Average Days Open"
        public Double getWMCAAActualQ1()
        {
            
            if (scorecardQ1 != null && scorecardQ1.WMCAAActual__c != null)
            {
                
                return  scorecardQ1.WMCAAActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getWMCAAActualQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.WMCAAActual__c != null)
            {
            
                return  scorecardQ2.WMCAAActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getWMCAAActualQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.WMCAAActual__c != null)
            {
                
                
                return  scorecardQ3.WMCAAActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getWMCAAActualQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.WMCAAActual__c != null)
            {
                return  scorecardQ4.WMCAAActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getWMCAATargetQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.WMCAATarget__c != null)
            {
                return  scorecardQ1.WMCAATarget__c;
            }
            else
            {
                return 0;   
            }   
        }
        
        public Double getWMCAATargetQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.WMCAATarget__c != null)
            {
                return  scorecardQ2.WMCAATarget__c;
            }
            else
            {
                return 0;   
            }   
        }
        
        public Double getWMCAATargetQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.WMCAATarget__c != null)
            {
                return  scorecardQ3.WMCAATarget__c;
            }
            else
            {
                return 0;   
            }   
        }
        
        public Double getWMCAATargetQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.WMCAATarget__c != null)
            {
                return  scorecardQ4.WMCAATarget__c;
            }
            else
            {
                return 0;   
            }       
        }
        
        public Long getWMCAAAttainmentQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.WMCAAActual__c != null && scorecardQ1.WMCAATarget__c != null)
            {
                if (scorecardQ1.WMCAATarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ1.WMCAAActual__c / scorecardQ1.WMCAATarget__c) * 100);
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
        
        public Long getWMCAAAttainmentQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.WMCAAActual__c != null && scorecardQ2.WMCAATarget__c != null)
            {
                if (scorecardQ2.WMCAATarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ2.WMCAAActual__c / scorecardQ2.WMCAATarget__c) * 100);
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
        
        public Long getWMCAAAttainmentQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.WMCAAActual__c != null && scorecardQ3.WMCAATarget__c != null)
            {
                if (scorecardQ3.WMCAATarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ3.WMCAAActual__c / scorecardQ3.WMCAATarget__c) * 100);
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
        
        public Long getWMCAAAttainmentQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.WMCAAActual__c != null && scorecardQ4.WMCAATarget__c != null)
            {
                if (scorecardQ4.WMCAATarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ4.WMCAAActual__c / scorecardQ4.WMCAATarget__c) * 100);
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
        
        public String getWMCAARating()
        {
             if (scorecardQ1 != null && scorecardQ1.WMCAARating__c != null)
             {
                if(scorecardQ1.WMCAARating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ1.WMCAARating__c.intValue());
             }
             
             if (scorecardQ2 != null && scorecardQ2.WMCAARating__c != null)
             {
                if(scorecardQ2.WMCAARating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ2.WMCAARating__c.intValue());
             }
             
             if (scorecardQ3 != null && scorecardQ3.WMCAARating__c != null)
             {
                if(scorecardQ3.WMCAARating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ3.WMCAARating__c.intValue());
             }
             
             if (scorecardQ4 != null && scorecardQ4.WMCAARating__c != null)
             {
                if(scorecardQ4.WMCAARating__c == -1){
                	return 'N/A';
                }
                return  getRatingDescription(scorecardQ4.WMCAARating__c.intValue());
             }
             
             return '--None--';
        }
        
        public Double getWMCAAWeight()
        {    
             if (scorecardQ1 != null && scorecardQ1.WMCAAWeight__c != null)
             {
                return  scorecardQ1.WMCAAWeight__c;
             }
             
             if (scorecardQ2 != null && scorecardQ2.WMCAAWeight__c != null)
             {
                return  scorecardQ2.WMCAAWeight__c;
             }
             
             if (scorecardQ3 != null && scorecardQ3.WMCAAWeight__c != null)
             {
                return  scorecardQ3.WMCAAWeight__c;
             }
             
             if (scorecardQ4 != null && scorecardQ4.WMCAAWeight__c != null)
             {
                return  scorecardQ4.WMCAAWeight__c;
             }
             
            return 0;
        }
        
        public Double getWMCAAYTDActual()
        {
            Double total = 0;
            Decimal ytd;
            Double Q1;
            Double Q2;
            Double Q3;
            Double Q4;
            
            if (scorecardQ1 != null && scorecardQ1.WMCAAActual__c != null)
            {
                total  = total + scorecardQ1.WMCAAActual__c;
                Q1 = scorecardQ1.WMCAAActual__c;
            }
            
            if (scorecardQ2 != null && scorecardQ2.WMCAAActual__c != null)
            {
                total = total + scorecardQ2.WMCAAActual__c;
                Q2 = scorecardQ2.WMCAAActual__c;
            }
            
            if (scorecardQ3 != null && scorecardQ3.WMCAAActual__c != null)
            {
                total = total +  scorecardQ3.WMCAAActual__c;
                Q3 = scorecardQ3.WMCAAActual__c;
            }
            
            if (scorecardQ4 != null && scorecardQ4.WMCAAActual__c != null)
            {
                total = total + scorecardQ4.WMCAAActual__c;
                Q4 = scorecardQ4.WMCAAActual__c;
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
           
           	System.debug('To to rett ' + ytd );
            ytd = ytd.divide(1,4,System.RoundingMode.HALF_UP);  
            return ytd;
        }
        
        public Double getWMCAAYTDTarget()
        {
            Double total = 0;
            Decimal ytd;
            Double Q1;
            Double Q2;
            Double Q3;
            Double Q4;
            
            if (scorecardQ1 != null && scorecardQ1.WMCAATarget__c != null)
            {
                total = total + scorecardQ1.WMCAATarget__c;
                Q1 = scorecardQ1.WMCAATarget__c;
            }
            
            if (scorecardQ2 != null && scorecardQ2.WMCAATarget__c != null)
            {
                total = total +  scorecardQ2.WMCAATarget__c;
                Q2 = scorecardQ2.WMCAATarget__c;
            }
            
            if (scorecardQ3 != null && scorecardQ3.WMCAATarget__c != null)
            {
                total = total + scorecardQ3.WMCAATarget__c;
                Q3 = scorecardQ3.WMCAATarget__c;
            }
            
            if (scorecardQ4 != null && scorecardQ4.WMCAATarget__c != null)
            {
                total = total +  scorecardQ4.WMCAATarget__c;
                Q4 = scorecardQ4.WMCAATarget__c;
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
           
            ytd = ytd.divide(1,4,System.RoundingMode.HALF_UP);
            return  ytd; 
        }
        
        public Long getWMCAAYTDAttainment()
        {
            Double target = 0;
            Double actual = 0;
            Double result = 0;
            
            target = getWMCAAYTDTarget();
            actual = getWMCAAYTDActual();
            
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
        
        public String getCommentWMCAA()
        {
            if (currentUserComment != null)
            {
                return currentUserComment.CommentWMCAA__c;
            }
            else
            {
                return '';
            }   
        }
        // END OF Case Age/Average Days Open Table
        
      // -------------------------------- Here start getters for workload management: "Solutions"
        public Double getWMSOActualQ1()
        {
            
            if (scorecardQ1 != null && scorecardQ1.WMSOActual__c != null)
            {
                
                return  scorecardQ1.WMSOActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getWMSOActualQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.WMSOActual__c != null)
            {
            
                return  scorecardQ2.WMSOActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getWMSOActualQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.WMSOActual__c != null)
            {
                
                
                return  scorecardQ3.WMSOActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getWMSOActualQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.WMSOActual__c != null)
            {
                return  scorecardQ4.WMSOActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getWMSOTargetQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.WMSOTarget__c != null)
            {
                return  scorecardQ1.WMSOTarget__c;
            }
            else
            {
                return 0;   
            }   
        }
        
        public Double getWMSOTargetQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.WMSOTarget__c != null)
            {
                return  scorecardQ2.WMSOTarget__c;
            }
            else
            {
                return 0;   
            }   
        }
        
        public Double getWMSOTargetQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.WMSOTarget__c != null)
            {
                return  scorecardQ3.WMSOTarget__c;
            }
            else
            {
                return 0;   
            }   
        }
        
        public Double getWMSOTargetQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.WMSOTarget__c != null)
            {
                return  scorecardQ4.WMSOTarget__c;
            }
            else
            {
                return 0;   
            }       
        }
        
        public Long getWMSOAttainmentQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.WMSOActual__c != null && scorecardQ1.WMSOTarget__c != null)
            {
                if (scorecardQ1.WMSOTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ1.WMSOActual__c / scorecardQ1.WMSOTarget__c) * 100);
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
        
        public Long getWMSOAttainmentQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.WMSOActual__c != null && scorecardQ2.WMSOTarget__c != null)
            {
                if (scorecardQ2.WMSOTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ2.WMSOActual__c / scorecardQ2.WMSOTarget__c) * 100);
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
        
        public Long getWMSOAttainmentQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.WMSOActual__c != null && scorecardQ3.WMSOTarget__c != null)
            {
                if (scorecardQ3.WMSOTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ3.WMSOActual__c / scorecardQ3.WMSOTarget__c) * 100);
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
        
        public Long getWMSOAttainmentQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.WMSOActual__c != null && scorecardQ4.WMSOTarget__c != null)
            {
                if (scorecardQ4.WMSOTarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ4.WMSOActual__c / scorecardQ4.WMSOTarget__c) * 100);
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
        
        public Decimal getWMSOYTDActual()
        {
            Decimal total = 0;
            
            if (scorecardQ1 != null && scorecardQ1.WMSOActual__c != null)
            {
                total  = total + scorecardQ1.WMSOActual__c;
            }
            
            if (scorecardQ2 != null && scorecardQ2.WMSOActual__c != null)
            {
                total = total + scorecardQ2.WMSOActual__c;
            }
            
            if (scorecardQ3 != null && scorecardQ3.WMSOActual__c != null)
            {
                total = total +  scorecardQ3.WMSOActual__c;
            }
            
            if (scorecardQ4 != null && scorecardQ4.WMSOActual__c != null)
            {
                total = total + scorecardQ4.WMSOActual__c;
            }
              
            total = total.divide(1,4,System.RoundingMode.HALF_DOWN);    
            return (total);
        }
        
        public Decimal getWMSOYTDTarget()
        {
            Decimal total = 0;
            
            if (scorecardQ1 != null && scorecardQ1.WMSOTarget__c != null)
            {
                total = total + scorecardQ1.WMSOTarget__c;
            }
            
            if (scorecardQ2 != null && scorecardQ2.WMSOTarget__c != null)
            {
                total = total +  scorecardQ2.WMSOTarget__c;
            }
            
            if (scorecardQ3 != null && scorecardQ3.WMSOTarget__c != null)
            {
                total = total + scorecardQ3.WMSOTarget__c;
            }
            
            if (scorecardQ4 != null && scorecardQ4.WMSOTarget__c != null)
            {
                total = total +  scorecardQ4.WMSOTarget__c;
            }
             
            total = total.divide(1,4,System.RoundingMode.HALF_DOWN);     
            return (total);
        }
        
        public Long getWMSOYTDAttainment()
        {
            Double target = 0;
            Double actual = 0;
            Double result = 0;
            
            target = getWMSOYTDTarget();
            actual = getWMSOYTDActual();
            
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
        
        // END OF Solutions Table
        
        
         // -------------------------------- Here start getters for workload management: "Backlog"
        public Double getWMBAActualQ1()
        {
            
            if (scorecardQ1 != null && scorecardQ1.WMBAActual__c != null)
            {
                
                return  scorecardQ1.WMBAActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getWMBAActualQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.WMBAActual__c != null)
            {
            
                return  scorecardQ2.WMBAActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getWMBAActualQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.WMBAActual__c != null)
            {
                
                
                return  scorecardQ3.WMBAActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getWMBAActualQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.WMBAActual__c != null)
            {
                return  scorecardQ4.WMBAActual__c;
            }
            else
            {
                return 0;   
            } 
        }
        
        public Double getWMBATargetQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.WMBATarget__c != null)
            {
                return  scorecardQ1.WMBATarget__c;
            }
            else
            {
                return 0;   
            }   
        }
        
        public Double getWMBATargetQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.WMBATarget__c != null)
            {
                return  scorecardQ2.WMBATarget__c;
            }
            else
            {
                return 0;   
            }   
        }
        
        public Double getWMBATargetQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.WMBATarget__c != null)
            {
                return  scorecardQ3.WMBATarget__c;
            }
            else
            {
                return 0;   
            }   
        }
        
        public Double getWMBATargetQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.WMBATarget__c != null)
            {
                return  scorecardQ4.WMBATarget__c;
            }
            else
            {
                return 0;   
            }       
        }
        
        public Long getWMBAAttainmentQ1()
        {
            if (scorecardQ1 != null && scorecardQ1.WMBAActual__c != null && scorecardQ1.WMBATarget__c != null)
            {
                if (scorecardQ1.WMBATarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ1.WMBAActual__c / scorecardQ1.WMBATarget__c) * 100);
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
        
        public Long getWMBAAttainmentQ2()
        {
            if (scorecardQ2 != null && scorecardQ2.WMSOActual__c != null && scorecardQ2.WMBATarget__c != null)
            {
                if (scorecardQ2.WMBATarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ2.WMBAActual__c / scorecardQ2.WMBATarget__c) * 100);
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
        
        public Long getWMBAAttainmentQ3()
        {
            if (scorecardQ3 != null && scorecardQ3.WMBAActual__c != null && scorecardQ3.WMBATarget__c != null)
            {
                if (scorecardQ3.WMBATarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ3.WMBAActual__c / scorecardQ3.WMBATarget__c) * 100);
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
        
        public Long getWMBAAttainmentQ4()
        {
            if (scorecardQ4 != null && scorecardQ4.WMBAActual__c != null && scorecardQ4.WMBATarget__c != null)
            {
                if (scorecardQ4.WMBATarget__c != 0)
                {
                    Long shortDouble = Math.roundToLong((scorecardQ4.WMBAActual__c / scorecardQ4.WMBATarget__c) * 100);
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
        
        
        public Double getWMBAYTDActual()
        {
            Double total = 0;
            
            if (scorecardQ1 != null && scorecardQ1.WMBAActual__c != null)
            {
                total  = total + scorecardQ1.WMBAActual__c;
            }
            
            if (scorecardQ2 != null && scorecardQ2.WMBAActual__c != null)
            {
                total = total + scorecardQ2.WMBAActual__c;
            }
            
            if (scorecardQ3 != null && scorecardQ3.WMBAActual__c != null)
            {
                total = total +  scorecardQ3.WMBAActual__c;
            }
            
            if (scorecardQ4 != null && scorecardQ4.WMBAActual__c != null)
            {
                total = total + scorecardQ4.WMBAActual__c;
            }
                
            return (total);
        }
        
        public Decimal getWMBAYTDTarget()
        {
            Decimal total = 0;
            
            if (scorecardQ1 != null && scorecardQ1.WMBATarget__c != null)
            {
                total = total + scorecardQ1.WMBATarget__c;
            }
            
            if (scorecardQ2 != null && scorecardQ2.WMBATarget__c != null)
            {
                total = total +  scorecardQ2.WMBATarget__c;
            }
            
            if (scorecardQ3 != null && scorecardQ3.WMBATarget__c != null)
            {
                total = total + scorecardQ3.WMBATarget__c;
            }
            
            if (scorecardQ4 != null && scorecardQ4.WMBATarget__c != null)
            {
                total = total +  scorecardQ4.WMBATarget__c;
            }
            
            total = total.divide(1,4,System.RoundingMode.HALF_DOWN);      
            return (total);
        }
        
        public Long getWMBAYTDAttainment()
        {
            Double target = 0;
            Double actual = 0;
            Double result = 0;
            
            target = getWMBAYTDTarget();
            actual = getWMBAYTDActual();
            
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
        
        
        // END OF Backlog Table
    } 
/*
* Inner Class 
* gets scorecard comments filtered by sharing rules
*/
    public with sharing class ScorecardUtil { 

        public list<ScorecardSupportComment__c> getScorecardCommentWithSharing(PerformanceReview__c p){

            return [select  s.Reviewer__r.Name, 
                            s.Reviewer__c,                        
                            s.CommentWMCCP__c, 
                            s.CommentWMCAA__c,                       
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