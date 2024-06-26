@isTest

private class Test_checkForUpdateManagerTrigger {
	
	private static testmethod void changeManagerTest() {
		List<User>uList = [Select u.Profile.Name, u.ProfileId, u.IsActive, u.Id, u.LastName, u.FirstName,u.Email, u.Name From User u where u.Profile.Name='System Administrator' and u.IsActive=true limit 3];
		uList[0].Manager__c = uList[1].Id;
		Test.startTest();
		update uList;
		uList[1].UserRoleId = null;
		uList[1].Manager__c = uList[2].Id;
		update uList;
		Test.stopTest();
	}
}