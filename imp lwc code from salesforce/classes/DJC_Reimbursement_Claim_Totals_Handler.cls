public with sharing class DJC_Reimbursement_Claim_Totals_Handler {

	public static void calculateTotalsAfterInsertingClaims(List<DJC_Wellness_Reimbursement_Claim__c> claims) {
		
		Map<Id,Case> cases = getCases(claims);
		List<DJC_Reimbursement_Total_Claimed__c> totals = getTotals(claims, cases);
		Map<String,DJC_Reimbursement_Total_Claimed__c> totalsMap = new Map<String,DJC_Reimbursement_Total_Claimed__c>();

		for(DJC_Reimbursement_Total_Claimed__c total : totals){
			totalsMap.put(total.Group_Id__c, total);
		}

		for(DJC_Wellness_Reimbursement_Claim__c claim : claims){

			Case c = cases.get(claim.DJC_Wellness_Case__c);
			String groupId = c.ContactId + ';' + claim.Time_Range__c + ';' + c.Reimbursement_Policy_Id__c.intValue() + ';' + claim.DJC_Wellness_Request_Status__c;
            
			DJC_Reimbursement_Total_Claimed__c total = totalsMap.get(groupId);

			if(total != null){
				if (claim.CurrencyIsoCode != c.CurrencyIsoCode) {
	                total.Amount__c += DJC_Wellness_Util.getConvertedCurrency (claim, c.CurrencyIsoCode);
	            } else {
	                total.Amount__c += claim.DJC_Wellness_Amount_Requested__c;
	            }
			}
        }
        UPDATE totals;
	}

	public static void calculateTotalsAfterUpdatingClaims(List<DJC_Wellness_Reimbursement_Claim__c> newClaims,
		Map<Id,DJC_Wellness_Reimbursement_Claim__c> oldClaims){


		Map<Id,Case> cases = getCases(newClaims);

		List<DJC_Reimbursement_Total_Claimed__c> newClaimsTotals = getTotals(newClaims, cases);
		List<DJC_Reimbursement_Total_Claimed__C> oldClaimsTotals = getTotals(oldClaims.values(), cases);

		Map<String,DJC_Reimbursement_Total_Claimed__c> totalsMap = new Map<String,DJC_Reimbursement_Total_Claimed__c>();

		for(DJC_Reimbursement_Total_Claimed__c total : newClaimsTotals){
			totalsMap.put(total.Group_Id__c, total);
		}

		for(DJC_Reimbursement_Total_Claimed__c total : oldClaimsTotals){
			totalsMap.put(total.Group_Id__c, total);
		}

		for(DJC_Wellness_Reimbursement_Claim__c newClaim : newClaims){

			DJC_Wellness_Reimbursement_Claim__c oldClaim = oldClaims.get(newClaim.Id);

			Case c = cases.get(newClaim.DJC_Wellness_Case__c);

			String oldGroupId = c.ContactId + ';' + oldClaim.Time_Range__c + ';' + c.Reimbursement_Policy_Id__c.intValue() + ';' + oldClaim.DJC_Wellness_Request_Status__c;
			String newGroupId = c.ContactId + ';' + newClaim.Time_Range__c + ';' + c.Reimbursement_Policy_Id__c.intValue() + ';' + newClaim.DJC_Wellness_Request_Status__c;			

			DJC_Reimbursement_Total_Claimed__c oldTotal = totalsMap.get(oldGroupId);
			DJC_Reimbursement_Total_Claimed__c newTotal = totalsMap.get(newGroupId);

			if(oldTotal != null){
				if (oldClaim.CurrencyIsoCode != c.CurrencyIsoCode) {
	                oldTotal.Amount__c -= DJC_Wellness_Util.getConvertedCurrency (oldClaim, c.CurrencyIsoCode);
	            } else {
	                oldTotal.Amount__c -= oldClaim.DJC_Wellness_Amount_Requested__c;
	            }
			}
			if(newTotal != null){
				if (newClaim.CurrencyIsoCode != c.CurrencyIsoCode) {
	                newTotal.Amount__c += DJC_Wellness_Util.getConvertedCurrency (newClaim, c.CurrencyIsoCode);
	            } else {
	                newTotal.Amount__c += newClaim.DJC_Wellness_Amount_Requested__c;
	            }
			}
        }

        UPDATE totalsMap.values();
	}

	public static void calculateTotalsAfterDeletingClaims(List<DJC_Wellness_Reimbursement_Claim__c> claims){

		Map<Id,Case> cases = getCases(claims);
		List<DJC_Reimbursement_Total_Claimed__c> totals = getTotals(claims, cases);
		Map<String,DJC_Reimbursement_Total_Claimed__c> totalsMap = new Map<String,DJC_Reimbursement_Total_Claimed__c>();

		for(DJC_Reimbursement_Total_Claimed__c total : totals){
			totalsMap.put(total.Group_Id__c, total);
		}

		for(DJC_Wellness_Reimbursement_Claim__c claim : claims){

			Case c = cases.get(claim.DJC_Wellness_Case__c);
			String groupId = c.ContactId + ';' + claim.Time_Range__c + ';' + c.Reimbursement_Policy_Id__c.intValue() + ';' + claim.DJC_Wellness_Request_Status__c;
			DJC_Reimbursement_Total_Claimed__c total = totalsMap.get(groupId);

			if(total != null){
				if (claim.CurrencyIsoCode != c.CurrencyIsoCode) {
	                total.Amount__c -= DJC_Wellness_Util.getConvertedCurrency (claim, c.CurrencyIsoCode);
	            } else {
	                total.Amount__c -= claim.DJC_Wellness_Amount_Requested__c;
	            }
			}
        }
        UPDATE totals;

	}

	private static List<DJC_Reimbursement_Total_Claimed__c> getTotals(List<DJC_Wellness_Reimbursement_Claim__c> claims, Map<Id,Case> cases){
		
		List<String> groupIds = new List<String>();

		for(DJC_Wellness_Reimbursement_Claim__c claim : claims){
			Case c = cases.get(claim.DJC_Wellness_Case__c);
			groupIds.add(c.ContactId + ';' + claim.Time_Range__c + ';' + c.Reimbursement_Policy_Id__c.intValue() + ';' + claim.DJC_Wellness_Request_Status__c);
        }

        return [SELECT Id, Group_Id__c, Amount__c FROM DJC_Reimbursement_Total_Claimed__c WHERE Group_Id__c IN :groupIds];
	}

	private static Map<Id,Case> getCases(List<DJC_Wellness_Reimbursement_Claim__c> claims){

		List<Id> caseIds = new List<Id>();

		for(DJC_Wellness_Reimbursement_Claim__c claim : claims){
        	caseIds.add(claim.DJC_Wellness_Case__c);
        }

        return new Map<Id,Case>([SELECT Id, ContactId, Reimbursement_Policy_Id__c, CurrencyIsoCode FROM Case WHERE Id IN :caseIds]);
	}
}