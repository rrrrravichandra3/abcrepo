/*
	Helper class for case Tier age calculations.. 
	*/
	public with sharing class ESDJC_TierAgeHelper {


		public Set<String> getValidSLACaseOrigins(){
			ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
			Set<String> validCaseOrigins = new Set<String>();
			if(settings.Valid_SLA_Origins__c!=null){
				for(String s : settings.Valid_SLA_Origins__c.split(',',-1)){
					validCaseOrigins.add(s);
				}
			}
			return validCaseOrigins;
		}

		/*Future method which preps data and calls ESDJC_CaseTierAgeCalc class */

		@future 
		public static void updateCaseTierAgesOnClosed(Set<Id> caseIds){
			List<Case> casesClosed = [SELECT Id,CreatedDate,Tier__c,Tier_1_Age__c,Tier_2_Age__c,Tier_3_Age__c,Tier_4_Age__c, BusinessHoursId, IsStopped, 
										       (Select Id, Case__c, 
										                    Tier_1_Age_Milliseconds__c, Tier_2_Age_Milliseconds__c, Tier_3_Age_Milliseconds__c, Tier_4_Age_Milliseconds__c, 
										                    Tier_1_Pause_Time_Milliseconds__c,Tier_2_Pause_Time_Milliseconds__c, Tier_3_Pause_Time_Milliseconds__c, Tier_4_Pause_Time_Milliseconds__c,
										                    Tier_1_Age_in_Days__c, Tier_2_Age_in_Days__c, Tier_3_Age_in_Days__c, Tier_4_Age_in_Days__c,
										                    Tier_1_Pause_Time_in_Days__c, Tier_2_Pause_Time_in_Days__c, Tier_3_Pause_Time_in_Days__c, Tier_4_Pause_Time_in_Days__c 
										                    from Case_Resolution_Times__r) 
										FROM Case WHERE Id IN : caseIds];

			ESDJC_CaseTierAgeCalc.calculateTierAge(casesClosed);

		}

		public static List<CaseHistory> getCaseHistories(Set<Id> caseIds){
			return [select Id,NewValue,OldValue,CreatedDate,Field,CaseId from CaseHistory where field='Tier__c' and caseId in : caseIds order by caseId,createdDate desc ];

		}

		public static Decimal convertToDaysFromMilliSeconds(Decimal timeInMilliSec){
			return (((timeInMilliSec/1000)/60)/60)/24; 

		}




	}