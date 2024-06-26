@isTest
private class ISTTest_SchedulingToolTaskViewOvdeCtrl {
	
	// When no IST_Scheduling_Tool_Hierarchy_Settings__c has been defined, user is redirected to the standard view page.
	@isTest static void testRedirectNoCustomSetting() {
		final String ASSERTION_NO_CUSTOM_SETTING = 'When no custom settings record (IST_Scheduling_Tool_Hierarchy_Settings__c) is defined, user should be redirected to standard view page.';
		final String ASSERTION_RECORDTYPE_NOT_FOUND = 'Unable to create test data. The Record Type was not found.';
		final String TASK_RECORDTYPE_DEVELOPERNAME = 'IST_Scheduling_Tool';

		Task task;
		User recruiter;
		PermissionSetAssignment recruiterPermissionSetAssignment;
		List<RecordType> taskRecordTypes;

		// runAs allows mixed DML operations.
		System.runAs(new User(Id = UserInfo.getUserId())) {

			recruiter = ISTTestDataFactory_SchedulingTool.getUser(null, ISTTestDataFactory_SchedulingTool.UserOption.RECRUITER, null, null);
			insert recruiter;

			Id permissionSetId = ISTTestDataFactory_SchedulingTool.getPermissionSet('IST_Scheduling_Tool_Recruiter').Id;
			recruiterPermissionSetAssignment = new PermissionSetAssignment(PermissionSetId = permissionSetId, AssigneeId = recruiter.Id);
			insert recruiterPermissionSetAssignment;

			taskRecordTypes = [select Id, DeveloperName from RecordType where DeveloperName = :TASK_RECORDTYPE_DEVELOPERNAME limit 1];
			System.assertNotEquals(0, taskRecordTypes.size(), ASSERTION_RECORDTYPE_NOT_FOUND + '[' + TASK_RECORDTYPE_DEVELOPERNAME + ']');
		}

		System.runAs(recruiter) {

			// Testing context: We need to assign a RecordType record that has the DeveloperName field populated otherwise the Standard Controller won't see that field value.
			// Runtime context: Don't need to do anything special. We are referencing the DeveloperName via the Visualforce markup as follow: <apex:outputField value="{!Task.RecordType.DeveloperName}" />
			task = new Task(RecordType = taskRecordTypes[0]);
			insert task;

			Test.startTest();
				Test.setCurrentPage(Page.IST_SchedulingToolTaskViewOverride);
				ApexPages.StandardController standardController = new ApexPages.StandardController(task);
				IST_SchedulingToolTaskViewOverrideCtrl extension = new IST_SchedulingToolTaskViewOverrideCtrl(standardController);
				String actualUrlRedirect = extension.pageRedirect().getUrl();
			Test.stopTest();

			String expectedUrlRedirect = '/'+ task.Id + '?nooverride=1';
			System.assertEquals(expectedUrlRedirect, actualUrlRedirect, ASSERTION_NO_CUSTOM_SETTING);
		}		
	}

