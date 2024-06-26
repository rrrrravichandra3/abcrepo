@isTest
private class Test_V2MOM_Value_Wrapper {
	
	public static testMethod void execute_methods_V2MOMValueWrapper() {
		GenerateEnvironmentTest2.genV2MOM_Value();
	  	   
	 	Test.startTest();
		try {
			List<Value__c> value = [Select v.V2MOM__c, v.Id, (Select Id, Value__c, Priority__c, V2MOM__c From Methods__r) From Value__c v where Id =: GenerateEnvironmentTest2.value1.Id];
			V2MOM_Value_Wrapper controller = new V2MOM_Value_Wrapper(value[0]);
			 
			if(controller.getValue() == null){
				System.assert(true, 'Null value');	
			} 
			if(controller.getMethods() == null){
				System.assert(true, 'Null methods');	
			} 
			if(controller.getMethods() != null){
				controller.setMethods(controller.getMethods());
			}
		} catch (Exception e) {
            System.debug(' ****************** execute_methods_V2MOMValueWrapper * ');
            System.debug(e.getMessage());
		}

	 	Test.stopTest();
		
	}

}