public class GenerateEnvironmentTest10 {
	
	/*
	 * ENVIRONMENT TO TEST: Test_ViewReviewPeriodController
	 */
	 
	public static PerformanceReviewPeriod__c PRPIndividual;
	public static PerformanceReviewPeriod__c PRPIndividualQ1Q2;
	public static PerformanceReviewPeriod__c PRPIndividualQ3Q4;
	public static PerformanceReviewPeriod__c PRPAdHoc;
	public static PerformanceReviewPeriod__c PRPErrors;
	
	public static ReviewPeriodDepartment__c RPDIndividual;
	public static ReviewPeriodDepartment__c RPDIndividualQ1Q2;
	public static ReviewPeriodDepartment__c RPDAdHoc;
	
	public static CompetencyGroup__c competencyGroup;
	public static ReviewFormTemplate__c reviewFormTemplate;
	//public static Department__c department;
	//public static Department__c departmentError;
	public static TF2_Department__c department;
	public static TF2_Department__c departmentError;
	
	public static User employeeConswStndMngr;
	public static User emptyEmployeeSupport;
	public static User managerStandard;
	public static User employeeConsulting;
	public static User managerConsulting;
	public static User pcommStandard;
	public static List<User> userList;

	public static V2MOM__c v2momIndividualQ1Q2;
	public static V2MOM__c v2momIndividualQ3Q4;
	
	public static Value__c value1;

	public static Method__c method1;

	public static Obstacle__c obstacle1;
	public static Obstacle__c obstacle2;

	public static Measure__c measure1;
	public static Measure__c measure2;
	
	
	public static void genPerformanceReviewPeriod() {
		try {
			getUsers();
			getUser('');
			Date d1 = System.today();
			Date d2 = d1.addYears(1);
			
			PRPIndividual = createPRP('Test PRP Department', 'FY08', 'Individual', d1, d2);
			PRPIndividualQ1Q2 = createPRP('Test PRP Individual Q1/Q2', 'FY08', 'Individual Q1/Q2', d1, d2);
			PRPIndividualQ3Q4 = createPRP('Test PRP Individual Q3/Q4', 'FY08', 'Individual Q3/Q4', d1, d2);
			PRPAdHoc = createPRP('Test PRP Ad Hoc', 'FY08', 'Ad Hoc', d1, d2);
			PRPErrors = createPRP('Test PRP with Errors', 'FY09', 'Organization', d1, d2);
			
			RPDIndividual = createRPD(PRPIndividual.Id);
			RPDIndividualQ1Q2 = createRPD(PRPIndividualQ1Q2.Id);	
			RPDAdHoc = createRPD(PRPAdHoc.Id);		
			
			competencyGroup = createCG(managerStandard.CompetencyGroupCode__c);
			reviewFormTemplate = createRFT(managerStandard.ReviewTemplateCode__c);
			department = createDepartment('Test Department', true);
			
			//departmentError = [select Id from Department__c where Name = 'CCDeptTest'];
			departmentError = [select Id from TF2_Department__c where Name = 'CCDeptTest'];
		} catch (Exception e) {
            System.debug(' ****************** genPerformanceReviewPeriod * ');
            System.debug(e.getMessage());
		}
	}

