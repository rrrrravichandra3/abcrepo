@isTest(SeeAllData = true)
private class Test_ESDJC_Util_SeeAllData
{
	@isTest
	static void testCreatePortalGuestUser() {		
		ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
		List<User> users = [SELECT id FROM User WHERE Username = :settings.Portal_Guest_Username__c]; 
		System.assertEquals(1, users.size());
	}
}