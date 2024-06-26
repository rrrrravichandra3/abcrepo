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
public with sharing class OverallSupportController {
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
    
    public OverallSupportController(PerformanceReview__c performanceReview){
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
    
    public OverallSupportController(){  
                      
    }
    
    public OverallSupportController(PerformanceReview__c performanceReview, boolean filter){
        perfReview = performanceReview;
        User currentUser = [select Id, Profile.Name, ProfileId from User where Id =: userInfo.getUserId()];
        List<PerformanceReview__c> pr = [SELECT p.V2MOM__r.V2MOM_Type__c, p.V2MOM__c, p.Name, p.PremierUser__c From PerformanceReview__c p Where id =: performanceReview.Id];
        if (pr.size()> 0 )
            V2MOMType = pr[0].V2MOM__r.V2MOM_Type__c;     
        list<ScorecardSupportReview__c> listScorecard = new list<ScorecardSupportReview__c>();
        listScorecard = [SELECT Id, FiscalQuarter__c, WeightCS__c, WeightRenewals__c, WeightWMCases__c, WeightWMSMES__c,WeightWMHC__c,WeightWMPA__c,WeightSI__c,
                                AdjustedRatingCS__c,AdjustedRatingRenewals__c,AdjustedRatingWMCases__c, AdjustedRatingWMSMES__c,AdjustedRatingWMHC__c,AdjustedRatingWMPA__c,AdjustedRatingSI__c,
                                CalculatedRatingCS__c, CalculatedRatingRenewals__c, CalculatedRatingWMCases__c,CalculatedRatingWMSMES__c,CalculatedRatingWMHC__c,CalculatedRatingWMPA__c,CalculatedRatingSI__c,
                                RatingCustomerSatisfaction__c, WeightCustomerSatisfaction__c,CustomerSatisfactionActual__c,CustomerSatisfactionTarget__c,WMCCPActual__c, 
                            	WMCCPWeight__c, WMCCPTarget__c, WMCCPRating__c,WMCAAActual__c, WMCAAWeight__c, WMCAATarget__c,WMCAARating__c,WMSOActual__c,WMSOTarget__c,WMBAActual__c,WMBATarget__c 
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
	                scorecardReview.AdjustedRatingCS__c = null;
	                scorecardReview.AdjustedRatingRenewals__c = null; 
	                scorecardReview.AdjustedRatingWMCases__c = null;
	                scorecardReview.AdjustedRatingWMSMES__c = null;
	                scorecardReview.AdjustedRatingWMHC__c = null;
	                scorecardReview.AdjustedRatingWMPA__c = null;
	                scorecardReview.AdjustedRatingSI__c = null;     
	                scorecardReview.RatingCustomerSatisfaction__c = null; 
		        	scorecardReview.WeightCustomerSatisfaction__c = null;
		        	scorecardReview.WMCCPActual__c = null;
		        	scorecardReview.WMCCPWeight__c = null; 
		        	scorecardReview.WMCCPTarget__c = null; 
		        	scorecardReview.WMCCPRating__c = null;
		            scorecardReview.WMCAAActual__c = null;
		            scorecardReview.WMCAAWeight__c = null;
		            scorecardReview.WMCAATarget__c = null;
		            scorecardReview.WMCAARating__c = null;
		            scorecardReview.WMSOActual__c = null;
		            scorecardReview.WMSOTarget__c = null;
		            scorecardReview.WMBAActual__c = null;
		            scorecardReview.WMBATarget__c = null;                   
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
    
    // checks the data and comments for the support metrics
     public String checkManagerSupportDataEntryRequirements(){
        if (V2MOMType.equals('Individual Q1/Q2')){
            if (!checkManagerSupportDataEntryRequirements(scorecardSRQ1))
                return(Label.ScorecardSupport_Error4 + '.'); 
            if (!checkWeightSum(scorecardSRQ1))
                return(Label.ScorecardSupport_Error9 + '.'); 
            if (!checkManagerSupportDataEntryRequirements(scorecardSRQ2))
                return(Label.ScorecardSupport_Error5 + '.'); 
            if (!checkWeightSum(scorecardSRQ2))
                return(Label.ScorecardSupport_Error10 + '.'); 
        }
        if (V2MOMType.equals('Individual Q3/Q4')){
            if (!checkManagerSupportDataEntryRequirements(scorecardSRQ3))
                return(Label.ScorecardSupport_Error6 + '.'); 
            if (!checkWeightSum(scorecardSRQ3))
                return(Label.ScorecardSupport_Error11 + '.'); 
            if (!checkManagerSupportDataEntryRequirements(scorecardSRQ4))
                return(Label.ScorecardSupport_Error7 + '.'); 
            if (!checkWeightSum(scorecardSRQ4))
                return(Label.ScorecardSupport_Error12 + '.'); 
        }       
        if (!checkManagerSupportCommentEntryRequirements())
            return(Label.ScorecardSupport_Error8 + '.');        
        return '';
     }    
     
     // checks the entered data for the support metrics is not null
    public boolean checkManagerSupportDataEntryRequirements(ScorecardSupportReview__c s){
            if(s == null){
                return true;
            }   
            if ((s.AdjustedRatingCS__c == null) 
            || (s.AdjustedRatingRenewals__c == null) 
            || (s.AdjustedRatingWMCases__c == null)
            || (s.AdjustedRatingWMHC__c == null)
            || (s.AdjustedRatingWMPA__c == null) 
            || (s.AdjustedRatingWMSMES__c == null)
            || (s.AdjustedRatingSI__c == null)  
            || (s.AdjustedRatingCS__c == '')
            || (s.AdjustedRatingRenewals__c == '')
            || (s.AdjustedRatingWMCases__c == '') 
            || (s.AdjustedRatingWMHC__c == '')
            || (s.AdjustedRatingWMPA__c == '')
            || (s.AdjustedRatingWMSMES__c == '')  
            || (s.AdjustedRatingSI__c == '')  
            || (s.AdjustedRatingCS__c == '0')
            || (s.AdjustedRatingRenewals__c == '0')
            || (s.AdjustedRatingWMCases__c == '0')
            || (s.AdjustedRatingWMHC__c == '0')
            || (s.AdjustedRatingWMPA__c == '0') 
            || (s.AdjustedRatingWMSMES__c == '0')
            || (s.AdjustedRatingSI__c == '0')
            || (s.WeightCS__c == null)
            || (s.WeightRenewals__c == null) 
            || (s.WeightWMCases__c == null)
            || (s.WeightWMHC__c == null)
            || (s.WeightWMPA__c == null)
            || (s.WeightWMSMES__c == null)
            || (s.WeightSI__c == null))
            	return false;           
        return true;            
    }   
       
	// checks the entered data for the support metrics sums 100
    public boolean checkWeightSum(ScorecardSupportReview__c s){
            if(s == null){
                return true;
            }   
			if (s.WeightCS__c + s.WeightRenewals__c + s.WeightWMCases__c + s.WeightWMHC__c 
			+ s.WeightWMPA__c + s.WeightWMSMES__c + s.WeightSI__c != 100)
				return false;           
        return true;            
    }
    
	// checks there are support metric comments entered
    public boolean checkManagerSupportCommentEntryRequirements(){
        list<ScorecardSupportComment__c> commentList = [select  s.Reviewer__r.Name, 
                        										s.Reviewer__c, s.CommentCS__c, 
                        										s.CommentRenewals__c, s.CommentSupportInitiatives__c, 
                        										s.CommentWMCases__c, s.CommentWMSMES__c,
                        										s.CommentWMPA__c, s.CommentWMHC__c, 
                        										s.CommentWMCCP__c, s.CommentWMCAA__c, 
                        										s.CreatedDate 
                        								from ScorecardSupportComment__c s 
                        								where  PerformanceReview__c  =: perfReview.Id
                        								and s.Reviewer__c =: perfReview.Manager__c 
                        								order by CreatedDate ASC]; 
           
           if (commentList.size() == 0)
                return true;              
           ScorecardSupportComment__c comment = commentList.get(0);          
           if ((comment.CommentCS__c == null) 
           		|| (comment.CommentRenewals__c == null)
           		|| (comment.CommentSupportInitiatives__c == null)
                || (comment.CommentWMCases__c == null)
                || (comment.CommentWMSMES__c == null)
                || (comment.CommentWMPA__c == null)  
                || (comment.CommentCS__c == '')
                || (comment.CommentRenewals__c == '')
                || (comment.CommentSupportInitiatives__c == '')
                || (comment.CommentWMCases__c == '')
                || (comment.CommentWMSMES__c == '')
                || (comment.CommentWMPA__c == '')
                || (comment.CommentWMHC__c == ''))
                return false;          
           return true;         
    }      
     
    // checks the data and comments for the new support metrics
     public String checkManagerNewSupportDataEntryRequirements(double sumMethodWeight){
     	String error;   	
     	error = checkManagerNewSupportDataScorecardEntryRequirements(scorecardSRQ1, sumMethodWeight);
        if (error != ''){
            return error; 
        }else{
	     	error = checkManagerNewSupportDataScorecardEntryRequirements(scorecardSRQ2, sumMethodWeight);
	        if (error != ''){
	            return error; 
	        }else{
		     	error = checkManagerNewSupportDataScorecardEntryRequirements(scorecardSRQ3, sumMethodWeight);
		        if (error != ''){
		            return error; 
		        }else{
			     	error = checkManagerNewSupportDataScorecardEntryRequirements(scorecardSRQ4, sumMethodWeight);
			        if (error != ''){
			            return error; 
			        }
		        }
	        }
        }       
        if (!checkManagerNewSupportCommentEntryRequirements())
            return(Label.Please_enter_comments_for_all_scorecard_metrics);       
        return '';
     }     
     
     // checks the data for the new support metrics
     public String checkManagerNewSupportDataScorecardEntryRequirements(ScorecardSupportReview__c s, double sumMethodWeight){
        if (s != null){
            if (!checkManagerNewSupportDataEntryRequirements(s))
                return(Label.Please_select_a_rating_for_each_scorecard_metric); 
            if (!checkManagerNewSupportWeightEntryRequirements(s, sumMethodWeight))
                return(Label.The_weights_for_all_methods_and_scorecard_metrics_must_equal); 
        }
        return '';
     }
     
	// checks the entered data for the new support metrics is not null
    public boolean checkManagerNewSupportDataEntryRequirements(ScorecardSupportReview__c s){
            if(s == null){
                return true;
            }   		
    		if(!perfReview.PremierUser__c){
	            if ((s.WeightCustomerSatisfaction__c == null) 
	            	|| (s.WMCCPWeight__c == null)
	            	|| (s.WMCAAWeight__c == null)
	            	|| (s.RatingCustomerSatisfaction__c == 0) 
	            	|| (s.WMCCPRating__c == 0) 
	            	|| (s.WMCAARating__c == 0)
	            	|| (s.RatingCustomerSatisfaction__c == null)
	            	|| (s.WMCCPRating__c == null) 
	            	|| (s.WMCAARating__c == null)){
	            	return false;
	        	}
    		}
    		else{
    			if ((s.WeightCustomerSatisfaction__c == null) 
    				|| (s.WMCCPWeight__c == null)
	            	|| (s.RatingCustomerSatisfaction__c == 0) 
	            	|| (s.WMCCPRating__c == 0)
	            	|| (s.RatingCustomerSatisfaction__c == null)
	            	|| (s.WMCCPRating__c == null)){
	            	return false;
	        	}
    		}         
        return true;            
    }
    
	// checks the entered weights for the new support metrics plus the method weights is 100%
    public boolean checkManagerNewSupportWeightEntryRequirements(ScorecardSupportReview__c s, double sumMethodWeight){
            double toPremierWeight;
            if(s == null){
                return true;
            }   
            if (s.WeightCustomerSatisfaction__c != null){
            	sumMethodWeight = sumMethodWeight + s.WeightCustomerSatisfaction__c;
            	toPremierWeight = sumMethodWeight;
            }  
            if (s.WMCCPWeight__c != null){
            	sumMethodWeight = sumMethodWeight + s.WMCCPWeight__c;
            	toPremierWeight = sumMethodWeight;
            }  		
            if (s.WMCAAWeight__c != null){
            	sumMethodWeight = sumMethodWeight + s.WMCAAWeight__c;
            	toPremierWeight = sumMethodWeight - s.WMCAAWeight__c;
            }			
			if(perfReview.PremierUser__c && toPremierWeight !=100){
				
				return false;	
			}
			else{
	            if (!perfReview.PremierUser__c && sumMethodWeight != 100){
	           
	            	return false;
	            }
			}    	           
        return true;            
    }
    
	// checks there are new support metric comments entered
    public boolean checkManagerNewSupportCommentEntryRequirements(){
        list<ScorecardSupportComment__c> commentList = [select  s.Reviewer__r.Name, s.Reviewer__c, s.CommentCS__c, s.CommentWMCCP__c,s.CommentWMCAA__c, s.CreatedDate 
                        								from ScorecardSupportComment__c s 
                        								where  PerformanceReview__c  =: perfReview.Id
                        								and s.Reviewer__c =: perfReview.Manager__c 
                        								order by CreatedDate ASC];           
           if (commentList.size() == 0)
                return true;               
           ScorecardSupportComment__c comment = commentList.get(0);          
           if(!perfReview.PremierUser__c){
	           if ((comment.CommentCS__c == null) 
	           	  || (comment.CommentWMCCP__c == null)
	           	  || (comment.CommentWMCAA__c == null)
	              || (comment.CommentCS__c == '')
	              || (comment.CommentWMCCP__c == '')
	              || (comment.CommentWMCAA__c == '')){	                              
	                return false;
	            }
           }
           else
           {
           		if ((comment.CommentCS__c == null) 
           			|| (comment.CommentWMCCP__c == null)
	              	|| (comment.CommentCS__c == '')
	              	|| (comment.CommentWMCCP__c == '')){                              
	                return false;
	            }
           }
                     
           return true;         
    }     
    
    public boolean getIsOld(){
		if(perfReview.V2MOM__r.V2MOM_Type__c == 'Individual Q1/Q2'){
        	if(scorecardSRQ1 != null && scorecardSRQ1.CustomerSatisfactionActual__c == null && scorecardSRQ1.CustomerSatisfactionTarget__c == null
        	   && scorecardSRQ2 != null && scorecardSRQ2.CustomerSatisfactionActual__c == null && scorecardSRQ2.CustomerSatisfactionTarget__c == null){	        		
        			return true;
        	}
		} 
		else{
			if(perfReview.V2MOM__r.V2MOM_Type__c == 'Individual Q3/Q4'){
				if((scorecardSRQ3 != null && scorecardSRQ3.CustomerSatisfactionActual__c == null && scorecardSRQ3.CustomerSatisfactionTarget__c == null
        	   && scorecardSRQ4 != null && scorecardSRQ4.CustomerSatisfactionActual__c == null && scorecardSRQ4.CustomerSatisfactionTarget__c == null)){	
					return true;
				}	
			}
		}
    	return false;
    }
    
    // NEW WORKLOAD MANAGEMENT TABLES
	public String getRatingWMCCP()
	{		
		if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt())
				return '-';
        if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
        	return '-';
		if (scorecardSRQ1 != null){
			if(scorecardSRQ1.WMCCPRating__c == -1)
            	return 'N/A';
            if ((scorecardSRQ1.WMCCPRating__c != null) && (scorecardSRQ1.WMCCPRating__c != 0))
                return PAMUtil.getRatingLabel(scorecardSRQ1.WMCCPRating__c.intValue());
        }
        if (scorecardSRQ3 != null){
        	if(scorecardSRQ3.WMCCPRating__c == -1)
            	return 'N/A';
            if ((scorecardSRQ3.WMCCPRating__c != null) && (scorecardSRQ3.WMCCPRating__c != 0))
                return PAMUtil.getRatingLabel(scorecardSRQ3.WMCCPRating__c.intValue());
        }
        return '-';
	}
	
	public String getWeightWMCCP(){
		Double weightWMCCP;
		if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt())
				return '-';
        if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
        	return '-';
        if (scorecardSRQ1 != null)
            if (scorecardSRQ1.WMCCPWeight__c != null){
            	weightWMCCP =  scorecardSRQ1.WMCCPWeight__c;
                return weightWMCCP + '%';
            }
        if (scorecardSRQ3 != null)
            if (scorecardSRQ3.WMCCPWeight__c != null){
            	weightWMCCP = scorecardSRQ3.WMCCPWeight__c;
                return weightWMCCP + '%';
            }
        return '-';
    }   
    
    public String getRatingWMCAA()
	{		
		if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt())
				return '-';
        if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
        	return '-';
		if (scorecardSRQ1 != null){
			if(scorecardSRQ1.WMCAARating__c == -1)
            	return 'N/A';
            if ((scorecardSRQ1.WMCAARating__c != null) && (scorecardSRQ1.WMCAARating__c != 0))
                return PAMUtil.getRatingLabel(scorecardSRQ1.WMCAARating__c.intValue());
        }
        if (scorecardSRQ3 != null){
        	if(scorecardSRQ3.WMCAARating__c == -1)
            	return 'N/A';
            if ((scorecardSRQ3.WMCAARating__c != null) && (scorecardSRQ3.WMCAARating__c != 0))
                return PAMUtil.getRatingLabel(scorecardSRQ3.WMCAARating__c.intValue());
        }
        return '-';
	}
	
	public String getWeightWMCAA(){
		Double weightWMCAA;
		if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt())
				return '-';
        if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
        	return '-';
        if (scorecardSRQ1 != null)
            if (scorecardSRQ1.WMCAAWeight__c != null){
            	weightWMCAA = scorecardSRQ1.WMCAAWeight__c;
                return weightWMCAA + '%';
            }
        if (scorecardSRQ3 != null)
            if (scorecardSRQ3.WMCAAWeight__c != null){
            	weightWMCAA = scorecardSRQ3.WMCAAWeight__c;
                return weightWMCAA + '%';
            }
        return '-';
    } 
     
    public String getRatingCustomerSatisfaction()
	{	
		if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt())
				return '-';
        if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
        	return '-';
		 if (scorecardSRQ1 != null){
		 	if(scorecardSRQ1.RatingCustomerSatisfaction__c == -1)
            	return 'N/A';
            if ((scorecardSRQ1.RatingCustomerSatisfaction__c != null) && (scorecardSRQ1.RatingCustomerSatisfaction__c != 0))
                return PAMUtil.getRatingLabel(scorecardSRQ1.RatingCustomerSatisfaction__c.intValue());
        }
        if (scorecardSRQ3 != null){
        	if(scorecardSRQ3.RatingCustomerSatisfaction__c == -1)
            	return 'N/A';
            if ((scorecardSRQ3.RatingCustomerSatisfaction__c != null) && (scorecardSRQ3.RatingCustomerSatisfaction__c != 0))
                return PAMUtil.getRatingLabel(scorecardSRQ3.RatingCustomerSatisfaction__c.intValue());
        }
        return '-';
	}
	
	public String getWeightCustomerSatisfaction(){
		Double weightCustomerSatisfaction;
		if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt())
				return '-';
        if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
        	return '-';
        if (scorecardSRQ1 != null)
            if (scorecardSRQ1.WeightCustomerSatisfaction__c != null){
            	weightCustomerSatisfaction = scorecardSRQ1.WeightCustomerSatisfaction__c;
                return weightCustomerSatisfaction + '%';
            }
        if (scorecardSRQ3 != null)
            if (scorecardSRQ3.WeightCustomerSatisfaction__c != null){
            	weightCustomerSatisfaction = scorecardSRQ3.WeightCustomerSatisfaction__c;
                return weightCustomerSatisfaction + '%';
            }
        return '-';
    }      
    
     public String getAvgQ1Q3(){      
        if(scorecardSRQ1 != null && V2MOMType.equals('Individual Q1/Q2')){        	
            if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
            	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
            	return '-';
            if (scorecardSRQ1.AdjustedRatingCS__c == null) return '-';
            	return scorecardSRQ1.AdjustedRatingCS__c;
        }
        else{
            if(scorecardSRQ3 != null && V2MOMType.equals('Individual Q3/Q4')){
                if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
            	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
	            {
	            	return '-';
	            }
                if (scorecardSRQ3.AdjustedRatingCS__c == null) return '-';
                return scorecardSRQ3.AdjustedRatingCS__c;
            }
        }
        return '-';           
    }	
    
	public String getCustomerSatisfactionRatingQ1_Q3(){        
        if(scorecardSRQ1 != null && V2MOMType.equals('Individual Q1/Q2')){       	
            if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
            	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
            {
            	return '-';
            }
            if (scorecardSRQ1.RatingCustomerSatisfaction__c == null) return '-';
            return String.valueOf(scorecardSRQ1.RatingCustomerSatisfaction__c);
        }
        else{
            if(scorecardSRQ3 != null && V2MOMType.equals('Individual Q3/Q4')){
                if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
            	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
	            {
	            	return '-';
	            }
                if (scorecardSRQ3.RatingCustomerSatisfaction__c == null) return '-';
                return String.valueOf(scorecardSRQ3.RatingCustomerSatisfaction__c);
            }
        }
        return '-';           
    }   
    
    public String getCustomerSatisfactionRatingQ2_Q4(){     
        if(scorecardSRQ2 != null && V2MOMType.equals('Individual Q1/Q2')){   	
            if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
            	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
            {
            	return '-';
            }
            if (scorecardSRQ2.RatingCustomerSatisfaction__c == null) return '-';
            return String.valueOf(scorecardSRQ2.RatingCustomerSatisfaction__c);
        }
        else{
            if(scorecardSRQ4 != null && V2MOMType.equals('Individual Q3/Q4')){
                if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
            	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
	            {
	            	return '-';
	            }
                if (scorecardSRQ4.RatingCustomerSatisfaction__c == null) return '-';
                return String.valueOf(scorecardSRQ4.RatingCustomerSatisfaction__c);
            }
        }
        return '-';           
    }	
    
    public String getAvgQ2Q4(){
        if(scorecardSRQ2 != null && V2MOMType.equals('Individual Q1/Q2')){
            if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
        	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
            {
            	return '-';
            }
            if (scorecardSRQ2.AdjustedRatingCS__c == null) return '-';
            return scorecardSRQ2.AdjustedRatingCS__c;
        }
        else{
            if(scorecardSRQ4 != null && V2MOMType.equals('Individual Q3/Q4')){
                if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
            	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
	            {
	            	return '-';
	            }
                if (scorecardSRQ4.AdjustedRatingCS__c == null) return '-';
                return scorecardSRQ4.AdjustedRatingCS__c;
            }
        }   
        return '-';           
    }
    
    public String getAvgQ1Q3Renewals(){
        if(scorecardSRQ1 != null && V2MOMType.equals('Individual Q1/Q2')){
            if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
        	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
            {
            	return '-';
            }
            if (scorecardSRQ1.AdjustedRatingRenewals__c == null) return '-';
            return scorecardSRQ1.AdjustedRatingRenewals__c;
        }
        else{
            if(scorecardSRQ3 != null && V2MOMType.equals('Individual Q3/Q4')){
                if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
            	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
	            {
	            	return '-';
	            }
                if (scorecardSRQ3.AdjustedRatingRenewals__c == null) return '-';
                return scorecardSRQ3.AdjustedRatingRenewals__c;
            }
        }
        return '-';           
    }
    
    public String getAvgQ2Q4Renewals(){
        if(scorecardSRQ2 != null && V2MOMType.equals('Individual Q1/Q2')){
            if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
        	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
            {
            	return '-';
            }
            if (scorecardSRQ2.AdjustedRatingRenewals__c == null) return '-';
            return scorecardSRQ2.AdjustedRatingRenewals__c;
        }
        else{
            if(scorecardSRQ4 != null && V2MOMType.equals('Individual Q3/Q4')){
                if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
            	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
	            {
	            	return '-';
	            }
                if (scorecardSRQ4.AdjustedRatingRenewals__c == null) return '-';
                return scorecardSRQ4.AdjustedRatingRenewals__c;
            }
        }   
        return '-';           
    }
    
    public String getAvgQ1Q3WMCases(){
        if(scorecardSRQ1 != null && V2MOMType.equals('Individual Q1/Q2')){
            if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
        	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
            {
            	return '-';
            }
            if (scorecardSRQ1.AdjustedRatingWMCases__c == null) return '-';
            return scorecardSRQ1.AdjustedRatingWMCases__c;
        }
        else{
            if(scorecardSRQ3 != null && V2MOMType.equals('Individual Q3/Q4')){
                if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
            	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
	            {
	            	return '-';
	            }
                if (scorecardSRQ3.AdjustedRatingWMCases__c == null) return '-';
                return scorecardSRQ3.AdjustedRatingWMCases__c;
            }
        }
        return '-';           
    }
    
    public String getAvgQ2Q4WMCases(){
        if(scorecardSRQ2 != null && V2MOMType.equals('Individual Q1/Q2')){
            if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
        	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
            {
            	return '-';
            }
            if (scorecardSRQ2.AdjustedRatingWMCases__c == null) return '-';
            return scorecardSRQ2.AdjustedRatingWMCases__c;
        }
        else{
            if(scorecardSRQ4 != null && V2MOMType.equals('Individual Q3/Q4')){
                if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
            	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
	            	return '-';
                if (scorecardSRQ4.AdjustedRatingWMCases__c == null) return '-';
                return scorecardSRQ4.AdjustedRatingWMCases__c;
            }
        }   
        return '-';           
    }
    
    public String getAvgQ1Q3WMSMES(){
        if(scorecardSRQ1 != null && V2MOMType.equals('Individual Q1/Q2')){
            if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
        	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
            	return '-';
            if (scorecardSRQ1.AdjustedRatingWMSMES__c == null) return '-';
            return scorecardSRQ1.AdjustedRatingWMSMES__c;
        }
        else{
            if(scorecardSRQ3 != null && V2MOMType.equals('Individual Q3/Q4')){
                if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
            	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
	            	return '-';
                if (scorecardSRQ3.AdjustedRatingWMSMES__c == null) return '-';
                return scorecardSRQ3.AdjustedRatingWMSMES__c;
            }
        }
        return '-';           
    }
    
    public String getAvgQ2Q4WMSMES(){
        if(scorecardSRQ2 != null && V2MOMType.equals('Individual Q1/Q2')){
            if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
        	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
            	return '-';
            if (scorecardSRQ2.AdjustedRatingWMSMES__c == null) return '-';
            return scorecardSRQ2.AdjustedRatingWMSMES__c;
        }
        else{
            if(scorecardSRQ4 != null && V2MOMType.equals('Individual Q3/Q4')){
                if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
            	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
	            	return '-';
                if (scorecardSRQ4.AdjustedRatingWMSMES__c == null) return '-';
                return scorecardSRQ4.AdjustedRatingWMSMES__c;
            }
        }   
        return '-';           
    }
    
    public String getAvgQ1Q3WMHC(){
        if(scorecardSRQ1 != null && V2MOMType.equals('Individual Q1/Q2')){
            if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
        	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
            	return '-';
            if (scorecardSRQ1.AdjustedRatingWMHC__c == null) return '-';
            return scorecardSRQ1.AdjustedRatingWMHC__c;
        }
        else{
            if(scorecardSRQ3 != null && V2MOMType.equals('Individual Q3/Q4')){
                if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
            	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
	            	return '-';
                if (scorecardSRQ3.AdjustedRatingWMHC__c == null) return '-';
                return scorecardSRQ3.AdjustedRatingWMHC__c;
            }
        }
        return '-';           
    }
    
    public String getAvgQ2Q4WMHC(){
        if(scorecardSRQ2 != null && V2MOMType.equals('Individual Q1/Q2')){
            if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
        	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
            	return '-';
            if (scorecardSRQ2.AdjustedRatingWMHC__c == null) return '-';
            return scorecardSRQ2.AdjustedRatingWMHC__c;
        }
        else{
            if(scorecardSRQ4 != null && V2MOMType.equals('Individual Q3/Q4')){
                if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
            	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
	            	return '-';
                if (scorecardSRQ4.AdjustedRatingWMHC__c == null) return '-';
                return scorecardSRQ4.AdjustedRatingWMHC__c;
            }
        }   
        return '-';           
    }
    
    public String getAvgQ1Q3WMPA(){
        if(scorecardSRQ1 != null && V2MOMType.equals('Individual Q1/Q2')){
            if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
        	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
            	return '-';
            if (scorecardSRQ1.AdjustedRatingWMPA__c == null) return '-';
            return scorecardSRQ1.AdjustedRatingWMPA__c;
        }
        else{
            if(scorecardSRQ3 != null && V2MOMType.equals('Individual Q3/Q4')){
                if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
            	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
	            	return '-';
                if (scorecardSRQ3.AdjustedRatingWMPA__c == null) return '-';
                return scorecardSRQ3.AdjustedRatingWMPA__c;
            }
        }
        return '-';           
    }
    
    public String getAvgQ2Q4WMPA(){
        if(scorecardSRQ2 != null && V2MOMType.equals('Individual Q1/Q2')){
            if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
        	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
            	return '-';
            if (scorecardSRQ2.AdjustedRatingWMPA__c == null) return '-';
            return scorecardSRQ2.AdjustedRatingWMPA__c;
        }
        else{
            if(scorecardSRQ4 != null && V2MOMType.equals('Individual Q3/Q4')){
                if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
            	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
	            	return '-';
                if (scorecardSRQ4.AdjustedRatingWMPA__c == null) return '-';
                return scorecardSRQ4.AdjustedRatingWMPA__c;
            }
        }   
        return '-';           
    }
    
    public String getAvgQ1Q3SI(){
        if(scorecardSRQ1 != null && V2MOMType.equals('Individual Q1/Q2')){
            if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
        	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
            	return '-';
            if (scorecardSRQ1.AdjustedRatingSI__c == null) return '-';
            return scorecardSRQ1.AdjustedRatingSI__c;
        }
        else{
            if(scorecardSRQ3 != null && V2MOMType.equals('Individual Q3/Q4')){
                if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
            	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
	            	return '-';
                if (scorecardSRQ3.AdjustedRatingSI__c == null) return '-';
                return scorecardSRQ3.AdjustedRatingSI__c;
            }
        }
        return '-';           
    }
    
    public String getAvgQ2Q4SI(){
        if(scorecardSRQ2 != null && V2MOMType.equals('Individual Q1/Q2')){
            if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
        	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
            	return '-';
            if (scorecardSRQ2.AdjustedRatingSI__c == null) return '-';
            return scorecardSRQ2.AdjustedRatingSI__c;
        }
        else{
            if(scorecardSRQ4 != null && V2MOMType.equals('Individual Q3/Q4')){
                if((perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.SecondManager__c)
            	|| (perfReview.Status__c == 'Manager Assessment' && perfReview.PreviousStatus__c == '2nd Level Manager Assessment' && userInfo.getUserId() == perfReview.PCOMM__c))
	            	return '-';
                if (scorecardSRQ4.AdjustedRatingSI__c == null) return '-';
                return scorecardSRQ4.AdjustedRatingSI__c;
            }
        }   
        return '-';           
    }
    
    public String getWeightQ1Q3(){
        if(scorecardSRQ1 != null && V2MOMType.equals('Individual Q1/Q2')){
            if (scorecardSRQ1.WeightCS__c == null) return '-';
            return scorecardSRQ1.WeightCS__c+'%';
        }
        else{
            if(scorecardSRQ3 != null && V2MOMType.equals('Individual Q3/Q4')){
                if (scorecardSRQ3.WeightCS__c == null) return '-';
                return scorecardSRQ3.WeightCS__c+'%';
            }
        }
        return '0%';           
    }
    
    public String getWeightQ2Q4(){
        if (scorecardSRQ2 != null && V2MOMType.equals('Individual Q1/Q2')){
            if (scorecardSRQ2.WeightCS__c == null) return '-';
            return scorecardSRQ2.WeightCS__c+'%';
        }
        else{
            if (scorecardSRQ4 != null && V2MOMType.equals('Individual Q3/Q4')){
                if (scorecardSRQ4.WeightCS__c == null) return '-';
                return scorecardSRQ4.WeightCS__c+'%';
            }
        }
        return '0%';           
    }
    
    public String getWeightQ1Q3Renewals(){
        if(scorecardSRQ1 != null && V2MOMType.equals('Individual Q1/Q2')){
            if (scorecardSRQ1.WeightRenewals__c == null) return '-';
            return scorecardSRQ1.WeightRenewals__c+'%';
        }
        else{
            if(scorecardSRQ3 != null && V2MOMType.equals('Individual Q3/Q4')){
                if (scorecardSRQ3.WeightRenewals__c == null) return '-';
                return scorecardSRQ3.WeightRenewals__c+'%';
            }
        }
        return '0%';           
    }
    
    public String getWeightQ2Q4Renewals(){
        if (scorecardSRQ2 != null && V2MOMType.equals('Individual Q1/Q2')){
            if (scorecardSRQ2.WeightRenewals__c == null) return '-';
            return scorecardSRQ2.WeightRenewals__c+'%';
        }
        else{
            if (scorecardSRQ4 != null && V2MOMType.equals('Individual Q3/Q4')){
                if (scorecardSRQ4.WeightRenewals__c == null) return '-';
                return scorecardSRQ4.WeightRenewals__c+'%';
            }
        }
        return '0%';           
    }  
     
    public String getWeightQ1Q3WMCases(){
        if(scorecardSRQ1 != null && V2MOMType.equals('Individual Q1/Q2')){
            if (scorecardSRQ1.WeightWMCases__c == null) return '-';
            return scorecardSRQ1.WeightWMCases__c+'%';
        }
        else{
            if(scorecardSRQ3 != null && V2MOMType.equals('Individual Q3/Q4')){
                if (scorecardSRQ3.WeightWMCases__c == null) return '-';
                return scorecardSRQ3.WeightWMCases__c+'%';
            }
        }
        return '0%';           
    }
    
    public String getWeightQ2Q4WMCases(){
        if (scorecardSRQ2 != null && V2MOMType.equals('Individual Q1/Q2')){
            if (scorecardSRQ2.WeightWMCases__c == null) return '-';
            return scorecardSRQ2.WeightWMCases__c+'%';
        }
        else{
            if (scorecardSRQ4 != null && V2MOMType.equals('Individual Q3/Q4')){
                if (scorecardSRQ4.WeightWMCases__c == null) return '-';
                return scorecardSRQ4.WeightWMCases__c+'%';
            }
        }
        return '0%';           
    }
    
    public String getWeightQ1Q3WMSMES(){       
        if(scorecardSRQ1 != null && V2MOMType.equals('Individual Q1/Q2')){
            if (scorecardSRQ1.WeightWMSMES__c == null) return '-';
            return scorecardSRQ1.WeightWMSMES__c+'%';
        }
        else{
            if(scorecardSRQ3 != null && V2MOMType.equals('Individual Q3/Q4')){
                if (scorecardSRQ3.WeightWMSMES__c == null) return '-';
                return scorecardSRQ3.WeightWMSMES__c+'%';
            }
        }       
        return '0%';           
    } 
      
    public String getWeightQ2Q4WMSMES(){       
        if (scorecardSRQ2 != null && V2MOMType.equals('Individual Q1/Q2')){
            if (scorecardSRQ2.WeightWMSMES__c == null) return '-';
            return scorecardSRQ2.WeightWMSMES__c+'%';
        }
        else{
            if (scorecardSRQ4 != null && V2MOMType.equals('Individual Q3/Q4')){
                if (scorecardSRQ4.WeightWMSMES__c == null) return '-';
                return scorecardSRQ4.WeightWMSMES__c+'%';
            }
        }       
        return '0%';           
    }
        
    public String getWeightQ1Q3WMHC(){        
        if(scorecardSRQ1 != null && V2MOMType.equals('Individual Q1/Q2')){
            if (scorecardSRQ1.WeightWMHC__c == null) return '-';
            return scorecardSRQ1.WeightWMHC__c+'%';
        }
        else{
            if(scorecardSRQ3 != null && V2MOMType.equals('Individual Q3/Q4')){
                if (scorecardSRQ3.WeightWMHC__c == null) return '-';
                return scorecardSRQ3.WeightWMHC__c+'%';
            }
        }       
        return '0%';           
    } 
     
    public String getWeightQ2Q4WMHC(){        
        if (scorecardSRQ2 != null && V2MOMType.equals('Individual Q1/Q2')){
            if (scorecardSRQ2.WeightWMHC__c == null) return '-';
            return scorecardSRQ2.WeightWMHC__c+'%';
        }
        else{
            if (scorecardSRQ4 != null && V2MOMType.equals('Individual Q3/Q4')){
                if (scorecardSRQ4.WeightWMHC__c == null) return '-';
                return scorecardSRQ4.WeightWMHC__c+'%';
            }
        }       
        return '0%';           
    } 
       
    public String getWeightQ1Q3WMPA(){    
        if(scorecardSRQ1 != null && V2MOMType.equals('Individual Q1/Q2')){
            if (scorecardSRQ1.WeightWMPA__c == null) return '-';
            return scorecardSRQ1.WeightWMPA__c+'%';
        }
        else{
            if(scorecardSRQ3 != null && V2MOMType.equals('Individual Q3/Q4')){
                if (scorecardSRQ3.WeightWMPA__c == null) return '-';
                return scorecardSRQ3.WeightWMPA__c+'%';
            }
        }       
        return '0%';           
    }  
     
    public String getWeightQ2Q4WMPA(){        
        if (scorecardSRQ2 != null && V2MOMType.equals('Individual Q1/Q2')){
            if (scorecardSRQ2.WeightWMPA__c == null) return '-';
            return scorecardSRQ2.WeightWMPA__c+'%';
        }
        else{
            if (scorecardSRQ4 != null && V2MOMType.equals('Individual Q3/Q4')){
                if (scorecardSRQ4.WeightWMPA__c == null) return '-';
                return scorecardSRQ4.WeightWMPA__c+'%';
            }
        }       
        return '0%';           
    } 
           
    public String getWeightQ1Q3SI(){  
        if(scorecardSRQ1 != null && V2MOMType.equals('Individual Q1/Q2')){
            if (scorecardSRQ1.WeightSI__c == null) return '-';
            return scorecardSRQ1.WeightSI__c+'%';
        }
        else{
            if(scorecardSRQ3 != null && V2MOMType.equals('Individual Q3/Q4')){
                if (scorecardSRQ3.WeightSI__c == null) return '-';
                return scorecardSRQ3.WeightSI__c+'%';
            }
        }      
        return '0%';           
    }  
     
    public String getWeightQ2Q4SI(){      
        if (scorecardSRQ2 != null && V2MOMType.equals('Individual Q1/Q2')){
            if (scorecardSRQ2.WeightSI__c == null) return '-';
            return scorecardSRQ2.WeightSI__c+'%';
        }
        else{
            if (scorecardSRQ4 != null && V2MOMType.equals('Individual Q3/Q4')){
                if (scorecardSRQ4.WeightSI__c == null) return '-';
                return scorecardSRQ4.WeightSI__c+'%';
            }
        }       
        return '0%';           
    }    
