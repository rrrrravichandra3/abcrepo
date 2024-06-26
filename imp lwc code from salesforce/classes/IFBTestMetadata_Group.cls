@isTest
public class IFBTestMetadata_Group {
	public enum Option { SIFT_RECRUITING, SIFT_QUESTIONS, CSG_API }
	private static final Set<String> groupNames;
	private static Map<String, Group> groupMap;

	private static final String EXCEPTION_INVALID_OPTION = 'We do not know how to interpret the option provided. Not sure which Public Group to return.';
	private static final String EXCEPTION_GROUP_NOT_FOUND = 'A Public Group is missing in the ORG or the mapping between the Public Group Name and the option provided is wrong.';

	static {
		// DeveloperName field.
		groupNames = new Set<String>();
		groupNames.add('SIFT_Recruiting');
		groupNames.add('SIFT_Questions');
		groupNames.add('CSG_API');
	}

	public static Group getGroup(Option opt) {
		Group publicGroup = null;

		if (groupMap == null) {
			groupMap = new Map<String, Group>();
			for (Group g : [select Id, DeveloperName from Group where DeveloperName in :groupNames]) {
				groupMap.put(g.DeveloperName, g);
			}
		}

		if (opt == Option.SIFT_RECRUITING) {
			publicGroup = groupMap.get('SIFT_Recruiting');
		} else if (opt == Option.SIFT_QUESTIONS) {
			publicGroup = groupMap.get('SIFT_Questions');
		} else if (opt == Option.CSG_API) {
			publicGroup = groupMap.get('CSG_API');
		} else {
			throw new IFB_TestException(EXCEPTION_INVALID_OPTION + '[opt: ' + opt.name() + ']');
		}

		if (publicGroup == null) {
			throw new IFB_TestException(EXCEPTION_GROUP_NOT_FOUND + '[opt: ' + opt.name() + ']');
		}
		return publicGroup;
	}
}