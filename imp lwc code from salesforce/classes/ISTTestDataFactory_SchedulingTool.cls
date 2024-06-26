@isTest
public class ISTTestDataFactory_SchedulingTool {

	public enum UserOption { RECRUITER, RECRUITER_COORDINATOR, RECRUITER_COORDINATOR_MANAGER, HIRING_MANAGER }
	public enum InterviewOption { INTERVIEW_1, INTERVIEW_2, INTERVIEW_3 }

	private static final String EXCEPTION_INVALID_PROFILE = 'The provided Profile record can not be used for the test User setup because it does not have an Id value.';
	private static final String EXCEPTION_INVALID_ROLE = 'The provided Role record can not be used for the test User setup because it does not have an Id value.';
	private static final String EXCEPTION_INVALID_OPTION = 'Could not create the test User. We do not know how to interpret the option provided.';
	private static final String EXCEPTION_PROFILE_NOT_FOUND = 'Was not able to find the Profile. Unable to setup the test user.';
	private static final String EXCEPTION_PERMISSION_SET_NOT_FOUND = 'Was not able to find the Permission Set. Unable to setup the test user.';
	private static final String EXCEPTION_GROUP_NOT_FOUND = 'Was not able to find the Group. Unable to setup the test user.';

	private static final Set<String> profileNames;
	private static Map<String, Profile> profilesMap;
	private static final Set<String> permissionSetNames;
	private static Map<String, PermissionSet> permissionSetMap;
	private static final Set<String> groupNames;
	private static Map<String, Group> groupMap;
	private static Map<UserOption, Integer> userIndexByOption;

	static {
		profileNames = new Set<String>();
		profileNames.add('Employee');
		profileNames.add('Manager');
		profileNames.add('System Administrator');
		profileNames.add('systemadministrator');

		permissionSetNames = new Set<String>();
		permissionSetNames.add('IST_Scheduling_Tool_Recruiter');
		permissionSetNames.add('IST_Scheduling_Tool_Recruiter_Coordinator');
		permissionSetNames.add('IST_Scheduling_Tool_Recruiter_Coordinator_Manager');

		groupNames = new Set<String>();
		groupNames.add('IST_Scheduling_Tool_Recruiting');

		userIndexByOption = new Map<UserOption, Integer>();
		userIndexByOption.put(UserOption.RECRUITER, 1);
		userIndexByOption.put(UserOption.RECRUITER_COORDINATOR, 1);
		userIndexByOption.put(UserOption.RECRUITER_COORDINATOR_MANAGER, 1);
		userIndexByOption.put(UserOption.HIRING_MANAGER, 1);
	}

