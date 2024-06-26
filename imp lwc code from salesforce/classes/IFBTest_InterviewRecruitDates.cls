@isTest
private class IFBTest_InterviewRecruitDates {

/* 
Commenting out insert test cases as they are not valid for the current functionality
of SIFT interview creation. Once McLaren goes live these test cases will become valid
and the code has to be fixed as there is a potential bug in the code. Currently the 
actual interview date from the interview does not flow up to the recruit when an interview
created. This decision has been made during the TF - SIFT sync implementation. 
But it has to flow once McLaren goes live and TF is retired.

	// For a Panel Interview, both the "First Screen Date" and the "Panal Interview Date" should be populated on insert (W-3404255)
	@isTest static void onInsertPanelInterview() {
		final String ASSERTION_FIRST_SCREEN_DATE_EMPTY = 'First Screen Date was not populated in the Recruit';
		final String ASSERTION_FIRST_SCREEN_DATE_WRONG = 'First Screen Date in the Recruit is wrong.';
		final String ASSERTION_PANEL_DATE_EMPTY = 'Panel Date was not populated in the Recruit.';
		final String ASSERTION_PANEL_DATE_WRONG = 'Panel Date in the Recruit is wrong.';

		// Setting up data as the user running the test (System Administrator). Mixed DML operations are allowed.
		// Inserting records from different sObject types in single DML transactions (as long as relationship allows)
		User recruiter;
		IFB_Interview_Candidate__c recruit;
		IFB_Interview__c interview;
		PermissionSetAssignment recruiterPermissionSetAssignment;
		GroupMember recruiterGroupMember;

		System.runAs(new User(Id = UserInfo.getUserId())) {
			List<sObject> recordsToInsert = new List<sObject>();

			recruiter = IFBTestData_User.getUser(null, IFBTestData_User.Option.EMPLOYEE, null, null);
			recruit = IFBTestData_Recruit.getRecruit(null, IFBTestData_Recruit.Option.SALES_EBU, null);
			recordsToInsert.clear();
			recordsToInsert.add(recruiter);
			recordsToInsert.add(recruit);
			insert recordsToInsert;

			interview = IFBTestData_Interview.getInterview(null, IFBTestData_Interview.Option.CSG_PANEL, recruit, null, null, null, null, null, null);
			recruiterPermissionSetAssignment = IFBTestData_PermissionSetAssignment.getPermmissionSetAssignment(null,
																											   IFBTestData_PermissionSetAssignment.Option.RECRUITER,
																											   recruiter);
			recruiterGroupMember = IFBTestData_GroupMember.getGroupMember(null, 
																		  IFBTestData_GroupMember.Option.SIFT_RECRUITING,
																		  recruiter);
			recordsToInsert.clear();
			recordsToInsert.add(recruiterPermissionSetAssignment);
			recordsToInsert.add(recruiterGroupMember);
			insert recordsToInsert;
		}

		// Run test as System Administrator.
		// (Interviewers can't insert Interview records, and Recruiter can't define an Actual Interview Date at the time they are creating the Interview record)
		DateTime actualInterviewDate = DateTime.now().addDays(6);
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
				interview.Actual_Interview_Date__c = actualInterviewDate;
				insert interview;
	       	Test.stopTest();
		}

		recruit = [select Id, First_Screen_Date__c, Panel_Interview_Date__c from IFB_Interview_Candidate__c where Id = : recruit.Id];
		System.assertNotEquals(null, recruit.First_Screen_Date__c, ASSERTION_FIRST_SCREEN_DATE_EMPTY);
		System.assertEquals(actualInterviewDate, recruit.First_Screen_Date__c, ASSERTION_FIRST_SCREEN_DATE_WRONG);
		System.assertNotEquals(null, recruit.Panel_Interview_Date__c, ASSERTION_PANEL_DATE_EMPTY);	
		System.assertEquals(actualInterviewDate, recruit.Panel_Interview_Date__c, ASSERTION_PANEL_DATE_WRONG);	
	}

	// For a Non Panel Interview, only the "First Screen Date" should be populated on insert (W-3404255)
	@isTest static void onInsertNonPanelInterview() {
		final String ASSERTION_FIRST_SCREEN_DATE_EMPTY = 'First Screen Date was not populated in the Recruit';
		final String ASSERTION_FIRST_SCREEN_DATE_WRONG = 'First Screen Date in the Recruit is wrong.';
		final String ASSERTION_PANEL_DATE_NOT_EMPTY = 'On this scenario, the Panel Date should not be populated in the Recruit.';

		// Setting up data as the user running the test (System Administrator). Mixed DML operations are allowed.
		// Inserting records from different sObject types in single DML transactions (as long as relationship allows)
		IFB_Interview_Candidate__c recruit;
		IFB_Interview__c interview;

		System.runAs(new User(Id = UserInfo.getUserId())) {
			List<sObject> recordsToInsert = new List<sObject>();

			recruit = IFBTestData_Recruit.getRecruit(null, IFBTestData_Recruit.Option.SALES_EBU, null);
			recordsToInsert.add(recruit);
			insert recordsToInsert;

			interview = IFBTestData_Interview.getInterview(null, IFBTestData_Interview.Option.CSG_TECHNICAL, recruit, null, null, null, null, null, null);
			recordsToInsert.clear();
			insert recordsToInsert;
		}

		// Run test as System Administrator.
		// The reason is : Interviewers can't insert Interview records, and Recruiter can't define an Actual Interview Date at the time they are creating the Interview record)
		DateTime actualInterviewDate = DateTime.now().addDays(6);
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
				interview.Actual_Interview_Date__c = actualInterviewDate;
				insert interview;
	       	Test.stopTest();
		}

		recruit = [select Id, First_Screen_Date__c, Panel_Interview_Date__c from IFB_Interview_Candidate__c where Id = : recruit.Id];
		System.assertNotEquals(null, recruit.First_Screen_Date__c, ASSERTION_FIRST_SCREEN_DATE_EMPTY);
		System.assertEquals(actualInterviewDate, recruit.First_Screen_Date__c, ASSERTION_FIRST_SCREEN_DATE_WRONG);
		System.assertEquals(null, recruit.Panel_Interview_Date__c, ASSERTION_PANEL_DATE_NOT_EMPTY);	
	} */

