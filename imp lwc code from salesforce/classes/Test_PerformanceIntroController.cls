@isTest
private class Test_PerformanceIntroController {
  
       public static testMethod void execute_methods_IntroController_Short_000() {
            GenerateEnvironmentTest6.genPerformanceIntroShort();
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers1(perf);
            Test.stopTest();
    } 
 
       public static testMethod void execute_methods_IntroController_Short_001() {
            GenerateEnvironmentTest6.genPerformanceIntroShort();
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers2(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_002() {
            GenerateEnvironmentTest6.genPerformanceIntroShort();
			GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividualShort,
														'Created', 'Employee Self Assessment');
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;
			
	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers1(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_003() {
            GenerateEnvironmentTest6.genPerformanceIntroShort();
			GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividualShort,
														'Created', 'Employee Self Assessment');
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers2(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_004() {
            GenerateEnvironmentTest6.genPerformanceIntroShort();
			GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividualShort,
														'Employee Self Assessment', 'Manager Assessment');
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers1(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_005() {
            GenerateEnvironmentTest6.genPerformanceIntroShort();
			GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividualShort,
														'Employee Self Assessment', 'Manager Assessment');
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers2(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_005A() {
            GenerateEnvironmentTest6.genPerformanceIntroShort();
			GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividualShort,
														'Employee Self Assessment', 'Manager Assessment');
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            	
            		PerformanceIntroController intro = testPerformanceUserSpecialCase(perf, perf.Manager__c);
            		if (intro != null){
            			intro.changeStatusApprove();
            			intro.changeStatusApprove();
            			System.assert(intro.getRenderRating());
            			//testPerformanceRejectEmployee(intro);	
            		}	
            	
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_005B() {
            GenerateEnvironmentTest6.genPerformanceIntroShort();
			GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividualShort,
														'Employee Self Assessment', 'Manager Assessment');
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            PerformanceIntroController intro = testPerformanceUserSpecialCase(perf, perf.Manager__c);
            testPerformanceRejectComment(intro);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_005C() {
            GenerateEnvironmentTest6.genPerformanceIntroShort();
			GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividualShort,
														'Employee Self Assessment', 'Manager Assessment');
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            PerformanceIntroController intro = testPerformanceUserSpecialCase(perf, perf.Manager__c);
            intro.changeStatusApprove();
            intro.changeStatusApprove();
            System.assert(intro.getRenderRating());
            testPerformanceSubmitComment(intro);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_006() {
            GenerateEnvironmentTest6.genPerformanceIntroShort();
			GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividualShort,
														'Manager Assessment', 'Employee Approval');
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers1(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_007() {
            GenerateEnvironmentTest6.genPerformanceIntroShort();
			GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividualShort,
														'Manager Assessment', 'Employee Approval');
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers2(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_007A() {
            GenerateEnvironmentTest6.genPerformanceIntroShort();
			GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividualShort,
														'Manager Assessment', 'Employee Approval');
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            PerformanceIntroController intro = testPerformanceUserSpecialCase(perf, perf.Employee__c);
            testPerformanceComplete(intro);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_007B() {
            Test.startTest();
            
            	GenerateEnvironmentTest6.genPerformanceIntroShort();
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividualShort,
														'Manager Assessment', 'Employee Approval');
	        	PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  			Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    		System.currentPageReference().getParameters().put('id', perf.Id);
            	System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
           
            	PerformanceIntroController intro = testPerformanceUserSpecialCase(perf, perf.Employee__c);
            	testPerformanceAccept(intro);
            
            	
            Test.stopTest();
    }


       public static testMethod void execute_methods_IntroController_Short_000_Empty() {
            GenerateEnvironmentTest6.setCreatePerfShortReviewEmpty();
            GenerateEnvironmentTest6.genPerformanceIntroShort();
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers1(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_001_Empty() {
            GenerateEnvironmentTest6.setCreatePerfShortReviewEmpty();
            GenerateEnvironmentTest6.genPerformanceIntroShort();
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers2(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_002_Empty() {
            GenerateEnvironmentTest6.setCreatePerfShortReviewEmpty();
            GenerateEnvironmentTest6.genPerformanceIntroShort();
			GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividualShort,
														'Created', 'Employee Self Assessment');
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers1(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_003_Empty() {
            GenerateEnvironmentTest6.setCreatePerfShortReviewEmpty();
            GenerateEnvironmentTest6.genPerformanceIntroShort();
			GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividualShort,
														'Created', 'Employee Self Assessment');
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers2(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_004_Empty() {
            GenerateEnvironmentTest6.setCreatePerfShortReviewEmpty();
            GenerateEnvironmentTest6.genPerformanceIntroShort();
			GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividualShort,
														'Employee Self Assessment', 'Manager Assessment');
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers1(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_005_Empty() {
            GenerateEnvironmentTest6.setCreatePerfShortReviewEmpty();
            GenerateEnvironmentTest6.genPerformanceIntroShort();
			GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividualShort,
														'Employee Self Assessment', 'Manager Assessment');
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers2(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_006_Empty() {
            GenerateEnvironmentTest6.setCreatePerfShortReviewEmpty();
            GenerateEnvironmentTest6.genPerformanceIntroShort();
			GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividualShort,
														'Manager Assessment', 'Employee Approval');
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            
            Test.startTest();
            testPerformanceAllUsers1(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_007_Empty() {
            GenerateEnvironmentTest6.setCreatePerfShortReviewEmpty();
            GenerateEnvironmentTest6.genPerformanceIntroShort();
			GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividualShort,
														'Manager Assessment', 'Employee Approval');
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers2(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_000A_Empty() {
           	Test.startTest();
            GenerateEnvironmentTest6.genPerformanceIntroShortEmpty();
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
           
            testPerformanceAllUsers1(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_001A_Empty() {
            GenerateEnvironmentTest6.genPerformanceIntroShortEmpty();
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers2(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_002A_Empty() {
            GenerateEnvironmentTest6.genPerformanceIntroShortEmpty();
			GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividualShort,
														'Created', 'Employee Self Assessment');
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers1(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_003A_Empty() {
            GenerateEnvironmentTest6.genPerformanceIntroShortEmpty();
			GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividualShort,
														'Created', 'Employee Self Assessment');
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers2(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_004A_Empty() {
            GenerateEnvironmentTest6.genPerformanceIntroShortEmpty();
			GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividualShort,
														'Employee Self Assessment', 'Manager Assessment');
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers1(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_005A_Empty() {
            GenerateEnvironmentTest6.genPerformanceIntroShortEmpty();
			GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividualShort,
														'Employee Self Assessment', 'Manager Assessment');
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers2(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_006A_Empty() {
            GenerateEnvironmentTest6.genPerformanceIntroShortEmpty();
			GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividualShort,
														'Manager Assessment', 'Employee Approval');
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers1(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Short_007A_Empty() {
            GenerateEnvironmentTest6.genPerformanceIntroShortEmpty();
			GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividualShort,
														'Manager Assessment', 'Employee Approval');
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers2(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_000() {
            Test.startTest();
            	GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
	        	PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;
	  			Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    		System.currentPageReference().getParameters().put('id', perf.Id);
	    		System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
               	testPerformanceAllUsers1(perf);
            Test.stopTest();
    }


       public static testMethod void execute_methods_IntroController_Long_001() {
            Test.startTest();
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
           
            testPerformanceAllUsers2(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_002() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers3(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_003() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.employeeStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'Created', 'Employee Self Assessment');
            //}
            PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers1(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_004() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.employeeStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'Created', 'Employee Self Assessment');
            //}
            PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers2(perf);
            Test.stopTest();
    }
    

       public static testMethod void execute_methods_IntroController_Long_005() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.employeeStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'Created', 'Employee Self Assessment');
            //}
            PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers3(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_006() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.employeeStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'Employee Self Assessment', 'Manager Assessment');
            //}
            PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers1(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_007() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.employeeStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'Employee Self Assessment', 'Manager Assessment');
            //}
            PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers2(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_008() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.employeeStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'Employee Self Assessment', 'Manager Assessment');
            //}
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers3(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_009() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.reviewManagerStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'Manager Assessment', '3rd Party Assessment');
            //}
            PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers1(perf);
           
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_010() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.reviewManagerStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'Manager Assessment', '3rd Party Assessment');
            //}
            PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers2(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_011() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.reviewManagerStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'Manager Assessment', '3rd Party Assessment');
            //}
            PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers3(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_012() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.reviewManagerStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'Manager Assessment', '2nd Level Manager Assessment');
            //}
            PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers1(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_013() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.reviewManagerStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'Manager Assessment', '2nd Level Manager Assessment');
            //}
            PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers2(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_014() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.reviewManagerStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'Manager Assessment', '2nd Level Manager Assessment');
            //}
            PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers3(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_015() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.review2ndManagerStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'2nd Level Manager Assessment', '3rd Party Assessment');
            //}
            PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers1(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_016() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.review2ndManagerStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'2nd Level Manager Assessment', '3rd Party Assessment');
            //}
            PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers2(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_017() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.review2ndManagerStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'2nd Level Manager Assessment', '3rd Party Assessment');
            //}
            PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers3(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_018() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.review2ndManagerStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'2nd Level Manager Assessment', 'Pending Employee Services');
            //}
            PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers1(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_019() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.review2ndManagerStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'2nd Level Manager Assessment', 'Pending Employee Services');
            //}
            PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers2(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_020() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.review2ndManagerStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'2nd Level Manager Assessment', 'Pending Employee Services');
            //}
            PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers3(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_021() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.esadminStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'Pending Employee Services', 'PCOMM Review');
            //}
            PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers1(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_022() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.esadminStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'Pending Employee Services', 'PCOMM Review');
            //}
            PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers2(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_023() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.esadminStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'Pending Employee Services', 'PCOMM Review');
            //}
            PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers3(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_024() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.pcommStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PerformanceReview,
															'PCOMM Review', 'Manager Approval');
            //}
            PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers1(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_025() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.pcommStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'PCOMM Review', 'Manager Approval');
            //}
            PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers2(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_026() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.pcommStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'PCOMM Review', 'Manager Approval');
            //}
            PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers3(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_027() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.reviewManagerStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'Manager Approval', 'Employee Approval');
            //}
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers1(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_028() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.reviewManagerStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'Manager Approval', 'Employee Approval');
            //}
            PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers2(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_029() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.reviewManagerStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'Manager Approval', 'Employee Approval');
            //}
            PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers3(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_030() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.employeeStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'Employee Approval', 'Completed');
            //}
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers1(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_031() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.employeeStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'Employee Approval', 'Completed');
            //}
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers2(perf);
            Test.stopTest();
    }

       public static testMethod void execute_methods_IntroController_Long_032() {
            GenerateEnvironmentTest6.genPerformanceIntroLongNormal();
            // System.RunAs(GenerateEnvironmentTest6.employeeStandard){
				GenerateEnvironmentTest6.changeStatusPReview(GenerateEnvironmentTest6.PRIndividual,
															'Employee Approval', 'Completed');
            //}
	        PerformanceReview__c perf = GenerateEnvironmentTest6.PerformanceReview;

	  		Test.setCurrentPageReference(new PageReference('Page.PerformanceIntro'));
	    	System.currentPageReference().getParameters().put('id', perf.Id);
            System.assertEquals(System.currentPageReference().getParameters().get('id'), perf.Id);
            Test.startTest();
            testPerformanceAllUsers3(perf);
            Test.stopTest();
    }

    public static void testPerformanceAllUsers1(PerformanceReview__c p) {
            testPerformanceUser(p, p.Employee__c);
            testPerformanceUser(p, p.Manager__c);
	}

    public static void testPerformanceAllUsers2(PerformanceReview__c p) {
            testPerformanceUser(p, p.SecondManager__c);
            testPerformanceUser(p, p.PCOMM__c);
	}

    public static void testPerformanceAllUsers3(PerformanceReview__c p) {
            testPerformanceUser(p, p.ThirdPartyReviewer__c);
            testPerformanceUser(p, UserInfo.getUserId());
	}

    public static void testPerformanceUser(PerformanceReview__c perf, Id user) {

		try {
	        ApexPages.StandardController std = new ApexPages.StandardController(perf); 
	        PerformanceIntroController intro = new PerformanceIntroController(std,user);
	        
	        PerformanceIntroController.IntroUtil introUtil = new PerformanceIntroController.IntroUtil();        
        	intro.setPerformanceReview(introUtil.getPerformanceReviewDetail(perf));
        	
        	intro.setCurrentUserId(user);
            testPerformance(intro);
           
            
           
        }catch(Exception e){
            System.debug(' ****************** testPerformanceUser * ');
            System.debug(e.getMessage());
        }
            
	}
	public static void testPerformance2(PerformanceIntroController intro){
		
		List<PerformanceIntroController.Method> meths = intro.getMethods();
         
        if (meths != null && meths.size() > 0) {
            PerformanceIntroController.Method meth = meths[0];
            meth.getMethod();
            meth.setMethod(GenerateEnvironmentTest6.method1);
            meth.getShowValue();
            meth.getReview();
            
            meth.getObstacles();
            List<Obstacle__c> obstacleList = new List<Obstacle__c>();
            obstacleList.add(GenerateEnvironmentTest6.obstacle1);
            meth.setObstacles(obstacleList);
            
            meth.getMetrics();
            List<Measure__c> measureList = new List<Measure__c>(); 
            measureList.add(GenerateEnvironmentTest6.measure1);
            meth.setMetrics(measureList);
        }
         
        List<PerformanceIntroController.Reviewer> revs = intro.getReviewers();
         
        if (revs != null && revs.size() > 0) {
        	for(PerformanceIntroController.Reviewer rev : revs){
	            PerformanceIntroController.Reviewer reviewer = rev;
	            
	            reviewer.getDateApproval();
	            reviewer.getApproved();
	            reviewer.getCurrentReviewer();
	            reviewer.getCurrentReviewerReview();
	            reviewer.getCurrentReviewerApproval();
	            reviewer.getIsUserReviewer();
	            reviewer.getStatus();
	            reviewer.getName();
	            reviewer.getTitle();
	            reviewer.getDepartment();
	            reviewer.getLocation();
	            reviewer.getReviewerType();
	            reviewer.getCalculatedRating();
	            
	           
        	}
        }
        
        list<PerformanceIntroController.Value> values = intro.getValues();
        
        if (values != null && values.size() > 0) {
            PerformanceIntroController.Value innerValue = values[0];
            
            innerValue.getName();
            innerValue.getIsLast();
            innerValue.getId();
        }        

		List<PerformanceIntroController.Competency> comps = intro.getCompetencies();
		
        if (comps != null && comps.size() > 0) {
            PerformanceIntroController.Competency innerComp = comps[0];
            
            innerComp.getCompetency();
            
            innerComp.setCompetency(GenerateEnvironmentTest6.competencyGroupMember1);
        }        
		
		try{
	        intro.saveButton();
			
	        intro.cancelButton();
		}catch (Exception e){
			System.debug(' *************** ERROR exception ');
			System.debug(e.getMessage());
		}
		
	}

    public static PerformanceIntroController testPerformanceUserSpecialCase(PerformanceReview__c perf, Id user) {

	        ApexPages.StandardController std = new ApexPages.StandardController(perf); 
	        PerformanceIntroController intro = new PerformanceIntroController(std);
	        intro = new PerformanceIntroController(std, user);
	 
	        PerformanceIntroController.IntroUtil introUtil = new PerformanceIntroController.IntroUtil();        
        	intro.setPerformanceReview(introUtil.getPerformanceReviewDetail(perf));
        	intro.setCurrentUserId(user);
        	intro.getCurrentComment();
        	//intro.getCompetencies();
        	testPerformance2(intro);
            return intro;
	}
    
    public static void testPerformance(PerformanceIntroController intro) {

        PerformanceReview__c performance = intro.getPerformanceReview();
        intro.getV2MOM();
        intro.getCurrentUserId();
        intro.getEmployee();
        intro.getManager();
        intro.getWithPrivileges();
        intro.setStatus();
        intro.getStartLinkText();
        intro.getStepsTopMargin();
        intro.getIsCurrentReviewer();
        intro.getStyleEditV2MOMLink();
        intro.getCommentsHistory();
        intro.getCommentsHistoryPrint();
        intro.getEmployeeCommentsHistory();
        
        List<MethodReview__c> mrs = [Select mr.Id, mr.Method__c from MethodReview__c mr limit 4];
        Method__c m = new Method__c();
        m.Id = mrs[0].Method__c;
        intro.getMr(mrs, m);
        
        List<Method__c> methods = [Select m.Id From Method__c m Where m.V2MOM__c =: performance.V2MOM__c];
        intro.getPerformanceReviewEmployeeWithoutSharing(performance, methods);
        intro.getPerformanceReviewCommentWithoutSharing(performance, methods);
        
        
        PerformanceIntroController.AdditionalCommentDate addCommDate = intro.getManagerCommentsHistory();
 
		if (addCommDate != null){
		//	addCommDate.setCreatedDate(addCommDate.getCreatedDate());
			addCommDate.setAdditionalComment(addCommDate.getAdditionalComment());
		}
		     
        intro.getShowEmployeeMessageMethods();
        intro.getShowManagerMessageMethods();
        intro.getShowEmployeeMessageCompetencies();
        intro.getShowManagerMessageCompetencies();
        intro.getShowMessageAdditional();
        intro.getDateApprovalList();

        intro.getEmployeeCommentsPrint();
        intro.getManagerCommentsPrint();
        intro.getShowEmployeeMessageMethodsPrint();
        intro.getShowManagerMessageMethodsPrint();
        intro.getShowEmployeeMessageCompetenciesPrint();
        intro.getShowManagerMessageCompetenciesPrint();
        intro.getShowMessageAdditionalPrint();

        intro.getShowReviewEdit();
        intro.getIsEmplMngr2ndMngrOr3PtInAssmnt();
        intro.getIsMngr();
        intro.getIsSysAdminProfile();
        intro.getIsMngr();
        intro.getShowSubmit();
        intro.getRejectFlag();
        intro.getShowError();
        intro.getMsgError();
        intro.getShowRatingToEmployee();
        intro.getRenderRating();
        intro.keepOldSharingHierarchy();
        intro.getIsEmployeeSelfAssessmentOrCreated();
            
        
        //testPerformance2(intro);
        
    }
    
        public static void testPerformanceSubmitComment(PerformanceIntroController intro){
			intro.submitCommentButton();
        }    
    
        public static void testPerformanceRejectComment(PerformanceIntroController intro){
			intro.rejectCommentButton();
        }    
    
        public static void testPerformanceSubmitManager(PerformanceIntroController intro){
			intro.submitManager();
        }    
    
        public static void testPerformanceRejectEmployee(PerformanceIntroController intro){
			intro.rejectEmployee();
        }    
    
        public static void testPerformanceComplete(PerformanceIntroController intro){
			intro.completeButton();
        }    
    
        public static void testPerformanceAccept(PerformanceIntroController intro){
        	try{
        		intro.acceptButton();	
        	}catch(Exception e){
        		System.debug('******************Error****************: ' + e);
        	}
			
        }    
}