	// When custom setting IST_Scheduling_Tool_Hierarchy_Settings__c.Enable_Scheduling_Tool__c == true, user is redirected to the Lightning view page.
	@isTest static void testRedirectUserEnabled() {
		final String ASSERTION_CUSTOM_SETTING_ENABLED = 'When the custom setting record (IST_Scheduling_Tool_Hierarchy_Settings__c) has the Enable_Scheduling_Tool__c field set to \'true\', user should be redirected to the Lightning view page.';
		final String ASSERTION_RECORDTYPE_NOT_FOUND = 'Unable to create test data. The Record Type was not found ';
		final String TASK_RECORDTYPE_DEVELOPERNAME = 'IST_Scheduling_Tool';

		Task task;
		User recruiter;
		PermissionSetAssignment recruiterPermissionSetAssignment;
		List<RecordType> taskRecordTypes;

		// runAs allows mixed DML operations.
		System.runAs(new User(Id = UserInfo.getUserId())) {
			
			recruiter = ISTTestDataFactory_SchedulingTool.getUser(null, ISTTestDataFactory_SchedulingTool.UserOption.RECRUITER, null, null);
			insert recruiter;

			Id permissionSetId = ISTTestDataFactory_SchedulingTool.getPermissionSet('IST_Scheduling_Tool_Recruiter').Id;
			recruiterPermissionSetAssignment = new PermissionSetAssignment(PermissionSetId = permissionSetId, AssigneeId = recruiter.Id);
			insert recruiterPermissionSetAssignment;

			taskRecordTypes = [select Id, DeveloperName from RecordType where DeveloperName = :TASK_RECORDTYPE_DEVELOPERNAME limit 1];
			System.assertNotEquals(0, taskRecordTypes.size(), ASSERTION_RECORDTYPE_NOT_FOUND + '[' + TASK_RECORDTYPE_DEVELOPERNAME + ']');
		}

		System.runAs(recruiter) {
			insert new IST_Scheduling_Tool_Hierarchy_Settings__c(Enable_Scheduling_Tool__c = true);

			// Testing context: We need to assign a RecordType record that has the DeveloperName field populated otherwise the Standard Controller won't see that field value.
			// Runtime context: Don't need to do anything special. We are referencing the DeveloperName via the Visualforce markup as follow: <apex:outputField value="{!Task.RecordType.DeveloperName}" />
			task = new Task(RecordType = taskRecordTypes[0]);
			insert task;

			Test.startTest();
				Test.setCurrentPage(Page.IST_SchedulingToolTaskViewOverride);
				ApexPages.StandardController standardController = new ApexPages.StandardController(task);
				IST_SchedulingToolTaskViewOverrideCtrl extension = new IST_SchedulingToolTaskViewOverrideCtrl(standardController);
				String actualUrlRedirect = extension.pageRedirect().getUrl();
			Test.stopTest();

			// Page redirect gives the page name in lower case.
			String expectedUrlRedirect = '/apex/ist_interviewschedulingrequest?tId='+ task.Id;
			System.assertEquals(expectedUrlRedirect, actualUrlRedirect, ASSERTION_CUSTOM_SETTING_ENABLED);
		}		
	}

	// When custom setting IST_Scheduling_Tool_Hierarchy_Settings__c.Enable_Scheduling_Tool__c == false, user is redirected to the to the standard view page.
	@isTest static void testRedirectUserDisable() {
		final String ASSERTION_CUSTOM_SETTING_DISABLED = 'When the custom setting record (IST_Scheduling_Tool_Hierarchy_Settings__c) has the Enable_Scheduling_Tool__c field set to \'false\', user should be redirected to the standard view page.';
		final String ASSERTION_RECORDTYPE_NOT_FOUND = 'Unable to create test data. The Record Type was not found ';
		final String TASK_RECORDTYPE_DEVELOPERNAME = 'IST_Scheduling_Tool';

		Task task;
		User recruiter;
		PermissionSetAssignment recruiterPermissionSetAssignment;
		List<RecordType> taskRecordTypes;

		// runAs allows mixed DML operations.
		System.runAs(new User(Id = UserInfo.getUserId())) {
			
			recruiter = ISTTestDataFactory_SchedulingTool.getUser(null, ISTTestDataFactory_SchedulingTool.UserOption.RECRUITER, null, null);
			insert recruiter;

			Id permissionSetId = ISTTestDataFactory_SchedulingTool.getPermissionSet('IST_Scheduling_Tool_Recruiter').Id;
			recruiterPermissionSetAssignment = new PermissionSetAssignment(PermissionSetId = permissionSetId, AssigneeId = recruiter.Id);
			insert recruiterPermissionSetAssignment;

			taskRecordTypes = [select Id, DeveloperName from RecordType where DeveloperName = :TASK_RECORDTYPE_DEVELOPERNAME limit 1];
			System.assertNotEquals(0, taskRecordTypes.size(), ASSERTION_RECORDTYPE_NOT_FOUND + '[' + TASK_RECORDTYPE_DEVELOPERNAME + ']');
		}

		System.runAs(recruiter) {
			insert new IST_Scheduling_Tool_Hierarchy_Settings__c(Enable_Scheduling_Tool__c = false);

			// Testing context: We need to assign a RecordType record that has the DeveloperName field populated otherwise the Standard Controller won't see that field value.
			// Runtime context: Don't need to do anything special. We are referencing the DeveloperName via the Visualforce markup as follow: <apex:outputField value="{!Task.RecordType.DeveloperName}" />
			task = new Task(RecordType = taskRecordTypes[0]);
			insert task;

			Test.startTest();
				Test.setCurrentPage(Page.IST_SchedulingToolTaskViewOverride);
				ApexPages.StandardController standardController = new ApexPages.StandardController(task);
				IST_SchedulingToolTaskViewOverrideCtrl extension = new IST_SchedulingToolTaskViewOverrideCtrl(standardController);
				String actualUrlRedirect = extension.pageRedirect().getUrl();
			Test.stopTest();

			// Page redirect gives the page name in lower case.
			String expectedUrlRedirect = '/'+ task.Id + '?nooverride=1';
			System.assertEquals(expectedUrlRedirect, actualUrlRedirect, ASSERTION_CUSTOM_SETTING_DISABLED);
		}		
	}

