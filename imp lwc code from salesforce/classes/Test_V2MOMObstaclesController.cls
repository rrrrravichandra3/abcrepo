@isTest
private class Test_V2MOMObstaclesController {
	
	public static testMethod void execute_V2MOMObstaclesController() {    
		
		GenerateEnvironmentTest1.gen();
		  
		Test.startTest();
		  
			System.assert(GenerateEnvironmentTest1.v2momLocked != null);
			System.assert(GenerateEnvironmentTest1.v2momUnlocked != null);
			System.assert(GenerateEnvironmentTest1.v2momNoValue != null);
			System.assert(GenerateEnvironmentTest1.valueForLocked != null);
			System.assert(GenerateEnvironmentTest1.valueForUnlocked != null);
			
			V2MOMObstaclesController controller = new V2MOMObstaclesController();
			 
			V2MOM__c v2momLocked = GenerateEnvironmentTest1.v2momLocked;
			V2MOM__c v2momUnlocked = GenerateEnvironmentTest1.v2momUnlocked;
			V2MOM__c v2momNoValue = GenerateEnvironmentTest1.v2momNoValue;
			
			System.currentPageReference().getParameters().put('id', v2momNoValue.Id);
			System.currentPageReference().getParameters().put('type', 'edit');
			controller = new V2MOMObstaclesController();
			controller.setV2momId(v2momNoValue.Id);
			controller.getPrioritySelectOptions();
			System.assert(controller.getValueSelectOptions() != null && controller.getValueSelectOptions().size() > 0);
			controller.getMethodSelectOptions();
			controller.getShow5MoreLink();
			controller.getShowAllLink();
			
			System.currentPageReference().getParameters().put('id', v2momLocked.Id);
			System.currentPageReference().getParameters().put('type', 'edit');
			controller = new V2MOMObstaclesController();
			controller.setV2momId(v2momLocked.Id);
			List<V2MOMObstaclesController.obstaclePriority> obstacles = controller.getObstacles();
			System.currentPageReference().getParameters().put('obstacleId', obstacles[0].getObstacle().Id);
			controller.loadObstacle();
	
			System.currentPageReference().getParameters().put('id', v2momUnlocked.Id);
			System.currentPageReference().getParameters().put('type', 'edit');
			controller = new V2MOMObstaclesController();
			controller.setV2momId(v2momUnlocked.Id);
			obstacles = controller.getObstacles();
			controller.getValueSelectOptions();
			controller.getMethodSelectOptions();
	
			controller.getV2momId();
			controller.getIsSaveAllowed();
			controller.getIsDeleteAllowed();
			controller.getIsEditPage();
			controller.initializeObstacle();
			controller.getPrioritySelectOptions();
			controller.getOverlayTitle();
			controller.getObstacle().getPriority();
			
			controller.getV2MOMName();
			controller.getV2MOM();
			controller.getValueId();
			controller.getMethodId();
			controller.getV2mom();
			 
			Obstacle__c o = new Obstacle__c();
			o.Description__c = 'test obstacle description';
			o.Priority__c = 1;
			o.V2MOM__c = v2momUnlocked.Id;
			V2MOMObstaclesController.obstaclePriority newO1 = new V2MOMObstaclesController.obstaclePriority(o);
			controller.setObstacle(newO1);
			controller.saveObstacle();
			
			o = new Obstacle__c();
			o.Description__c = 'test obstacle 2 description';
			o.Priority__c = 1;
			o.V2MOM__c = v2momUnlocked.Id;
			V2MOMObstaclesController.obstaclePriority newO2 = new V2MOMObstaclesController.obstaclePriority(o);
			controller.setObstacle(newO2);
			controller.saveObstacleNew();
			
			o = new Obstacle__c();
			o.Description__c = 'test obstacle 7 description';
			o.Priority__c = 1;
			o.V2MOM__c = v2momUnlocked.Id;
			V2MOMObstaclesController.obstaclePriority newOb = new V2MOMObstaclesController.obstaclePriority(o);
			controller.setObstacle(newOb);
			newOb.setPriority('9');
			controller.saveObstacle();
			
			controller.loadObstacle();
			controller.getOverlayTitle();
			controller.saveObstacle();
			controller.loadObstacle();
			controller.getPrioritySelectOptions();
			controller.getOverlayTitle();
			controller.saveObstacleNew();
		
			controller.loadObstacle();
			controller.getPrioritySelectOptions();
			
			controller.getObstacleSize();
			controller.show5More();
			controller.getShow5MoreLink();
			controller.show5Less();
			controller.getShow5LessLink();
			controller.showAll();
			controller.getShowAllLink();
			
			controller.setV2MOM(null);
			controller.getPrioritySelectOptions();
			controller.getV2MOMName();
			
			controller.loadObstacles();
			controller.getValueId();
			controller.getMethodId();
			controller.DeleteObstacleDetail();
			
			V2MOMObstaclesController controller2 = new V2MOMObstaclesController(); 
			
			ApexPages.StandardController std = new ApexPages.StandardController(v2momLocked);
			System.currentPageReference().getParameters().put('retURL', '/'+v2momLocked.Id);
			controller2 = new V2MOMObstaclesController(std);
			
			V2MOMObstaclesController controller3 = new V2MOMObstaclesController(); 
			
			System.currentPageReference().getParameters().put('retURL', '/');
			controller3 = new V2MOMObstaclesController(std);
			
		Test.stopTest();
		
	}
	
}