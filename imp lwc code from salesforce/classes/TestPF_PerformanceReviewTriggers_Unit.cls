@isTest
private class TestPF_PerformanceReviewTriggers_Unit {
  
	public static testMethod void execute_PerformanceReviewTriggers() {     
	
		GenerateEnvironmentTest8.genPerformanceReviewTriggers();
		  
		Test.startTest();
        try {
	
			User employee = GenerateEnvironmentTest8.employeeSupport;
			User secondManager = GenerateEnvironmentTest8.reviewManagerSupport;
			PerformanceReview__c pr = GenerateEnvironmentTest8.PRAdHoc;
			
			insert pr;
			
			MethodReview__c mre = new MethodReview__c ( PerformanceReview__c = pr.Id,
	                                					Reviewer__c = employee.Id,
	                                					Comment__c = 'Hello Method Review');
	        insert mre;
	                             					
			CompetencyReview__c cre = new CompetencyReview__c ( PerformanceReview__c = pr.Id,
		                                    					Reviewer__c = employee.Id,
		                                    					Comment__c = 'Hello Competency Review');
			insert cre;
			
			AdditionalComment__c ace = new AdditionalComment__c(PerformanceReview__c = pr.Id,
		                                    					Reviewer__c = employee.Id,
		                                    					Comment__c = 'Hello Additional Comment');
			insert ace;
			
		} catch (Exception e) {
            System.debug(' ****************** execute_PerformanceReviewTriggers * ');
            System.debug(e.getMessage());
		}
		Test.stopTest();
	}
	
	public static testMethod void execute_PerformanceReviewTriggers2() {     
	
		GenerateEnvironmentTest8.genPerformanceReviewTriggers();
		Test.startTest();
		
        try {
			User employee = GenerateEnvironmentTest8.employeeSupport;
			User secondManager = GenerateEnvironmentTest8.reviewManagerSupport;
			PerformanceReview__c pr = GenerateEnvironmentTest8.PRAdHocDB; 
			pr.PreviousStatus__c = pr.Status__c;
			pr.Status__c = 'Employee Self Assessment';			
			update pr;
			
			MethodReview__c mrm = new MethodReview__c ( PerformanceReview__c = pr.Id,
	                                					Reviewer__c = employee.ReviewManager__c,
	                                					Comment__c = 'Hello Method Review Manager');
	        insert mrm;
		} catch (Exception e) {
            System.debug(' ****************** execute_PerformanceReviewTriggers2 * ');
            System.debug(e.getMessage());
		}
     	Test.stopTest();   
	}
	
	public static testMethod void execute_PerformanceReviewTriggers3() {     
	
		GenerateEnvironmentTest8.genPerformanceReviewTriggers();
		Test.startTest();
		
        try {
			User employee = GenerateEnvironmentTest8.employeeSupport;
			User secondManager = GenerateEnvironmentTest8.reviewManagerSupport;
			PerformanceReview__c pr = GenerateEnvironmentTest8.PRAdHocDB; 
			
	        ReviewRating__c rrm = new ReviewRating__c ( PerformanceReview__c = pr.Id,
	                                					Reviewer__c = employee.ReviewManager__c,
	                                					CalculatedRating__c = 3.0,
	                                					OverallRating__c = 3.0);
	        insert rrm;
	        
	        ScorecardSupportComment__c sscm = new ScorecardSupportComment__c (  PerformanceReview__c = pr.Id,
							                                					Reviewer__c = employee.ReviewManager__c,
							                                					CommentCS__c = 'Hello Scorecard Support Comment Manager');
	        insert sscm;
	        
	        ScorecardSupportReview__c ssrm = new ScorecardSupportReview__c (PerformanceReview__c = pr.Id,
						                                					Reviewer__c = employee.ReviewManager__c,
						                                					PerformanceReviewPeriod__c = GenerateEnvironmentTest8.PRPAdHoc.Id, 
						                                					FiscalQuarter__c = 'Q1');
	        insert ssrm;
		} catch (Exception e) {
            System.debug(' ****************** execute_PerformanceReviewTriggers3 * ');
            System.debug(e.getMessage());
		}
	        
		Test.stopTest(); 
	}
	
	public static testMethod void execute_PerformanceReviewTriggers4() {     
			
		GenerateEnvironmentTest8.genPerformanceReviewTriggers();
		Test.startTest();
		
        try {
			User employee = GenerateEnvironmentTest8.employeeSupport;
			User secondManager = GenerateEnvironmentTest8.reviewManagerSupport;
			PerformanceReview__c pr = GenerateEnvironmentTest8.PRAdHocDB; 
		
			pr.PreviousStatus__c = 'Manager Assessment';
			pr.Status__c = '3rd Party Assessment';			
			update pr;
		} catch (Exception e) {
            System.debug(' ****************** execute_PerformanceReviewTriggers4 * ');
            System.debug(e.getMessage());
		}
		
		Test.stopTest();
	}	
	public static testMethod void execute_PerformanceReviewTriggers5() {     
			
		GenerateEnvironmentTest8.genPerformanceReviewTriggers();
		Test.startTest();
        try {
			User employee = GenerateEnvironmentTest8.employeeSupport;
			User secondManager = GenerateEnvironmentTest8.reviewManagerSupport;
			PerformanceReview__c pr = GenerateEnvironmentTest8.PRAdHocDB; 
			
			pr.PreviousStatus__c = pr.Status__c;
			pr.Status__c = 'Manager Assessment';	
			if (secondManager != null) 
				pr.Manager__c = secondManager.ReviewManager__c; 		
			update pr;
		}catch (Exception e) {
            System.debug(' ****************** execute_PerformanceReviewTriggers5 * ');
            System.debug(e.getMessage());
		}
		Test.stopTest();
	}
	
	public static testMethod void execute_PerformanceReviewTriggers6() {     
			
		GenerateEnvironmentTest8.genPerformanceReviewTriggers();
		Test.startTest();
		
        try {
			User employee = GenerateEnvironmentTest8.employeeSupport;
			User secondManager = GenerateEnvironmentTest8.reviewManagerSupport;
			PerformanceReview__c pr = GenerateEnvironmentTest8.PRAdHocDB; 
			pr.PreviousStatus__c = 'Employee Approval';
			pr.Status__c = 'Complete';			
			update pr;
		} catch (Exception e) {
            System.debug(' ****************** execute_PerformanceReviewTriggers6 * ');
            System.debug(e.getMessage());
		}
		
		Test.stopTest();
	}

}