	// When the RecordType.DeveloperName is not the one used by the Scheduling Tool, user is ALWAYS redirected to the to the standard view page
	// regardless if she/he has acess to the Scheduling Tool.
	@isTest static void testRedirectUserNonSchedulingToolRecordType() {
		final String ASSERTION_CUSTOM_SETTING_DISABLED = 'When the custom setting record (IST_Scheduling_Tool_Hierarchy_Settings__c) has the Enable_Scheduling_Tool__c field set to \'false\', user should be redirected to the standard view page.';
		final String ASSERTION_RECORDTYPE_NOT_FOUND = 'Unable to create test data. The Record Type was not found ';
		final String TASK_RECORDTYPE_DEVELOPERNAME = 'Schedule_Interview'; // This is not used by the Scheduling Tool.

		Task task;
		User recruiter;
		PermissionSetAssignment recruiterPermissionSetAssignment;
		List<RecordType> taskRecordTypes;

		// runAs allows mixed DML operations.
		System.runAs(new User(Id = UserInfo.getUserId())) {
			
			recruiter = ISTTestDataFactory_SchedulingTool.getUser(null, ISTTestDataFactory_SchedulingTool.UserOption.RECRUITER, null, null);
			insert recruiter;

			Id permissionSetId = ISTTestDataFactory_SchedulingTool.getPermissionSet('IST_Scheduling_Tool_Recruiter').Id;
			recruiterPermissionSetAssignment = new PermissionSetAssignment(PermissionSetId = permissionSetId, AssigneeId = recruiter.Id);
			insert recruiterPermissionSetAssignment;

			taskRecordTypes = [select Id, DeveloperName from RecordType where DeveloperName = :TASK_RECORDTYPE_DEVELOPERNAME limit 1];
			System.assertNotEquals(0, taskRecordTypes.size(), ASSERTION_RECORDTYPE_NOT_FOUND + '[' + TASK_RECORDTYPE_DEVELOPERNAME + ']');
		}

		System.runAs(recruiter) {
			insert new IST_Scheduling_Tool_Hierarchy_Settings__c(Enable_Scheduling_Tool__c = true);

			// Testing context: We need to assign a RecordType record that has the DeveloperName field populated otherwise the Standard Controller won't see that field value.
			// Runtime context: Don't need to do anything special. We are referencing the DeveloperName via the Visualforce markup as follow: <apex:outputField value="{!Task.RecordType.DeveloperName}" />
			task = new Task(RecordType = taskRecordTypes[0]);
			insert task;

			Test.startTest();
				Test.setCurrentPage(Page.IST_SchedulingToolTaskViewOverride);
				ApexPages.StandardController standardController = new ApexPages.StandardController(task);
				IST_SchedulingToolTaskViewOverrideCtrl extension = new IST_SchedulingToolTaskViewOverrideCtrl(standardController);
				String actualUrlRedirect = extension.pageRedirect().getUrl();
			Test.stopTest();

			// Page redirect gives the page name in lower case.
			String expectedUrlRedirect = '/'+ task.Id + '?nooverride=1';
			System.assertEquals(expectedUrlRedirect, actualUrlRedirect, ASSERTION_CUSTOM_SETTING_DISABLED);
		}		
	}	
}