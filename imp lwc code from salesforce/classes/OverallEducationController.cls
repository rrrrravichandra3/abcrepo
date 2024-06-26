/*
 * RelEng Perforce/RCS Header - Do not remove!
 *
 * $Author:  $Fabritzio Calvetti
 * $Change:  $
 * $DateTime:  $
 * $File:  $
 * $Id:  $
 * $Revision:  $
 * this class will take an account and assign it to a user.
*/
public with sharing class OverallEducationController {
	public String avgQ1Q2Q3Q4;
    public PerformanceReview__c perfReview;
    public String weightQ1Q2Q3Q4;
    ScorecardSupportReview__c scorecardSupportReview;
    public ScorecardSupportReview__c scorecardSRQ1;
    public ScorecardSupportReview__c scorecardSRQ2;
    public ScorecardSupportReview__c scorecardSRQ3;
    public ScorecardSupportReview__c scorecardSRQ4;
    String V2MOMType = '';
    boolean checkScorecardsQ1Q2 = true;
    boolean checkScorecardsQ3Q4 = true;
    Integer checkQ1 = 0;
    Integer checkQ2 = 0;
    Integer checkQ3 = 0;
    Integer checkQ4 = 0;
	PerformanceAccessUtil accessUtil; 
    OverallUtil util = new OverallUtil();
    
    public OverallEducationController(PerformanceReview__c performanceReview){
    	perfReview = performanceReview;	
        List<PerformanceReview__c> pr = [SELECT p.V2MOM__r.V2MOM_Type__c, p.PremierUser__c, p.V2MOM__c, p.Name From PerformanceReview__c p Where id =: performanceReview.Id];		
        if (pr.size()> 0 )
        {
            V2MOMType = pr[0].V2MOM__r.V2MOM_Type__c;
        }
        util.getScorecardSupportReviewQXWithSharing(performanceReview.Id);
        checkScorecardsQ1Q2 = util.checkScorecardsQ1Q2();
        checkScorecardsQ3Q4 = util.checkScorecardsQ3Q4();        
        scorecardSRQ1 = util.getScorecardSupportReviewQ1WithSharing();                    
        scorecardSRQ2 = util.getScorecardSupportReviewQ2WithSharing();                      
        scorecardSRQ3 = util.getScorecardSupportReviewQ3WithSharing();                
        scorecardSRQ4 = util.getScorecardSupportReviewQ4WithSharing();
    }
    
    public OverallEducationController(){  
                      
    }
    
    public OverallEducationController(PerformanceReview__c performanceReview, boolean filter){
        perfReview = performanceReview;
        User currentUser = [select Id, Profile.Name, ProfileId from User where Id =: userInfo.getUserId()];
        List<PerformanceReview__c> pr = [SELECT p.V2MOM__r.V2MOM_Type__c, p.V2MOM__c, p.Name, p.PremierUser__c From PerformanceReview__c p Where id =: performanceReview.Id];
        if (pr.size()> 0 )
            V2MOMType = pr[0].V2MOM__r.V2MOM_Type__c;     
        list<ScorecardSupportReview__c> listScorecard = new list<ScorecardSupportReview__c>();
        listScorecard = [SELECT Id, FiscalQuarter__c, ForecastAccuracyWeight__c,SalesImpactWeight__c,TimeOnPlatformWeight__c, ForecastAccuracyRating__c,SalesImpactRating__c,TimeOnPlatformRating__c 
                       From ScorecardSupportReview__c 
                       WHERE PerformanceReview__c =: performanceReview.Id];                              
        for(ScorecardSupportReview__c scorecardReview: listScorecard) {
            if (scorecardReview.FiscalQuarter__c == 'Q1')
            {
                scorecardSRQ1 = scorecardReview;
                checkQ1 = checkQ1 + 1;
            }          
            if (scorecardReview.FiscalQuarter__c == 'Q2')
            {
                scorecardSRQ2 = scorecardReview;
                checkQ2 = checkQ2 + 1;
            }        
            if (scorecardReview.FiscalQuarter__c == 'Q3')
            {
                scorecardSRQ3 = scorecardReview;
                checkQ3 = checkQ3 + 1;
            }          
            if (scorecardReview.FiscalQuarter__c == 'Q4')
            {
                scorecardSRQ4 = scorecardReview;
                checkQ4 = checkQ4 + 1;
            }           
            if(currentUser != null && currentUser.Profile.id != PerformanceAccessUtil.getSystem_Administrator_Id()){
	            if (filter){ 
	                scorecardReview.ForecastAccuracyWeight__c = null;
	                scorecardReview.SalesImpactWeight__c = null;
	                scorecardReview.TimeOnPlatformWeight__c = null;                          	
	                scorecardReview.ForecastAccuracyRating__c = null;
	                scorecardReview.SalesImpactRating__c = null;
	                scorecardReview.TimeOnPlatformRating__c = null;               
	            }
            }
        }       
        checkScorecardsQ1Q2 = !((checkQ1 > 1) || (checkQ2 > 1));
        checkScorecardsQ3Q4 = !((checkQ3 > 1) || (checkQ4 > 1));
    }
    
    public OverallUtil getOverallUtil(){
        return  util;
    }
    
    public void setPerformanceAccessUtil(PerformanceAccessUtil au){
    	accessUtil = au;
    }
    
    // checks the data and comments for the education metrics
     public String checkManagerEducationDataEntryRequirements(double sumMethodWeight){
     	String error;     	
     	error = checkManagerEducationDataScorecardEntryRequirements(scorecardSRQ1, sumMethodWeight);
        if (error != ''){
            return error; 
        }else{
	     	error = checkManagerEducationDataScorecardEntryRequirements(scorecardSRQ2, sumMethodWeight);
	        if (error != ''){
	            return error; 
	        }else{
		     	error = checkManagerEducationDataScorecardEntryRequirements(scorecardSRQ3, sumMethodWeight);
		        if (error != ''){
		            return error; 
		        }else{
			     	error = checkManagerEducationDataScorecardEntryRequirements(scorecardSRQ4, sumMethodWeight);
			        if (error != '')
			            return error; 
		        }
	        }
        }       
        if (!checkManagerEducationCommentEntryRequirements())
            return(Label.Please_enter_comments_for_all_scorecard_metrics);       
        return '';
     }
     
     // checks the data for the education metrics
     public String checkManagerEducationDataScorecardEntryRequirements(ScorecardSupportReview__c s, double sumMethodWeight){
        if (s != null){
            if (!checkManagerEducationDataEntryRequirements(s))
                return(Label.Please_select_a_rating_for_each_scorecard_metric); 
            if (!checkManagerEducationWeightEntryRequirements(s, sumMethodWeight))
                return(Label.The_weights_for_all_methods_and_scorecard_metrics_must_equal); 
        }
        return '';
     }

	// checks the entered data for the education metrics is not null
    public boolean checkManagerEducationDataEntryRequirements(ScorecardSupportReview__c s){
            if(s == null)
                return true;           
            if ((s.SalesImpactWeight__c == null)|| (s.TimeOnPlatformWeight__c == null)|| (s.ForecastAccuracyWeight__c == null)
            	|| (s.SalesImpactRating__c == 0)|| (s.TimeOnPlatformRating__c == 0)	|| (s.ForecastAccuracyRating__c == 0)
           	 	|| (s.SalesImpactRating__c == null)|| (s.TimeOnPlatformRating__c == null)|| (s.ForecastAccuracyRating__c == null)){            	
            	return false;     
       	 	} 
       	 	      
        return true;            
    }
    
	// checks the entered weights for the education metrics plus the method weights is 100%
    public boolean checkManagerEducationWeightEntryRequirements(ScorecardSupportReview__c s, double sumMethodWeight){
          
            if(s == null)
                return true;
            if (s.SalesImpactWeight__c != null)
            	sumMethodWeight = sumMethodWeight + s.SalesImpactWeight__c;    
            if (s.TimeOnPlatformWeight__c != null)
            	sumMethodWeight = sumMethodWeight + s.TimeOnPlatformWeight__c;   
            if (s.ForecastAccuracyWeight__c != null)
            	sumMethodWeight = sumMethodWeight + s.ForecastAccuracyWeight__c;
            if (sumMethodWeight != 100)
            	return false;
        return true;            
    }
    
	// checks there are education metric comments entered
    public boolean checkManagerEducationCommentEntryRequirements(){
        list<ScorecardSupportComment__c> commentList = [select  s.Reviewer__r.Name,s.Reviewer__c, s.CommentSalesImpact__c, s.CommentTimeOnPlatform__c,s.CommentForecastAccuracy__c,s.CreatedDate 
                        								from ScorecardSupportComment__c s where  PerformanceReview__c  =: perfReview.Id and s.Reviewer__c =: perfReview.Manager__c order by CreatedDate ASC]; 
           if (commentList.size() == 0)
                return true;            
           ScorecardSupportComment__c comment = commentList.get(0);       
           if ((comment.CommentSalesImpact__c == null)
           		|| (comment.CommentTimeOnPlatform__c == null)
           		|| (comment.CommentForecastAccuracy__c == null) 
                || (comment.CommentSalesImpact__c == '')
                || (comment.CommentTimeOnPlatform__c == '')
                || (comment.CommentForecastAccuracy__c == ''))
                return false;
           
           return true;          
    }   
    
    public String getRatingSalesImpact(){
        if (scorecardSRQ1 != null)
        {	
            if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
            	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
            	return '-';
			
			if(scorecardSRQ1.SalesImpactRating__c == -1)
        		return 'N/A';
            if ((scorecardSRQ1.SalesImpactRating__c != null))
            {
                if (scorecardSRQ1.SalesImpactRating__c.intValue() == 0)
                	return '-';
                return PAMUtil.getRatingLabel(scorecardSRQ1.SalesImpactRating__c.intValue());
            }
        }
        if (scorecardSRQ3 != null)
        {
            if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
            	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
            	return '-';
            if(scorecardSRQ3.SalesImpactRating__c == -1)
        		return 'N/A';
            if ((scorecardSRQ3.SalesImpactRating__c != null) && (scorecardSRQ3.SalesImpactRating__c != 0))
                return PAMUtil.getRatingLabel(scorecardSRQ3.SalesImpactRating__c.intValue());
        }       
        return '-';
    }   
    
    public String getWeightSalesImpact(){
        Double weightSalesImpact;
        if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
        	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
            	return '-';
        if (scorecardSRQ1 != null)
            if (scorecardSRQ1.SalesImpactWeight__c != null){
            	weightSalesImpact = scorecardSRQ1.SalesImpactWeight__c;
                return weightSalesImpact + '%';
            }
        if (scorecardSRQ3 != null)
            if (scorecardSRQ3.SalesImpactWeight__c != null){
            	weightSalesImpact = scorecardSRQ3.SalesImpactWeight__c;
                return weightSalesImpact + '%';
            }
                
        return '-';
    }
    
    public String getRatingTimeOnPlatform(){
    	if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
            	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
            	return '-';
        if (scorecardSRQ1 != null){
        	if(scorecardSRQ1.TimeOnPlatformRating__c == -1)
            	return 'N/A';
            if ((scorecardSRQ1.TimeOnPlatformRating__c != null) && (scorecardSRQ1.TimeOnPlatformRating__c != 0))
                return PAMUtil.getRatingLabel(scorecardSRQ1.TimeOnPlatformRating__c.intValue());
        }
        if (scorecardSRQ3 != null){
        	if(scorecardSRQ3.TimeOnPlatformRating__c == -1)
            	return 'N/A';
            if ((scorecardSRQ3.TimeOnPlatformRating__c != null) && (scorecardSRQ3.TimeOnPlatformRating__c != 0))
                return PAMUtil.getRatingLabel(scorecardSRQ3.TimeOnPlatformRating__c.intValue());
        }
        return '-';
    }
    
    public String getWeightTimeOnPlatform(){
        Double weightTimeOnPlatform;
        if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
            	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
            	return '-';
        if (scorecardSRQ1 != null)
            if (scorecardSRQ1.TimeOnPlatformWeight__c != null){
            	weightTimeOnPlatform = scorecardSRQ1.TimeOnPlatformWeight__c;
                return weightTimeOnPlatform + '%';
            }
        if (scorecardSRQ3 != null)
            if (scorecardSRQ3.TimeOnPlatformWeight__c != null){
            	weightTimeOnPlatform = scorecardSRQ3.TimeOnPlatformWeight__c;
                return scorecardSRQ3.TimeOnPlatformWeight__c.intValue() + '%';
            }
        return '-';
    }
    
    public String getRatingForecastAccuracy(){
    	if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
            	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
            	return '-';
        if (scorecardSRQ1 != null){
        	if(scorecardSRQ1.ForecastAccuracyRating__c == -1)
            	return 'N/A';
            if ((scorecardSRQ1.ForecastAccuracyRating__c != null) && (scorecardSRQ1.ForecastAccuracyRating__c != 0))
                return PAMUtil.getRatingLabel(scorecardSRQ1.ForecastAccuracyRating__c.intValue());
        }
        if (scorecardSRQ3 != null){
        	if(scorecardSRQ3.ForecastAccuracyRating__c == -1)
            	return 'N/A';
            if ((scorecardSRQ3.ForecastAccuracyRating__c != null) && (scorecardSRQ3.ForecastAccuracyRating__c != 0))
                return PAMUtil.getRatingLabel(scorecardSRQ3.ForecastAccuracyRating__c.intValue());
        }
        return '-';
    }  
    
    public String getWeightForecastAccuracy(){
    	if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
            	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
            	return '-';
    	Double weightForecastAccuracy;
    	if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt())
				return '-';
        if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
        	return '-';
        if (scorecardSRQ1 != null)
            if (scorecardSRQ1.ForecastAccuracyWeight__c != null){
             	weightForecastAccuracy = scorecardSRQ1.ForecastAccuracyWeight__c;
                return weightForecastAccuracy + '%';
            }
        if (scorecardSRQ3 != null)
            if (scorecardSRQ3.ForecastAccuracyWeight__c != null){
            	weightForecastAccuracy = scorecardSRQ3.ForecastAccuracyWeight__c;
                return weightForecastAccuracy + '%';
            }
        return '-';
    }
    
    // Rating for Education Metrics
     public Double getAvgRatingEducationMetrics(){
         double avgRatingEducationMetrics = 0;
             if (scorecardSRQ1 != null){
                if((scorecardSRQ1.SalesImpactRating__c != null) && (scorecardSRQ1.SalesImpactWeight__c != null) && (scorecardSRQ1.SalesImpactRating__c != -1))
                    avgRatingEducationMetrics = avgRatingEducationMetrics + scorecardSRQ1.SalesImpactRating__c * scorecardSRQ1.SalesImpactWeight__c/100;
                if((scorecardSRQ1.TimeOnPlatformRating__c != null) && (scorecardSRQ1.TimeOnPlatformWeight__c != null) && (scorecardSRQ1.TimeOnPlatformRating__c != -1))
                    avgRatingEducationMetrics = avgRatingEducationMetrics + scorecardSRQ1.TimeOnPlatformRating__c * scorecardSRQ1.TimeOnPlatformWeight__c/100;
                if((scorecardSRQ1.ForecastAccuracyRating__c != null) && (scorecardSRQ1.ForecastAccuracyWeight__c != null) && (scorecardSRQ1.ForecastAccuracyRating__c != -1))
                    avgRatingEducationMetrics = avgRatingEducationMetrics + scorecardSRQ1.ForecastAccuracyRating__c * scorecardSRQ1.ForecastAccuracyWeight__c/100;
             }else{ 
                if (scorecardSRQ3 != null){
                    if((scorecardSRQ3.SalesImpactRating__c != null) && (scorecardSRQ3.SalesImpactWeight__c != null) && (scorecardSRQ3.SalesImpactRating__c != -1))
                        avgRatingEducationMetrics = avgRatingEducationMetrics + scorecardSRQ3.SalesImpactRating__c * scorecardSRQ3.SalesImpactWeight__c/100;
                    if((scorecardSRQ3.TimeOnPlatformRating__c != null) && (scorecardSRQ3.TimeOnPlatformWeight__c != null) && (scorecardSRQ3.TimeOnPlatformRating__c != -1))
                        avgRatingEducationMetrics = avgRatingEducationMetrics + scorecardSRQ3.TimeOnPlatformRating__c * scorecardSRQ3.TimeOnPlatformWeight__c/100;
                    if((scorecardSRQ3.ForecastAccuracyRating__c != null) && (scorecardSRQ3.ForecastAccuracyWeight__c != null) && (scorecardSRQ3.ForecastAccuracyRating__c != -1))
                        avgRatingEducationMetrics = avgRatingEducationMetrics + scorecardSRQ3.ForecastAccuracyRating__c * scorecardSRQ3.ForecastAccuracyWeight__c/100;
                }
             }
         return avgRatingEducationMetrics;
     }   
    
    
    /*
	 * Inner class: utility class to obtain data with sharing rules
     */
   public with sharing class OverallUtil {            
        List<ScorecardSupportReview__c> scorecardSupportReviews = new List<ScorecardSupportReview__c>();       
        Integer checkQ1 = 0;
        Integer checkQ2 = 0;
        Integer checkQ3 = 0;
        Integer checkQ4 = 0;      
        // checks if there is no more than one scorecard per quarter
        public void checkScorecards(){
            for(ScorecardSupportReview__c scorecardReview: scorecardSupportReviews) {
                if (scorecardReview.FiscalQuarter__c == 'Q1')
                    checkQ1 = checkQ1 + 1;
                if (scorecardReview.FiscalQuarter__c == 'Q2')
                    checkQ2 = checkQ2 + 1;
                if (scorecardReview.FiscalQuarter__c == 'Q3')
                    checkQ3 = checkQ3 + 1;
                if (scorecardReview.FiscalQuarter__c == 'Q4')
                    checkQ4 = checkQ4 + 1;
            }
        }
        // checks if there is no more than one scorecard per quarter
        public boolean checkScorecardsQ1Q2(){
            if ((checkQ1 > 1) || (checkQ2 > 1))
                return false;
            return true;
        }
        // checks if there is no more than one scorecard per quarter
        public boolean checkScorecardsQ3Q4(){
            if ((checkQ3 > 1) || (checkQ4 > 1))  
                return false;
            return true;
        }       
        public ScorecardSupportReview__c getScorecardSupportReviewQ1WithSharing(){
            for (ScorecardSupportReview__c scorecardReview: scorecardSupportReviews){
                if (scorecardReview.FiscalQuarter__c == 'Q1')
                    return scorecardReview;
            }      
            return null;
        }
        public ScorecardSupportReview__c getScorecardSupportReviewQ2WithSharing(){
            for (ScorecardSupportReview__c scorecardReview: scorecardSupportReviews){
                if (scorecardReview.FiscalQuarter__c == 'Q2')
                    return scorecardReview;
            }
            return null;
        }
        public ScorecardSupportReview__c getScorecardSupportReviewQ3WithSharing(){
            for (ScorecardSupportReview__c scorecardReview: scorecardSupportReviews){
                if (scorecardReview.FiscalQuarter__c == 'Q3')
                    return scorecardReview;
            }
            return null;
        }      
        public ScorecardSupportReview__c getScorecardSupportReviewQ4WithSharing(){
            for (ScorecardSupportReview__c scorecardReview: scorecardSupportReviews){
                if (scorecardReview.FiscalQuarter__c == 'Q4')
                    return scorecardReview;
            }
            return null;
        }
        public void getScorecardSupportReviewQXWithSharing(Id id){
            scorecardSupportReviews=[SELECT Id, FiscalQuarter__c, ForecastAccuracyWeight__c,SalesImpactWeight__c,TimeOnPlatformWeight__c,
            								ForecastAccuracyRating__c,SalesImpactRating__c, TimeOnPlatformRating__c
               						From ScorecardSupportReview__c  
                   					WHERE PerformanceReview__c =: Id];       
            checkScorecards();
        }
    }
}