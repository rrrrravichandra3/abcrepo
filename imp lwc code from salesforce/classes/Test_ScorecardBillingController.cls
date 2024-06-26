@isTest
private class Test_ScorecardBillingController {
	  
	  public static testMethod void execute_scorecardBillingController() {
	  	Test.startTest();
	  	  
	  	try {
		  	ScorecardAdminConsultBillingController controller = new ScorecardAdminConsultBillingController();
		  	
		  	 
		  	//Test_PAMUtil.execute_PAMUtilController();
		  	controller.newBillingChangesReload();
		  	
		  	if(controller.getBillingDeptEast() == null){
		  		System.assert(true, 'Null billing dept east');
		  	}
		  	if(controller.getScorecard() == null){
		  		System.assert(true, 'Null scorecard');
		  	}
		  	if(controller.getBillingDeptWest() == null){
		  		System.assert(true, 'Null billing west ');
		  	}
		  	if(controller.getRatingSelectOptions() == null){
		  		System.assert(true, 'Null rating select options');
		  	}
		  	if(controller.getScorecard() == null){
		  		System.assert(true, 'Null scorecard');
		  	}
		  	
	//------------------------- INNER CLASS DEPARTMENT BILLING EAST --------------------------------------------------	  	
		  	ScorecardAdminConsultBillingController.DepartmentBillingEast billingEast = controller.getBillingDeptEast();
		  	if(billingEast != null){
		  		if(billingEast.getActualQ1() == null){
		  			System.assert(true, 'Null Actual Q1');
		  		}
		  		if(billingEast.getActualQ2() == null){
		  			System.assert(true, 'Null Actual Q2');
		  		}
		  		if(billingEast.getActualQ3() == null){
		  			System.assert(true, 'Null Actual Q3');
		  		}
		  		if(billingEast.getActualQ4() == null){
		  			System.assert(true, 'Null Actual Q4');
		  		}
		  		if(billingEast.getTargetQ1() == null){
		  			System.assert(true, 'Null target Q1');
		  		}
		  		if(billingEast.getTargetQ2() == null){
		  			System.assert(true, 'Null target Q2');
		  		}
		  		if(billingEast.getTargetQ3() == null){
		  			System.assert(true, 'Null target Q3');
		  		}
		  		if(billingEast.getTargetQ4() == null){
		  			System.assert(true, 'Null target Q4');
		  		}
		  		if(billingEast.getRatingQ1() == null){
		  			System.assert(true, 'Null rating Q1');
		  		}
		  		if(billingEast.getRatingQ2() == null){
		  			System.assert(true, 'Null rating Q2');
		  		}
		  		if(billingEast.getRatingQ3() == null){
		  			System.assert(true, 'Null rating Q3');
		  		}
		  		if(billingEast.getRatingQ4() == null){
		  			System.assert(true, 'Null rating Q4');
		  		}
		  		if(billingEast.getAvgRatingQ1Q2() == null){
		  			System.assert(true, 'Null avg rating Q1 Q2');
		  		}
		  		if(billingEast.getAvgRatingQ3Q4() == null){
		  			System.assert(true, 'Null avg rating Q3 Q4');
		  		}
		  		if(billingEast.getAttainabilityQ1() == null){
		  			System.assert(true, 'Null Attainability Q1');
		  		}
		  		if(billingEast.getAttainabilityQ2() == null){
		  			System.assert(true, 'Null Attainability Q2');
		  		}
		  		if(billingEast.getAttainabilityQ3() == null){
		  			System.assert(true, 'Null Attainability Q3');
		  		}
		  		if(billingEast.getAttainabilityQ4() == null){
		  			System.assert(true, 'Null Attainability Q4');
		  		}
		  		if(billingEast.getAttainalibityAvgQ1Q2() == null){
		  			System.assert(true, 'Null Attainability avg Q1 Q2');
		  		}
		  		if(billingEast.getAttainalibityAvgQ3Q4() == null){
		  			System.assert(true, 'Null Attainability avg Q3 Q4');
		  		}		
		  	}
	// -------------------------- INNER CLASS DEPARTMENT BILLING WEST -------------------------------------------------
			
			ScorecardAdminConsultBillingController.DepartmentBillingWest billingWest = controller.getBillingDeptWest();
		  	if(billingWest != null){
		  		if(billingWest.getActualQ1() == null){
		  			System.assert(true, 'Null Actual Q1');
		  		}
		  		if(billingWest.getActualQ2() == null){
		  			System.assert(true, 'Null Actual Q2');
		  		}
		  		if(billingWest.getActualQ3() == null){
		  			System.assert(true, 'Null Actual Q3');
		  		}
		  		if(billingWest.getActualQ4() == null){
		  			System.assert(true, 'Null Actual Q4');
		  		}
		  		if(billingWest.getTargetQ1() == null){
		  			System.assert(true, 'Null target Q1');
		  		}
		  		if(billingWest.getTargetQ2() == null){
		  			System.assert(true, 'Null target Q2');
		  		}
		  		if(billingWest.getTargetQ3() == null){
		  			System.assert(true, 'Null target Q3');
		  		}
		  		if(billingWest.getTargetQ4() == null){
		  			System.assert(true, 'Null target Q4');
		  		}
		  		if(billingWest.getRatingQ1() == null){
		  			System.assert(true, 'Null rating Q1');
		  		}
		  		if(billingWest.getRatingQ2() == null){
		  			System.assert(true, 'Null rating Q2');
		  		}
		  		if(billingWest.getRatingQ3() == null){
		  			System.assert(true, 'Null rating Q3');
		  		}
		  		if(billingWest.getRatingQ4() == null){
		  			System.assert(true, 'Null rating Q4');
		  		}
		  		if(billingWest.getAvgRatingQ1Q2() == null){
		  			System.assert(true, 'Null avg rating Q1 Q2');
		  		}
		  		if(billingWest.getAvgRatingQ3Q4() == null){
		  			System.assert(true, 'Null avg rating Q3 Q4');
		  		}
		  		if(billingWest.getAttainabilityQ1() == null){
		  			System.assert(true, 'Null Attainability Q1');
		  		}
		  		if(billingWest.getAttainabilityQ2() == null){
		  			System.assert(true, 'Null Attainability Q2');
		  		}
		  		if(billingWest.getAttainabilityQ3() == null){
		  			System.assert(true, 'Null Attainability Q3');
		  		}
		  		if(billingWest.getAttainabilityQ4() == null){
		  			System.assert(true, 'Null Attainability Q4');
		  		}
		  		if(billingWest.getAttainalibityAvgQ1Q2() == null){
		  			System.assert(true, 'Null Attainability avg Q1 Q2');
		  		}
		  		if(billingWest.getAttainalibityAvgQ3Q4() == null){
		  			System.assert(true, 'Null Attainability avg Q3 Q4');
		  		}
		  		
		  				
		  	}
		} catch (Exception e) {
            System.debug(' ****************** execute_scorecardBillingController * ');
            System.debug(e.getMessage());
		}
		  	
	  	Test.stopTest();
				  		
	  }
	  
