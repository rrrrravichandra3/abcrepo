@isTest
private class TestPF_V2MOMValuesController_Unit {
	
	public static testMethod void execute_V2MOMValuesController() {
		 
		GenerateEnvironmentTest1.gen();
		     
		 try
		 {
		Test.startTest();
		
			V2MOMValuesController controller = new V2MOMValuesController();
			 
			V2MOM__c v2momLocked = GenerateEnvironmentTest1.v2momLocked;
			System.assert(v2momLocked != null);
			V2MOM__c v2momUnlocked = GenerateEnvironmentTest1.v2momUnlocked;
			System.assert(v2momUnlocked != null);
			V2MOM__c v2momNoValue = GenerateEnvironmentTest1.v2momNoValue; 
			System.assert(v2momNoValue != null);
			
			System.currentPageReference().getParameters().put('id', v2momNoValue.Id);
			System.currentPageReference().getParameters().put('type', 'edit');
			controller = new V2MOMValuesController();
			controller.setV2momId(v2momNoValue.Id);
			controller.getPrioritySelectOptions();
			controller.getShow5MoreLink();
			controller.getShowAllLink();
			
			System.currentPageReference().getParameters().put('id', v2momLocked.Id);
			System.currentPageReference().getParameters().put('type', 'edit');
			controller = new V2MOMValuesController();
			controller.setV2momId(v2momLocked.Id);
			List<V2MOMValuesController.valuePriority> values = controller.getValues();
			System.currentPageReference().getParameters().put('valueId', values[0].getValue().Id);
			controller.loadValue();
			
			System.currentPageReference().getParameters().put('id', v2momUnlocked.Id);
			System.currentPageReference().getParameters().put('type', 'edit');
			controller = new V2MOMValuesController();
			controller.setV2momId(v2momUnlocked.Id);
			values = controller.getValues();
	
			controller.getV2momId();
			controller.getIsSaveAllowed();
			controller.getIsDeleteAllowed();
			controller.getIsEditPage();
			controller.getPrioritySelectOptions();
			controller.getOverlayTitle();
			controller.getValuePriority().getPriority();
			controller.setValue(values[0]);
			controller.getV2mom(); 
			controller.getV2MOMName();
			 
			Value__c v = new Value__c();
			v.Name = 'test value';
			v.Tag_Line__c = 'test value tag line';
			v.Priority__c = 1;
			v.V2MOM__c = v2momUnlocked.Id;
			V2MOMValuesController.valuePriority newV1 = new V2MOMValuesController.valuePriority(v);
			controller.setValue(newV1);
			newV1.setPriority('9');
		
	
			v = new Value__c();
			v.Name = 'test value';
			v.Tag_Line__c = 'test value 2 tag line';
			v.Priority__c = 1;
			v.V2MOM__c = v2momUnlocked.Id;
			V2MOMValuesController.valuePriority newV2 = new V2MOMValuesController.valuePriority(v);
			controller.setValue(newV2);
		
			
			System.currentPageReference().getParameters().put('valueId', values[0].getValue().Id);
			controller.loadValue();
			controller.getPrioritySelectOptions();
			controller.getOverlayTitle();
			controller.loadValue();
			controller.getOverlayTitle();
						
			System.currentPageReference().getParameters().put('valueId', values[0].getValue().Id);
			controller.loadValue();
			controller.getPrioritySelectOptions();
			
			controller.getValueSize();
			controller.show5More();
			controller.getShow5MoreLink();
			controller.show5Less();
			controller.getShow5LessLink();
			controller.showAll();
			controller.getShowAllLink();
			controller.getShowError();
			controller.getMsgError();
			
			V2MOMValuesController.valuePriority valuePrio = controller.getValuePriority();
			valuePrio.getValueShortId();
		
			
			controller.setV2MOM(null);
			controller.getPrioritySelectOptions();
			controller.getV2MOMName();
			controller.cancel();
			
			
			
	
		Test.stopTest();
	  }
	  catch(Exception ex)
	  {
	  	
	  }
	}
	
	
}