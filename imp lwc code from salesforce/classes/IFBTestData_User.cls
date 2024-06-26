// GHE Rollout Test Comment - 1/11/2018
@isTest
public with sharing class IFBTestData_User {
	public enum Option { EMPLOYEE, MANAGER, CSG_API}
	private static final String EXCEPTION_INVALID_PROFILE = 'The provided Profile record can not be used for the test User setup because it does not have an Id value.';
	private static final String EXCEPTION_INVALID_ROLE = 'The provided Role record can not be used for the test User setup because it does not have an Id value.';
	private static final String EXCEPTION_INVALID_OPTION = 'Could not create the test User. We do not know how to interpret the option provided.';
	private static Map<Option, Integer> userIndexByOption;

	static {
		userIndexByOption = new Map<Option, Integer>();
		userIndexByOption.put(Option.EMPLOYEE, 1);
		userIndexByOption.put(Option.MANAGER, 1);
		userIndexByOption.put(Option.CSG_API, 1);
	}

	public static User getUser(User user, Option opt, Profile profile, UserRole role) {
		// Standard User record setup
		if (user == null) {
			user = new User();
		}

		user.Alias = (user.Alias == null) ? 'sift' : user.Alias;
		user.Email = (user.Email == null) ? 'sift.test@example.com' : user.Email; 
        user.EmailEncodingKey = (user.EmailEncodingKey == null) ? 'UTF-8' : user.EmailEncodingKey;
        user.FirstName = (user.FirstName == null) ? 'SIFT' : user.FirstName;
        user.LastName = (user.LastName == null) ? 'Test': user.LastName;
        user.LanguageLocaleKey  = (user.LanguageLocaleKey == null) ? 'en_US' : user.LanguageLocaleKey;
        user.LocaleSidKey = (user.LocaleSidKey == null) ? 'en_US' : user.LocaleSidKey;
        user.TimeZoneSidKey = (user.TimeZoneSidKey == null) ? 'America/Los_Angeles' : user.TimeZoneSidKey;

		// If related records are provided, those are used.
		if ( profile != null && profile.Id != null) {
			user.ProfileId = profile.Id;
		} else if (profile != null) {
			throw new IFB_TestException(EXCEPTION_INVALID_PROFILE + '[profile:' + profile + ']');
		}

		// If related records are provided, those are used.
		if ( role != null && role.Id != null) {
			user.UserRoleId = role.Id;
		} else if (role != null) {
			throw new IFB_TestException(EXCEPTION_INVALID_ROLE + '[role:' + role + ']');
		}
		
		// User setup specific for the provided option
		if (opt == Option.EMPLOYEE) {
			// Provided parameters take precendence over option specific settings
			if (user.UserName == null) {
				user.UserName = 'sift.employee.'+ userIndexByOption.get(opt) +'@example.com';
				userIndexByOption.put(opt, userIndexByOption.get(opt) + 1);
			}
			if (user.ProfileId == null) {
				user.ProfileId = IFBTestMetadata_Profile.getProfile(IFBTestMetadata_Profile.Option.EMPLOYEE).Id;
			}
		} else if (opt == Option.MANAGER) {
			// Provided parameters take precendence over option specific settings
			if (user.UserName == null) {
				user.UserName = 'sift.manager.'+ userIndexByOption.get(opt) +'@example.com';
				userIndexByOption.put(opt, userIndexByOption.get(opt) + 1);
			}
			if (user.ProfileId == null) {
				user.ProfileId = IFBTestMetadata_Profile.getProfile(IFBTestMetadata_Profile.Option.MANAGER).Id;
			}
		} else if (opt == Option.CSG_API) {
			// Provided parameters take precendence over option specific settings
			if (user.UserName == null) {
				user.UserName = 'sift.csgapi.'+ userIndexByOption.get(opt) +'@example.com';
				userIndexByOption.put(opt, userIndexByOption.get(opt) + 1);
			}
			if (user.ProfileId == null) {
				user.ProfileId = IFBTestMetadata_Profile.getProfile(IFBTestMetadata_Profile.Option.API_INTERNAL_CSG).Id;
			}
			if (user.UserRoleId == null) {
				user.UserRoleId = IFBTestMetadata_Role.getRole(IFBTestMetadata_Role.Option.CSG_API).Id;
			}
		} else {
			throw new IFB_TestException(EXCEPTION_INVALID_OPTION + '[opt:' + opt.name() + ']');
		}

		return user;
	}

}