@isTest
private class IFBTest_InterviewOverrideNewController {
	/*
	// By default, show the Custom Page to create new SIFT Interviews. (multiple records are created, one by each of the interviewers)
	@isTest static void testNewInterviewCustomPage() {

		IFB_SIFT_Settings_List__c settings = new IFB_SIFT_Settings_List__c();
		settings.Name = 'SIFT';
		settings.New_Interview_Override_Record_Type_Ids__c = null; 
		insert settings;


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
				PageReference pageRef = Page.IFB_InterviewOverrideNew;
		        Test.setCurrentPage(pageRef);
		        ApexPages.StandardController standardController = new ApexPages.standardController(interview);
	    		IFB_InterviewOverrideNewController extensionController = new IFB_InterviewOverrideNewController(standardController);
	    		PageReference resultPr = extensionController.redirectToUserInputForm();
	       	Test.stopTest();

	       	System.assertNotEquals(null,resultPr, 'We were expecting to be redirected to a page where we can create an SIFT Interview');
	       	System.assert(resultPr.getUrl().toLowerCase().contains('ifb_panelinterview'), 'We were expecting that by default, we will be redirected to a custom page to create SIFT interviews');
	       	
		}	
	
	}
	*/
	/*
	// If the Record Type is "in the list", do an exception and use the Standard Page Layout to create a new SIFT Interview.
	@isTest static void testNewInterviewStandardPage() {
		IFB_SIFT_Settings_List__c settings = new IFB_SIFT_Settings_List__c();
		settings.Name = 'SIFT';
		settings.New_Interview_Override_Record_Type_Ids__c = IFBTestData_Interview.recordTypeMap.get(IFBTestData_Interview.RECORDTYPE_SALES_FIRST); 
		insert settings;


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
				PageReference pageRef = Page.IFB_InterviewOverrideNew;
		        Test.setCurrentPage(pageRef);
		        ApexPages.StandardController standardController = new ApexPages.standardController(interview);
	    		IFB_InterviewOverrideNewController extensionController = new IFB_InterviewOverrideNewController(standardController);
	    		PageReference resultPr = extensionController.redirectToUserInputForm();
	       	Test.stopTest();

	       	System.assertNotEquals(null,resultPr, 'We were expecting to be redirected to a page where we can create an SIFT Interview');
	       	System.assert(!resultPr.getUrl().toLowerCase().contains('ifb_panelinterview'), 'We were expecting NOT to be redirected to custom page create SIFT interviews');
	       	
		}	
	
	}
	*/
	/*
	// If the Record Type is "in the list", do an exception and use the Standard Page Layout to create a new SIFT Interview.
	// If the "New SIFT Interview" button in the on the "SIFT Interview" tab is clicked, confirm that the URL contains an specific cancelURL
	@isTest static void testNewInterviewStandardPageCancelInterviewTab() {
		IFB_SIFT_Settings_List__c settings = new IFB_SIFT_Settings_List__c();
		settings.Name = 'SIFT';
		settings.New_Interview_Override_Record_Type_Ids__c = IFBTestData_Interview.recordTypeMap.get(IFBTestData_Interview.RECORDTYPE_SALES_FIRST); 
		insert settings;


		// Setting up data as the user running the test (System Administrator). Mixed DML operations are allowed.
		// Inserting records from different sObject types in single DML transactions (as long as relationship allows)
		User recruiterCoordinator;
		IFB_Interview__c interview;
		PermissionSetAssignment recruiterPermissionSetAssignment;
		PermissionSetAssignment recruiterCoordinatorPermissionSetAssignment;
		GroupMember recruiterGroupMember;

		System.runAs(new User(Id = UserInfo.getUserId())) {
			List<sObject> recordsToInsert = new List<sObject>();

			recruiterCoordinator = IFBTestData_User.getUser(null, IFBTestData_User.Option.EMPLOYEE, null, null);
			recordsToInsert.clear();
			recordsToInsert.add(recruiterCoordinator);
			insert recordsToInsert;

			//We intentionally create a "SIFT Interview" without a Recruit record.
			interview = IFBTestData_Interview.getInterview(null, IFBTestData_Interview.Option.SALES_FIRST, null, null, null, null, null, null, null);
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
			recordsToInsert.add(recruiterPermissionSetAssignment);
			recordsToInsert.add(recruiterCoordinatorPermissionSetAssignment);
			recordsToInsert.add(recruiterGroupMember);
			insert recordsToInsert;
		}

		//Run test as Recruiter
		System.runAs(recruiterCoordinator) {
			Test.startTest();
				PageReference pageRef = Page.IFB_InterviewOverrideNew;
		        Test.setCurrentPage(pageRef);
		        ApexPages.StandardController standardController = new ApexPages.standardController(interview);
	    		IFB_InterviewOverrideNewController extensionController = new IFB_InterviewOverrideNewController(standardController);
	    		PageReference resultPr = extensionController.redirectToUserInputForm();
	       	Test.stopTest();

	       	System.assertNotEquals(null,resultPr, 'We were expecting to be redirected to a page where we can create an SIFT Interview');
	       	System.assert(!resultPr.getUrl().toLowerCase().contains('ifb_panelinterview'), 'We were expecting NOT to be redirected to custom page create SIFT interviews');


	       	String expectedCancelURL = 'cancelurl=%2f' + IFB_ObjectDescribe.getObjectPrefix('IFB_Interview__c');
	       	System.assert(resultPr.getUrl().toLowerCase().contains(expectedCancelURL.toLowerCase()), 'We were expecting a cancelURL parameter that redirects user to SIFT Interview object home');
	       	
		}	
	
	}
	*/
	
}