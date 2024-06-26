@isTest
private class IFBTest_CaptureFeedbackButton {
	
	// If Recruiter is NOT listed as an Interviewer, it should not see the 'Capture Feedback' button (W-3390841)
	@isTest static void recruiterNotAsInterviewer() {

		final String ASSERTION_RECRUITERS_SHOULD_NOT_HAVE_ACCCESS = 'Recruiter should NOT see the Capture Feedback button if not listed as Interviewer';

		// Setting up data as the user running the test (System Administrator). Mixed DML operations are allowed.
		// Inserting records from different sObject types in single DML transactions (as long as relationship allows)
		User recruiter;
		IFB_Interview_Candidate__c recruit;
		IFB_Interview__c interview;
		PermissionSetAssignment recruiterPermissionSetAssignment;
		GroupMember recruiterGroupMember;

		System.runAs([select Id from User where Id = :UserInfo.getUserId()][0]) {
			List<sObject> recordsToInsert = new List<sObject>();

			recruiter = IFBTestData_User.getUser(null, IFBTestData_User.Option.EMPLOYEE, null, null);
			recruit = IFBTestData_Recruit.getRecruit(null, IFBTestData_Recruit.Option.SALES_EBU, null);
			recordsToInsert.clear();
			recordsToInsert.add(recruiter);
			recordsToInsert.add(recruit);
			insert recordsToInsert;

			interview = IFBTestData_Interview.getInterview(null, IFBTestData_Interview.Option.SALES_FIRST, recruit, null, null, null, null, null, null);
			recruiterPermissionSetAssignment = IFBTestData_PermissionSetAssignment.getPermmissionSetAssignment(null,
																											   IFBTestData_PermissionSetAssignment.Option.RECRUITER,
																											   recruiter);
			recruiterGroupMember = IFBTestData_GroupMember.getGroupMember(null, 
																		  IFBTestData_GroupMember.Option.SIFT_RECRUITING,
																		  recruiter);
			recordsToInsert.clear();
			recordsToInsert.add(interview);
			recordsToInsert.add(recruiterPermissionSetAssignment);
			recordsToInsert.add(recruiterGroupMember);
			insert recordsToInsert;
		}

		//Run test as Recruiter
		System.runAs(recruiter) {
			Test.startTest();
				PageReference pageRef = Page.IFB_CaptureFeedbackButton;
		        Test.setCurrentPage(pageRef);
		        ApexPages.StandardController standardController = new ApexPages.standardController(interview);
	    		IFB_CaptureFeedbackButtonController extensionController = new IFB_CaptureFeedbackButtonController(standardController);
	       	Test.stopTest();

	       	System.assertEquals(false, extensionController.isCaptureFeedbackButtonVisible, ASSERTION_RECRUITERS_SHOULD_NOT_HAVE_ACCCESS);
		}	
	}
	
	// If Recruiter is listed as an Interviewer, it should not see the 'Capture Feedback' button (W-3390841)
	@isTest static void recruiterAsInterviewer() {
		final String ASSERTION_RECRUITERS_SHOULD_HAVE_ACCCES = 'Recruiter should see the Capture Feedback button if listed as Interviewer';

		// Setting up data as the user running the test (System Administrator). Mixed DML operations are allowed.
		// Inserting records from different sObject types in single DML transactions (as long as relationship allows)
		User recruiter;
		IFB_Interview_Candidate__c recruit;
		IFB_Interview__c interview;
		PermissionSetAssignment recruiterPermissionSetAssignment;
		GroupMember recruiterGroupMember;

		System.runAs([select Id from User where Id = :UserInfo.getUserId()][0]) {
			List<sObject> recordsToInsert = new List<sObject>();

			recruiter = IFBTestData_User.getUser(null, IFBTestData_User.Option.EMPLOYEE, null, null);
			recruit = IFBTestData_Recruit.getRecruit(null, IFBTestData_Recruit.Option.SALES_EBU, null);
			recordsToInsert.clear();
			recordsToInsert.add(recruiter);
			recordsToInsert.add(recruit);
			insert recordsToInsert;

			// We set the Recruiter as one of the Interviewers
			interview = IFBTestData_Interview.getInterview(null, IFBTestData_Interview.Option.SALES_FIRST, recruit, recruiter, null, null, null, null, null);
			recruiterPermissionSetAssignment = IFBTestData_PermissionSetAssignment.getPermmissionSetAssignment(null,
																											   IFBTestData_PermissionSetAssignment.Option.RECRUITER,
																											   recruiter);
			recruiterGroupMember = IFBTestData_GroupMember.getGroupMember(null, 
																		  IFBTestData_GroupMember.Option.SIFT_RECRUITING,
																		  recruiter);
			recordsToInsert.clear();
			recordsToInsert.add(interview);
			recordsToInsert.add(recruiterPermissionSetAssignment);
			recordsToInsert.add(recruiterGroupMember);
			insert recordsToInsert;
		}

		//Run test as Recruiter
		System.runAs(recruiter) {
			Test.startTest();
				PageReference pageRef = Page.IFB_CaptureFeedbackButton;
		        Test.setCurrentPage(pageRef);
		        ApexPages.StandardController standardController = new ApexPages.standardController(interview);
	    		IFB_CaptureFeedbackButtonController extensionController = new IFB_CaptureFeedbackButtonController(standardController);
	       	Test.stopTest();

	       	System.assertEquals(true, extensionController.isCaptureFeedbackButtonVisible, ASSERTION_RECRUITERS_SHOULD_HAVE_ACCCES);
		}
	}
}