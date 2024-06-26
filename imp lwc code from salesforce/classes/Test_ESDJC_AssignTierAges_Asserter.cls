global with sharing class Test_ESDJC_AssignTierAges_Asserter {

	global void assertScope(List<sObject> scope){
		assertCasesSentToSupportForce(scope);
	}

	private void assertCasesSentToSupportForce(List<sObject> scope){

		for(sObject o:scope){
			Case c = [Select Id, Status, ESDJC_Supportforce_Case_Number__c from Case where Id = :o.Id];
			System.assertNotEquals('Sent to Supportforce', c.Status);
			System.assertNotEquals('In Transit', c.Status);
			System.assertEquals(null, c.ESDJC_Supportforce_Case_Number__c);
		}

	}
	
}