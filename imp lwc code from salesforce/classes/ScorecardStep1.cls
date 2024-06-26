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

public class ScorecardStep1 {
	
	List<ScorecardSupportReview__c> scorecardSupportReviews;
    ScorecardSupportReview__c scorecardQ1;
    ScorecardSupportReview__c scorecardQ2;
    ScorecardSupportReview__c scorecardQ3;
    ScorecardSupportReview__c scorecardQ4;
    PerformanceReview__c performanceReview;
    //Not sure why doesn't works without this local variables in setters.
    Long adjustedRatingQ1 = 0;
    Long adjustedRatingQ2 = 0;
    Long adjustedRatingQ3 = 0;
    Long adjustedRatingQ4 = 0;
    String id;
	PerformanceAccessUtil accessUtil;    
	
	
	// constructor without filtering any value
    public ScorecardStep1(List<ScorecardSupportReview__c> scorecardReview, PerformanceReview__c pR )
    {
        scorecardSupportReviews = scorecardReview;
        performanceReview = pR;

        scorecardQ1 =  getQuarter('Q1');
        scorecardQ2 =  getQuarter('Q2');
        scorecardQ3 =  getQuarter('Q3');
        scorecardQ4 =  getQuarter('Q4');
    }

    // constructor filtering values according to filter condition
    public ScorecardStep1(List<ScorecardSupportReview__c> scorecardReview, PerformanceReview__c pR, boolean filter)
    {
        scorecardSupportReviews = scorecardReview;
        performanceReview = pR;

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
	
	public void setPerformanceAccessUtil(PerformanceAccessUtil au){
        	accessUtil = au;
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
                
        	}
        	return s;
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
        
        
        public String getCustomerSatisfactionRating(){
            if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
					return '-';
			}
            if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
            {
            	return '-';
            }
        	return V2MOM_Util.getCustomerSatisfactionRating(scorecardQ1,scorecardQ2,scorecardQ3,scorecardQ4);
        }
        
