@isTest
private class TestPF_MethodPriorizationRow_Unit {
	 
	public static testMethod void execute_methods_MethodPriorizationRow() {
		  
		GenerateEnvironmentTest2.gen();
		
		Test.startTest();
		 
		try {
			MethodPrioritizationRow controller = new MethodPrioritizationRow(GenerateEnvironmentTest2.method);
			
			if(controller.getMethod() == null){
				System.assert(true, 'Null Method');	
			}	
			controller.setPriority('4');
			
			if(controller.getPriority() == null){
				System.assert(true, 'Null priority');
			}
			
			controller.setLastRow(true);
			if(controller.getStyleClass() != 'dataRow odd last'){
				System.assert(true, 'Error in code must be dataRow odd last');
			}
			controller.setLastRow(false);
			controller.setFirstRow(true);	
			if(controller.getStyleClass() != 'dataRow odd first'){
				System.assert(true, 'Error in code must be dataRow odd first');
			}
			controller.setLastRow(false);
			controller.setFirstRow(false);
			
			controller.getPriority();
			controller.getStyleClass();
			if(controller.getStyleClass() != 'dataRow odd'){
				System.assert(true, 'Error in code must be dataRow odd');
			}
			
	
        }catch(Exception e){
            System.debug(' ****************** Test_MethodPriorizationRow * ');
            System.debug(e.getMessage());
        }
		
		Test.stopTest();
		
	}

}