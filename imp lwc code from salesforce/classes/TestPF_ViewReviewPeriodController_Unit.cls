@isTest
private class TestPF_ViewReviewPeriodController_Unit {
	
	public static testMethod void execute_ViewReviewPeriodController01() {
		       
        GenerateEnvironmentTest10.genPerformanceReviewPeriod();
        PerformanceReviewPeriod__c period = GenerateEnvironmentTest10.PRPIndividual;
        System.assert(period != null);
        
        Test.startTest();
         
        try {
			ApexPages.StandardController stdController = new ApexPages.StandardController(period);
			ViewReviewPeriodController controller = new ViewReviewPeriodController(stdController);
			
			/* Trigger Period Date Validation */
			period.startDate__c = system.today();
			period.endDate__c = system.today()+1;
			update period;
			
			PerformanceReviewPeriod__c updatedPeriod = [Select Id, Name, StartDate__c, EndDate__c from PerformanceReviewPeriod__c Where Id=: period.Id];
			System.assert(updatedPeriod != null);
			System.assertEquals(period.Id, updatedPeriod.Id);
			System.assertEquals(period.startDate__c, updatedPeriod.startDate__c);
			System.assertEquals(period.endDate__c, updatedPeriod.endDate__c);
			
			controller.getShowAdminOptions();
			controller.getPeriod();
			controller.getShowSingleDepartment();
			controller.getDepartments();
			System.debug('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
			System.debug(period.Effective_Date__c);
			System.debug(period.V2MOM_Type__c);
			//if ((v.Effective_Date__c == period.Effective_Date__c) && v.V2MOM_Type__c=='Individual'&&period.V2MOM_Type__c=='Year End Short'){// added
			
			
			V2MOM__c v2mom = [SELECT Id FROM V2MOM__c Where V2MOM_Type__c =: 'Ad Hoc' limit 1];

				
		} catch (Exception e) {
            System.debug(' ****************** execute_ViewReviewPeriodController01 * ');
            System.debug(e.getMessage());
		}
        	
        Test.stopTest();	
	}

	public static testMethod void execute_ViewReviewPeriodController02() {
		       
        GenerateEnvironmentTest10.genPerformanceReviewPeriod();
        PerformanceReviewPeriod__c period = GenerateEnvironmentTest10.PRPIndividualQ1Q2;
        System.assert(period != null);
        ReviewPeriodDepartment__c department = GenerateEnvironmentTest10.RPDIndividualQ1Q2;
        System.assert(department!= null);
        Test.startTest();
        
        try {
			ApexPages.StandardController stdController = new ApexPages.StandardController(period);
			ViewReviewPeriodController controller = new ViewReviewPeriodController(stdController);
			
			controller.getShowAdminOptions();
			controller.getPeriod();
						
			controller.getDepartments();
			
		} catch (Exception e) {
            System.debug(' ****************** execute_ViewReviewPeriodController02 * ');
            System.debug(e.getMessage());
		}
        	
        Test.stopTest();	
	}
	
	
	public static testMethod void execute_ViewReviewPeriodController03() {
		       
        GenerateEnvironmentTest10.genPerformanceReviewPeriod();
        PerformanceReviewPeriod__c period = GenerateEnvironmentTest10.PRPAdHoc;
        System.assert(period != null);
        Test.startTest();
        
		try {
			ApexPages.StandardController stdController = new ApexPages.StandardController(period);
			ViewReviewPeriodController controller = new ViewReviewPeriodController(stdController);
		
			controller.getShowAdminOptions();
			controller.getPeriod();

			controller.getShowSingleDepartment();
			
			controller.getDepartments();
			      
			
		} catch (Exception e) {
            System.debug(' ****************** execute_ViewReviewPeriodController03 * ');
            System.debug(e.getMessage());
		}
        	
        Test.stopTest();	
	}
		

}