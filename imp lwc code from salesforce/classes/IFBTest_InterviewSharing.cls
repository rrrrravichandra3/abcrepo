@isTest
private class IFBTest_InterviewSharing {
	
	@testSetup static void questionsAndCategoryMapping() {
		insert IFBTestConfig_IntQuestionCategoryMap.getSettings();
		insert IFBTestDataSet_Question.getQuestions();
	}

	@isTest static void insertInterview() {
		final String ASSERTION_FIRST_SCREEN_DATE_EMPTY = 'First Screen Date was not populated in the Recruit';
		final String ASSERTION_FIRST_SCREEN_DATE_WRONG = 'First Screen Date in the Recruit is wrong.';
		final String ASSERTION_PANEL_DATE_EMPTY = 'Panel Date was not populated in the Recruit.';
		final String ASSERTION_PANEL_DATE_WRONG = 'Panel Date in the Recruit is wrong.';

		// Setting up data as the user running the test (System Administrator). Mixed DML operations are allowed.
		// Inserting records from different sObject types in single DML transactions (as long as relationship allows)
		User recruiter;
		User interviewer;
		User hiringManagerManager;
		User hiringManager;

		IFB_Interview_Candidate__c recruit;
		IFB_Interview__c interview;
		PermissionSetAssignment recruiterPermissionSetAssignment;
		GroupMember recruiterGroupMember;

		System.runAs(new User(Id = UserInfo.getUserId())) {
			List<sObject> recordsToInsert = new List<sObject>();

			recruiter = IFBTestData_User.getUser(null, IFBTestData_User.Option.EMPLOYEE, null, null);
			hiringManagerManager = IFBTestData_User.getUser(null, IFBTestData_User.Option.MANAGER, null, null);
			interviewer = IFBTestData_User.getUser(null, IFBTestData_User.Option.EMPLOYEE, null, null);

			recruit = IFBTestData_Recruit.getRecruit(null, IFBTestData_Recruit.Option.CSG_PA, null);

			recordsToInsert.add(recruiter);
			recordsToInsert.add(hiringManagerManager);
			recordsToInsert.add(interviewer);
			recordsToInsert.add(recruit);
			insert recordsToInsert;

			hiringManager = IFBTestData_User.getUser(null, IFBTestData_User.Option.MANAGER, null, null);
			hiringManager.Manager__c = hiringManagerManager.Id;
			recruiterPermissionSetAssignment = IFBTestData_PermissionSetAssignment.getPermmissionSetAssignment(null,
																											   IFBTestData_PermissionSetAssignment.Option.RECRUITER,
																											   recruiter);
			recruiterGroupMember = IFBTestData_GroupMember.getGroupMember(null, 
																		  IFBTestData_GroupMember.Option.SIFT_RECRUITING,
																		  recruiter);
			recordsToInsert.clear();
			recordsToInsert.add(hiringManager);
			recordsToInsert.add(recruiterPermissionSetAssignment);
			recordsToInsert.add(recruiterGroupMember);
			insert recordsToInsert;
			
			interview = IFBTestData_Interview.getInterview(null, IFBTestData_Interview.Option.CSG_PANEL, recruit, interviewer, null, null, null, null, hiringManager);
		}

		// Run test as recruiter
		System.runAs(recruiter) {
			Test.startTest();
				insert interview;
	       	Test.stopTest();
		}

		Set<Id> questionIds = new Set<Id>();
		for (IFB_Interview_Evaluation__c evaluation : [select Id, Interview_Question__c 
													   from IFB_Interview_Evaluation__c 
													   where Interview__c = :interview.Id]){
			questionIds.add(evaluation.Interview_Question__c);
		}

		// Making sure that record sharing done via APEX Sharing Reasons (Interviewer and Hiring Manager and above is working)
		System.runAs(interviewer) {
			System.assertEquals(1, [select Id from IFB_Interview_Candidate__c where Id = :recruit.Id].size());
			System.assertEquals(1, [select Id from IFB_Interview__c where Id = :interview.Id].size());
			System.assertEquals(questionIds.size(), [select Id from IFB_Interview_Question__c where Id in :questionIds].size());
		}

		System.runAs(hiringManager) {
			System.assertEquals(1, [select Id from IFB_Interview_Candidate__c where Id = :recruit.Id].size());
			System.assertEquals(1, [select Id from IFB_Interview__c where Id = :interview.Id].size());
			System.assertEquals(questionIds.size(), [select Id from IFB_Interview_Question__c where Id in :questionIds].size());
		}

		System.runAs(hiringManagerManager) {
			System.assertEquals(1, [select Id from IFB_Interview_Candidate__c where Id = :recruit.Id].size());
			System.assertEquals(1, [select Id from IFB_Interview__c where Id = :interview.Id].size());
			System.assertEquals(questionIds.size(), [select Id from IFB_Interview_Question__c where Id in :questionIds].size());
		}
		
	}
	
}