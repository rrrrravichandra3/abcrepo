@isTest
private class Test_ViewReviewPeriodController {
	
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
			controller.getErrors();
			controller.getWarnings();
			controller.getError();
			controller.initReviewPeriod();
			controller.launchPerformanceReviews();
			controller.returnPerformanceReviewPeriod();
			controller.getRenderSetupButton();
			controller.getShowSingleDepartment();
			controller.getIsRepeatedDepartment();
			controller.getLaunchStatus();
			controller.getDepartments();
			controller.getNewDepartment();
			controller.saveDepartment();
			controller.setPerformanceReviewType('testPerformanceReviewType');
			controller.getPerformanceReviewType();
			System.debug('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
			System.debug(period.Effective_Date__c);
			System.debug(period.V2MOM_Type__c);
			//if ((v.Effective_Date__c == period.Effective_Date__c) && v.V2MOM_Type__c=='Individual'&&period.V2MOM_Type__c=='Year End Short'){// added
			
			
			V2MOM__c v2mom = [SELECT Id FROM V2MOM__c Where V2MOM_Type__c =: 'Ad Hoc' limit 1];
			ViewReviewPeriodController.cloneV2MOM(v2mom);
			ViewReviewPeriodController.cloneV2MOMWithoutType(v2mom);
				
		} catch (Exception e) {
            System.debug(' ****************** execute_ViewReviewPeriodController01 * ');
            System.debug(e.getMessage());
		}
        	
