@isTest
private class IFBTest_CancelInterviewCtrl {
	
	@isTest static void cancelInterviewPositive() {

		final String ASSERTION_RCS_NOT_ABLE_TO_CANCEL_INTERVIEW = 'Recruiter coordinators were not able to cancel the Interviewer.';

		// Setting up data as the user running the test (System Administrator). Mixed DML operations are allowed.
		// Inserting records from different sObject types in single DML transactions (as long as relationship allows)
		User recruiterCoordinator;
		IFB_Interview_Candidate__c recruit;
		IFB_Interview__c interview;
		PermissionSetAssignment recruiterPermissionSetAssignment;
		PermissionSetAssignment recruiterCoordinatorPermissionSetAssignment;
		GroupMember recruiterGroupMember;

		System.runAs(new User(Id = UserInfo.getUserId())) {
			List<sObject> recordsToInsert = new List<sObject>();

			recruiterCoordinator = IFBTestData_User.getUser(null, IFBTestData_User.Option.EMPLOYEE, null, null);
			recruit = IFBTestData_Recruit.getRecruit(null, IFBTestData_Recruit.Option.SALES_EBU, null);
			recordsToInsert.clear();
			recordsToInsert.add(recruiterCoordinator);
			recordsToInsert.add(recruit);
			insert recordsToInsert;

			interview = IFBTestData_Interview.getInterview(null, IFBTestData_Interview.Option.SALES_FIRST, recruit, null, null, null, null, null, null);
			recruiterPermissionSetAssignment = IFBTestData_PermissionSetAssignment.getPermmissionSetAssignment(null,
																											   IFBTestData_PermissionSetAssignment.Option.RECRUITER,
																											   recruiterCoordinator);
			recruiterCoordinatorPermissionSetAssignment = IFBTestData_PermissionSetAssignment.getPermmissionSetAssignment(null,
																											   IFBTestData_PermissionSetAssignment.Option.RECRUITER_COORDINATOR,
																											   recruiterCoordinator);

			recruiterGroupMember = IFBTestData_GroupMember.getGroupMember(null, 
																		  IFBTestData_GroupMember.Option.SIFT_RECRUITING,
																		  recruiterCoordinator);
			recordsToInsert.clear();
			recordsToInsert.add(interview);
			recordsToInsert.add(recruiterPermissionSetAssignment);
			recordsToInsert.add(recruiterCoordinatorPermissionSetAssignment);
			recordsToInsert.add(recruiterGroupMember);
			insert recordsToInsert;
		}

		//Run test as Recruiter
		System.runAs(recruiterCoordinator) {
			Test.startTest();
				PageReference pageRef = Page.IFB_CancelInterview;
		        Test.setCurrentPage(pageRef);
		        ApexPages.StandardController standardController = new ApexPages.standardController(interview);
	    		IFB_CancelInterviewCtrl extensionController = new IFB_CancelInterviewCtrl(standardController);
	    		PageReference resultPr = extensionController.cancelInterview();
	       	Test.stopTest();

	       	System.assertNotEquals(null, resultPr, ASSERTION_RCS_NOT_ABLE_TO_CANCEL_INTERVIEW + ' We were expecting to be redirected to the detail page of the interview');
	       	interview = [select Status__c, Locked__c from IFB_Interview__c where Id = :interview.Id];
	       	System.assertEquals('Interview Cancelled', interview.Status__c, ASSERTION_RCS_NOT_ABLE_TO_CANCEL_INTERVIEW + ' We were expecting an Status update');
	       	System.assertEquals(true, interview.Locked__c, ASSERTION_RCS_NOT_ABLE_TO_CANCEL_INTERVIEW + ' We were expecting an update to the Locked field');
		}	
	}

	@isTest static void cancelInterviewNegative() {

		final String ASSERTION_RECRUITER_ABLE_TO_CANCEL_INTERVIEW = 'Recruiters should not be able to cancel the Interviewer';

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
				PageReference pageRef = Page.IFB_CancelInterview;
		        Test.setCurrentPage(pageRef);
		        ApexPages.StandardController standardController = new ApexPages.standardController(interview);
	    		IFB_CancelInterviewCtrl extensionController = new IFB_CancelInterviewCtrl(standardController);
	    		PageReference resultPr = extensionController.cancelInterview();
	       	Test.stopTest();

	       	List<Apexpages.Message> msgs = ApexPages.getMessages();
			boolean b = false;
			for(Apexpages.Message msg:msgs){
			    if (msg.getDetail().contains('You don\'t have the access to cancel the Interview.')) b = true;
			}
			System.assert(b, 'We were expecting an specific validation error message to prevent to update');

	       	System.assertEquals(null, resultPr, ASSERTION_RECRUITER_ABLE_TO_CANCEL_INTERVIEW + ' We were expecting not to be redirected, because of an validation rule error');
	       	interview = [select Status__c, Locked__c from IFB_Interview__c where Id = :interview.Id];
	       	System.assertNotEquals('Interview Cancelled', interview.Status__c, ASSERTION_RECRUITER_ABLE_TO_CANCEL_INTERVIEW + ' We were not expecting an Status update');
	       	System.assertNotEquals(true, interview.Locked__c, ASSERTION_RECRUITER_ABLE_TO_CANCEL_INTERVIEW + ' We were not expecting an update to the Locked field');
		}	
	}
	
}