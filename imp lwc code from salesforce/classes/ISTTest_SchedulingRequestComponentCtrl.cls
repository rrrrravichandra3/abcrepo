@isTest
private class ISTTest_SchedulingRequestComponentCtrl {

	// Test the Scheduling Tool configurations wrapper class IST_SchedulingToolConfigurations
	@isTest static void testLoadSchedulingConfigurations() {
		final String ASSERTION_CUSTOMMETADATA_TOOL_ENABLED = 'The \'toolIsEnabled\' property is not following the value of the Custom Metadata field \'IST_Scheduling_Tool_Settings_Metadata__mdt.Enable_Scheduling_Tool__c\'';
		final String ASSERTION_CUSTOMSETTING_TOOL_ENABLED = 'The \'userIsEnabled\' property is not following the value of the Custom Setting field \'IST_Scheduling_Tool_Hierarchy_Settings__c.getInstance().Enable_Scheduling_Tool__c\'';

		IST_Scheduling_Tool_Settings_Metadata__mdt settingsMetadata;
		User recruiter;
		PermissionSetAssignment recruiterPermissionSetAssignment;
		IST_SchedulingToolConfigurations configurations;

		System.runAs(new User(Id = UserInfo.getUserId())) {

			settingsMetadata = [select Enable_Scheduling_Tool__c, Task_Record_Type__c
        						from IST_Scheduling_Tool_Settings_Metadata__mdt
        						where DeveloperName = 'IST_Scheduling_Tool' limit 1];

        	recruiter = ISTTestDataFactory_SchedulingTool.getUser(null, ISTTestDataFactory_SchedulingTool.UserOption.RECRUITER, null, null);
			insert recruiter;

			Id permissionSetId = ISTTestDataFactory_SchedulingTool.getPermissionSet('IST_Scheduling_Tool_Recruiter').Id;
			recruiterPermissionSetAssignment = new PermissionSetAssignment(PermissionSetId = permissionSetId, AssigneeId = recruiter.Id);
			insert recruiterPermissionSetAssignment;
			
		} 
     
		System.runAs(recruiter) {
			Test.startTest();
				configurations = IST_SchedulingRequestComponentController.loadSchedulingConfigurations();
			Test.stopTest();

			System.assertEquals(settingsMetadata.Enable_Scheduling_Tool__c, configurations.toolIsEnabled, '');
			System.assertEquals(IST_Scheduling_Tool_Hierarchy_Settings__c.getInstance().Enable_Scheduling_Tool__c, configurations.userIsEnabled, '');
		}
	}