        Test.stopTest();	
	}
	public static testMethod void execute_ViewReviewPeriodController01_1(){
		Test.startTest();
		 	GenerateEnvironmentTest10.genPerformanceReviewPeriod();
        	PerformanceReviewPeriod__c period = GenerateEnvironmentTest10.PRPIndividual;
			System.assert(period != null);
			
			ApexPages.StandardController stdController = new ApexPages.StandardController(period);
			ViewReviewPeriodController controller = new ViewReviewPeriodController(stdController);
			PerformanceReview__c prnew = controller.getNewReview();
			System.assert(prnew != null);
			
			prnew.Employee__c = controller.getCurrentUserId();
			controller.setCurrentUserId(prnew.Employee__c);
			System.assert(prnew.Employee__c != null);
			controller.launchReview();
			
			controller.getShowAfterLaunched();
			controller.getShowLaunchPerformanceReviews();
			controller.getShowError();
			
			ReviewPeriodDepartment__c rpd = controller.getNewSingleDepartment();        
	        	        
			if(controller.getErrors() != null && controller.getErrors().size() > 0){
			    ViewReviewPeriodController.SetupInfo innerClass = controller.getErrors()[0];
				
				innerClass.getUser();
				innerClass.getMessage();
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
			controller.getErrors();
			controller.getWarnings();
			controller.getError();
			controller.initReviewPeriod();
			
	    	controller.launchPerformanceReviews();
			controller.returnPerformanceReviewPeriod();
			controller.getRenderSetupButton();
			controller.getShowSingleDepartment();
			
			controller.getLaunchStatus();
			controller.getDepartments();
			controller.getNewDepartment();
			controller.saveDepartment();
			
			PerformanceReview__c prnew = controller.getNewReview();
			System.assert(prnew != null);
			prnew.Employee__c = controller.getCurrentUserId();
			System.assert(prnew.Employee__c != null);
			controller.launchReview();
			
			controller.getShowAfterLaunched();
			controller.getShowLaunchPerformanceReviews();
			controller.getShowError();
			
			controller.launchReviewForDepartment();
			
			ReviewPeriodDepartment__c rpd = controller.getNewSingleDepartment();        
	        	        
			System.currentPageReference().getParameters().put('deptId', department.Id);
	        controller.deleteDepartment();
	        
			if(controller.getErrors() != null && controller.getErrors().size() > 0){
			    ViewReviewPeriodController.SetupInfo innerClass = controller.getErrors()[0];
				
				innerClass.getUser();
				innerClass.getMessage();
			}
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
			controller.getErrors();
			controller.getWarnings();
			controller.getError();
			controller.initReviewPeriod();
			
	    	controller.launchPerformanceReviews();
			controller.returnPerformanceReviewPeriod();
			controller.getRenderSetupButton();
			controller.getShowSingleDepartment();
			
			controller.getLaunchStatus();
			controller.getDepartments();
			controller.getNewDepartment();
			controller.saveDepartment();
			
			PerformanceReview__c prnew = controller.getNewReview();
			System.assert(prnew != null);
			prnew.Employee__c = controller.getCurrentUserId();
			System.assert(prnew.Employee__c != null);
			
			controller.launchReview();
			
			controller.getShowAfterLaunched();
			controller.getShowLaunchPerformanceReviews();
			controller.getShowError();
			
			
			
			ReviewPeriodDepartment__c rpd = controller.getNewSingleDepartment();
			System.assert(rpd != null);
			      
			
			if(controller.getErrors() != null && controller.getErrors().size() > 0){
			    ViewReviewPeriodController.SetupInfo innerClass = controller.getErrors()[0];
				
				innerClass.getUser();
				innerClass.getMessage();
			}
		} catch (Exception e) {
            System.debug(' ****************** execute_ViewReviewPeriodController03 * ');
            System.debug(e.getMessage());
		}
        	
        Test.stopTest();	
	}
	
	public static testMethod void execute_ViewReviewPeriodController04() {
		       
        GenerateEnvironmentTest10.genPerformanceReviewPeriod();
        PerformanceReviewPeriod__c period = GenerateEnvironmentTest10.PRPIndividualQ1Q2;
        System.assert(period != null);
        
        User managerStandard = GenerateEnvironmentTest10.managerStandard;
        Department__c department = [select Id from Department__c limit 1];
        
        Test.startTest();
        
        try {
	        system.runAs(managerStandard) {			 
		    	ApexPages.StandardController stdController = new ApexPages.StandardController(period);
				ViewReviewPeriodController controller = new ViewReviewPeriodController(stdController);
				
				controller.getShowAdminOptions();
				controller.initReviewPeriod();
				controller.getNewReview();	
				controller.launchReview();
				
				ReviewPeriodDepartment__c rpd = controller.getNewSingleDepartment();
				System.assert(rpd != null);
				
				rpd.Department__c = department.Id;
				controller.launchReviewForDepartment();
	        }
		} catch (Exception e) {
            System.debug(' ****************** execute_ViewReviewPeriodController04 * ');
            System.debug(e.getMessage());
		}
        
		Test.stopTest();
	}	
	
	
	public static testMethod void execute_ViewReviewPeriodController05() {
		       
        GenerateEnvironmentTest10.genPerformanceReviewPeriod();
        PerformanceReviewPeriod__c period = GenerateEnvironmentTest10.PRPErrors;
        System.assert(period != null);
        
        User managerConsulting = GenerateEnvironmentTest10.managerConsulting;
        System.assert(managerConsulting != null);
        
        Department__c department = [select Id from Department__c limit 1];
        
        Test.startTest();
        
        try {
	        system.runAs(managerConsulting) {			 
		    	ApexPages.StandardController stdController = new ApexPages.StandardController(period);
				ViewReviewPeriodController controller = new ViewReviewPeriodController(stdController);
				
				controller.getShowAdminOptions();
				controller.initReviewPeriod();	
				controller.getNewReview();
				controller.launchReview();
				
				ReviewPeriodDepartment__c rpd = controller.getNewSingleDepartment();
				System.assert(rpd != null);
				rpd.Department__c = department.Id;
				controller.launchReviewForDepartment();
	        }
		} catch (Exception e) {
            System.debug(' ****************** execute_ViewReviewPeriodController05 * ');
            System.debug(e.getMessage());
		}
        
		Test.stopTest();
	}	
	
	
	public static testMethod void execute_ViewReviewPeriodController06() {
		       
        GenerateEnvironmentTest10.genPerformanceReviewPeriod();
        PerformanceReviewPeriod__c period = GenerateEnvironmentTest10.PRPErrors;
        System.assert(period != null);
        
        User employeeConsulting = GenerateEnvironmentTest10.employeeConsulting;
        System.assert(employeeConsulting != null);
        
        Department__c department = [select Id from Department__c limit 1];
        
        Test.startTest();
        
        try {
	        system.runAs(employeeConsulting) {			 
		    	ApexPages.StandardController stdController = new ApexPages.StandardController(period);
				ViewReviewPeriodController controller = new ViewReviewPeriodController(stdController);
				
				controller.getShowAdminOptions();
				controller.initReviewPeriod();
				controller.getNewReview();	
				controller.launchReview();
				
				ReviewPeriodDepartment__c rpd = controller.getNewSingleDepartment();
				System.assert(rpd != null);
				rpd.Department__c = department.Id;
				controller.launchReviewForDepartment();
	        }
		} catch (Exception e) {
            System.debug(' ****************** execute_ViewReviewPeriodController06 * ');
            System.debug(e.getMessage());
		}
        
		Test.stopTest();
	}
	
	
	public static testMethod void execute_ViewReviewPeriodController07() {
		       
        GenerateEnvironmentTest10.genPerformanceReviewPeriod();
        PerformanceReviewPeriod__c period = GenerateEnvironmentTest10.PRPErrors;
        System.assert(period != null);
        
        User pcommStandard = GenerateEnvironmentTest10.pcommStandard;
        System.assert(pcommStandard != null);
        
        Department__c department = [select Id from Department__c limit 1];
        
        Test.startTest();
        
        try {
	        system.runAs(pcommStandard) {			 
		    	ApexPages.StandardController stdController = new ApexPages.StandardController(period);
				ViewReviewPeriodController controller = new ViewReviewPeriodController(stdController);
				
				controller.getShowAdminOptions();
				controller.initReviewPeriod();
				controller.getNewReview();	
				controller.launchReview();
				
				ReviewPeriodDepartment__c rpd = controller.getNewSingleDepartment();
				System.assert(rpd != null);
				
				rpd.Department__c = department.Id;
				controller.launchReviewForDepartment();
	        }
		} catch (Exception e) {
            System.debug(' ****************** execute_ViewReviewPeriodController07 * ');
            System.debug(e.getMessage());
		}
        
		Test.stopTest();
	}		

	
	public static testMethod void execute_ViewReviewPeriodController08() {
		       
        GenerateEnvironmentTest10.genPerformanceReviewPeriod();
        PerformanceReviewPeriod__c period = GenerateEnvironmentTest10.PRPErrors;
        System.assert(period != null);
        
        Department__c department = [select Id from Department__c limit 1];
        User pcommStandard = GenerateEnvironmentTest10.pcommStandard;
        System.assert(pcommStandard!= null);
        
        Test.startTest();
        
        try {
        	
	        system.runAs(pcommStandard) {			 
		    	ApexPages.StandardController stdController = new ApexPages.StandardController(period);
				ViewReviewPeriodController controller = new ViewReviewPeriodController(stdController);
				
				controller.getShowAdminOptions();
				controller.initReviewPeriod();
				controller.getNewReview();	
				controller.launchReview();
				
				ReviewPeriodDepartment__c rpd = controller.getNewSingleDepartment();
				System.assert(rpd != null);
				
				rpd.Department__c = department.Id;
				controller.launchReviewForDepartment();
	        }
		} catch (Exception e) {
            System.debug(' ****************** execute_ViewReviewPeriodController08 * ');
            System.debug(e.getMessage());
		}
        
		Test.stopTest();
	}		
	
	
	public static testMethod void execute_ViewReviewPeriodController09() {
		       
        GenerateEnvironmentTest10.genPerformanceReviewPeriod();
        //GenerateEnvironmentTest10.createV2MOMIndividualQ1Q2Data();
        
        PerformanceReviewPeriod__c period = GenerateEnvironmentTest10.PRPAdHoc;
        System.assert(period != null);
        
        User pcommStandard = GenerateEnvironmentTest10.pcommStandard;
        System.assert(pcommStandard != null);
        
        Test.startTest();
        Department__c department = [select Id from Department__c limit 1];
        system.runAs(pcommStandard) {			 
        	try {
		    	ApexPages.StandardController stdController = new ApexPages.StandardController(period);
				ViewReviewPeriodController controller = new ViewReviewPeriodController(stdController);
				
				controller.getShowAdminOptions();
				controller.initReviewPeriod();
				controller.getNewReview();	
				controller.launchReview();
				
				ReviewPeriodDepartment__c rpd = controller.getNewSingleDepartment();
				System.assert(rpd != null);
				rpd.Department__c = department.Id;
				controller.launchReviewForDepartment();
			} catch (Exception e) {
	            System.debug(' ****************** execute_ViewReviewPeriodController09 * ');
	            System.debug(e.getMessage());
			}
        }
        
		Test.stopTest();
	}		

	
	public static testMethod void execute_ViewReviewPeriodController10() {
		       
        GenerateEnvironmentTest10.genPerformanceReviewPeriod();
        //GenerateEnvironmentTest10.createV2MOMIndividualQ1Q2Data();
        
        PerformanceReviewPeriod__c period = GenerateEnvironmentTest10.PRPIndividualQ1Q2;
        System.assert(period != null);
        User pcommStandard = GenerateEnvironmentTest10.pcommStandard;
        System.assert(pcommStandard != null);
        
        Test.startTest();
        
        try {
        	Department__c department = [SELECT Id FROM Department__c limit 1];	
	        system.runAs(pcommStandard) {			 
	        	
		    	ApexPages.StandardController stdController = new ApexPages.StandardController(period);
				ViewReviewPeriodController controller = new ViewReviewPeriodController(stdController);
				
				controller.getShowAdminOptions();
				controller.initReviewPeriod();
				controller.getNewReview();	
				controller.launchReview();
				
				ReviewPeriodDepartment__c rpd = controller.getNewSingleDepartment();
				System.assert(rpd != null);
				
				rpd.Department__c = department.Id;
				controller.launchReviewForDepartment();
	        }
		} catch (Exception e) {
            System.debug(' ****************** execute_ViewReviewPeriodController10 * ');
            System.debug(e.getMessage());
		}
        
		Test.stopTest();
	}		

	
	public static testMethod void execute_ViewReviewPeriodController11() {
		       
        GenerateEnvironmentTest10.genPerformanceReviewPeriod();
        //GenerateEnvironmentTest10.createV2MOMIndividualQ1Q2Data();
        
        PerformanceReviewPeriod__c period = GenerateEnvironmentTest10.PRPIndividual;
        System.assert(period != null);
        
        User pcommStandard = GenerateEnvironmentTest10.pcommStandard;
        System.assert(pcommStandard != null);
        
        Test.startTest();
        
        try {
        	Department__c department = [SELECT Id FROM Department__c limit 1];
	        system.runAs(pcommStandard) {			 
	        	
		    	ApexPages.StandardController stdController = new ApexPages.StandardController(period);
				ViewReviewPeriodController controller = new ViewReviewPeriodController(stdController);
				
				controller.getShowAdminOptions();
				controller.initReviewPeriod();
				controller.getNewReview();	
				controller.launchReview();
				
				ReviewPeriodDepartment__c rpd = controller.getNewSingleDepartment();
				System.assert(rpd != null);
				rpd.Department__c = department.Id;
				controller.launchReviewForDepartment();
	        }
		} catch (Exception e) {
            System.debug(' ****************** execute_ViewReviewPeriodController11 * ');
            System.debug(e.getMessage());
		}
        
		Test.stopTest();
	}		

	
	public static testMethod void execute_ViewReviewPeriodController12() {
		       
        GenerateEnvironmentTest10.genPerformanceReviewPeriod();
        //GenerateEnvironmentTest10.createV2MOMIndividualQ3Q4Data();
        
        PerformanceReviewPeriod__c period = GenerateEnvironmentTest10.PRPAdHoc;
        System.assert(period != null);
        
        User pcommStandard = GenerateEnvironmentTest10.pcommStandard;
        System.assert(pcommStandard != null);
        Test.startTest();
        
        system.runAs(pcommStandard) {			 
        	try {
        		Department__c department = [SELECT Id FROM Department__c limit 1];
		    	ApexPages.StandardController stdController = new ApexPages.StandardController(period);
				ViewReviewPeriodController controller = new ViewReviewPeriodController(stdController);
				
				controller.getShowAdminOptions();
				controller.initReviewPeriod();
				controller.getNewReview();	
				controller.launchReview();
				
				ReviewPeriodDepartment__c rpd = controller.getNewSingleDepartment();
				System.assert(rpd != null);
				rpd.Department__c = department.Id;
				controller.launchReviewForDepartment();
			} catch (Exception e) {
	            System.debug(' ****************** execute_ViewReviewPeriodController12 * ');
	            System.debug(e.getMessage());
			}
        }
        
		Test.stopTest();
	}		
	
	public static testMethod void execute_ViewReviewPeriodController13() {
		       
        GenerateEnvironmentTest10.genPerformanceReviewPeriod();
        //GenerateEnvironmentTest10.createV2MOMIndividualQ3Q4Data();
        GenerateEnvironmentTest3.getEmployeeStandard();
        PerformanceReviewPeriod__c period = GenerateEnvironmentTest10.PRPIndividualQ3Q4;
        System.assert(period != null);
        
        User pcommStandard = GenerateEnvironmentTest10.pcommStandard;
        System.assert(pcommStandard != null);
        
        Test.startTest();
        
        try {
        	Department__c department = [SELECT Id FROM Department__c limit 1];
	        system.runAs(pcommStandard) {			 
	        	
		    	ApexPages.StandardController stdController = new ApexPages.StandardController(period);
				ViewReviewPeriodController controller = new ViewReviewPeriodController(stdController);
				
				controller.getShowAdminOptions();
				controller.initReviewPeriod();
				controller.getNewReview();	
				controller.launchReview();
				
				ReviewPeriodDepartment__c rpd = controller.getNewSingleDepartment();
				System.assert(rpd != null);
				rpd.Department__c = department.Id;
				controller.launchReviewForDepartment();
	        }
		} catch (Exception e) {
            System.debug(' ****************** execute_ViewReviewPeriodController13 * ');
            System.debug(e.getMessage());
		}
        
		Test.stopTest();
	}		

	
	public static testMethod void execute_ViewReviewPeriodController14() {
		       
        GenerateEnvironmentTest10.genPerformanceReviewPeriod();
        //GenerateEnvironmentTest10.createV2MOMIndividualQ3Q4Data();
        
        PerformanceReviewPeriod__c period = GenerateEnvironmentTest10.PRPIndividual;
        System.assert(period != null);
        
        User pcommStandard = GenerateEnvironmentTest10.pcommStandard;
        System.assert(pcommStandard != null);
        Test.startTest();
        
        try {
        	Department__c department = [SELECT Id FROM Department__c limit 1];
	        system.runAs(pcommStandard) {			 				
		    	ApexPages.StandardController stdController = new ApexPages.StandardController(period);
				ViewReviewPeriodController controller = new ViewReviewPeriodController(stdController);
				
				controller.getShowAdminOptions();
				controller.initReviewPeriod();
				controller.getNewReview();	
				controller.launchReview();
				
				ReviewPeriodDepartment__c rpd = controller.getNewSingleDepartment();
				System.assert(rpd != null);
				rpd.Department__c = department.Id;
				controller.launchReviewForDepartment();
				// ************** Launch Review For Department Ad Hoc ************** \\
				controller.launchReviewForDepartmentAdHoc();
				controller.getPRPPrefix();
				controller.getPerformanceReviewsTypes();
				controller.getIsAdHoc();
	        }
		} catch (Exception e) {
            System.debug(' ****************** execute_ViewReviewPeriodController14 * ');
            System.debug(e.getMessage());
		}
        
		Test.stopTest();
	}
	
	
	
			

}