	// For a Panel Interview, both the "First Screen Date" and the "Panal Interview Date" should be populated on update. (W-3404255)
	@isTest static void onUpdatePanelInterview() { 
		final String ASSERTION_FIRST_SCREEN_DATE_EMPTY = 'First Screen Date was not populated in the Recruit';
		final String ASSERTION_FIRST_SCREEN_DATE_WRONG = 'First Screen Date in the Recruit is wrong.';
		final String ASSERTION_PANEL_DATE_EMPTY = 'Panel Date was not populated in the Recruit.';
		final String ASSERTION_PANEL_DATE_WRONG = 'Panel Date in the Recruit is wrong.';

		// Setting up data as the user running the test (System Administrator). Mixed DML operations are allowed.
		// Inserting records from different sObject types in single DML transactions (as long as relationship allows)
		User interviewer;
		User recruiter;
		IFB_Interview_Candidate__c recruit;
		IFB_Interview__c interview;
		PermissionSetAssignment recruiterPermissionSetAssignment;
		GroupMember recruiterGroupMember;

		System.runAs(new User(Id = UserInfo.getUserId())) {
			List<sObject> recordsToInsert = new List<sObject>();
			recruiter = IFBTestData_User.getUser(null, IFBTestData_User.Option.EMPLOYEE, null, null);
			interviewer = IFBTestData_User.getUser(null, IFBTestData_User.Option.EMPLOYEE, null, null);			
			recordsToInsert.clear();
			recordsToInsert.add(recruiter);
			recordsToInsert.add(interviewer);			
			insert recordsToInsert;

			recruiterPermissionSetAssignment = IFBTestData_PermissionSetAssignment.getPermmissionSetAssignment(null,
													IFBTestData_PermissionSetAssignment.Option.RECRUITER,
													recruiter);
			recruiterGroupMember = IFBTestData_GroupMember.getGroupMember(null, 
										IFBTestData_GroupMember.Option.SIFT_RECRUITING,
										recruiter);
			recordsToInsert.clear();
			recordsToInsert.add(recruiterPermissionSetAssignment);
			recordsToInsert.add(recruiterGroupMember);
			insert recordsToInsert;	
			
		}

		// Insert records as recruiters and update the date on panel interview.
		DateTime actualInterviewDate = DateTime.now().addDays(6);
		System.runAs(recruiter) {
			List<sObject> recordsToInsert = new List<sObject>();						
			Test.startTest();
				recruit = IFBTestData_Recruit.getRecruit(null, IFBTestData_Recruit.Option.SALES_EBU, null);
				recordsToInsert.add(recruit);
				insert recordsToInsert;

				interview = new IFB_Interview__c(Actual_Interview_Date__c = DateTime.now().addDays(12));
				interview = IFBTestData_Interview.getInterview(interview, IFBTestData_Interview.Option.CSG_PANEL, recruit, interviewer, null, null, null, null, null);
				recordsToInsert.clear();
				recordsToInsert.add(interview);
				insert recordsToInsert;			
				interview.Actual_Interview_Date__c = actualInterviewDate;
				update interview;
	       	Test.stopTest();
		}

		recruit = [select Id, First_Screen_Date__c, Panel_Interview_Date__c from IFB_Interview_Candidate__c where Id = : recruit.Id];
		System.assertNotEquals(null, recruit.First_Screen_Date__c, ASSERTION_FIRST_SCREEN_DATE_EMPTY);
		System.assertEquals(actualInterviewDate, recruit.First_Screen_Date__c, ASSERTION_FIRST_SCREEN_DATE_WRONG);
		System.assertNotEquals(null, recruit.Panel_Interview_Date__c, ASSERTION_PANEL_DATE_EMPTY);	
		System.assertEquals(actualInterviewDate, recruit.Panel_Interview_Date__c, ASSERTION_PANEL_DATE_WRONG);	
	}