	// Tests that we are able to load existing Scheduling Tool task  related to a Talenforce - Interview 1 record.
	@isTest static void testLoadExistingSchedulingTaskInterview1() {
		final String ASSERTION_TASK_INFORMATION_MISMATCH = 'There is a mismatch with the Task information that was inserted and the Task information that is being retrieved.';
		final String ASSERTION_RECORDTYPE_NOT_FOUND = 'Unable to create test data. The Record Type was not found.';
		final String ASSERTION_UNABLE_TO_SETUP_TALENTFORCE = 'Unable to setup Talentforce interview data. Scheduling Tool task could not be tested until the Task has an interview record to be attached to';
		final String ASSERTION_TASK_NOT_FOUND = 'Unable to find the Task record that was setup for testing. Check if the runAs user has access to the Task record.';
		
		// Information to setup the Talentforce interview.
		final String TALENTFORCE_CANDIDATE_SOURCE_NAME = 'Employee Referral';
		final String TALENTFORCE_JOB_NAME = 'Job Name';
		final String TALENTFORCE_CANDIDATE_NAME = 'Candidate Name';
		final String TALENTFORCE_REFERRER_NAME = 'Employee Name';

		// Information to setup the Scheduling Tool task.
		final String TASK_RECORDTYPE_DEVELOPERNAME = 'IST_Scheduling_Tool';
		final String TASK_STATUS = 'Not Started';
		final String INTERVIEW_SCHEDULING_REQUEST_COMMENTS = 'Test Comments 123';
		final String INTERVIEW_SCHEDULING_REQUEST_TYPE = 'Phone';

		Task task;
		Task taskReturned;
		IST_Interview_Scheduling_Request__c schedulingRequest;
		User recruiter;
		PermissionSetAssignment recruiterPermissionSetAssignment;
		GroupMember recruiterGroupMember;
		List<RecordType> taskRecordTypes;
		Id interviewId;

		System.runAs(new User(Id = UserInfo.getUserId())) {
			List<sObject> recordsToInsert = new List<sObject>();

			recruiter = ISTTestDataFactory_SchedulingTool.getUser(null, ISTTestDataFactory_SchedulingTool.UserOption.RECRUITER, null, null);
			insert recruiter;

			// Setting up the permission set and group assignment for the Recruiter.
			Id permissionSetId = ISTTestDataFactory_SchedulingTool.getPermissionSet('IST_Scheduling_Tool_Recruiter').Id;
			recruiterPermissionSetAssignment = new PermissionSetAssignment(PermissionSetId = permissionSetId, AssigneeId = recruiter.Id);
			recordsToInsert.add(recruiterPermissionSetAssignment);

			Id groupId = ISTTestDataFactory_SchedulingTool.getGroup('IST_Scheduling_Tool_Recruiting').Id;
			recruiterGroupMember = new GroupMember(UserOrGroupId = recruiter.Id, GroupId = groupId);
			recordsToInsert.add(recruiterGroupMember);

			insert recordsToInsert;

			taskRecordTypes = [select Id, DeveloperName from RecordType where DeveloperName = :TASK_RECORDTYPE_DEVELOPERNAME limit 1];
			System.assertNotEquals(0, taskRecordTypes.size(), ASSERTION_RECORDTYPE_NOT_FOUND + '[' + TASK_RECORDTYPE_DEVELOPERNAME + ']');

			interviewId = ISTTestDataFactory_SchedulingTool.setupAndInsertTalentforceInterview(ISTTestDataFactory_SchedulingTool.InterviewOption.INTERVIEW_1, recruiter,  
																							   TALENTFORCE_CANDIDATE_SOURCE_NAME, TALENTFORCE_JOB_NAME, TALENTFORCE_CANDIDATE_NAME, TALENTFORCE_REFERRER_NAME);

			System.assertNotEquals(null, ASSERTION_UNABLE_TO_SETUP_TALENTFORCE);

			schedulingRequest = new IST_Interview_Scheduling_Request__c(Comments__c = INTERVIEW_SCHEDULING_REQUEST_COMMENTS, Interview_Type__c = INTERVIEW_SCHEDULING_REQUEST_TYPE);
			insert schedulingRequest;

			task = new Task(Status = TASK_STATUS, RecordTypeId = taskRecordTypes[0].Id, IST_Interview_Scheduling_Request__c = schedulingRequest.Id, WhatId = interviewId);
			insert task;
			
		}

		System.runAs(recruiter) {
			
			Test.startTest();
				
				taskReturned = IST_SchedulingRequestComponentController.loadExistingSchedulingTask(task.Id);
				
				System.assertNotEquals(null, taskReturned, ASSERTION_TASK_NOT_FOUND);				
				System.assertEquals(task.Id, taskReturned.Id, ASSERTION_TASK_INFORMATION_MISMATCH + '[Field: Task.Id]');
				System.assertEquals(task.Status, taskReturned.Status, ASSERTION_TASK_INFORMATION_MISMATCH + '[Field: Task.Status]');
				System.assertEquals(task.WhatId, taskReturned.WhatId, ASSERTION_TASK_INFORMATION_MISMATCH + '[Field: Task.WhatId]');
				System.assertEquals(task.IST_Interview_Scheduling_Request__c, taskReturned.IST_Interview_Scheduling_Request__c, ASSERTION_TASK_INFORMATION_MISMATCH + '[Field: Task.IST_Interview_Scheduling_Request__c]');
				System.assertEquals(schedulingRequest.Comments__c , taskReturned.IST_Interview_Scheduling_Request__r.Comments__c, ASSERTION_TASK_INFORMATION_MISMATCH + '[Field: Task.IST_Interview_Scheduling_Request__r.Comments__c]');

			Test.stopTest();
		}
	}
 

