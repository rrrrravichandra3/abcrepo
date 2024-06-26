@isTest
public class IFBTestMetadata_Profile {
	public enum Option { EMPLOYEE, MANAGER, SYSTEM_ADMIN, LITTLE_SYSTEM_ADMIN, API_INTERNAL_CSG}
	private static final Set<String> profileNames;
	private static Map<String, Profile> profilesMap;

	private static final String EXCEPTION_INVALID_OPTION = 'We do not know how to interpret the option provided. Not sure which Profile to return.';
	private static final String EXCEPTION_PROFILE_NOT_FOUND = 'A Profile is missing in the ORG or the mapping between the Profile Name and the option provided is wrong.';

	static {
		profileNames = new Set<String>();
		profileNames.add('Employee');
		profileNames.add('Manager');
		profileNames.add('System Administrator');
		profileNames.add('systemadministrator');
		profileNames.add('API Internal - CSG');
	}

	public static Profile getProfile(Option opt) {
		Profile profile = null;

		if (profilesMap == null) {
			profilesMap = new Map<String, Profile>();
			for (Profile p : [select Id, Name from Profile where Name in :profileNames]) {
				profilesMap.put(p.Name, p);
			}
		}

		if (opt == Option.EMPLOYEE) {
			profile = profilesMap.get('Employee');
		} else if (opt == Option.MANAGER) {
			profile = profilesMap.get('Manager');
		} else if (opt == Option.SYSTEM_ADMIN) {
			profile = profilesMap.get('System Administrator');
		} else if (opt == Option.LITTLE_SYSTEM_ADMIN) {
			profile = profilesMap.get('systemadministrator');
		} else if (opt == Option.API_INTERNAL_CSG) {
			profile = profilesMap.get('API Internal - CSG');
		} else {
			throw new IFB_TestException(EXCEPTION_INVALID_OPTION + '[opt: ' + opt.name() + ']');
		}

		if (profile == null) {
			throw new IFB_TestException(EXCEPTION_PROFILE_NOT_FOUND + '[opt: ' + opt.name() + ']');
		}
		return profile;
	}

}