         public String getCustomerSatisfactionWeight(){
         	if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
					return '-';
			}
            if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
            {
            	return '-';
            }
        	return V2MOM_Util.getCustomerSatisfactionWeight(scorecardQ1,scorecardQ2,scorecardQ3,scorecardQ4);	
        }
        
        public String getWMCCPRating(){
        	if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
					return '-';
			}
            if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
            {
            	return '-';
            }
        	return V2MOM_Util.getWMCCPRating(scorecardQ1,scorecardQ2,scorecardQ3,scorecardQ4);
        }
        
         public String getWMCCPWeight(){
         	if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
					return '-';
			}
            if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
            {
            	return '-';
            }
        	return V2MOM_Util.getWMCCPWeight(scorecardQ1,scorecardQ2,scorecardQ3,scorecardQ4);	
        }
        
        public String getWMCAARating(){
        	if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
					return '-';
			}
            if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
            {
            	return '-';
            }
        	return V2MOM_Util.getWMCAARating(scorecardQ1,scorecardQ2,scorecardQ3,scorecardQ4);
        }
        
         public String getWMCAAWeight(){
         	if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
					return '-';
			}
            if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
            {
            	return '-';
            }
        	return V2MOM_Util.getWMCAAWeight(scorecardQ1,scorecardQ2,scorecardQ3,scorecardQ4);	
        }
        
        public String getSalesImpactRating(){
        	if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
					return '-';
			}
            if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
            {
            	return '-';
            }
        	return V2MOM_Util.getSalesImpactRating(scorecardQ1,scorecardQ2,scorecardQ3,scorecardQ4);
        }
        
         public String getSalesImpactWeight(){
         	if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
					return '-';
			}
            if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
            {
            	return '-';
            }
        	return V2MOM_Util.getSalesImpactWeight(scorecardQ1,scorecardQ2,scorecardQ3,scorecardQ4);	
        }
        
         public String getTimeOnPlatformRating(){
         	if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
					return '-';
			}
            if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
            {
            	return '-';
            }
        	return V2MOM_Util.getTimeOnPlatformRating(scorecardQ1,scorecardQ2,scorecardQ3,scorecardQ4);	
        }
        
        public String getTimeOnPlatformWeight(){ 
        	if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
					return '-';
			}
            if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
            {
            	return '-';
            }
        	return V2MOM_Util.getTimeOnPlatformWeight(scorecardQ1,scorecardQ2,scorecardQ3,scorecardQ4);
        }
        
        public String getForecastAccuracyRating(){
        	if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
					return '-';
			}
            if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
            {
            	return '-';
            }
        	return V2MOM_Util.getForecastAccuracyRating(scorecardQ1,scorecardQ2,scorecardQ3,scorecardQ4);
        }
        
        public String getForecastAccuracyWeight(){
        	if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
					return '-';
			}
            if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
            {
            	return '-';
            }
        	return V2MOM_Util.getForecastAccuracyWeight(scorecardQ1,scorecardQ2,scorecardQ3,scorecardQ4);
    	}   
    		
    	public String getCSMSalesImpactRating(){
    		if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
					return '-';
			}
            if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
            {
            	return '-';
            }
        	return V2MOM_Util.getCSMSalesImpactRating(scorecardQ1,scorecardQ2,scorecardQ3,scorecardQ4);
        } 
               
         public String getCSMSalesImpactWeight(){
         	if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
					return '-';
			}
            if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
            {
            	return '-';
            }
        	return V2MOM_Util.getCSMSalesImpactWeight(scorecardQ1,scorecardQ2,scorecardQ3,scorecardQ4);	
        }        
        public String getRenewalExcellenceRating(){
        	if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
					return '-';
			}
            if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
            {
            	return '-';
            }
        	return V2MOM_Util.getRenewalExcellenceRating(scorecardQ1,scorecardQ2,scorecardQ3,scorecardQ4);
        }     
           
        public String getRenewalExcellenceWeight(){
        	if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
					return '-';
			}
            if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
            {
            	return '-';
            }
        	return V2MOM_Util.getRenewalExcellenceWeight(scorecardQ1,scorecardQ2,scorecardQ3,scorecardQ4);
    	}   	
    	
    	public String getOperationalExcellenceRating(){
    		if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
					return '-';
			}
            if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
            {
            	return '-';
            }
        	return V2MOM_Util.getOperationalExcellenceRating(scorecardQ1,scorecardQ2,scorecardQ3,scorecardQ4);
        }  
             
        public String getOperationalExcellenceWeight(){
        	if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
					return '-';
			}
            if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
            {
            	return '-';
            }
        	return V2MOM_Util.getOperationalExcellenceWeight(scorecardQ1,scorecardQ2,scorecardQ3,scorecardQ4);
    	}   
    	
    	public String getStrategicInitiativesRating(){
    		if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
					return '-';
			}
            if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
            {
            	return '-';
            }
        	return V2MOM_Util.getStrategicInitiativesRating(scorecardQ1,scorecardQ2,scorecardQ3,scorecardQ4);
        }  
             
        public String getStrategicInitiativesWeight(){
        	if(!accessUtil.showRatingAndWeightIn3rdPartyAssmnt()){
					return '-';
			}
            if ((!accessUtil.getIsSysAdminProfile()) && ((!accessUtil.getIsMngrInAssmnt() && ((!accessUtil.getIsEmpl()) && !((accessUtil.getStatusRO1() || accessUtil.getStatusRO2()) && accessUtil.getIsMngr2ndMngrOrPCOMM()))) || accessUtil.getStatusRO3() || (accessUtil.getIsEmpl() && !accessUtil.getStatusRO2())))
            {
            	return '-';
            }
        	return V2MOM_Util.getStrategicInitiativesWeight(scorecardQ1,scorecardQ2,scorecardQ3,scorecardQ4);
    	}   
    		
    	public boolean getIsOldWorkloadManagement(){
    		if(performanceReview.V2MOM__r.V2MOM_Type__c == 'Individual Q1/Q2'){
    			if(scorecardQ1 != null && scorecardQ1.WMCCPActual__c == null && scorecardQ1.WMCCPTarget__c == null
    				&& scorecardQ2 != null && scorecardQ2.WMCCPActual__c == null && scorecardQ2.WMCCPTarget__c == null){
    				return true;
    			}
    		}
    		else{
    			if(performanceReview.V2MOM__r.V2MOM_Type__c == 'Individual Q3/Q4'){
					if((scorecardQ3 != null && scorecardQ3.WMCCPActual__c == null && scorecardQ3.WMCCPTarget__c == null
	        	   && scorecardQ4 != null && scorecardQ4.WMCCPActual__c == null && scorecardQ4.WMCCPTarget__c == null)){	
						return true;
					}	
    			}
    		}
    		return false;
    	}
    	
    	public boolean getIsOld(){
    		if(performanceReview.V2MOM__r.V2MOM_Type__c == 'Individual Q1/Q2'){
	        	if(scorecardQ1 != null && scorecardQ1.CustomerSatisfactionActual__c == null && scorecardQ1.CustomerSatisfactionTarget__c == null
	        	   && scorecardQ2 != null && scorecardQ2.CustomerSatisfactionActual__c == null && scorecardQ2.CustomerSatisfactionTarget__c == null){	        		
	        			return true;
	        	}
    		}
    		else{
    			if(performanceReview.V2MOM__r.V2MOM_Type__c == 'Individual Q3/Q4'){
					if((scorecardQ3 != null && scorecardQ3.CustomerSatisfactionActual__c == null && scorecardQ3.CustomerSatisfactionTarget__c == null
	        	   && scorecardQ4 != null && scorecardQ4.CustomerSatisfactionActual__c == null && scorecardQ4.CustomerSatisfactionTarget__c == null)){	
						return true;
					}	
    			}
    		}
        	return false;
        }   
	
    
}