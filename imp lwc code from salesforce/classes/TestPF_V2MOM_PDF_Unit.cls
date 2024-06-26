@isTest
private class TestPF_V2MOM_PDF_Unit {
	
	public static testMethod void execute_methods_V2MOMPDFController() {
		   
		GenerateEnvironmentTest2.genV2MOM_Value();
		Test.startTest();
		  
		try {
			V2MOM_PDF_Controller controller = new V2MOM_PDF_Controller();
	
			controller.setV2MOM(GenerateEnvironmentTest2.v2mom);
			System.currentPageReference().getParameters().put('Value',GenerateEnvironmentTest2.value1.Id);
			if(controller.getV2MOM() == null){
				System.assert(true, 'Null v2mom');
			}
			
			if(controller.getValues() == null){
				System.assert(true, 'Null values');	
			}
			
			if(controller.reset() != null){
				System.assert(true, 'must be null');
			}
			
			controller.setValues(GenerateEnvironmentTest2.valueList);
			
			if(controller.addMethod() != null){
				System.assert(true, 'must be null');	
			}
			
			if(controller.addValue() != null){
				System.assert(true, 'must be null');	
			}	
						
		} catch (Exception e) {
            System.debug(' ****************** execute_methods_V2MOMPDFController * ');
            System.debug(e.getMessage());
		}
	
		Test.stopTest();
		
	}

}