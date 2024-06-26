public class GenerateEnvironmentTest {
    
    /*
     * ENVIRONMENT TO TEST: Test_ReviewFormTemplateCls
     *                      Test_DepartmentEditController
     *                      Test_CompetencyGroupMemberDetail
     *                      Test_CompetencyGroupDetailController
     *                      Test_ValueAfterTrig
     *                      Test_scorecardSupportReviewAfterInsert
     *                      Test_V2momPrioritizeController
     *                      Test_V2MOMCloneController    
     *                      Test_V2MOM_Prioritization_Controller_AW
    */

    //public static Department__c department;
    public static TF2_Department__c department;
    
    public static CompetencyGroup__c competencyGroup;
    public static Competency__c competency;
    public static Competency__c competency1;
    public static CompetencyGroupMember__c competencyGroupMember;
    public static CompetencyReview__c competencyReview;
    
    public static User pcommStandard;
    public static User esadminStandard;
    
    public static User secondManager;
    public static User pcommUser;
    
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

    
    public static V2MOM__c v2momAdHoc;
    public static V2MOM__c v2momIndividual;
    public static V2MOM__c v2momIndividualQ1Q2;
    public static V2MOM__c v2momIndividualQ3Q4;
    public static V2MOM__c v2momDepartment;
    public static V2MOM__c v2momOnboarding;
    public static V2MOM__c v2momOrganization;
    
    public static Value__c value1;
    public static Value__c value2;
    public static Value__c value3;

    public static Method__c method1;
    public static Method__c method2;
    public static Method__c method3;

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

    public static ScorecardSupportReview__c sQ1;
    public static ScorecardSupportReview__c sQ2;
    public static ScorecardSupportReview__c sQ3;
    public static ScorecardSupportReview__c sQ4;
    
    public static List<Method__c> methodList = new List<Method__c>();
	public static List<Measure__c> metricList = new List<Measure__c>();
	public static List<Obstacle__c> obstacleList = new List<Obstacle__c>();
    
    public static List<Profile> profList;
    public static List<User> userList;

    public static void genDepartmentTest(){
        try {
            department = createDepartment('Test Department', false);
        } catch (Exception e) {
            System.debug(' ****************** genDepartmentTest * ');
            System.debug(e.getMessage());
        }
    }

    public static void genReviewFormTemplateTest(){
        try {
            reviewFormTemplate = [select Id from ReviewFormTemplate__c where Name = 'CCRevTpl' and Code__c='CCRevTpl'];
        } catch (Exception e) {
            System.debug(' ****************** genReviewFormTemplateTest * ');
            System.debug(e.getMessage());
        }
    }
        
    public static void genCompGroupTest(){
        try {
            competency = createCompetency('Test Competency', 'New competency test');
            competency1 = createCompetency('Test Competency', 'New competency test');
            
            competencyGroup = createCompetencyGroup('Test Competency Group', 'Test CG');
            
            getUsers();
            getUser('');
        } catch (Exception e) {
            System.debug(' ****************** genCompGroupTest * ');
            System.debug(e.getMessage());
        }
    }

    public static void genV2MOMPrioritize(){
        try {
            getUsers();
            createV2MOMIndividualData();
        } catch (Exception e) {
            System.debug(' ****************** genV2MOMPrioritize * ');
            System.debug(e.getMessage());
        }
        
    }


    public static void genV2MOMLocked(){
        try {
            getUsers();
            createV2MOMIndividualDataLocked();
        } catch (Exception e) {
            System.debug(' ****************** genV2MOMLocked * ');
            System.debug(e.getMessage());
        }
        
    }

    public static void genAfterTrig(){
        try {
            getUsers();
            createV2MOMIndividualDataAfterTrig();
        } catch (Exception e) {
            System.debug(' ****************** genAfterTrig * ');
            System.debug(e.getMessage());
        }
        
    }

    public static void genScorecardSupportReviewAfterInsert(){
        try {
            getUsers();
            createV2MOMIndividualData();
            //createV2MOMIndividualQ1Q2Data(true);
            department = createDepartment('Test Department', false);
            
            Date d1 = System.today();
            Date d2 = d1.addYears(1);
            
            PRPIndividual = createPRP('Test PRP Individual', 'FY08', 'Individual', d1, d2);
            
            //competencyGroup = [select Id from CompetencyGroup__c where Name = 'CCCompGrp' and Code__c='CCCompGrp'];
            
            //reviewFormTemplate = [select Id from ReviewFormTemplate__c where Name = 'CCRevTpl' and Code__c='CCRevTpl'];
    
            competencyGroup = createCompetencyGroup();
            competency1 = createCompetency('competency1', 'test competency');
            competencyGroupMember = createCompetencyGroupMember('compGroupMember', competencyGroup.Code__c, competency1.Id, competencyGroup.Id, 20);
            
            reviewFormTemplate = createReviewFromTemplate();
            
            System.debug('Pass01');
            PRCreated = createPReviewNormal('Test PReview', 
                                        PRPIndividual.Id, 
                                        v2momIndividual.Id, 
                                        competencyGroup.Id,
                                        reviewFormTemplate.Id,
                                        employeeStandard.Id,
                                        reviewManagerStandard.Id, 
                                        review2ndManagerStandard.Id,
                                        pcommStandard.Id,
                                        department.Id);
            System.debug('Pass02');
            System.debug(reviewManagerStandard.Id);
            System.debug(PRCreated.Id);
            competencyReview = createCompetencyReview(PRCreated.Employee__c, PRCreated.Id, 'competency Review', competencyGroupMember.Id, 'this is my comment');
            sq1 = createScorecardSupportReview('Test Scorecard Q1 28.11.2008', PRCreated.Id, reviewManagerStandard.Id, 'Q1');
            System.debug('Pass03');
            sq2 = createScorecardSupportReview('Test Scorecard Q2 28.11.2008', PRCreated.Id, reviewManagerStandard.Id, 'Q2');
            sq3 = createScorecardSupportReview('Test Scorecard Q3 28.11.2008', PRCreated.Id, reviewManagerStandard.Id, 'Q3');
            sq4 = createScorecardSupportReview('Test Scorecard Q4 28.11.2008', PRCreated.Id, reviewManagerStandard.Id, 'Q4');
                
        } catch (Exception e) {
            System.debug(' ****************** genScorecardSupportReviewAfterInsert * ');
            System.debug(e.getMessage());
        }
    }

    public static void createV2MOMIndividualData(){
        v2momIndividual = createV2MOM(employeeStandard.Id, 'vision individual', 'Individual', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
        v2momDepartment = createV2MOM(employeeStandard.Id, 'vision Department', 'Department', 'Test V2MOM Department', 'FY08', 'My Management Hierarchy');
        v2momOnboarding = createV2MOM(employeeStandard.Id, 'vision Onboarding', 'Onboarding', 'Test V2MOM Onboarding', 'FY08', 'My Management Hierarchy');
        v2momOrganization = createV2MOM(employeeStandard.Id, 'vision Organization', 'Organization', 'Test V2MOM Organization', 'FY08', 'My Management Hierarchy');
       
        
        value1 = createValue(v2momIndividual.Id, 1, 'Value 1');
        value2 = createValue(v2momIndividual.Id, 2, 'Value 2');
        
        System.debug('ValuesCreated');
       
        addMethod(method1, v2momIndividual.Id, value1.Id, 1, 'Method 1', 'Description method 1');
        addMethod(method2, v2momIndividual.Id, value1.Id, 2, 'Method 2', 'Description method 2');
        addMethod(method3, v2momIndividual.Id, value1.Id, 3, 'Method 3', 'Description method 3');
    	
    	System.debug('The method list ' + methodList );
    	 System.debug('UpsertMethods ' + method1);
        insert(methodList);
        
        method1 = methodList[0];
        method2 = methodList[1];
        method3 = methodList[2];
       
        
        addObstacle(obstacle1, v2momIndividual.Id, null, null, 1, 'Description obstacle 1');
        addObstacle(obstacle2, v2momIndividual.Id, null, null, 2, 'Description obstacle 2');
		
		upsert(obstacleList);
		
		obstacle1 = obstacleList[0];
		obstacle2 = obstacleList[1];
		
		
		System.debug('UpsertObstacles');
		
        Date d = System.today();
        
        addMetric(measure1, v2momIndividual.Id, null, null, 1, 'Description measure 1', d, d);
        addMetric(measure2, v2momIndividual.Id, null, null, 2, 'Description measure 2', d, d);
        
        upsert(metricList);
        
        measure1 = metricList[0];
        measure2 = metricList[1];
        
        System.debug('FinishedMetricss');
    }

    public static void createV2MOMIndividualDataLocked(){
        v2momIndividual = createV2MOM(employeeStandard.Id, 'vision individual', 'Individual', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
        
        value1 = createValue(v2momIndividual.Id, 1, 'Value 1');
        
        addMethod(method1, v2momIndividual.Id, value1.Id, 1, 'Method 1', 'Description method 1');
        upsert(methodList);
        
        addObstacle(obstacle1, v2momIndividual.Id, null, null, 1, 'Description obstacle 1');
		upsert(obstacleList);
		
        Date d = System.today();
        
        addMetric(measure1, v2momIndividual.Id, null, null, 1, 'Description measure 1', d, d);        
        upsert(metricList);
        
        v2momIndividual.Locked__c = true;
        
        update v2momIndividual;
    }
    
    public static User getManager(){
    		try{
    			manager = [Select Id, Name From User Where userName =: 'test__manager@test.com' limit 1];	
    		}catch(Exception e){
    			System.debug('Error: ' + e.getMessage());
    		}
						
			if(manager == null){
				Profile p = [Select Id From Profile where Name =: 'Manager'];
				manager =  new User(username='test__manager@test.com',
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
    public static User getSecondManager(){
    	try{
    		secondManager = [Select Id, Name From User Where userName =: 'testSecManager@test.com'];
    	}catch(Exception e){
    		System.debug('Error: ' + e.getMessage());
    	}
    	
    	if(secondManager == null){
    		Profile p = [Select Id From Profile Where Name =: 'Manager'];
    		secondManager = new User(userName = 'testSecManager@test.com',
    									lastName = 'manager',
										email = 'secManagertest1@mailinator.com',
										alias = 'smtest',
										timeZoneSidKey ='America/Los_Angeles',
										manager__c = getSystemAdmin().Id,
										localeSidKey = 'en_US',
										emailEncodingKey = 'ISO-8859-1',
										LanguagelocaleKey = 'en_US',
										ProfileId = p.Id
									);
    		/* Run As Admin */
			system.runAs( getSystemAdmin()){
				insert secondManager;	
			}								
    								
    	}
    	return secondManager; 
    }
    
    public static User getPCOMMUser(){
    	try{
    		pcommUser = [Select Id, Name From User Where userName =: 'testpcUser@test.com'];
    	}catch(Exception e){
    		System.debug('Error: ' + e.getMessage());
    	}
    	
    	if(pcommUser == null){
    		Profile p = [Select Id, Name From Profile Where Name =: 'PCOMM'];
    		pcommUser = new User(	userName = 'testpcUser@test.com',
    								lastName = 'manager',
									email = 'pcommtest1@mailinator.com',
									alias = 'pcmmtest',
									timeZoneSidKey ='America/Los_Angeles',
									manager__c = getSystemAdmin().Id,
									localeSidKey = 'en_US',
									emailEncodingKey = 'ISO-8859-1',
									LanguagelocaleKey = 'en_US',
									ProfileId = p.Id
									);
    		/* Run As Review Employee */
			system.runAs(getSecondManager()){
				insert pcommUser;	
			}	
    	}
    	
    	return pcommUser;
    }
    public static User getEmployeeStandard(){
    	try{
    		employeeStandard = [Select Id, Name From User Where userName =: 'testStandardemp@test.com'];	
    	}catch(Exception e){
    		System.debug('Error: ' + e.getMessage());
    	}
    	Profile p = [Select Id From Profile where Name =: 'Employee'];
    	
    	if(employeeStandard == null){
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
				
    	}
		return employeeStandard;									
    }
    
    public static User getSystemAdmin(){
		Profile p = [Select Id From Profile where Name =: 'System Administrator'];
		User adminUser = [Select id From User Where ProfileID =: p.Id And IsActive =: True limit 1][0];
		return adminUser; 
	}	 
    
    public static void createV2MOMIndividualDataAfterTrig(){
        v2momIndividual = createV2MOM(employeeSupport.Id, 'vision individual', 'Individual Q1/Q2', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
        
        value1 = createValue(v2momIndividual.Id, 1, 'Value 1');
        value2 = createValue(v2momIndividual.Id, 2, 'Value 2');
        
        addMethod(method1, v2momIndividual.Id, value1.Id, 1, 'Method 1', 'Description method 1');
        addMethod(method2, v2momIndividual.Id, value1.Id, 2, 'Method 2', 'Description method 2');
        
        upsert(methodList);
        
        addObstacle(obstacle1, v2momIndividual.Id, value1.Id, method1.Id, 1, 'Description obstacle 1');
        addObstacle(obstacle2, v2momIndividual.Id, value1.Id, method1.Id, 2, 'Description obstacle 2');
		
		upsert(obstacleList);

        Date d = System.today();
        
        addMetric(measure1, v2momIndividual.Id, value1.Id, method1.Id, 1, 'Description measure 1', d, d);
        addMetric(measure2, v2momIndividual.Id, value1.Id, method1.Id, 2, 'Description measure 2', d, d);
        
        upsert(metricList);
      
    }

    public static void createV2MOMDetailController () {
        getUsers();
        
        
        v2momIndividual = createV2MOM(employeeSupport.Id, 'vision individual', 'Individual', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
        v2momDepartment = createV2MOM(employeeStandard.Id, 'vision Department', 'Ad Hoc', 'Test V2MOM Department', 'FY08', 'My Management Hierarchy');
    
    }

    public static void getUsers(){
        userList = [select id, username, start_Date__c, Profile.Name from User 
                                                where (username=:GenerateEnvironmentTestUsers.ccpcomm 
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
                                                or username=:GenerateEnvironmentTestUsers.cceduempl)
                                                
                                                ];
                                                
        pcommStandard = getUser(GenerateEnvironmentTestUsers.ccpcomm);
        esadminStandard = getUser(GenerateEnvironmentTestUsers.ccesadmin);
                                                
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
    }

    public static User getUser(String oname){
        for (User u : userList){
            if (u.username.equals(oname)){
                return u;
            }
        }
        return null;
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
		
		upsert s;
		
		return s;		
	}

    public static PerformanceReview__c createPReviewNormal(String pname, 
                                                        Id prp,
                                                        Id v2mom,
                                                        Id cgrp,
                                                        Id rftpl,
                                                        Id empl,
                                                        Id mngr,
                                                        Id sndMngr,
                                                        Id pcomm,
                                                        Id dpt){
                                                            
        PerformanceReview__c pr = new PerformanceReview__c(Name = pname,
                                                        PerformanceReviewPeriod__c = prp,
                                                        V2MOM__c = v2mom,
                                                        CompetencyGroup__c = cgrp,
                                                        ReviewFormTemplate__c = rftpl,
                                                        Employee__c = empl,
                                                        Manager__c = mngr,
                                                        SecondManager__c = sndMngr,
                                                        PCOMM__c = pcomm,
                                                        Cost_Center__c = dpt,
                                                        Status__c = 'Created');
                                                        //Department__c = dpt,
                                                                        
        upsert(pr);
        
        return pr;
    }

    public static PerformanceReviewPeriod__c createPRP(String pname, String effdate, String v2momType,
                                                        Date sdate, Date edate){
        PerformanceReviewPeriod__c prp = new PerformanceReviewPeriod__c(Name = pname,
                                                                        Effective_Date__c = effdate,
                                                                        V2MOM_Type__c = v2momType,
                                                                        StartDate__c = sdate,
                                                                        EndDate__c = edate);
                                                                        
        upsert(prp);
        
        return prp;
    }
    
    public static ScorecardSupportReview__c createScorecardSupportReview(String pname, 
                                                                        Id pr,
                                                                        Id reviewer,
                                                                        String fq){
        ScorecardSupportReview__c s = new ScorecardSupportReview__c (Name = pname,
                                                                    PerformanceReview__c = pr,
                                                                    Reviewer__c = reviewer,
                                                                    FiscalQuarter__c = fq);
        upsert(s);
        
        return s;
    }
    
    public static V2MOM__c createV2MOM(Id user, String vision, String t, String name, 
                                        String effDate, String share){
        V2MOM__c v2mom = new V2MOM__c ( OwnerId=user,
                                        Vision__c = vision, 
                                        V2MOM_Type__c = t,
                                        Name = name, 
                                        Effective_Date__c = effDate,
                                        Share_With__c = share);
        try{
        	upsert(v2mom);	
        }catch(Exception e){
        	
        }
        
        
        return v2mom;
    }
    
    public static Value__c createValue(Id v2mom, Integer p, String name){
        Value__c value = new Value__c ( V2MOM__c = v2mom, 
                                            Priority__c = p, 
                                            Name = name);
        try{
        	upsert(value);	
        }catch(Exception e){
        	
        }
        
        
        return value;
    }
	
    
    public static void addMethod(Method__c m, Id v2mom, Id value, Integer p, String name, String d){
    	m = new Method__c();
    	m.V2MOM__c = v2mom;
        m.Value__c = value;
        m.Priority__c = p; 
        m.Name = name;
        m.Description__c = d;
    	
    	methodList.add(m);
    }
    
    public static void addMetric(Measure__c m, Id v2mom, Id value, Id method, Integer p, String d, Date startDate, Date endDate){
    	m = new Measure__c();
    	m.V2MOM__c = v2mom; 
        m.Method__c = method;
        m.Value__c = value;
        m.Priority__c = p; 
        m.Description__c = d;
        m.Start_Date__c = startDate;
        m.End_Date__c = endDate;
        
        metricList.add(m);
    }
    
    public static void addObstacle(Obstacle__c o, Id v2mom, Id value, Id method, Integer p, String d){
    	o = new Obstacle__c();
    	o.V2MOM__c = v2mom; 
        o.Method__c = method;
        o.Value__c = value;
        o.Priority__c = p;
        o.Description__c = d;
    	
    	obstacleList.add(o);
    }
    
    //public static Department__c createDepartment(String name, boolean excl){
    public static TF2_Department__c createDepartment(String name, boolean excl){
            //Department__c d = new Department__c();
            TF2_Department__c d = new TF2_Department__c();
            d.Name = name;
            d.Exclude_ESBP__c= excl;
            try{
            	upsert(d);	
            }catch(Exception e){
            	
            }
            
            return d;
    }
    
    public static CompetencyGroup__c createCompetencyGroup(String name, String code){
            CompetencyGroup__c c = new CompetencyGroup__c();
            c.Name = name;
            c.Code__c = code;
            try{
            	upsert(c);	
            }catch(Exception e){}
            
            return c;
    }
    
    public static CompetencyGroupMember__c createCompetencyGroupMember(String name, 
                                            String code, Id comp, 
                                            Id cg, Integer w){
            CompetencyGroupMember__c c = new CompetencyGroupMember__c();
            c.Name = name;
            c.CompetencyGroup__c = cg;
            c.Competency__c = comp;
            c.Weight__c = w;
            try{
            	upsert(c);	
            }catch(Exception e){}
            
            return c;
    }
    
    public static Competency__c createCompetency(String name, String d){
            Competency__c c = new Competency__c();
            c.Name = name;
            c.Description__c = d;
            try{
            	upsert(c);	
            }catch(Exception e){}
            
            return c;
    }
    
    public static CompetencyGroup__c createCompetencyGroup()
    {
        CompetencyGroup__c competencyGroupNew = new CompetencyGroup__c(Name = 'CCCompGrp', Code__c = 'CCCompGrp');
        try{
        	upsert(competencyGroupNew);	
        }catch(Exception e){}
        	
        
        return competencyGroupNew;
    }
    
    public static CompetencyReview__c createCompetencyReview(Id reviewer, Id performanceReview, String name, Id competencyGroupMemberNew, String comment){
    	CompetencyReview__c c = new CompetencyReview__c();
    	c.Reviewer__c = reviewer;
    	c.PerformanceReview__c = performanceReview;
    	c.CompetencyGroupMember__c = competencyGroupMemberNew;
    	c.Comment__c = comment; 
    	try{
    		upsert c;	
    	}catch(Exception e){}
    	
    	return c; 
    }
      
    public static ReviewFormTemplate__c createReviewFromTemplate()
    {
        ReviewFormTemplate__c reviewFromTemplate = new ReviewFormTemplate__c(Name = 'CCRevTpl', Code__c = 'CCRevTpl');
        try{
        	upsert(reviewFromTemplate);	
        }catch(Exception e){}
        
        
        return reviewFromTemplate;
    }
    
    
    public static ReviewFormTemplate__c createReviewFromTemplate(String rftName, String rftCode)
    {
        ReviewFormTemplate__c reviewFromTemplate = new ReviewFormTemplate__c(Name = rftName, Code__c = rftCode);
        try{
        	upsert(reviewFromTemplate);	
        }catch(Exception e){}
        
        
        return reviewFromTemplate;
    }
    
     public static ReviewFormTemplate__c createReviewFromTemplate(String rftName, String rftCode, Double methodW, Double competencyW)
    {
        ReviewFormTemplate__c reviewFromTemplate = new ReviewFormTemplate__c(Name = rftName, Code__c = rftCode, MethodWeight__c = methodW, CompetencyWeight__c = competencyW );
        try{
        	upsert(reviewFromTemplate);	
        }catch(Exception e){}
        
        
        return reviewFromTemplate;
    }
    
    public static void updateReviewFormTemplate(ReviewFormTemplate__c rft){
    	try{
    		upsert rft;
    	}catch(Exception e){
    		
    	}
    }
    
    public static void updateUser(User u){
    	try{
    		system.runAs( getSystemAdmin() ){
    			update u;
    		}
    	}catch(Exception e){
    	
    	}
    }
}