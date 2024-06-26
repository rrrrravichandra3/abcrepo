public class GenerateEnvironmentTest3 {
	
	/*
	 * ENVIRONMENT TO TEST: Test_MetricEducation
	 * 						Test_V2MOMUtil
	 *						Test_ScorecardSupport
	 *						Test_ScorecardReviewSupportCSController
	 *						Test_V2MOMSharingController
	*/
	
	// Test
	//public static Department__c department;
	public static TF2_Department__c department;
	
	public static CompetencyGroup__c competencyGroup;
	public static CompetencyGroupMember__c competencyGroupMember1;
	public static CompetencyGroupMember__c competencyGroupMember2;
	public static List<CompetencyGroupMember__c> allCompetencyGroupMembers = new List<CompetencyGroupMember__c>();
	public static Competency__c competency1;
	public static Competency__c competency2;
	
	public static User pcommStandard;
	public static User esadminStandard;
	public static User ceoStandard;
	public static User esbpStandard;
	
	public static User manager;
	
	public static User employeeStandard;
	public static User managerStandard;
	public static User secondManagerStandard;
	public static User reviewManagerStandard;
	public static User review2ndManagerStandard;
	
	public static User employeeSupport;
	public static User managerSupport;
	public static User secondManagerSupport;
	public static User reviewManagerSupport;
	public static User review2ndManagerSupport;
	
	public static User employeeEducation;
	public static User managerEducation;
	public static User secondManagerEducation;
	public static User reviewManagerEducation;
	public static User review2ndManagerEducation;
	
	public static User employeeConsulting;
	public static User managerConsulting;
	public static User secondManagerConsulting;
	public static User reviewManagerConsulting;
	public static User review2ndManagerConsulting;
	
	public static User employeeCSM;
	public static User managerCSM;
	public static User secondManagerCSM;
	public static User reviewManagerCSM;
	public static User review2ndManagerCSM;

	
	public static V2MOM__c v2momAdHoc;
	public static V2MOM__c v2momIndividual;
	public static V2MOM__c v2momIndividualQ1Q2Sup;
	public static V2MOM__c v2momIndividualQ3Q4Sup;
	public static V2MOM__c v2momIndividualQ1Q2Edu;
	public static V2MOM__c v2momIndividualQ3Q4Edu;
	
	public static Method__c method1;
	public static Method__c method2;
	
	public static Method__c methodQ1Q2Sup1;
	public static Method__c methodQ1Q2Sup2;
	public static Method__c methodQ3Q4Sup3;
	public static Method__c methodQ3Q4Sup4;

	public static Method__c methodQ1Q2Edu1;
	public static Method__c methodQ1Q2Edu2;
	public static Method__c methodQ3Q4Edu3;
	public static Method__c methodQ3Q4Edu4;

	public static List<Method__c> allMethods = new List<Method__c>();
	

	public static boolean emptyMethodReviewRating = false;
	public static boolean emptyMethodReviewComment = false;

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

	public static boolean emptyCompReviewRating = false;
	public static boolean emptyCompReviewComment = false;
	
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

	public static boolean emptyOverallReview = false;
	
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


	public static boolean emptyOverallRating = false;

	public static ReviewRating__c reviewRating;
	public static ReviewRating__c reviewRatingQ1Q2Sup;
	public static ReviewRating__c reviewRatingQ3Q4Sup;
	public static ReviewRating__c reviewRatingQ1Q2Edu;
	public static ReviewRating__c reviewRatingQ3Q4Edu;

	public static List<ReviewRating__c> allOverallRatings = new List<ReviewRating__c>();


	public static boolean emptySSComm = false;
	
	public static ScorecardSupportComment__c sscommQ1Q2SuprevEmpl;
	public static ScorecardSupportComment__c sscommQ1Q2SuprevMngr;
	public static ScorecardSupportComment__c sscommQ1Q2Suprev2ndMngr;
	public static ScorecardSupportComment__c sscommQ1Q2Suprev3rdParty;
	
	public static ScorecardSupportComment__c sscommQ3Q4SuprevEmpl;
	public static ScorecardSupportComment__c sscommQ3Q4SuprevMngr;
	public static ScorecardSupportComment__c sscommQ3Q4Suprev2ndMngr;
	public static ScorecardSupportComment__c sscommQ3Q4Suprev3rdParty;
	
	public static ScorecardSupportComment__c sscommQ1Q2EdurevEmpl;
	public static ScorecardSupportComment__c sscommQ1Q2EdurevMngr;
	public static ScorecardSupportComment__c sscommQ1Q2Edurev2ndMngr;
	
	public static ScorecardSupportComment__c sscommQ3Q4EdurevEmpl;
	public static ScorecardSupportComment__c sscommQ3Q4EdurevMngr;
	public static ScorecardSupportComment__c sscommQ3Q4Edurev2ndMngr;
	
	public static List<ScorecardSupportComment__c> allSSComms = new List<ScorecardSupportComment__c>();
	

	public static ReviewFormTemplate__c reviewFormTemplate;
	
	public static PerformanceReviewPeriod__c PRPIndividual;
	public static PerformanceReviewPeriod__c PRPIndividualQ1Q2;
	public static PerformanceReviewPeriod__c PRPIndividualQ3Q4;

	public static List<PerformanceReviewPeriod__c> allPRPs = new List<PerformanceReviewPeriod__c>();
	
	public static PerformanceReview__c PRIndividual;
	public static PerformanceReview__c PRIndividualQ1Q2Edu;
	public static PerformanceReview__c PRIndividualQ3Q4Edu;
	public static PerformanceReview__c PRIndividualQ1Q2Sup;
	public static PerformanceReview__c PRIndividualQ3Q4Sup;

	public static List<PerformanceReview__c> allPRs = new List<PerformanceReview__c>();

	public static boolean createScorecards = true;
	public static boolean createScorecardsWithData = false;
	public static boolean createScorecardsWithDataZero = false;

	public static ScorecardSupportReview__c sQ1Sup;
	public static ScorecardSupportReview__c sQ2Sup;
	public static ScorecardSupportReview__c sQ3Sup;
	public static ScorecardSupportReview__c sQ4Sup;

	public static ScorecardSupportReview__c sQ1Edu;
	public static ScorecardSupportReview__c sQ2Edu;
	public static ScorecardSupportReview__c sQ3Edu;
	public static ScorecardSupportReview__c sQ4Edu;
	public static PerformanceAccessUtil accessUtil;
	
	public static List<ScorecardSupportReview__c> allScorecards = new List<ScorecardSupportReview__c>();

	
	public static List<Profile> profList;
	public static List<User> userList;
	
		
	public static void setEnvironmentVars(boolean mrrat, boolean mrcomm, boolean crrat, 
												boolean crcomm, boolean orev, 
												boolean orat, boolean sscomm){
		emptyMethodReviewRating = mrrat;
		emptyMethodReviewComment = mrcomm;

		emptyCompReviewRating = crrat;
		emptyCompReviewComment = crcomm;
		
		emptyOverallReview = orev;
		emptyOverallRating = orat;
		
		emptySSComm = sscomm;
	}
	
	public static void setCreateEmptyScorecardComments(){
		emptySSComm = true;
	}
	
	public static void setNotCreateScorecards(){
		createScorecards = false;
	}

	public static void setCreateScorecardsWithData(){
		createScorecardsWithData = true;
	}

	public static void setCreateScorecardsWithDataZero(){
		createScorecardsWithDataZero = true;
	}

	public static void genV2MOMUtil(){
		try {
			getUsers();
			getUser('None');
			
			v2momIndividualQ1Q2Edu = createV2MOM(employeeEducation.Id, 'vision individual Edu Q1Q2', 'Individual Q1/Q2', 'Test V2MOM Individual Q1Q2', 'FY08', 'My Management Hierarchy');
			
			methodQ1Q2Edu1 = createMethod(v2momIndividualQ1Q2Edu.Id, null, 1, 'Method 1', 'Description method 1');
			
			upsert(allmethods);
			
			//competencyGroup = [select Id from CompetencyGroup__c where Name = 'CCCompGrp' and Code__c='CCCompGrp'];
			competencyGroup = createCompetencyGroup();
			competency1 = createCompetency('Test Competency 1', 'New competency test 1');
			upsert(allCompetencyGroupMembers);
			
			//reviewFormTemplate = [select Id from ReviewFormTemplate__c where Name = 'CCRevTpl' and Code__c='CCRevTpl'];
			reviewFormTemplate = createReviewFromTemplate();
			
			department = createDepartment('Test Department', false);
			
			Date d1 = System.today();
			Date d2 = d1.addYears(1);
			
			PRPIndividualQ1Q2 = createPRP('Test PRP Individual Q1/Q2', 'FY08', 'Individual Q1/Q2', d1, d2);
			
			upsert(allPRPs);
			
			System.debug('Go asign 1');
			PRIndividualQ1Q2Edu = createPerformanceReview('Test PReview Edu IndividualQ1Q2', PRPIndividualQ1Q2.Id, 
											 v2momIndividualQ1Q2Edu.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 employeeEducation.Id, reviewManagerEducation.Id, review2ndManagerEducation.Id,
											 pcommStandard.Id, managerSupport.Id, department.Id, 'Created');
			
			System.debug('Value 1 is ' + PRIndividualQ1Q2Edu );						 
			upsert(allPRs);		
			
			sq1Edu = createScorecardSupportReviewWithDataEducation('Test Scorecard Edu Q1', PRIndividualQ1Q2Edu.Id, reviewManagerEducation.Id, 'Q1',
																	0, 0, 0, 1, 1, 3, 0, 0, 0, 0, 0, 0);	
			upsert(allScorecards);																							 
		} catch (Exception e) {
            System.debug(' ****************** genV2MOMUtil * ');
            System.debug(e.getMessage());
		}
	}

	public static void genV2MOMController(){
		try {
			getUsers();
			getUser('None');
			
			v2momIndividualQ1Q2Edu = createV2MOM(employeeEducation.Id, 'vision individual Edu Q1Q2', 'Individual Q1/Q2', 'Test V2MOM Individual Q1Q2', 'FY08', 'My Management Hierarchy');
			
			methodQ1Q2Edu1 = createMethod(v2momIndividualQ1Q2Edu.Id, null, 1, 'Method 1', 'Description method 1');
			
			upsert(allmethods);
			
			//competencyGroup = [select Id from CompetencyGroup__c where Name = 'CCCompGrp' and Code__c='CCCompGrp'];
			competencyGroup = createCompetencyGroup();
			competency1 = createCompetency('Test Competency 1', 'New competency test 1');
			upsert(allCompetencyGroupMembers);
			
			//reviewFormTemplate = [select Id from ReviewFormTemplate__c where Name = 'CCRevTpl' and Code__c='CCRevTpl'];
			reviewFormTemplate = createReviewFromTemplate();
			department = createDepartment('Test Department', false);
			
			Date d1 = System.today();
			Date d2 = d1.addYears(1);
			
			PRPIndividualQ1Q2 = createPRP('Test PRP Individual Q1/Q2', 'FY08', 'Individual Q1/Q2', d1, d2);
			upsert(allPRPs);
			
			System.debug('Go assign 2');
			PRIndividualQ1Q2Edu = createPerformanceReview('Test PReview Edu IndividualQ1Q2', PRPIndividualQ1Q2.Id, 
											 v2momIndividualQ1Q2Edu.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 employeeEducation.Id, reviewManagerEducation.Id, review2ndManagerEducation.Id,
											 pcommStandard.Id, managerSupport.Id, department.Id, 'Created');
			
			System.debug('Value 2 is ' + PRIndividualQ1Q2Edu );								 
			upsert(allPRs);		
			
			sq1Edu = createScorecardSupportReviewWithDataEducation('Test Scorecard Edu Q1', PRIndividualQ1Q2Edu.Id, reviewManagerEducation.Id, 'Q1',
																	0, 0, 0, 1, 1, 3, 0, 0, 0, 0, 0, 0);	
			upsert(allScorecards);																							 
		} catch (Exception e) {
            System.debug(' ****************** genV2MOMController * ');
            System.debug(e.getMessage());
		}
	}

	public static void genScorecardMetricEducation(){
		try {
			System.debug('Enter Gen');
			
			getUsers();
			
			System.debug('The list ' + userList.size());
			
			System.debug('Pass one');
			
			getUser('None');
			
			System.debug('Pass three');
			
			
			// create v2moms
			v2momIndividual = createV2MOM(employeeStandard.Id, 'vision individual', 'Individual', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
			
			
			
			v2momIndividualQ1Q2Sup = createV2MOM(employeeSupport.Id, 'vision individual Sup Q1Q2', 'Individual Q1/Q2', 'Test V2MOM Individual Q1Q2', 'FY08', 'My Management Hierarchy');
			v2momIndividualQ3Q4Sup = createV2MOM(employeeSupport.Id, 'vision individual Sup Q3Q4', 'Individual Q3/Q4', 'Test V2MOM Individual Q3Q4', 'FY08', 'My Management Hierarchy');
			
		
					
			v2momIndividualQ1Q2Edu = createV2MOM(employeeEducation.Id, 'vision individual Edu Q1Q2', 'Individual Q1/Q2', 'Test V2MOM Individual Q1Q2', 'FY08', 'My Management Hierarchy');
			v2momIndividualQ3Q4Edu = createV2MOM(employeeEducation.Id, 'vision individual Edu Q3Q4', 'Individual Q3/Q4', 'Test V2MOM Individual Q3Q4', 'FY08', 'My Management Hierarchy');
			
			System.debug('PASS Education');
			
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
			
			System.debug('Methods are created');
			
			// create the competencies for step 2
			//competencyGroup = [select Id from CompetencyGroup__c where Name = 'CCCompGrp' and Code__c='CCCompGrp'];
			
			competencyGroup = createCompetencyGroup();
			
			competency1 = createCompetency('Test Competency 1', 'New competency test 1');
			competency2 = createCompetency('Test Competency 2', 'New competency test 2');
			competencyGroupMember1 = createCompetencyGroupMember('CCCompGrpMember1', competency1.Id, competencyGroup.Id, 30);
			competencyGroupMember2 = createCompetencyGroupMember('CCCompGrpMember2', competency2.Id, competencyGroup.Id, 70);
			
			upsert(allCompetencyGroupMembers);
			
			System.debug('Competencies group member are created');
			
			// create other necessary elements
			//reviewFormTemplate = [select Id from ReviewFormTemplate__c where Name = 'CCRevTpl' and Code__c='CCRevTpl'];
			
			reviewFormTemplate = createReviewFromTemplate();
			department = createDepartment('Test Department', false);
			
			
		
			
			Date d1 = System.today();
			Date d2 = d1.addYears(1);
			
			// Create the performance review periods for different V2MOMs types		
			PRPIndividual = createPRP('Test PRP Department', 'FY08', 'Individual', d1, d2);
			PRPIndividualQ1Q2 = createPRP('Test PRP Individual Q1/Q2', 'FY08', 'Individual Q1/Q2', d1, d2);
			PRPIndividualQ3Q4 = createPRP('Test PRP Individual Q3/Q4', 'FY08', 'Individual Q3/Q4', d1, d2);
			
			upsert(allPRPs);
			
			System.debug('CreatePR');
	
			// Create the different performance reviews for each V2MOM type
			PRIndividual = createPerformanceReview('Test PReview Individual', PRPIndividual.Id,
											 v2momIndividual.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 employeeStandard.Id, reviewManagerStandard.Id, review2ndManagerStandard.Id, 
											 pcommStandard.Id, managerSupport.Id, department.Id, 'Created');
	
			System.debug('Go assign 3');
			
			PRIndividualQ1Q2Edu = createPerformanceReview('Test PReview Edu IndividualQ1Q2', PRPIndividualQ1Q2.Id, 
											 v2momIndividualQ1Q2Edu.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 employeeEducation.Id, reviewManagerEducation.Id, review2ndManagerEducation.Id,
											 pcommStandard.Id, managerSupport.Id, department.Id, 'Created');
			
			PRIndividualQ3Q4Edu = createPerformanceReview('Test PReview Edu IndividualQ3Q4', PRPIndividualQ3Q4.Id, 
											 v2momIndividualQ3Q4Edu.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 employeeEducation.Id, reviewManagerEducation.Id, review2ndManagerEducation.Id, 
											 pcommStandard.Id, managerSupport.Id, department.Id, 'Created');
	
			System.debug('Value 3 is ' + PRIndividualQ1Q2Edu );
			
			upsert(allPRs);
			
			if (createScorecards){
				// Create the support scorecards
				
				if (!createScorecardsWithData){
					// Create the education scorecards
					sq1Edu = createScorecardSupportReviewEmpty('Test Scorecard Edu Q1', PRIndividualQ1Q2Edu.Id, reviewManagerEducation.Id, 'Q1');
					sq2Edu = createScorecardSupportReviewEmpty('Test Scorecard Edu Q2', PRIndividualQ1Q2Edu.Id, reviewManagerEducation.Id, 'Q2');
					sq3Edu = createScorecardSupportReviewEmpty('Test Scorecard Edu Q3', PRIndividualQ3Q4Edu.Id, reviewManagerEducation.Id, 'Q3');
					sq4Edu = createScorecardSupportReviewEmpty('Test Scorecard Edu Q4', PRIndividualQ3Q4Edu.Id, reviewManagerEducation.Id, 'Q4');
	
				}else{
						sq1Edu = createScorecardSupportReviewWithDataEducation('Test Scorecard Edu Q1', PRIndividualQ1Q2Edu.Id, reviewManagerEducation.Id, 'Q1',
																	10, 1, 5, 2, 1, 3, 31, 32, 33, 34, 35, 36);
						sq2Edu = createScorecardSupportReviewWithDataEducation('Test Scorecard Edu Q2', PRIndividualQ1Q2Edu.Id, reviewManagerEducation.Id, 'Q2',
																	20, 10, 30, 2, 4, 3, 21, 22, 23, 24, 25, 26);
						sq3Edu = createScorecardSupportReviewWithDataEducation('Test Scorecard Edu Q3', PRIndividualQ3Q4Edu.Id, reviewManagerEducation.Id, 'Q3',
																	20, 10, 30, 2, 1, 5, 21, 22, 23, 24, 25, 26);
						sq4Edu = createScorecardSupportReviewWithDataEducation('Test Scorecard Edu Q4', PRIndividualQ3Q4Edu.Id, reviewManagerEducation.Id, 'Q4',
																	10, 1, 5, 2, 4, 5, 31, 32, 33, 34, 35, 36);
				}
			}
			
			upsert(allScorecards);
			
			// Create the method reviews
			method1revEmpl = createMethodReview('Method Review employee std method1', PRIndividual.Id, null, null,
												'In Progress', employeeStandard.Id, method1.Id,
												'comment method 1 employee standard');
			
			method1revMngr = createMethodReview('Method Review manager std method1', PRIndividual.Id, 2.0, 35,
												null, reviewManagerStandard.Id, method1.Id,
												'comment method 1 manager standard');
			
			method1rev2ndMngr = createMethodReview('Method Review 2nd manager stnd method1', PRIndividual.Id, null, null,
												null, review2ndManagerStandard.Id, method1.Id,
												'comment method 1 2nd manager standard');
					
			method2revEmpl = createMethodReview('Method Review employee std method2', PRIndividual.Id, null, null,
												'Completed', employeeStandard.Id, method2.Id,
												'comment method 2 employee standard');
			
			method2revMngr = createMethodReview('Method Review manager std method2', PRIndividual.Id, 3.0, 65,
												null, reviewManagerStandard.Id, method2.Id,
												'comment method 2 manager standard');
			
			method2rev2ndMngr = createMethodReview('Method Review 2nd manager stnd method2', PRIndividual.Id, null, null,
												null, review2ndManagerStandard.Id, method2.Id,
												'comment method 2 2nd manager standard');			
			
			methodQ1Q2Edu1revEmpl = createMethodReview('Method Review employee sup methodQ1Q2Edu1', PRIndividualQ1Q2Edu.Id, null, null,
												'N/A', employeeEducation.Id, methodQ1Q2Edu1.Id,
												'comment methodQ1Q2Edu1 employee education');
			
			methodQ1Q2Edu1revMngr = createMethodReview('Method Review manager sup methodQ1Q2Edu1', PRIndividualQ1Q2Edu.Id, 1.0, 30,
												null, reviewManagerEducation.Id, methodQ1Q2Edu1.Id,
												'comment methodQ1Q2Edu1 manager education');
			
			methodQ1Q2Edu1rev2ndMngr = createMethodReview('Method Review 2nd manager sup methodQ1Q2Edu1', PRIndividualQ1Q2Edu.Id, null, null,
												null, review2ndManagerEducation.Id, methodQ1Q2Edu1.Id,
												'comment methodQ1Q2Edu1 2nd manager education');
			
			methodQ1Q2Edu2revEmpl = createMethodReview('Method Review employee sup methodQ1Q2Edu2', PRIndividualQ1Q2Edu.Id, null, null,
												'In Progress', employeeEducation.Id, methodQ1Q2Edu2.Id,
												'comment methodQ1Q2Edu2 employee education');
			
			methodQ1Q2Edu2revMngr = createMethodReview('Method Review manager sup methodQ1Q2Edu2', PRIndividualQ1Q2Edu.Id, 4.0, 70,
												null, reviewManagerEducation.Id, methodQ1Q2Edu2.Id,
												'comment method 2 manager education');
			
			methodQ1Q2Edu2rev2ndMngr = createMethodReview('Method Review 2nd manager sup methodQ1Q2Edu2', PRIndividualQ1Q2Edu.Id, null, null,
												null, review2ndManagerEducation.Id, methodQ1Q2Edu2.Id,
												'comment methodQ1Q2Edu2 2nd manager education');
			
			methodQ3Q4Edu3revEmpl = createMethodReview('Method Review employee sup methodQ3Q4Edu3', PRIndividualQ3Q4Edu.Id, null, null,
												'N/A', employeeEducation.Id, methodQ3Q4Edu3.Id,
												'comment methodQ3Q4Edu3 employee education');
			
			methodQ3Q4Edu3revMngr = createMethodReview('Method Review manager sup methodQ3Q4Edu3', PRIndividualQ3Q4Edu.Id, 5.0, 10,
												null, reviewManagerEducation.Id, methodQ3Q4Edu3.Id,
												'comment methodQ3Q4Edu3 manager education');
			
			methodQ3Q4Edu3rev2ndMngr = createMethodReview('Method Review 2nd manager sup methodQ3Q4Edu3', PRIndividualQ3Q4Edu.Id, null, null,
												null, review2ndManagerEducation.Id, methodQ3Q4Edu3.Id,
												'comment methodQ3Q4Edu3 2nd manager education');
			
			methodQ3Q4Edu4revEmpl = createMethodReview('Method Review employee sup methodQ3Q4Edu4', PRIndividualQ3Q4Edu.Id, null, null,
												'In Progress', employeeEducation.Id, methodQ3Q4Edu4.Id,
												'comment methodQ3Q4Edu4 employee education');
			
			methodQ3Q4Edu4revMngr = createMethodReview('Method Review manager sup methodQ3Q4Edu4', PRIndividualQ3Q4Edu.Id, 2.0, 90,
												null, reviewManagerEducation.Id, methodQ3Q4Edu4.Id,
												'comment methodQ3Q4Edu4 manager education');
			
			methodQ3Q4Edu4rev2ndMngr = createMethodReview('Method Review 2nd manager sup methodQ3Q4Edu4', PRIndividualQ3Q4Edu.Id, null, null,
												null, review2ndManagerEducation.Id, methodQ3Q4Edu4.Id,
												'comment methodQ3Q4Edu4 2nd manager education');
			
			upsert(allMethodReviews);
	
			
			// Create the competency reviews
			competency1revEmpl = createCompetencyReview('Competency Review employee std competency1', PRIndividual.Id, null,
												employeeStandard.Id, competencyGroupMember1.Id,
												'comment competency 1 employee standard');
			
			competency1revMngr = createCompetencyReview('Competency Review manager std competency1', PRIndividual.Id, 2.0,
												reviewManagerStandard.Id, competencyGroupMember1.Id,
												'comment competency 1 manager standard');
			
			competency1rev2ndMngr = createCompetencyReview('Competency Review 2nd manager stnd competency1', PRIndividual.Id, null,
												review2ndManagerStandard.Id, competencyGroupMember1.Id,
												'comment competency 1 2nd manager standard');
					
			competency2revEmpl = createCompetencyReview('Competency Review employee std competency2', PRIndividual.Id, null,
												employeeStandard.Id, competencyGroupMember2.Id,
												'comment competency 2 employee standard');
			
			competency2revMngr = createCompetencyReview('Competency Review manager std competency2', PRIndividual.Id, 3.0,
												reviewManagerStandard.Id, competencyGroupMember2.Id,
												'comment competency 2 manager standard');
			
			competency2rev2ndMngr = createCompetencyReview('Competency Review 2nd manager stnd competency2', PRIndividual.Id, null,
												review2ndManagerStandard.Id, competencyGroupMember2.Id,
												'comment competency 2 2nd manager standard');			
			
			competencyQ1Q2Edu1revEmpl = createCompetencyReview('Competency Review employee sup competencyQ1Q2Edu1', PRIndividualQ1Q2Edu.Id, null,
												employeeEducation.Id, competencyGroupMember1.Id,
												'comment competencyQ1Q2Edu1 employee education');
			
			competencyQ1Q2Edu1revMngr = createCompetencyReview('Competency Review manager sup competencyQ1Q2Edu1', PRIndividualQ1Q2Edu.Id, 1.0,
												reviewManagerEducation.Id, competencyGroupMember1.Id,
												'comment competencyQ1Q2Edu1 manager education');
			
			competencyQ1Q2Edu1rev2ndMngr = createCompetencyReview('Competency Review 2nd manager sup competencyQ1Q2Edu1', PRIndividualQ1Q2Edu.Id, null,
												review2ndManagerEducation.Id, competencyGroupMember1.Id,
												'comment competencyQ1Q2Edu1 2nd manager education');
			
			competencyQ1Q2Edu2revEmpl = createCompetencyReview('Competency Review employee sup competencyQ1Q2Edu2', PRIndividualQ1Q2Edu.Id, null,
												employeeEducation.Id, competencyGroupMember2.Id,
												'comment competencyQ1Q2Edu2 employee education');
			
			competencyQ1Q2Edu2revMngr = createCompetencyReview('Competency Review manager sup competencyQ1Q2Edu2', PRIndividualQ1Q2Edu.Id, 4.0,
												reviewManagerEducation.Id, competencyGroupMember2.Id,
												'comment competency 2 manager education');
			
			competencyQ1Q2Edu2rev2ndMngr = createCompetencyReview('Competency Review 2nd manager sup competencyQ1Q2Edu2', PRIndividualQ1Q2Edu.Id, null,
												review2ndManagerEducation.Id, competencyGroupMember2.Id,
												'comment competencyQ1Q2Edu2 2nd manager education');
			
			competencyQ3Q4Edu3revEmpl = createCompetencyReview('Competency Review employee sup competencyQ3Q4Edu3', PRIndividualQ3Q4Edu.Id, null,
												employeeEducation.Id, competencyGroupMember1.Id,
												'comment competencyQ3Q4Edu3 employee education');
			
			competencyQ3Q4Edu3revMngr = createCompetencyReview('Competency Review manager sup competencyQ3Q4Edu3', PRIndividualQ3Q4Edu.Id, 5.0,
												reviewManagerEducation.Id, competencyGroupMember1.Id,
												'comment competencyQ3Q4Edu3 manager education');
			
			competencyQ3Q4Edu3rev2ndMngr = createCompetencyReview('Competency Review 2nd manager sup competencyQ3Q4Edu3', PRIndividualQ3Q4Edu.Id, null,
												review2ndManagerEducation.Id, competencyGroupMember1.Id,
												'comment competencyQ3Q4Edu3 2nd manager education');
			
			competencyQ3Q4Edu4revEmpl = createCompetencyReview('Competency Review employee sup competencyQ3Q4Edu4', PRIndividualQ3Q4Edu.Id, null,
												employeeEducation.Id, competencyGroupMember2.Id,
												'comment competencyQ3Q4Edu4 employee education');
			
			competencyQ3Q4Edu4revMngr = createCompetencyReview('Competency Review manager sup competencyQ3Q4Edu4', PRIndividualQ3Q4Edu.Id, 2.0,
												reviewManagerEducation.Id, competencyGroupMember2.Id,
												'comment competencyQ3Q4Edu4 manager education');
			
			competencyQ3Q4Edu4rev2ndMngr = createCompetencyReview('Competency Review 2nd manager sup competencyQ3Q4Edu4', PRIndividualQ3Q4Edu.Id, null,
												review2ndManagerEducation.Id, competencyGroupMember2.Id,
												'comment competencyQ3Q4Edu4 2nd manager education');
			
			upsert(allCompetencyReviews);
			
			overallrevEmpl = createOverallReview('overall review Empl stnd', PRIndividual.Id, '', '', '', '', 
													employeeStandard.Id, 'comment Empl stnd overall');
			
			overallrevMngr = createOverallReview('overall review Mngr stnd', PRIndividual.Id, '', '', '', '', 
													reviewManagerStandard.Id, 'comment Mngr stnd overall');
			
			overallrev2ndMngr = createOverallReview('overall review 2nd Mngr stnd', PRIndividual.Id, '', '', '', '', 
													review2ndManagerStandard.Id, 'comment 2nd Mngr stnd overall');
					
			overallQ1Q2EdurevEmpl = createOverallReview('overall review Empl edu', PRIndividualQ1Q2Edu.Id, '', '', '', '', 
													employeeEducation.Id, 'comment Empl edu overall');
			
			overallQ1Q2EdurevMngr = createOverallReview('overall review Mngr edu', PRIndividualQ1Q2Edu.Id, '', '', '', '', 
													reviewManagerEducation.Id, 'comment Mngr edu overall');
			
			overallQ1Q2Edurev2ndMngr = createOverallReview('overall review 2nd Mngr edu', PRIndividualQ1Q2Edu.Id, '', '', '', '', 
													review2ndManagerEducation.Id, 'comment 2nd Mngr edu overall');
					
			overallQ3Q4EdurevEmpl = createOverallReview('overall review Empl edu', PRIndividualQ3Q4Edu.Id, '', '', '', '', 
													employeeEducation.Id, 'comment Empl edu overall');
			
			overallQ3Q4EdurevMngr = createOverallReview('overall review Mngr edu', PRIndividualQ3Q4Edu.Id, '', '', '', '', 
													reviewManagerEducation.Id, 'comment Mngr edu overall');
			
			overallQ3Q4Edurev2ndMngr = createOverallReview('overall review 2nd Mngr edu', PRIndividualQ3Q4Edu.Id, '', '', '', '', 
													review2ndManagerEducation.Id, 'comment 2nd Mngr edu overall');
			
			upsert(allOverallReviews);
	
			reviewRating = createOverallRating('overall rating Mngr stnd', PRIndividual.Id, 2.0, 3.2, reviewManagerStandard.Id);
			reviewRatingQ1Q2Edu = createOverallRating('overall rating Mngr edu q1q2', PRIndividualQ1Q2Edu.Id, 3.0, 1.3, reviewManagerEducation.Id);
			reviewRatingQ3Q4Edu = createOverallRating('overall rating Mngr edu q3q4', PRIndividualQ3Q4Edu.Id, 4.0, 0.5, reviewManagerEducation.Id);
			
			upsert(allOverallRatings);
	
			if (createScorecards){
				sscommQ1Q2EdurevEmpl = createScorecardSupportReviewComment(PRIndividualQ1Q2Edu.Id,
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
				
				sscommQ1Q2EdurevMngr = createScorecardSupportReviewComment(PRIndividualQ1Q2Edu.Id,
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
				
				sscommQ1Q2Edurev2ndMngr = createScorecardSupportReviewComment(PRIndividualQ1Q2Edu.Id,
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
						
				sscommQ3Q4EdurevEmpl = createScorecardSupportReviewComment(PRIndividualQ3Q4Edu.Id,
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
				
				sscommQ3Q4EdurevMngr = createScorecardSupportReviewComment(PRIndividualQ3Q4Edu.Id,
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
				
				sscommQ3Q4Edurev2ndMngr = createScorecardSupportReviewComment(PRIndividualQ3Q4Edu.Id,
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
				
				
				
				System.debug('Finish');
			}
		} catch (Exception e) {
            System.debug(' ****************** genScorecardMetricEducation * ');
            System.debug(e.getMessage());
		}
	}


	public static void genScorecardSupportIndividualPerformance(){
		try {
			getUsers();
			getUser('None');
			
			// create v2moms
			v2momIndividual = createV2MOM(employeeStandard.Id, 'vision individual', 'Individual', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
			
			// create the methods for each v2mom		
			method1 = createMethod(v2momIndividual.Id, null, 1, 'Method 1', 'Description method 1');
			method2 = createMethod(v2momIndividual.Id, null, 2, 'Method 2', 'Description method 2');
			
			upsert(allmethods);
			
			// create the competencies for step 2
			//competencyGroup = [select Id from CompetencyGroup__c where Name = 'CCCompGrp' and Code__c='CCCompGrp'];
			competencyGroup = createCompetencyGroup();
			competency1 = createCompetency('Test Competency 1', 'New competency test 1');
			competency2 = createCompetency('Test Competency 2', 'New competency test 2');
			competencyGroupMember1 = createCompetencyGroupMember('CCCompGrpMember1', competency1.Id, competencyGroup.Id, 30);
			competencyGroupMember2 = createCompetencyGroupMember('CCCompGrpMember2', competency2.Id, competencyGroup.Id, 70);
			
			upsert(allCompetencyGroupMembers);
			
			
			// create other necessary elements
			//reviewFormTemplate = [select Id from ReviewFormTemplate__c where Name = 'CCRevTpl' and Code__c='CCRevTpl'];
			
			reviewFormTemplate = createReviewFromTemplate();
			department = createDepartment('Test Department', false);
			
			Date d1 = System.today();
			Date d2 = d1.addYears(1);
			
			// Create the performance review periods for different V2MOMs types		
			PRPIndividual = createPRP('Test PRP Department', 'FY08', 'Individual', d1, d2);
			
			upsert(allPRPs);
	
			// Create the different performance reviews for each V2MOM type
			PRIndividual = createPerformanceReview('Test PReview Individual', PRPIndividual.Id,
											 v2momIndividual.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 employeeStandard.Id, reviewManagerStandard.Id, review2ndManagerStandard.Id, 
											 pcommStandard.Id, managerSupport.Id, department.Id, 'Created');
	
			upsert(allPRs);
		} catch (Exception e) {
            System.debug(' ****************** genScorecardSupportIndividualPerformance * ');
            System.debug(e.getMessage());
		}
	}
	
	public static void genScorecardSupport(){
		try {
			getUsers();
			getUser('None');
			
			// create v2moms
			v2momIndividualQ1Q2Sup = createV2MOM(employeeSupport.Id, 'vision individual Sup Q1Q2', 'Individual Q1/Q2', 'Test V2MOM Individual Q1Q2', 'FY08', 'My Management Hierarchy');
			v2momIndividualQ3Q4Sup = createV2MOM(employeeSupport.Id, 'vision individual Sup Q3Q4', 'Individual Q3/Q4', 'Test V2MOM Individual Q3Q4', 'FY08', 'My Management Hierarchy');
			
			// create the methods for each v2mom		
			methodQ1Q2Sup1 = createMethod(v2momIndividualQ1Q2Sup.Id, null, 1, 'Method 1', 'Description method 1');
			methodQ1Q2Sup2 = createMethod(v2momIndividualQ1Q2Sup.Id, null, 2, 'Method 2', 'Description method 2');
			
			methodQ3Q4Sup3 = createMethod(v2momIndividualQ3Q4Sup.Id, null, 1, 'Method 1', 'Description method 1');
			methodQ3Q4Sup4 = createMethod(v2momIndividualQ3Q4Sup.Id, null, 2, 'Method 2', 'Description method 2');
			
			upsert(allmethods);
			
			// create the competencies for step 2
			//competencyGroup = [select Id from CompetencyGroup__c where Name = 'CCCompGrp' and Code__c='CCCompGrp'];
			competencyGroup = createCompetencyGroup();
			
			competency1 = createCompetency('Test Competency 1', 'New competency test 1');
			competency2 = createCompetency('Test Competency 2', 'New competency test 2');
			competencyGroupMember1 = createCompetencyGroupMember('CCCompGrpMember1', competency1.Id, competencyGroup.Id, 30);
			competencyGroupMember2 = createCompetencyGroupMember('CCCompGrpMember2', competency2.Id, competencyGroup.Id, 70);
			
			upsert(allCompetencyGroupMembers);
			
			// create other necessary elements
			//reviewFormTemplate = [select Id from ReviewFormTemplate__c where Name = 'CCRevTpl' and Code__c='CCRevTpl'];
			
			reviewFormTemplate = createReviewFromTemplate();
			department = createDepartment('Test Department', false);
			
			
			Date d1 = System.today();
			Date d2 = d1.addYears(1);
			
			// Create the performance review periods for different V2MOMs types		
			PRPIndividualQ1Q2 = createPRP('Test PRP Individual Q1/Q2', 'FY08', 'Individual Q1/Q2', d1, d2);
			PRPIndividualQ3Q4 = createPRP('Test PRP Individual Q3/Q4', 'FY08', 'Individual Q3/Q4', d1, d2);
			
			upsert(allPRPs);
	
			// Create the different performance reviews for each V2MOM type
			PRIndividualQ1Q2Sup = createPerformanceReview('Test PReview Sup IndividualQ1Q2', PRPIndividualQ1Q2.Id, 
											 v2momIndividualQ1Q2Sup.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 employeeSupport.Id, reviewManagerSupport.Id, review2ndManagerSupport.Id,
											 pcommStandard.Id, managerStandard.Id, department.Id, 'Created');
			
			PRIndividualQ3Q4Sup = createPerformanceReview('Test PReview Sup IndividualQ3Q4', PRPIndividualQ3Q4.Id, 
											 v2momIndividualQ3Q4Sup.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 employeeSupport.Id, reviewManagerSupport.Id, review2ndManagerSupport.Id, 
											 pcommStandard.Id, managerStandard.Id, department.Id, 'Created');
	
			upsert(allPRs);
			
			if (createScorecards){
				// Create the support scorecards
				System.debug('must be trueeeee     '   + createScorecardsWithData);
				if (!createScorecardsWithData){
					// Create the education scorecards
					sq1Sup = createScorecardSupportReviewEmpty('Test Scorecard Sup Q1', PRIndividualQ1Q2Sup.Id, reviewManagerSupport.Id, 'Q1');
					sq2Sup = createScorecardSupportReviewEmpty('Test Scorecard Sup Q2', PRIndividualQ1Q2Sup.Id, reviewManagerSupport.Id, 'Q2');
					sq3Sup = createScorecardSupportReviewEmpty('Test Scorecard Sup Q3', PRIndividualQ3Q4Sup.Id, reviewManagerSupport.Id, 'Q3');
					sq4Sup = createScorecardSupportReviewEmpty('Test Scorecard Sup Q4', PRIndividualQ3Q4Sup.Id, reviewManagerSupport.Id, 'Q4');
	
				}else{
						sq1Sup = addScorecardSupportReviewWithDataSupport('Test Scorecard Sup Q1', PRIndividualQ1Q2Sup.Id, reviewManagerSupport.Id, 'Q1',
																	10, 1, 5, 2, 1, 3, 31, 
																	'1', '2', '3', '4', '5', '4', '3',
																	2.1, 3.2, 4.3, 5.4, 4.5, 3.6, 2.7, 34,40);
						sq1Sup = addScorecardSupportReviewWithDataEducation(sq1Sup,
																	10, 1, 5, 2, 1, 3, 31, 32, 33, 34, 35, 36);
						sq2Sup = addScorecardSupportReviewWithDataSupport('Test Scorecard Sup Q2', PRIndividualQ1Q2Sup.Id, reviewManagerSupport.Id, 'Q2',
																	10, 1, 5, 2, 41, 3, 31, 
																	'2', '2', '3', '4', '5', '4', '3',
																	2.7, 3.6, 4.5, 5.4, 4.3, 3.2, 2.1, 15, 20);
						sq2Sup = addScorecardSupportReviewWithDataEducation(sq2Sup,
																	20, 10, 30, 2, 4, 3, 21, 22, 23, 24, 25, 26);
						sq3Sup = addScorecardSupportReviewWithDataSupport('Test Scorecard Sup Q3', PRIndividualQ3Q4Sup.Id, reviewManagerSupport.Id, 'Q3',
																	10, 1, 5, 2, 51, 3, 31, 
																	'3', '2', '3', '4', '5', '4', '3',
																	2.1, 3.1, 4.2, 5.2, 4.3, 3.3, 2.4, 25, 25);
						sq3Sup = addScorecardSupportReviewWithDataEducation(sq3Sup,
																	20, 10, 30, 2, 1, 5, 21, 22, 23, 24, 25, 26);
						sq4Sup = addScorecardSupportReviewWithDataSupport('Test Scorecard Sup Q4', PRIndividualQ3Q4Sup.Id, reviewManagerSupport.Id, 'Q4',
																	10, 1, 5, 2, 71, 3, 31, 
																	'4', '2', '3', '4', '5', '4', '3',
																	2.9, 3.9, 4.9, 5.9, 4.9, 3.9, 2.9, 30, 30);
						sq4Sup = addScorecardSupportReviewWithDataEducation(sq4Sup,
																	10, 1, 5, 2, 4, 5, 31, 32, 33, 34, 35, 36);
				}
			}
			
			System.debug('whatttt1    \n\n\n ' + sq1Sup);
			System.debug('whatttt2    \n\n\n ' + sq2Sup);
			System.debug('whatttt3    \n\n\n ' + sq3Sup);
			System.debug('whatttt4    \n\n\n ' + sq4Sup);
			upsert(sq1Sup);
			upsert(sq2Sup);
			upsert(sq3Sup);
			upsert(sq4Sup);
			
			System.debug('Finish upsert all');
			//upsert(allScorecards);
	
			if (createScorecards){
				sscommQ1Q2SuprevEmpl = createScorecardSupportReviewComment(PRIndividualQ1Q2Sup.Id,
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
				
				sscommQ1Q2SuprevMngr = createScorecardSupportReviewComment(PRIndividualQ1Q2Sup.Id,
		    																	reviewManagerSupport.Id, 
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
				
				sscommQ1Q2Suprev2ndMngr = createScorecardSupportReviewComment(PRIndividualQ1Q2Sup.Id,
		    																	review2ndManagerSupport.Id, 
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
						
				sscommQ3Q4SuprevEmpl = createScorecardSupportReviewComment(PRIndividualQ3Q4Sup.Id,
		    																	employeeSupport.Id, 
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
				
				sscommQ3Q4SuprevMngr = createScorecardSupportReviewComment(PRIndividualQ3Q4Sup.Id,
		    																	reviewManagerSupport.Id, 
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
				
				sscommQ3Q4Suprev2ndMngr = createScorecardSupportReviewComment(PRIndividualQ3Q4Sup.Id,
		    																	review2ndManagerSupport.Id, 
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
				
				accessUtil = new PerformanceAccessUtil(PRIndividualQ3Q4Sup, reviewManagerCSM, reviewManagerCSM);
				
			}
		} catch (Exception e) {
            System.debug(' ****************** genScorecardSupport * ');
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
	
	//public static Department__c createDepartment(String name, boolean excl){
	public static TF2_Department__c createDepartment(String name, boolean excl){
			//Department__c d = new Department__c();
			TF2_Department__c d = new TF2_Department__c();
			d.Name = name;
			d.Exclude_ESBP__c = excl;
			upsert(d);
			return d;
	}
	
	public static Method__c createMethod(Id v2mom, Id value, Integer p, String name, String d){
		Method__c method = new Method__c(V2MOM__c = v2mom, 
										Value__c = value,
										Priority__c = p, 
										Name = name,
										Description__c = d);
		
		allMethods.add(method);
		
		return method;
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
	public static MethodReview__c createMethodReview(String oname,
												Id pr,
												double rating,
												Integer weight,
												String status, 
												Id reviewer,
												Id method,
												String comment){
		
		MethodReview__c methodReview;
		
		if (emptyMethodReviewComment){
			methodReview = new MethodReview__c(Weight__c = weight, 
												Status__c = status, 
												Reviewer__c = reviewer, 
												Rating__c = rating, 
												PerformanceReview__c = pr, 
												Method__c = method);
		}

		if (emptyMethodReviewRating){
			methodReview = new MethodReview__c(Weight__c = weight, 
												Status__c = status, 
												Reviewer__c = reviewer,  
												PerformanceReview__c = pr, 
												Method__c = method, 
												Comment__c = comment);
		}
		
		if ((!emptyMethodReviewRating) && (!emptyMethodReviewRating)){
			methodReview = new MethodReview__c(Weight__c = weight, 
												Status__c = status, 
												Reviewer__c = reviewer, 
												Rating__c = rating, 
												PerformanceReview__c = pr, 
												Method__c = method, 
												Comment__c = comment);
		}
		
		allMethodReviews.add(methodReview);
		
		return methodReview;
	}

	public static CompetencyReview__c createCompetencyReview(String oname,
												Id pr,
												double rating,
												Id reviewer,
												Id cgm,
												String comment){
		
		CompetencyReview__c compReview;
		
		if (emptyCompReviewComment){
			compReview = new CompetencyReview__c(Reviewer__c = reviewer, 
												Rating__c = rating, 
												PerformanceReview__c = pr, 
												CompetencyGroupMember__c = cgm);
		}
		
		if (emptyCompReviewRating){
			compReview = new CompetencyReview__c(Reviewer__c = reviewer,
												PerformanceReview__c = pr, 
												CompetencyGroupMember__c = cgm, 
												Comment__c = comment);
		}
		
		if ((!emptyCompReviewComment) && (!emptyCompReviewRating)){
			compReview = new CompetencyReview__c(Reviewer__c = reviewer, 
												Rating__c = rating, 
												PerformanceReview__c = pr, 
												CompetencyGroupMember__c = cgm, 
												Comment__c = comment);
		}
		
		allCompetencyReviews.add(compReview);
		
		return compReview;
	}

	public static AdditionalComment__c createOverallReview(String oname,
															Id pr,
															String updtMeth,
															String suggComp,
															String suggMeth,
															String commComp,
															Id reviewer,
															String comment){
		AdditionalComment__c overallReview;
		
		if (emptyOverallReview){
			overallReview = new AdditionalComment__c(Reviewer__c = reviewer, 
													PerformanceReview__c = pr);
		}
		
		if (!emptyOverallReview){
			overallReview = new AdditionalComment__c(UpdateMethods__c = updtMeth, 
													SuggestionsCompetencies__c = suggComp, 
													SuggestionMethods__c = suggMeth, 
													Reviewer__c = reviewer, 
													PerformanceReview__c = pr, 
													Comment__c = comment, 
													CommentCompetencies__c = commComp);
		}
		
		allOverallReviews.add(overallReview);
		
		return overallReview;
	}

	public static ReviewRating__c createOverallRating(String oname,
															Id pr,
															double orating,
															double crating,
															Id reviewer){
		
		ReviewRating__c overallRating;
		
		if (emptyOverallRating){
			overallRating = new ReviewRating__c(Reviewer__c = reviewer, 
												PerformanceReview__c = pr);
		}
		
		if (!emptyOverallRating){
			overallRating = new ReviewRating__c(Reviewer__c = reviewer, 
												PerformanceReview__c = pr, 
												OverallRating__c = orating,
												CalculatedRating__c = crating);
		}
		
		allOverallRatings.add(overallRating);
		
		return overallRating;
	}
		
	public static ScorecardSupportReview__c createScorecardSupportReviewEmpty(String pname, 
																		Id pr,
																		Id reviewer,
																		String fq){
		ScorecardSupportReview__c s = new ScorecardSupportReview__c (Name = pname,
																	PerformanceReview__c = pr,
																	FiscalQuarter__c = fq);

		
		allScorecards.add(s);
		
		return s;
	}
		
	public static ScorecardSupportReview__c addScorecardSupportReviewWithDataSupport(String pname,
																				Id pr,
																				Id reviewer,
																				String fq,
												                                Double weightCS, 
												                                Double weightRenewals, 
												                                Double weightWMCases, 
												                                Double weightWMSMES,
												                                Double weightWMHC,
												                                Double weightWMPA,
												                                Double weightSI,
												                                String adjustedRatingCS,
												                                String adjustedRatingRenewals, 
												                                String adjustedRatingWMCases, 
												                                String adjustedRatingWMSMES,
												                                String adjustedRatingWMHC,
												                                String adjustedRatingWMPA,
												                                String adjustedRatingSI,
												                                Double calculatedRatingCS, 
												                                Double calculatedRatingRenewals, 
												                                Double calculatedRatingWMCases, 
												                                Double calculatedRatingWMSMES,
												                                Double calculatedRatingWMHC,
												                                Double calculatedRatingWMPA,
												                                Double calculatedRatingSI,
												                                Integer customerSatisfactionActual,
												                                Integer customerSatisfactionTarget){
		ScorecardSupportReview__c s = new ScorecardSupportReview__c (Name = pname,
																	PerformanceReview__c = pr,
																	FiscalQuarter__c = fq,
																	WeightCS__c = weightCS, 
									                                WeightRenewals__c = weightRenewals, 
									                                WeightWMCases__c = weightWMCases, 
									                                WeightWMSMES__c = weightWMSMES,
									                                WeightWMHC__c = weightWMHC,
									                                WeightWMPA__c = weightWMPA,
									                                WeightSI__c = weightSI,
									                                AdjustedRatingCS__c = adjustedRatingCS,
									                                AdjustedRatingRenewals__c = adjustedRatingRenewals, 
									                                AdjustedRatingWMCases__c = adjustedRatingWMCases, 
									                                AdjustedRatingWMSMES__c = adjustedRatingWMSMES,
									                                AdjustedRatingWMHC__c = adjustedRatingWMHC,
									                                AdjustedRatingWMPA__c = adjustedRatingWMPA,
									                                AdjustedRatingSI__c  = adjustedRatingSI,
									                                CalculatedRatingCS__c = calculatedRatingCS, 
									                                CalculatedRatingRenewals__c = calculatedRatingRenewals, 
									                                CalculatedRatingWMCases__c = calculatedRatingWMCases, 
									                                CalculatedRatingWMSMES__c = calculatedRatingWMSMES,
									                                CalculatedRatingWMHC__c = calculatedRatingWMHC,
									                                CalculatedRatingWMPA__c = calculatedRatingWMPA,
									                                CalculatedRatingSI__c = calculatedRatingSI,
									                                CustomerSatisfactionActual__c = customerSatisfactionActual,												                               
									                                CustomerSatisfactionTarget__c = customerSatisfactionTarget,
									                                OperationalExcellenceRating__c = 1, StrategicInitiativesRating__c = 1,
									                                WMCCPRating__c = 1, WMCCPWeight__c = 1, WMCAARating__c = 1, WMCAAWeight__c = 1,
									                                RatingCustomerSatisfaction__c = 1, WeightCustomerSatisfaction__c = 1 , OperationalExcellenceWeight__c = 1,
									                                StrategicInitiativesWeight__c = 1, CSMSalesImpactRating__c = 1					                                
									                                );
		
        return s;											                                
    }
    
    public static ScorecardSupportReview__c createScorecardSupportReviewWithDataEducation(String pname, 
																		Id pr,
																		Id reviewer,
																		String fq,
										                                Double forecastAccuracyWeight,
										                                Double salesImpactWeight,
										                                Double timeOnPlatformWeight,  
										                                Double forecastAccuracyRating,
										                                Double salesImpactRating,
										                                Double timeOnPlatformRating,
										                                Double forecastAccuracyActual,
										                                Double forecastAccuracyTarget,
										                                Double timeOnPlatformTarget,
										                                Double timeOnPlatformActual,
										                                Double salesImpactActual,
										                                Double salesImpactTarget) {

		ScorecardSupportReview__c s = new ScorecardSupportReview__c (Name = pname,
																	PerformanceReview__c = pr,
																	FiscalQuarter__c = fq);
    	
        s.ForecastAccuracyWeight__c = forecastAccuracyWeight;
        s.SalesImpactWeight__c = salesImpactWeight;
        s.TimeOnPlatformWeight__c = timeOnPlatformWeight;  
        s.ForecastAccuracyRating__c = forecastAccuracyRating;
        s.SalesImpactRating__c = salesImpactRating;
        s.TimeOnPlatformRating__c = timeOnPlatformRating;
        s.ForecastAccuracyActual__c = forecastAccuracyActual;
        s.ForecastAccuracyTarget__c = forecastAccuracyTarget;
        s.TimeOnPlatformTarget__c = timeOnPlatformTarget;
        s.TimeOnPlatformActual__c = timeOnPlatformActual;
        s.SalesImpactActual__c = salesImpactActual;
        s.SalesImpactTarget__c = salesImpactTarget;
        
		allScorecards.add(s);
		
		return s;
    }
    
        
    public static ScorecardSupportReview__c addScorecardSupportReviewWithDataEducation(ScorecardSupportReview__c s,
										                                Double forecastAccuracyWeight,
										                                Double salesImpactWeight,
										                                Double timeOnPlatformWeight,  
										                                Double forecastAccuracyRating,
										                                Double salesImpactRating,
										                                Double timeOnPlatformRating,
										                                Double forecastAccuracyActual,
										                                Double forecastAccuracyTarget,
										                                Double timeOnPlatformTarget,
										                                Double timeOnPlatformActual,
										                                Double salesImpactActual,
										                                Double salesImpactTarget) {
   	
        s.ForecastAccuracyWeight__c = forecastAccuracyWeight;
        s.SalesImpactWeight__c = salesImpactWeight;
        s.TimeOnPlatformWeight__c = timeOnPlatformWeight;  
        s.ForecastAccuracyRating__c = forecastAccuracyRating;
        s.SalesImpactRating__c = salesImpactRating;
        s.TimeOnPlatformRating__c = timeOnPlatformRating;
        s.ForecastAccuracyActual__c = forecastAccuracyActual;
        s.ForecastAccuracyTarget__c = forecastAccuracyTarget;
        s.TimeOnPlatformTarget__c = timeOnPlatformTarget;
        s.TimeOnPlatformActual__c = timeOnPlatformActual;
        s.SalesImpactActual__c = salesImpactActual;
        s.SalesImpactTarget__c = salesImpactTarget;
        
		allScorecards.add(s);
		
		return s;
    }
    
    public static ScorecardSupportComment__c createScorecardSupportReviewComment(Id pr,
    																	Id reviewer, 
																		String CS,
																		String renewals,
																		String WMCases,
																		String WMSMES, 
																		String WMHC,
																		String WMPA,
																		String supportInitiatives,
																		String salesImpact,
																		String timeOnPlatform,
																		String forecastAccuracy){
		
		ScorecardSupportComment__c s;
		
		if (emptySSComm){
			s = new ScorecardSupportComment__c (Reviewer__c = reviewer,
								                PerformanceReview__c = pr);
		}
		
		if (!emptySSComm){
			s = new ScorecardSupportComment__c (Reviewer__c = reviewer,
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
								                CommentCS__c = CS, CommentWMCCP__c = 'CommentWMCCP__c',
								                CommentWMCAA__c = 'CommentWMCAA__c'
								                );
		}
		
		allSSComms.add(s);
		
		return s;
		
	}
		
	public static CompetencyGroupMember__c createCompetencyGroupMember(String name, 
											Id comp, Id cg, Integer w){
			CompetencyGroupMember__c c = new CompetencyGroupMember__c();
			c.Name = name;
			c.CompetencyGroup__c = cg;
			c.Competency__c = comp;
			c.Weight__c = w;
			allCompetencyGroupMembers.add(c);
			return c;
	}
	
	public static Competency__c createCompetency(String name, String d){
			Competency__c c = new Competency__c();
			c.Name = name;
			c.Description__c = d;
			upsert(c);
			return c;
	}
	
	public static PerformanceReviewPeriod__c createPRP(String pname, String effdate, String v2momType,
														Date sdate, Date edate){
		PerformanceReviewPeriod__c prp = new PerformanceReviewPeriod__c(Name = pname,
																		Effective_Date__c = effdate,
																		V2MOM_Type__c = v2momType,
																		StartDate__c = sdate,
																		EndDate__c = edate);
																		
		allPRPs.add(prp);
		
		return prp;
	}
	
	
	public static void getUsers(){
		userList = [select id, username, name, Profile.Name from User 
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
												];
												
		pcommStandard = getUser(GenerateEnvironmentTestUsers.ccpcomm);
		esadminStandard = getUser(GenerateEnvironmentTestUsers.ccesadmin);
		ceoStandard = getUser(GenerateEnvironmentTestUsers.ccceo);
		esbpStandard = getUser(GenerateEnvironmentTestUsers.ccesbp);
												
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

		employeeEducation = getEducationEmployee();
		managerEducation = getUser(GenerateEnvironmentTestUsers.ccedumngr);
		secondManagerEducation = getUser(GenerateEnvironmentTestUsers.ccedu2ndmngr);
		reviewManagerEducation = getUser(GenerateEnvironmentTestUsers.ccrevedumngr);
		review2ndManagerEducation = getUser(GenerateEnvironmentTestUsers.ccrevedu2ndmngr);

		employeeConsulting = getUser(GenerateEnvironmentTestUsers.ccconsempl);
		managerConsulting = getUser(GenerateEnvironmentTestUsers.ccconsmngr);
		secondManagerConsulting = getUser(GenerateEnvironmentTestUsers.cccons2ndmngr);
		reviewManagerConsulting = getUser(GenerateEnvironmentTestUsers.ccrevconsmngr);
		review2ndManagerConsulting = getUser(GenerateEnvironmentTestUsers.ccrevcons2ndmngr);

		employeeCSM = getUser(GenerateEnvironmentTestUsers.cccsmempl);
		managerCSM = getUser(GenerateEnvironmentTestUsers.cccsmmngr);
		secondManagerCSM = getUser(GenerateEnvironmentTestUsers.cccsm2ndmngr);
		reviewManagerCSM = getUser(GenerateEnvironmentTestUsers.ccrevcsmmngr);
		review2ndManagerCSM = getUser(GenerateEnvironmentTestUsers.ccrevcsm2ndmngr);
		
		System.debug('GoCheckUser ' );
		
		System.debug(pcommStandard );
		System.debug(esadminStandard );
		System.debug(ceoStandard );
		System.debug(esbpStandard );
		System.debug(employeeStandard );
		System.debug(managerStandard );
		System.debug(secondManagerStandard );
		System.debug(reviewManagerStandard );
		System.debug(review2ndManagerStandard );
		System.debug(employeeSupport );
		System.debug(managerSupport );
		System.debug(secondManagerSupport );
		System.debug(reviewManagerSupport );
		System.debug(review2ndManagerSupport );
		System.debug(employeeEducation );
		System.debug(managerEducation );
		System.debug(secondManagerEducation );
		System.debug(reviewManagerEducation );
		System.debug(review2ndManagerEducation );
		System.debug(employeeConsulting );
		System.debug(managerConsulting );
		System.debug(secondManagerConsulting );
		System.debug(reviewManagerConsulting );
		System.debug(review2ndManagerConsulting );
		System.debug(employeeCSM );
		System.debug(managerCSM );
		System.debug(secondManagerCSM );
		System.debug(reviewManagerCSM );
		System.debug(review2ndManagerCSM );
	
	}
	
	public static User getManager(){
						
			if(manager == null){
				Profile p = [Select Id From Profile where Name =: 'Manager'];
				manager =  new User(	username='test__manager@test.com',
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
					insert manager;	
				}					
				
			}
			return manager;
		
	}
    
    public static User getEmployeeStandard(){
    	
    	try{
    		employeeStandard = [Select id, Name, ProfileId From User Where username =: 'testStandardemp@test.com'];	
    	}catch(Exception e){
    		System.debug('Error: ' + e.getMessage());
    	} 
		
		if(employeeStandard == null){
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
			//Select the employee from the database to get the id 
			employeeStandard = [Select id, Name, ProfileId From User Where username =: 'testStandardemp@test.com'];	
		}
		
		
		
		return employeeStandard;									
    }
    
    public static User getEducationEmployee(){
    	Profile p = [Select Id From Profile where Name =: 'Education Employee'];
		employeeEducation =  new User(	username = 'testEducationemp@test.com',
										lastName = 'education',
										email = 'eduemptest1@mailinator.com',
										alias = 'edutest',
										timeZoneSidKey ='America/Los_Angeles',
										manager__c = getManager().Id,
										localeSidKey = 'en_US',
										emailEncodingKey = 'ISO-8859-1',
										LanguagelocaleKey = 'en_US',
										ProfileId = p.Id
									);
		/* Run As Review Manager */
		system.runAs(getManager()){
			insert employeeEducation;
		}
		return employeeEducation;									
    }
    
     public static User getPCOMMStandard(){
    	Profile p = [Select Id From Profile where Name =: 'PCOMM'];
		pcommStandard =  new User(	username = 'testpcommStandardemp@test.com',
										lastName = 'standard',
										email = 'pcomm@mailinator.com',
										alias = 'etest',
										timeZoneSidKey ='America/Los_Angeles',
										manager__c = getManager().Id,
										localeSidKey = 'en_US',
										emailEncodingKey = 'ISO-8859-1',
										LanguagelocaleKey = 'en_US',
										ProfileId = p.Id
									);
		/* Run As Review Manager */
		system.runAs(getSystemAdmin()){
			insert pcommStandard;
		}
		return pcommStandard;									
    }
    
    public static User getSystemAdmin(){
		Profile p = [Select Id From Profile where Name =: 'System Administrator'];
		User adminUser = [Select id From User Where ProfileID =: p.Id And IsActive =: True limit 1][0];
		return adminUser; 
	}	 
	
	public static User getUser(String oname){
		for (User u : userList){
			if (u.username.equals(oname)){
				return u;
			}
		}

		return null;
	}
	
	public static PerformanceReview__c createPerformanceReview(String pname, Id prp, Id v2, Id cgrp, Id rftpl,
															  Id empl, Id mngr, Id sndMngr, Id pcomm, Id thirdP,
															  Id dpt, String status){
															
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
														   ThirdPartyReviewer__c = thirdP);
														   //Department__c = dpt,
																		
		allPRs.add(pr);
		
		return pr;
	}

	
	public static PerformanceReview__c changeStatusPReview(PerformanceReview__c pr,
																String previousStatus,
																String newStatus){
		try{
			pr.Status__c = newStatus;
			pr.PreviousStatus__c = previousStatus;
		
			upsert(pr);	
		}catch(Exception e){
			
		}
		return pr;
	}


}