	// Tests that we are able to load existing Scheduling Tool task  related to a Talenforce - Interview 2 record.
	@isTest static void testLoadExistingSchedulingTaskInterview2() {
		final String ASSERTION_TASK_INFORMATION_MISMATCH = 'There is a mismatch with the Task information that was inserted and the Task information that is being retrieved.';
		final String ASSERTION_RECORDTYPE_NOT_FOUND = 'Unable to create test data. The Record Type was not found.';
		final String ASSERTION_UNABLE_TO_SETUP_TALENTFORCE = 'Unable to setup Talentforce interview data. Scheduling Tool task could not be tested until the Task has an interview record to be attached to';
		final String ASSERTION_TASK_NOT_FOUND = 'Unable to find the Task record that was setup for testing. Check if the runAs user has access to the Task record.';
		
		// Information to setup the Talentforce interview.
		final String TALENTFORCE_CANDIDATE_SOURCE_NAME = 'Employee Referral';
		final String TALENTFORCE_JOB_NAME = 'Job Name';
		final String TALENTFORCE_CANDIDATE_NAME = 'Candidate Name';
		final String TALENTFORCE_REFERRER_NAME = 'Employee Name';

		// Information to setup the Scheduling Tool task.
		final String TASK_RECORDTYPE_DEVELOPERNAME = 'IST_Scheduling_Tool';
		final String TASK_STATUS = 'Not Started';
		final String INTERVIEW_SCHEDULING_REQUEST_COMMENTS = 'Test Comments 123';
		final String INTERVIEW_SCHEDULING_REQUEST_TYPE = 'Phone';

		Task task;
		Task taskReturned;
		IST_Interview_Scheduling_Request__c schedulingRequest;
		User recruiter;
		PermissionSetAssignment recruiterPermissionSetAssignment;
		GroupMember recruiterGroupMember;
		List<RecordType> taskRecordTypes;
		Id interviewId;

		System.runAs(new User(Id = UserInfo.getUserId())) {
			List<sObject> recordsToInsert = new List<sObject>();

			recruiter = ISTTestDataFactory_SchedulingTool.getUser(null, ISTTestDataFactory_SchedulingTool.UserOption.RECRUITER, null, null);
			insert recruiter;

			// Setting up the permission set and group assignment for the Recruiter.
			Id permissionSetId = ISTTestDataFactory_SchedulingTool.getPermissionSet('IST_Scheduling_Tool_Recruiter').Id;
			recruiterPermissionSetAssignment = new PermissionSetAssignment(PermissionSetId = permissionSetId, AssigneeId = recruiter.Id);
			recordsToInsert.add(recruiterPermissionSetAssignment);

			Id groupId = ISTTestDataFactory_SchedulingTool.getGroup('IST_Scheduling_Tool_Recruiting').Id;
			recruiterGroupMember = new GroupMember(UserOrGroupId = recruiter.Id, GroupId = groupId);
			recordsToInsert.add(recruiterGroupMember);

			insert recordsToInsert;

			taskRecordTypes = [select Id, DeveloperName from RecordType where DeveloperName = :TASK_RECORDTYPE_DEVELOPERNAME limit 1];
			System.assertNotEquals(0, taskRecordTypes.size(), ASSERTION_RECORDTYPE_NOT_FOUND + '[' + TASK_RECORDTYPE_DEVELOPERNAME + ']');

			interviewId = ISTTestDataFactory_SchedulingTool.setupAndInsertTalentforceInterview(ISTTestDataFactory_SchedulingTool.InterviewOption.INTERVIEW_2, recruiter,  
																							   TALENTFORCE_CANDIDATE_SOURCE_NAME, TALENTFORCE_JOB_NAME, TALENTFORCE_CANDIDATE_NAME, TALENTFORCE_REFERRER_NAME);

			System.assertNotEquals(null, ASSERTION_UNABLE_TO_SETUP_TALENTFORCE);

			schedulingRequest = new IST_Interview_Scheduling_Request__c(Comments__c = INTERVIEW_SCHEDULING_REQUEST_COMMENTS, Interview_Type__c = INTERVIEW_SCHEDULING_REQUEST_TYPE);
			insert schedulingRequest;

			task = new Task(Status = TASK_STATUS, RecordTypeId = taskRecordTypes[0].Id, IST_Interview_Scheduling_Request__c = schedulingRequest.Id, WhatId = interviewId);
			insert task;
			
		}

		System.runAs(recruiter) {
			
			Test.startTest();
				
				taskReturned = IST_SchedulingRequestComponentController.loadExistingSchedulingTask(task.Id);
				
				System.assertNotEquals(null, taskReturned, ASSERTION_TASK_NOT_FOUND);				
				System.assertEquals(task.Id, taskReturned.Id, ASSERTION_TASK_INFORMATION_MISMATCH + '[Field: Task.Id]');
				System.assertEquals(task.Status, taskReturned.Status, ASSERTION_TASK_INFORMATION_MISMATCH + '[Field: Task.Status]');
				System.assertEquals(task.WhatId, taskReturned.WhatId, ASSERTION_TASK_INFORMATION_MISMATCH + '[Field: Task.WhatId]');
				System.assertEquals(task.IST_Interview_Scheduling_Request__c, taskReturned.IST_Interview_Scheduling_Request__c, ASSERTION_TASK_INFORMATION_MISMATCH + '[Field: Task.IST_Interview_Scheduling_Request__c]');
				System.assertEquals(schedulingRequest.Comments__c , taskReturned.IST_Interview_Scheduling_Request__r.Comments__c, ASSERTION_TASK_INFORMATION_MISMATCH + '[Field: Task.IST_Interview_Scheduling_Request__r.Comments__c]');

			Test.stopTest();
		}
	}

