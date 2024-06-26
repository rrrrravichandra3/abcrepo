public class DJC_YearClaimManager extends DJC_ClaimManager{

	private Date hireDate;
	private String contactCountry;
	private static final Decimal ZERO_BALANCE = 0;

	public DJC_YearClaimManager(DJC_Region region, Reimbursement_Policy__mdt policy, DJC_TimeRangeManager timeRangeManager, Contact contact){
		super(region, policy, timeRangeManager, contact);
		hireDate = Contact.Start_Date__c;
		contactCountry = Contact.ES_DJC_Contact_Country__c;
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
        	if(balanceForCurrentTimeRange == null && (timeRangeManager.getCurrentTimeRange() == timeRangeManager.getCurrentTimeRange(hireDate))){
    			Decimal balanceForAMonth = getLimitForPeriodAndPolicy(timeRangeManager.getCurrentTimeRange()).Limit__c / 12;
        		if (timeRangeManager.getRegion() == DJC_Region.APAC && contactCountry.equalsIgnoreCase(System.Label.ES_DJC_Country_India_Label)) {
	        		if(hireDate.month() >= 8 && hireDate.month() <= 12){
	        			balanceForCurrentTimeRange = balanceForAMonth * (20 - hireDate.month());
	        		}
	        		else {
	        			balanceForCurrentTimeRange = balanceForAMonth * (8 - hireDate.month());
	        		}
	        	}
				else if (timeRangeManager.getRegion() == DJC_Region.APAC || timeRangeManager.getRegion() == DJC_Region.LACA) {
	        		if(hireDate.month() >= 2 && hireDate.month() <= 12){
	        			balanceForCurrentTimeRange = balanceForAMonth * (14 - hireDate.month());
	        		}
	        		else {
	        			balanceForCurrentTimeRange = balanceForAMonth;
	        		}
	        	}
	        	else{
	        			balanceForCurrentTimeRange = balanceForAMonth * (13 - hireDate.month());
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
        private set;
    }
    
    private Decimal balanceForPreviousTimeRange {
        get {
        	if(balanceForPreviousTimeRange == null && (timeRangeManager.getPreviousTimeRange() == timeRangeManager.getCurrentTimeRange(hireDate))){
        		Decimal balanceForAMonth = getLimitForPeriodAndPolicy(timeRangeManager.getPreviousTimeRange()).Limit__c / 12;
        		if (timeRangeManager.getRegion() == DJC_Region.APAC && contactCountry.equalsIgnoreCase(System.Label.ES_DJC_Country_India_Label)) {
	        		if(hireDate.month() >= 8 && hireDate.month() <= 12){
	        			balanceForPreviousTimeRange = balanceForAMonth * (20 - hireDate.month());
	        		}
	        		else {
	        			balanceForPreviousTimeRange = balanceForAMonth * (8 - hireDate.month());
	        		}
	        	}
				else if (timeRangeManager.getRegion() == DJC_Region.APAC || timeRangeManager.getRegion() == DJC_Region.LACA) {
	        		if(hireDate.month() >= 2 && hireDate.month() <= 12){
	        			balanceForPreviousTimeRange = balanceForAMonth * (14 - hireDate.month());
	        		}
	        		else {
	        			balanceForPreviousTimeRange = balanceForAMonth;
	        		}
	        	}
	        	else{
	        			balanceForPreviousTimeRange = balanceForAMonth * (13 - hireDate.month());
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