@isTest
private class TestPF_ScorecardAdminConsultingMT_Unit {
	     
	  public static testMethod void execute_scorecardBillingController() {
	  	  
	    Scorecard__c sc = new Scorecard__c();
        sc.EffectiveDate__c = 'FY08';
        sc.Department__c = 'Consulting';
        sc.Type__c = 'Margin Target';
         
        insert sc;
           
        DeptScorecard__c deptEast = new DeptScorecard__c();
        deptEast.Zone__c = 'East';
        deptEast.Scorecard__c = sc.Id;
        deptEast.Q1Actual__c = 1;
        deptEast.Q1Rating__c = 1;
        deptEast.Q1Target__c = 1;
        deptEast.Q2Actual__c = 1;
        deptEast.Q2Rating__c = 1;
        deptEast.Q2Target__c = 1;
        deptEast.Q3Actual__c = 1;
        deptEast.Q3Rating__c = 1;
        deptEast.Q3Target__c = 1;
        deptEast.Q4Actual__c = 1;
        deptEast.Q4Rating__c = 1;
        deptEast.Q4Target__c = 1;
        
        insert deptEast;
        
        DeptScorecard__c deptWest = new DeptScorecard__c();
        deptWest.Zone__c = 'West';
        deptWest.Scorecard__c = sc.Id;
        
        deptWest.Q1Actual__c = 1;
        deptWest.Q1Rating__c = 1;
        deptWest.Q1Target__c = 1;
        deptWest.Q2Actual__c = 1;
        deptWest.Q2Rating__c = 1;
        deptWest.Q2Target__c = 1;
        deptWest.Q3Actual__c = 1;
        deptWest.Q3Rating__c = 1;
        deptWest.Q3Target__c = 1;
        deptWest.Q4Actual__c = 1;
        deptWest.Q4Rating__c = 1;
        deptWest.Q4Target__c = 1;
        
        insert deptWest;
        
	  	Test.startTest();
	  	 
	  	try {
		  	ScorecardAdminConsultingMTController controller = new ScorecardAdminConsultingMTController();
		  	
		  	controller.newMarginTargetChangesReload();
		  	controller.getMarginTargetDeptEast();
		  	controller.getScorecard();
		  	controller.getMarginTargetDeptWest();
		  	controller.getRatingSelectOptions();
		  	
		  	ScorecardAdminConsultingMTController.DepartmentMarginTargetEast departmentEast = controller.getMarginTargetDeptEast();
		  	ScorecardAdminConsultingMTController.DepartmentMarginTargetWest departmentWest = controller.getMarginTargetDeptWest();
		  	
		  	departmentEast.getActualQ1();
		  	departmentEast.getActualQ2();
		  	departmentEast.getActualQ3();
		  	departmentEast.getActualQ4();
		  	departmentEast.getTargetQ1();
		  	departmentEast.getTargetQ2();
		  	departmentEast.getTargetQ3();
		  	departmentEast.getTargetQ4();
		  	departmentEast.getRatingQ1();
		  	departmentEast.getRatingQ2();
		  	departmentEast.getRatingQ3();
		  	departmentEast.getRatingQ4();
		  	departmentEast.getAvgRatingQ1Q2();
		  	departmentEast.getAvgRatingQ3Q4();
		  	departmentEast.getAttainabilityQ1();
		  	departmentEast.getAttainabilityQ2();
		  	departmentEast.getAttainabilityQ3();
		  	departmentEast.getAttainabilityQ4();
		  	departmentEast.getAttainalibityAvgQ1Q2();
		  	departmentEast.getAttainalibityAvgQ3Q4();
		  	
		  		
		  	departmentWest.getActualQ1();
		  	departmentWest.getActualQ2();
		  	departmentWest.getActualQ3();
		  	departmentWest.getActualQ4();
		  	departmentWest.getTargetQ1();
		  	departmentWest.getTargetQ2();
		  	departmentWest.getTargetQ3();
		  	departmentWest.getTargetQ4();
		  	departmentWest.getRatingQ1();
		  	departmentWest.getRatingQ2();
		  	departmentWest.getRatingQ3();
		  	departmentWest.getRatingQ4();
		  	departmentWest.getAvgRatingQ1Q2();
		  	departmentWest.getAvgRatingQ3Q4();
		  	departmentWest.getAttainabilityQ1();
		  	departmentWest.getAttainabilityQ2();
		  	departmentWest.getAttainabilityQ3();
		  	departmentWest.getAttainabilityQ4();
		  	departmentWest.getAttainalibityAvgQ1Q2();
		  	departmentWest.getAttainalibityAvgQ3Q4();
		  	
		  	
		  	
		  
		  	}
		 catch (Exception e) {
            System.debug(' ****************** execute_scorecardBillingController * ');
            System.debug(e.getMessage());
		}
		  	
	  	Test.stopTest();
				  		
	  }
	