	// Tests that we are able to load existing Scheduling Tool task  related to a Talenforce - Interview 3 record.
	@isTest static void testLoadExistingSchedulingTaskInterview3() {
		final String ASSERTION_TASK_INFORMATION_MISMATCH = 'There is a mismatch with the Task information that was inserted and the Task information that is being retrieved.';
		final String ASSERTION_RECORDTYPE_NOT_FOUND = 'Unable to create test data. The Record Type was not found.';
		final String ASSERTION_UNABLE_TO_SETUP_TALENTFORCE = 'Unable to setup Talentforce interview data. Scheduling Tool task could not be tested until the Task has an interview record to be attached to';
		final String ASSERTION_TASK_NOT_FOUND = 'Unable to find the Task record that was setup for testing. Check if the runAs user has access to the Task record.';
		
		// Information to setup the Talentforce interview.
		final String TALENTFORCE_CANDIDATE_SOURCE_NAME = 'Employee Referral';
		final String TALENTFORCE_JOB_NAME = 'Job Name';
		final String TALENTFORCE_CANDIDATE_NAME = 'Candidate Name';
		final String TALENTFORCE_REFERRER_NAME = 'Employee Name';

		// Information to setup the Scheduling Tool task.
		final String TASK_RECORDTYPE_DEVELOPERNAME = 'IST_Scheduling_Tool';
		final String TASK_STATUS = 'Not Started';
		final String INTERVIEW_SCHEDULING_REQUEST_COMMENTS = 'Test Comments 123';
		final String INTERVIEW_SCHEDULING_REQUEST_TYPE = 'Phone';

		Task task;
		Task taskReturned;
		IST_Interview_Scheduling_Request__c schedulingRequest;
		User recruiter;
		PermissionSetAssignment recruiterPermissionSetAssignment;
		GroupMember recruiterGroupMember;
		List<RecordType> taskRecordTypes;
		Id interviewId;

		System.runAs(new User(Id = UserInfo.getUserId())) {
			List<sObject> recordsToInsert = new List<sObject>();

			recruiter = ISTTestDataFactory_SchedulingTool.getUser(null, ISTTestDataFactory_SchedulingTool.UserOption.RECRUITER, null, null);
			insert recruiter;

			// Setting up the permission set and group assignment for the Recruiter.
			Id permissionSetId = ISTTestDataFactory_SchedulingTool.getPermissionSet('IST_Scheduling_Tool_Recruiter').Id;
			recruiterPermissionSetAssignment = new PermissionSetAssignment(PermissionSetId = permissionSetId, AssigneeId = recruiter.Id);
			recordsToInsert.add(recruiterPermissionSetAssignment);

			Id groupId = ISTTestDataFactory_SchedulingTool.getGroup('IST_Scheduling_Tool_Recruiting').Id;
			recruiterGroupMember = new GroupMember(UserOrGroupId = recruiter.Id, GroupId = groupId);
			recordsToInsert.add(recruiterGroupMember);

			insert recordsToInsert;

			taskRecordTypes = [select Id, DeveloperName from RecordType where DeveloperName = :TASK_RECORDTYPE_DEVELOPERNAME limit 1];
			System.assertNotEquals(0, taskRecordTypes.size(), ASSERTION_RECORDTYPE_NOT_FOUND + '[' + TASK_RECORDTYPE_DEVELOPERNAME + ']');

			interviewId = ISTTestDataFactory_SchedulingTool.setupAndInsertTalentforceInterview(ISTTestDataFactory_SchedulingTool.InterviewOption.INTERVIEW_3, recruiter,  
																							   TALENTFORCE_CANDIDATE_SOURCE_NAME, TALENTFORCE_JOB_NAME, TALENTFORCE_CANDIDATE_NAME, TALENTFORCE_REFERRER_NAME);

			System.assertNotEquals(null, ASSERTION_UNABLE_TO_SETUP_TALENTFORCE);

			schedulingRequest = new IST_Interview_Scheduling_Request__c(Comments__c = INTERVIEW_SCHEDULING_REQUEST_COMMENTS, Interview_Type__c = INTERVIEW_SCHEDULING_REQUEST_TYPE);
			insert schedulingRequest;

			task = new Task(Status = TASK_STATUS, RecordTypeId = taskRecordTypes[0].Id, IST_Interview_Scheduling_Request__c = schedulingRequest.Id, WhatId = interviewId);
			insert task;
			
		}

		System.runAs(recruiter) {
			
			Test.startTest();
				
				taskReturned = IST_SchedulingRequestComponentController.loadExistingSchedulingTask(task.Id);
				
				System.assertNotEquals(null, taskReturned, ASSERTION_TASK_NOT_FOUND);				
				System.assertEquals(task.Id, taskReturned.Id, ASSERTION_TASK_INFORMATION_MISMATCH + '[Field: Task.Id]');
				System.assertEquals(task.Status, taskReturned.Status, ASSERTION_TASK_INFORMATION_MISMATCH + '[Field: Task.Status]');
				System.assertEquals(task.WhatId, taskReturned.WhatId, ASSERTION_TASK_INFORMATION_MISMATCH + '[Field: Task.WhatId]');
				System.assertEquals(task.IST_Interview_Scheduling_Request__c, taskReturned.IST_Interview_Scheduling_Request__c, ASSERTION_TASK_INFORMATION_MISMATCH + '[Field: Task.IST_Interview_Scheduling_Request__c]');
				System.assertEquals(schedulingRequest.Comments__c , taskReturned.IST_Interview_Scheduling_Request__r.Comments__c, ASSERTION_TASK_INFORMATION_MISMATCH + '[Field: Task.IST_Interview_Scheduling_Request__r.Comments__c]');

			Test.stopTest();
		}
	}

