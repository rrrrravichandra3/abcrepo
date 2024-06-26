@isTest
private class Test_PerformanceOverallController { 
	   
	public static Integer test_case = 1;
	 
    public static testMethod void execute_methods_PerformanceOverallController_Edu_00X() {
    	 
    	try
    	{  
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
	         
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	            
	        Test.startTest();  
	        try{
	        	PerformanceOverallController overall = new PerformanceOverallController();
	        }catch (Exception e){
	        }
	  	    System.currentPageReference().getParameters().put('id', GenerateEnvironmentTest7.PRIndividualQ1Q2Edu.Id); 
	        PerformanceOverallController overall = new PerformanceOverallController();
	        overall.disapproveButton();
	        overall.approve();
	        overall.changeStatusApprove();
	        overall.changeIncomplete();
	        overall.changeStatusDisapprove();
	        overall.submit3rdPartyButton();
	        overall.request3rdPartyButton();
	        overall.request3rdPartyButtonSysAdmin();
	        System.assertEquals(System.currentPageReference().getParameters().get('id'), GenerateEnvironmentTest7.PRIndividualQ1Q2Edu.Id);
	        Test.stopTest();
    	}
    	catch(Exception s)
    	{
    		
    	}
    }
     
    public static testMethod void execute_methods_PerformanceOverallController_Edu_000() {
    	
    	try
    	 {
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
	        
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	            
	        Test.startTest();
			test_case = 1;
			System.assertEquals(test_case, 1);
	     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu);
	        Test.stopTest();
	      }
    	catch(Exception s)
    	{
    		
    	}
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_001() {
    	
    	try
    	{
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
	        
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	        System.assert(perfEmployee != null);    
	        Test.startTest();
	     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu);
	        Test.stopTest();
	   	}
    	catch(Exception s)
    	{
    		
    	}
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_002() {
    	try
    	{
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
	        System.assert(perfEmployee != null);
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	            
	        Test.startTest();
	     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu);
	     	
	        Test.stopTest();
	    }
    	catch(Exception s)
    	{
    		
    	}
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_003() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
        System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ3Q4Edu);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_004() {
    	try
    	{
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
	        System.assert(perfEmployee != null);
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	            
	        Test.startTest();
	     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividualQ3Q4Edu);
	        Test.stopTest();
	    }
    	catch(Exception s)
    	{
    		
    	}
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_005() {
    	
    	try
    	{
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
	        System.assert(perfEmployee != null);
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	            
	        Test.startTest();
	     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividualQ3Q4Edu);
	        Test.stopTest();
    	}
    	catch(Exception s)
    	{
    		
    	}
    }

	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_006() {
    	
    	try
    	{
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
	        System.assert(perfEmployee != null);
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	
			GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu,
															'Employee Self Assessment', 'Manager Assessment');
	            
	        Test.startTest();
			test_case = 1;
	     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu);
	        Test.stopTest();
    	}
    		
    	catch(Exception s)
    	{
    		
    	}
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_007() {
    	try
    	{
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
	        System.assert(perfEmployee != null);
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	
			GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu,
															'Employee Self Assessment', 'Manager Assessment');
	            
	        Test.startTest();
	     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu);
	        Test.stopTest();
	      }
    	catch(Exception s)
    	{
    		
    	}
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_008() {
    	
    	try
    	{
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
	        System.assert(perfEmployee != null);
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	
			GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu,
															'Employee Self Assessment', 'Manager Assessment');
	            
	        Test.startTest();
	     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu);
	        Test.stopTest();
	     }
    	catch(Exception s)
    	{
    		
    	}
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_009() {
    	
    	try
    	{
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
	        System.assert(perfEmployee != null);
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	
			GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Edu,
															'Employee Self Assessment', 'Manager Assessment');
	            
	        Test.startTest();
			test_case = 1;
	     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ3Q4Edu);
	        Test.stopTest();
    	}
    		
    	catch(Exception s)
    	{
    		
    	}
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_010() {
    	try
    	{
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
	        System.assert(perfEmployee != null);
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	
			GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Edu,
															'Employee Self Assessment', 'Manager Assessment');
	            
	        Test.startTest();
	     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividualQ3Q4Edu);
	        Test.stopTest();
	    }
    	catch(Exception s)
    	{
    		
    	}
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_011() {
    	
    	try
    	{
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
	        System.assert(perfEmployee != null);
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	
			GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Edu,
															'Employee Self Assessment', 'Manager Assessment');
	            
	        Test.startTest();
	     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividualQ3Q4Edu);
	        Test.stopTest();
    	}
    	catch(Exception s)
    	{
    		
    	}
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_012() {
    	
    	try
    	{
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
	        System.assert(perfEmployee != null);
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	
			GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu,
															'Manager Assessment', '3rd Party Assessment');
	            
	        Test.startTest();
			test_case = 1;
	     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu);
	        Test.stopTest();
	    }
    	catch(Exception s)
    	{
    		
    	}
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_013() {
    	
    	try
    	{
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
	        System.assert(perfEmployee != null);
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	
			GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu,
															'Manager Assessment', '3rd Party Assessment');
	            
	        Test.startTest();
	     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu);
	        Test.stopTest();
    	}
    	catch(Exception s)
    	{
    		
    	}
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_014() {
    	
    	try
    	{
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
	        System.assert(perfEmployee != null);
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	
			GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu,
															'Manager Assessment', '3rd Party Assessment');
	            
	        Test.startTest();
	     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu);
	        Test.stopTest();
	     }
    	catch(Exception s)
    	{
    		
    	}
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_015() {
    	try
    	{
		    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
		        System.assert(perfEmployee != null);
		        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
		
				GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Edu,
																'Manager Assessment', '3rd Party Assessment');
		            
		        Test.startTest();
				test_case = 1;
		     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ3Q4Edu);
		        Test.stopTest();
		    }
    	catch(Exception s)
    	{
    		
    	}
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_016() {
    	
    	try
    	{
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
	        System.assert(perfEmployee != null);
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	
			GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Edu,
															'Manager Assessment', '3rd Party Assessment');
	            
	        Test.startTest();
	     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividualQ3Q4Edu);
	        Test.stopTest();
	   	}
    	catch(Exception s)
    	{
    		
    	}
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_017() {
    	try
    	{
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
	         System.assert(perfEmployee != null);
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	
			GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Edu,
															'Manager Assessment', '3rd Party Assessment');
	            
	        Test.startTest();
	     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividualQ3Q4Edu);
	        Test.stopTest();
	     }
    	catch(Exception s)
    	{
    		
    	}
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_018A() {
    	
    	try
    	{
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
			 System.assert(perfEmployee != null);	        
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	
			GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu,
															'Manager Assessment', '2nd Level Manager Assessment');
	            
	        Test.startTest();
			test_case = 1;
	     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu);
	        Test.stopTest();
	     	}
    	catch(Exception s)
    	{
    		
    	}
        
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_018B() {
    	try
    	{
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
	    	 System.assert(perfEmployee != null);
	        GenerateEnvironmentTest7.setCreateScorecardsWithData();
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	
			GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu,
															'Manager Assessment', '2nd Level Manager Assessment');
	            
	        Test.startTest();
			test_case = 1;
	     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu);
	        Test.stopTest();
        	}
    	catch(Exception s)
    	{
    		
    	}
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_019() {
    	/*
    	try
    	{
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
	        
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	
			GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu,
															'Manager Assessment', '2nd Level Manager Assessment');
	            
	        Test.startTest();
	     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu);
	        Test.stopTest();
	      }
    	catch(Exception s)
    	{
    		
    	}
        */
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_020() {
    	
    	try
    	{
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
	         System.assert(perfEmployee != null);
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	
			GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu,
															'Manager Assessment', '2nd Level Manager Assessment');
	            
	        Test.startTest();
	     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu);
	        Test.stopTest();
	      	}
    	catch(Exception s)
    	{
    		
    	}
        
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_021() {
    	try
    	{
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
	         System.assert(perfEmployee != null);
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	
			GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Edu,
															'Manager Assessment', '2nd Level Manager Assessment');
	            
	        Test.startTest();
			test_case = 1;
	     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ3Q4Edu);
	        Test.stopTest();
        	}
    	catch(Exception s)
    	{
    		
    	}
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_022() {
    	
    /*
    	try
    	{
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
	        
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	
			GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Edu,
															'Manager Assessment', '2nd Level Manager Assessment');
	            
	        Test.startTest();
	     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividualQ3Q4Edu);
	        Test.stopTest();
        	}
    	catch(Exception s)
    	{
    		
    	}
    	*/
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_023() {
    	try
    	{
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
	         System.assert(perfEmployee != null);
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	
			GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Edu,
															'Manager Assessment', '2nd Level Manager Assessment');
	            
	        Test.startTest();
	     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividualQ3Q4Edu);
	        Test.stopTest();
	      	}
    	catch(Exception s)
    	{
    		
    	}
        
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_024() {
    	try
    	{
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
	         System.assert(perfEmployee != null);
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	
			GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu,
															'2nd Level Manager Assessment', '3rd Party Assessment');
	            
	        Test.startTest();
			test_case = 1;
	     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu);
	        Test.stopTest();
	     	}
    	catch(Exception s)
    	{
    		
    	}
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Edu_025() {
    	try
    	{
	    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
	         System.assert(perfEmployee != null);
	        GenerateEnvironmentTest7.genPerformanceOverallControllerEducation();
	
			GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu,
															'2nd Level Manager Assessment', '3rd Party Assessment');
	            
	        Test.startTest();
	     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividualQ1Q2Edu);
	        Test.stopTest();
    	}
    	catch(Exception s)
    	{
    		
    	}
    }
    
    /* **************************************************************************************** */

    
    public static testMethod void execute_methods_PerformanceOverallController_Stnd_000() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallController();
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividual);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Stnd_001() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallController();
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividual);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Stnd_002() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
        
        GenerateEnvironmentTest7.genPerformanceOverallController();
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividual);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Stnd_006() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallController();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividual,
														'Employee Self Assessment', 'Manager Assessment');
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividual);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Stnd_007() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallController();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividual,
														'Employee Self Assessment', 'Manager Assessment');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividual);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Stnd_008() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallController();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividual,
														'Employee Self Assessment', 'Manager Assessment');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividual);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Stnd_012() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
        
        GenerateEnvironmentTest7.genPerformanceOverallController();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividual,
														'Manager Assessment', '3rd Party Assessment');
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividual);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Stnd_013() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallController();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividual,
														'Manager Assessment', '3rd Party Assessment');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividual);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Stnd_014() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallController();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividual,
														'Manager Assessment', '3rd Party Assessment');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividual);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Stnd_018() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallController();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividual,
														'Manager Assessment', '2nd Level Manager Assessment');
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividual);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Stnd_019() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallController();

		//GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividual,
			//											'Manager Assessment', '2nd Level Manager Assessment');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividual);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Stnd_020() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallController();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividual,
														'Manager Assessment', '2nd Level Manager Assessment');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividual);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Stnd_024() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallController();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividual,
														'2nd Level Manager Assessment', '3rd Party Assessment');
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividual);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Stnd_025() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallController();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividual,
														'2nd Level Manager Assessment', '3rd Party Assessment');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividual);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Stnd_026() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallController();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividual,
														'2nd Level Manager Assessment', '3rd Party Assessment');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividual);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Stnd_030() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallController();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividual,
														'PCOMM Review', 'Manager Approval');
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividual);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Stnd_031() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallController();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividual,
														'PCOMM Review', 'Manager Approval');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividual);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Stnd_032() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallController();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividual,
														'PCOMM Review', 'Manager Approval');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividual);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Stnd_036() {
    	/*
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
        
        GenerateEnvironmentTest7.genPerformanceOverallController();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividual,
														'Manager Approval', 'Employee Approval');
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividual);
        Test.stopTest();
        */
        
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Stnd_037() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallController();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividual,
														'Manager Approval', 'Employee Approval');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividual);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Stnd_038() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallController();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividual,
														'Manager Approval', 'Employee Approval');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividual);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Stnd_042() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallController();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividual,
														'Employee Approval', 'Complete');
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividual);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Stnd_043() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallController();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividual,
														'Employee Approval', 'Complete');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividual);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Stnd_044() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallController();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividual,
														'Employee Approval', 'Complete');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividual);
        Test.stopTest();
    }

	/* **************************************************************************************** */

	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_00X() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();
            
        Test.startTest();
        try{
        	PerformanceOverallController overall = new PerformanceOverallController();
        	System.currentPageReference().getParameters().put('id', GenerateEnvironmentTest7.PRIndividualQ1Q2Sup.Id);

        }catch (Exception e){
        }
  	    
        
        Test.stopTest();
    }
    
    public static testMethod void execute_methods_PerformanceOverallController_Sup_000() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_001() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_002() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();
            
        Test.startTest();
         
     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_003() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_004() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_005() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup);
        Test.stopTest();
    }

	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_006() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup,
														'Employee Self Assessment', 'Manager Assessment');
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
    }
	
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_007() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup,
														'Employee Self Assessment', 'Manager Assessment');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_008() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup,
														'Employee Self Assessment', 'Manager Assessment');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_009() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup,
														'Employee Self Assessment', 'Manager Assessment');
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_010() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup,
														'Employee Self Assessment', 'Manager Assessment');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_011() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup,
														'Employee Self Assessment', 'Manager Assessment');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_012() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup,
														'Manager Assessment', '3rd Party Assessment');
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_013() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup,
														'Manager Assessment', '3rd Party Assessment');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_014() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup,
														'Manager Assessment', '3rd Party Assessment');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_015() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup,
														'Manager Assessment', '3rd Party Assessment');
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_016() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup,
														'Manager Assessment', '3rd Party Assessment');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_017() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
         System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup,
														'Manager Assessment', '3rd Party Assessment');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_018A() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
    	 System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.setEnvironmentVars(true, false, false, false, false, false, false);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup,
														'Manager Assessment', '2nd Level Manager Assessment');
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_018B() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
    	 System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.setEnvironmentVars(false, true, false, false, false, false, false);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup,
														'Manager Assessment', '2nd Level Manager Assessment');
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_018C() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
    	 System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.setEnvironmentVars(false, false, true, false, false, false, false);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup,
														'Manager Assessment', '2nd Level Manager Assessment');
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_018D() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
    	 System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.setEnvironmentVars(false, false, false, true, false, false, false);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup,
														'Manager Assessment', '2nd Level Manager Assessment');
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_018E() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
    	 System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.setEnvironmentVars(false, false, false, false, true, false, false);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup,
														'Manager Assessment', '2nd Level Manager Assessment');
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_018F() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
    	 System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.setEnvironmentVars(false, false, false, false, false, true, false);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup,
														'Manager Assessment', '2nd Level Manager Assessment');
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_018G() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
    	 System.assert(perfEmployee != null);
        GenerateEnvironmentTest7.setEnvironmentVars(false, false, false, false, false, false, true);
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup,
														'Manager Assessment', '2nd Level Manager Assessment');
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_019() {
    	/*
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
        
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup,
														'Manager Assessment', '2nd Level Manager Assessment');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
        */
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_020() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
        
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup,
														'Manager Assessment', '2nd Level Manager Assessment');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_021() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
        
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup,
														'Manager Assessment', '2nd Level Manager Assessment');
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_022A() {
    	/*
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
        
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup,
														'Manager Assessment', '2nd Level Manager Assessment');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup);
        Test.stopTest();
        */
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_022B() {
    	/*
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
        
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup,
														'Manager Assessment', '2nd Level Manager Assessment');
            
		test_case = 4;
        Test.startTest();
     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup);
        Test.stopTest();
        */
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_022C_A() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
        
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup,
														'Manager Assessment', '2nd Level Manager Assessment');
            
		test_case = 5;
        Test.startTest();
        try{
        	test_PerformanceOverallController_User(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup, GenerateEnvironmentTest7.PRIndividualQ3Q4Sup.PCOMM__c);	
        }catch(Exception e){
        	System.debug(e.getMessage());
        }
	  	
        Test.stopTest();
    }

    public static testMethod void execute_methods_PerformanceOverallController_Sup_022C_B() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
    	try{
    		GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

	    	Test.startTest();
			GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup,
														'Manager Assessment', '2nd Level Manager Assessment');
			test_case = 5;
        
	  		test_PerformanceOverallController_User(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup, GenerateEnvironmentTest7.PRIndividualQ3Q4Sup.secondManager__c);												
    	}catch(Exception e){
    		System.debug(e.getMessage());
    	}
        
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_022D_A() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
        try{
        	GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();
			GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup,
														'Manager Assessment', '2nd Level Manager Assessment');
     
	        Test.startTest();
			test_case = 6;
        	test_PerformanceOverallController_User(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup, GenerateEnvironmentTest7.PRIndividualQ3Q4Sup.secondManager__c);
        }catch(Exception e){
        	System.debug(e.getMessage());
        }
        
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_022D_B() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
        try{
        	GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();
	        Test.startTest();
			GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup,
														'Manager Assessment', '2nd Level Manager Assessment');
            test_case = 6;
        	test_PerformanceOverallController_User(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup, GenerateEnvironmentTest7.PRIndividualQ3Q4Sup.PCOMM__c);	
        }catch(Exception e){
        	System.debug(e.getMessage());	
        }
        
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_023() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
        try{
        	GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();
        	Test.startTest();

			GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup,
														'Manager Assessment', '2nd Level Manager Assessment');
            
        
     		test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup);	
        }catch(Exception e){
        	System.debug(e.getMessage());
        }
        
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_024() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
        
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup,
														'2nd Level Manager Assessment', '3rd Party Assessment');
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_025() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
        
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup,
														'2nd Level Manager Assessment', '3rd Party Assessment');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_026() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
        
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup,
														'2nd Level Manager Assessment', '3rd Party Assessment');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_027() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
        
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup,
														'Pending Employee Services', 'PCOMM Review');
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_028() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
        
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup,
														'Pending Employee Services', 'PCOMM Review');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_029() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
        
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup,
														'Pending Employee Services', 'PCOMM Review');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividualQ3Q4Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_030() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
        
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup,
														'PCOMM Review', 'Manager Approval');
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_031() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
        
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup,
														'PCOMM Review', 'Manager Approval');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_032() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
        
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup,
														'PCOMM Review', 'Manager Approval');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
    }
		
    public static testMethod void execute_methods_PerformanceOverallController_Sup_036() {
    
       /*
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
        
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup,
														'Manager Approval', 'Employee Approval');
            
        Test.startTest();
		test_case = 1;
     	test_PerformanceOverallController_AllUsers1(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
        */
        
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_037() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
        
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup,
														'Manager Approval', 'Employee Approval');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers2(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
    }
	
    public static testMethod void execute_methods_PerformanceOverallController_Sup_038() {
    	
    	List<PerformanceReview__c> perfEmployee = new List<PerformanceReview__c>();
        
        GenerateEnvironmentTest7.genPerformanceOverallControllerSupport();

		GenerateEnvironmentTest7.changeStatusPReview(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup,
														'Manager Approval', 'Employee Approval');
            
        Test.startTest();
     	test_PerformanceOverallController_AllUsers3(GenerateEnvironmentTest7.PRIndividualQ1Q2Sup);
        Test.stopTest();
    }
	    
    /* **************************************************************************************** */
    
	  public static void test_PerformanceOverallController_AllUsers1(PerformanceReview__c p) {
	  	System.debug('Performance Review: ' + p);
	  	try{
	  		test_PerformanceOverallController_User(p, p.Employee__c);
	  		test_PerformanceOverallController_User(p, p.Manager__c);	
	  	}catch(Exception e){
	  		System.debug(e.getMessage());
	  	}
	  	
	  }
	
	  public static void test_PerformanceOverallController_AllUsers2(PerformanceReview__c p) {
	  	try{
	  		test_PerformanceOverallController_User(p, p.secondManager__c);
	  		test_PerformanceOverallController_User(p, p.PCOMM__c);	
	  	}catch(Exception e){
	  		System.debug(e.getMessage());
	  	}
	  	
	  }
	
	  public static void test_PerformanceOverallController_AllUsers3(PerformanceReview__c p) {
	  	try{
	  		test_PerformanceOverallController_User(p, p.ThirdPartyReviewer__c);
	  		test_PerformanceOverallController_User(p, UserInfo.getUserId());	
	  	}catch(Exception e){
	  		System.debug(e.getMessage());
	  	}
	  	
	  	
	  }
        
  	public static void test_PerformanceOverallController_User(PerformanceReview__c pr, Id userId) {
	    	
	        PerformanceOverallController overall;
	    	
	    	try {
		    	List<PerformanceOverallController.Method> mwv;
		    	List<PerformanceOverallController.Value> values;
		    	List<PerformanceOverallController.Competency> comps;
	      		 
	      	    System.currentPageReference().getParameters().put('id', pr.Id);
	      	    
	            overall = new PerformanceOverallController(userId);
	      	    overall.setUserInf(userId);
	            
	            overall.getShowMethodsWithoutValue();
	            
				mwv = overall.getMethodsWithoutValue();
	            
	            if (mwv.size() > 0){
	               	PerformanceOverallController.Method m = mwv[0];
		            m.setMethod(m.getMethod());
		            m.setMethodName(m.getMethodName());
		            m.getNameEllipsis();
		            m.getWeightShow();
		            m.setWeight(3);
		            m.getRating();
		            m.setRating(2);
	            }
	                 
	            values = overall.getValues();
	            
	            if (values.size() > 0){
	                PerformanceOverallController.Value v = values[0];
		            v.getId();
		            v.getMethodCount();
		            v.getFullName();
		            v.getMethods();
		            v.getName();
		            v.getTextMethod();
	            }
	                            
	            overall.getIsScorecardProfile();
	            overall.getShowReviewEdit();
	            overall.getShowOverallRatingRead();
	            overall.getShowOverallRatingWrite();
	            overall.getShowOverallRating();
	            overall.getIsManager();  
	            overall.getIsEmployee();
	            overall.getPerformanceReview();
	            overall.getDisplayOverallRating();
	            overall.getOverallRating();
	            overall.setOverallRating('3');
	            overall.getRatingSelectOptions();
	            
	            comps = overall.getCompetencies();
	            
	            if (comps.size() > 0){
			 		PerformanceOverallController.Competency competency = comps[0];
			 		competency.setCompetencyName(competency.getCompetencyName());
			 		competency.getRating();
			 		competency.setRating(2);
			 		competency.getWeight();
			 		competency.setWeight(4);
			 		competency.getRatingShow();
			 		
	            }
	                        
	            overall.getUserProfile();
	            
	            overall.getShowSupportScorecard();
	            
	            overall.getIsEducationProfile();
	            overall.getIsSupportProfile();
	            overall.getIsConsultingProfile();
	            overall.getIsCSMProfile();
	            overall.getHaveProfile();
	            overall.getIsSysAdminProfile();
	            overall.getScorecardViewProfile();
	            overall.getIsMngr();
	            overall.getIsMngrInAssmnt();
	            overall.getIsEmplMngr2ndMngrOr3PtInAssmnt();
	            overall.getOverallCalcMethodRatingView();
	            overall.getOverallCalcMetricRatingView();
	            overall.getOverallCalcCompRatingView();
	            overall.getOverallRatingView();
	            overall.getOverallCalcCompRatingView();
	            overall.getDisplayCompetencyCalculatedRating();
	            overall.getDisplayMethodCalculatedWeight();
	            overall.getDisplayMethodCalculatedRating();
	            overall.getDisplayMetricCalculatedWeight();
	            overall.getDisplayMetricCalculatedRating();
	            overall.getDisplayOverallCalculatedRating();
	            overall.getScorecardSupport();
	            overall.getIsQuarterV2MOM();
	            overall.getValueApprove();
	            overall.getShowApprove();
	            
	            List<PerformanceOverallController.additionalCommentDate> ch = overall.getCommentsHistory();
	            
	            if (ch.size() > 0){
	            	ch[0].setAdditionalComment(ch[0].getAdditionalComment());
	            	ch[0].setCreatedDate(ch[0].getCreatedDate());
	            }
	                
	            overall.getShowMessage();
	               
	            overall.getCurrentComment();
	            overall.setCurrentComment('current comment');
	            overall.getApproveFlag();
	            overall.getRejectFlag();
	            overall.getThirdSubmitFlag();         
	            overall.getThirdRequestFlag();
	            overall.getShowError();
	            overall.getMsgError().equals('');         
	            overall.flipApprove();
	            overall.flipReject();
	            overall.flip3rdPartySubmit();
	            overall.flip3rdPartyRequest();
	            overall.cancelButton();
	            overall.getValueSubmit();
	            overall.getShowSubmit();
	            overall.getShowSubmitPCOMM();
	            overall.getValueReject();
	            overall.getShowReject();
	            overall.getShow3rdPartySubmitButton();
	            overall.thirdPartyButton();
	            overall.cancel3rdPartyButton();
	            overall.notBelongsPerformaceReview(userId);
	        
	            overall.getShow3rdPartyButton();
	            overall.getAllMethodWeightSum() ;
	            overall.getMethodAndMetricWeight();
	            overall.getCompetencyWeight();
	            overall.getMetricWeight();
	            overall.getCompetencyWeight();
	            overall.getMethodCalculatedRating();
	            overall.getMethodCalculatedRatingWithinMethods();
	            overall.getMetricCalculatedRating();
	            overall.getMetricCalculatedRatingWithinMetrics();
	            overall.getMethodsAndMetricsCalculatedRating();
	            overall.getCompetencyCalculatedRating();
	            overall.getCompetencyCalculatedRatingWithinCompetencies();
	            overall.getOverallCalculatedRating();
	       
	            overall.getIsManagerOrSecondManager();
	        }catch(Exception e){
	            System.debug(' ****************** test_PerformanceOverallController_User * ');
	            System.debug(e.getMessage());
	        }
            
            try{
            	if (((pr.Status__c == 'Employee Self Assessment') && (userId == pr.Employee__c))
					|| ((pr.Status__c == '2nd Level Manager Assessment') && (userId == pr.SecondManager__c))
            		|| ((pr.Status__c == 'Manager Assessment') && (userId == pr.Manager__c))){
		            overall.saveButton();
		            if (test_case == 1){
		            	test_case = 2;
		            	overall.approve();
		            }
		            if (test_case == 2){
		            	test_case = 3;
		            	overall.disapproveButton();
		            }
            	}
            }catch(Exception e){
	            System.debug(' ****************** test_PerformanceOverallController_User * ');
	            System.debug(e.getMessage());
            }

            try{
		        if (test_case == 3){
	            	if ((pr.Status__c == '2nd Level Manager Assessment') && (userId == pr.SecondManager__c)){
		            	overall.submitToPCOMM();
			            test_case = 4;
	            	}
		        }
            }catch(Exception e){
	            System.debug(' ****************** test_PerformanceOverallController_User * ');
	            System.debug(e.getMessage());
            }

            
    }
    
    public static testMethod void testPerformanceOverrall_Submit(){
    	Test.startTest();
    		PerformanceReview__c pr = [Select Id, Status__c, CreatedDate, Employee__c, Manager__c, SecondManager__c, PCOMM__c, PreviousStatus__c, ReviewRating__r.CalculatedRating__c  From PerformanceReview__c limit 1][0];
    		String userId = pr.Manager__c;
    		System.currentPageReference().getParameters().put('id', pr.Id);
    		System.assertEquals(System.currentPageReference().getParameters().get('id'), pr.Id);
    		PerformanceOverallController overall = new PerformanceOverallController(userId);
    		
    		//try{
	            overall.submitCommentButton();
	            overall.acceptButton();
	            
	            overall.submit3rdPartyButton();
	            
	          
            /*}catch(Exception e){
	            System.debug(' ****************** test_PerformanceOverallController_User * ');
	            System.debug(e.getMessage());
            }*/

            try{
		        if (test_case == 5){
	            	if (((pr.Status__c == '2nd Level Manager Assessment') && (userId == pr.SecondManager__c))
	            		|| ((pr.Status__c == 'Manager Assessment') && (userId == pr.Manager__c))){
		            	overall.request3rdPartyButton();
			            test_case = 6;
	            	}
		        }
            }catch(Exception e){
	            System.debug(' ****************** test_PerformanceOverallController_User * ');
	            System.debug(e.getMessage());
            }
            try{
		        if (test_case == 6){
	            	if ((pr.Status__c == '2nd Level Manager Assessment') && (userId == pr.SecondManager__c)){
		            	overall.submit3rdPartyButton();
			            test_case = 1;
	            	}
		        }
            }catch(Exception e){
	            System.debug(' ****************** test_PerformanceOverallController_User * ');
	            System.debug(e.getMessage());
            }

            try{
            	if (((pr.Status__c == 'Employee Approval') && (userId == pr.Employee__c))
            		|| ((pr.Status__c == 'Manager Approval') && (userId == pr.Manager__c)))
	            	overall.acceptButton();
            }catch(Exception e){
	            System.debug(' ****************** test_PerformanceOverallController_User * ');
	            System.debug(e.getMessage());
            }
    		
    	Test.stopTest();
    }
    
    public static testMethod void testPerformanceOverrall_Submit2(){
    	Test.startTest();
    		PerformanceReview__c pr = [Select Id, Status__c, CreatedDate, Employee__c, Manager__c, SecondManager__c, PCOMM__c, PreviousStatus__c, ReviewRating__r.CalculatedRating__c  From PerformanceReview__c limit 1][0];
    		String userId = pr.Manager__c;
    		System.assertEquals(userId, pr.Manager__c);
    		System.currentPageReference().getParameters().put('id', pr.Id);
    		PerformanceOverallController overall = new PerformanceOverallController(userId);
    		overall.goFromManagerApprovalReject();
	        overall.goFromPCOMMReject();
	        overall.getIsCompleteBack();
	        overall.submitToPCOMM();
    	Test.stopTest();	
    }
    
    public static testMethod void testPerformanceOverall_Submit3(){
    	Test.startTest();
    	
    			PerformanceReview__c pr = [Select Id, Status__c, CreatedDate, Employee__c, Manager__c, SecondManager__c, PCOMM__c, PreviousStatus__c, ReviewRating__r.CalculatedRating__c  From PerformanceReview__c limit 1][0];
    			String userId = pr.Manager__c;
    			System.assertEquals(userId, pr.Manager__c);
    			System.currentPageReference().getParameters().put('id', pr.Id);
    			PerformanceOverallController overall = new PerformanceOverallController(userId);
    			overall.shareMethodReview();
	            overall.shareCompetencyReview();
	            overall.getShowTextAreaSummaryComment();
	            overall.getIsMngrSecondMngrAssessment();
	            overall.getShowRejectDefaultButton();
	            overall.getShowReject3Party();
	            overall.getShowIncomplete();
	            overall.goCompleteBack();
	            overall.goFromPCOMMReject();
	            overall.getIsCompleteBack();
	            overall.getIsOldPerformanceReview();
	            overall.getIsOnlyJuniorAdminProfile();
	            
    	Test.stopTest();
    }
        
    public static testMethod void testRating(){
               PerformanceReview__c pr = [Select Id, Status__c, CreatedDate, Employee__c, Manager__c, SecondManager__c, PCOMM__c, PreviousStatus__c, ReviewRating__r.CalculatedRating__c  From PerformanceReview__c limit 1][0];
    		   String userId = pr.Manager__c;
    		   System.assertEquals(userId, pr.Manager__c);
    		   System.currentPageReference().getParameters().put('id', pr.Id);
    		   PerformanceOverallController overall = new PerformanceOverallController(userId);
    		   PerformanceOverallController.Method method = new PerformanceOverallController.Method('name');
    		   method.getMethod();
    		   method.getMethodName();
    		
    }    
        
 }