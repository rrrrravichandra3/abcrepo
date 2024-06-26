@isTest
private class TestPF_userProfileTrig_Unit {
	
	public static testMethod void execute_methods_userProfileTrig() {
		  
		GenerateEnvironmentTest2.genUsersTriggers();
		 
		GenerateEnvironmentTest2.consultingEmployee.CompanyName = 'new company';
		
		Test.startTest();
		
		try {
			update GenerateEnvironmentTest2.consultingEmployee;
		} catch (Exception e) {
            System.debug(' ****************** execute_methods_userProfileTrig * ');
            System.debug(e.getMessage());
		}
		 
		Test.stopTest();
		
	}
}