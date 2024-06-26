@isTest
private class Test_PerformanceReviewController {
	static testmethod void performanceReviewControllerTest(){
		Test.startTest();
         
		Id currentUserId = userInfo.getUserId();


        User employeeStandard;
        User managerStandard;
        User secondManagerStandard;
        User pcommStandard;
        
        V2MOM__c v2momIndividual;
        Method__c method;
        Department__c department;
        MethodReview__c review; 
        List<MethodReview__c> history;
        List<Obstacle__c> obstacle;
        List<Measure__c> metrics;
        
        double rating1 = 25;
        double weight = 34;
        String statusManagerAssessment = 'Manager Assessment';
        String statusThirdParty='3rd Party Assessment';
        String previousStatus='Created';
        
        
      			
        //Create Employees         
        employeeStandard  = [select id, username, name, Profile.Name from User where username=:GenerateEnvironmentTestUsers.ccstndmngr];
        managerStandard =  [select id, username, name, Profile.Name from User where username=:GenerateEnvironmentTestUsers.CCRevSup2ndMngr];
        secondManagerStandard =  [select id, username, name, Profile.Name from User where username=:GenerateEnvironmentTestUsers.CCStnd2ndMngr];
        pcommStandard = [select id, username, name, Profile.Name from User where username=:GenerateEnvironmentTestUsers.CCPCOMM];


        //Create Performance Review Period
      	Date sdate = System.today();
		Date edate = sdate.addYears(1);
         PerformanceReviewPeriod__c performanceReviewPeriod = new PerformanceReviewPeriod__c(Name = 'Test PRP Department',
																		Effective_Date__c = 'FY11',
																		V2MOM_Type__c = 'Individual',
															            StartDate__c = sdate,
																		EndDate__c = edate);
        
        

        
        //Create a new V2MOM
        v2momIndividual = GenerateEnvironmentTest3.createV2MOM(employeeStandard.Id, 'Vision', 'Individual', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
       
        //Create a method associated to the V2MOM
        method  =  GenerateEnvironmentTest3.createMethod(v2momIndividual.Id, null, 1, 'Method', 'Description');
       
        //Create a Department
        department =  GenerateEnvironmentTest3.createDepartment('Test Department', false);
       
        //Create Competency Group
        CompetencyGroup__c competencyGroup = new CompetencyGroup__c(Name = 'CCCompGrp', Code__c = 'CCCompGrp');
		insert competencyGroup;
		//Create Review Form Template
        ReviewFormTemplate__c reviewFormTemplate = new ReviewFormTemplate__c(Name = 'CCRevTpl', Code__c = 'CCRevTpl');
        insert reviewFormTemplate;
      
        PerformanceReview__c p = new PerformanceReview__c(Name = 'Performance Review',
														   PerformanceReviewPeriod__c = performanceReviewPeriod.Id,
														   V2MOM__c = v2momIndividual.Id,
														   CompetencyGroup__c = competencyGroup.Id,
														   ReviewFormTemplate__c = reviewFormTemplate.Id,
														   Employee__c = employeeStandard.Id,
														   Manager__c = managerStandard.Id,
														   SecondManager__c = secondManagerStandard.Id,
														   PCOMM__c = pcommStandard.Id,
														   Department__c = department.Id,
														   Status__c = statusThirdParty,
													       PreviousStatus__c = statusManagerAssessment); 
	   insert p;  


		
				ApexPages.Standardcontroller testController = new ApexPages.Standardcontroller(p);
              
				
				PerformanceReviewController.Method methods = new PerformanceReviewController.Method(method,p);
                methods.getMethod();
                methods.getMethod();
                methods.getObstacles();
                methods.getReview();
                methods.getShowValue();
                methods.setMethod(method);
                List<Measure__c> m = new List<Measure__c>();
                methods.setMetrics(m);
                List<Obstacle__c> o = new List<Obstacle__c>();
                methods.setObstacles(o);
                methods.getMetrics();
                PerformanceReviewController testPerController = new PerformanceReviewController(testController,currentUserId);
                testPerController.cancelButton();
                testPerController.getRejectFlag();
                testPerController.getShowError();
                testPerController.getMsgError();
                testPerController.getShowEmployeeApproval();
                testPerController.getWithPrivileges();
                testPerController.getStartLinkText();
                Value__c v = new Value__c();
                PerformanceReviewController.Value values = new PerformanceReviewController.Value(v,true);
                values.getIsLast();
                values.getName();
               
	
		Test.stopTest();
	}
	
	static testMethod void unitTest1(){
		test.startTest();
			List<PerformanceReview__c> listPerformanceReview = [Select Id, Status__c, CreatedDate, ThirdPartyReviewer__c, Employee__c, Manager__c, SecondManager__c, PCOMM__c, V2MOM__c, PreviousStatus__c, ReviewRating__r.CalculatedRating__c  From PerformanceReview__c limit 5];
			 
			Id currentUserId = userInfo.getUserId();
			PerformanceReview__c p = listPerformanceReview[3];
			ApexPages.Standardcontroller testController = new ApexPages.Standardcontroller(p);
			PerformanceReviewController testPerController = new PerformanceReviewController(testController,currentUserId);
			testPerController.getMethods();
			testPerController.getCurrentComment();
			testPerController.getCompetencies();
			testPerController.getCommentsHistory();
			testPerController.getDueDate();
			testPerController.getReviewers();
			testPerController.getShowReviewEdit();
			testPerCOntroller.submitCommentButton();
			testPerController.rejectCommentButton();
		test.stopTest();
	}
	
	static testMethod void unitTest2(){
		test.startTest();
			List<PerformanceReview__c> listPerformanceReview = [Select Id, Status__c, CreatedDate, ThirdPartyReviewer__c, Employee__c, Manager__c, SecondManager__c, PCOMM__c, V2MOM__c, PreviousStatus__c, ReviewRating__r.CalculatedRating__c  From PerformanceReview__c limit 5];
			 
			Id currentUserId = userInfo.getUserId();
			PerformanceReview__c p = listPerformanceReview[3];
			ApexPages.Standardcontroller testController = new ApexPages.Standardcontroller(p);
			PerformanceReviewController testPerController = new PerformanceReviewController(testController,currentUserId);
			testPerController.moveToEmployeeApproval();
			testPerController.setStatus();
			testPerController.setupSharingScorecard();
			testPerController.keepOldSharingHierarchy();
			testPerController.getIsCurrentReviewer();
			testPerController.setCurrentUserId(p.Manager__c);
			testPerController.setPerformanceReview(p);
			testPerController.setupSharingScorecard();
			testPerController.getEmployeeCommentsPrint();
			testPerController.getShowEmployeeMessageMethodsPrint();
			testPerController.getShowManagerMessageMethodsPrint();
			testPerController.getShowEmployeeMessageCompetenciesPrint();
			testPerController.getShow3rdPartySubmitButton();
			testPerController.getShowManagerMessageCompetenciesPrint();
			testPerController.getCommentsHistoryPrint();
			testPerController.getShowEmployeeMessageMethods();
			testPerController.getShowManagerMessageMethods();
			testPerController.getShowEmployeeMessageCompetencies();
			testPerController.getShowManagerMessageCompetencies();
			testPerController.getShowMessageAdditional();
			testPerController.getIsManager();
			testPerController.goStep1();		
			testPerController.getPerformanceReview();
			testPerController.getV2MOM();
			testPerController.getCurrentUserId();
			testPerController.getEmployee();
			testPerController.getIsEmployeeSelfAssessmentOrCreated();
			testPerController.getQuarter();
			testPerController.getIsShort();
			testPerController.getIsEmplMngr2ndMngrOr3PtInAssmnt();
			testPerController.getManager();
			testPerController.getStepsTopMargin();
			testPerController.getStyleEditV2MOMLink();
			List<MethodReview__c> mthr =[Select r.Name, 
                                        		r.Method__c, 
                                        		r.CreatedDate, 
                                        		r.CreatedBy.Name, 
                                        		r.Reviewer__c, 
                                        		r.Weight__c, 
                                        		r.Rating__c 
                                 		From MethodReview__c r 
                                 		Where PerformanceReview__c =: p.Id];
                                 		

            testPerController.getIsMngr();
                       		
			testPerController.getRenderReject();
			testPerController.completeButton();
			testPerController.getShowSubmit();
			testPerController.getShowIncomplete(); 
			testPerController.changeIncomplete();
			//testPerController.performanceReview.DueDate__c=System.now().date();
			//testPerController.getDueDate();
			//testPerController.performanceReview.Quarter__c='null';
			testPerController.getQuarter();
			testPerController.getPrId();
			testPerController.getIsYearEnd();

			

            
			
			
					
						
		test.stopTest();
	}
	

	
	static testMethod void reviewersListTest(){
		
				
			//Create an admin user to test
      
        	Test.startTest();
        	Profile p = [select id from profile where name='System Administrator'];
        	User uAdmin = new User(alias = 'adminU', email='admin@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='admin@testorg.com');
        	insert uAdmin;
        	
            Id currentUserId = userInfo.getUserId();
        	//List<PerformanceReview__c> reviews = GenerateEnvironmentTest2.genPerformanceReview2(); 
        	PerformanceReview__c performanceReview = [Select Id, Status__c, CreatedDate, Employee__c, Manager__c, SecondManager__c, PCOMM__c, PreviousStatus__c, ReviewRating__r.CalculatedRating__c  From PerformanceReview__c where performanceReviewPeriod__r.v2mom_Type__c = 'Year End Short'][0];
        	ApexPages.Standardcontroller testController=new ApexPages.Standardcontroller(performanceReview);
        	
        	PerformanceReviewController testPerController=new PerformanceReviewController(testController);	
        	
			
        	List<PerformanceReview__History> listHistory = [SELECT  CreatedDate,
                    												Id,
                            										CreatedById,
                            										CreatedBy.Profile.Name,
                            										NewValue,
                            										OldValue,
                            										Field 
                    										 FROM PerformanceReview__History
                   											 WHERE Field = 'Status__c' AND ParentId =: performanceReview.id
                    										 Order By CreatedDate desc];
        	PerformanceReviewController.Reviewer r1 = new PerformanceReviewController.Reviewer(uAdmin,performanceReview,'Employee',listHistory);
        	PerformanceReviewController.Reviewer r2 = new PerformanceReviewController.Reviewer(uAdmin, performanceReview, 'Manager', listHistory);
			PerformanceReviewController.Reviewer r3 = new PerformanceReviewController.Reviewer(uAdmin, performanceReview, 'PCOMM', listHistory);
			PerformanceReviewController.Reviewer r4 = new PerformanceReviewController.Reviewer(uAdmin, performanceReview, 'Second Manager', listHistory);
			r1.getDateApproval();
			r2.getDateApproval();
			r3.getDateApproval();
			r4.getDateApproval();
			r1.getLabelApproved();
			r2.getLabelApproved();
			r3.getLabelApproved();
			r4.getLabelApproved();
			r1.getCurrentReviewer();
			r2.getCurrentReviewer();
			r3.getCurrentReviewer();
			r4.getCurrentReviewer();
			r1.getCurrentReviewer();
			r2.getCurrentReviewer();
			r3.getCurrentReviewerReview();
			r4.getCurrentReviewer();
			r1.getIsCompleted();
			r2.getStatus();
			r3.getDepartment();
			r4.getCalculatedRating();
			
			
			r4.getCurrentReviewerReview();
			r3.getCurrentReviewerApproval();	
		Test.stopTest();
		
	}
	static testmethod void testMethod3(){
		test.startTest();
	    Id currentUserId = userInfo.getUserId();


        User employeeStandard;
        User managerStandard;
        User secondManagerStandard;
        User pcommStandard;
        
        V2MOM__c v2momIndividual;
        Method__c method;
        Department__c department;
        MethodReview__c review; 
        List<MethodReview__c> history;
        List<Obstacle__c> obstacle;
        List<Measure__c> metrics;
        
        double rating1 = 25;
        double weight = 34;
        String statusManagerAssessment = 'Manager Assessment';
        String statusThirdParty='3rd Party Assessment';
        String previousStatus='Created';
        
        
      			
        //Create Employees         
        employeeStandard  = [select id, username, name, Profile.Name from User where username=:GenerateEnvironmentTestUsers.ccstndmngr];
        managerStandard =  [select id, username, name, Profile.Name from User where username=:GenerateEnvironmentTestUsers.CCRevSup2ndMngr];
        secondManagerStandard =  [select id, username, name, Profile.Name from User where username=:GenerateEnvironmentTestUsers.CCStnd2ndMngr];
        pcommStandard = [select id, username, name, Profile.Name from User where username=:GenerateEnvironmentTestUsers.CCPCOMM];


        //Create Performance Review Period
      	Date sdate = System.today();
		Date edate = sdate.addYears(1);
         PerformanceReviewPeriod__c performanceReviewPeriod = new PerformanceReviewPeriod__c(Name = 'Test PRP Department',
																		Effective_Date__c = 'FY11',
																		V2MOM_Type__c = 'Individual',
															            StartDate__c = sdate,
																		EndDate__c = edate);
        
        

        
        //Create a new V2MOM
        v2momIndividual = GenerateEnvironmentTest3.createV2MOM(employeeStandard.Id, 'Vision', 'Individual', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
       
        //Create a method associated to the V2MOM
        method  =  GenerateEnvironmentTest3.createMethod(v2momIndividual.Id, null, 1, 'Method', 'Description');
       
        //Create a Department
        department =  GenerateEnvironmentTest3.createDepartment('Test Department', false);
       
        //Create Competency Group
        CompetencyGroup__c competencyGroup = new CompetencyGroup__c(Name = 'CCCompGrp', Code__c = 'CCCompGrp');
		insert competencyGroup;
		//Create Review Form Template
        ReviewFormTemplate__c reviewFormTemplate = new ReviewFormTemplate__c(Name = 'CCRevTpl', Code__c = 'CCRevTpl');
        insert reviewFormTemplate;
      
        PerformanceReview__c p = new PerformanceReview__c(Name = 'Performance Review',
														   PerformanceReviewPeriod__c = performanceReviewPeriod.Id,
														   V2MOM__c = v2momIndividual.Id,
														   CompetencyGroup__c = competencyGroup.Id,
														   ReviewFormTemplate__c = reviewFormTemplate.Id,
														   Employee__c = employeeStandard.Id,
														   Manager__c = managerStandard.Id,
														   SecondManager__c = secondManagerStandard.Id,
														   PCOMM__c = pcommStandard.Id,
														   Department__c = department.Id,
														   Status__c = statusThirdParty,
													       PreviousStatus__c = statusManagerAssessment); 
	   
		
		
		
		    p.DueDate__c=null;
			p.Employee__c=currentUserID;
			insert p;
			ApexPages.Standardcontroller testController = new ApexPages.Standardcontroller(p);
			PerformanceReviewController testPerController = new PerformanceReviewController(testController,currentUserId);
			testPerController.getDueDate();
			testPerController.moveToEmployeeApproval();
			testPerController.setStatus();
			testPerController.setupSharingScorecard();
			testPerController.keepOldSharingHierarchy();
			testPerController.getIsCurrentReviewer();
			testPerController.setCurrentUserId(p.Manager__c);
			testPerController.setPerformanceReview(p);
			testPerController.setupSharingScorecard();
			testPerController.getEmployeeCommentsPrint();
			testPerController.getShowEmployeeMessageMethodsPrint();
			testPerController.getShowManagerMessageMethodsPrint();
			testPerController.getShowEmployeeMessageCompetenciesPrint();
			testPerController.getShow3rdPartySubmitButton();
			testPerController.getShowManagerMessageCompetenciesPrint();
			testPerController.getCommentsHistoryPrint();
			testPerController.getShowEmployeeMessageMethods();
			testPerController.getShowManagerMessageMethods();
			testPerController.getShowEmployeeMessageCompetencies();
			testPerController.getShowManagerMessageCompetencies();
			testPerController.getShowMessageAdditional();
			testPerController.getIsManager();
			testPerController.goStep1();		
			testPerController.getPerformanceReview();
			testPerController.getV2MOM();
			testPerController.getCurrentUserId();
			testPerController.getEmployee();
			testPerController.getIsEmployeeSelfAssessmentOrCreated();
			testPerController.getQuarter();
			testPerController.getIsShort();
			testPerController.getIsEmplMngr2ndMngrOr3PtInAssmnt();
			testPerController.getManager();
			testPerController.getStepsTopMargin();
			testPerController.getStyleEditV2MOMLink();
			List<MethodReview__c> mthr =[Select r.Name, 
                                        		r.Method__c, 
                                        		r.CreatedDate, 
                                        		r.CreatedBy.Name, 
                                        		r.Reviewer__c, 
                                        		r.Weight__c, 
                                        		r.Rating__c 
                                 		From MethodReview__c r 
                                 		Where PerformanceReview__c =: p.Id];
                                 		



		test.stopTest();
	}
	static testMethod void testIntroUtil(){
		test.startTest();
		PerformanceReviewController.IntroUtil intro = new PerformanceReviewController.IntroUtil();
		PerformanceReview__c performanceReview = [Select Id, Status__c, CreatedDate, Employee__c, Manager__c, SecondManager__c, PCOMM__c, PreviousStatus__c, ReviewRating__r.CalculatedRating__c  From PerformanceReview__c][0];
		intro.getPerformanceReviewDetail(performanceReview);
		
		test.stopTest(); 
	} 
}