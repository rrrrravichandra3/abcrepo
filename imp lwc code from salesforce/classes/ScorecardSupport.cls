/*
 * RelEng Perforce/RCS Header - Do not remove!
 *
 * $Author:  $
 * $Change:  $
 * $DateTime:  $
 * $File:  $
 * $Id:  $
 * $Revision:  $
 * this class will take an account and assign it to a user.
 * @author
*/
public with sharing class ScorecardSupport {
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
    public OverallCSMController csmController;
    public OverallEducationController educationController;
    public OverallSupportController supportController;
    /*
     * Constructor filters data with sharing rules
     */
    public ScorecardSupport(PerformanceReview__c performanceReview){
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
       
       csmController = new OverallCSMController(performanceReview);
       educationController = new OverallEducationController(performanceReview);
       supportController = new OverallSupportController(performanceReview);
    }

    public OverallUtil getOverallUtil(){
        return  util;
    }
    
    public ScorecardSupport(){  
       csmController = new OverallCSMController();  
       educationController = new OverallEducationController();  
       supportController = new OverallSupportController();         
    }
    
    /*
     * Constructor without sharing rules
     * filters data manually
     */
    public ScorecardSupport(PerformanceReview__c performanceReview, boolean filter){
        perfReview = performanceReview;
        List<PerformanceReview__c> pr = [SELECT p.V2MOM__r.V2MOM_Type__c, p.V2MOM__c, p.Name, p.PremierUser__c From PerformanceReview__c p Where id =: performanceReview.Id];
        if (pr.size()> 0 )
            V2MOMType = pr[0].V2MOM__r.V2MOM_Type__c;     
        list<ScorecardSupportReview__c> listScorecard = new list<ScorecardSupportReview__c>();
        listScorecard = [SELECT Id, FiscalQuarter__c,WeightCS__c, WeightRenewals__c, WeightWMCases__c, WeightWMSMES__c,WeightWMHC__c,WeightWMPA__c,WeightSI__c,
                                AdjustedRatingCS__c,AdjustedRatingRenewals__c,AdjustedRatingWMCases__c, AdjustedRatingWMSMES__c,AdjustedRatingWMHC__c,AdjustedRatingWMPA__c,AdjustedRatingSI__c,
                                CalculatedRatingCS__c, CalculatedRatingRenewals__c, CalculatedRatingWMCases__c,CalculatedRatingWMSMES__c,CalculatedRatingWMHC__c,CalculatedRatingWMPA__c,CalculatedRatingSI__c,
                                ForecastAccuracyWeight__c,SalesImpactWeight__c,TimeOnPlatformWeight__c, ForecastAccuracyRating__c,SalesImpactRating__c,TimeOnPlatformRating__c , CSMSalesImpactRating__c,
                                CSMSalesImpactWeight__c,RenewalExcellenceRating__c,RenewalExcellenceWeight__c,OperationalExcellenceRating__c,OperationalExcellenceWeight__c,StrategicInitiativesRating__c,
                            	StrategicInitiativesWeight__c,RatingCustomerSatisfaction__c, WeightCustomerSatisfaction__c,CustomerSatisfactionActual__c,CustomerSatisfactionTarget__c,WMCCPActual__c, 
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
            if (filter){
                scorecardReview.AdjustedRatingCS__c = null;
                scorecardReview.AdjustedRatingRenewals__c = null; 
                scorecardReview.AdjustedRatingWMCases__c = null;
                scorecardReview.AdjustedRatingWMSMES__c = null;
                scorecardReview.AdjustedRatingWMHC__c = null;
                scorecardReview.AdjustedRatingWMPA__c = null;
                scorecardReview.AdjustedRatingSI__c = null;               
                scorecardReview.ForecastAccuracyWeight__c = null;
                scorecardReview.SalesImpactWeight__c = null;
                scorecardReview.TimeOnPlatformWeight__c = null;              
                scorecardReview.ForecastAccuracyRating__c = null;
                scorecardReview.SalesImpactRating__c = null;
                scorecardReview.TimeOnPlatformRating__c = null;           
                //scorecardReview.CsmSalesImpactRating__c = null;
               // scorecardReview.RenewalExcellenceRating__c = null;
               // scorecardReview.StrategicInitiativesRating__c = null;                          	
               //scorecardReview.StrategicInitiativesWeight__c = null;
               //scorecardReview.CsmSalesImpactWeight__c = null;
               //scorecardReview.RenewalExcellenceWeight__c = null;              
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
        checkScorecardsQ1Q2 = !((checkQ1 > 1) || (checkQ2 > 1));
        checkScorecardsQ3Q4 = !((checkQ3 > 1) || (checkQ4 > 1));
        
        csmController = new OverallCSMController(performanceReview, filter);
        educationController = new OverallEducationController(performanceReview, filter);
        supportController = new OverallSupportController(performanceReview, filter);
    }
        // checks if there is no more than one scorecard per quarter
        public boolean checkScorecards(){
            if (V2MOMType == 'Individual Q1/Q2')
                return checkScorecardsQ1Q2;
            return checkScorecardsQ3Q4;
        }      
       //filter
       public void setPerformanceAccessUtil(PerformanceAccessUtil au){
        	accessUtil = au;
        }
    /* 
     * BEGIN FUNCTIONS FOR METRIC DATA ENTRY CHECK *************
     */ 
     
	// checks the data and comments for the education metrics
     public String checkManagerEducationDataEntryRequirements(double sumMethodWeight){
        return educationController.checkManagerEducationDataEntryRequirements(sumMethodWeight);
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
     //checks the entered data for the CSM metrics is not null    
     public String checkManagerCSMDataEntryRequirements(double sumMethodWeight){
     	return csmController.checkManagerCSMDataEntryRequirements(sumMethodWeight);
     }     
     
	// checks the entered data for the support metrics is not null
    public boolean checkManagerSupportDataEntryRequirements(ScorecardSupportReview__c s){      
        return supportController.checkManagerSupportDataEntryRequirements(s);           
    }      
	// checks the entered data for the support metrics sums 100
    public boolean checkWeightSum(ScorecardSupportReview__c s){         
        return supportController.checkWeightSum(s);            
    }
	// checks there are support metric comments entered
    public boolean checkManagerSupportCommentEntryRequirements(){      
           return supportController.checkManagerSupportCommentEntryRequirements();         
    }       
    // checks the data and comments for the new support metrics
     public String checkManagerNewSupportDataEntryRequirements(double sumMethodWeight){    
        return supportController.checkManagerNewSupportDataEntryRequirements(sumMethodWeight);
     }     
   
    /*
     * END FUNCTIONS FOR METRIC DATA ENTRY CHECK *************
     */
	public boolean getIsOld(){		
    	return supportController.getIsOld();
    }
    /*
     * BEGIN FUNCTIONS FOR EDUCATION METRICS *************
     */
     
    public String getRatingSalesImpact(){
        if(perfReview.Status__c == '3rd Party Assessment' && perfReview.PreviousStatus__c == 'Manager Assessment' && perfReview.SecondManager__c == userInfo.getUserId()){
        	return '-';
        }
        return educationController.getRatingSalesImpact();
    }  
     
    public String getWeightSalesImpact(){               
        if(perfReview.Status__c == '3rd Party Assessment' && perfReview.PreviousStatus__c == 'Manager Assessment' && perfReview.SecondManager__c == userInfo.getUserId()){
        	return '-';
        }
        return educationController.getWeightSalesImpact();
    }
    
    public String getRatingTimeOnPlatform(){
        if(perfReview.Status__c == '3rd Party Assessment' && perfReview.PreviousStatus__c == 'Manager Assessment' && perfReview.SecondManager__c == userInfo.getUserId()){
        	return '-';
        }
        return educationController.getRatingTimeOnPlatform();
    }
    
    public String getWeightTimeOnPlatform(){
        if(perfReview.Status__c == '3rd Party Assessment' && perfReview.PreviousStatus__c == 'Manager Assessment' && perfReview.SecondManager__c == userInfo.getUserId()){
        	return '-';
        }
        return educationController.getWeightTimeOnPlatform();
    }
    
    public String getRatingForecastAccuracy(){
        if(perfReview.Status__c == '3rd Party Assessment' && perfReview.PreviousStatus__c == 'Manager Assessment' && perfReview.SecondManager__c == userInfo.getUserId()){
        	return '-';
        }
        return educationController.getRatingForecastAccuracy();
    }
    
    public String getWeightForecastAccuracy(){
        if(perfReview.Status__c == '3rd Party Assessment' && perfReview.PreviousStatus__c == 'Manager Assessment' && perfReview.SecondManager__c == userInfo.getUserId()){
        	return '-';
        }
        return educationController.getWeightForecastAccuracy();
    }
    
	public String getRatingCSMSalesImpact()
	{
		return csmController.getRatingCSMSalesImpact();
	}
		
	public String getRatingRenewalExcellence()
	{
        return csmController.getRatingRenewalExcellence();
	}
		
	public String getRatingOperationalExcellence()
	{
        return csmController.getRatingOperationalExcellence();
	}
		
	public String getRatingStrategicInitiatives()
	{
        return csmController.getRatingStrategicInitiatives();
	}
	
	// NEW WORKLOAD MANAGEMENT TABLES
	public String getRatingWMCCP()
	{		
        return supportController.getRatingWMCCP();
	}
	
	public String getWeightWMCCP(){
        return supportController.getWeightWMCCP();
    }  
     
    public String getRatingWMCAA()
	{		
        return supportController.getRatingWMCAA();
	}
	
	public String getWeightWMCAA(){
        return supportController.getWeightWMCAA();
    } 
     
    public String getRatingCustomerSatisfaction()
	{	
        return supportController.getRatingCustomerSatisfaction();
	}
	
	public String getWeightCustomerSatisfaction(){
        return supportController.getWeightCustomerSatisfaction();
    }   
    //  END
   
	 public String getWeightCSMSalesImpact(){
        return csmController.getWeightCSMSalesImpact();
    } 
      
    public String getWeightRenewalExcellence(){
        return csmController.getWeightRenewalExcellence();
    } 
      
    public String getWeightOperationalExcellence(){
        return csmController.getWeightOperationalExcellence();
    }
    
    public String getWeightStrategicInitiatives(){
        return csmController.getWeightStrategicInitiatives();
    }   
    /*
     * END FUNCTIONS FOR EDUCATION METRICS *************
     * BEGIN FUNCTIONS FOR SUPPORT METRICS *************
     */
     
    public String getAvgQ1Q3(){      
        return supportController.getAvgQ1Q3();           
    }	
    
	public String getCustomerSatisfactionRatingQ1_Q3(){        
        return supportController.getCustomerSatisfactionRatingQ1_Q3();           
    } 
      
    public String getCustomerSatisfactionRatingQ2_Q4(){     
        return supportController.getCustomerSatisfactionRatingQ2_Q4();         
    }	
    
    public String getAvgQ2Q4(){
        return supportController.getAvgQ2Q4();
    }
    
    public String getAvgQ1Q3Renewals(){
        return supportController.getAvgQ1Q3Renewals();       
    }
    
    public String getAvgQ2Q4Renewals(){
        return supportController.getAvgQ2Q4Renewals();        
    }
    
    public String getAvgQ1Q3WMCases(){
        return supportController.getAvgQ1Q3WMCases();    
    }
    
    public String getAvgQ2Q4WMCases(){
        return supportController.getAvgQ2Q4WMCases();   
    }
    
    public String getAvgQ1Q3WMSMES(){
        return supportController.getAvgQ1Q3WMSMES();     
    }
    
    public String getAvgQ2Q4WMSMES(){
        return supportController.getAvgQ2Q4WMSMES();      
    }
    
    public String getAvgQ1Q3WMHC(){
        return supportController.getAvgQ1Q3WMHC();         
    }
    
    public String getAvgQ2Q4WMHC(){
        return supportController.getAvgQ2Q4WMHC();       
    }
    
    public String getAvgQ1Q3WMPA(){
        return supportController.getAvgQ1Q3WMPA();    
    }
    
    public String getAvgQ2Q4WMPA(){
        return supportController.getAvgQ2Q4WMPA();    
    }
    
    public String getAvgQ1Q3SI(){
       return supportController.getAvgQ1Q3SI();    
    }
    
    public String getAvgQ2Q4SI(){
        return supportController.getAvgQ2Q4SI();      
    }
    
    public String getWeightQ1Q3(){
        return supportController.getWeightQ1Q3();  
    }
    
    public String getWeightQ2Q4(){
        return supportController.getWeightQ2Q4();           
    }
    
    public String getWeightQ1Q3Renewals(){
        return supportController.getWeightQ1Q3Renewals();          
    }
    
    public String getWeightQ2Q4Renewals(){
        return supportController.getWeightQ2Q4Renewals();       
    } 
      
    public String getWeightQ1Q3WMCases(){
        return supportController.getWeightQ1Q3WMCases();   
    }
    
    public String getWeightQ2Q4WMCases(){
        return supportController.getWeightQ2Q4WMCases();           
    }
    
    public String getWeightQ1Q3WMSMES(){       
        return supportController.getWeightQ1Q3WMSMES();        
    }
       
    public String getWeightQ2Q4WMSMES(){       
        return supportController.getWeightQ2Q4WMSMES();     
    }
        
    public String getWeightQ1Q3WMHC(){        
        return supportController.getWeightQ1Q3WMHC();          
    }  
    
    public String getWeightQ2Q4WMHC(){        
        return supportController.getWeightQ2Q4WMHC();          
    }
        
    public String getWeightQ1Q3WMPA(){    
        return supportController.getWeightQ1Q3WMPA();   
    }   
    
    public String getWeightQ2Q4WMPA(){        
        return supportController.getWeightQ2Q4WMPA();          
    }
            
    public String getWeightQ1Q3SI(){  
        return supportController.getWeightQ1Q3SI();       
    } 
      
    public String getWeightQ2Q4SI(){      
        return supportController.getWeightQ2Q4SI();          
    }  
      
// ------------------------------- FUNCTIONS FOR METRIC AVGS -----------
     // Rating Q1/Q2 or Q3/Q4 of Customer Satisfaction
     public Double getAvgRatingCSAT(){
         return supportController.getAvgRatingCSAT();
     }  
         
     // Rating Q1/Q2 or Q3/Q4 of Renewals
     public Double getAvgRatingRenewals(){
         return supportController.getAvgRatingRenewals();
     }
     
    // Rating Q1/Q2 or Q3/Q4 of Workload Management Cases
    public Double getAvgRatingWMCases(){
        return supportController.getAvgRatingWMCases();
    }
    
    // Rating Q1/Q2 or Q3/Q4 of Workload Management SME + Solutions
    public Double getAvgRatingWMSMES(){
        return supportController.getAvgRatingWMSMES();
    }  
     
    // Rating Q1/Q2 or Q3/Q4 of Workload Management Health Checks
    public Double getAvgRatingWMHC(){
        return supportController.getAvgRatingWMHC();
    }
    
    // Rating Q1/Q2 or Q3/Q4 of Workload Management Procedure Adherence
    public Double getAvgRatingWMPA(){
        return supportController.getAvgRatingWMPA();
    }   
        
    // Rating Q1/Q2 or Q3/Q4 of Support Initiatives
    public Double getAvgRatingSI(){
         return supportController.getAvgRatingSI();
     }
     
     // Rating for Education Metrics
     public Double getAvgRatingEducationMetrics(){
         return educationController.getAvgRatingEducationMetrics();
     } 
       
     // Rating for CSM Metrics
     public Double getAvgRatingCSMMetrics(){
         return csmController.getAvgRatingCSMMetrics();
     }
            
     // Rating for Support Metrics     
     public Double getAvgRatingSupportMetrics(){
         return supportController.getAvgRatingSupportMetrics();
     }  
       
    /*
     * END FUNCTIONS FOR SUPPORT METRICS *************
     */  
      
    public String getFirstColumn(){
        if(V2MOMType != null && V2MOMType.equals('Individual Q1/Q2'))
            return Label.ScoreCards_Q1_Label;
        else if(V2MOMType != null && V2MOMType.equals('Individual Q3/Q4'))
            return Label.ScoreCards_Q3_Label;

        return '';
    }
    
    public String getSecondColumn(){
        if(V2MOMType != null && V2MOMType.equals('Individual Q1/Q2'))
            return Label.ScoreCards_Q2_Label;
        else if(V2MOMType != null && V2MOMType.equals('Individual Q3/Q4'))
            return Label.ScoreCards_Q4_Label;
        return '';
    }
    
    public String getScorecardType(){
        return Label.Customer_Satisfaction_label;
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
				                            CalculatedRatingWMPA__c,CalculatedRatingSI__c,ForecastAccuracyWeight__c,SalesImpactWeight__c,TimeOnPlatformWeight__c,ForecastAccuracyRating__c,SalesImpactRating__c,
				                            TimeOnPlatformRating__c,CSMSalesImpactRating__c,CSMSalesImpactWeight__c,RenewalExcellenceRating__c,RenewalExcellenceWeight__c,OperationalExcellenceRating__c,OperationalExcellenceWeight__c,
				                            StrategicInitiativesRating__c,StrategicInitiativesWeight__c,RatingCustomerSatisfaction__c, WeightCustomerSatisfaction__c,CustomerSatisfactionActual__c,CustomerSatisfactionTarget__c,
				                            WMCCPActual__c, WMCCPWeight__c, WMCCPTarget__c, WMCCPRating__c,WMCAAActual__c, WMCAAWeight__c, WMCAATarget__c, WMCAARating__c,WMSOActual__c,WMSOTarget__c,WMBAActual__c,WMBATarget__c 
               						From ScorecardSupportReview__c  
                   					WHERE PerformanceReview__c =: Id];       
            checkScorecards();
        }
    }
}