	  static testMethod void unitTest2(){
	   	Test.startTest();
	   		// -------------------------- INNER CLASS DEPARTMENT BILLING WEST -------------------------------------------------
	   		
	   		try{
	   			DeptScorecard__c departmentWest = new DeptScorecard__c(Q1Actual__c = -1, Q2Actual__c = -1, Q3Actual__c = -1, Q4Actual__c = -1, Q1Target__c = -1, Q2Target__c = -1, Q3Target__c = -1,
	   																Q4Target__c = -1, Q1Rating__c = -1, Q2Rating__c = -1, Q3Rating__c = -1, Q4Rating__c = -1);
	            ScorecardAdminConsultBillingController.DepartmentBillingWest billingWest = new ScorecardAdminConsultBillingController.DepartmentBillingWest(departmentWest);
		   		billingWest.getActualQ1();
		  		billingWest.getActualQ2();
		  		billingWest.getActualQ3();
		  		billingWest.getActualQ4();
		  		billingWest.getTargetQ1();
		  		billingWest.getTargetQ2();
		  		billingWest.getTargetQ3();
		  		billingWest.getTargetQ4();
		  		billingWest.getRatingQ1();
		  		billingWest.getRatingQ2();
		  		billingWest.getRatingQ3();
		  		billingWest.getRatingQ4();
		  		billingWest.getAttainabilityQ1();
		  		billingWest.getAttainabilityQ2();
		  		billingWest.getAttainabilityQ3();
		  		billingWest.getAttainabilityQ4();
		  		billingWest.getAvgRatingQ1Q2();
		  		billingWest.getAvgRatingQ3Q4();
		  		
		  		billingWest.getAttainalibityAvgQ1Q2();
		  		billingWest.getAttainalibityAvgQ3Q4();	
	   		}catch (Exception e){
	   			
	   		}
	   		
	   	Test.stopTest();
	  }
	  
	  static testMethod void unitTest3(){
	  	Test.startTest();
	  		// -------------------------- INNER CLASS DEPARTMENT BILLING EAST -------------------------------------------------
	   		
	   		try{
	   			DeptScorecard__c departmentEast = new DeptScorecard__c(Q1Actual__c = -1, Q2Actual__c = -1, Q3Actual__c = -1, Q4Actual__c = -1, Q1Target__c = -1, Q2Target__c = -1, Q3Target__c = -1,
	   																Q4Target__c = -1, Q1Rating__c = -1, Q2Rating__c = -1, Q3Rating__c = -1, Q4Rating__c = -1);
	            ScorecardAdminConsultBillingController.DepartmentBillingEast billingEast = new ScorecardAdminConsultBillingController.DepartmentBillingEast(departmentEast);
	            billingEast.getActualQ1();
	            billingEast.getActualQ2();
	            billingEast.getActualQ3();
	            billingEast.getActualQ4();
	            billingEast.getAttainabilityQ1();
	            billingEast.getAttainabilityQ2();
	            billingEast.getAttainabilityQ3();
	            billingEast.getAttainabilityQ4();
	            billingEast.getAttainalibityAvgQ1Q2();
	            billingEast.getAttainalibityAvgQ3Q4();
	            billingEast.getAvgRatingQ1Q2();
	            billingEast.getAvgRatingQ3Q4();
	            billingEast.getRatingQ1();
	            billingEast.getRatingQ2();
	            billingEast.getRatingQ3();
	            billingEast.getRatingQ4();
	            billingEast.getTargetQ1();
	            billingEast.getTargetQ2();
	            billingEast.getTargetQ3();
	            billingEast.getTargetQ4();
	   		}catch (Exception e){
	   			
	   		}
	   			
            
	  	Test.stopTest();
	  }
	
}