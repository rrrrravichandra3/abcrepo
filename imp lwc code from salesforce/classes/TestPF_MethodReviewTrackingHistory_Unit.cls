@isTest
private class TestPF_MethodReviewTrackingHistory_Unit {
  
    static testMethod void Test_MethodReviewTrackingHistory() {
       Test.startTest();
       User employeeStandard;
       User managerStandard;
       User secondManagerStandard;
       User pcommStandard;
        
       V2MOM__c v2momIndividual;
       Method__c method;
       Department__c department;
       MethodReview__c review;  
       String statusThirdParty='3rd Party Assessment';
       double rating1 = 25;
       double weight = 34;
       String statusManagerAssessment = 'Manager Assessment';
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
        department =  new Department__c(Name='Test',ExcludeESBP__c=true);
        insert department;
       
        //Create Competency Group
        CompetencyGroup__c competencyGroup = new CompetencyGroup__c(Name = 'CCCompGrp', Code__c = 'CCCompGrp');
        
        System.assertEquals(competencyGroup.Name, 'CCCompGrp');
		insert competencyGroup;
		//Create Review Form Template
        ReviewFormTemplate__c reviewFormTemplate = new ReviewFormTemplate__c(Name = 'CCRevTpl', Code__c = 'CCRevTpl');
        System.assertEquals(reviewFormTemplate.Name, 'CCRevTpl');
        insert reviewFormTemplate;
      
        PerformanceReview__c performanceReview = new PerformanceReview__c(Name = 'Performance Review',
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
        System.assertEquals(performanceReview.V2MOM__c, v2momIndividual.Id);                                                             
        PerformanceMethodController controller = new PerformanceMethodController(method ,performanceReview); 
		
        //Create a New Method REview
               //Create Method Review
	    review = new MethodReview__c(Name='Review Name',CreatedDate=sdate,LastModifiedDate=edate,Reviewer__c =managerStandard.Id);	
	    insert review;
	    review.Comment__c = 'Change';
	    update review;
 
        Test.stopTest();
 
    } 
}