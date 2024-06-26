public class DJC_QuarterClaimManager extends DJC_ClaimManager{

	private Date hireDate;
	private static final Decimal ZERO_BALANCE = 0;

	public DJC_QuarterClaimManager(DJC_Region region, Reimbursement_Policy__mdt policy, DJC_TimeRangeManager timeRangeManager, Contact contact){
		super(region, policy, timeRangeManager, contact);
		hireDate = Contact.Start_Date__c;
	}

	public override Decimal getBalanceForCurrentTimeRange(){
		return this.balanceForCurrentTimeRange;
	}

	public override Decimal getBalanceForPreviousTimeRange(){
		return this.balanceForPreviousTimeRange;
	}

	private Decimal balanceForCurrentTimeRange {
        get {
        	if(balanceForCurrentTimeRange == null && (timeRangeManager.getCurrentTimeRange() == timeRangeManager.getCurrentTimeRange(hireDate))){
    			Decimal balanceForAMonthInQuarter = getLimitForPeriodAndPolicy(timeRangeManager.getCurrentTimeRange()).Limit__c / 3;
        		if (timeRangeManager.getRegion() == DJC_Region.APAC || timeRangeManager.getRegion() == DJC_Region.LACA) {
	        		if(Math.mod(hireDate.month(), 3) == 2){
	        			balanceForCurrentTimeRange = balanceForAMonthInQuarter * 3;
	        		}
	        		if(Math.mod(hireDate.month(), 3) == 0){
	        			balanceForCurrentTimeRange = balanceForAMonthInQuarter * 2;
	        		}
	        		if(Math.mod(hireDate.month(), 3) == 1){
	        			balanceForCurrentTimeRange = balanceForAMonthInQuarter * 1;
	        		}
	        	}
	        	else{
	        		if(Math.mod(hireDate.month(), 3) == 2){
	        			balanceForCurrentTimeRange = balanceForAMonthInQuarter * 2;
	        		}
	        		if(Math.mod(hireDate.month(), 3) == 0){
	        			balanceForCurrentTimeRange = balanceForAMonthInQuarter * 1;
	        		}
	        		if(Math.mod(hireDate.month(), 3) == 1){
	        			balanceForCurrentTimeRange = balanceForAMonthInQuarter * 3;
	        		}
	        	}
        		balanceForCurrentTimeRange -= claimsForCurrentTimeRange;
        		balanceForPreviousTimeRange = ZERO_BALANCE;
        	}
			else if (balanceForCurrentTimeRange == null) {
                balanceForCurrentTimeRange = getLimitForPeriodAndPolicy(timeRangeManager.getCurrentTimeRange()).Limit__c  - claimsForCurrentTimeRange;
            }
            if(balanceForCurrentTimeRange < 0){
            	balanceForCurrentTimeRange = ZERO_BALANCE;
            }
            return balanceForCurrentTimeRange;
        }
        set;
    }
    
    private Decimal balanceForPreviousTimeRange {
        get {
        	if(balanceForPreviousTimeRange == null && (timeRangeManager.getPreviousTimeRange() == timeRangeManager.getQuarter(hireDate))){
        		Decimal balanceForAMonthInQuarter = getLimitForPeriodAndPolicy(timeRangeManager.getPreviousTimeRange()).Limit__c / 3;
        		if (timeRangeManager.getRegion() == DJC_Region.APAC || timeRangeManager.getRegion() == DJC_Region.LACA) {
	        		if(Math.mod(hireDate.month(), 3) == 2){
	        			balanceForPreviousTimeRange = balanceForAMonthInQuarter * 3;
	        		}
	        		if(Math.mod(hireDate.month(), 3) == 0){
	        			balanceForPreviousTimeRange = balanceForAMonthInQuarter * 2;
	        		}
	        		if(Math.mod(hireDate.month(), 3) == 1){
	        			balanceForPreviousTimeRange = balanceForAMonthInQuarter * 1;
	        		}
        		}
        		else{
        			if(Math.mod(hireDate.month(), 3) == 2){
	        			balanceForPreviousTimeRange = balanceForAMonthInQuarter * 2;
	        		}
	        		if(Math.mod(hireDate.month(), 3) == 0){
	        			balanceForPreviousTimeRange = balanceForAMonthInQuarter * 1;
	        		}
	        		if(Math.mod(hireDate.month(), 3) == 1){
	        			balanceForPreviousTimeRange = balanceForAMonthInQuarter * 3;
	        		}
        		}
        		balanceForPreviousTimeRange -= claimsForPreviousTimeRange;
        	}
            else if (balanceForPreviousTimeRange == null) {
				balanceForPreviousTimeRange = getLimitForPeriodAndPolicy(timeRangeManager.getPreviousTimeRange()).Limit__c - claimsForPreviousTimeRange;
            }
            if(balanceForPreviousTimeRange < 0){
            	balanceForPreviousTimeRange = ZERO_BALANCE;
            }
            return balanceForPreviousTimeRange;
        }
        set;
    }

	public override Decimal getClaimsForPreviousTimeRange(){
		return this.claimsForPreviousTimeRange;
	}

	public override Decimal getClaimsForCurrentTimeRange(){
		return this.claimsForCurrentTimeRange;
	} 
 
	public override Decimal getClaimTotalsForGivenStatusRange(String status ,String Range){
		return ClaimTotalsForGivenStatusRange(status,Range);
	} 
	private Decimal ClaimTotalsForGivenStatusRange(String status ,String Range){
		

                List<DJC_Wellness_Reimbursement_Claim__c> claims = [select DJC_Wellness_Amount_Requested__c,
                                                                    CurrencyIsoCode
		                                                            from DJC_Wellness_Reimbursement_Claim__c
		                                                            where DJC_Wellness_Case__r.Reimbursement_Policy_Id__c = :policy.Id__c
		                                                            and DJC_Wellness_Claim_Quarter__c = :Range
		                                                            and DJC_Wellness_Case__r.contactId = :contact.Id
		                                                            and DJC_Wellness_Request_Status__c = :status	
			                                                        and DJC_Wellness_Case__r.status NOT IN ('Rejected','Saved')];
																															
																	

		        Decimal claimTotalsByStatusRange = 0;

		        for (DJC_Wellness_Reimbursement_Claim__c claim : claims) {
		            decimal claimAmount = 0;
		            if (claim.CurrencyIsoCode != policy.Currency__c) {
		                claimTotalsByStatusRange += DJC_Wellness_Util.getConvertedCurrency(claim, policy.Currency__c);
		            } else {
		                claimTotalsByStatusRange += claim.DJC_Wellness_Amount_Requested__c;
		            }
		        }
	    	
	    	return claimTotalsByStatusRange;
	}
	private Decimal claimsForPreviousTimeRange {
		get{
			if(claimsForPreviousTimeRange == null){

                List<DJC_Wellness_Reimbursement_Claim__c> claims = [select DJC_Wellness_Amount_Requested__c,
                                                                    CurrencyIsoCode
		                                                            from DJC_Wellness_Reimbursement_Claim__c
		                                                            where DJC_Wellness_Case__r.Reimbursement_Policy_Id__c = :policy.Id__c
		                                                            and DJC_Wellness_Claim_Quarter__c = :timeRangeManager.getPreviousTimeRange()
		                                                            and DJC_Wellness_Case__r.contactId = :contact.Id
		                                                            and DJC_Wellness_Request_Status__c NOT IN ('Rejected','Saved')
		                                                            and DJC_Wellness_Case__r.status NOT IN ('Rejected','Saved')];

		        claimsForPreviousTimeRange = 0;

		        for (DJC_Wellness_Reimbursement_Claim__c claim : claims) {
		            decimal claimAmount = 0;
		            if (claim.CurrencyIsoCode != policy.Currency__c) {
		                claimsForPreviousTimeRange += DJC_Wellness_Util.getConvertedCurrency(claim, policy.Currency__c);
		            } else {
		                claimsForPreviousTimeRange += claim.DJC_Wellness_Amount_Requested__c;
		            }
		        }
	    	}
	    	return claimsForPreviousTimeRange;
    	}
    	set;
    }
    
    private Decimal claimsForCurrentTimeRange {
    	get{
	    	if(claimsForCurrentTimeRange == null){

                List<DJC_Wellness_Reimbursement_Claim__c> claims = [select DJC_Wellness_Amount_Requested__c, CurrencyISOCode
		                                                            from DJC_Wellness_Reimbursement_Claim__c
		                                                            where DJC_Wellness_Case__r.Reimbursement_Policy_Id__c = :policy.Id__c
		                                                            and DJC_Wellness_Claim_Quarter__c = :timeRangeManager.getCurrentTimeRange()
		                                                            and DJC_Wellness_Case__r.contactId = :contact.Id
		                                                            and DJC_Wellness_Request_Status__c NOT IN ('Rejected','Saved')
		                                                            and DJC_Wellness_Case__r.status NOT IN ('Rejected','Saved')];
		        
		        claimsForCurrentTimeRange = 0;

		        for (DJC_Wellness_Reimbursement_Claim__c claim : claims) {
		            decimal claimAmount = 0;
		            if (claim.CurrencyIsoCode != policy.Currency__c) {
		                claimsForCurrentTimeRange += DJC_Wellness_Util.getConvertedCurrency(claim, policy.Currency__c);
		            } else {
		                claimsForCurrentTimeRange += claim.DJC_Wellness_Amount_Requested__c;
		            }
		        }
	    	}
	    	return claimsForCurrentTimeRange;
    	}
    	set;
    }
}