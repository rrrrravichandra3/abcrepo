@isTest
private class TestPF_PerformanceRwShrngManager_Unit {
  
	public static testMethod void execute_PerformanceReviewSharingManager01() {  
		GenerateEnvironmentTest2.genAllObjects();		
		PerformanceReview__c pr12 = GenerateEnvironmentTest2.PRQ1Q2;
		
		Test.startTest();
          
        try {
			pr12 = GenerateEnvironmentTest2.changeStatusPReview(pr12, 'Created', 'Employee Self Assessment');			
		} catch (Exception e) {
            System.debug(' ****************** execute_PerformanceReviewSharingManager01 * ');
            System.debug(e.getMessage());
		}
				
		Test.stopTest();
		
	}
	
	
	public static testMethod void execute_PerformanceReviewSharingManager02() {   
		GenerateEnvironmentTest2.genAllObjects();		
		PerformanceReview__c pr = GenerateEnvironmentTest2.PREmplAssmnt;
		
		Test.startTest();
        
        try {
			pr = GenerateEnvironmentTest2.changeStatusPReview(pr, 'Employee Self Assessment', 'Manager Assessment');	
		} catch (Exception e) {
            System.debug(' ****************** execute_PerformanceReviewSharingManager02 * ');
            System.debug(e.getMessage());
		}
		
		Test.stopTest();
		
	}	
	
	
	public static testMethod void execute_PerformanceReviewSharingManager03() {     
		GenerateEnvironmentTest2.genAllObjects();		
		PerformanceReview__c pr = GenerateEnvironmentTest2.PRMngrAssmnt;
		
		Test.startTest();
        
        try {
			pr = GenerateEnvironmentTest2.changeStatusPReview(pr, 'Manager Assessment', 'Employee Self Assessment');
		} catch (Exception e) {
            System.debug(' ****************** execute_PerformanceReviewSharingManager03 * ');
            System.debug(e.getMessage());
		}
		
		Test.stopTest();
		
	}
	
	
	public static testMethod void execute_PerformanceReviewSharingManager04() {   
		GenerateEnvironmentTest2.genAllObjects();		
		PerformanceReview__c pr = GenerateEnvironmentTest2.PRMngrAssmnt;
		
		Test.startTest();
        
        try {
			pr = GenerateEnvironmentTest2.changeStatusPReview(pr, 'Manager Assessment', '2nd Level Manager Assessment');
		} catch (Exception e) {
            System.debug(' ****************** execute_PerformanceReviewSharingManager04 * ');
            System.debug(e.getMessage());
		}
		
		Test.stopTest();
		
	}
		
	
	public static testMethod void execute_PerformanceReviewSharingManager05() { 
		GenerateEnvironmentTest2.genAllObjects();		
		PerformanceReview__c pr = GenerateEnvironmentTest2.PR2ndMngrAssmnt;
		
		Test.startTest();
        
        try {
			pr = GenerateEnvironmentTest2.changeStatusPReview(pr, '2nd Level Manager Assessment', 'Manager Assessment');
		} catch (Exception e) {
            System.debug(' ****************** execute_PerformanceReviewSharingManager05 * ');
            System.debug(e.getMessage());
		}
		
		Test.stopTest();
		
	}
		
		
	public static testMethod void execute_PerformanceReviewSharingManager06() {  
		GenerateEnvironmentTest2.genAllObjects();		
		PerformanceReview__c pr = GenerateEnvironmentTest2.PRMngrAssmnt;
		
		Test.startTest();
        
        try {
			pr = GenerateEnvironmentTest2.changeStatusPReview(pr, 'Manager Assessment', '3rd Party Assessment');
		} catch (Exception e) {
            System.debug(' ****************** execute_PerformanceReviewSharingManager06 * ');
            System.debug(e.getMessage());
		}
		
		Test.stopTest();
		
	}
	
				
	public static testMethod void execute_PerformanceReviewSharingManager07() {
		GenerateEnvironmentTest2.genAllObjects();		
		PerformanceReview__c pr = GenerateEnvironmentTest2.PR3rdParty;
		
		Test.startTest();
        
        try {
			pr = GenerateEnvironmentTest2.changeStatusPReview(pr, '3rd Party Assessment', 'Manager Assessment');
		} catch (Exception e) {
            System.debug(' ****************** execute_PerformanceReviewSharingManager07 * ');
            System.debug(e.getMessage());
		}
		
		Test.stopTest();
		
	}
			
				
	public static testMethod void execute_PerformanceReviewSharingManager08() { 
		GenerateEnvironmentTest2.genAllObjects();
		PerformanceReview__c pr = GenerateEnvironmentTest2.PR2ndMngrAssmnt;
		
		Test.startTest();
        
        try {
			pr = GenerateEnvironmentTest2.changeStatusPReview(pr, '2nd Level Manager Assessment', '3rd Party Assessment');
		} catch (Exception e) {
            System.debug(' ****************** execute_PerformanceReviewSharingManager08 * ');
            System.debug(e.getMessage());
		}
		
		Test.stopTest();
		
	}		
	
				
	public static testMethod void execute_PerformanceReviewSharingManager09() { 	
		GenerateEnvironmentTest2.genAllObjects();		
		PerformanceReview__c pr = GenerateEnvironmentTest2.PR3rdParty;
		
		Test.startTest();
        
        try {
			pr = GenerateEnvironmentTest2.changeStatusPReview(pr, '3rd Party Assessment', '2nd Level Manager Assessment');
		} catch (Exception e) {
            System.debug(' ****************** execute_PerformanceReviewSharingManager09 * ');
            System.debug(e.getMessage());
		}
		
		Test.stopTest();
		
	}		
			
				
	public static testMethod void execute_PerformanceReviewSharingManager10() {     
	
		GenerateEnvironmentTest2.genAllObjects();		
		PerformanceReview__c pr = GenerateEnvironmentTest2.PR2ndMngrAssmnt;
		
		Test.startTest();
        
        try {
			pr = GenerateEnvironmentTest2.changeStatusPReview(pr, '2nd Level Manager Assessment', 'Pending Employee Services');
		} catch (Exception e) {
            System.debug(' ****************** execute_PerformanceReviewSharingManager10 * ');
            System.debug(e.getMessage());
		}
		
		Test.stopTest();
		
	}		
				
				
	public static testMethod void execute_PerformanceReviewSharingManager11() {     	
		GenerateEnvironmentTest2.genAllObjects();		
		PerformanceReview__c pr = GenerateEnvironmentTest2.PRMngrAssmnt;
		
		Test.startTest();
        
        try {
			pr = GenerateEnvironmentTest2.changeStatusPReview(pr, 'Manager Assessment', 'Pending Employee Services');
		} catch (Exception e) {
            System.debug(' ****************** execute_PerformanceReviewSharingManager11 * ');
            System.debug(e.getMessage());
		}
		
		Test.stopTest();
		
	}					
			