	// Tests that we are able to load a new Scheduling Tool task related to  a Talenforce - Interview 1 record.
	@isTest static void testLoadNewSchedulingTaskInterview1() {
		final String ASSERTION_TASK_INFORMATION_MISMATCH = 'There is a mismatch with the (in memory) Task information that was generate versus the expected values.';
		final String ASSERTION_RECORDTYPE_NOT_FOUND = 'Unable to create test data. The Record Type was not found.';
		final String ASSERTION_UNABLE_TO_SETUP_TALENTFORCE = 'Unable to setup Talentforce interview data. Scheduling Tool task could not be tested until the Task has an interview record to be attached to';
		
		// Information to setup the Talentforce interview.
		final String TALENTFORCE_CANDIDATE_SOURCE_NAME = 'Employee Referral';
		final String TALENTFORCE_JOB_NAME = 'Job Name';
		final String TALENTFORCE_CANDIDATE_NAME = 'Candidate Name';
		final String TALENTFORCE_REFERRER_NAME = 'Employee Name';

		// Information to setup the Scheduling Tool task.
		final String TASK_RECORDTYPE_DEVELOPERNAME = 'IST_Scheduling_Tool';
		final String TASK_STATUS = 'Not Started';

		Task taskReturned;
		User recruiter;
		PermissionSetAssignment recruiterPermissionSetAssignment;
		GroupMember recruiterGroupMember;
		List<RecordType> taskRecordTypes;
		Id interviewId;

		System.runAs(new User(Id = UserInfo.getUserId())) {
			List<sObject> recordsToInsert = new List<sObject>();

			recruiter = ISTTestDataFactory_SchedulingTool.getUser(null, ISTTestDataFactory_SchedulingTool.UserOption.RECRUITER, null, null);
			insert recruiter;

			// Setting up the permission set and group assignment for the Recruiter.
			Id permissionSetId = ISTTestDataFactory_SchedulingTool.getPermissionSet('IST_Scheduling_Tool_Recruiter').Id;
			recruiterPermissionSetAssignment = new PermissionSetAssignment(PermissionSetId = permissionSetId, AssigneeId = recruiter.Id);
			recordsToInsert.add(recruiterPermissionSetAssignment);

			Id groupId = ISTTestDataFactory_SchedulingTool.getGroup('IST_Scheduling_Tool_Recruiting').Id;
			recruiterGroupMember = new GroupMember(UserOrGroupId = recruiter.Id, GroupId = groupId);
			recordsToInsert.add(recruiterGroupMember);

			insert recordsToInsert;

			taskRecordTypes = [select Id, DeveloperName from RecordType where DeveloperName = :TASK_RECORDTYPE_DEVELOPERNAME limit 1];
			System.assertNotEquals(0, taskRecordTypes.size(), ASSERTION_RECORDTYPE_NOT_FOUND + '[' + TASK_RECORDTYPE_DEVELOPERNAME + ']');

			interviewId = ISTTestDataFactory_SchedulingTool.setupAndInsertTalentforceInterview(ISTTestDataFactory_SchedulingTool.InterviewOption.INTERVIEW_1, recruiter,
																							   TALENTFORCE_CANDIDATE_SOURCE_NAME, TALENTFORCE_JOB_NAME, TALENTFORCE_CANDIDATE_NAME, TALENTFORCE_REFERRER_NAME);

			System.assertNotEquals(null, ASSERTION_UNABLE_TO_SETUP_TALENTFORCE);
		}
	
		System.runAs(recruiter) {

			Test.startTest();
				
				taskReturned = IST_SchedulingRequestComponentController.loadNewSchedulingTask(interviewId);
								
				System.assertEquals(TASK_STATUS, taskReturned.Status, ASSERTION_TASK_INFORMATION_MISMATCH + '[Field: Task.Status]');
				System.assertEquals(interviewId, taskReturned.WhatId, ASSERTION_TASK_INFORMATION_MISMATCH + '[Field: Task.WhatId]');

			Test.stopTest();
		}
	}

