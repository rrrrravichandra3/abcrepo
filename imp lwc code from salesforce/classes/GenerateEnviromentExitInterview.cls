public class GenerateEnviromentExitInterview 
{

	private static ExitInterview__c exitInterview;
	private static ExitInterviewComment__c exitInterviewComment;
	private static ExitInterviewCommentContinue__c exitInterviewCommentContinue;
	private static List<User> userList;
	public static User employeeStandard;
	
	public ExitInterview__c getExitInterview()
	{
		return exitInterview;
	}
	
	public static ExitInterviewComment__c getExitInterviewComment()
	{
		return exitInterviewComment;	
	}
	
	public ExitInterviewCommentContinue__c getExitInterviewCommentContinue()
	{
		return exitInterviewCommentContinue;
	}
	
	public static void GenEnviroment()
	{
		getUsers();
		
		createExitInterview();
		createExitInterviewComment();
		createExitInterviewCommentContinue();
	}
	

	
	private static void createExitInterview()
	{
		User testEmployee = GenerateEnvironmentTest.getEmployeeStandard();
		
		exitInterview = new ExitInterview__c();
		exitInterview.Employee__c = testEmployee.id;
		exitInterview.Name = 'Exit Interview Object';
		exitInterview.HavePersonalV2MOM__c = 'Yes';
		exitInterview.Compensation__c = 'Compesentation';
		exitInterview.BenefitsNotAsGood__c = 'Not Good as'; 
		exitInterview.Benefits__c = 'Benefits';
		 exitInterview.CanFedbackBeeShared__c = 'Yes';
		 exitInterview.CareerDevelopmentOpportunities__c = 'Career Development';
		 exitInterview.CompensationNotGoodAs__c = 'Compensation not good as';
		 exitInterview.Compensattion__c = 'Compensattion__c';
		 exitInterview.CultureAtSalesforce__c = 'Culture at salesforce';
		 exitInterview.CurrentManager__c = 'Current Manager';
		 exitInterview.ExpectationsNotClosed__c = 'Expectation not closed';
		 exitInterview.Expectations__c = 'Expectations';
		 exitInterview.FrequencyMeetings__c = 'Frequency Meetings';
		 exitInterview.HireDate__c = System.today();
		 exitInterview.HowYouHeardOportunity__c = 'How you heard oportunity';
		 exitInterview.ItemsNotRankedAsFive__c = 'Items Not Ranked as Five';
		 exitInterview.LeavingReasonOther__c  = 'Leaving Reason Other';
		 exitInterview.LeavingReason__c = 'Leaving Reason';
		 exitInterview.ManagerCommunicateDepartmentV2MOM__c = 'Manager Communicate Department';
		 exitInterview.ManagerDoneDifferently__c = 'Manager Done Differently';
		 exitInterview.ManagerPerformanceExpectations__c = 'Manager Performance Expectations';
		 exitInterview.ManagersInterestSupport__c = 'Managers Interest Support';
		 exitInterview.MoraleOnYourTeam__c = 'Moral On Yout Team';
		 exitInterview.NewCompanyName__c = 'New Company Name';
		 exitInterview.NewRole__c = 'New Role';
		 exitInterview.OnboardingExperience__c = 'Onboarding Experience';
		 exitInterview.OverallWorkExperience__c = 'Overall Work Experience';
		 exitInterview.PerformanceMeasured__c = 'Performance Measured';
		 exitInterview.PositionOffer__c = 'Position Offer';
		 exitInterview.ReceivePerformanceReview__c = 'Yes';
		 exitInterview.RegularOneToOneWithManager__c = 'Yes';
		 exitInterview.RoleContributedCompany__c = 'Yes' ;
		 exitInterview.SalesforceStrengthsAndWeaknesse__c = 'Salesforce strengths'; 
		 exitInterview.SomethingToShare__c = 'No';
		 exitInterview.TerminationDate__c = System.today();
		 exitInterview.ThinkLeaving__c = 'Think Leaving';
		 exitInterview.ValueAndEffectiveness__c = 'Value and effectiveness';
		 exitInterview.WhatWasDiscussed__c = 'What was discussed';
		 exitInterview.UnderstandRoleContributed__c = 'Yes';
		 exitInterview.WhereAreYouGoing__c = 'Are you going';
		 exitInterview.Status__c = 'Not Completed';
		 
		 insert(exitInterview); 
	}
	
	private static void createExitInterviewComment()
	{
		exitInterviewComment = new ExitInterviewComment__c();
		
		exitInterviewComment.Name = 'Exit Interview Comment';
		exitInterviewComment.BenefitsNotAsGood__c = 'Benefits not good as';
		exitInterviewComment.Benefits__c = 'Benefits';
		exitInterviewComment.CanFedbackBeeShared__c = 'Can feedbackBe share';
		exitInterviewComment.CareerDevelopmentOpportunities__c = 'Carrer Development Oportunities';
		exitInterviewComment.CompensationNotGoodAs__c = 'Compesentation Not good as';
		exitInterviewComment.Compensation__c = 'Compensation';
		exitInterviewComment.CultureAtSalesforce__c = 'Culture at salesforce';
		exitInterviewComment.ExpectationsNotClosed__c = 'Expectations Not Closed';
		exitInterviewComment.Expectations__c = 'Expectations';
		exitInterviewComment.FrequencyMeetings__c = 'Frequency Meetings';
		exitInterviewComment.HowYouHeardOportunity__c = 'How you heard oportunity';
		exitInterviewComment.ItemsNotRankedAsFive__c = 'Items not ranked as five';
		exitInterviewComment.LeavingReason__c = 'Leaving Reason';
		exitInterviewComment.ManagerCommunicateDepartmentV2MOM__c = 'Manager Communicate Department';
		exitInterviewComment.ManagerDoneDifferently__c = 'Manager Done Differently';
		exitInterviewComment.ManagerPerformanceExpectations__c = 'Manager Performance Expectations';
		exitInterviewComment.ManagersInterestSupport__c = 'Manager interest support';
		exitInterviewComment.MoraleOnYourTeam__c = 'Moral on your team';
		exitInterviewComment.OnboardingExperience__c = 'On boarding experience'; 
		exitInterviewComment.OverallWorkExperience__c = 'Overall Work Experience';
		exitInterviewComment.PerformanceMeasured__c = 'Performance Measured';
		exitInterviewComment.PositionOffer__c = 'Position Offer';
		exitInterviewComment.ReceivePerformanceReview__c = 'Receive Performance Review';
		exitInterviewComment.RegularOneToOneWithManager__c = 'Regular One To One With Manager';
		exitInterviewComment.RoleContributedCompany__c = 'Role Contributed Company';
		
		exitInterviewComment.ExitInterview__c = exitInterView.Id;
		
		insert exitInterviewComment;
	}
	
	private static void createExitInterviewCommentContinue()
	{
		exitInterviewCommentContinue = new ExitInterviewCommentContinue__c();
		
		exitInterviewCommentContinue.HavePersonalV2MOM__c = 'Have Personal V2MOM';
		exitInterviewCommentContinue.SalesforceStrengthsAndWeaknesse__c = 'Salesforce Strengths and Weeknesse';
		exitInterviewCommentContinue.SomethingToShare__c = 'Somethind To share';
		exitInterviewCommentContinue.ThinkLeaving__c = 'Think Leaving';
		exitInterviewCommentContinue.ValueAndEffectiveness__c = 'Value And Effectiveness'; 
		exitInterviewCommentContinue.WhatWasDiscussed__c = 'What was discussed';
		exitInterviewCommentContinue.UnderstandRoleContributed__c = 'Understand Role Contributed';
		exitInterviewCommentContinue.WhereAreYouGoing__c = 'Where are you going';
	
		exitInterviewCommentContinue.ExitInterview__c = exitInterview.Id;
		
		insert 	exitInterviewCommentContinue;
	}
	
	private static User getUser(String oname)
	{
		for (User u : userList)
		{
			if (u.username.equals(oname))
			{
				return u;
			}
		}
		return null;
	}
	
	private static void getUsers(){
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
												

												
		employeeStandard = GenerateEnvironmentTest.getEmployeeStandard();
		
	}	
	@isTest
	static void test1(){
		GenerateEnviromentExitInterview.createExitInterview();
		GenerateEnviromentExitInterview.createExitInterviewComment();
		GenerateEnviromentExitInterview.createExitInterviewCommentContinue();
		
	}
}