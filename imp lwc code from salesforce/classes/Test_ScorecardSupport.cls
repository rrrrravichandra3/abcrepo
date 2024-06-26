@isTest
private class Test_ScorecardSupport { 
	  
	 //This Controller is Deprecated
     public static testMethod void testScorecardSupport() {
             
        PerformanceReviewPeriod__c prp;
        CompetencyGroup__c compGroup;
        Competency__c competency;
        CompetencyGroupMember__c compGroupMember;
        ReviewFormTemplate__c rft;     
        PerformanceReview__c p;
        User employeeStandard;
        User managerStandard;
        User secondManagerStandard;
        User pcommStandard;

        //Create Employees         
        employeeStandard  =  GenerateEnvironmentTest.getEmployeeStandard();       
        managerStandard =   GenerateEnvironmentTest.getManager();       
        pcommStandard = createPCOMM();         
		secondManagerStandard = create2ndManager();
		
		system.runAs( GenerateEnvironmentTest3.getSystemAdmin() ){
		
		//Review Period
		prp = createReviewPeriod();
            
        //V2MOM
        V2MOM__c v2mom = GenerateEnvironmentTest3.createV2MOM(employeeStandard.Id, 'Vision', 'Individual', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
       
        //Create a Department
		Department__c department =  GenerateEnvironmentTest3.createDepartment('Test Department', false);
			       		        
		//Create Competency Group
		compGroup = createCompetencyGroup();
					
		//Competencies for the competency group
		competency = createCompetency();								
				
		//Competency group member
		compGroupMember = createCompetencyGroupMember(compGroup, competency );
				
		//Create Review Form Template
		rft = createReviewFormTemplate(); 
			    
        //Performance Review
        p = createPerformanceReview(prp, v2mom, compGroup, rft, employeeStandard, managerStandard, pcommStandard, department, secondManagerStandard);
		ScorecardSupportReview__c supportReview = insertScorecardSupportReview('SSR', p.Id);
			

		ScorecardSupport ss = new ScorecardSupport(p);
		system.assert(ss != null);
			
			ss = null;
			ss = new ScorecardSupport();


			ss = null;
			ss = new ScorecardSupport(p, true);
		
			Profile usrProfile = [select id from Profile where id = :employeeStandard.ProfileId];
			ss.csmController.setPerformanceAccessUtil(new PerformanceAccessUtil(p,employeeStandard,employeeStandard));
		    ss.supportController.setPerformanceAccessUtil(new PerformanceAccessUtil(p,employeeStandard,employeeStandard));
		
			ScorecardSupport.OverallUtil oUtil = ss.getOverallUtil();
			
			ss.checkScorecards();
			
			ss.checkManagerEducationDataEntryRequirements(1);
			
			ss.checkManagerSupportDataEntryRequirements(supportReview);
			
			ss.checkManagerCSMDataEntryRequirements(1);
			
			ss.checkManagerSupportCommentEntryRequirements();
			
			ss.checkManagerNewSupportDataEntryRequirements(1);
			ss.checkManagerSupportDataEntryRequirements();
			//ss.checkWeightSum(supportReview);
			
			ss.getRatingCSMSalesImpact();
			ss.getRatingRenewalExcellence();
			ss.getRatingOperationalExcellence();
			ss.getRatingStrategicInitiatives();
			ss.getRatingWMCCP();
			ss.getWeightWMCCP();
			ss.getRatingWMCAA();
			ss.getWeightWMCAA();
			ss.getRatingCustomerSatisfaction();
			ss.getWeightCustomerSatisfaction();
			ss.getWeightCSMSalesImpact();
			ss.getWeightRenewalExcellence();
			ss.getWeightOperationalExcellence();
			ss.getWeightStrategicInitiatives();
			System.assert(oUtil != null);
		}
     }
     
     static ScorecardSupportReview__c insertScorecardSupportReview(String n, Id performanceReviewId){
      
      	ScorecardSupportReview__c s = new ScorecardSupportReview__c (name=n, performanceReview__c = performanceReviewId);
      	insert s;
      	return s;
     }
     
     static  PerformanceReviewPeriod__c createReviewPeriod(){
			Date sdate = System.today();
				Date edate = sdate.addYears(1);
		         PerformanceReviewPeriod__c performanceReviewPeriod = new PerformanceReviewPeriod__c(Name = 'Test PRP Department',
																				Effective_Date__c = 'FY11',
																				V2MOM_Type__c = 'Individual',
																	            StartDate__c = sdate,
																				EndDate__c = edate);
		        
		        insert performanceReviewPeriod;
		        return performanceReviewPeriod;
		
	}
	
	static User createPCOMM(){
		Profile profile = [Select Id From Profile where Name =: 'PCOMM'];
		User pcommStandard =  new User(	username = 'testpcomm@test.com',
										lastName = 'standard',
										email = 'emptest1@mailinator.com',
										alias = 'etest',
										timeZoneSidKey ='America/Los_Angeles',
										
										localeSidKey = 'en_US',
										emailEncodingKey = 'ISO-8859-1',
										LanguagelocaleKey = 'en_US',
										ProfileId = profile.Id
									);
 		insert pcommStandard;
 		return pcommStandard;
	}
	
	static User create2ndManager(){
		Profile profile = [Select Id From Profile where Name =: 'Manager'];
		User secondManager =  new User(	username = 'secondManager@test.com',
										lastName = 'standard',
										email = 'emptest1@mailinator.com',
										alias = 'etest',
										timeZoneSidKey ='America/Los_Angeles',
										
										localeSidKey = 'en_US',
										emailEncodingKey = 'ISO-8859-1',
										LanguagelocaleKey = 'en_US',
										ProfileId = profile.Id
									);
 		insert secondManager;
 		return secondManager;
	}

    static   CompetencyGroup__c createCompetencyGroup(){
    	    CompetencyGroup__c competencyGroup = new CompetencyGroup__c(Name = 'CCCompGrp', Code__c = 'CCCompGrp');
			insert competencyGroup;
			return competencyGroup;
    }
    
   static   Competency__c createCompetency(){
   		 Competency__c competency = new Competency__c(Name = 'Competency1');
		 insert competency;
		 return competency;
   }
   
   static CompetencyGroupMember__c createCompetencyGroupMember(CompetencyGroup__c competencyGroup, Competency__c competency){
   		CompetencyGroupMember__c competencyGroupMember = new CompetencyGroupMember__c(CompetencyGroup__c = competencyGroup.Id, Competency__c = competency.Id );
		insert competencyGroupMember;
		return competencyGroupMember;
		
   }
   
   static   ReviewFormTemplate__c createReviewFormTemplate(){
     ReviewFormTemplate__c reviewFormTemplate = new ReviewFormTemplate__c(Name = 'CCRevTpl', Code__c = 'CCRevTpl');
	 insert reviewFormTemplate;
	 return reviewFormTemplate;
   }
   
    static  PerformanceReview__c createPerformanceReview(PerformanceReviewPeriod__c performanceReviewPeriod, V2MOM__c v2momIndividual,CompetencyGroup__c competencyGroup, ReviewFormTemplate__c reviewFormTemplate, User employeeStandard, User managerStandard, User pcommStandard, Department__c department,User secondManager){
  	 	String statusThirdParty='3rd Party Assessment';
  	 	String statusManagerAssessment = 'Manager Assessment';
       PerformanceReview__c p = new PerformanceReview__c(Name = 'Performance Review',
																   PerformanceReviewPeriod__c = performanceReviewPeriod.Id,
																   V2MOM__c = v2momIndividual.Id,
																   CompetencyGroup__c = competencyGroup.Id,
																   ReviewFormTemplate__c = reviewFormTemplate.Id,
																   Employee__c = employeeStandard.Id,
																   Manager__c = managerStandard.Id,
																   SecondManager__c = secondManager.Id,
																   PCOMM__c = pcommStandard.Id,
																   Department__c = department.Id,
																   Status__c = statusThirdParty,
															       PreviousStatus__c = statusManagerAssessment); 
			   insert p;  
			   return p;
    }
    
}