@isTest
private class Test_MyTeamController {
      
    public static testMethod void execute_methods_MyTeamcontroller() {

        GenerateEnvironmentTest.getUsers(); 
         
        Test.startTest();        
   
      
        User users = GenerateEnvironmentTest.managerStandard;
        
        System.debug('The first user is ' + users );
        MyTeamController controller = new MyTeamController();
		System.debug('DIRECTT ' + controller.getDirectReports());
	    controller.selectAllEmployees();
        controller.getEmployeesSelected();
        controller.launchPerformanceReview();
        controller.launchPerfromanceReviewAdHoc();
     

		System.debug('BEFOREE');
        controller.getShowErrors();
        controller.getShowWarnings();
        controller.getErrors();
        controller.getWarnings();
            
          
        System.debug('AFTERR');
        
        System.currentPageReference().getParameters().put('id', users.id);
        controller = new MyTeamController();
       
        // test InnerClass SetupInfo
        MyTeamController.SetupInfo s = new MyTeamController.SetupInfo(users, 'Hola');
        
        s.getUser();
        s.getMessage();
        // END test SetupInfo
        
        controller.setCurrentUserId(users.Id); 
        
        controller.getErrors();
        controller.getWarnings();
        controller.getError();
    
       
        controller.getShowFirstLaunch();
        controller.getShowError();
        
        controller.getEffectiveDates();
        controller.setEffectiveDate('FY09');
        System.assert(controller.getEffectiveDate().equals('FY09'));
        controller.getDirectReports();
        controller.getMyTeam();
        
        controller.selectAllEmployees();
        controller.getEmployeesSelected();
       
    
        controller.getPerformanceReviewsType();
        
        controller.launch();
        controller.cancel();	        
        
        controller.getMyTeamUtil();
        controller.getThisYear();
        controller.getQuarters();
        controller.getPerformanceReview();
        controller.getQuarter();
        controller.setQuarter('Q1');
        controller.setPerformanceReview(controller.getPerformanceReview());
        // InnerClass DirectReportWrapper
        MyTeamController.DirectReportWrapper drw = new MyTeamController.DirectReportWrapper(users);
        
        drw.getUser();
       // drw.getLatestReview();
        drw.getCalculatedRating();
        drw.getPerformanceReviewAdHoc();
        drw.setPerformanceReviewAdHoc(true);
        drw.getPerformanceReviewType();
        drw.setPerformanceReviewType(1);
        drw.getPerformanceReviewTypeName();
        drw.setPerformanceReviewType(0);
        drw.getPerformanceReviewTypeName();
        // END DirectReportWrapper	        

    	//Test_PAMUtil.execute_PAMUtilController();
        users = GenerateEnvironmentTest.managerSupport;
        System.debug('\n **** user Support ' + users);
        	
        System.currentPageReference().getParameters().put('id', users.id);
        controller = new MyTeamController();
       
        controller.setCurrentUserId(users.Id); 
        
        controller.getEffectiveDates();
        controller.setEffectiveDate('FY09');
        System.assert(controller.getEffectiveDate().equals('FY09'));
        controller.getDirectReports();
        controller.getMyTeam();
        
        controller.selectAllEmployees();
        controller.getEmployeesSelected();
        controller.launchPerfromanceReviewAdHoc();
        controller.launchPerformanceReview();
        controller.getAux();
        controller.setAux('Test');
        controller.getToday();
        controller.getLastName();
        controller.getFirstName();
        controller.getTitle();
        controller.getStreet();
        controller.getCity();
        controller.getPhone();
        controller.getDepartment();
        controller.getFax();
        controller.getReviewManager();
        controller.getEmail();
        controller.getIsBack();
        controller.back();
        
        MyTeamController.MyTeamUtil util = controller.getMyTeamUtil();
        
      
        controller.getPerformanceReviewsType();
        
        controller.launch();
        controller.cancel();        

        Test.stopTest();
        
    }
    
    public static testMethod void execute_methods_MyTeamcontroller2()
    {
    	 GenerateEnvironmentTest.getUsers(); 
       
        User user = GenerateEnvironmentTest.managerStandard;
       
       	System.debug('The user is ' + user );
       	
        System.runAs(user){
        	
            Test.startTest();  
			
			try {
				MyTeamController controller = new MyTeamController();
				controller.getDirectReports();
			    controller.selectAllEmployees();
			    System.assert(controller.getAccessValidation()); 
		        controller.getEmployeesSelected();
		        controller.launchPerfromanceReviewAdHoc();
		        controller.launchPerformanceReview();
		        controller.getLoggedUser();
		        controller.getIsPCOMMOrFirstManager();
		        controller.getDueDate();
			} catch (Exception e) {
	            System.debug(' ****************** execute_methods_MyTeamcontroller2 * ');
	            System.debug(e.getMessage());
			}
			
            Test.stopTest();
            
        }
    }
    
    public static testMethod void execute_methods_MyTeamcontroller3() {
    	
    	
    	Test.startTest();  
    	
    	try {
	    	MyTeamController controller = new MyTeamController();
	    	
	    	// InnerClass PerformanceReviewWrapper
	    	
	        List<MyTeamController.PerformanceReviewWrapper> prws = controller.getPerformanceReviews();
	        if (prws.size() <= 0) {
		        List<PerformanceReview__c> prs = new List<PerformanceReview__c>{GenerateEnvironmentTest2.PRQ3Q4};
		        MyTeamController.PerformanceReviewWrapper icprw = new MyTeamController.PerformanceReviewWrapper(prs[0]);
		        icprw.getPerformanceReview();
		        icprw.getOverallRating();
		        icprw.getCalculatedRating();
		        
		        prs = new List<PerformanceReview__c>{GenerateEnvironmentTest2.PRQ1Q2};
		        icprw = new MyTeamController.PerformanceReviewWrapper(prs[0]);
		        icprw.getPerformanceReview();
		        icprw.getOverallRating();
		        icprw.getCalculatedRating();
	        }
	        else {
		        for (Integer i=0; i<prws.size(); i++) {
		           MyTeamController.PerformanceReviewWrapper prw = prws[i];
		           System.assert(prw.getPerformanceReview() != null);
		           prw.getOverallRating();
		           prw.getCalculatedRating();
		        }
	        }
		} catch (Exception e) {
            System.debug(' ****************** execute_methods_MyTeamcontroller3 * ');
            System.debug(e.getMessage());
		}
        
        // END PerformanceReviewWrapper	
    	
    	Test.stopTest();
    	
    }    
    
}