	public static User getUser(User user, UserOption opt, Profile profile, UserRole role) {
		// Standard User record setup
		if (user == null) {
			user = new User();
		}

		user.Alias = (user.Alias == null) ? 'ist' : user.Alias;
		user.Email = (user.Email == null) ? 'ist.test@example.com' : user.Email; 
        user.EmailEncodingKey = (user.EmailEncodingKey == null) ? 'UTF-8' : user.EmailEncodingKey;
        user.FirstName = (user.FirstName == null) ? 'IST' : user.FirstName;
        user.LastName = (user.LastName == null) ? 'Test': user.LastName;
        user.LanguageLocaleKey  = (user.LanguageLocaleKey == null) ? 'en_US' : user.LanguageLocaleKey;
        user.LocaleSidKey = (user.LocaleSidKey == null) ? 'en_US' : user.LocaleSidKey;
        user.TimeZoneSidKey = (user.TimeZoneSidKey == null) ? 'America/Los_Angeles' : user.TimeZoneSidKey;

		// If related records are provided, those are used.
		if ( profile != null && profile.Id != null) {
			user.ProfileId = profile.Id;
		} else if (profile != null) {
			throw new IST_TestException(EXCEPTION_INVALID_PROFILE + '[profile:' + profile + ']');
		}

		// If related records are provided, those are used.
		if ( role != null && role.Id != null) {
			user.UserRoleId = role.Id;
		} else if (role != null) {
			throw new IST_TestException(EXCEPTION_INVALID_ROLE + '[role:' + role + ']');
		}
		
		// User setup specific for the provided option
		if (opt == UserOption.RECRUITER) {
			// Provided parameters take precendence over option specific settings
			if (user.UserName == null) {
				user.UserName = 'ist.recruiter.'+ userIndexByOption.get(opt) +'@example.com';
				userIndexByOption.put(opt, userIndexByOption.get(opt) + 1);
			}
			if (user.ProfileId == null) {
				user.ProfileId = ISTTestDataFactory_SchedulingTool.getProfile('Employee').Id;
			}
		} else if (opt == UserOption.RECRUITER_COORDINATOR) {
			// Provided parameters take precendence over option specific settings
			if (user.UserName == null) {
				user.UserName = 'ist.recruitercoordinator.'+ userIndexByOption.get(opt) +'@example.com';
				userIndexByOption.put(opt, userIndexByOption.get(opt) + 1);
			}
			if (user.ProfileId == null) {
				user.ProfileId = ISTTestDataFactory_SchedulingTool.getProfile('Employee').Id;
			}
		} else if (opt == UserOption.RECRUITER_COORDINATOR_MANAGER) {
			// Provided parameters take precendence over option specific settings
			if (user.UserName == null) {
				user.UserName = 'ist.rcmanager.'+ userIndexByOption.get(opt) +'@example.com';
				userIndexByOption.put(opt, userIndexByOption.get(opt) + 1);
			}
			if (user.ProfileId == null) {
				user.ProfileId = ISTTestDataFactory_SchedulingTool.getProfile('Manager').Id;
			}
		} else if (opt == UserOption.HIRING_MANAGER) {
			// Provided parameters take precendence over option specific settings
			if (user.UserName == null) {
				user.UserName = 'ist.hmanager.'+ userIndexByOption.get(opt) +'@example.com';
				userIndexByOption.put(opt, userIndexByOption.get(opt) + 1);
			}
			if (user.ProfileId == null) {
				user.ProfileId = ISTTestDataFactory_SchedulingTool.getProfile('Manager').Id;
			}
		} else {
			throw new IST_TestException(EXCEPTION_INVALID_OPTION + '[opt:' + opt.name() + ']');
		}

		return user;
	}

	public static Profile getProfile(String profileName) {
		Profile profile = null;

		if (profilesMap == null) {
			profilesMap = new Map<String, Profile>();
			for (Profile p : [select Id, Name from Profile where Name in :profileNames]) {
				profilesMap.put(p.Name, p);
			}
		}

		if (profilesMap.containsKey(profileName) == true) {
			profile = profilesMap.get(profileName);
		} else {
			throw new IST_TestException(EXCEPTION_PROFILE_NOT_FOUND + '[profileName:' + profileName + ']');
		}
		return profile;
	}

	public static PermissionSet getPermissionSet(String permissionSetName) {
		PermissionSet permissionSet = null;

		if (permissionSetMap == null) {
			permissionSetMap = new Map<String, PermissionSet>();
			for (PermissionSet ps : [select Id, Name from PermissionSet where Name in :permissionSetNames]) {
				permissionSetMap.put(ps.Name, ps);
			}
		}

		if (permissionSetMap.containsKey(permissionSetName) == true) {
			permissionSet = permissionSetMap.get(permissionSetName);
		} else {
			throw new IST_TestException(EXCEPTION_PERMISSION_SET_NOT_FOUND + '[permissionSetName:' + permissionSetName + ']');
		}

		return permissionSet;
	}

	public static Group getGroup(String groupDeveloperName) {
		Group groupToReturn = null;

		if (groupMap == null) {
			groupMap = new Map<String, Group>();
			for (Group g : [select Id, DeveloperName from Group where DeveloperName in :groupNames]) {
				groupMap.put(g.DeveloperName, g);
			}
		}

		if (groupMap.containsKey(groupDeveloperName) == true) {
			groupToReturn = groupMap.get(groupDeveloperName);
		} else {
			throw new IST_TestException(EXCEPTION_GROUP_NOT_FOUND + '[groupDeveloperName:' + groupDeveloperName + ']');
		}

		return groupToReturn;
	}

