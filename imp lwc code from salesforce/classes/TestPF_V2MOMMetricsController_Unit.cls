@isTest
private class TestPF_V2MOMMetricsController_Unit {
	
	public static testMethod void execute_V2MOMMetricsController() {   
		 
		GenerateEnvironmentTest1.gen();
		 try
		 {  
		Test.startTest();
		
			 
			V2MOMMetricsController controller = new V2MOMMetricsController();
			V2MOM__c v2momLocked = GenerateEnvironmentTest1.v2momLocked;
			System.assert(v2momLocked != null); 
			V2MOM__c v2momUnlocked = GenerateEnvironmentTest1.v2momUnlocked;
			System.assert(v2momUnlocked != null);
			V2MOM__c v2momNoValue = GenerateEnvironmentTest1.v2momNoValue;
			System.assert(v2momNoValue != null);
			
			System.currentPageReference().getParameters().put('id', v2momNoValue.Id);
			System.currentPageReference().getParameters().put('type', 'edit');
			
			controller = new V2MOMMetricsController();
			controller.setV2momId(v2momNoValue.Id);
			controller.getPrioritySelectOptions();
			controller.getValueSelectOptions();
			controller.getMethodSelectOptions();
			controller.getShow5MoreLink();
			controller.getShowAllLink();
			
			System.currentPageReference().getParameters().put('id', v2momLocked.Id);
			System.currentPageReference().getParameters().put('type', 'edit');
			controller = new V2MOMMetricsController();
			controller.setV2momId(v2momLocked.Id);
			List<V2MOMMetricsController.measureDate> metrics = controller.getMetrics();
			System.currentPageReference().getParameters().put('metricId', metrics[0].getMetric().Id);
			metrics[0].getStartDate();
			metrics[0].getEndDate();
			metrics[0].getPriority();
			controller.loadMetric();
			controller.getPrioritySelectOptions();
	
			System.currentPageReference().getParameters().put('id', v2momUnlocked.Id);
			System.currentPageReference().getParameters().put('type', 'edit');
			controller = new V2MOMMetricsController();
			controller.setV2momId(v2momUnlocked.Id);
			metrics = controller.getMetrics();
			
			System.assert(controller.getValueSelectOptions() != null && controller.getValueSelectOptions().size() > 0);
			
			controller.getMethodSelectOptions();
	
			controller.getV2momId();
			controller.getIsSaveAllowed();
			controller.getIsDeleteAllowed();
			controller.getIsEditPage();
			controller.getOverlayTitle();
			controller.getNewMetric();
			controller.setNewMetric(metrics[0].getMetric());
			controller.getV2MOMName();
			controller.getMetric();
			 
			Measure__c m = new Measure__c();
			m.Description__c = 'test metric description';
			m.Start_Date__c = System.today();
			m.End_Date__c = System.today();
			m.Priority__c = 1;
			m.V2MOM__c = v2momUnlocked.Id;
			controller.setNewMetric(m);
			
			    
			m = new Measure__c();
			m.Description__c = 'test metric 2 description';
			m.Start_Date__c = System.today();
			m.End_Date__c = System.today();
			m.Priority__c = 1;
			m.V2MOM__c = v2momUnlocked.Id;
			controller.setNewMetric(m);
		
			
			m = new Measure__c();
			m.Description__c = 'test metric 5 description';
			m.Start_Date__c = System.today();
			m.End_Date__c = System.today();
			m.Priority__c = 1;
			m.V2MOM__c = v2momUnlocked.Id;
			V2MOMMetricsController.measureDate newMe = new V2MOMMetricsController.measureDate(m);
			controller.setMetric(newMe);
			newMe.setPriority('9');
			newMe.setStartDate(System.today());
			newMe.setEndDate(System.today());
			
			System.currentPageReference().getParameters().put('metricId', metrics[0].getMetric().Id);
			controller.loadMetric();
			controller.getOverlayTitle();
			
			controller.loadMetric();
			controller.getPrioritySelectOptions();
			controller.getOverlayTitle();
			
			
			System.currentPageReference().getParameters().put('metricId', metrics[0].getMetric().Id);
			controller.loadMetric();
			controller.getPrioritySelectOptions();
			
			controller.getMetricSize();
			controller.show5More();
			controller.getShow5MoreLink();
			controller.show5Less();
			controller.getShow5LessLink();
			controller.showAll();
			controller.getShowAllLink();
			
			controller.setV2MOM(null);
			controller.getPrioritySelectOptions();
			controller.getV2MOMName();
			
			controller.getPriorities();
			
			
			
			controller.setPriorities('');
			controller.loadMetrics();
			controller.getValueId();
			controller.getMethodId();
			
			controller.getDateToday();
			
			V2MOMMetricsController.measureDate meas = controller.getMetric();
			meas.getMetricShortId();
			meas.getDescription();
		
			   

	
		Test.stopTest();
	  
		 }
		 catch(Exception ex)
		 {
		 	System.debug(ex);
		 }
		
	}
	

}