	public static void createV2MOMIndividualQ1Q2Data(){
		v2momIndividualQ1Q2 = createV2MOM(employeeConswStndMngr.Id, 'vision individual', 'Individual Q1/Q2', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
		
		value1 = createValue(v2momIndividualQ1Q2.Id, 1, 'Value 1');
		
		method1 = createMethod(v2momIndividualQ1Q2.Id, value1.Id, 1, 'Method 1', 'Description method 1');
		
		obstacle1 = createObstacle(v2momIndividualQ1Q2.Id, value1.Id, method1.Id, 1, 'Description obstacle 1');
		obstacle2 = createObstacle(v2momIndividualQ1Q2.Id, null, method1.Id, 2, 'Description obstacle 2');


		Date d = System.today();
		
		measure1 = createMeasure(v2momIndividualQ1Q2.Id, value1.Id, method1.Id, 1, 'Description measure 1', d, d);
		measure2 = createMeasure(v2momIndividualQ1Q2.Id, null, method1.Id, 2, 'Description measure 2', d, d);
	}

	public static void createV2MOMIndividualQ3Q4Data(){
		v2momIndividualQ3Q4 = createV2MOM(employeeConswStndMngr.Id, 'vision individual', 'Individual Q3/Q4', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
		
		value1 = createValue(v2momIndividualQ3Q4.Id, 1, 'Value 1');
		
		method1 = createMethod(v2momIndividualQ3Q4.Id, value1.Id, 1, 'Method 1', 'Description method 1');
		
		obstacle1 = createObstacle(v2momIndividualQ3Q4.Id, value1.Id, method1.Id, 1, 'Description obstacle 1');
		obstacle2 = createObstacle(v2momIndividualQ3Q4.Id, null, method1.Id, 2, 'Description obstacle 2');


		Date d = System.today();
		
		measure1 = createMeasure(v2momIndividualQ3Q4.Id, value1.Id, method1.Id, 1, 'Description measure 1', d, d);
		measure2 = createMeasure(v2momIndividualQ3Q4.Id, null, method1.Id, 2, 'Description measure 2', d, d);
	}
	
	public static PerformanceReviewPeriod__c createPRP(String pname, String effdate, String v2momType,
														Date sdate, Date edate){
		PerformanceReviewPeriod__c prp = new PerformanceReviewPeriod__c(Name = pname,
																		Effective_Date__c = effdate,
																		V2MOM_Type__c = v2momType,
																		StartDate__c = sdate,
																		EndDate__c = edate);																		
		upsert prp;
		
		return prp;
	}
	
	public static ReviewPeriodDepartment__c createRPD(String prpId) {
		ReviewPeriodDepartment__c rpd = new ReviewPeriodDepartment__c(PerformanceReviewPeriod__c = prpId);
		
		upsert rpd;
		
		return rpd;
	}	
			
	public static CompetencyGroup__c createCG(String cgcId) {
		CompetencyGroup__c cg = new CompetencyGroup__c(Code__c = cgcId);
		
		upsert cg;
		
		return cg;
	}
				
	public static ReviewFormTemplate__c createRFT(String rftId) {
		ReviewFormTemplate__c rft = new ReviewFormTemplate__c(Code__c = rftId);
		
		upsert rft;
		
		return rft;
	}
	
	//public static Department__c createDepartment(String name, boolean excl){
	public static TF2_Department__c createDepartment(String name, boolean excl){
		TF2_Department__c d = new TF2_Department__c(Name = name,
											Exclude_ESBP__c = excl);
		upsert d;
		
		return d;
	}
	
	public static V2MOM__c createV2MOM(Id user, String vision, String t, String name, 
										String effDate, String share){
		V2MOM__c v2mom = new V2MOM__c (	OwnerId=user,
										Vision__c = vision, 
										V2MOM_Type__c = t,
										Name = name, 
										Effective_Date__c = effDate,
										Share_With__c = share);
		upsert(v2mom);
		
		return v2mom;
	}
	
	public static Value__c createValue(Id v2mom, Integer p, String name){
		Value__c value = new Value__c (	V2MOM__c = v2mom, 
											Priority__c = p, 
											Name = name);
		upsert(value);
		
		return value;
	}

	public static Method__c createMethod(Id v2mom, Id value, Integer p, String name, String d){
		Method__c method = new Method__c(V2MOM__c = v2mom, 
										Value__c = value,
										Priority__c = p, 
										Name = name,
										Description__c = d);
		upsert(method);
		
		return method;
	}
	
	public static Measure__c createMeasure(Id v2mom, Id value, Id method, Integer p, String d, Date startDate, Date endDate){
		Measure__c metric = new Measure__c(V2MOM__c = v2mom, 
										Method__c = method,
										Value__c = value,
										Priority__c = p, 
										Description__c = d,
										Start_Date__c = startDate,
										End_Date__c = endDate);
		upsert(metric);
		
		return metric;
	}
	
	public static Obstacle__c createObstacle(Id v2mom, Id value, Id method, Integer p, String d){
		Obstacle__c obstacle = new Obstacle__c(V2MOM__c = v2mom, 
										Method__c = method,
										Value__c = value,
										Priority__c = p, 
										Description__c = d);
		upsert(obstacle);
		
		return obstacle;
	}
		
	public static void getUsers() {
		userList = [select id, username, name, Profile.Name, CompetencyGroupCode__c, ReviewTemplateCode__c 
					from User 
					where username=:GenerateEnvironmentTestUsers.ccpcomm 
						or username=:GenerateEnvironmentTestUsers.ccesadmin
						or username=:GenerateEnvironmentTestUsers.ccceo
						or username=:GenerateEnvironmentTestUsers.ccesbp
						or username=:GenerateEnvironmentTestUsers.ccemptysupempl
						or username=:GenerateEnvironmentTestUsers.ccconsemplwstndmngr
						
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
						or username=:GenerateEnvironmentTestUsers.cccsmempl];
												
		managerStandard = getUser(GenerateEnvironmentTestUsers.ccstndmngr);
		managerConsulting = getUser(GenerateEnvironmentTestUsers.ccconsmngr);
		employeeConsulting = getUser(GenerateEnvironmentTestUsers.ccconsempl);
		pcommStandard = getUser(GenerateEnvironmentTestUsers.ccpcomm);		
		emptyEmployeeSupport = getUser(GenerateEnvironmentTestUsers.ccemptysupempl);		
		employeeConswStndMngr = getUser(GenerateEnvironmentTestUsers.ccconsemplwstndmngr);		
	}
		
	public static User getUser(String oname){
		for (User u : userList){
			if (u.username.equals(oname)){
				return u;
			}
		}

		return null;
	}
}