@isTest
private class TestPF_MetricEducation_Unit {
 	   
 	    
	  public static testMethod void execute_methods_ScorecardMetricEducationZero() {

		GenerateEnvironmentTest3.genScorecardMetricEducation();
		 
		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	   	  
	  	try{
		  	ScorecardMetricEducation controller = new ScorecardMetricEducation();
		  		
		  	if (controller.getperformanceR() == null){
		  		System.assert(false,'Null Performance Review');	  			
		  	}
	  	}catch(Exception e){ 
	  		System.debug(' NULL performance review Test_MetricEducation');
	  		System.debug(e.getMessage());
	  	}
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu);

		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
														'Created', 'Employee Self Assessment');
	  	System.assert(GenerateEnvironmentTest3.getEmployeeStandard() != null);
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu);
	  	
	  	Test.stopTest();
	  	
	}

 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationOne() {
	  	
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
		
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
														'Employee Self Assessment', 'Manager Assessment');
	  	System.assert(GenerateEnvironmentTest3.getEmployeeStandard() != null);
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu);
	  	
	  	Test.stopTest();
	  	
	}

 	  
	  public static testMethod void execute_methods_ScorecardMetricEducationTwo() {
	  	
		GenerateEnvironmentTest3.genScorecardMetricEducation();
	//	GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
		//												'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
														'Manager Assessment', '2nd Level Manager Assessment');
	  	System.assert(GenerateEnvironmentTest3.getSystemAdmin() != null);
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu);
	  	
	  	Test.stopTest();
	  	
	}
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationThree() {
	  	
	  	GenerateEnvironmentTest3.setEnvironmentVars(true, false, false, false, false, false, false);
		GenerateEnvironmentTest3.genScorecardMetricEducation();
	//	GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
		//												'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu);
	  	System.assert(GenerateEnvironmentTest3.getSystemAdmin() != null);
	  	Test.stopTest();
	  	
	}
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationFour() {
	  	
	  	GenerateEnvironmentTest3.setEnvironmentVars(false, true, false, false, false, false, false);
		GenerateEnvironmentTest3.genScorecardMetricEducation();
	//	GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
		//												'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	System.assert(GenerateEnvironmentTest3.getSystemAdmin() != null);
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu);
	  	
	  	Test.stopTest();
	  	
	}
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationFive() {
	  	
	  	GenerateEnvironmentTest3.setEnvironmentVars(false, false, true, false, false, false, false);
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		//GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
			//											'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 System.assert(GenerateEnvironmentTest3.getSystemAdmin() != null);
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu);
	  	
	  	Test.stopTest();
	  	
	}
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationSix() {
	  	
	  	GenerateEnvironmentTest3.setEnvironmentVars(false, false, false, true, false, false, false);
		GenerateEnvironmentTest3.genScorecardMetricEducation();
	//	GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
		//												'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 System.assert(GenerateEnvironmentTest3.getSystemAdmin() != null);
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu);
	  	
	  	Test.stopTest();
	  	
	}
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationSeven() {
	  	
	  	GenerateEnvironmentTest3.setEnvironmentVars(false, false, false, false, true, false, false);
		GenerateEnvironmentTest3.genScorecardMetricEducation();
	//	GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
		//												'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		System.assert(GenerateEnvironmentTest3.getManager() != null); 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu);
	  	
	  	Test.stopTest();
	  	
	}
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationEight() {
	  	
	  	GenerateEnvironmentTest3.setEnvironmentVars(false, false, false, false, false, true, false);
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		//GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
			//											'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
														'Employee Self Assessment', 'Manager Assessment');
		System.assert(!GenerateEnvironmentTest3.emptyMethodReviewRating);
		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu);
	  	
	  	Test.stopTest();
	  	
	}
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationNine() {
	  	
	  	GenerateEnvironmentTest3.setEnvironmentVars(false, false, false, false, false, false, true);
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		//GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
			//											'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
														'Employee Self Assessment', 'Manager Assessment');
		System.assert(!GenerateEnvironmentTest3.emptyMethodReviewRating);
		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu);
	  	
	  	Test.stopTest();
	  	
	}
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationTen() {
	  	
	  	GenerateEnvironmentTest3.setNotCreateScorecards();
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
	//	GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
		//												'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu);
	  	
	  	Test.stopTest();
	  	
	}

	  public static testMethod void execute_methods_ScorecardMetricEducationZero2() {
	  	
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		Test.startTest();  
		 System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	try{
		  	ScorecardMetricEducation controller = new ScorecardMetricEducation();
		  		
		  	if (controller.getperformanceR() == null){
		  		System.assert(false,'Null Performance Review');	  			
		  	}
	  	}catch(Exception e){
	  		System.debug(' NULL performance review ');
	  	}
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu);

		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
														'Created', 'Employee Self Assessment');
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu);
	  	
	  	Test.stopTest();
	  	
	}

	  public static testMethod void execute_methods_ScorecardMetricEducationOne2() {
	  	
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
														'Employee Self Assessment', 'Manager Assessment');
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu);
	  	
	  	Test.stopTest();
	  	
	}
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationTwo2() {
	  	
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
		//GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
			//											'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
														'Manager Assessment', '2nd Level Manager Assessment');
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu);
	  	
	  	Test.stopTest();
	  	
	}
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationThree2() {
	  	
	  	GenerateEnvironmentTest3.setEnvironmentVars(true, false, false, false, false, false, false);
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.emptyMethodReviewRating);
		//GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
			//											'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu);
	  	
	  	Test.stopTest();
	  	
	}
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationFour2() {
	  	
	  	GenerateEnvironmentTest3.setEnvironmentVars(false, true, false, false, false, false, false);
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(!GenerateEnvironmentTest3.emptyMethodReviewRating);
		//GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
			//											'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu);
	  	
	  	Test.stopTest();
	  	
	}
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationFive2() {
	  	
	  	GenerateEnvironmentTest3.setEnvironmentVars(false, false, true, false, false, false, false);
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(!GenerateEnvironmentTest3.emptyMethodReviewRating);
	//	GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
		//												'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu);
	  	
	  	Test.stopTest();
	  	
	}
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationSix2() {
	  	
	  	GenerateEnvironmentTest3.setEnvironmentVars(false, false, false, true, false, false, false);
	  	System.assert(!GenerateEnvironmentTest3.emptyMethodReviewRating);
		GenerateEnvironmentTest3.genScorecardMetricEducation();
	//	GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
		//												'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu);
	  	
	  	Test.stopTest();
	  	
	}
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationSeven2() {
	  	
	  	GenerateEnvironmentTest3.setEnvironmentVars(false, false, false, false, true, false, false);
	  	System.assert(!GenerateEnvironmentTest3.emptyMethodReviewRating);
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		//GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
			//											'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu);
	  	
	  	Test.stopTest();
	  	
	}
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationEight2() {
	  	
	  	GenerateEnvironmentTest3.setEnvironmentVars(false, false, false, false, false, true, false);
	  	System.assert(!GenerateEnvironmentTest3.emptyMethodReviewRating);
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		//GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
			//											'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu);
	  	
	  	Test.stopTest();
	  	
	}
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationNine2() {
	  	
	  	GenerateEnvironmentTest3.setEnvironmentVars(false, false, false, false, false, false, true);
	  	System.assert(!GenerateEnvironmentTest3.emptyMethodReviewRating);
		GenerateEnvironmentTest3.genScorecardMetricEducation();
	//	GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
		//												'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu);
	  	
	  	Test.stopTest();
	  	
	}
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationTen2() {
	  	
	  	GenerateEnvironmentTest3.setNotCreateScorecards();
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
	//	GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
		//												'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu);
	  	
	  	Test.stopTest();
	  	
	}

	  public static testMethod void execute_methods_ScorecardMetricEducationZero3() {
	  	
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	try{
		  	ScorecardMetricEducation controller = new ScorecardMetricEducation();
		  		
		  	if (controller.getperformanceR() == null){
		  		System.assert(false,'Null Performance Review');	  			
		  	}
	  	}catch(Exception e){
	  		System.debug(' NULL performance review ');
	  	}
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividual);

		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividual,
														'Created', 'Employee Self Assessment');
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividual);
	  	
	  	Test.stopTest();
	  	
	}

	  public static testMethod void execute_methods_ScorecardMetricEducationOne3() {
	  	
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividual,
														'Employee Self Assessment', 'Manager Assessment');
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividual);
	  	
	  	Test.stopTest();
	  	
	} 
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationTwo3() {
	  	
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
		//GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividual,
		//												'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividual,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividual,
														'Manager Assessment', '2nd Level Manager Assessment');
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividual);
	  	
	  	Test.stopTest();
	  	
	}
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationThree3() {
	  	
	  	GenerateEnvironmentTest3.setEnvironmentVars(true, false, false, false, false, false, false);
	  	System.assert(GenerateEnvironmentTest3.emptyMethodReviewRating);
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		//GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividual,
			//											'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividual,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividual);
	  	
	  	Test.stopTest();
	  	
	}
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationFour3() {
	  	
	  	GenerateEnvironmentTest3.setEnvironmentVars(false, true, false, false, false, false, false);
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
	//	GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividual,
		//												'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividual,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividual);
	  	
	  	Test.stopTest();
	  	
	}
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationFive3() {
	  	
	  	GenerateEnvironmentTest3.setEnvironmentVars(false, false, true, false, false, false, false);
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
	//	GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividual,
		//												'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividual,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividual);
	  	
	  	Test.stopTest();
	  	
	}
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationSix3() {
	  	
	 
	  	
	}
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationSeven3() {
	  	
	  	GenerateEnvironmentTest3.setEnvironmentVars(false, false, false, false, true, false, false);
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
		//GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividual,
			//											'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividual,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividual);
	  	
	  	Test.stopTest();
	  	
	}
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationEight3() {
	  	
	  	GenerateEnvironmentTest3.setEnvironmentVars(false, false, false, false, false, true, false);
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
	//	GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividual,
		//												'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividual,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividual);
	  	
	  	Test.stopTest();
	  	
	}
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationNine3() {
	  	
	  	GenerateEnvironmentTest3.setEnvironmentVars(false, false, false, false, false, false, true);
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
	//	GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividual,
		//												'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividual,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividual);
	  	
	  	Test.stopTest();
	  	
	}
 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationTen3() {
	  	
	  	GenerateEnvironmentTest3.setNotCreateScorecards();
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
	//	GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividual,
		//												'Created', 'Employee Self Assessment');
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividual,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividual);
	  	
	  	Test.stopTest();
	  	
	}
	 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationEleven() {
	  	
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
														'2nd Level Manager Assessment', 'Pending Employee Services');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu);
	  	
	  	Test.stopTest();
	  	
	}
	 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationEleven2() {
	  	
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
														'2nd Level Manager Assessment', 'Pending Employee Services');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  		  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu);
	  	
	  	Test.stopTest();
	  	
	}
	 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationEleven3() {
	  	
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividual,
														'2nd Level Manager Assessment', 'Pending Employee Services');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividual);
	  	
	  	Test.stopTest();
	  	
	}

	 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationTwelve() {
	  	
	  	GenerateEnvironmentTest3.setCreateScorecardsWithData();
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu);
	  	
	  	Test.stopTest();
	  	
	}
	 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationTwelve2() {
	  	
	  	GenerateEnvironmentTest3.setCreateScorecardsWithData();
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  		  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu);
	  	
	  	Test.stopTest();
	  	
	}
	 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationTwelve3() {
	  	
	  	GenerateEnvironmentTest3.setCreateScorecardsWithData();
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividual,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividual);
	  	
	  	Test.stopTest();
	}
	 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationThirteen() {
	  	
	  	GenerateEnvironmentTest3.setCreateScorecardsWithDataZero();
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu);
	  	
	  	Test.stopTest();
	  	
	}
	 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationThirteen2() {
	  	
	  	GenerateEnvironmentTest3.setCreateScorecardsWithDataZero();
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  		  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu);
	  	
	  	Test.stopTest();
	  	
	}
	 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationThirteen3() {
	  	
	  	GenerateEnvironmentTest3.setCreateScorecardsWithDataZero();
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividual,
														'Employee Self Assessment', 'Manager Assessment');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividual);
	  	
	  	Test.stopTest();
	}
	 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationFourteen() {
	  	
	  	GenerateEnvironmentTest3.setCreateScorecardsWithData();
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
														'Manager Approval', 'Employee Approval');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu);
	  	
	  	Test.stopTest();
	  	
	}
	 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationFourteen2() {
	  	
	  	GenerateEnvironmentTest3.setCreateScorecardsWithData();
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
														'Manager Approval', 'Employee Approval');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  		  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu);
	  	
	  	Test.stopTest();
	  	
	}
	 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationFourteen3() {
	  	
	  	GenerateEnvironmentTest3.setCreateScorecardsWithData();
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividual,
														'Manager Approval', 'Employee Approval');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividual);
	  	
	  	Test.stopTest();
	}

	 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationFifteen() {
	  	
	  	GenerateEnvironmentTest3.setCreateScorecardsWithDataZero();
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
														'Manager Approval', 'Employee Approval');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu);
	  	
	  	Test.stopTest();
	  	
	}
	 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationFifteen2() {
	  	
	  	GenerateEnvironmentTest3.setCreateScorecardsWithDataZero();
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
														'Manager Approval', 'Employee Approval');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  		  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu);
	  	
	  	Test.stopTest();
	  	
	}
	 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationFifteen3() {
	  	
	  	GenerateEnvironmentTest3.setCreateScorecardsWithDataZero();
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividual,
														'Manager Approval', 'Employee Approval');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividual);
	  	
	  	Test.stopTest();
	}
	
	 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationSixteen() {
	  	
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,
														'Manager Approval', 'Employee Approval');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu);
	  	
	  	Test.stopTest();
	  	
	}
	 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationSixteen2() {
	  	
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu,
														'Manager Approval', 'Employee Approval');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  		  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividualQ3Q4Edu);
	  	
	  	Test.stopTest();
	  	
	}
	 	   
	  public static testMethod void execute_methods_ScorecardMetricEducationSixteen3() {
	  	
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		
		System.assert(GenerateEnvironmentTest3.v2momIndividual != null);
		GenerateEnvironmentTest3.changeStatusPReview(GenerateEnvironmentTest3.PRIndividual,
														'Manager Approval', 'Employee Approval');

		Test.startTest();  
		 
	  	Test.setCurrentPageReference(new PageReference('Page.NewPeopleForceStep1'));
	  	
	  	test_ScorecardMetricEducationAllUsers(GenerateEnvironmentTest3.PRIndividual);
	  	
	  	Test.stopTest();
	}
		
	  public static void test_ScorecardMetricEducationAllUsers(PerformanceReview__c performanceReviewEducation) {
	  		try{
	  			test_ScorecardMetricEducationUser(performanceReviewEducation, performanceReviewEducation.Employee__c);
	  			test_ScorecardMetricEducationUser(performanceReviewEducation, performanceReviewEducation.Manager__c);
	  			test_ScorecardMetricEducationUser(performanceReviewEducation, performanceReviewEducation.secondManager__c);
	  			test_ScorecardMetricEducationUser(performanceReviewEducation, UserInfo.getUserId());	
	  		}catch(Exception e){
	  		
	  		}
	  	
	  }
	  
	  public static void test_ScorecardMetricEducationUser(PerformanceReview__c performanceReviewEducation, Id user) {
	    
	    ScorecardMetricEducation controller;
	    
	    try {
		    System.currentPageReference().getParameters().put('id', performanceReviewEducation.Id);
	
		  	controller = new ScorecardMetricEducation();
		  	controller = new ScorecardMetricEducation(user);
		  	
		  	controller.setUserId(user);
		  	controller.UserId();	  	
		  	controller.getv2momType();
		  	controller.getScorecardSupportReview();
		
	  		controller.getIsQ1Q2();
	  		controller.getIsQ3Q4();
	  		controller.getIsQ1Q2Q3Q4InMgrAssmnt();
	  		
		  	controller.getScorecard();
		  	controller.getCurrentUserId();
		  	controller.getCurrentUserComment();
		  	controller.getUserProfile();
		  	controller.getperformanceR();
		  	
		  	controller.getLabelPreviousMetric();
		  	controller.getLabelNextMetric();
		  	controller.getLabelMetricAvail();
		  	controller.getLabelMetricComment();
		  	
		   	controller.getIsSysAdminProfile();
		  	controller.getIsMngr();
		  	controller.getIsMngrInAssmnt();
		  	controller.getIs3PtInAssmnt();
		  	controller.getIsMngr2ndMngrOr3PtInAssmnt();
	
		  	controller.getScorecardCommentWithoutSharing(performanceReviewEducation);
		  	controller.getRatingSelectOptions();
        }catch(Exception e){
            System.debug(' ****************** test_ScorecardMetricEducationUser * ');
            System.debug(e.getMessage());
        }
	  	
	  	
	  	try{
		  	List<ScorecardMetricEducation.HistoryComments> hcs = controller.getHistoryCommentForecastAccurancy();
		  	ScorecardMetricEducation.HistoryComments hc;
	  	
		  	hc = hcs.get(0);
		  	hc.getComment();
		  	hc.setComment(hc.getComment());
		  	hc.getCreatedDate();
		  	hc.setCreatedDate('');

		  	hcs = controller.getHistoryCommentTimeOnPlatform();
		  	
		  	hc = hcs.get(0);
		  	hc.getComment();
		  	hc.setComment(hc.getComment());
		  	hc.getCreatedDate();
		  	hc.setCreatedDate('');

		  	hcs = controller.getHistoryCommentSalesImpact();
		  	
		  	hc = hcs.get(0);
		  	hc.getComment();
		  	hc.setComment(hc.getComment());
		  	hc.getCreatedDate();
		  	hc.setCreatedDate('');
	  	}catch(Exception e){
	  		System.debug(' NULL comment history ');
	  	}

		try {
			
		  	controller.getHasCommentTimeOnPlatform();
		  	controller.getHasCommentForecastAccuracy();
		  	controller.getHasCommentSalesImpact();
	
		  	
		  	List<ScorecardSupportReview__c> scorecardReview = new List<ScorecardSupportReview__c>();
		  	
			ScorecardMetricEducation.ScoreCardReviewSupport scorecardReviewSupport = new ScorecardMetricEducation.ScoreCardReviewSupport(scorecardReview, performanceReviewEducation, controller.getCurrentUserComment());
		  	test_ScoreCardReviewSupport(scorecardReviewSupport, user);
	
			scorecardReviewSupport = new ScorecardMetricEducation.ScoreCardReviewSupport(scorecardReview, performanceReviewEducation, controller.getCurrentUserComment(), true);
		  	test_ScoreCardReviewSupport(scorecardReviewSupport, user);
	
			scorecardReviewSupport = new ScorecardMetricEducation.ScoreCardReviewSupport(scorecardReview, performanceReviewEducation, controller.getCurrentUserComment(), false);
		  	test_ScoreCardReviewSupport(scorecardReviewSupport, user);
	
		  	if (GenerateEnvironmentTest3.sQ1Edu != null)
		  		scorecardReview.add(GenerateEnvironmentTest3.sQ1Edu);
		  	if (GenerateEnvironmentTest3.sQ2Edu != null)
		  		scorecardReview.add(GenerateEnvironmentTest3.sQ2Edu);
		  	if (GenerateEnvironmentTest3.sQ3Edu != null)
		  		scorecardReview.add(GenerateEnvironmentTest3.sQ3Edu);
		  	if (GenerateEnvironmentTest3.sQ4Edu != null)
		  		scorecardReview.add(GenerateEnvironmentTest3.sQ4Edu);
		  	
			scorecardReviewSupport = new ScorecardMetricEducation.ScoreCardReviewSupport(scorecardReview, performanceReviewEducation, controller.getCurrentUserComment());
		  	test_ScoreCardReviewSupport(scorecardReviewSupport, user);
	
			scorecardReviewSupport = new ScorecardMetricEducation.ScoreCardReviewSupport(scorecardReview, performanceReviewEducation, controller.getCurrentUserComment(), true);
		  	test_ScoreCardReviewSupport(scorecardReviewSupport, user);
	
			scorecardReviewSupport = new ScorecardMetricEducation.ScoreCardReviewSupport(scorecardReview, performanceReviewEducation, controller.getCurrentUserComment(), false);
		  	test_ScoreCardReviewSupport(scorecardReviewSupport, user);
        }catch(Exception e){
            System.debug(' ****************** test_ScorecardMetricEducationUser * ');
            System.debug(e.getMessage());
        }
	  }

	  public static void test_ScoreCardReviewSupport(ScorecardMetricEducation.ScoreCardReviewSupport scorecardReviewSupport, Id user) {
	  	
	  	scorecardReviewSupport.getScorecardSupportReview();
	  	
	  	scorecardReviewSupport.setUserId(user);
	  	scorecardReviewSupport.getUserId();
	  	scorecardReviewSupport.getId();
	  	scorecardReviewSupport.getScorecardSupportReview();
	  
	  	
	  	scorecardReviewSupport.getQuarter('Q1');
	  	scorecardReviewSupport.getQuarter('Q2');
	  	scorecardReviewSupport.getQuarter('Q3');
	  	scorecardReviewSupport.getQuarter('Q4');
	  	
	  	scorecardReviewSupport.getForecastAccuracyActualQ1();
	  	scorecardReviewSupport.getForecastAccuracyActualQ2();
	  	scorecardReviewSupport.getForecastAccuracyActualQ3();
	  	scorecardReviewSupport.getForecastAccuracyActualQ4();
	  	
	  	scorecardReviewSupport.getForecastAccuracyTargetQ1();
	  	scorecardReviewSupport.getForecastAccuracyTargetQ2();
	  	scorecardReviewSupport.getForecastAccuracyTargetQ3();
	  	scorecardReviewSupport.getForecastAccuracyTargetQ4();
	  	
	  	scorecardReviewSupport.getForecastAccuracyAttainmentQ1();
	  	scorecardReviewSupport.getForecastAccuracyAttainmentQ2();
	  	scorecardReviewSupport.getForecastAccuracyAttainmentQ3();
	  	scorecardReviewSupport.getForecastAccuracyAttainmentQ4();
	  	
	  	scorecardReviewSupport.getYTDActual();
	  	scorecardReviewSupport.getYTDTarget();
	  	scorecardReviewSupport.getYTDAttainment();
	  	scorecardReviewSupport.getCommentForecastAccuracy();
	  	scorecardReviewSupport.getForecastAccuracyRating();
	  	scorecardReviewSupport.getForecastAccuracyWeight();
	  	
	  	scorecardReviewSupport.getRatingDescription(1);
	  	scorecardReviewSupport.getRatingDescription(2);
	  	scorecardReviewSupport.getRatingDescription(3);
	  	scorecardReviewSupport.getRatingDescription(4);
	  	scorecardReviewSupport.getRatingDescription(5);
	  	
	  	scorecardReviewSupport.getTimeOnPlatformActualQ1();	  	
	  	scorecardReviewSupport.getTimeOnPlatformActualQ2();
	  	scorecardReviewSupport.getTimeOnPlatformActualQ3();
	  	scorecardReviewSupport.getTimeOnPlatformActualQ4();
	  	
	  	scorecardReviewSupport.getTimeOnPlatformTargetQ1();
	  	scorecardReviewSupport.getTimeOnPlatformTargetQ2();
	  	scorecardReviewSupport.getTimeOnPlatformTargetQ3();
	  	scorecardReviewSupport.getTimeOnPlatformTargetQ4();
	  	
	  	scorecardReviewSupport.getTimeOnPlatformAttainmentQ1();
	  	scorecardReviewSupport.getTimeOnPlatformAttainmentQ2();
	  	scorecardReviewSupport.getTimeOnPlatformAttainmentQ3();
	  	scorecardReviewSupport.getTimeOnPlatformAttainmentQ4();
	  	
	  	scorecardReviewSupport.getYTDActualTimeOnPlatform();
	  	scorecardReviewSupport.getYTDTargetTimeOnPlatform();
	  	scorecardReviewSupport.getYTDAttainmentTimeOnPlatform();
	  	scorecardReviewSupport.getCommentTimeOnPlatform();
	  	scorecardReviewSupport.getTimeOnPlatformRating();
		scorecardReviewSupport.getTimeOnPlatformWeight();
		
	  	scorecardReviewSupport.getSalesImpactActual();
	  	scorecardReviewSupport.getSalesImpactTarget();
	  	scorecardReviewSupport.getSalesImpactDifference();
	  	
	  	scorecardReviewSupport.getSalesImpactRating();
	  	scorecardReviewSupport.getSalesImpactWeight();
	  	scorecardReviewSupport.getCommentSalesImpact();
	  	scorecardReviewSupport.getSalesImpactDifference();
	  }

}