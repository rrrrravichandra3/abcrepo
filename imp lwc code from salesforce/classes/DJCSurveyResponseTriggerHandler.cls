public without sharing class DJCSurveyResponseTriggerHandler {
	
	public static void addCaseLookup(List<DJC_Survey_Response__c> newRecords){
		for (DJC_Survey_Response__c response: newRecords){
			if (response.Case_Id_Text__c!=null){
				try{
					response.Case__c = response.Case_Id_Text__c;
				}catch(DmlException ex){
					system.debug('DML Exception inserting case lookup. Skipping this record with Case Id: '+response.Case_Id_Text__c);
				}
			}
		}		
	}
}