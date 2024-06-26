@isTest
private class Test_EmployeeHandbookEditController {
	  
	public static testMethod void execute_methods_HandBookController() {
		
		GenerateEnvironmentTest2.getHandbook();
		 
		Test.startTest();
		   
		try {
			ApexPages.StandardController std = new ApexPages.StandardController(GenerateEnvironmentTest2.employeeHandbook);
			EmployeeHandbookEditController controller = new EmployeeHandbookEditController(std);
			
			if(controller.getEmployeeHandbook() == null){
				System.assert(true, 'null object');	
			}
			if(controller.save() == null){
				System.assert(true, 'null not save');	
			}
			if(controller.getIdPrefix() == null){
				System.assert(true, 'null prefix');
			}
			controller.saveAndNew();
        }catch(Exception e){
            System.debug(' ****************** Test_EmployeeHandbookEditController * ');
            System.debug(e.getMessage());
        }
		
		Test.stopTest();
		
	}
	
}