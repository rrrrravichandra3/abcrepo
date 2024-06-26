public with sharing class PF_NHW_WDCandidateStore{

	public static WDR_Candidate__c getWDCandidateById(Id candidateId){
		if(candidateId == null){
			return null;
		}else{
			return [Select Id, Phone__c,
					   Mailing_City__c,Mailing_Street__c,Mailing_State__c,
					   Mailing_Country__c,Mailing_Postal_Code__c
				From WDR_Candidate__c 
				Where Id = :candidateId];
		}	
	}
}