	// Tests that we are able to load a new Scheduling Tool task related to  a Talenforce - Interview 2 record.
	@isTest static void testLoadNewSchedulingTaskInterview2() {
		final String ASSERTION_TASK_INFORMATION_MISMATCH = 'There is a mismatch with the (in memory) Task information that was generate versus the expected values.';
		final String ASSERTION_RECORDTYPE_NOT_FOUND = 'Unable to create test data. The Record Type was not found.';
		final String ASSERTION_UNABLE_TO_SETUP_TALENTFORCE = 'Unable to setup Talentforce interview data. Scheduling Tool task could not be tested until the Task has an interview record to be attached to';
		
		// Information to setup the Talentforce interview.
		final String TALENTFORCE_CANDIDATE_SOURCE_NAME = 'Employee Referral';
		final String TALENTFORCE_JOB_NAME = 'Job Name';
		final String TALENTFORCE_CANDIDATE_NAME = 'Candidate Name';
		final String TALENTFORCE_REFERRER_NAME = 'Employee Name';

		// Information to setup the Scheduling Tool task.
		final String TASK_RECORDTYPE_DEVELOPERNAME = 'IST_Scheduling_Tool';
		final String TASK_STATUS = 'Not Started';

		Task taskReturned;
		User recruiter;
		PermissionSetAssignment recruiterPermissionSetAssignment;
		GroupMember recruiterGroupMember;
		List<RecordType> taskRecordTypes;
		Id interviewId;

		System.runAs(new User(Id = UserInfo.getUserId())) {
			List<sObject> recordsToInsert = new List<sObject>();

			recruiter = ISTTestDataFactory_SchedulingTool.getUser(null, ISTTestDataFactory_SchedulingTool.UserOption.RECRUITER, null, null);
			insert recruiter;

			// Setting up the permission set and group assignment for the Recruiter.
			Id permissionSetId = ISTTestDataFactory_SchedulingTool.getPermissionSet('IST_Scheduling_Tool_Recruiter').Id;
			recruiterPermissionSetAssignment = new PermissionSetAssignment(PermissionSetId = permissionSetId, AssigneeId = recruiter.Id);
			recordsToInsert.add(recruiterPermissionSetAssignment);

			Id groupId = ISTTestDataFactory_SchedulingTool.getGroup('IST_Scheduling_Tool_Recruiting').Id;
			recruiterGroupMember = new GroupMember(UserOrGroupId = recruiter.Id, GroupId = groupId);
			recordsToInsert.add(recruiterGroupMember);

			insert recordsToInsert;

			taskRecordTypes = [select Id, DeveloperName from RecordType where DeveloperName = :TASK_RECORDTYPE_DEVELOPERNAME limit 1];
			System.assertNotEquals(0, taskRecordTypes.size(), ASSERTION_RECORDTYPE_NOT_FOUND + '[' + TASK_RECORDTYPE_DEVELOPERNAME + ']');

			interviewId = ISTTestDataFactory_SchedulingTool.setupAndInsertTalentforceInterview(ISTTestDataFactory_SchedulingTool.InterviewOption.INTERVIEW_2, recruiter,
																							   TALENTFORCE_CANDIDATE_SOURCE_NAME, TALENTFORCE_JOB_NAME, TALENTFORCE_CANDIDATE_NAME, TALENTFORCE_REFERRER_NAME);

			System.assertNotEquals(null, ASSERTION_UNABLE_TO_SETUP_TALENTFORCE);
		}
	
		System.runAs(recruiter) {

			Test.startTest();
				
				taskReturned = IST_SchedulingRequestComponentController.loadNewSchedulingTask(interviewId);
								
				System.assertEquals(TASK_STATUS, taskReturned.Status, ASSERTION_TASK_INFORMATION_MISMATCH + '[Field: Task.Status]');
				System.assertEquals(interviewId, taskReturned.WhatId, ASSERTION_TASK_INFORMATION_MISMATCH + '[Field: Task.WhatId]');

			Test.stopTest();
		}
	}

