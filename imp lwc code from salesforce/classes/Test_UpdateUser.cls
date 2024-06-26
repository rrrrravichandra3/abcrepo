@isTest private class Test_UpdateUser {
	
	public static testMethod void updateUser() {
		GenerateEnvironmentTest.getUsers();
		   
		Test.startTest();
		try {
			User updateUser = GenerateEnvironmentTest.pcommStandard;
			updateUser.alias = 'Foo Update';
			//update updateUser;
		} catch (Exception e) {
            System.debug(' ****************** updateUser * ');
            System.debug(e.getMessage());
		} 
		Test.stopTest();	
	} 
}