	public static testMethod void execute_scorecardBillingController1() {
	  	  
	    Scorecard__c sc = new Scorecard__c();
        sc.EffectiveDate__c = 'FY08';
        sc.Department__c = 'Consulting';
        sc.Type__c = 'Margin Target';
        
        insert sc;
         
        
        DeptScorecard__c deptEast = new DeptScorecard__c();
        deptEast.Zone__c = 'East';
        deptEast.Scorecard__c = sc.Id;
        deptEast.Q1Actual__c = 0;
        deptEast.Q1Rating__c = 0;
        deptEast.Q1Target__c = 0;
        deptEast.Q2Actual__c = 0;
        deptEast.Q2Rating__c = 0;
        deptEast.Q2Target__c = 0;
        deptEast.Q3Actual__c = 0;
        deptEast.Q3Rating__c = 0;
        deptEast.Q3Target__c = 0;
        deptEast.Q4Actual__c = 0;
        deptEast.Q4Rating__c = 0;
        deptEast.Q4Target__c = 0;
        
        insert deptEast;
        
        DeptScorecard__c deptWest = new DeptScorecard__c();
        deptWest.Zone__c = 'West';
        deptWest.Scorecard__c = sc.Id;
        
        deptWest.Q1Actual__c = 0;
        deptWest.Q1Rating__c = 0;
        deptWest.Q1Target__c = 0;
        deptWest.Q2Actual__c = 0;
        deptWest.Q2Rating__c = 0;
        deptWest.Q2Target__c = 0;
        deptWest.Q3Actual__c = 0;
        deptWest.Q3Rating__c = 0;
        deptWest.Q3Target__c = 0;
        deptWest.Q4Actual__c = 0;
        deptWest.Q4Rating__c = 0;
        deptWest.Q4Target__c = 0;
        
        insert deptWest;
        
	  	Test.startTest();
	  	 
	  	try {
		  	ScorecardAdminConsultingMTController controller = new ScorecardAdminConsultingMTController();
		  	
		  	controller.newMarginTargetChangesReload();
		  	controller.getMarginTargetDeptEast();
		  	controller.getScorecard();
		  	controller.getMarginTargetDeptWest();
		  	controller.getRatingSelectOptions();
		  	
		  	ScorecardAdminConsultingMTController.DepartmentMarginTargetEast departmentEast = controller.getMarginTargetDeptEast();
		  	ScorecardAdminConsultingMTController.DepartmentMarginTargetWest departmentWest = controller.getMarginTargetDeptWest();
		  	
		  	departmentEast.getActualQ1();
		  	departmentEast.getActualQ2();
		  	departmentEast.getActualQ3();
		  	departmentEast.getActualQ4();
		  	departmentEast.getTargetQ1();
		  	departmentEast.getTargetQ2();
		  	departmentEast.getTargetQ3();
		  	departmentEast.getTargetQ4();
		  	departmentEast.getRatingQ1();
		  	departmentEast.getRatingQ2();
		  	departmentEast.getRatingQ3();
		  	departmentEast.getRatingQ4();
		  	departmentEast.getAvgRatingQ1Q2();
		  	departmentEast.getAvgRatingQ3Q4();
		  	departmentEast.getAttainabilityQ1();
		  	departmentEast.getAttainabilityQ2();
		  	departmentEast.getAttainabilityQ3();
		  	departmentEast.getAttainabilityQ4();
		  	departmentEast.getAttainalibityAvgQ1Q2();
		  	departmentEast.getAttainalibityAvgQ3Q4();
		  	
		  		
		  	departmentWest.getActualQ1();
		  	departmentWest.getActualQ2();
		  	departmentWest.getActualQ3();
		  	departmentWest.getActualQ4();
		  	departmentWest.getTargetQ1();
		  	departmentWest.getTargetQ2();
		  	departmentWest.getTargetQ3();
		  	departmentWest.getTargetQ4();
		  	departmentWest.getRatingQ1();
		  	departmentWest.getRatingQ2();
		  	departmentWest.getRatingQ3();
		  	departmentWest.getRatingQ4();
		  	departmentWest.getAvgRatingQ1Q2();
		  	departmentWest.getAvgRatingQ3Q4();
		  	departmentWest.getAttainabilityQ1();
		  	departmentWest.getAttainabilityQ2();
		  	departmentWest.getAttainabilityQ3();
		  	departmentWest.getAttainabilityQ4();
		  	departmentWest.getAttainalibityAvgQ1Q2();
		  	departmentWest.getAttainalibityAvgQ3Q4();
		  	
		  	
		  	
		  
		  	}
		 catch (Exception e) {
            System.debug(' ****************** execute_scorecardBillingController * ');
            System.debug(e.getMessage());
		}
		  	
	  	Test.stopTest();
				  		
	  }
	  
