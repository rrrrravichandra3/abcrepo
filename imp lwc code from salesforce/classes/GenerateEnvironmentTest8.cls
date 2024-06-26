public class GenerateEnvironmentTest8 {
	
	/*
	 *	ENVIRONMENT TO TEST: Test_performanceReviewTrigger, 
	 *						 Test_ReviewSharing, 
	 *						 Test_ReviewRatingSharingManager
	*/
	
	
	//public static Department__c department;
	public static TF2_Department__c department;
	public static CompetencyGroup__c competencyGroup;
	
	/*
		USERS		
	*/
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
	public static User review2ndManagerSupport; // review manager of managerSuppor
	public static User consultingEmployee;
	public static User consultingManager;
	public static User consulting2ndManager;
	
	public static V2MOM__c v2momAdHoc;
	public static V2MOM__c v2momIndividualQ1Q2;
	public static Method__c method1;
	public static ReviewFormTemplate__c reviewFormTemplate;
	public static PerformanceReviewPeriod__c PRPAdHoc;
	public static PerformanceReviewPeriod__c PRPIndividualQ1Q2;
	public static PerformanceReview__c PRAdHoc;
	public static PerformanceReview__c PRAdHocDB;
	public static PerformanceReview__c PRIndividualQ1Q2;
	
	public static List<Profile> profList;
	public static List<User> userList;
	
	public static CompetencyReview__c competency1revEmpl;
	public static CompetencyReview__c competency1revMngr;
	
	public static MethodReview__c method1revEmpl;
	public static MethodReview__c method1revMngr;
	
	public static ReviewRating__c reviewRating;
	
	public static AdditionalComment__c overallrevEmpl;
	public static AdditionalComment__c overallrevMngr;
	
	public static CompetencyGroupMember__c competencyGroupMember1;
	public static Competency__c competency1;
	
	public static void genPerformanceReviewTriggers(){
		try {
			getUsers(); 
			v2momAdHoc = createV2MOM('Test V2MOM', 'Ad Hoc', 'FY08', 'Test', false);
			department = createDepartment('Test Ad Hoc', false);
			Date d1 = System.today();
			Date d2 = d1.addYears(1);
			PRPAdHoc = createPRP('Test PRP Ad Hoc', 'FY08', 'Ad Hoc', d1, d2);	
		//	competencyGroup = [select Id from CompetencyGroup__c where Name = 'CCCompGrp' and Code__c='CCCompGrp'];	
		//	reviewFormTemplate = [select Id from ReviewFormTemplate__c where Name = 'CCRevTpl' and Code__c='CCRevTpl'];
			competencyGroup = createCompetencyGroup();
			reviewFormTemplate = createReviewFromTemplate();
			PRAdHoc = createPerformanceReviewInMemory('Test PRAdHoc', PRPAdHoc.Id, v2momAdHoc.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 		employeeSupport.Id, reviewManagerSupport.Id, review2ndManagerSupport.Id, pcommStandard.Id, department.Id, 'Created');
			
			
			PRAdHocDB = createPerformanceReview('Test PRAdHoc', PRPAdHoc.Id, v2momAdHoc.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 		employeeSupport.Id, reviewManagerSupport.Id, review2ndManagerSupport.Id, pcommStandard.Id, department.Id, 'Created');
			
			reviewRating = createOverallRating('overall rating Mngr stnd', PRAdHoc.Id, 2.0, 3.2, reviewManagerStandard.Id);
		} catch (Exception e) {
            System.debug(' ****************** genPerformanceReviewTriggers * ');
            System.debug(e.getMessage());
		}
	}
	
	public static void genReviewSharing(){
		try {
			getUsers(); 
			v2momAdHoc = createV2MOM('Test V2MOM', 'Ad Hoc', 'FY08', 'Test', false);
			method1 = createMethod(v2momAdHoc.Id, null, 1, 'test Method', 'test description method 1');
			department = createDepartment('Test Ad Hoc', false);
			Date d1 = System.today();
			Date d2 = d1.addYears(1);
			PRPAdHoc = createPRP('Test PRP Ad Hoc', 'FY08', 'Ad Hoc', d1, d2);	
			//competencyGroup = [select Id from CompetencyGroup__c where Name = 'CCCompGrp' and Code__c='CCCompGrp'];	
			//reviewFormTemplate = [select Id from ReviewFormTemplate__c where Name = 'CCRevTpl' and Code__c='CCRevTpl'];
			
			competencyGroup = createCompetencyGroup();
			reviewFormTemplate = createReviewFromTemplate();
			
			PRAdHocDB = createPerformanceReview('Test PRAdHoc', PRPAdHoc.Id, v2momAdHoc.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 		employeeStandard.Id, reviewManagerStandard.Id, review2ndManagerStandard.Id, pcommStandard.Id, department.Id, 'Created');	
		
			method1revEmpl = createMethodReview('Method Review employee std method1', PRAdHocDB.Id, null, null,
												'In Progress', employeeStandard.Id, method1.Id,
												'comment method 1 employee standard');
			
			method1revMngr = createMethodReview('Method Review manager std method1', PRAdHocDB.Id, 2.0, 35,
												null, reviewManagerStandard.Id, method1.Id,
												'comment method 1 manager standard');
			
			competency1 = createCompetency('Test Competency 1', 'New competency test 1');
												
			competencyGroupMember1 = createCompetencyGroupMember('CCCompGrpMember1', competency1.Id, competencyGroup.Id, 30);									
			
			competency1revEmpl = createCompetencyReview('Competency Review employee std competency1', PRAdHocDB.Id, null,
												employeeStandard.Id, competencyGroupMember1.Id,
												'comment competency 1 employee standard');
			
			competency1revMngr = createCompetencyReview('Competency Review manager std competency1', PRAdHocDB.Id, 2.0,
												reviewManagerStandard.Id, competencyGroupMember1.Id,
												'comment competency 1 manager standard');
			
			overallrevEmpl = createOverallReview('overall review Empl stnd', PRAdHocDB.Id, '', '', '', '', 
													employeeStandard.Id, 'comment Empl stnd overall');
			
			reviewRating = createOverallRating('overall rating Mngr stnd', PRAdHocDB.Id, 2.0, 3.2, reviewManagerStandard.Id);
		
		
		} catch (Exception e) {
            System.debug(' ****************** genReviewSharing * ');
            System.debug(e.getMessage());
		}
	}
	
	
	public static void genScorecardReviewSharingManager(){
		try {
			getUsers(); 
			v2momIndividualQ1Q2 = createV2MOM2(employeeSupport.Id, 'Test V2MOM', 'Individual Q1/Q2', 'FY08', 'Test', false);
			department = createDepartment('Test trigger', false);
			Date d1 = System.today();
			Date d2 = d1.addYears(1);
			PRPIndividualQ1Q2 = createPRP('Test PRP individualQ1Q2', 'FY08', 'Individual Q1/Q2', d1, d2);	
			//competencyGroup = [select Id from CompetencyGroup__c where Name = 'CCCompGrp' and Code__c='CCCompGrp'];	
			//reviewFormTemplate = [select Id from ReviewFormTemplate__c where Name = 'CCRevTpl' and Code__c='CCRevTpl'];
			
			competencyGroup = createCompetencyGroup();
			reviewFormTemplate = createReviewFromTemplate();
			
			PRIndividualQ1Q2 = createPerformanceReview('Test PRIndividualQ1/Q2', PRPIndividualQ1Q2.Id, v2momIndividualQ1Q2.Id, competencyGroup.Id, reviewFormTemplate.Id,
											 		employeeSupport.Id, reviewManagerSupport.Id, review2ndManagerSupport.Id, pcommStandard.Id, department.Id, 'Created');
		} catch (Exception e) {
            System.debug(' ****************** genScorecardReviewSharingManager * ');
            System.debug(e.getMessage());
		}
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
	
	public static V2MOM__c createV2MOM2(Id owner, String name, String t, String effectiveDate, String vision, boolean locked){
		V2MOM__c v = new V2MOM__c();
		v.OwnerId = owner;
		v.Name = name;
		v.V2MOM_Type__c = t;
		v.Effective_Date__c = effectiveDate;
		v.Vision__c = vision;
		v.Locked__c = locked;
		upsert(v);
		return v;
	}
	//public static Department__c createDepartment(String name, boolean excl){
	public static TF2_Department__c createDepartment(String name, boolean excl){
			TF2_Department__c d = new TF2_Department__c();
			d.Name = name;
			d.Exclude_ESBP__c = excl;
			upsert(d);
			return d;
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
	public static PerformanceReview__c createPerformanceReviewInMemory(String pname, Id prp,Id v2, Id cgrp, Id rftpl,
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
																		
		//upsert(pr);
		
		return pr;
	}
	
	public static void getUsers(){
		userList = [select id, username, Profile.Name, ReviewManager__c from User 
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
												or username=: UserInfo.getUserName()
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

		consultingEmployee = getUser(GenerateEnvironmentTestUsers.ccconsempl);
		consultingManager = getUser(GenerateEnvironmentTestUsers.ccconsmngr);
		consulting2ndManager = getUser(GenerateEnvironmentTestUsers.cccons2ndmngr);
	}
	
	public static User getUser(String oname){ 
		for (User u : userList){
			if (u.username.equals(oname)){
				return u;
			}
		}
		return null;
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
		
		methodReview = new MethodReview__c(Weight__c = weight, 
											Status__c = status, 
											Reviewer__c = reviewer, 
											Rating__c = rating, 
											PerformanceReview__c = pr, 
											Method__c = method, 
											Comment__c = comment);
		upsert(methodReview);
		
		return methodReview;
	}
	
	public static CompetencyReview__c createCompetencyReview(String oname,
												Id pr,
												double rating,
												Id reviewer,
												Id cgm,
												String comment){
		
		CompetencyReview__c compReview;
		compReview = new CompetencyReview__c(Reviewer__c = reviewer, 
											Rating__c = rating, 
											PerformanceReview__c = pr, 
											CompetencyGroupMember__c = cgm, 
											Comment__c = comment);
		upsert(compReview);
		
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
		overallReview = new AdditionalComment__c(UpdateMethods__c = updtMeth, 
												SuggestionsCompetencies__c = suggComp, 
												SuggestionMethods__c = suggMeth, 
												Reviewer__c = reviewer, 
												PerformanceReview__c = pr, 
												Comment__c = comment, 
												CommentCompetencies__c = commComp);
		upsert(overallReview);
		
		return overallReview;
	}
	
	public static ReviewRating__c createOverallRating(String oname,
															Id pr,
															double orating,
															double crating,
															Id reviewer){
		
		ReviewRating__c overallRating;
		overallRating = new ReviewRating__c(Reviewer__c = reviewer, 
											PerformanceReview__c = pr, 
											OverallRating__c = orating,
											CalculatedRating__c = crating);
		upsert(overallRating);
		
		return overallRating;
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
	
	public static CompetencyGroupMember__c createCompetencyGroupMember(String name, 
											Id comp, Id cg, Integer w){
			CompetencyGroupMember__c c = new CompetencyGroupMember__c();
			c.Name = name;
			c.CompetencyGroup__c = cg;
			c.Competency__c = comp;
			c.Weight__c = w;
			upsert(c);
			return c;
	}
	
	public static Competency__c createCompetency(String name, String d){
			Competency__c c = new Competency__c();
			c.Name = name;
			c.Description__c = d;
			upsert(c);
			return c;
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
	
}