@isTest
private class TestPF_userV2MOMTrig_Unit {
	public static testMethod void execute_methods_V2MOMTrigger() {
		
		GenerateEnvironmentTest2.genUsersTriggers();
		  
		Test.startTest(); 
 
		try {
			GenerateEnvironmentTest2.employeeSupport.Manager__c = GenerateEnvironmentTest2.reviewManagerSupport.Id;
			GenerateEnvironmentTest2.employeeSupport.ReviewManager__c = GenerateEnvironmentTest2.managerSupport.Id;	
			update GenerateEnvironmentTest2.employeeSupport;
		} catch (Exception e) {
            System.debug(' ****************** execute_methods_V2MOMTrigger * ');
            System.debug(e.getMessage());
		}
	 
		Test.stopTest();
		
	 }

}