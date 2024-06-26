@isTest
public class IFBTestMetadata_Role {
	public enum Option { CSG_API }
	private static final Set<String> roleNames;
	private static Map<String, UserRole> rolesMap;

	private static final String EXCEPTION_INVALID_OPTION = 'We do not know how to interpret the option provided. Not sure which Role to return.';
	private static final String EXCEPTION_ROLE_NOT_FOUND = 'A Role is missing in the ORG or the mapping between the Role Name and the option provided is wrong.';

	static {
		roleNames = new Set<String>();
		roleNames.add('CSG API');
	}

	public static UserRole getRole(Option opt) {
		UserRole role = null;

		if (rolesMap == null) {
			rolesMap = new Map<String, UserRole>();
			for (UserRole r : [select Id, Name from UserRole where Name in :roleNames]) {
				rolesMap.put(r.Name, r);
			}
		}

		if (opt == Option.CSG_API) {
			role = rolesMap.get('CSG API');
		} else {
			throw new IFB_TestException(EXCEPTION_INVALID_OPTION + '[opt: ' + opt.name() + ']');
		}

		if (role == null) {
			throw new IFB_TestException(EXCEPTION_ROLE_NOT_FOUND + '[opt: ' + opt.name() + ']');
		}
		return role;
	}
}