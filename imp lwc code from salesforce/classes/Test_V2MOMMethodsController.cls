@isTest
private class Test_V2MOMMethodsController {
	
	public static testMethod void execute_V2MOMMethodsController() {   
		 
		GenerateEnvironmentTest1.gen();
		 
		try {
		Test.startTest();
		
			V2MOMMethodsController controller = new V2MOMMethodsController();
			 
			V2MOM__c v2momLocked = GenerateEnvironmentTest1.v2momLocked;
			System.assert(v2momLocked != null);
			V2MOM__c v2momUnlocked = GenerateEnvironmentTest1.v2momUnlocked;
			System.assert(v2momUnlocked != null);
			V2MOM__c v2momNoValue = GenerateEnvironmentTest1.v2momNoValue; 
			 System.assert(v2momNoValue != null);
			
			System.currentPageReference().getParameters().put('id', v2momNoValue.Id);
			System.currentPageReference().getParameters().put('type', 'edit');
			
			controller = new V2MOMMethodsController();
			controller.setV2momId(v2momNoValue.Id);
			controller.getPrioritySelectOptions();
			
			System.assert(controller.getValueSelectOptions() != null && controller.getValueSelectOptions().size() > 0);
			
			controller.getShow5MoreLink();
			controller.getShowAllLink();
			
			System.currentPageReference().getParameters().put('id', v2momLocked.Id);
			System.currentPageReference().getParameters().put('type', 'edit');
			
			controller = new V2MOMMethodsController();
			controller.setV2momId(v2momLocked.Id);
			List<V2MOMMethodsController.methodPriority> methods = controller.getMethods();
			System.currentPageReference().getParameters().put('methodId', methods[0].getMethod().Id);
			controller.loadMethod();
			controller.getPrioritySelectOptions();
	
			System.currentPageReference().getParameters().put('id', v2momUnlocked.Id);
			System.currentPageReference().getParameters().put('type', 'edit');
			
			controller = new V2MOMMethodsController();
			controller.setV2momId(v2momUnlocked.Id);
			methods = controller.getMethods();
			controller.getAllMethods();
			controller.getValueSelectOptions();
	
			controller.getV2momId();
			controller.getIsSaveAllowed();
			controller.getIsDeleteAllowed();
			controller.getIsEditPage();
			controller.initializeMethod();
			controller.getPrioritySelectOptions();
			controller.getOverlayTitle();
			controller.getNewMethod();
			controller.setNewMethod(methods[0]);
			controller.getV2MOMName();
			 
			controller.getIsSysAdminOrManager();
			
			Method__c m = new Method__c();
			m.Name = 'test method';
			m.Description__c = 'test method description';
			m.Priority__c = 1;
			m.V2MOM__c = v2momUnlocked.Id;
			V2MOMMethodsController.methodPriority newM = new V2MOMMethodsController.methodPriority(m);
			newM.getPriority();
			controller.setNewMethod(newM);
			newM.setPriority('9');
			controller.saveMethodNew();
			 
			m = new Method__c();
			m.Name = 'test method';
			m.Description__c = 'test method 2 description';
			m.Priority__c = 1; 
			m.V2MOM__c = v2momUnlocked.Id;
			controller.setNewMethod(new V2MOMMethodsController.methodPriority(m));
			controller.saveMethod();
			
			System.currentPageReference().getParameters().put('methodId', methods[0].getMethod().Id);
			controller.loadMethod();
			controller.getOverlayTitle();
			controller.saveMethod();
			controller.loadMethod();
			controller.getPrioritySelectOptions();
			controller.getOverlayTitle();
			controller.saveMethodNew();
			
			System.currentPageReference().getParameters().put('methodId', methods[0].getMethod().Id);
			controller.loadMethod();
			controller.deleteMethod();
			
			controller.getMethodSize();
			controller.show5More();
			controller.getShow5MoreLink();
			controller.show5Less();
			controller.getShow5LessLink();
			controller.showAll();
			controller.getShowAllLink();
			
			controller.setV2MOM(null);
			controller.getPrioritySelectOptions();
			controller.getV2MOMName();
			
			controller.loadMethods();
			controller.getValueId();
			
			
			V2MOMMethodsController.methodPriority methodPrio = controller.getNewMethod();
			methodPrio.getMethodShortId();
			methodPrio.getDescription();
			
			V2MOMMethodsController controller2 = new V2MOMMethodsController(); 
			
			ApexPages.StandardController std = new ApexPages.StandardController(v2momLocked);
			System.currentPageReference().getParameters().put('retURL', '/'+v2momLocked.Id);
			controller2 = new V2MOMMethodsController(std);
			
			V2MOMMethodsController controller3 = new V2MOMMethodsController(); 
			
			System.currentPageReference().getParameters().put('retURL', '/');
			controller3 = new V2MOMMethodsController(std);
	
		
		Test.stopTest();
		
		}
		 
		catch (Exception ex) {
			System.debug(ex);
		}
	}
}