// ------------------------------- FUNCTIONS FOR METRIC AVGS -----------
     // Rating Q1/Q2 or Q3/Q4 of Customer Satisfaction
     public Double getAvgRatingCSAT(){
         double avgCSAT = 0;
         if (V2MOMType != null && V2MOMType.equals('Individual Q1/Q2')) {
             if (scorecardSRQ1 != null)
                if((scorecardSRQ1.AdjustedRatingCS__c != null) && (scorecardSRQ1.WeightCS__c != null))
                {
                    avgCSAT = Integer.valueOf(scorecardSRQ1.AdjustedRatingCS__c) * scorecardSRQ1.WeightCS__c/100;
                   
                   
                }
             if (scorecardSRQ2 != null) 
                if((scorecardSRQ2.AdjustedRatingCS__c != null) && (scorecardSRQ2.WeightCS__c != null))
                    avgCSAT = avgCSAT + Integer.valueOf(scorecardSRQ2.AdjustedRatingCS__c) * scorecardSRQ2.WeightCS__c/100;
         } 
         else{
             if (V2MOMType != null && V2MOMType.equals('Individual Q3/Q4')) {
                 if (scorecardSRQ3 != null)
                    if((scorecardSRQ3.AdjustedRatingCS__c != null) && (scorecardSRQ3.WeightCS__c != null))
                        avgCSAT = avgCSAT + Integer.valueOf(scorecardSRQ3.AdjustedRatingCS__c) * scorecardSRQ3.WeightCS__c/100;
                 if (scorecardSRQ4 != null)
                    if((scorecardSRQ4.AdjustedRatingCS__c != null) && (scorecardSRQ4.WeightCS__c != null))
                        avgCSAT = avgCSAT + Integer.valueOf(scorecardSRQ4.AdjustedRatingCS__c) * scorecardSRQ4.WeightCS__c/100;
             }
         }        
         return avgCSAT/2;
     }  
         
     // Rating Q1/Q2 or Q3/Q4 of Renewals
     public Double getAvgRatingRenewals(){
         double avgRenewals = 0;
         if (V2MOMType != null && V2MOMType.equals('Individual Q1/Q2')) {
             if (scorecardSRQ1 != null) 
                if((scorecardSRQ1.AdjustedRatingRenewals__c != null) && (scorecardSRQ1.WeightRenewals__c != null))
                    avgRenewals = Integer.valueOf(scorecardSRQ1.AdjustedRatingRenewals__c) * scorecardSRQ1.WeightRenewals__c/100;
             if (scorecardSRQ2 != null) 
                if((scorecardSRQ2.AdjustedRatingRenewals__c != null) && (scorecardSRQ2.WeightRenewals__c != null))
                    avgRenewals = avgRenewals + Integer.valueOf(scorecardSRQ2.AdjustedRatingRenewals__c) * scorecardSRQ2.WeightRenewals__c/100;
         }
         else{
             if (V2MOMType != null && V2MOMType.equals('Individual Q3/Q4')) {
                 if (scorecardSRQ3 != null)
                    if((scorecardSRQ3.AdjustedRatingRenewals__c != null) && (scorecardSRQ3.WeightRenewals__c != null))
                        avgRenewals = avgRenewals + Integer.valueOf(scorecardSRQ3.AdjustedRatingRenewals__c) * scorecardSRQ3.WeightRenewals__c/100;
                 if (scorecardSRQ4 != null)
                    if((scorecardSRQ4.AdjustedRatingRenewals__c != null) && (scorecardSRQ4.WeightRenewals__c != null))
                        avgRenewals = avgRenewals + Integer.valueOf(scorecardSRQ4.AdjustedRatingRenewals__c) * scorecardSRQ4.WeightRenewals__c/100;
             }
         }
         return avgRenewals/2;
     }
     
    // Rating Q1/Q2 or Q3/Q4 of Workload Management Cases
    public Double getAvgRatingWMCases(){
        double avgWMCases = 0;
        if (V2MOMType != null && V2MOMType.equals('Individual Q1/Q2')) {
            if (scorecardSRQ1 != null) 
                if((scorecardSRQ1.AdjustedRatingWMCases__c != null) && (scorecardSRQ1.WeightWMCases__c != null))
                    avgWMCases = Integer.valueOf(scorecardSRQ1.AdjustedRatingWMCases__c) * scorecardSRQ1.WeightWMCases__c/100;
            if (scorecardSRQ2 != null) 
                if((scorecardSRQ2.AdjustedRatingWMCases__c != null) && (scorecardSRQ2.WeightWMCases__c != null))
                    avgWMCases = avgWMCases + Integer.valueOf(scorecardSRQ2.AdjustedRatingWMCases__c) * scorecardSRQ2.WeightWMCases__c/100;
        }
        else {
            if (V2MOMType != null && V2MOMType.equals('Individual Q3/Q4')) {
                if (scorecardSRQ3 != null)
                    if((scorecardSRQ3.AdjustedRatingWMCases__c != null) && (scorecardSRQ3.WeightWMCases__c != null))
                        avgWMCases = avgWMCases + Integer.valueOf(scorecardSRQ3.AdjustedRatingWMCases__c) * scorecardSRQ3.WeightWMCases__c/100;
                if (scorecardSRQ4 != null)
                    if((scorecardSRQ4.AdjustedRatingWMCases__c != null) && (scorecardSRQ4.WeightWMCases__c != null))
                        avgWMCases = avgWMCases + Integer.valueOf(scorecardSRQ4.AdjustedRatingWMCases__c) * scorecardSRQ4.WeightWMCases__c/100;
            }
        }   
        return avgWMCases/2;
    }
    
    // Rating Q1/Q2 or Q3/Q4 of Workload Management SME + Solutions
    public Double getAvgRatingWMSMES(){
        double avgWMSMES = 0;
        if (V2MOMType != null && V2MOMType.equals('Individual Q1/Q2')) {
            if (scorecardSRQ1 != null) 
                if((scorecardSRQ1.AdjustedRatingWMSMES__c != null) && (scorecardSRQ1.WeightWMSMES__c != null))
                    avgWMSMES = Integer.valueOf(scorecardSRQ1.AdjustedRatingWMSMES__c) * scorecardSRQ1.WeightWMSMES__c/100;
            if (scorecardSRQ2 != null) 
                if((scorecardSRQ2.AdjustedRatingWMSMES__c != null) && (scorecardSRQ2.WeightWMSMES__c != null))
                    avgWMSMES = avgWMSMES + Integer.valueOf(scorecardSRQ2.AdjustedRatingWMSMES__c) * scorecardSRQ2.WeightWMSMES__c/100;
        }
        else {
            if (V2MOMType != null && V2MOMType.equals('Individual Q3/Q4')) {
                if (scorecardSRQ3 != null)
                    if((scorecardSRQ3.AdjustedRatingWMSMES__c != null) && (scorecardSRQ3.WeightWMSMES__c != null))
                        avgWMSMES = avgWMSMES + Integer.valueOf(scorecardSRQ3.AdjustedRatingWMSMES__c) * scorecardSRQ3.WeightWMSMES__c/100;
                if (scorecardSRQ4 != null)
                    if((scorecardSRQ4.AdjustedRatingWMSMES__c != null) && (scorecardSRQ4.WeightWMSMES__c != null))
                        avgWMSMES = avgWMSMES + Integer.valueOf(scorecardSRQ4.AdjustedRatingWMSMES__c) * scorecardSRQ4.WeightWMSMES__c/100;
            }
        }   
        return avgWMSMES/2;
    }   
    
    // Rating Q1/Q2 or Q3/Q4 of Workload Management Health Checks
    public Double getAvgRatingWMHC(){
        double avgWMHC = 0;
        if (V2MOMType != null && V2MOMType.equals('Individual Q1/Q2')) {
            if (scorecardSRQ1 != null) 
                if((scorecardSRQ1.AdjustedRatingWMHC__c != null) && (scorecardSRQ1.WeightWMHC__c != null))
                    avgWMHC = Integer.valueOf(scorecardSRQ1.AdjustedRatingWMHC__c) * scorecardSRQ1.WeightWMHC__c/100;
            if (scorecardSRQ2 != null) 
                if((scorecardSRQ2.AdjustedRatingWMHC__c != null) && (scorecardSRQ2.WeightWMHC__c != null))
                    avgWMHC = avgWMHC + Integer.valueOf(scorecardSRQ2.AdjustedRatingWMHC__c) * scorecardSRQ2.WeightWMHC__c/100;
        }
        else {
            if (V2MOMType != null && V2MOMType.equals('Individual Q3/Q4')) {
                if (scorecardSRQ3 != null)
                    if((scorecardSRQ3.AdjustedRatingWMHC__c != null) && (scorecardSRQ3.WeightWMHC__c != null))
                        avgWMHC = avgWMHC + Integer.valueOf(scorecardSRQ3.AdjustedRatingWMHC__c) * scorecardSRQ3.WeightWMHC__c/100;
                if (scorecardSRQ4 != null)
                    if((scorecardSRQ4.AdjustedRatingWMHC__c != null) && (scorecardSRQ4.WeightWMHC__c != null))
                        avgWMHC = avgWMHC + Integer.valueOf(scorecardSRQ4.AdjustedRatingWMHC__c) * scorecardSRQ4.WeightWMHC__c/100;
            }
        }   
        return avgWMHC/2;
    }
    
    // Rating Q1/Q2 or Q3/Q4 of Workload Management Procedure Adherence
    public Double getAvgRatingWMPA(){
        double avgWMPA = 0;
        if (V2MOMType != null && V2MOMType.equals('Individual Q1/Q2')) {
            if (scorecardSRQ1 != null) 
                if((scorecardSRQ1.AdjustedRatingWMPA__c != null) && (scorecardSRQ1.WeightWMPA__c != null))
                    avgWMPA = Integer.valueOf(scorecardSRQ1.AdjustedRatingWMPA__c) * scorecardSRQ1.WeightWMPA__c/100;
            if (scorecardSRQ2 != null) 
                if((scorecardSRQ2.AdjustedRatingWMPA__c != null) && (scorecardSRQ2.WeightWMPA__c != null))
                    avgWMPA = avgWMPA + Integer.valueOf(scorecardSRQ2.AdjustedRatingWMPA__c) * scorecardSRQ2.WeightWMPA__c/100;
        }
        else {
            if (V2MOMType != null && V2MOMType.equals('Individual Q3/Q4')) {
                if (scorecardSRQ3 != null)
                    if((scorecardSRQ3.AdjustedRatingWMPA__c != null) && (scorecardSRQ3.WeightWMPA__c != null))
                        avgWMPA = avgWMPA + Integer.valueOf(scorecardSRQ3.AdjustedRatingWMPA__c) * scorecardSRQ3.WeightWMPA__c/100;
                if (scorecardSRQ4 != null)
                    if((scorecardSRQ4.AdjustedRatingWMPA__c != null) && (scorecardSRQ4.WeightWMPA__c != null))
                        avgWMPA = avgWMPA + Integer.valueOf(scorecardSRQ4.AdjustedRatingWMPA__c) * scorecardSRQ4.WeightWMPA__c/100;
            }
        }   
        return avgWMPA/2;
    }   
        
    // Rating Q1/Q2 or Q3/Q4 of Support Initiatives
    public Double getAvgRatingSI(){
         double avgSI = 0;
         if (V2MOMType != null && V2MOMType.equals('Individual Q1/Q2')) {
             if (scorecardSRQ1 != null) 
                if((scorecardSRQ1.AdjustedRatingSI__c != null) && (scorecardSRQ1.WeightSI__c != null))
                    avgSI = Integer.valueOf(scorecardSRQ1.AdjustedRatingSI__c) * scorecardSRQ1.WeightSI__c/100;
             if (scorecardSRQ2 != null) 
                if((scorecardSRQ2.AdjustedRatingSI__c != null) && (scorecardSRQ2.WeightSI__c != null))
                    avgSI = avgSI + Integer.valueOf(scorecardSRQ2.AdjustedRatingSI__c) * scorecardSRQ2.WeightSI__c/100;
         } 
         else{
             if (V2MOMType != null && V2MOMType.equals('Individual Q3/Q4')) {
                 if (scorecardSRQ3 != null)
                    if((scorecardSRQ3.AdjustedRatingSI__c != null) && (scorecardSRQ3.WeightSI__c != null))
                        avgSI = avgSI + Integer.valueOf(scorecardSRQ3.AdjustedRatingSI__c) * scorecardSRQ3.WeightSI__c/100;
                 if (scorecardSRQ4 != null)
                    if((scorecardSRQ4.AdjustedRatingSI__c != null) && (scorecardSRQ4.WeightSI__c != null))
                        avgSI = avgSI + Integer.valueOf(scorecardSRQ4.AdjustedRatingSI__c) * scorecardSRQ4.WeightSI__c/100;
             }
         }    
         return avgSI/2;
     }
     
     // Rating for Support Metrics     
     public Double getAvgRatingSupportMetrics(){
         double avgRatingSupportMetrics = 0;
             if (scorecardSRQ1 != null){
                if((scorecardSRQ1.RatingCustomerSatisfaction__c != null) && (scorecardSRQ1.WeightCustomerSatisfaction__c != null) && (scorecardSRQ1.RatingCustomerSatisfaction__c != -1))
                    avgRatingSupportMetrics = avgRatingSupportMetrics + scorecardSRQ1.RatingCustomerSatisfaction__c * scorecardSRQ1.WeightCustomerSatisfaction__c/100;
                if((scorecardSRQ1.WMCCPRating__c != null) && (scorecardSRQ1.WMCCPWeight__c != null) && (scorecardSRQ1.WMCCPRating__c != -1))
                    avgRatingSupportMetrics = avgRatingSupportMetrics + scorecardSRQ1.WMCCPRating__c * scorecardSRQ1.WMCCPWeight__c/100;
                if((scorecardSRQ1.WMCAARating__c != null) && (scorecardSRQ1.WMCAAWeight__c != null) && (scorecardSRQ1.WMCAARating__c != -1))
                    avgRatingSupportMetrics = avgRatingSupportMetrics + scorecardSRQ1.WMCAARating__c * scorecardSRQ1.WMCAAWeight__c/100;
             }else{ 
                if (scorecardSRQ3 != null){
                    if((scorecardSRQ3.RatingCustomerSatisfaction__c != null) && (scorecardSRQ3.WeightCustomerSatisfaction__c != null) && (scorecardSRQ3.RatingCustomerSatisfaction__c != -1))
                        avgRatingSupportMetrics = avgRatingSupportMetrics + scorecardSRQ3.RatingCustomerSatisfaction__c * scorecardSRQ3.WeightCustomerSatisfaction__c/100;
                    if((scorecardSRQ3.WMCCPRating__c != null) && (scorecardSRQ3.WMCCPWeight__c != null) && (scorecardSRQ3.WMCCPRating__c != -1))
                        avgRatingSupportMetrics = avgRatingSupportMetrics + scorecardSRQ3.WMCCPRating__c * scorecardSRQ3.WMCCPWeight__c/100;
                    if((scorecardSRQ3.WMCAARating__c != null) && (scorecardSRQ3.WMCAAWeight__c != null) && (scorecardSRQ3.WMCAARating__c != -1))
                        avgRatingSupportMetrics = avgRatingSupportMetrics + scorecardSRQ3.WMCAARating__c * scorecardSRQ3.WMCAAWeight__c/100;
                }
             }          
         return avgRatingSupportMetrics;
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
            scorecardSupportReviews=[SELECT Id, FiscalQuarter__c,WeightCS__c, WeightRenewals__c, WeightWMCases__c, WeightWMSMES__c,WeightWMHC__c,WeightWMPA__c,WeightSI__c,
				                            AdjustedRatingCS__c,AdjustedRatingRenewals__c, AdjustedRatingWMCases__c, AdjustedRatingWMSMES__c,AdjustedRatingWMHC__c,AdjustedRatingWMPA__c,
				                            AdjustedRatingSI__c,CalculatedRatingCS__c, CalculatedRatingRenewals__c, CalculatedRatingWMCases__c, CalculatedRatingWMSMES__c,CalculatedRatingWMHC__c,
				                            CalculatedRatingWMPA__c,CalculatedRatingSI__c, RatingCustomerSatisfaction__c, WeightCustomerSatisfaction__c,CustomerSatisfactionActual__c,CustomerSatisfactionTarget__c,
				                            WMCCPActual__c, WMCCPWeight__c, WMCCPTarget__c, WMCCPRating__c,WMCAAActual__c, WMCAAWeight__c, WMCAATarget__c, WMCAARating__c,WMSOActual__c,WMSOTarget__c,WMBAActual__c,WMBATarget__c 
               						From ScorecardSupportReview__c  
                   					WHERE PerformanceReview__c =: Id];       
            checkScorecards();
        }
    }
}