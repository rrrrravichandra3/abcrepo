@isTest
public class IFBTestData_GroupMember {
	public enum Option { SIFT_RECRUITING, SIFT_QUESTIONS, CSG_API } 
	private static final String EXCEPTION_NO_USER_PROVIDED = 'Can not create GroupMember because the User record was not provided or the Id of the user is null';
	private static final String EXCEPTION_NO_ROLE_PROVIDED = 'Can not create GroupMember because the Role record was not provided or the Id of the Role is null';
	private static final String EXCEPTION_INVALID_OPTION = 'Could not create the GroupMember. We do not know how to interpret the option provided.';

	public static GroupMember getGroupMember(GroupMember groupMember, Option opt, User user) {
		if (groupMember == null) {
			groupMember = new GroupMember();
		}

		// User is required.
		// If field was already set, it takes precedence
		if (groupMember.UserOrGroupId == null) {
			if ( user != null && user.Id != null) {
				groupMember.UserOrGroupId = user.Id;
			} else {
				throw new IFB_TestException(EXCEPTION_NO_USER_PROVIDED);
			}
		}	
		
		// PermissionSetAssignment setup specific for the provided option
		if (opt == Option.SIFT_RECRUITING) {
			// If field was already set, it takes precedence
			if (groupMember.GroupId == null) {
				groupMember.GroupId = IFBTestMetadata_Group.getGroup(IFBTestMetadata_Group.Option.SIFT_RECRUITING).Id;
			}
		} else if (opt == Option.CSG_API) {
			// If field was already set, it takes precedence
			if (groupMember.GroupId == null) {
				groupMember.GroupId = IFBTestMetadata_Group.getGroup(IFBTestMetadata_Group.Option.CSG_API).Id;
			}
		} else {
			throw new IFB_TestException(EXCEPTION_INVALID_OPTION + '[opt:' + opt.name() + ']');
		}

		return groupMember;
	}
}