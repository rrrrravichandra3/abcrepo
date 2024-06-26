public class GenerateEnvironmentTest9 {
	/*
	 * ENVIRONMENT TO TEST: Test_ScorecardAdminConsultingUT
	 */
	
	public static Scorecard__c scorecardFY09;
	public static Scorecard__c scorecardFY08;
	public static Scorecard__c scorecardFY11;
	
	public static User employeeEducation;
	public static User managerEducation;
	public static User employeeSupport;
	public static User employeeConsulting;
	public static User managerConsulting;
	public static User employeeCSM;
	
	public static List<User> userList;
	
	public static void genScorecard() {
		try {
			getUsers();
			/*
			scorecardFY09 = new Scorecard__c(Department__c = Label.Consulting_label,
											Type__c = Label.Utilization_Target_label,
											EffectiveDate__c = 'FY10',
											Name = 'Test Scorecard 10',
											Rating__c = 1);
			*/								
			
			scorecardFY09 = new Scorecard__c(Cost_Center__c = Label.Consulting_label,
											Type__c = Label.Utilization_Target_label,
											EffectiveDate__c = 'FY10',
											Name = 'Test Scorecard 10',
											Rating__c = 1);
			
			upsert scorecardFY09;
			
			IndividualActualScorecard__c individualActual = new IndividualActualScorecard__c (Scorecard__c = scorecardFY09.Id,
																							Q1__c = 3,
																							Q2__c = 3,
																							Q3__c = 3,
																							Q4__c = 3);
			IndividualTargetScorecard__c individualTarget = new IndividualTargetScorecard__c (Scorecard__c = scorecardFY09.Id,
																							Employee__c = managerConsulting.Id,
																							Q1__c = 3,
																							Q2__c = 3,
																							Q3__c = 3,
																							Q4__c = 3);
			/*
			scorecardFY08 = new Scorecard__c(Department__c = Label.Consulting_label,
											Type__c = Label.Utilization_Target_label,
											EffectiveDate__c = 'FY08',
											Name = 'Test Scorecard 08',
											Rating__c = 1);
			*/
			scorecardFY08 = new Scorecard__c(Cost_Center__c = Label.Consulting_label,
											Type__c = Label.Utilization_Target_label,
											EffectiveDate__c = 'FY08',
											Name = 'Test Scorecard 08',
											Rating__c = 1);								
			upsert scorecardFY08;
			/*
			scorecardFY11 = new Scorecard__c(Department__c = Label.Consulting_label,
											Type__c = Label.Utilization_Target_label,
											EffectiveDate__c = 'FY11',
											Name = 'Test Scorecard 11',
											Rating__c = 1,
											Weight__c = 2);
			*/
			scorecardFY11 = new Scorecard__c(Cost_Center__c = Label.Consulting_label,
											Type__c = Label.Utilization_Target_label,
											EffectiveDate__c = 'FY11',
											Name = 'Test Scorecard 11',
											Rating__c = 1,
											Weight__c = 2);
											
			upsert scorecardFY11;
			
			IndividualActualScorecard__c individualActual2 = new IndividualActualScorecard__c (Scorecard__c = scorecardFY11.Id,
																							Q1__c = -1,
																							Q2__c = -1,
																							Q3__c = -1,
																							Q4__c = -1);
			IndividualTargetScorecard__c individualTarget2 = new IndividualTargetScorecard__c (Scorecard__c = scorecardFY11.Id,
																							Employee__c = employeeConsulting.Id,
																							Q1__c = -1,
																							Q2__c = -1,
																							Q3__c = -1,
																							Q4__c = -1);
		} catch (Exception e) {
            System.debug(' ****************** genScorecard * ');
            System.debug(e.getMessage());
		}
	}
		
	public static void getUsers() {
		userList = [select id, username, name, Profile.Name 
					from User 
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
						or username=:GenerateEnvironmentTestUsers.cccsmempl];
												
		employeeEducation = getUser(GenerateEnvironmentTestUsers.cceduempl);
		managerEducation = getUser(GenerateEnvironmentTestUsers.ccedumngr);	    
	    employeeSupport = getUser(GenerateEnvironmentTestUsers.ccsupempl);		
		employeeConsulting = getUser(GenerateEnvironmentTestUsers.ccconsempl);
		managerConsulting = getUser(GenerateEnvironmentTestUsers.ccconsmngr);
		employeeCSM = getUser(GenerateEnvironmentTestUsers.cccsmempl);
		
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