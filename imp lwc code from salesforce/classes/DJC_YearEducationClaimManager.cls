public with sharing class DJC_YearEducationClaimManager extends DJC_ClaimManager{

	public DJC_YearEducationClaimManager(DJC_Region region, Reimbursement_Policy__mdt policy, DJC_TimeRangeManager timeRangeManager, Contact contact){
		super(region, policy, timeRangeManager, contact);
	}

	public override Decimal getClaimsForPreviousTimeRange(){
		return claimsForPreviousTimeRange;
	}

	public override Decimal getClaimsForCurrentTimeRange(){
		return claimsForCurrentTimeRange;
	}

	public override Decimal getBalanceForCurrentTimeRange(){
		return balanceForCurrentTimeRange;
	}

	public override Decimal getBalanceForPreviousTimeRange(){
		return balanceForPreviousTimeRange;
	}

    private Decimal balanceForCurrentTimeRange {
        get {
            if (balanceForCurrentTimeRange == null) {
                balanceForCurrentTimeRange = getLimitForPeriodAndPolicy(timeRangeManager.getCurrentTimeRange()).Limit__c  - claimsForCurrentTimeRange;
            }
            return balanceForCurrentTimeRange;
        }
        private set;
    }
    
    private Decimal balanceForPreviousTimeRange {
        get {
            if (balanceForPreviousTimeRange == null) {
                balanceForPreviousTimeRange = getLimitForPeriodAndPolicy(timeRangeManager.getPreviousTimeRange()).Limit__c - claimsForPreviousTimeRange;
            }
            return balanceForPreviousTimeRange;
        }
        private set;
    }  
	public override Decimal getClaimTotalsForGivenStatusRange(String status ,String Range){
		return ClaimTotalsForGivenStatusRange(status,Range);
	} 
	private Decimal ClaimTotalsForGivenStatusRange(String status ,String Range){
		

                List<DJC_Wellness_Reimbursement_Claim__c> claims = [select DJC_Wellness_Amount_Requested__c,
                                                                    CurrencyIsoCode
		                                                            from DJC_Wellness_Reimbursement_Claim__c
		                                                            where DJC_Wellness_Case__r.Reimbursement_Policy_Id__c = :policy.Id__c
		                                                            and DJC_Wellness_Claim_Fiscal_Year_Start__c = :Range
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
                List<DJC_Wellness_Reimbursement_Claim__c> claims = [select DJC_Wellness_Amount_Requested__c, CurrencyISOCode
	                                                                from DJC_Wellness_Reimbursement_Claim__c
	                                                                where DJC_Wellness_Case__r.Reimbursement_Policy_Id__c = :policy.Id__c
	                                                                and DJC_Wellness_Claim_Fiscal_Year_Start__c = :timeRangeManager.getPreviousTimeRange()
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
    
    public Decimal claimsForCurrentTimeRange {
    	get{
			if (claimsForCurrentTimeRange == null) {
                List<DJC_Wellness_Reimbursement_Claim__c> claims = [select DJC_Wellness_Amount_Requested__c, CurrencyISOCode
	                                                                from DJC_Wellness_Reimbursement_Claim__c
	                                                                where DJC_Wellness_Case__r.Reimbursement_Policy_Id__c = :policy.Id__c
	                                                                and DJC_Wellness_Claim_Fiscal_Year_Start__c = :timeRangeManager.getCurrentTimeRange()
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