	// Tests that we are able to load a new Scheduling Tool task related to  a Talenforce - Interview 3 record.
	@isTest static void testLoadNewSchedulingTaskInterview3() {
		final String ASSERTION_TASK_INFORMATION_MISMATCH = 'There is a mismatch with the (in memory) Task information that was generate versus the expected values.';
		final String ASSERTION_RECORDTYPE_NOT_FOUND = 'Unable to create test data. The Record Type was not found.';
		final String ASSERTION_UNABLE_TO_SETUP_TALENTFORCE = 'Unable to setup Talentforce interview data. Scheduling Tool task could not be tested until the Task has an interview record to be attached to';
		
		// Information to setup the Talentforce interview.
		final String TALENTFORCE_CANDIDATE_SOURCE_NAME = 'Employee Referral';
		final String TALENTFORCE_JOB_NAME = 'Job Name';
		final String TALENTFORCE_CANDIDATE_NAME = 'Candidate Name';
		final String TALENTFORCE_REFERRER_NAME = 'Employee Name';

		// Information to setup the Scheduling Tool task.
		final String TASK_RECORDTYPE_DEVELOPERNAME = 'IST_Scheduling_Tool';
		final String TASK_STATUS = 'Not Started';

		Task taskReturned;
		User recruiter;
		PermissionSetAssignment recruiterPermissionSetAssignment;
		GroupMember recruiterGroupMember;
		List<RecordType> taskRecordTypes;
		Id interviewId;

		System.runAs(new User(Id = UserInfo.getUserId())) {
			List<sObject> recordsToInsert = new List<sObject>();

			recruiter = ISTTestDataFactory_SchedulingTool.getUser(null, ISTTestDataFactory_SchedulingTool.UserOption.RECRUITER, null, null);
			insert recruiter;

			// Setting up the permission set and group assignment for the Recruiter.
			Id permissionSetId = ISTTestDataFactory_SchedulingTool.getPermissionSet('IST_Scheduling_Tool_Recruiter').Id;
			recruiterPermissionSetAssignment = new PermissionSetAssignment(PermissionSetId = permissionSetId, AssigneeId = recruiter.Id);
			recordsToInsert.add(recruiterPermissionSetAssignment);

			Id groupId = ISTTestDataFactory_SchedulingTool.getGroup('IST_Scheduling_Tool_Recruiting').Id;
			recruiterGroupMember = new GroupMember(UserOrGroupId = recruiter.Id, GroupId = groupId);
			recordsToInsert.add(recruiterGroupMember);

			insert recordsToInsert;

			taskRecordTypes = [select Id, DeveloperName from RecordType where DeveloperName = :TASK_RECORDTYPE_DEVELOPERNAME limit 1];
			System.assertNotEquals(0, taskRecordTypes.size(), ASSERTION_RECORDTYPE_NOT_FOUND + '[' + TASK_RECORDTYPE_DEVELOPERNAME + ']');

			interviewId = ISTTestDataFactory_SchedulingTool.setupAndInsertTalentforceInterview(ISTTestDataFactory_SchedulingTool.InterviewOption.INTERVIEW_3, recruiter,
																							   TALENTFORCE_CANDIDATE_SOURCE_NAME, TALENTFORCE_JOB_NAME, TALENTFORCE_CANDIDATE_NAME, TALENTFORCE_REFERRER_NAME);

			System.assertNotEquals(null, ASSERTION_UNABLE_TO_SETUP_TALENTFORCE);
		}
	
		System.runAs(recruiter) {

			Test.startTest();
				
				taskReturned = IST_SchedulingRequestComponentController.loadNewSchedulingTask(interviewId);
								
				System.assertEquals(TASK_STATUS, taskReturned.Status, ASSERTION_TASK_INFORMATION_MISMATCH + '[Field: Task.Status]');
				System.assertEquals(interviewId, taskReturned.WhatId, ASSERTION_TASK_INFORMATION_MISMATCH + '[Field: Task.WhatId]');

			Test.stopTest();
		}
	}

}