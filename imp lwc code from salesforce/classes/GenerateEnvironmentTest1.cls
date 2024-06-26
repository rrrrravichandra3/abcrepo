public class GenerateEnvironmentTest1 {
	
	/*
	 * ENVIRONMENT TO TEST: Test_checkForLockedV2MOM
	 *						Test_V2MOMUtil
	 *						Test_V2MOMValuesController
	 *						Test_V2MOMMethodsController
	 *						Test_V2MOMMetricsController
	 *						Test_V2MOMObstaclesController
	*/	
	
	public static V2MOM__c v2mom;
	public static V2MOM__c v2momLocked;
	public static V2MOM__c v2momUnlocked;
	public static V2MOM__c v2momNoValue; 
	public static V2MOM__c v2momIndividual;
	
	public static List<V2MOM__c> v2momListUnLocked = new List<V2MOM__c>();
	public static List<V2MOM__c> v2momListLocked = new List<V2MOM__c>();
	
	public static Value__c valueForLocked;
	public static Value__c valueForLocked2;
	public static Value__c valueForUnlocked;
	
	public static List<Value__c> valueList = new List<Value__c>();
	
	public static Method__c methodForLocked;
	public static Method__c methodForLocked2;
	public static Method__c methodForLocked3;
	public static Method__c methodForUnlocked;
	public static Method__c methodForUnlocked3;
	public static Method__c methodForUnlocked4;
	public static Method__c methodForUnlocked5;
	public static Method__c methodForUnlocked6;
	
	public static List<Method__c> methodList = new List<Method__c>();
	public static List<Measure__c> metricList = new List<Measure__c>();
	public static List<Obstacle__c> obstacleList = new List<Obstacle__c>();
	
	public static Measure__c metricForLocked;
	public static Measure__c metricForLocked2;
	public static Measure__c metricForLocked3;
	public static Measure__c metricForUnlocked;
	public static Measure__c metricForUnlocked4;
	public static Measure__c metricForUnlocked5;
	public static Measure__c metricForUnlocked6;
	public static Measure__c metricForUnlocked7;
	
	public static Obstacle__c obstacleForLocked;
	public static Obstacle__c obstacleForLocked2;
	public static Obstacle__c obstacleForLocked3;
	public static Obstacle__c obstacleForUnlocked;
	public static Obstacle__c obstacleForUnlocked4;
	public static Obstacle__c obstacleForUnlocked5;
	public static Obstacle__c obstacleForUnlocked6;
	public static Obstacle__c obstacleForUnlocked7;
	
	public static Note testNote;
	public static Attachment testAttach;
	
	public static ReviewFormTemplate__c reviewFormTemplate;	
	public static PerformanceReview__c PRIndividual;
	public static PerformanceReview__c PRYearEnd;
	public static PerformanceReviewPeriod__c PRPIndividual;
	public static Department__c department;
	public static CompetencyGroup__c competencyGroup;
	public static CompetencyGroupMember__c competencyGroupMember1;
	public static Competency__c competency1;
	
	
	public static User pcommStandard;
    public static User esadminStandard;
    
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
	
	public static List<User> userList;
	
	public static List<PerformanceReview__c> allPRs = new List<PerformanceReview__c>();
	
	public static void gen()
	{
		v2momLocked = createV2MOM('Test V2MOM', 'Department', 'FY08', 'Test', 'My Management Hierarchy', 'Not Submitted', false);
		v2momUnlocked = createV2MOM('Test V2MOM 2', 'Department', 'FY08', 'Test 2', 'My Management Hierarchy', 'Not Submitted', false);
		v2momNoValue = createV2MOM('Test V2MOM 3', 'Department', 'FY08', 'Test 3', 'My Management Hierarchy', 'Not Submitted', false);
		
		valueForLocked = createValue('test value', 'test value tag line 1', 1, v2momLocked.Id);
		valueForUnlocked = createValue('test value', 'test value tag line 2', 1, v2momUnlocked.Id);
		
		/*
		* ADD METHODS TO THE LIST AND UPSERT
		*/
		addMethod(methodForLocked, 'test method', 'test method tag line 1', 1, v2momLocked.Id, null);
		addMethod(methodForLocked2, 'test method 3', 'test method tag line 3', 1, v2momLocked.Id, null);
		addMethod(methodForUnlocked, 'test method 2', 'test method tag line 2', 1, v2momUnlocked.Id, null);
        addMethod(methodForUnlocked3, 'test method 3', 'test method tag line 2', 1, v2momUnlocked.Id, null);
        
        upsert(methodList);
        
        /*
		* ADD METRICS TO THE LIST AND UPSERT
		*/
        addMetric(metricForLocked, 'test metric 1', 'test metric tag line 1', 1, v2momLocked.Id, null, null);
        addMetric(metricForLocked2, 'test metric 2', 'test metric tag line 2', 1, v2momLocked.Id, null, null);
        addMetric(metricForUnlocked, 'test metric 3', 'test metric tag line 3', 1, v2momUnlocked.Id, null, null);
        addMetric(metricForUnlocked4, 'test metric 4', 'test metric tag line 4', 1, v2momUnlocked.Id, null, null);
        
        upsert(metricList);
        
        /*
		* ADD OBSTACLES TO THE LIST AND UPSERT
		*/
        addObstacle(obstacleForLocked, 'test obstacle tag line 1', 1, v2momLocked.Id, null, null);
        addObstacle(obstacleForLocked2, 'test obstacle tag line 2', 1, v2momLocked.Id, null, null);
        addObstacle(obstacleForUnlocked, 'test obstacle tag line 3', 1, v2momUnlocked.Id, null, null);
        addObstacle(obstacleForUnlocked4, 'test obstacle tag line 4', 1, v2momUnlocked.Id, null, null);
   		
   		upsert(obstacleList);
		
		lockV2MOM(v2momLocked); 
		
		createAttach('Test Attach', obstacleList[0].Id);
		createNote('Test Note', obstacleList[0].Id, 'ths is a test note');
	}
	
	public static void genV2MOMPresentation()
	{

		v2momUnlocked = createV2MOM('Test V2MOM 2', 'Department', 'FY08', 'Test 2', 'My Management Hierarchy', 'Not Submitted', false);
		valueForUnlocked = createValue('test value', 'test value tag line 2', 1, v2momUnlocked.Id);
		
		
		/*
		* ADD METHODS TO THE LIST AND UPSERT
		*/
		addMethod(methodForUnlocked, 'test method 2', 'test method tag line 2', 1, v2momUnlocked.Id, null);
        addMethod(methodForUnlocked3, 'test method 3', 'test method tag line 2', 1, v2momUnlocked.Id, null);
        addMethod(methodForUnlocked4, 'test method 4', 'test method tag line 2', 1, v2momUnlocked.Id, null);
        addMethod(methodForUnlocked5, 'test method 5', 'test method tag line 2', 1, v2momUnlocked.Id, null);
        addMethod(methodForUnlocked6, 'test method 6', 'test method tag line 2', 1, v2momUnlocked.Id, null);
        
        upsert(methodList);
        
        /*
		* ADD METRICS TO THE LIST AND UPSERT
		*/
        addMetric(metricForUnlocked, 'test metric 3', 'test metric tag line 3', 1, v2momUnlocked.Id, null, null);
        addMetric(metricForUnlocked4, 'test metric 4', 'test metric tag line 4', 1, v2momUnlocked.Id, null, null);
        addMetric(metricForUnlocked5, 'test metric 5', 'test metric tag line 5', 1, v2momUnlocked.Id, null, null);
        addMetric(metricForUnlocked6, 'test metric 6', 'test metric tag line 6', 1, v2momUnlocked.Id, null, null);
        addMetric(metricForUnlocked7, 'test metric 7', 'test metric tag line 7', 1, v2momUnlocked.Id, null, null);
        
        upsert(metricList);
        
        /*
		* ADD OBSTACLES TO THE LIST AND UPSERT
		*/
        addObstacle(obstacleForUnlocked, 'test obstacle tag line 3', 1, v2momUnlocked.Id, null, null);
        addObstacle(obstacleForUnlocked4, 'test obstacle tag line 4', 1, v2momUnlocked.Id, null, null);
        addObstacle(obstacleForUnlocked5, 'test obstacle tag line 5', 1, v2momUnlocked.Id, null, null);
        addObstacle(obstacleForUnlocked6, 'test obstacle tag line 6', 1, v2momUnlocked.Id, null, null);
        addObstacle(obstacleForUnlocked7, 'test obstacle tag line 7', 1, v2momUnlocked.Id, null, null);
    
    	upsert(obstacleList);
       
	}

	public static void genV2MOMUtil ()
	{
		v2momLocked = createV2MOM('Test V2MOM', 'Department', 'FY08', 'Test', 'My Management Hierarchy', 'Approved', false);
		v2momUnlocked = createV2MOM('Test V2MOM 2', 'Department', 'FY08', 'Test 2', 'My Management Hierarchy', 'Pending Approval', false);
		v2momNoValue = createV2MOM('Test V2MOM 3', 'Department', 'FY08', 'Test 3', 'My Management Hierarchy', 'Rejected', false);
		
		valueForLocked = createValue('test value', 'test value tag line 1', 1, v2momLocked.Id);
		valueForUnlocked = createValue('test value', 'test value tag line 2', 2, v2momUnlocked.Id);
		
		/*
		* ADD METHODS TO THE LIST AND UPSERT
		*/
		addMethod(methodForLocked, 'test method', 'test method tag line 1', 1, v2momLocked.Id, null);
		addMethod(methodForLocked2, 'test method 3', 'test method tag line 3', 1, v2momLocked.Id, null);
		addMethod(methodForUnlocked, 'test method 2', 'test method tag line 2', 1, v2momUnlocked.Id, null);
		
		upsert(methodList);
		
		/*
		* ADD METRICS TO THE LIST AND UPSERT
		*/
		addMetric(metricForLocked, 'test metric 1', 'test metric tag line 1', 1, v2momLocked.Id, null, null);
		addMetric(metricForLocked2, 'test metric 2', 'test metric tag line 2', 1, v2momLocked.Id, null, null);
		addMetric(metricForUnlocked, 'test metric 3', 'test metric tag line 3', 1, v2momUnlocked.Id, null, null);
		
		upsert(metricList);
		
		/*
		* ADD OBSTACLES TO THE LIST AND UPSERT
		*/	        
		addObstacle(obstacleForLocked, 'test obstacle tag line 1', 1, v2momLocked.Id, null, null);
		addObstacle(obstacleForLocked2, 'test obstacle tag line 2', 1, v2momLocked.Id, null, null);
		addObstacle(obstacleForUnlocked, 'test obstacle tag line 3', 1, v2momUnlocked.Id, null, null);
		
		upsert(obstacleList);
		
		lockV2MOM(v2momLocked);
		
		v2momListUnLocked.add(v2momLocked);
		v2momListUnLocked.add(v2momUnlocked);
		v2momListUnLocked.add(v2momNoValue); 
		
		valueList.add(valueForLocked);
		valueList.add(valueForUnlocked);
		
		v2momListLocked.add(createV2MOM('Test V2MOM 4', 'Department', 'FY08', 'Test 4', 'My Management Hierarchy', 'Approved', true));
		v2momListLocked.add(createV2MOM('Test V2MOM 5', 'Department', 'FY08', 'Test 5', 'My Management Hierarchy', 'Pending Approval', true));
		v2momListLocked.add(createV2MOM('Test V2MOM 6', 'Department', 'FY08', 'Test 6', 'My Management Hierarchy', 'Pending Approval', true)); 
		
	}
	
	
	/***************************************************************************************
	**************************** GENERATE PERFORMANCE REVIEW *******************************
	***************************************************************************************/
	public static void genPerformanceReview(){
		getUsers();
		department = createDepartment('Test Department', false);
		reviewFormTemplate = createReviewFromTemplate();
		competencyGroup = createCompetencyGroup();
		competency1 = createCompetency('Test Competency 1', 'New competency test 1');
		Date d1 = System.today();
		Date d2 = d1.addYears(1);
		v2momIndividual = createV2MOM('Test V2MOM 4', 'Individual', 'FY08', 'Test 4', 'My Management Hierarchy', 'Approved', true);		
		PRPIndividual = createPRP('Test PRP Department', 'FY08', 'Individual', d1, d2);
		
		System.debug('\n\n\n v2mom  ' + v2momIndividual);
		System.debug('\n\n\n PRPIndividual  ' + PRPIndividual);
		System.debug('\n\n\n competencyGroup  ' + competencyGroup);
		System.debug('\n\n\n reviewFormTemplate  ' + reviewFormTemplate);
		System.debug('\n\n\n department  ' + department);
		PRIndividual = createPerformanceReview('Test PReview Individual', PRPIndividual.Id,
											 v2momIndividual.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 employeeStandard.Id, reviewManagerStandard.Id, review2ndManagerStandard.Id, 
											 pcommStandard.Id, managerSupport.Id, department.Id, 'Created');
	}


	public static void genPerformanceReviewYearEnd(){
		getUsers();
		
		department = createDepartment('Test Department for YearEnd', false);
		reviewFormTemplate = createReviewFromTemplate();
		competencyGroup = createCompetencyGroup();
		competency1 = createCompetency('Test Competency 1', 'New competency test 1');
		Date d1 = System.today();
		Date d2 = d1.addYears(1);
		try{
			v2momIndividual = [Select v.V2MOM_Type__c, v.Name, v.Id, v.Effective_Date__c From V2MOM__c v Where v.V2MOM_Type__c =: 'Individual' And v.Effective_Date__c =: 'FY12' limit 1];
		}catch(Exception e){
			System.debug('GenerateEnvironmentTest1 v2momIndividual does not exist');
		}
		
		if (v2momIndividual == null){
			v2momIndividual = createV2MOM('Test V2MOM For YearEnd', 'Individual', 'FY12', 'Test Year End', 'My Management Hierarchy', 'Approved', true);	
		}
				
		PRPIndividual = createPRP('Test PRP Department for YearEnd', 'FY12', 'Individual', d1, d2);
		
		System.debug('\n\n\n v2mom  ' + v2momIndividual);
		System.debug('\n\n\n PRPIndividual  ' + PRPIndividual);
		System.debug('\n\n\n competencyGroup  ' + competencyGroup);
		System.debug('\n\n\n reviewFormTemplate  ' + reviewFormTemplate);
		System.debug('\n\n\n department  ' + department);
		PRYearEnd = createPerformanceReview('Test PerformanceReview for Year end', PRPIndividual.Id,
											 v2momIndividual.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 employeeStandard.Id, reviewManagerStandard.Id, review2ndManagerStandard.Id, 
											 pcommStandard.Id, managerSupport.Id, department.Id, 'Created');
											 
		PRYearEND.PreviousStatus__c = '';
	}

	//duplicating the function to only affect the calibration controller test that use it
	public static void genPerformanceReviewYearEnd2(){
		getUsers();
		
		department = createDepartment('Test Department for YearEnd', false);
		reviewFormTemplate = createReviewFromTemplate();
		competencyGroup = createCompetencyGroup();
		competency1 = createCompetency('Test Competency 1', 'New competency test 1');
		Date d1 = System.today();
		Date d2 = d1.addYears(1);
		try{
			v2momIndividual = [Select v.V2MOM_Type__c, v.Name, v.Id, v.Effective_Date__c From V2MOM__c v Where v.V2MOM_Type__c =: 'Individual' And v.Effective_Date__c =: 'FY12' limit 1];
		}catch(Exception e){
			System.debug('GenerateEnvironmentTest1 v2momIndividual does not exist');
		}
		
		if (v2momIndividual == null){
			v2momIndividual = createV2MOM('Test V2MOM For YearEnd', 'Individual', 'FY12', 'Test Year End', 'My Management Hierarchy', 'Approved', true);	
		}
				
		PRPIndividual = createPRP('Test PRP Department for YearEnd', 'FY12', 'Individual', d1, d2);
		
		System.debug('\n\n\n v2mom  ' + v2momIndividual);
		System.debug('\n\n\n PRPIndividual  ' + PRPIndividual);
		System.debug('\n\n\n competencyGroup  ' + competencyGroup);
		System.debug('\n\n\n reviewFormTemplate  ' + reviewFormTemplate);
		System.debug('\n\n\n department  ' + department);
		PRYearEnd = new PerformanceReview__c(Name = 'Test PerformanceReview for Year end',
														   PerformanceReviewPeriod__c = PRPIndividual.Id,
														   V2MOM__c = v2momIndividual.Id,
														   CompetencyGroup__c = competencyGroup.Id,
														   ReviewFormTemplate__c = reviewFormTemplate.Id,
														   Employee__c = employeeStandard.Id,
														   Manager__c = reviewManagerStandard.Id,
														   SecondManager__c = review2ndManagerStandard.Id,
														   PCOMM__c = pcommStandard.Id,
														   Department__c = department.Id,
														   Status__c = 'Created',
														   ThirdPartyReviewer__c = managerSupport.Id);
		
		System.runAs(GenerateEnvironmentTest.getSystemAdmin()  ){
			insert(PRYearEnd);	
		}									 
		
		PRYearEND.PreviousStatus__c = '';
	}


	public static PerformanceReview__c genPerformanceReviewAdHoc(){
		getUsers();
		
		department = createDepartment('Test Department for YearEnd', false);
		reviewFormTemplate = createReviewFromTemplate();
		competencyGroup = createCompetencyGroup();
		competency1 = createCompetency('Test Competency 1', 'New competency test 1');
		Date d1 = System.today();
		Date d2 = d1.addYears(1);
		
		v2momIndividual = createV2MOM('Test AdHoc V2MOM', 'Ad Hoc', 'FY12', 'Ad Hoc vision', 'My Management Hierarchy', 'Approved', true);	
		
				
		PerformanceReviewPeriod__c PRPAdHoc = createPRP('Test PRP Department for Ad Hoc', 'FY12', 'Ad Hoc', d1, d2);
		
		System.debug('\n\n\n v2mom  ' + v2momIndividual);
		System.debug('\n\n\n PRPAdHoc ' + PRPAdHoc);
		System.debug('\n\n\n competencyGroup  ' + competencyGroup);
		System.debug('\n\n\n reviewFormTemplate  ' + reviewFormTemplate);
		System.debug('\n\n\n department  ' + department);
		PerformanceReview__c PRAdHoc = new PerformanceReview__c(Name = 'Test PerformanceReview for Year end',
														   PerformanceReviewPeriod__c = PRPAdHoc.Id,
														   V2MOM__c = v2momIndividual.Id,
														   CompetencyGroup__c = competencyGroup.Id,
														   ReviewFormTemplate__c = reviewFormTemplate.Id,
														   Employee__c = employeeStandard.Id,
														   Manager__c = reviewManagerStandard.Id,
														   SecondManager__c = review2ndManagerStandard.Id,
														   PCOMM__c = pcommStandard.Id,
														   Department__c = department.Id,
														   Status__c = 'Created',
														   ThirdPartyReviewer__c = managerSupport.Id);
		
		System.runAs(GenerateEnvironmentTest.getSystemAdmin()  ){
			insert(PRAdHoc);	
		}									 
		
		PRAdHoc.PreviousStatus__c = '';
		return PRAdHoc;
	}



	public static V2MOM__c createV2MOM(String name, String t, String effectiveDate, String vision, String share, String status, boolean locked)
	{
		V2MOM__c v = new V2MOM__c();
		v.Name = name;
		v.V2MOM_Type__c = t;
		v.Effective_Date__c = effectiveDate;
		v.Vision__c = vision;
		v.Share_With__c = share;
		v.Status__c = status;
		v.Locked__c = locked;
		System.runAs(GenerateEnvironmentTest.getManager()){
			upsert(v);	
		}
		
		
		return v;
	}
	
	public static Value__c createValue(String name, String tagLine, Integer priority, Id id)
	{
		Value__c v = new Value__c();
		v.Name = name;
		v.Tag_Line__c = tagLine;
		v.Priority__c = priority;
		v.V2MOM__c = id;
		upsert(v);
		
		return v;
	}
	
	
	public static V2MOM__c lockV2MOM (V2MOM__c v2moms)
	{
		v2moms.Locked__c = true;
		update v2moms;
		
		return v2moms;
	}
	
	
	public static void addMethod(Method__c m, String name, String description, Integer priority, Id id, Id valueId)
	{
		m = new Method__c();
		m.Name = name;
		m.Description__c = description;
		m.Priority__c = priority;
		if (valueId != null)
			m.Value__c = valueId;
		m.V2MOM__c = id;
		
		methodList.add(m);
	}
	
	public static void addMetric(Measure__c m, String name, String description, Integer priority, Id id, Id valueId, Id methodId)
	{
		m = new Measure__c();
		m.Description__c = description;
		m.Start_Date__c = System.today();
		m.End_Date__c = System.today().addYears(1);
		m.Priority__c = priority;
		if (valueId != null)
			m.Value__c = valueId;
		if (methodId != null)
			m.Method__c = methodId;
		m.V2MOM__c = id;
		
		metricList.add(m);
	}
	
	public static void addObstacle(Obstacle__c obs, String description, Integer priority, Id id, Id valueId, Id methodId)
	{
		obs = new Obstacle__c();
		obs.Description__c = description;
		obs.Priority__c = priority;
		if (valueId != null)
			obs.Value__c = valueId;
		if (methodId != null)
			obs.Method__c = methodId;
		obs.V2MOM__c = id;
		
		obstacleList.add(obs);
	}
	
	public static void createNote( String title, Id parentId, String body)
	{
		Note note = new Note();
		note.Title = title;
		note.ParentId = parentId;
		note.Body = body;
		
		upsert note;
		testNote = note;
	}
	
	public static void createAttach( String name, Id parentId)
	{
		Blob b = Blob.valueOf('Content');
		Attachment attach = new Attachment();
		attach.Name = name;
		attach.ParentId = parentId;
		attach.Body = b;
		
		upsert attach;
		testAttach = attach;
	}
	
/****************************************************************************************************************************
************************* METHODS FOR PERFORMANCE REVIEW ********************************************************************
****************************************************************************************************************************/	
	
	
	/*
	*Create Department
	*/
	public static Department__c createDepartment(String name, boolean excl){
			Department__c d = new Department__c();
			d.Name = name;
			d.ExcludeESBP__c = excl;
			System.runAs(GenerateEnvironmentTest.getManager()){
				upsert(d);	
			}
			
			return d;
	}
	
	/*
	*Create Competency Group
	*/
	public static CompetencyGroup__c createCompetencyGroup()
	{
		CompetencyGroup__c competencyGroupNew = new CompetencyGroup__c(Name = 'CCCompGrp', Code__c = 'CCCompGrp');
		System.runAs(GenerateEnvironmentTest.getManager()){
			upsert(competencyGroupNew);	
		}
				
		return competencyGroupNew;
	}
	
	/*
	*Create Competency Group Member
	*/
	public static CompetencyGroupMember__c createCompetencyGroupMember(String name, 
											Id comp, Id cg, Integer w){
			CompetencyGroupMember__c c = new CompetencyGroupMember__c();
			c.Name = name;
			c.CompetencyGroup__c = cg;
			c.Competency__c = comp;
			c.Weight__c = w;
			return c;
	}
	
	/*
	*Create Competency
	*/
	public static Competency__c createCompetency(String name, String d){
			Competency__c c = new Competency__c();
			c.Name = name;
			c.Description__c = d;
			System.runAs(GenerateEnvironmentTest.getManager()){
				upsert(c);	
			}
			
			return c;
	}
	
	/*
	*Create Review Form Template
	*/
	public static ReviewFormTemplate__c createReviewFromTemplate()
	{
		ReviewFormTemplate__c reviewFromTemplate = new ReviewFormTemplate__c(Name = 'CCRevTpl', Code__c = 'CCRevTpl');
		System.runAs(GenerateEnvironmentTest.getEmployeeStandard()){
			upsert(reviewFromTemplate);
		}
		
		
		return reviewFromTemplate;
	}
	
	/*
	*Create Performance Review Period
	*/
	public static PerformanceReviewPeriod__c createPRP(String pname, String effdate, String v2momType,
														Date sdate, Date edate){
		PerformanceReviewPeriod__c prp = new PerformanceReviewPeriod__c(Name = pname,
																		Effective_Date__c = effdate,
																		V2MOM_Type__c = v2momType,
																		StartDate__c = sdate,
																		EndDate__c = edate);
		return prp;
	}
	
	/*
	*Create Performance Review
	*/
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
														   Department__c = dpt,
														   Status__c = status,
														   ThirdPartyReviewer__c = thirdP);
		
		System.runAs(GenerateEnvironmentTest.getManager()){
			insert(pr);	
		}
		
		return pr;
	}
	
	public static void getUsers(){
        userList = [select id, username, Profile.Name from User 
                                                where username=:GenerateEnvironmentTestUsers.ccpcomm 
                                                or username=:GenerateEnvironmentTestUsers.ccesadmin
                                                
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
                                                ];
                                                
        pcommStandard = getUser(GenerateEnvironmentTestUsers.ccpcomm);
        esadminStandard = getUser(GenerateEnvironmentTestUsers.ccesadmin);
                                                
        employeeStandard = getUser(GenerateEnvironmentTestUsers.ccstndempl);
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