	  public static testMethod void execute_scorecardBillingController2() {
	  	  
	    Scorecard__c sc = new Scorecard__c();
        sc.EffectiveDate__c = 'FY08';
        sc.Department__c = 'Consulting';
        sc.Type__c = 'Margin Target';
        
        insert sc;
         
        
        DeptScorecard__c deptEast = new DeptScorecard__c();
        deptEast.Zone__c = 'East';
        deptEast.Scorecard__c = sc.Id;
        deptEast.Q1Actual__c = -1;
        deptEast.Q1Rating__c = -1;
        deptEast.Q1Target__c = -1;
        deptEast.Q2Actual__c = -1;
        deptEast.Q2Rating__c = -1;
        deptEast.Q2Target__c = -1;
        deptEast.Q3Actual__c = -1;
        deptEast.Q3Rating__c = -1;
        deptEast.Q3Target__c = -1;
        deptEast.Q4Actual__c = -1;
        deptEast.Q4Rating__c = -1;
        deptEast.Q4Target__c = -1;
        
        insert deptEast;
        
        DeptScorecard__c deptWest = new DeptScorecard__c();
        deptWest.Zone__c = 'West';
        deptWest.Scorecard__c = sc.Id;
        
        deptWest.Q1Actual__c = -1;
        deptWest.Q1Rating__c = -1;
        deptWest.Q1Target__c = -1;
        deptWest.Q2Actual__c = -1;
        deptWest.Q2Rating__c = -1;
        deptWest.Q2Target__c = -1;
        deptWest.Q3Actual__c = -1;
        deptWest.Q3Rating__c = -1;
        deptWest.Q3Target__c = -1;
        deptWest.Q4Actual__c = -1;
        deptWest.Q4Rating__c = -1;
        deptWest.Q4Target__c = -1;
        
        insert deptWest;
        
	  	Test.startTest();
	  	 
	  	try {
		  	ScorecardAdminConsultingMTController controller = new ScorecardAdminConsultingMTController();
		  	
		  	controller.newMarginTargetChangesReload();
		  	controller.getMarginTargetDeptEast();
		  	controller.getScorecard();
		  	controller.getMarginTargetDeptWest();
		  	controller.getRatingSelectOptions();
		  	
		  	ScorecardAdminConsultingMTController.DepartmentMarginTargetEast departmentEast = controller.getMarginTargetDeptEast();
		  	ScorecardAdminConsultingMTController.DepartmentMarginTargetWest departmentWest = controller.getMarginTargetDeptWest();
		  	
		  	departmentEast.getActualQ1();
		  	departmentEast.getActualQ2();
		  	departmentEast.getActualQ3();
		  	departmentEast.getActualQ4();
		  	departmentEast.getTargetQ1();
		  	departmentEast.getTargetQ2();
		  	departmentEast.getTargetQ3();
		  	departmentEast.getTargetQ4();
		  	departmentEast.getRatingQ1();
		  	departmentEast.getRatingQ2();
		  	departmentEast.getRatingQ3();
		  	departmentEast.getRatingQ4();
		  	departmentEast.getAvgRatingQ1Q2();
		  	departmentEast.getAvgRatingQ3Q4();
		  	departmentEast.getAttainabilityQ1();
		  	departmentEast.getAttainabilityQ2();
		  	departmentEast.getAttainabilityQ3();
		  	departmentEast.getAttainabilityQ4();
		  	departmentEast.getAttainalibityAvgQ1Q2();
		  	departmentEast.getAttainalibityAvgQ3Q4();
		  	
		  		
		  	departmentWest.getActualQ1();
		  	departmentWest.getActualQ2();
		  	departmentWest.getActualQ3();
		  	departmentWest.getActualQ4();
		  	departmentWest.getTargetQ1();
		  	departmentWest.getTargetQ2();
		  	departmentWest.getTargetQ3();
		  	departmentWest.getTargetQ4();
		  	departmentWest.getRatingQ1();
		  	departmentWest.getRatingQ2();
		  	departmentWest.getRatingQ3();
		  	departmentWest.getRatingQ4();
		  	departmentWest.getAvgRatingQ1Q2();
		  	departmentWest.getAvgRatingQ3Q4();
		  	departmentWest.getAttainabilityQ1();
		  	departmentWest.getAttainabilityQ2();
		  	departmentWest.getAttainabilityQ3();
		  	departmentWest.getAttainabilityQ4();
		  	departmentWest.getAttainalibityAvgQ1Q2();
		  	departmentWest.getAttainalibityAvgQ3Q4();
		  	
		  	
		  	
		  
		  	}
		 catch (Exception e) {
            System.debug(' ****************** execute_scorecardBillingController * ');
            System.debug(e.getMessage());
		}
		  	
	  	Test.stopTest();
				  		
	  }
}