	public static testMethod void execute_PerformanceReviewSharingManager12() {     	
		GenerateEnvironmentTest2.genAllObjects();		
		PerformanceReview__c pr = GenerateEnvironmentTest2.PREmplSelfAssmnt;
		
		Test.startTest();
        
        try {
			pr = GenerateEnvironmentTest2.changeStatusPReview(pr, 'Pending Employee Services', 'PCOMM Review');
		} catch (Exception e) {
            System.debug(' ****************** execute_PerformanceReviewSharingManager12 * ');
            System.debug(e.getMessage());
		}
		
		Test.stopTest();
		
	}			
			
	public static testMethod void execute_PerformanceReviewSharingManager13() {     	
		GenerateEnvironmentTest2.genAllObjects();		
		PerformanceReview__c pr = GenerateEnvironmentTest2.PRPCOMM;
		
		Test.startTest();
        
        try {
			pr = GenerateEnvironmentTest2.changeStatusPReview(pr, 'PCOMM Review', '2nd Level Manager Approval');
		} catch (Exception e) {
            System.debug(' ****************** execute_PerformanceReviewSharingManager13 * ');
            System.debug(e.getMessage());
		}
		
		Test.stopTest();
		
	}			
		
	public static testMethod void execute_PerformanceReviewSharingManager14() {     	
		GenerateEnvironmentTest2.genAllObjects();		
		PerformanceReview__c pr = GenerateEnvironmentTest2.PRPCOMM;
		
		Test.startTest();
        
        try {
			pr = GenerateEnvironmentTest2.changeStatusPReview(pr, 'PCOMM Review', 'Manager Approval');
		} catch (Exception e) {
            System.debug(' ****************** execute_PerformanceReviewSharingManager14 * ');
            System.debug(e.getMessage());
		}
		
		Test.stopTest();
		
	}		
			
	public static testMethod void execute_PerformanceReviewSharingManager15() {     	
		GenerateEnvironmentTest2.genAllObjects();		
		PerformanceReview__c pr = GenerateEnvironmentTest2.PRPCOMM; //to do
		
		Test.startTest();
        
        try {
			pr = GenerateEnvironmentTest2.changeStatusPReview(pr, 'Manager Approval', 'Employee Approval');
		} catch (Exception e) {
            System.debug(' ****************** execute_PerformanceReviewSharingManager15 * ');
            System.debug(e.getMessage());
		}
		
		Test.stopTest();
		
	}		
			
	public static testMethod void execute_PerformanceReviewSharingManager16() {   	
		GenerateEnvironmentTest2.genAllObjects();		
		PerformanceReview__c pr = GenerateEnvironmentTest2.PRPCOMM; // to do
		
		Test.startTest();
        
        try {
			pr = GenerateEnvironmentTest2.changeStatusPReview(pr, 'Employee Approval', 'Complete');
		} catch (Exception e) {
            System.debug(' ****************** execute_PerformanceReviewSharingManager16 * ');
            System.debug(e.getMessage());
		}
		
		Test.stopTest();
		
	}	
	
	public static testMethod void execute_PerformanceReviewSharingManager17() {     
		// change manager
		GenerateEnvironmentTest2.genAllObjects();		
		PerformanceReview__c pr = GenerateEnvironmentTest2.PREmplSelfAssmnt; 
		User newManager = GenerateEnvironmentTest2.managerStandard;
		
		Test.startTest();
        try {
	        
			pr.Manager__c = newManager.Id;
			update pr;
		} catch (Exception e) {
            System.debug(' ****************** execute_PerformanceReviewSharingManager17 * ');
            System.debug(e.getMessage());
		}
		
		Test.stopTest();
		
	}	
		
		
	public static testMethod void execute_PerformanceReviewSharingManager18() {   	
		GenerateEnvironmentTest2.genAllObjects();		
		PerformanceReview__c pr = GenerateEnvironmentTest2.PRQ3Q4; // to do
		
		Test.startTest();
        
        try {
			pr = GenerateEnvironmentTest2.changeStatusPReview(pr, 'Employee Approval', 'Complete');
		} catch (Exception e) {
            System.debug(' ****************** execute_PerformanceReviewSharingManager18 * ');
            System.debug(e.getMessage());
		}
		
		Test.stopTest();
		
	}	    		 
}