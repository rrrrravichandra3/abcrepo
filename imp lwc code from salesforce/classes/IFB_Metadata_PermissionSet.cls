public class IFB_Metadata_PermissionSet {
	public enum Option { SIFT_RECRUITER, SIFT_INTERVIEWER, SIFT_HIRING_ORGANIZATION, SIFT_QUESTIONS }
	private static final Set<String> permissionSetNames;
	private static Map<String, PermissionSet> permissionSetMap;

	private static final String EXCEPTION_INVALID_OPTION = 'We do not know how to interpret the option provided. Not sure which Permision Set to return.';
	private static final String EXCEPTION_PERMISSION_SET_NOT_FOUND = 'A Permission Set is missing in the ORG or the mapping between the Permission Set Name and the option provided is wrong.';

	static {
		permissionSetNames = new Set<String>();
		permissionSetNames.add('IFB_Recruiting_Recruiter');
		permissionSetNames.add('IFB_Recruiting_Interviewer');
		permissionSetNames.add('IFB_Recruiting_Hiring_Organization');
		permissionSetNames.add('IFB_Recruiting_Questions');
	}

	public static PermissionSet getPermissionSet(Option opt) {
		PermissionSet permissionSet = null;

		if (permissionSetMap == null) {
			permissionSetMap = new Map<String, PermissionSet>();
			for (PermissionSet ps : [select Id, Name from PermissionSet where Name in :permissionSetNames]) {
				permissionSetMap.put(ps.Name, ps);
			}
		}

		if (opt == Option.SIFT_RECRUITER) {
			permissionSet = permissionSetMap.get('IFB_Recruiting_Recruiter');
		} else if (opt == Option.SIFT_INTERVIEWER) {
			permissionSet = permissionSetMap.get('IFB_Recruiting_Interviewer');
		} else if (opt == Option.SIFT_HIRING_ORGANIZATION) {
			permissionSet = permissionSetMap.get('IFB_Recruiting_Hiring_Organization');
		} else if (opt == Option.SIFT_QUESTIONS) {
			permissionSet = permissionSetMap.get('IFB_Recruiting_Questions');
		} else {
			throw new IFB_TestException(EXCEPTION_INVALID_OPTION + '[opt: ' + opt.name() + ']');
		}

		if (permissionSet == null) {
			throw new IFB_TestException(EXCEPTION_PERMISSION_SET_NOT_FOUND + '[opt: ' + opt.name() + ']');
		}
		return permissionSet;
	}

}