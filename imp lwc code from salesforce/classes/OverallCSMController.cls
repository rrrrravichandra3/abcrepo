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
public with sharing class OverallCSMController {
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
    
    
    public OverallCSMController(PerformanceReview__c performanceReview){
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
    
    public OverallCSMController(){  
                      
    }
    
    public OverallCSMController(PerformanceReview__c performanceReview, boolean filter){
        perfReview = performanceReview;
        List<PerformanceReview__c> pr = [SELECT p.V2MOM__r.V2MOM_Type__c, p.V2MOM__c, p.Name, p.PremierUser__c From PerformanceReview__c p Where id =: performanceReview.Id];
        if (pr.size()> 0 )
            V2MOMType = pr[0].V2MOM__r.V2MOM_Type__c;     
        list<ScorecardSupportReview__c> listScorecard = new list<ScorecardSupportReview__c>();
        listScorecard = [SELECT Id, FiscalQuarter__c, CSMSalesImpactRating__c, CSMSalesImpactWeight__c,RenewalExcellenceRating__c,RenewalExcellenceWeight__c,OperationalExcellenceRating__c,
        						OperationalExcellenceWeight__c, StrategicInitiativesRating__c, StrategicInitiativesWeight__c
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
            if (filter){ 
                //scorecardReview.CsmSalesImpactRating__c = null;
                //scorecardReview.RenewalExcellenceRating__c = null;
               // scorecardReview.StrategicInitiativesRating__c = null;                          	
                //scorecardReview.StrategicInitiativesWeight__c = null;
                //scorecardReview.CsmSalesImpactWeight__c = null;
                //scorecardReview.RenewalExcellenceWeight__c = null;              
                //scorecardReview.RatingCustomerSatisfaction__c = null; 
            }
        }       
        checkScorecardsQ1Q2 = !((checkQ1 > 1) || (checkQ2 > 1));
        checkScorecardsQ3Q4 = !((checkQ3 > 1) || (checkQ4 > 1));
    }
    
    public OverallUtil getOverallUtil(){
        return  util;
    }
    
    public boolean getIsOldPerformanceReview(){ 
		if(perfReview.PerformanceReviewPeriod__r.Effective_Date__c == 'FY08' || perfReview.PerformanceReviewPeriod__r.Effective_Date__c == 'FY09'){
			return true;
		}
		
		return false;
	}
    
    public void setPerformanceAccessUtil(PerformanceAccessUtil au){
    	accessUtil = au;
    }   
    //checks the entered data for the CSM metrics is not null    
     public String checkManagerCSMDataEntryRequirements(double sumMethodWeight){
     	String error;    	
     	error = checkManagerCSMDataScorecardEntryRequirements(scorecardSRQ1, sumMethodWeight);
        if (error != ''){
            return error; 
        }else{
	     	error = checkManagerCSMDataScorecardEntryRequirements(scorecardSRQ2, sumMethodWeight);
	        if (error != ''){
	            return error; 
	        }else{
		     	error = checkManagerCSMDataScorecardEntryRequirements(scorecardSRQ3, sumMethodWeight);
		        if (error != ''){
		            return error; 
		        }else{
			     	error = checkManagerCSMDataScorecardEntryRequirements(scorecardSRQ4, sumMethodWeight);
			        if (error != '')
			            return error; 
		        }
	        }
        }        
        if (!checkManagerCSMCommentEntryRequirements())
            return(Label.Please_enter_comments_for_all_scorecard_metrics);        
        return '';
     }     
     
     public String checkManagerCSMDataScorecardEntryRequirements(ScorecardSupportReview__c s, double sumMethodWeight){
        if (s != null){
            if (!checkManagerCSMDataEntryRequirements(s))
                return(Label.Please_select_a_rating_for_each_scorecard_metric); 
            if (!checkManagerCSMWeightEntryRequirements(s, sumMethodWeight))
                return(Label.The_weights_for_all_methods_and_scorecard_metrics_must_equal);  
        }
        return '';
     }  
     
     public boolean checkManagerCSMDataEntryRequirements(ScorecardSupportReview__c s){
            if(s == null)
                return true; 		
            if ((s.CSMSalesImpactWeight__c == null)
            	|| (s.RenewalExcellenceWeight__c == null)
            	|| ((s.OperationalExcellenceRating__c == null && getIsOldPerformanceReview()))
				|| (s.StrategicInitiativesWeight__c == null)
				|| (s.CSMSalesImpactRating__c == 0) 
				|| (s.RenewalExcellenceRating__c == 0)
				|| ((s.OperationalExcellenceRating__c == 0 && getIsOldPerformanceReview()))
				|| (s.StrategicInitiativesRating__c == 0)	
				|| (s.CSMSalesImpactRating__c == null)
            	|| (s.RenewalExcellenceRating__c == null) 
            	|| ((s.OperationalExcellenceRating__c == null && getIsOldPerformanceReview()))
            	|| (s.StrategicInitiativesRating__c == null))
            return false;           
        return true;            
    }       
    
    public boolean checkManagerCSMWeightEntryRequirements(ScorecardSupportReview__c s, double sumMethodWeight){
            if(s == null)
                return true; 
            if (s.CSMSalesImpactWeight__c != null)
            	sumMethodWeight = sumMethodWeight + s.CSMSalesImpactWeight__c;   
            if (s.RenewalExcellenceWeight__c != null)
            	sumMethodWeight = sumMethodWeight + s.RenewalExcellenceWeight__c;       	
        	if(getIsOldPerformanceReview()){
	        	if (s.OperationalExcellenceWeight__c != null)
	            	sumMethodWeight = sumMethodWeight + s.OperationalExcellenceWeight__c;       	
        	}
        	if (s.StrategicInitiativesWeight__c != null)
            	sumMethodWeight = sumMethodWeight + s.StrategicInitiativesWeight__c;
            if (sumMethodWeight != 100)
            	return false;          
        return true;            
    }
    
	// checks there are education metric comments entered
    public boolean checkManagerCSMCommentEntryRequirements(){
        list<ScorecardSupportComment__c> commentList = [select  s.Reviewer__r.Name, 
                        s.Reviewer__c, s.CommentCSMSalesImpact__c, s.CommentRenewalExcellence__c, 
                        s.CommentOperationalExcellence__c,s.CommentStrategicInitiatives__c, s.CreatedDate 
                        from ScorecardSupportComment__c s 
                        where  PerformanceReview__c  =: perfReview.Id
                        and s.Reviewer__c =: perfReview.Manager__c 
                        order by CreatedDate ASC]; 
           
           if (commentList.size() == 0)
                return true;               
           ScorecardSupportComment__c comment = commentList.get(0);          
           if ((comment.CommentCSMSalesImpact__c == null)
           		|| (comment.CommentRenewalExcellence__c == null)
   				|| ((comment.CommentOperationalExcellence__c == null && getIsOldPerformanceReview())) 
   				|| (comment.CommentStrategicInitiatives__c == null) 				
                || (comment.CommentCSMSalesImpact__c == '') 
                || (comment.CommentOperationalExcellence__c == '') 
                || (comment.CommentStrategicInitiatives__c == ''))
                return false;          
           return true;       
    }     
    
    public String getRatingCSMSalesImpact()
	{
		if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt())
			return '-';
        if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
        	return '-';

		if (scorecardSRQ1 != null){
			if(scorecardSRQ1.CSMSalesImpactRating__c == -1)
            	return 'N/A';
            if ((scorecardSRQ1.CSMSalesImpactRating__c != null) && (scorecardSRQ1.CSMSalesImpactRating__c != 0))
                return PAMUtil.getRatingLabel(scorecardSRQ1.CSMSalesImpactRating__c.intValue());
		}
        if (scorecardSRQ3 != null){
        	if(scorecardSRQ3.CSMSalesImpactRating__c == -1)
            	return 'N/A';
            if ((scorecardSRQ3.CSMSalesImpactRating__c != null) && (scorecardSRQ3.CSMSalesImpactRating__c != 0))
                return PAMUtil.getRatingLabel(scorecardSRQ3.CSMSalesImpactRating__c.intValue());
        }
        return '-';
	}	
	
	public String getRatingRenewalExcellence()
	{
		if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt())
			return '-';			
        if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
        	return '-';   
		 if (scorecardSRQ1 != null){
		 	if(scorecardSRQ1.RenewalExcellenceRating__c == -1)
            	return 'N/A';
            if ((scorecardSRQ1.RenewalExcellenceRating__c != null) && (scorecardSRQ1.RenewalExcellenceRating__c != 0))
                return PAMUtil.getRatingLabel(scorecardSRQ1.RenewalExcellenceRating__c.intValue());
		 }
        if (scorecardSRQ3 != null){
        	if(scorecardSRQ3.RenewalExcellenceRating__c == -1)
            	return 'N/A';
            if ((scorecardSRQ3.RenewalExcellenceRating__c != null) && (scorecardSRQ3.RenewalExcellenceRating__c != 0))
                return PAMUtil.getRatingLabel(scorecardSRQ3.RenewalExcellenceRating__c.intValue());
        }
        return '-';
	}	
	
	public String getRatingOperationalExcellence()
	{
		if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt())
			return '-';
        if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
        	return '-';
		 if (scorecardSRQ1 != null){
		 	if(scorecardSRQ1.OperationalExcellenceRating__c == -1)
            	return 'N/A';
            if ((scorecardSRQ1.OperationalExcellenceRating__c != null) && (scorecardSRQ1.OperationalExcellenceRating__c != 0))
                return PAMUtil.getRatingLabel(scorecardSRQ1.OperationalExcellenceRating__c.intValue());
		 }
        if (scorecardSRQ3 != null){
        	if(scorecardSRQ3.OperationalExcellenceRating__c == -1)
            	return 'N/A';
            if ((scorecardSRQ3.OperationalExcellenceRating__c != null) && (scorecardSRQ3.OperationalExcellenceRating__c != 0))
                return PAMUtil.getRatingLabel(scorecardSRQ3.OperationalExcellenceRating__c.intValue());
        }
        return '-';
	}	
	
	public String getRatingStrategicInitiatives()
	{
		 if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt())
				return '-';
    	 if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
        	return '-';
		 if (scorecardSRQ1 != null){
		 	if(scorecardSRQ1.StrategicInitiativesRating__c == -1)
            	return 'N/A';
            if ((scorecardSRQ1.StrategicInitiativesRating__c != null) && (scorecardSRQ1.StrategicInitiativesRating__c != 0))
                return PAMUtil.getRatingLabel(scorecardSRQ1.StrategicInitiativesRating__c.intValue());
         }
        if (scorecardSRQ3 != null){
        	if(scorecardSRQ3.StrategicInitiativesRating__c == -1)
            	return 'N/A';
            if ((scorecardSRQ3.StrategicInitiativesRating__c != null) && (scorecardSRQ3.StrategicInitiativesRating__c != 0))
                return PAMUtil.getRatingLabel(scorecardSRQ3.StrategicInitiativesRating__c.intValue());
        }
        return '-';
	}
	
	public String getWeightCSMSalesImpact(){
	 	Double weightCSMSalesImpact;
	 	if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt())
				return '-';
        if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
        	return '-';
        if (scorecardSRQ1 != null)
            if (scorecardSRQ1.CSMSalesImpactWeight__c != null){
            	weightCSMSalesImpact = scorecardSRQ1.CSMSalesImpactWeight__c;
                return weightCSMSalesImpact + '%';
            }
        if (scorecardSRQ3 != null)
            if (scorecardSRQ3.CSMSalesImpactWeight__c != null){
            	weightCSMSalesImpact = scorecardSRQ3.CSMSalesImpactWeight__c;
                return weightCSMSalesImpact + '%';
            }
        return '-';
    }   
    
    public String getWeightRenewalExcellence(){
    	Double weightRenewalExcellence;
     	if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt())
				return '-';
        if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
        	return '-';
        if (scorecardSRQ1 != null)
            if (scorecardSRQ1.RenewalExcellenceWeight__c != null){
            	weightRenewalExcellence = scorecardSRQ1.RenewalExcellenceWeight__c;
                return weightRenewalExcellence + '%';
            }
        if (scorecardSRQ3 != null)
            if (scorecardSRQ3.RenewalExcellenceWeight__c != null){
            	weightRenewalExcellence = scorecardSRQ3.RenewalExcellenceWeight__c;
                return weightRenewalExcellence + '%';
            }
        return '-';
    }   
    
    public String getWeightOperationalExcellence(){
    	Double weightOperationalExcellence;
    	if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt())
			return '-';
        if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
        	return '-';
        if (scorecardSRQ1 != null)
            if (scorecardSRQ1.OperationalExcellenceWeight__c != null){
            	weightOperationalExcellence = scorecardSRQ1.OperationalExcellenceWeight__c;
                return weightOperationalExcellence + '%';
            }
        if (scorecardSRQ3 != null)
            if (scorecardSRQ3.OperationalExcellenceWeight__c != null){
            	weightOperationalExcellence = scorecardSRQ3.OperationalExcellenceWeight__c;
                return weightOperationalExcellence + '%';
            }
        return '-';
    }
    
    public String getWeightStrategicInitiatives(){
    	Double weightStrategicInitiatives;
    	if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt())
			return '-';
        if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
        	return '-';
        if (scorecardSRQ1 != null)
            if (scorecardSRQ1.StrategicInitiativesWeight__c != null){
            	weightStrategicInitiatives = scorecardSRQ1.StrategicInitiativesWeight__c;
                return weightStrategicInitiatives + '%';
            }
        if (scorecardSRQ3 != null)
            if (scorecardSRQ3.StrategicInitiativesWeight__c != null){
            	weightStrategicInitiatives = scorecardSRQ3.StrategicInitiativesWeight__c;
                return weightStrategicInitiatives + '%';
            }
        return '-';
    }   
    
    // Rating for CSM Metrics
     public Double getAvgRatingCSMMetrics(){
         double avgRatingCSMMetrics = 0;
             if (scorecardSRQ1 != null){            	
                if((scorecardSRQ1.CSMSalesImpactRating__c != null) && (scorecardSRQ1.CSMSalesImpactWeight__c != null) && (scorecardSRQ1.CSMSalesImpactRating__c != -1))
                    avgRatingCSMMetrics = avgRatingCSMMetrics + scorecardSRQ1.CSMSalesImpactRating__c * scorecardSRQ1.CSMSalesImpactWeight__c/100;
                if((scorecardSRQ1.RenewalExcellenceRating__c != null) && (scorecardSRQ1.RenewalExcellenceWeight__c != null) && (scorecardSRQ1.RenewalExcellenceRating__c != -1))
                    avgRatingCSMMetrics = avgRatingCSMMetrics + scorecardSRQ1.RenewalExcellenceRating__c * scorecardSRQ1.RenewalExcellenceWeight__c/100;
                if((scorecardSRQ1.OperationalExcellenceRating__c != null) && (scorecardSRQ1.OperationalExcellenceWeight__c != null) && (scorecardSRQ1.OperationalExcellenceRating__c != -1))
                    avgRatingCSMMetrics = avgRatingCSMMetrics + scorecardSRQ1.OperationalExcellenceRating__c * scorecardSRQ1.OperationalExcellenceWeight__c/100;
				 if((scorecardSRQ1.StrategicInitiativesRating__c != null) && (scorecardSRQ1.StrategicInitiativesWeight__c != null) && (scorecardSRQ1.StrategicInitiativesRating__c != -1))
                    avgRatingCSMMetrics = avgRatingCSMMetrics + scorecardSRQ1.StrategicInitiativesRating__c * scorecardSRQ1.StrategicInitiativesWeight__c/100;                                   
             }else{ 
                if (scorecardSRQ3 != null){
              		if((scorecardSRQ3.CSMSalesImpactRating__c != null) && (scorecardSRQ3.CSMSalesImpactWeight__c != null) && (scorecardSRQ3.CSMSalesImpactRating__c != -1))
                    	avgRatingCSMMetrics = avgRatingCSMMetrics + scorecardSRQ3.CSMSalesImpactRating__c * scorecardSRQ3.CSMSalesImpactWeight__c/100;
              		if((scorecardSRQ3.RenewalExcellenceRating__c != null) && (scorecardSRQ3.RenewalExcellenceWeight__c != null) && (scorecardSRQ3.RenewalExcellenceRating__c != -1))
                    	avgRatingCSMMetrics = avgRatingCSMMetrics + scorecardSRQ3.RenewalExcellenceRating__c * scorecardSRQ3.RenewalExcellenceWeight__c/100;
              		if((scorecardSRQ3.OperationalExcellenceRating__c != null) && (scorecardSRQ3.OperationalExcellenceWeight__c != null) && (scorecardSRQ3.OperationalExcellenceRating__c != -1))
                    	avgRatingCSMMetrics = avgRatingCSMMetrics + scorecardSRQ3.OperationalExcellenceRating__c * scorecardSRQ3.OperationalExcellenceWeight__c/100;
	            	if((scorecardSRQ3.StrategicInitiativesRating__c != null) && (scorecardSRQ3.StrategicInitiativesWeight__c != null) && (scorecardSRQ3.StrategicInitiativesRating__c != -1))
	                    avgRatingCSMMetrics = avgRatingCSMMetrics + scorecardSRQ3.StrategicInitiativesRating__c * scorecardSRQ3.StrategicInitiativesWeight__c/100;
	                }
             }           
         return avgRatingCSMMetrics;
     }       
     
     
     /*
     * Inner class
     * utilities to retrieve data with sharing
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
            scorecardSupportReviews=[SELECT Id, FiscalQuarter__c, CSMSalesImpactRating__c,CSMSalesImpactWeight__c,RenewalExcellenceRating__c,RenewalExcellenceWeight__c,
            								OperationalExcellenceRating__c,OperationalExcellenceWeight__c,StrategicInitiativesRating__c,StrategicInitiativesWeight__c 
               						From ScorecardSupportReview__c  
                   					WHERE PerformanceReview__c =: Id];       
            checkScorecards();
        }
    }
}