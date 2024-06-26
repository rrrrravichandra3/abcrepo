public class GenerateEnvironmentTest2 {
	/*
	 * ENVIRONMENT TO TEST: Test_EmployeeHandbookEditController, 
	 						Test_MethodPriorizationRow, 
	 						Test_MyTeamController,
	 						Test_PerformanceESBPAdminController,
	 						Test_userProfileTrig,
	 						Test_userV2MOMTrig , 
	 						Test_V2MOM_Admin_Web_Services, 
	 						Test_V2MOM_PDF_Controller, 
	 						Test_V2MOM_Value_Wrapper
	 						Test_V2MOM_Web_Services, 
	 						Test_PerformancePCOMMController, 
	 						Test_PerformanceReviewSharingManager
	*/
	
	//public static Department__c department;
	public static TF2_Department__c department;
	
	public static CompetencyGroup__c competencyGroup;
	public static Competency__c competency;
	
	public static User manager;
	public static User employeeStandard;
	public static User managerStandard;
	public static User secondManagerStandard;
	public static User reviewManagerStandard;
	public static User review2ndManagerStandard;
	public static User pcommStandard;
	public static User esadminStandard;
	
	public static User employeeSupport;
	public static User managerSupport; // manager of employeeSupport
	public static User secondManagerSupport; // manager of managerSupport
	public static User reviewManagerSupport; // review manager of employeeSupport
	public static User review2ndManagerSupport; // review manager of managerSupport
	//public static User pcommSupport; // pcomm of the employeeSupport
	//public static User esadminSupport; // ES admin of the employeeSupport
	//public static User thirdPartySupport;
	
	public static User consultingEmployee;
	public static User consultingManager;
	public static User consulting2ndManager;
	
	public static User employeeEducation;
	public static User managerEducation;
	public static User secondManagerEducation;
	public static User reviewManagerEducation;
	public static User review2ndManagerEducation;
	
	public static V2MOM__c v2momAdHoc;
	public static V2MOM__c v2momIndividual;
	public static V2MOM__c v2momIndividualQ1Q2;
	public static V2MOM__c v2momIndividualQ3Q4;
	public static V2MOM__c v2momDepartment;
	public static V2MOM__c v2momOnboarding;
	public static V2MOM__c v2momOrganization;
	
	public static Value__c value1;
	public static Value__c value2;

	public static Method__c method1;
	public static Method__c method2;
	public static Method__c method3;
	
	public static Value__c valueD1;
	public static Value__c valueD2;

	public static Method__c methodD1;
	public static Method__c methodD2;
	public static Method__c methodD3;
	
	public static Obstacle__c obstacle1;
	public static Obstacle__c obstacle2;

	public static Measure__c measure1;
	public static Measure__c measure2;

	public static ReviewFormTemplate__c reviewFormTemplate;
	
	public static PerformanceReviewPeriod__c PRPIndividual;
	public static PerformanceReviewPeriod__c PRPIndividualQ1Q2;
	public static PerformanceReviewPeriod__c PRPIndividualQ3Q4;
	public static PerformanceReviewPeriod__c PRPDepartment;
	public static PerformanceReviewPeriod__c PRPOnboarding;
	public static PerformanceReviewPeriod__c PRPOrganization;
	public static PerformanceReviewPeriod__c PRPAdHoc;
	

	public static PerformanceReview__c PRCreated;
	public static PerformanceReview__c PREmplAssmnt;
	public static PerformanceReview__c PRMngrAssmnt;
	public static PerformanceReview__c PR3rdPartyAssmnt;
	public static PerformanceReview__c PR2ndMngrAssmnt;
	public static PerformanceReview__c PREmplServ;
	public static PerformanceReview__c PRPCOMM;
	public static PerformanceReview__c PRMngrApproval;
	public static PerformanceReview__c PREmplApproval;
	public static PerformanceReview__c PRComplete;
	public static PerformanceReview__c PR3rdParty;
	public static PerformanceReview__c PREmplSelfAssmnt;
	
	public static PerformanceReview__c PRQ1Q2;
	public static PerformanceReview__c PRQ3Q4;
	public static PerformanceReview__c PRDepartment;

	public static PerformanceReview__c PRIndividual;
	public static PerformanceReview__c PRIndividualQ1Q2Edu;
	public static PerformanceReview__c PRIndividualQ3Q4Edu;
	public static PerformanceReview__c PRIndividualQ1Q2Sup;
	public static PerformanceReview__c PRIndividualQ3Q4Sup;

	public static List<PerformanceReview__c> allPRs = new List<PerformanceReview__c>();
	
	public static ScorecardSupportReview__c sQ1;
	public static ScorecardSupportReview__c sQ2;
	public static ScorecardSupportReview__c sQ3;
	public static ScorecardSupportReview__c sQ4;
	
	public static ScorecardSupportComment__c sscommQ1Q2SuprevMngr;
	public static ScorecardSupportComment__c sscommQ1Q2Suprev2ndMngr;
	
	public static Method__c method;
	public static Method__c methodNotTide;
	public static V2MOM__c v2mom;
	public static Value__c value;
	public static Obstacle__c obstacle;
	public static Measure__c measure;
	public static Obstacle__c obstacleNotTide;
	public static Measure__c measureNotTide;
	
	public static List<Profile> profList;
	public static List<User> userList;
	public static List<Value__c> valueList;
	public static List<ScorecardSupportComment__c> allSSComms = new List<ScorecardSupportComment__c>();
	
	public static List<ScorecardSupportReview__c> allScorecards = new List<ScorecardSupportReview__c>();
	public static Employee_Handbook__c employeeHandbook;
	
	public static ScorecardSupportReview__c sQ1Edu;
	public static ScorecardSupportReview__c sQ2Edu;
	public static ScorecardSupportReview__c sQ3Edu;
	public static ScorecardSupportReview__c sQ4Edu;
	
	public static ScorecardSupportComment__c sscommQ1Q2EdurevEmpl;
	public static ScorecardSupportComment__c sscommQ1Q2EdurevMngr;
	public static ScorecardSupportComment__c sscommQ1Q2Edurev2ndMngr;
	
	public static ScorecardSupportComment__c sscommQ3Q4EdurevEmpl;
	public static ScorecardSupportComment__c sscommQ3Q4EdurevMngr;
	public static ScorecardSupportComment__c sscommQ3Q4Edurev2ndMngr;

	public static V2MOM__c v2momIndividualQ1Q2Sup;
	public static V2MOM__c v2momIndividualQ3Q4Sup;
	public static V2MOM__c v2momIndividualQ1Q2Edu;
	public static V2MOM__c v2momIndividualQ3Q4Edu;
		
	public static Method__c methodQ1Q2Sup1;
	public static Method__c methodQ1Q2Sup2;
	public static Method__c methodQ3Q4Sup3;
	public static Method__c methodQ3Q4Sup4;

	public static Method__c methodQ1Q2Edu1;
	public static Method__c methodQ1Q2Edu2;
	public static Method__c methodQ3Q4Edu3;
	public static Method__c methodQ3Q4Edu4;

	public static List<Method__c> allMethods = new List<Method__c>();
	
	public static CompetencyGroupMember__c competencyGroupMember1;
	public static CompetencyGroupMember__c competencyGroupMember2;
	public static List<CompetencyGroupMember__c> allCompetencyGroupMembers = new List<CompetencyGroupMember__c>();
	public static Competency__c competency1;
	public static Competency__c competency2;
	
	public static MethodReview__c method1revEmpl;
	public static MethodReview__c method1revMngr;
	public static MethodReview__c method1rev2ndMngr;
	public static MethodReview__c method1rev3rdParty;
	
	public static MethodReview__c method2revEmpl;
	public static MethodReview__c method2revMngr;
	public static MethodReview__c method2rev2ndMngr;
	public static MethodReview__c method2rev3rdParty;
	
	public static MethodReview__c methodQ1Q2Sup1revEmpl;
	public static MethodReview__c methodQ1Q2Sup1revMngr;
	public static MethodReview__c methodQ1Q2Sup1rev2ndMngr;
	public static MethodReview__c methodQ1Q2Sup1rev3rdParty;
	
	public static MethodReview__c methodQ1Q2Sup2revEmpl;
	public static MethodReview__c methodQ1Q2Sup2revMngr;
	public static MethodReview__c methodQ1Q2Sup2rev2ndMngr;
	public static MethodReview__c methodQ1Q2Sup2rev3rdParty;
	
	public static MethodReview__c methodQ3Q4Sup3revEmpl;
	public static MethodReview__c methodQ3Q4Sup3revMngr;
	public static MethodReview__c methodQ3Q4Sup3rev2ndMngr;
	public static MethodReview__c methodQ3Q4Sup3rev3rdParty;
	
	public static MethodReview__c methodQ3Q4Sup4revEmpl;
	public static MethodReview__c methodQ3Q4Sup4revMngr;
	public static MethodReview__c methodQ3Q4Sup4rev2ndMngr;
	public static MethodReview__c methodQ3Q4Sup4rev3rdParty;
	
	public static MethodReview__c methodQ1Q2Edu1revEmpl;
	public static MethodReview__c methodQ1Q2Edu1revMngr;
	public static MethodReview__c methodQ1Q2Edu1rev2ndMngr;
	public static MethodReview__c methodQ1Q2Edu1rev3rdParty;
	
	public static MethodReview__c methodQ1Q2Edu2revEmpl;
	public static MethodReview__c methodQ1Q2Edu2revMngr;
	public static MethodReview__c methodQ1Q2Edu2rev2ndMngr;
	public static MethodReview__c methodQ1Q2Edu2rev3rdParty;
	
	public static MethodReview__c methodQ3Q4Edu3revEmpl;
	public static MethodReview__c methodQ3Q4Edu3revMngr;
	public static MethodReview__c methodQ3Q4Edu3rev2ndMngr;
	public static MethodReview__c methodQ3Q4Edu3rev3rdParty;
	
	public static MethodReview__c methodQ3Q4Edu4revEmpl;
	public static MethodReview__c methodQ3Q4Edu4revMngr;
	public static MethodReview__c methodQ3Q4Edu4rev2ndMngr;
	public static MethodReview__c methodQ3Q4Edu4rev3rdParty;
	
	public static List<MethodReview__c> allMethodReviews = new List<MethodReview__c>();
	
	public static CompetencyReview__c competency1revEmpl;
	public static CompetencyReview__c competency1revMngr;
	public static CompetencyReview__c competency1rev2ndMngr;
	public static CompetencyReview__c competency1rev3rdParty;
	
	public static CompetencyReview__c competency2revEmpl;
	public static CompetencyReview__c competency2revMngr;
	public static CompetencyReview__c competency2rev2ndMngr;
	public static CompetencyReview__c competency2rev3rdParty;
	
	public static CompetencyReview__c competencyQ1Q2Sup1revEmpl;
	public static CompetencyReview__c competencyQ1Q2Sup1revMngr;
	public static CompetencyReview__c competencyQ1Q2Sup1rev2ndMngr;
	public static CompetencyReview__c competencyQ1Q2Sup1rev3rdParty;
	
	public static CompetencyReview__c competencyQ1Q2Sup2revEmpl;
	public static CompetencyReview__c competencyQ1Q2Sup2revMngr;
	public static CompetencyReview__c competencyQ1Q2Sup2rev2ndMngr;
	public static CompetencyReview__c competencyQ1Q2Sup2rev3rdParty;
	
	public static CompetencyReview__c competencyQ3Q4Sup3revEmpl;
	public static CompetencyReview__c competencyQ3Q4Sup3revMngr;
	public static CompetencyReview__c competencyQ3Q4Sup3rev2ndMngr;
	public static CompetencyReview__c competencyQ3Q4Sup3rev3rdParty;
	
	public static CompetencyReview__c competencyQ3Q4Sup4revEmpl;
	public static CompetencyReview__c competencyQ3Q4Sup4revMngr;
	public static CompetencyReview__c competencyQ3Q4Sup4rev2ndMngr;
	public static CompetencyReview__c competencyQ3Q4Sup4rev3rdParty;
	
	public static CompetencyReview__c competencyQ1Q2Edu1revEmpl;
	public static CompetencyReview__c competencyQ1Q2Edu1revMngr;
	public static CompetencyReview__c competencyQ1Q2Edu1rev2ndMngr;
	public static CompetencyReview__c competencyQ1Q2Edu1rev3rdParty;
	
	public static CompetencyReview__c competencyQ1Q2Edu2revEmpl;
	public static CompetencyReview__c competencyQ1Q2Edu2revMngr;
	public static CompetencyReview__c competencyQ1Q2Edu2rev2ndMngr;
	public static CompetencyReview__c competencyQ1Q2Edu2rev3rdParty;
	
	public static CompetencyReview__c competencyQ3Q4Edu3revEmpl;
	public static CompetencyReview__c competencyQ3Q4Edu3revMngr;
	public static CompetencyReview__c competencyQ3Q4Edu3rev2ndMngr;
	public static CompetencyReview__c competencyQ3Q4Edu3rev3rdParty;
	
	public static CompetencyReview__c competencyQ3Q4Edu4revEmpl;
	public static CompetencyReview__c competencyQ3Q4Edu4revMngr;
	public static CompetencyReview__c competencyQ3Q4Edu4rev2ndMngr;
	public static CompetencyReview__c competencyQ3Q4Edu4rev3rdParty;
	
	public static List<CompetencyReview__c> allCompetencyReviews = new List<CompetencyReview__c>();
	
	public static AdditionalComment__c overallrevEmpl;
	public static AdditionalComment__c overallrevMngr;
	public static AdditionalComment__c overallrev2ndMngr;
	public static AdditionalComment__c overallrev3rdParty;
	
	public static AdditionalComment__c overallQ1Q2SuprevEmpl;
	public static AdditionalComment__c overallQ1Q2SuprevMngr;
	public static AdditionalComment__c overallQ1Q2Suprev2ndMngr;
	public static AdditionalComment__c overallQ1Q2Suprev3rdParty;
	
	public static AdditionalComment__c overallQ3Q4SuprevEmpl;
	public static AdditionalComment__c overallQ3Q4SuprevMngr;
	public static AdditionalComment__c overallQ3Q4Suprev2ndMngr;
	public static AdditionalComment__c overallQ3Q4Suprev3rdParty;
	
	public static AdditionalComment__c overallQ1Q2EdurevEmpl;
	public static AdditionalComment__c overallQ1Q2EdurevMngr;
	public static AdditionalComment__c overallQ1Q2Edurev2ndMngr;
	public static AdditionalComment__c overallQ1Q2Edurev3rdParty;
	
	public static AdditionalComment__c overallQ3Q4EdurevEmpl;
	public static AdditionalComment__c overallQ3Q4EdurevMngr;
	public static AdditionalComment__c overallQ3Q4Edurev2ndMngr;
	public static AdditionalComment__c overallQ3Q4Edurev3rdParty;
	
	public static List<AdditionalComment__c> allOverallReviews = new List<AdditionalComment__c>();

	public static ReviewRating__c reviewRating;
	public static ReviewRating__c reviewRatingQ1Q2Sup;
	public static ReviewRating__c reviewRatingQ3Q4Sup;
	public static ReviewRating__c reviewRatingQ1Q2Edu;
	public static ReviewRating__c reviewRatingQ3Q4Edu;
	
	public static List<Method__c> methodList = new List<Method__c>();
	public static List<Measure__c> metricList = new List<Measure__c>();
	public static List<Obstacle__c> obstacleList = new List<Obstacle__c>();

	public static List<ReviewRating__c> allOverallRatings = new List<ReviewRating__c>();
	
	public static void genUsers(){
		List<User> tempUserList = new List<User>();
		User tempUser = new User();
		Integer index=0;
		for(Profile p:[Select Id, Name From Profile Where Name!='Package License Manager'limit 100]){
			tempUser = new User();
			//tempUser.Name = 'User'+index;
			tempUser.LastName = 'Test';
			tempUser.Username =  index+'Test@mailinator.com';
			tempUser.Alias = index+'Test';
			tempUser.Email = index+'Test@mailinator.com';
			tempUser.CommunityNickname = index+'Test';
			tempUser.ProfileId = p.Id;
			
			tempUser.TimeZoneSidKey ='America/Los_Angeles';
			tempUser.LocaleSidKey='en_US';
			tempUser.LanguageLocaleKey ='en_US';
			tempUser.EmailEncodingKey = 'UTF-8';
			tempUser.ReceivesInfoEmails = true; 
			tempUser.ReceivesAdminInfoEmails = true;
			tempUser.IsActive = true;
			
			tempUserList.add(tempUser);
			index++;
		}
		try{
			for(User u:tempUserList){
				insert u;	
			} 
				
		}catch(Exception e){
			e.getMessage();
		}
	}	
	public static void gen(){
		try {
			v2mom = createV2MOM('Test V2MOM', 'Department', 'FY08', 'Test', false);
			value = createValue('Test Value', v2mom, 1);
			
			addMethod(method, 'Test Method', value, v2mom, 1, 'test method');
			addMethodNotTide(methodNotTide, 'Test Not Tide Method', v2mom, 2, 'method not tide');	
			upsert methodList;
			
			addObstacle(obstacle, 'Test obstacle', v2mom, value, method, 1);
			addObstacleNotTide(obstacleNotTide, 'Test Obstacle Not Tide', v2mom, 2);			
			upsert obstacleList;
			
			addMetric(measure, 'Test metric', v2mom, value, method, System.today(), System.today(), 1);			
			addMetricNotTide(measureNotTide, 'Test Metric Not Tide', v2mom, System.today(), System.today(), 2);
			upsert metricList;
			
		} catch (Exception e) {
            System.debug(' ****************** gen Error * ');
            System.debug(e.getMessage());
		}
	}
	
	public static void getHandbook(){
		try {
			employeeHandbook = createHandbook('test handbook', 'Not Completed', 'FY09');
		} catch (Exception e) {
            System.debug(' ****************** getHandbook Error * ');
            System.debug(e.getMessage());
		}
	}
	
	public static void genPerformanceReview(){
		List<PerformanceReview__c> prList = new List<PerformanceReview__c>();
		
		//genUsers();
		
		User UsrPcomm = new User();
		User UsrEmpSupport = new User();
		User UsrManagerSupport = new User();
		User UsrSecondManagerSupport = new User();
		UsrPcomm = getUserByProfile('PCOMM');
		UsrEmpSupport = getUserByProfile('Support Employee');
		UsrManagerSupport = getUserByProfile('Support Manager');
		UsrSecondManagerSupport = getUserByProfile('Manager');
		
		
		
		v2mom = createV2MOM('Test V2MOM', 'Department', 'FY08', 'Test', false);
		department = createDepartment('Test Department', false);
		Date d1 = System.today();
		Date d2 = d1.addYears(1);
		PRPDepartment = createPRP('Test PRP Department', 'FY08', 'Department', d1, d2);
		competencyGroup = createCompetencyGroup();	
		reviewFormTemplate = createReviewFromTemplate();
		
		/* PCOMM Reviews For Accept and Reject */
	 	prList.add(new PerformanceReview__c(name='Test PReviewPCOMReviewForAccept', PerformanceReviewPeriod__c=PRPDepartment.Id, V2MOM__c=v2mom.Id, CompetencyGroup__c=competencyGroup.Id, ReviewFormTemplate__c=reviewFormTemplate.Id,Employee__c=UsrEmpSupport.Id, Manager__c=UsrManagerSupport.Id, SecondManager__c=UsrSecondManagerSupport.Id, PCOMM__c=UsrPcomm.Id, Cost_Center__c=department.Id, Status__c='PCOMM Review'));
	 	prList.add(new PerformanceReview__c(name='Test PReviewPCOMReviewForAccept2', PerformanceReviewPeriod__c=PRPDepartment.Id, V2MOM__c=v2mom.Id, CompetencyGroup__c=competencyGroup.Id, ReviewFormTemplate__c=reviewFormTemplate.Id,Employee__c=UsrEmpSupport.Id, Manager__c=UsrManagerSupport.Id, SecondManager__c=UsrSecondManagerSupport.Id, PCOMM__c=UsrPcomm.Id, Cost_Center__c=department.Id, Status__c='PCOMM Review'));
	 	prList.add(new PerformanceReview__c(name='Test PReviewPCOMReviewForAccept3', PerformanceReviewPeriod__c=PRPDepartment.Id, V2MOM__c=v2mom.Id, CompetencyGroup__c=competencyGroup.Id, ReviewFormTemplate__c=reviewFormTemplate.Id,Employee__c=UsrEmpSupport.Id, Manager__c=UsrManagerSupport.Id, SecondManager__c=UsrSecondManagerSupport.Id, PCOMM__c=UsrPcomm.Id, Cost_Center__c=department.Id, Status__c='PCOMM Review'));
	 	prList.add(new PerformanceReview__c(name='Test PReviewPCOMReviewForReject_2ndManager', PerformanceReviewPeriod__c=PRPDepartment.Id, V2MOM__c=v2mom.Id, CompetencyGroup__c=competencyGroup.Id, ReviewFormTemplate__c=reviewFormTemplate.Id,Employee__c=UsrEmpSupport.Id, Manager__c=UsrManagerSupport.Id, SecondManager__c=UsrSecondManagerSupport.Id, PCOMM__c=UsrPcomm.Id, Cost_Center__c=department.Id, Status__c='PCOMM Review'));
	 	prList.add(new PerformanceReview__c(name='Test PReviewPCOMReviewForReject_No2ndManager', PerformanceReviewPeriod__c=PRPDepartment.Id, V2MOM__c=v2mom.Id, CompetencyGroup__c=competencyGroup.Id, ReviewFormTemplate__c=reviewFormTemplate.Id,Employee__c=UsrEmpSupport.Id, Manager__c=UsrManagerSupport.Id, SecondManager__c=null, PCOMM__c=UsrPcomm.Id, Cost_Center__c=department.Id, Status__c='PCOMM Review'));
	 	
		try{
			insert prList;
		}catch(DMLException e){
			system.debug(e.getMessage());
		}	
	}
	
	public static List<PerformanceReview__c> genPerformanceReview2(){
		List<PerformanceReview__c> prList = new List<PerformanceReview__c>();
		
		//genUsers();
		
		User UsrPcomm = new User();
		User UsrEmpSupport = new User();
		User UsrManagerSupport = new User();
		User UsrSecondManagerSupport = new User();
		UsrPcomm = getUserByProfile('PCOMM');
		UsrEmpSupport = getUserByProfile('Support Employee');
		UsrManagerSupport = getUserByProfile('Support Manager');
		UsrSecondManagerSupport = getUserByProfile('Manager');
		
		
		
		v2mom = createV2MOM('Test V2MOM', 'Department', 'FY08', 'Test', false);
		department = createDepartment('Test Department', false);
		Date d1 = System.today();
		Date d2 = d1.addYears(1);
		PRPDepartment = createPRP('Test PRP Department', 'FY08', 'Department', d1, d2);
		competencyGroup = createCompetencyGroup();	
		reviewFormTemplate = createReviewFromTemplate();
		
		/* PCOMM Reviews For Accept and Reject */
	 	prList.add(new PerformanceReview__c(name='Test PReviewPCOMReviewForAccept', PerformanceReviewPeriod__c=PRPDepartment.Id, V2MOM__c=v2mom.Id, CompetencyGroup__c=competencyGroup.Id, ReviewFormTemplate__c=reviewFormTemplate.Id,Employee__c=UsrEmpSupport.Id, Manager__c=UsrManagerSupport.Id, SecondManager__c=UsrSecondManagerSupport.Id, PCOMM__c=UsrPcomm.Id, Cost_Center__c=department.Id, Status__c='PCOMM Review'));
	 	prList.add(new PerformanceReview__c(name='Test PReviewPCOMReviewForAccept2', PerformanceReviewPeriod__c=PRPDepartment.Id, V2MOM__c=v2mom.Id, CompetencyGroup__c=competencyGroup.Id, ReviewFormTemplate__c=reviewFormTemplate.Id,Employee__c=UsrEmpSupport.Id, Manager__c=UsrManagerSupport.Id, SecondManager__c=UsrSecondManagerSupport.Id, PCOMM__c=UsrPcomm.Id, Cost_Center__c=department.Id, Status__c='PCOMM Review'));
	 	prList.add(new PerformanceReview__c(name='Test PReviewPCOMReviewForAccept3', PerformanceReviewPeriod__c=PRPDepartment.Id, V2MOM__c=v2mom.Id, CompetencyGroup__c=competencyGroup.Id, ReviewFormTemplate__c=reviewFormTemplate.Id,Employee__c=UsrEmpSupport.Id, Manager__c=UsrManagerSupport.Id, SecondManager__c=UsrSecondManagerSupport.Id, PCOMM__c=UsrPcomm.Id, Cost_Center__c=department.Id, Status__c='PCOMM Review'));
	 	prList.add(new PerformanceReview__c(name='Test PReviewPCOMReviewForReject_2ndManager', PerformanceReviewPeriod__c=PRPDepartment.Id, V2MOM__c=v2mom.Id, CompetencyGroup__c=competencyGroup.Id, ReviewFormTemplate__c=reviewFormTemplate.Id,Employee__c=UsrEmpSupport.Id, Manager__c=UsrManagerSupport.Id, SecondManager__c=UsrSecondManagerSupport.Id, PCOMM__c=UsrPcomm.Id, Cost_Center__c=department.Id, Status__c='PCOMM Review'));
	 	prList.add(new PerformanceReview__c(name='Test PReviewPCOMReviewForReject_No2ndManager', PerformanceReviewPeriod__c=PRPDepartment.Id, V2MOM__c=v2mom.Id, CompetencyGroup__c=competencyGroup.Id, ReviewFormTemplate__c=reviewFormTemplate.Id,Employee__c=UsrEmpSupport.Id, Manager__c=UsrManagerSupport.Id, SecondManager__c=null, PCOMM__c=UsrPcomm.Id, Cost_Center__c=department.Id, Status__c='PCOMM Review'));
	 	
		/*try{
			insert prList;
		}catch(DMLException e){
			system.debug(e.getMessage());
		}*/
		return prList;	
	}
	
	public static void genV2MOM_Value(){
		try {
			getUsers();
			v2mom = createV2MOMTwo(employeeStandard.Id, 'vision individual', 'Individual', 'V2MOM Individual', 'FY08', 'My Management Hierarchy');
			value1 = createValue('Value 1', v2mom, 1);
			value2 = createValue('Value 2', v2mom, 2);
			valueList = new List<Value__c>();
			valueList.add(value1);
			valueList.add(value2);
			
			addMethod(method1, 'Method 1', value1, v2mom, 1, 'Description method 1');
			addMethod(method2, 'Method 2', value1, v2mom, 2, 'Description method 2');
			upsert methodList;
			
		} catch (Exception e) {
            System.debug(' ****************** genV2MOM_Value Error * ');
            System.debug(e.getMessage());
		}
	}
	public static User getUserByProfile(String profileName){
		return [Select id, Name From User Where Profile.Name =: profileName limit 1];
	}
	public static void genUsersTriggers(){
		try {
			getUsers();
			V2MOM__c v = createV2MOMTwo(employeeStandard.Id, 'vision individual', 'Individual', 'V2MOM Individual', 'FY08', 'My Management Hierarchy');
		} catch (Exception e) {
            System.debug(' ****************** genUsersTriggers Error * ');
            System.debug(e.getMessage());
		}
	}
	
	public static void genPerformanceReviewFlow(){
		try {
			getUsers();
			
			createV2MOMIndividualData();
			department = createDepartment('Test Department', false);
			Date d1 = System.today();
			Date d2 = d1.addYears(1);
			
			competencyGroup = createCompetencyGroup();
			reviewFormTemplate = createReviewFromTemplate();
			
			PRPDepartment = createPRP('Test PRP Department', 'FY08', 'Department', d1, d2);
			
			PRDepartment = createPerformanceReview('Test PReviewDepartment', PRPDepartment.Id, v2momDepartment.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 employeeSupport.Id, reviewManagerSupport.Id, review2ndManagerSupport.Id, pcommStandard.Id, department.Id, 'Created');
	
			sscommQ1Q2SuprevMngr = createScorecardSupportReviewComment(PRDepartment.Id,
																		employeeSupport.Id, 
																		'CS comm Q1Q2 employee sup',
																		'renewals comm Q1Q2 employee sup',
																		'WMCases comm Q1Q2 employee sup',
																		'WMSMES comm Q1Q2 employee sup', 
																		'WMHC comm Q1Q2 employee sup',
																		'WMPA comm Q1Q2 employee sup',
																		'supportInitiatives comm Q1Q2 employee sup',
																		'salesImpact comm Q1Q2 employee sup',
																		'timeOnPlatform comm Q1Q2 employee sup',
																		'forecastAccuracy comm Q1Q2 employee sup');
		
			upsert(allSSComms);
	
		} catch (Exception e) {
            System.debug(' ****************** genPerformanceReviewFlow Error * ');
            System.debug(e.getMessage());
		}
	}
	
	public static void genPerformanceReviewsWithPrevStatus(){
		try {		
			getUsers();
			//createV2MOMIndividualData();
			v2momDepartment = createV2MOMTwo(employeeStandard.Id, 'vision Department', 'Department', 'V2MOM Department', 'FY08', 'My Management Hierarchy');
			
			department = createDepartment('Test Department', false);
			
			Date d1 = System.today();
			Date d2 = d1.addYears(1);
			
			competencyGroup = [select Id from CompetencyGroup__c where Name = 'CCCompGrp' and Code__c='CCCompGrp'];
			
			reviewFormTemplate = [select Id from ReviewFormTemplate__c where Name = 'CCRevTpl' and Code__c='CCRevTpl'];
			
			
			//Create the performance review period for differents V2MOMs types		
			PRPIndividualQ1Q2 = createPRP('Test PRP IndividualQ1/Q2', 'FY08', 'Individual Q1/Q2', d1, d2);
			PRPIndividualQ3Q4 = createPRP('Test PRP IndividualQ3/Q4', 'FY08', 'Individual Q3/Q4', d1, d2);
			PRPDepartment = createPRP('Test PRP Department', 'FY08', 'Department', d1, d2);
			
			//Create the differents performance review for each V2MOMs types		
			PRDepartment = createPerformanceReview2('Test PReviewDepartment', PRPDepartment.Id, v2momDepartment.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 employeeSupport.Id, reviewManagerSupport.Id, review2ndManagerSupport.Id, pcommStandard.Id, department.Id, 'Created', null);
			
			PREmplAssmnt = createPerformanceReview2('Test PReviewEmplAssess', PRPDepartment.Id, v2momDepartment.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 employeeSupport.Id, reviewManagerSupport.Id, review2ndManagerSupport.Id, pcommStandard.Id, department.Id, 'Employee Self Assessment', 'Created');
			
			PRMngrAssmnt = createPerformanceReview2('Test PReviewMgrAssess', PRPDepartment.Id, v2momDepartment.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 employeeSupport.Id, reviewManagerSupport.Id, review2ndManagerSupport.Id, pcommStandard.Id, department.Id, 'Manager Assessment', 'Employee Self Assessment');
			
			PR2ndMngrAssmnt = createPerformanceReview2('Test PReview2ndMgrAssess', PRPDepartment.Id, v2momDepartment.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 employeeSupport.Id, reviewManagerSupport.Id, review2ndManagerSupport.Id, pcommStandard.Id, department.Id, '2nd Level Manager Assessment', 'Manager Assessment');
			
			PRPCOMM = createPerformanceReview2('Test PReviewPCOMM', PRPDepartment.Id, v2momDepartment.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 employeeSupport.Id, reviewManagerSupport.Id, review2ndManagerSupport.Id, pcommStandard.Id, department.Id, 'PCOMM Review', 'Pending Employee Services');
			
			PR3rdParty = createPerformanceReview2('Test PReview3rdParty', PRPDepartment.Id, v2momDepartment.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 employeeSupport.Id, reviewManagerSupport.Id, review2ndManagerSupport.Id, pcommStandard.Id, department.Id, '3rd Party Assessment', '2nd Level Manager Assessment');
											 
			PREmplSelfAssmnt = createPerformanceReview2('Test PReviewEmplSelfAssmnt', PRPDepartment.Id, v2momDepartment.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 employeeSupport.Id, reviewManagerSupport.Id, review2ndManagerSupport.Id, pcommStandard.Id, department.Id, 'Pending Employee Services', '2nd Level Manager Assessment');										 
		 	
		} catch (Exception e) {
            System.debug(' ****************** genPerformanceReviewsWithPrevStatus * ');
            System.debug(e.getMessage());
		}
	}
	
	
	public static Employee_Handbook__c createHandbook(String name, String status, String fiscalYear){
		Employee_Handbook__c eH = new Employee_Handbook__c();
		eH.Name = name;
		eH.Status__c = status;
		eH.Fiscal_Year__c = fiscalYear;
		
		upsert(eH);
		return eH;
	}
		
	public static PerformanceReviewPeriod__c createPRP(String pname, String effdate, String v2momType, Date sdate, Date edate){
		PerformanceReviewPeriod__c prp = new PerformanceReviewPeriod__c(Name = pname,
																		Effective_Date__c = effdate,
																		V2MOM_Type__c = v2momType,
																		StartDate__c = sdate,
																		EndDate__c = edate);
																		
		upsert (prp);
		
		return prp;
	}
	
	
	public static V2MOM__c createV2MOMTwo(Id user, String vision, String t, String name, 
										String effDate, String share){
		V2MOM__c v = new V2MOM__c (	OwnerId=user,
										Vision__c = vision, 
										V2MOM_Type__c = t,
										Name = name, 
										Effective_Date__c = effDate,
										Share_With__c = share);
		upsert(v);
		
		return v;
	}
	
	public static V2MOM__c createV2MOM(String name, String t, String effectiveDate, String vision, boolean locked){
		V2MOM__c v = new V2MOM__c();
		v.Name = name;
		v.V2MOM_Type__c = t;
		v.Effective_Date__c = effectiveDate;
		v.Vision__c = vision;
		v.Locked__c = locked;
		upsert(v);
		return v;
	}
	public static Value__c createValue(String name, V2MOM__c v, double priority){
		Value__c val = new Value__c();
		val.Name = name;
		val.V2MOM__c = v.Id;
		val.Priority__c = priority;
		upsert(val);
		return val;
	}
	
	public static void addMethod(Method__c m, String name, Value__c v, V2MOM__c v2m, double priority, String description){
		m = new Method__c();
		m.Name = name;
		m.Value__c = v.Id;
		m.V2MOM__c = v2m.Id;
		m.Priority__c = priority;
		m.Description__c = description;
		
		methodList.add(m);
	}
	
	public static void addMethodNotTide(Method__c m, String name, V2MOM__c v2m, double priority, String description){
		m = new Method__c();
		m.Name = name;
		m.Value__c = null;
		m.V2MOM__c = v2m.Id;
		m.Priority__c = priority;
		m.Description__c = description;
		
		methodList.add(m);
	}
	
	public static void addObstacle(Obstacle__c o, String description, V2MOM__c v, Value__c val, Method__c m, double priority){
		o = new Obstacle__c();
		o.Description__c = description;
		o.V2MOM__c = v.Id;
		o.Value__c = val.Id;
		if(m != null){
			o.Method__c = m.Id;
		}else{
			for (Method__c me : methodList){
				if (me.v2mom__c == v.Id){
					o.Method__c = me.Id;
					break;
				}
			}
		}
		o.Priority__c = priority;
		
		obstacleList.add(o);
	}
	
	public static void addObstacleNotTide(Obstacle__c o, String description, V2MOM__c v, double priority){
		o = new Obstacle__c();
		o.Description__c = description;
		o.V2MOM__c = v.Id;
		o.Value__c = null;
		o.Method__c = null;
		o.Priority__c = priority;
		
		obstacleList.add(o);
	}
	
	public static void addMetric(Measure__c me, String description, V2MOM__c v, Value__c val, Method__c m, Date startDate, Date endDate, double priority){
		me = new Measure__c();
		me.Description__c = description;
		me.V2MOM__c = v.Id;
		me.Value__c = val.Id;
		me.Method__c = m.Id;
		me.Start_Date__c = startDate;
		me.End_Date__c = endDate;
		me.Priority__c = priority;
		
		metricList.add(me);
	}
	
	public static void addMetricNotTide(Measure__c me, String description, V2MOM__c v, Date startDate, Date endDate, double priority){
		me = new Measure__c();
		me.Description__c = description;
		me.V2MOM__c = v.Id;
		me.Value__c = null;
		me.Method__c = null;
		me.Start_Date__c = startDate;
		me.End_Date__c = endDate;
		me.Priority__c = priority;
		
		metricList.add(me);
	}
	
	
	
	//public static Department__c createDepartment(String name, boolean excl){
	public static TF2_Department__c createDepartment(String name, boolean excl){
		//Department__c d = new Department__c();
		TF2_Department__c d = new TF2_Department__c();
		d.Name = name;
		d.Exclude_ESBP__c = excl;
		
		upsert(d);
		
		return d;
	}
	
	// Method to crate the differents V2MOMs	
	public static void createV2MOMIndividualData(){
		v2momIndividual = createV2MOMTwo(employeeStandard.Id, 'vision individual', 'Individual', 'V2MOM Individual', 'FY08', 'My Management Hierarchy');
		v2momIndividualQ1Q2 = createV2MOMTwo(employeeSupport.Id, 'vision individual Q1Q2', 'Individual Q1/Q2', 'V2MOM Individual Q1Q2', 'FY08', 'My Management Hierarchy');
		v2momIndividualQ3Q4 = createV2MOMTwo(employeeSupport.Id, 'vision individual Q3Q4', 'Individual Q3/Q4', 'V2MOM Individual Q3Q4', 'FY08', 'My Management Hierarchy');
		v2momDepartment = createV2MOMTwo(employeeStandard.Id, 'vision Department', 'Department', 'V2MOM Department', 'FY08', 'My Management Hierarchy');
		v2momOnboarding = createV2MOMTwo(employeeStandard.Id, 'vision Onboarding', 'Onboarding', 'V2MOM Onboarding', 'FY08', 'My Management Hierarchy');
		v2momOrganization = createV2MOMTwo(employeeStandard.Id, 'vision Organization', 'Organization', 'V2MOM Organization', 'FY08', 'My Management Hierarchy');

		value1 = createValue('Value 1', v2momIndividual, 1);
		value2 = createValue('Value 2', v2momIndividual, 2);
	
		addMethod(method1, 'Method 1', value1, v2momIndividual, 1, 'Description method 1');
		addMethod(method2, 'Method 2', value1, v2momIndividual, 2, 'Description method 2');
		addMethod(method3, 'Method 3', value1, v2momIndividual, 3, 'Description method 3');
		upsert methodList;
				
		valueD1 = createValue('Value Dep 1', v2momDepartment, 1);
		valueD2 = createValue('Value Dep 2', v2momDepartment, 2);

		Date d = System.today();
	}
	
	public static Competency__c createCompetency(String name, String d){
		Competency__c c = new Competency__c();
		c.Name = name;
		c.Description__c = d;
		upsert(c);
		return c;
	}
	
	public static void getUsers(){
		userList = [select id, username, Profile.Name, CompanyName from User 
												where username=:GenerateEnvironmentTestUsers.ccpcomm 
												or username=:GenerateEnvironmentTestUsers.ccesadmin
												or username=:GenerateEnvironmentTestUsers.ccceo
												or username=:GenerateEnvironmentTestUsers.ccesbp
												
												or username=:GenerateEnvironmentTestUsers.ccstndempl
												or username=:GenerateEnvironmentTestUsers.ccstndmngr
												or username=:GenerateEnvironmentTestUsers.ccrevstndmngr
												or username=:GenerateEnvironmentTestUsers.ccrevstnd2ndmngr
												or username=:GenerateEnvironmentTestUsers.ccstnd2ndmngr
												
												or username=:GenerateEnvironmentTestUsers.ccsup2ndmngr
												or username=:GenerateEnvironmentTestUsers.ccrevsup2ndmngr
												or username=:GenerateEnvironmentTestUsers.ccsupmngr
												or username=:GenerateEnvironmentTestUsers.ccrevsupmngr
												or username=:GenerateEnvironmentTestUsers.ccsupempl
												
												or username=:GenerateEnvironmentTestUsers.ccedu2ndmngr
												or username=:GenerateEnvironmentTestUsers.ccrevedu2ndmngr
												or username=:GenerateEnvironmentTestUsers.ccedumngr
												or username=:GenerateEnvironmentTestUsers.ccrevedumngr
												or username=:GenerateEnvironmentTestUsers.cceduempl
												
												or username=:GenerateEnvironmentTestUsers.cccons2ndmngr
												or username=:GenerateEnvironmentTestUsers.ccrevcons2ndmngr
												or username=:GenerateEnvironmentTestUsers.ccconsmngr
												or username=:GenerateEnvironmentTestUsers.ccrevconsmngr
												or username=:GenerateEnvironmentTestUsers.ccconsempl
												
												or username=:GenerateEnvironmentTestUsers.cccsm2ndmngr
												or username=:GenerateEnvironmentTestUsers.ccrevcsm2ndmngr
												or username=:GenerateEnvironmentTestUsers.cccsmmngr
												or username=:GenerateEnvironmentTestUsers.ccrevcsmmngr
												or username=:GenerateEnvironmentTestUsers.cccsmempl
												or username=:GenerateEnvironmentTestUsers.ccconsempl
												];
												
		pcommStandard = getUser(GenerateEnvironmentTestUsers.ccpcomm);
		esadminStandard = getUser(GenerateEnvironmentTestUsers.ccesadmin);
												
		//employeeStandard = getUser(GenerateEnvironmentTestUsers.ccstndempl);
		employeeStandard = getEmployeeStandard();
		
		managerStandard = getUser(GenerateEnvironmentTestUsers.ccstndmngr);
		secondManagerStandard = getUser(GenerateEnvironmentTestUsers.ccstnd2ndmngr);
		reviewManagerStandard = getUser(GenerateEnvironmentTestUsers.ccrevstndmngr);
		review2ndManagerStandard = getUser(GenerateEnvironmentTestUsers.ccrevstnd2ndmngr);

		employeeSupport = getUser(GenerateEnvironmentTestUsers.ccsupempl);
		managerSupport = getUser(GenerateEnvironmentTestUsers.ccsupmngr);
		secondManagerSupport = getUser(GenerateEnvironmentTestUsers.ccsup2ndmngr);
		reviewManagerSupport = getUser(GenerateEnvironmentTestUsers.ccrevsupmngr);
		review2ndManagerSupport = getUser(GenerateEnvironmentTestUsers.ccrevsup2ndmngr);

		employeeEducation = getUser(GenerateEnvironmentTestUsers.cceduempl);
		managerEducation = getUser(GenerateEnvironmentTestUsers.ccedumngr);
		secondManagerEducation = getUser(GenerateEnvironmentTestUsers.ccedu2ndmngr);
		reviewManagerEducation = getUser(GenerateEnvironmentTestUsers.ccrevedumngr);
		review2ndManagerEducation = getUser(GenerateEnvironmentTestUsers.ccrevedu2ndmngr);
		consultingEmployee = getUser(GenerateEnvironmentTestUsers.ccconsempl);
	}
	
	public static User getUser(String oname){
		for (User u : userList){
			if (u.username.equals(oname)){
				return u;
			}
		}
		return null;
	}
	
	public static PerformanceReview__c createPerformanceReview(String pname, Id prp,Id v2, Id cgrp, Id rftpl,
															  Id empl, Id mngr, Id sndMngr, Id pcomm, Id dpt, String status){
															
		PerformanceReview__c pr = new PerformanceReview__c(Name = pname,
														   PerformanceReviewPeriod__c = prp,
														   V2MOM__c = v2,
														   CompetencyGroup__c = cgrp,
														   ReviewFormTemplate__c = rftpl,
														   Employee__c = empl,
														   Manager__c = mngr,
														   SecondManager__c = sndMngr,
														   PCOMM__c = pcomm,
														   Cost_Center__c = dpt,
														   Status__c = status);
														   //Department__c = dpt,
																		
		upsert(pr);
		
		return pr;
	}
	
	public static PerformanceReview__c createPerformanceReview2(String pname, Id prp,Id v2, Id cgrp, Id rftpl,
															  Id empl, Id mngr, Id sndMngr, Id pcomm, Id dpt, String status, String prevStatus){
															
		PerformanceReview__c pr = new PerformanceReview__c(Name = pname,
														   PerformanceReviewPeriod__c = prp,
														   V2MOM__c = v2,
														   CompetencyGroup__c = cgrp,
														   ReviewFormTemplate__c = rftpl,
														   Employee__c = empl,
														   Manager__c = mngr,
														   SecondManager__c = sndMngr,
														   PCOMM__c = pcomm,
														   Cost_Center__c = dpt,
														   Status__c = status,
														   PreviousStatus__c = prevStatus);
														   //Department__c = dpt,
																		
		upsert(pr);
		
		return pr;
	}
	
	public static PerformanceReview__c changeStatusPReview(PerformanceReview__c pr,
                                                                String previousStatus,
                                                                String newStatus){
        pr.Status__c = newStatus;
        pr.PreviousStatus__c = previousStatus;
       
        upsert(pr);
       
        return pr;
    }
        
    public static ScorecardSupportComment__c createScorecardSupportReviewComment(Id pr,	Id reviewer, String CS,
																		String renewals, String WMCases, String WMSMES, 
																		String WMHC, String WMPA, String supportInitiatives,
																		String salesImpact, String timeOnPlatform, String forecastAccuracy){
																			
		ScorecardSupportComment__c s = new ScorecardSupportComment__c (Reviewer__c = reviewer,
													                PerformanceReview__c = pr,
													                CommentWMSMES__c = WMSMES,
													                CommentWMPA__c = WMPA,
													                CommentWMHC__c = WMHC,
													                CommentWMCases__c = WMCases,
													                CommentTimeOnPlatform__c = timeOnPlatform,
													                CommentSupportInitiatives__c = supportInitiatives,
													                CommentSalesImpact__c = salesImpact,
													                CommentRenewals__c = renewals,
													                CommentForecastAccuracy__c = forecastAccuracy,
													                CommentCS__c = CS);
		
		allSSComms.add(s);
		
		return s;		
	}
	
		
	public static ScorecardSupportReview__c createScorecardSupportReviewEmpty(String pname, 
																		Id pr,
																		Id reviewer,
																		String fq){
		ScorecardSupportReview__c s = new ScorecardSupportReview__c (Name = pname,
																	PerformanceReview__c = pr,
																	Reviewer__c = reviewer,
																	FiscalQuarter__c = fq);
		
		allScorecards.add(s);
		
		return s;
	}
	
	public static void genReviewRating () {
		try {
			getUsers();
			getUser('None');
			
			// create other necessary elements and performance reviews
			genPerformanceReviewsWithPrevStatus();
			
			// create v2moms
			v2momIndividual = createV2MOM(employeeStandard.Id, 'vision individual', 'Individual', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
					
			v2momIndividualQ1Q2Sup = createV2MOM(employeeSupport.Id, 'vision individual Sup Q1Q2', 'Individual Q1/Q2', 'Test V2MOM Individual Q1Q2', 'FY08', 'My Management Hierarchy');
			v2momIndividualQ3Q4Sup = createV2MOM(employeeSupport.Id, 'vision individual Sup Q3Q4', 'Individual Q3/Q4', 'Test V2MOM Individual Q3Q4', 'FY08', 'My Management Hierarchy');
					
			v2momIndividualQ1Q2Edu = createV2MOM(employeeEducation.Id, 'vision individual Edu Q1Q2', 'Individual Q1/Q2', 'Test V2MOM Individual Q1Q2', 'FY08', 'My Management Hierarchy');
			v2momIndividualQ3Q4Edu = createV2MOM(employeeEducation.Id, 'vision individual Edu Q3Q4', 'Individual Q3/Q4', 'Test V2MOM Individual Q3Q4', 'FY08', 'My Management Hierarchy');
			
			// create individuals performance reviews
			PRQ1Q2 = createPerformanceReview('Test PReviewQ1Q2', PRPIndividualQ1Q2.Id, v2momIndividualQ1Q2Sup.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 employeeSupport.Id, reviewManagerSupport.Id, review2ndManagerSupport.Id, pcommStandard.Id, department.Id, 'Created');
			
			PRQ3Q4 = createPerformanceReview('Test PReviewQ3Q4', PRPIndividualQ3Q4.Id, v2momIndividualQ3Q4Sup.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 employeeSupport.Id, reviewManagerSupport.Id, review2ndManagerSupport.Id, pcommStandard.Id, department.Id, 'Created');
			
			
			reviewRating = createOverallRating('overall rating Mngr stnd', PRMngrAssmnt.Id, 2.0, 3.2, reviewManagerStandard.Id);
			reviewRatingQ1Q2Edu = createOverallRating('overall rating Mngr edu q1q2', PRQ1Q2.Id, 3.0, 1.3, reviewManagerEducation.Id);
			reviewRatingQ3Q4Edu = createOverallRating('overall rating Mngr edu q3q4', PRQ3Q4.Id, null, null, reviewManagerEducation.Id);
			
			upsert(allOverallRatings);
		
		} catch (Exception e) {
            System.debug(' ****************** genReviewRating Error * ');
            System.debug(e.getMessage());
		}
	}
	
	public static void genAllObjects(){
		try {
			getUsers();
			getUser('None');
			
			// create other necessary elements and performance reviews
			genPerformanceReviewsWithPrevStatus();
			
			// create v2moms
			v2momIndividual = createV2MOM(employeeStandard.Id, 'vision individual', 'Individual', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
					
			v2momIndividualQ1Q2Sup = createV2MOM(employeeSupport.Id, 'vision individual Sup Q1Q2', 'Individual Q1/Q2', 'Test V2MOM Individual Q1Q2', 'FY08', 'My Management Hierarchy');
			v2momIndividualQ3Q4Sup = createV2MOM(employeeSupport.Id, 'vision individual Sup Q3Q4', 'Individual Q3/Q4', 'Test V2MOM Individual Q3Q4', 'FY08', 'My Management Hierarchy');
					 
			v2momIndividualQ1Q2Edu = createV2MOM(employeeEducation.Id, 'vision individual Edu Q1Q2', 'Individual Q1/Q2', 'Test V2MOM Individual Q1Q2', 'FY08', 'My Management Hierarchy');
			v2momIndividualQ3Q4Edu = createV2MOM(employeeEducation.Id, 'vision individual Edu Q3Q4', 'Individual Q3/Q4', 'Test V2MOM Individual Q3Q4', 'FY08', 'My Management Hierarchy');
			
			// create individuals performance reviews
			PRQ1Q2 = createPerformanceReview('Test PReviewQ1Q2', PRPIndividualQ1Q2.Id, v2momIndividualQ1Q2Sup.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 employeeSupport.Id, reviewManagerSupport.Id, review2ndManagerSupport.Id, pcommStandard.Id, department.Id, 'Created');
			
			PRQ3Q4 = createPerformanceReview('Test PReviewQ3Q4', PRPIndividualQ3Q4.Id, v2momIndividualQ3Q4Sup.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 employeeSupport.Id, reviewManagerSupport.Id, review2ndManagerSupport.Id, pcommStandard.Id, department.Id, 'Created');
			
			
			// create the methods for each v2mom		
			method1 = createMethod(v2momIndividual.Id, null, 1, 'Method 1', 'Description method 1');
			method2 = createMethod(v2momIndividual.Id, null, 2, 'Method 2', 'Description method 2');
			
			methodQ1Q2Sup1 = createMethod(v2momIndividualQ1Q2Sup.Id, null, 1, 'Method 1', 'Description method 1');
			methodQ1Q2Sup2 = createMethod(v2momIndividualQ1Q2Sup.Id, null, 2, 'Method 2', 'Description method 2');
			
			methodQ3Q4Sup3 = createMethod(v2momIndividualQ3Q4Sup.Id, null, 1, 'Method 1', 'Description method 1');
			methodQ3Q4Sup4 = createMethod(v2momIndividualQ3Q4Sup.Id, null, 2, 'Method 2', 'Description method 2');
			
			methodQ1Q2Edu1 = createMethod(v2momIndividualQ1Q2Edu.Id, null, 1, 'Method 1', 'Description method 1');
			methodQ1Q2Edu2 = createMethod(v2momIndividualQ1Q2Edu.Id, null, 2, 'Method 2', 'Description method 2');
			
			methodQ3Q4Edu3 = createMethod(v2momIndividualQ3Q4Edu.Id, null, 1, 'Method 1', 'Description method 1');
			methodQ3Q4Edu4 = createMethod(v2momIndividualQ3Q4Edu.Id, null, 2, 'Method 2', 'Description method 2');
			
			upsert(allmethods);
			
			// create the competencies for step 2
			competencyGroup = [select Id from CompetencyGroup__c where Name = 'CCCompGrp' and Code__c='CCCompGrp'];
			competency1 = createCompetency('Test Competency 1', 'New competency test 1');
			competency2 = createCompetency('Test Competency 2', 'New competency test 2');
			competencyGroupMember1 = createCompetencyGroupMember('CCCompGrpMember1', competency1.Id, competencyGroup.Id, 30);
			competencyGroupMember2 = createCompetencyGroupMember('CCCompGrpMember2', competency2.Id, competencyGroup.Id, 70);

			upsert allCompetencyGroupMembers;
			
			// Create the education scorecards
			sq1Edu = createScorecardSupportReviewEmpty('Test Scorecard Edu Q1', PRQ1Q2.Id, reviewManagerEducation.Id, 'Q1');
			sq2Edu = createScorecardSupportReviewEmpty('Test Scorecard Edu Q2', PRQ1Q2.Id, reviewManagerEducation.Id, 'Q2');
			sq3Edu = createScorecardSupportReviewEmpty('Test Scorecard Edu Q3', PRQ3Q4.Id, reviewManagerEducation.Id, 'Q3');
			sq4Edu = createScorecardSupportReviewEmpty('Test Scorecard Edu Q4', PRQ3Q4.Id, reviewManagerEducation.Id, 'Q4');
			
			upsert(allScorecards);
			
			Date d1 = System.today();
			Date d2 = d1.addYears(1);
			// Create the performance review periods for different V2MOMs types		
			PRPIndividual = createPRP('Test PRP Department', 'FY08', 'Individual', d1, d2);
			PRPIndividualQ1Q2 = createPRP('Test PRP Individual Q1/Q2', 'FY08', 'Individual Q1/Q2', d1, d2);
			PRPIndividualQ3Q4 = createPRP('Test PRP Individual Q3/Q4', 'FY08', 'Individual Q3/Q4', d1, d2);
			
			// Create the method reviews
			method1revEmpl = createMethodReview('Method Review employee std method1', PRMngrAssmnt.Id, null, null,
												'In Progress', employeeStandard.Id, method1.Id,
												'comment method 1 employee standard');
			
			method1revMngr = createMethodReview('Method Review manager std method1', PRMngrAssmnt.Id, 2.0, 35,
												null, reviewManagerStandard.Id, method1.Id,
												'comment method 1 manager standard');
			
			method1rev2ndMngr = createMethodReview('Method Review 2nd manager stnd method1', PRMngrAssmnt.Id, null, null,
												null, review2ndManagerStandard.Id, method1.Id,
												'comment method 1 2nd manager standard');
					
			method2revEmpl = createMethodReview('Method Review employee std method2', PRMngrAssmnt.Id, null, null,
												'Completed', employeeStandard.Id, method2.Id,
												'comment method 2 employee standard');
			
			method2revMngr = createMethodReview('Method Review manager std method2', PRMngrAssmnt.Id, 3.0, 65,
												null, reviewManagerStandard.Id, method2.Id,
												'comment method 2 manager standard');
			
			method2rev2ndMngr = createMethodReview('Method Review 2nd manager stnd method2', PRMngrAssmnt.Id, null, null,
												null, review2ndManagerStandard.Id, method2.Id,
												'comment method 2 2nd manager standard');			
			
			methodQ1Q2Edu1revEmpl = createMethodReview('Method Review employee sup methodQ1Q2Edu1', PRQ1Q2.Id, null, null,
												'N/A', employeeEducation.Id, methodQ1Q2Edu1.Id,
												'comment methodQ1Q2Edu1 employee education');
			
			methodQ1Q2Edu1revMngr = createMethodReview('Method Review manager sup methodQ1Q2Edu1', PRQ1Q2.Id, 1.0, 30,
												null, reviewManagerEducation.Id, methodQ1Q2Edu1.Id,
												'comment methodQ1Q2Edu1 manager education');
			
			methodQ1Q2Edu1rev2ndMngr = createMethodReview('Method Review 2nd manager sup methodQ1Q2Edu1', PRQ1Q2.Id, null, null,
												null, review2ndManagerEducation.Id, methodQ1Q2Edu1.Id,
												'comment methodQ1Q2Edu1 2nd manager education');
			
			methodQ1Q2Edu2revEmpl = createMethodReview('Method Review employee sup methodQ1Q2Edu2', PRQ1Q2.Id, null, null,
												'In Progress', employeeEducation.Id, methodQ1Q2Edu2.Id,
												'comment methodQ1Q2Edu2 employee education');
			
			methodQ1Q2Edu2revMngr = createMethodReview('Method Review manager sup methodQ1Q2Edu2', PRQ1Q2.Id, 4.0, 70,
												null, reviewManagerEducation.Id, methodQ1Q2Edu2.Id,
												'comment method 2 manager education');
			
			methodQ1Q2Edu2rev2ndMngr = createMethodReview('Method Review 2nd manager sup methodQ1Q2Edu2', PRQ1Q2.Id, null, null,
												null, review2ndManagerEducation.Id, methodQ1Q2Edu2.Id,
												'comment methodQ1Q2Edu2 2nd manager education');
			
			methodQ3Q4Edu3revEmpl = createMethodReview('Method Review employee sup methodQ3Q4Edu3', PRQ3Q4.Id, null, null,
												'N/A', employeeEducation.Id, methodQ3Q4Edu3.Id,
												'comment methodQ3Q4Edu3 employee education');
			
			methodQ3Q4Edu3revMngr = createMethodReview('Method Review manager sup methodQ3Q4Edu3', PRQ3Q4.Id, 5.0, 10,
												null, reviewManagerEducation.Id, methodQ3Q4Edu3.Id,
												'comment methodQ3Q4Edu3 manager education');
			
			methodQ3Q4Edu3rev2ndMngr = createMethodReview('Method Review 2nd manager sup methodQ3Q4Edu3', PRQ3Q4.Id, null, null,
												null, review2ndManagerEducation.Id, methodQ3Q4Edu3.Id,
												'comment methodQ3Q4Edu3 2nd manager education');
			
			methodQ3Q4Edu4revEmpl = createMethodReview('Method Review employee sup methodQ3Q4Edu4', PRQ3Q4.Id, null, null,
												'In Progress', employeeEducation.Id, methodQ3Q4Edu4.Id,
												'comment methodQ3Q4Edu4 employee education');
			
			methodQ3Q4Edu4revMngr = createMethodReview('Method Review manager sup methodQ3Q4Edu4', PRQ3Q4.Id, 2.0, 90,
												null, reviewManagerEducation.Id, methodQ3Q4Edu4.Id,
												'comment methodQ3Q4Edu4 manager education');
			
			methodQ3Q4Edu4rev2ndMngr = createMethodReview('Method Review 2nd manager sup methodQ3Q4Edu4', PRQ3Q4.Id, null, null,
												null, review2ndManagerEducation.Id, methodQ3Q4Edu4.Id,
												'comment methodQ3Q4Edu4 2nd manager education');
			
			upsert(allMethodReviews);
	
			
			// Create the competency reviews
			competency1revEmpl = createCompetencyReview('Competency Review employee std competency1', PRMngrAssmnt.Id, null,
												employeeStandard.Id, competencyGroupMember1.Id,
												'comment competency 1 employee standard');
			
			competency1revMngr = createCompetencyReview('Competency Review manager std competency1', PRMngrAssmnt.Id, 2.0,
												reviewManagerStandard.Id, competencyGroupMember1.Id,
												'comment competency 1 manager standard');
			
			competency1rev2ndMngr = createCompetencyReview('Competency Review 2nd manager stnd competency1', PRMngrAssmnt.Id, null,
												review2ndManagerStandard.Id, competencyGroupMember1.Id,
												'comment competency 1 2nd manager standard');
					
			competency2revEmpl = createCompetencyReview('Competency Review employee std competency2', PRMngrAssmnt.Id, null,
												employeeStandard.Id, competencyGroupMember2.Id,
												'comment competency 2 employee standard');
			
			competency2revMngr = createCompetencyReview('Competency Review manager std competency2', PRMngrAssmnt.Id, 3.0,
												reviewManagerStandard.Id, competencyGroupMember2.Id,
												'comment competency 2 manager standard');
			
			competency2rev2ndMngr = createCompetencyReview('Competency Review 2nd manager stnd competency2', PRMngrAssmnt.Id, null,
												review2ndManagerStandard.Id, competencyGroupMember2.Id,
												'comment competency 2 2nd manager standard');			
			
			competencyQ1Q2Edu1revEmpl = createCompetencyReview('Competency Review employee sup competencyQ1Q2Edu1', PRQ1Q2.Id, null,
												employeeEducation.Id, competencyGroupMember1.Id,
												'comment competencyQ1Q2Edu1 employee education');
			
			competencyQ1Q2Edu1revMngr = createCompetencyReview('Competency Review manager sup competencyQ1Q2Edu1', PRQ1Q2.Id, 1.0,
												reviewManagerEducation.Id, competencyGroupMember1.Id,
												'comment competencyQ1Q2Edu1 manager education');
			
			competencyQ1Q2Edu1rev2ndMngr = createCompetencyReview('Competency Review 2nd manager sup competencyQ1Q2Edu1', PRQ1Q2.Id, null,
												review2ndManagerEducation.Id, competencyGroupMember1.Id,
												'comment competencyQ1Q2Edu1 2nd manager education');
			
			competencyQ1Q2Edu2revEmpl = createCompetencyReview('Competency Review employee sup competencyQ1Q2Edu2', PRQ1Q2.Id, null,
												employeeEducation.Id, competencyGroupMember2.Id,
												'comment competencyQ1Q2Edu2 employee education');
			
			competencyQ1Q2Edu2revMngr = createCompetencyReview('Competency Review manager sup competencyQ1Q2Edu2', PRQ1Q2.Id, 4.0,
												reviewManagerEducation.Id, competencyGroupMember2.Id,
												'comment competency 2 manager education');
			
			competencyQ1Q2Edu2rev2ndMngr = createCompetencyReview('Competency Review 2nd manager sup competencyQ1Q2Edu2', PRQ1Q2.Id, null,
												review2ndManagerEducation.Id, competencyGroupMember2.Id,
												'comment competencyQ1Q2Edu2 2nd manager education');
			
			competencyQ3Q4Edu3revEmpl = createCompetencyReview('Competency Review employee sup competencyQ3Q4Edu3', PRQ3Q4.Id, null,
												employeeEducation.Id, competencyGroupMember1.Id,
												'comment competencyQ3Q4Edu3 employee education');
			
			competencyQ3Q4Edu3revMngr = createCompetencyReview('Competency Review manager sup competencyQ3Q4Edu3', PRQ3Q4.Id, 5.0,
												reviewManagerEducation.Id, competencyGroupMember1.Id,
												'comment competencyQ3Q4Edu3 manager education');
			
			competencyQ3Q4Edu3rev2ndMngr = createCompetencyReview('Competency Review 2nd manager sup competencyQ3Q4Edu3', PRQ3Q4.Id, null,
												review2ndManagerEducation.Id, competencyGroupMember1.Id,
												'comment competencyQ3Q4Edu3 2nd manager education');
			
			competencyQ3Q4Edu4revEmpl = createCompetencyReview('Competency Review employee sup competencyQ3Q4Edu4', PRQ3Q4.Id, null,
												employeeEducation.Id, competencyGroupMember2.Id,
												'comment competencyQ3Q4Edu4 employee education');
			
			competencyQ3Q4Edu4revMngr = createCompetencyReview('Competency Review manager sup competencyQ3Q4Edu4', PRQ3Q4.Id, 2.0,
												reviewManagerEducation.Id, competencyGroupMember2.Id,
												'comment competencyQ3Q4Edu4 manager education');
			
			competencyQ3Q4Edu4rev2ndMngr = createCompetencyReview('Competency Review 2nd manager sup competencyQ3Q4Edu4', PRQ3Q4.Id, null,
												review2ndManagerEducation.Id, competencyGroupMember2.Id,
												'comment competencyQ3Q4Edu4 2nd manager education');
			
			upsert(allCompetencyReviews);
			
			overallrevEmpl = createOverallReview('overall review Empl stnd', PRMngrAssmnt.Id, '', '', '', '', 
													employeeStandard.Id, 'comment Empl stnd overall');
			
			overallrevMngr = createOverallReview('overall review Mngr stnd', PRMngrAssmnt.Id, '', '', '', '', 
													reviewManagerStandard.Id, 'comment Mngr stnd overall');
			
			overallrev2ndMngr = createOverallReview('overall review 2nd Mngr stnd', PRMngrAssmnt.Id, '', '', '', '', 
													review2ndManagerStandard.Id, 'comment 2nd Mngr stnd overall');
					
			overallQ1Q2EdurevEmpl = createOverallReview('overall review Empl edu', PRQ1Q2.Id, '', '', '', '', 
													employeeEducation.Id, 'comment Empl edu overall');
			
			overallQ1Q2EdurevMngr = createOverallReview('overall review Mngr edu', PRQ1Q2.Id, '', '', '', '', 
													reviewManagerEducation.Id, 'comment Mngr edu overall');
			
			overallQ1Q2Edurev2ndMngr = createOverallReview('overall review 2nd Mngr edu', PRQ1Q2.Id, '', '', '', '', 
													review2ndManagerEducation.Id, 'comment 2nd Mngr edu overall');
					
			overallQ3Q4EdurevEmpl = createOverallReview('overall review Empl edu', PRQ3Q4.Id, '', '', '', '', 
													employeeEducation.Id, 'comment Empl edu overall');
			
			overallQ3Q4EdurevMngr = createOverallReview('overall review Mngr edu', PRQ3Q4.Id, '', '', '', '', 
													reviewManagerEducation.Id, 'comment Mngr edu overall');
			
			overallQ3Q4Edurev2ndMngr = createOverallReview('overall review 2nd Mngr edu', PRQ3Q4.Id, '', '', '', '', 
													review2ndManagerEducation.Id, 'comment 2nd Mngr edu overall');
			
			upsert(allOverallReviews);
	
			reviewRating = createOverallRating('overall rating Mngr stnd', PRMngrAssmnt.Id, 2.0, 3.2, reviewManagerStandard.Id);
			reviewRatingQ1Q2Edu = createOverallRating('overall rating Mngr edu q1q2', PRQ1Q2.Id, 3.0, 1.3, reviewManagerEducation.Id);
			reviewRatingQ3Q4Edu = createOverallRating('overall rating Mngr edu q3q4', PRQ3Q4.Id, 4.0, 0.5, reviewManagerEducation.Id);
			
			upsert(allOverallRatings);
	
			sscommQ1Q2EdurevEmpl = createScorecardSupportReviewComment(PRQ1Q2.Id,
																		employeeEducation.Id, 
																		'CS comm Q1Q2 employee sup',
																		'renewals comm Q1Q2 employee sup',
																		'WMCases comm Q1Q2 employee sup',
																		'WMSMES comm Q1Q2 employee sup', 
																		'WMHC comm Q1Q2 employee sup',
																		'WMPA comm Q1Q2 employee sup',
																		'supportInitiatives comm Q1Q2 employee sup',
																		'salesImpact comm Q1Q2 employee sup',
																		'timeOnPlatform comm Q1Q2 employee sup',
																		'forecastAccuracy comm Q1Q2 employee sup');
			
			sscommQ1Q2EdurevMngr = createScorecardSupportReviewComment(PRQ1Q2.Id,
																		reviewManagerEducation.Id, 
																		'CS comm Q1Q2 manager sup',
																		'renewals comm Q1Q2 manager sup',
																		'WMCases comm Q1Q2 manager sup',
																		'WMSMES comm Q1Q2 manager sup', 
																		'WMHC comm Q1Q2 manager sup',
																		'WMPA comm Q1Q2 manager sup',
																		'supportInitiatives comm Q1Q2 manager sup',
																		'salesImpact comm Q1Q2 manager sup',
																		'timeOnPlatform comm Q1Q2 manager sup',
																		'forecastAccuracy comm Q1Q2 manager sup');
			
			sscommQ1Q2Edurev2ndMngr = createScorecardSupportReviewComment(PRQ1Q2.Id,
																		review2ndManagerEducation.Id, 
																		'CS comm Q1Q2 secondManager sup',
																		'renewals comm Q1Q2 secondManager sup',
																		'WMCases comm Q1Q2 secondManager sup',
																		'WMSMES comm Q1Q2 secondManager sup', 
																		'WMHC comm Q1Q2 secondManager sup',
																		'WMPA comm Q1Q2 secondManager sup',
																		'supportInitiatives comm Q1Q2 secondManager sup',
																		'salesImpact comm Q1Q2 secondManager sup',
																		'timeOnPlatform comm Q1Q2 secondManager sup',
																		'forecastAccuracy comm Q1Q2 secondManager sup');
					
			sscommQ3Q4EdurevEmpl = createScorecardSupportReviewComment(PRQ3Q4.Id,
																		employeeEducation.Id, 
																		'CS comm Q3Q4 employee sup',
																		'renewals comm Q3Q4 employee sup',
																		'WMCases comm Q3Q4 employee sup',
																		'WMSMES comm Q3Q4 employee sup', 
																		'WMHC comm Q3Q4 employee sup',
																		'WMPA comm Q3Q4 employee sup',
																		'supportInitiatives comm Q3Q4 employee sup',
																		'salesImpact comm Q3Q4 employee sup',
																		'timeOnPlatform comm Q3Q4 employee sup',
																		'forecastAccuracy comm Q3Q4 employee sup');
			
			sscommQ3Q4EdurevMngr = createScorecardSupportReviewComment(PRQ3Q4.Id,
																		reviewManagerEducation.Id, 
																		'CS comm Q3Q4 manager sup',
																		'renewals comm Q3Q4 manager sup',
																		'WMCases comm Q3Q4 manager sup',
																		'WMSMES comm Q3Q4 manager sup', 
																		'WMHC comm Q3Q4 manager sup',
																		'WMPA comm Q3Q4 manager sup',
																		'supportInitiatives comm Q3Q4 manager sup',
																		'salesImpact comm Q3Q4 manager sup',
																		'timeOnPlatform comm Q3Q4 manager sup',
																		'forecastAccuracy comm Q3Q4 manager sup');
			
			sscommQ3Q4Edurev2ndMngr = createScorecardSupportReviewComment(PRQ3Q4.Id,
																		review2ndManagerEducation.Id, 
																		'CS comm Q3Q4 secondManager sup',
																		'renewals comm Q3Q4 secondManager sup',
																		'WMCases comm Q3Q4 secondManager sup',
																		'WMSMES comm Q3Q4 secondManager sup', 
																		'WMHC comm Q3Q4 secondManager sup',
																		'WMPA comm Q3Q4 secondManager sup',
																		'supportInitiatives comm Q3Q4 secondManager sup',
																		'salesImpact comm Q3Q4 secondManager sup',
																		'timeOnPlatform comm Q3Q4 secondManager sup',
																		'forecastAccuracy comm Q3Q4 secondManager sup');
	
			upsert(allSSComms);
		} catch (Exception e) {
            System.debug(' ****************** genAllObjects Error * ');
            System.debug(e.getMessage());
		}
	}

	
	public static V2MOM__c createV2MOM(Id user, String vision, String t, String name, 
										String effDate, String share){
		V2MOM__c v = new V2MOM__c (	OwnerId=user,
										Vision__c = vision, 
										V2MOM_Type__c = t,
										Name = name, 
										Effective_Date__c = effDate,
										Share_With__c = share);
		//allv2moms.add(v);
		upsert(v);
		
		return v;
	}

	
	public static Method__c createMethod(Id v2momId, Id valueId, Integer p, String name, String d){
		Method__c methodResult = new Method__c(V2MOM__c = v2momId, 
										Value__c = valueId,
										Priority__c = p, 
										Name = name,
										Description__c = d);
		
		allMethods.add(methodResult);
		
		return methodResult;
	}	
	
	public static CompetencyGroupMember__c createCompetencyGroupMember(String name, Id comp, Id cg, Integer w){
			CompetencyGroupMember__c c = new CompetencyGroupMember__c(Name = name,
																	CompetencyGroup__c = cg,
																	Competency__c = comp,
																	Weight__c = w);
			
			allCompetencyGroupMembers.add(c);
			//upsert c;
			return c;
	}	
	
	
	public static MethodReview__c createMethodReview(String oname, Id pr, double rating, Integer weight,
													String status, Id reviewer, Id methodId, String comment){
		
		MethodReview__c methodReview = new MethodReview__c(	Weight__c = weight, 
															Status__c = status, 
															Reviewer__c = reviewer, 
															Rating__c = rating, 
															PerformanceReview__c = pr, 
															Method__c = methodId, 
															Comment__c = comment);
		
		allMethodReviews.add(methodReview);
		
		return methodReview;
	}
	
	
	public static CompetencyReview__c createCompetencyReview(String oname, Id pr, double rating, Id reviewer, Id cgm, String comment){
		
		CompetencyReview__c compReview = new CompetencyReview__c(Reviewer__c = reviewer, 
																Rating__c = rating, 
																PerformanceReview__c = pr, 
																CompetencyGroupMember__c = cgm, 
																Comment__c = comment);
		
		allCompetencyReviews.add(compReview);
		
		return compReview;
	}
	
	public static AdditionalComment__c createOverallReview(String oname, Id pr, String updtMeth, String suggComp, String suggMeth,
															String commComp, Id reviewer, String comment){
		AdditionalComment__c overallReview = new AdditionalComment__c(UpdateMethods__c = updtMeth, 
																	SuggestionsCompetencies__c = suggComp, 
																	SuggestionMethods__c = suggMeth, 
																	Reviewer__c = reviewer, 
																	PerformanceReview__c = pr, 
																	Comment__c = comment, 
																	CommentCompetencies__c = commComp);
		
		allOverallReviews.add(overallReview);
		
		return overallReview;
	}
		
	public static ReviewRating__c createOverallRating(String oname,	Id pr, double orating, double crating, Id reviewer){
		
		ReviewRating__c overallRating = new ReviewRating__c(Reviewer__c = reviewer, 
															PerformanceReview__c = pr, 
															OverallRating__c = orating,
															CalculatedRating__c = crating);
		
		allOverallRatings.add(overallRating);
		
		return overallRating;
	}
	
	public static CompetencyGroup__c createCompetencyGroup()
	{
		CompetencyGroup__c competencyGroupNew = new CompetencyGroup__c(Name = 'CCCompGrp', Code__c = 'CCCompGrp');
		upsert(competencyGroupNew);
		
		return competencyGroupNew;
	}
	
	
	public static ReviewFormTemplate__c createReviewFromTemplate()
	{
		ReviewFormTemplate__c reviewFromTemplate = new ReviewFormTemplate__c(Name = 'CCRevTpl', Code__c = 'CCRevTpl');
		upsert(reviewFromTemplate);
		
		return reviewFromTemplate;
	}
	
	public static testMethod void unitTest1(){
		Test.startTest();
		User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
		System.runAs ( thisUser ) {
			GenerateEnvironmentTest2.genUsers();
			GenerateEnvironmentTest2.genPerformanceReview2();
			GenerateEnvironmentTest2.createCompetency('testCompetency', 'Unit Test');
		}
		Test.stopTest();
	}
	
	    public static User getManager(){
						
			if(managerStandard == null){
				Profile p = [Select Id From Profile where Name =: 'Manager'];
				managerStandard =  new User(	username='test__manager@test.com',
									lastName='testManager',
									email='managertest@mailinator.com',
									alias='mtest',
									timeZoneSidKey='America/Los_Angeles',
									localeSidKey='en_US',
									emailEncodingKey='ISO-8859-1',
									LanguagelocaleKey='en_US',
									ProfileID = p.Id);
				/* Run As Review Employee */
				system.runAs( getSystemAdmin()){
					insert managerStandard;	
				}					
				
			}
			return managerStandard;
		
	}
    
    public static User getEmployeeStandard(){
    	Profile p = [Select Id From Profile where Name =: 'Employee'];
		employeeStandard =  new User(	username = 'testStandardemp@test.com',
										lastName = 'standard',
										email = 'emptest1@mailinator.com',
										alias = 'etest',
										timeZoneSidKey ='America/Los_Angeles',
										manager__c = getManager().Id,
										localeSidKey = 'en_US',
										emailEncodingKey = 'ISO-8859-1',
										LanguagelocaleKey = 'en_US',
										ProfileId = p.Id
									);
		/* Run As Review Manager */
		system.runAs(getManager()){
			insert employeeStandard;
		}
		return employeeStandard;									
    }
    
    public static User getSystemAdmin(){
		Profile p = [Select Id From Profile where Name =: 'System Administrator'];
		User adminUser = [Select id From User Where ProfileID =: p.Id And IsActive =: True limit 1][0];
		return adminUser; 
	}	
}