	public static Id setupAndInsertTalentforceInterview(InterviewOption opt, User recruiter, String candidateSourceName, String jobName, String candidateName, String referrerName) {

		// We disable trigger execution for this data setup.
		IST_TriggerControl.disableContactTriggersExecutionOnTests = true;
        IST_TriggerControl.disableJobTriggersExecutionOnTests = true;
        IST_TriggerControl.disableApplicationTriggersExecutionOnTests = true;
        IST_TriggerControl.disableInterview1TriggersExecutionOnTests = true;
		
		Id interviewId;

		ts2__Source__c candidateSource;
		Contact candidate;
		Contact referrer;
		User manager;
		ts2__Job__c job;
		ts2__Application__c application;
		ts2extams__Custom_stage_2__c interview1;
		ts2extams__Custom_stage_3__c interview2;
		ts2extams__Custom_stage_4__c interview3;

		// NOTE: As much as possible we group the records to be inserted in a single DML operation.
		List<sObject> recordsToInsert = new List<sObject>();

		// Inserting the "Candidate Source" and "Manager"
		candidateSource = new ts2__Source__c(Name = candidateSourceName);
		recordsToInsert.add(candidateSource);

		// Inserting the "Manager"
		manager =  ISTTestDataFactory_SchedulingTool.getUser(null, ISTTestDataFactory_SchedulingTool.UserOption.HIRING_MANAGER,
															 null, null);

		recordsToInsert.add(manager);

		insert recordsToInsert;
		recordsToInsert.clear();

		// Inserting the "Job", "Candidate" and "Referrer" records.
		job = new ts2__Job__c(Name = jobName);
		job.ts2__Manager__c = manager.Id;
		// To make tasks visibible to "Recruiter" we make him the owner of the Job record.
		job.OwnerId = recruiter.Id; 
		recordsToInsert.add(job);

		candidate = new Contact(LastName = candidateName);
		candidate.ts2__Candidate_Source__c = candidateSource.Id;
		recordsToInsert.add(candidate);

		referrer = new Contact(LastName = referrerName);
		recordsToInsert.add(referrer);		

		insert recordsToInsert;
		recordsToInsert.clear();

		// Inserting the "Application" record.
		application = new ts2__Application__c();
		application.ts2__Job__c = job.Id;
		application.ts2__Candidate_Contact__c = candidate.Id;
		application.ts2__referred_by__c = referrer.Id;
		insert application;

		// Inserting the "Interview" record.
		if (opt == InterviewOption.INTERVIEW_1) {		
			interview1 = new ts2extams__Custom_stage_2__c();
			interview1.ts2extams__Job__c = job.Id;
			interview1.ts2extams__Contact__c = candidate.Id;
			interview1.ts2extams__Application__c = application.Id;
			interview1.Hiring_Manager__c = manager.Id;
			interview1.Primary_Recruiter__c = recruiter.Id;
			insert interview1;

			interviewId = interview1.Id;

		} else if (opt == InterviewOption.INTERVIEW_2) {
			interview2 = new ts2extams__Custom_stage_3__c();
			interview2.ts2extams__Job__c = job.Id;
			interview2.ts2extams__Contact__c = candidate.Id;
			interview2.ts2extams__Application__c = application.Id;
			interview2.Hiring_Manager__c = manager.Id;
			interview2.Primary_Recruiter__c = recruiter.Id;
			insert interview2;

			System.debug('interview2: ' + interview2);

			interviewId = interview2.Id;

		} else if (opt == InterviewOption.INTERVIEW_3) {
			interview3 = new ts2extams__Custom_stage_4__c();
			interview3.ts2extams__Job__c = job.Id;
			interview3.ts2extams__Contact__c = candidate.Id;
			interview3.ts2extams__Application__c = application.Id;
			interview3.Hiring_Manager__c = manager.Id;
			interview3.Primary_Recruiter__c = recruiter.Id;
			insert interview3;

			interviewId = interview3.Id;
		}

		return interviewId;
	}

}