	// For a Non Panel Interview, only the "First Screen Date" should be populated on update (W-3404255)
	@isTest static void onUpdateNonPanelInterview() {
		final String ASSERTION_FIRST_SCREEN_DATE_EMPTY = 'First Screen Date was not populated in the Recruit';
		final String ASSERTION_FIRST_SCREEN_DATE_WRONG = 'First Screen Date in the Recruit is wrong.';
		final String ASSERTION_PANEL_DATE_NOT_EMPTY = 'On this scenario, the Panel Date should not be populated in the Recruit.';

		// Setting up data as the user running the test (System Administrator). Mixed DML operations are allowed.
		// Inserting records from different sObject types in single DML transactions (as long as relationship allows)
		User interviewer;
		User recruiter;
		IFB_Interview_Candidate__c recruit;
		IFB_Interview__c interview;
		PermissionSetAssignment recruiterPermissionSetAssignment;
		GroupMember recruiterGroupMember;

		System.runAs(new User(Id = UserInfo.getUserId())) {
			List<sObject> recordsToInsert = new List<sObject>();
			recruiter = IFBTestData_User.getUser(null, IFBTestData_User.Option.EMPLOYEE, null, null);
			interviewer = IFBTestData_User.getUser(null, IFBTestData_User.Option.EMPLOYEE, null, null);			
			recordsToInsert.clear();
			recordsToInsert.add(recruiter);
			recordsToInsert.add(interviewer);			
			insert recordsToInsert;

			recruiterPermissionSetAssignment = IFBTestData_PermissionSetAssignment.getPermmissionSetAssignment(null,
													IFBTestData_PermissionSetAssignment.Option.RECRUITER,
													recruiter);
			recruiterGroupMember = IFBTestData_GroupMember.getGroupMember(null, 
										IFBTestData_GroupMember.Option.SIFT_RECRUITING,
										recruiter);
			recordsToInsert.clear();
			recordsToInsert.add(recruiterPermissionSetAssignment);
			recordsToInsert.add(recruiterGroupMember);
			insert recordsToInsert;	
		}

		// Insert records as recruiters and update the date on interview.
		DateTime actualInterviewDate = DateTime.now().addDays(6);
		System.runAs(recruiter) {
			List<sObject> recordsToInsert = new List<sObject>();			
			Test.startTest();
				recruit = IFBTestData_Recruit.getRecruit(null, IFBTestData_Recruit.Option.SALES_EBU, null);
				recordsToInsert.clear();
				recordsToInsert.add(recruit);
				insert recordsToInsert;
				
				interview = new IFB_Interview__c(Actual_Interview_Date__c = DateTime.now().addDays(12));
				interview = IFBTestData_Interview.getInterview(interview, IFBTestData_Interview.Option.CSG_TECHNICAL, recruit, interviewer, null, null, null, null, null);
			
				recordsToInsert.clear();
				recordsToInsert.add(interview);
				insert recordsToInsert;
				
				interview.Actual_Interview_Date__c = actualInterviewDate;
				update interview;
	       	Test.stopTest();
		}

		recruit = [select Id, First_Screen_Date__c, Panel_Interview_Date__c from IFB_Interview_Candidate__c where Id = : recruit.Id];
		System.assertNotEquals(null, recruit.First_Screen_Date__c, ASSERTION_FIRST_SCREEN_DATE_EMPTY);
		System.assertEquals(actualInterviewDate, recruit.First_Screen_Date__c, ASSERTION_FIRST_SCREEN_DATE_WRONG);
		System.assertEquals(null, recruit.Panel_Interview_Date__c, ASSERTION_PANEL_DATE_NOT_EMPTY);	
	}
/*
	// "First Screen Date" and "Panel Date" calculation on recruit should be bulkyfied (W-3404255)
	@isTest static void onBulkInsertInterviews() {
		final String ASSERTION_FIRST_SCREEN_DATE_EMPTY = 'First Screen Date was not populated in the Recruit';
		final String ASSERTION_FIRST_SCREEN_DATE_WRONG = 'First Screen Date in the Recruit is wrong. It should be the Actual Date of the first Interview';
		final String ASSERTION_PANEL_DATE_EMPTY = 'Panel Date was not populated in the Recruit.';
		final String ASSERTION_PANEL_DATE_WRONG = 'Panel Date in the Recruit is wrong.';

		// Setting up data as the user running the test (System Administrator). Mixed DML operations are allowed.
		// Inserting records from different sObject types in single DML transactions (as long as relationship allows)

		List<IFB_Interview_Candidate__c> recruits = new List<IFB_Interview_Candidate__c>();
		List<IFB_Interview__c> interviews = new List<IFB_Interview__c>();

		System.runAs(new User(Id = UserInfo.getUserId())) {
			// Creating 10 recruits
			for (Integer i = 1; i <= 10; i++) {
				recruits.add(IFBTestData_Recruit.getRecruit(null, IFBTestData_Recruit.Option.CSG_PA, null));
			}
			insert recruits;

			// Creating 300 interviews (3 by recruit)
			for (IFB_Interview_Candidate__c recruit : recruits) {
				interviews.add(IFBTestData_Interview.getInterview(null, IFBTestData_Interview.Option.CSG_TECHNICAL, recruit, null, null, null, null, null, null));
				interviews.add(IFBTestData_Interview.getInterview(null, IFBTestData_Interview.Option.CSG_CONSULTING, recruit, null, null, null, null, null, null));
				interviews.add(IFBTestData_Interview.getInterview(null, IFBTestData_Interview.Option.CSG_PANEL, recruit, null, null, null, null, null, null));
			}
		}

		// Run test as System Administrator.
		// (Interviewers can't insert Interview records, and Recruiter can't define an Actual Interview Date at the time they are creating the Interview record)
		DateTime technicalActualInterviewDate = DateTime.now().addDays(6);
		DateTime consultingActualInterviewDate = DateTime.now().addDays(9);
		DateTime panelActualInterviewDate = DateTime.now().addDays(12);

		System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();

				for (IFB_Interview__c interview : interviews) {
					if (interview.RecordTypeId == IFBTestData_Interview.recordTypeMap.get(IFBTestData_Interview.RECORDTYPE_CSG_TECHNICAL)) {
						interview.Actual_Interview_Date__c = technicalActualInterviewDate;
					} else if (interview.RecordTypeId == IFBTestData_Interview.recordTypeMap.get(IFBTestData_Interview.RECORDTYPE_CSG_CONSULTING)) {
						interview.Actual_Interview_Date__c = consultingActualInterviewDate;
					} else if (interview.RecordTypeId == IFBTestData_Interview.recordTypeMap.get(IFBTestData_Interview.RECORDTYPE_CSG_PANEL)) {
						interview.Actual_Interview_Date__c = panelActualInterviewDate;
					}
				}
				insert interviews;
	       	Test.stopTest();
		}

		recruits = [select Id, First_Screen_Date__c, Panel_Interview_Date__c from IFB_Interview_Candidate__c where Id = : recruits];
		for (IFB_Interview_Candidate__c recruit : recruits) {
			System.assertNotEquals(null, recruit.First_Screen_Date__c, ASSERTION_FIRST_SCREEN_DATE_EMPTY);
			// We assert that the "First Screen Date" is the Tecnical Interview because of the test data that we just inserted, it was
			// the interview with the "oldest" Actual Interview Date.
			System.assertEquals(technicalActualInterviewDate, recruit.First_Screen_Date__c, ASSERTION_FIRST_SCREEN_DATE_WRONG);
			System.assertNotEquals(null, recruit.Panel_Interview_Date__c, ASSERTION_PANEL_DATE_EMPTY);	
			System.assertEquals(panelActualInterviewDate, recruit.Panel_Interview_Date__c, ASSERTION_PANEL_DATE_WRONG);	
		}
		
	}
*/	
	
}