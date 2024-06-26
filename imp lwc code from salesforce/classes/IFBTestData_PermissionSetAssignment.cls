@isTest
public class IFBTestData_PermissionSetAssignment {
	public enum Option { RECRUITER, RECRUITER_COORDINATOR, INTERVIEWER } 
	private static final String EXCEPTION_NO_USER_PROVIDED = 'Can not create PermissionSetAssignment because the User record was not provided or the Id of the user is null';
	private static final String EXCEPTION_INVALID_OPTION = 'Could not create the PermissionSetAssignment. We do not know how to interpret the option provided.';

	public static PermissionSetAssignment getPermmissionSetAssignment(PermissionSetAssignment permissionSetAssignment,
																	  Option opt, 
																	  User user) {
		if (permissionSetAssignment == null) {
			permissionSetAssignment = new PermissionSetAssignment();
		}

		// User is required.
		// If field was already set, it takes precedence
		if (permissionSetAssignment.AssigneeId == null) {
			if ( user != null && user.Id != null) {
				permissionSetAssignment.AssigneeId = user.Id;
			} else {
				throw new IFB_TestException(EXCEPTION_NO_USER_PROVIDED);
			}
		}	
		
		// PermissionSetAssignment setup specific for the provided option
		if (opt == Option.RECRUITER) {
			// If field was already set, it takes precedence
			if (permissionSetAssignment.PermissionSetId == null) {
				permissionSetAssignment.PermissionSetId = IFBTestMetadata_PermissionSet.getPermissionSet(IFBTestMetadata_PermissionSet.Option.SIFT_RECRUITER).Id;
			}
		} else if (opt == Option.RECRUITER_COORDINATOR) {
			// If field was already set, it takes precedence
			if (permissionSetAssignment.PermissionSetId == null) {
				permissionSetAssignment.PermissionSetId = IFBTestMetadata_PermissionSet.getPermissionSet(IFBTestMetadata_PermissionSet.Option.SIFT_QUESTIONS).Id;
			}
		} else if (opt == Option.INTERVIEWER) {
			// If field was already set, it takes precedence
			if (permissionSetAssignment.PermissionSetId == null) {
				permissionSetAssignment.PermissionSetId = IFBTestMetadata_PermissionSet.getPermissionSet(IFBTestMetadata_PermissionSet.Option.SIFT_INTERVIEWER).Id;
			}
		} else {
			throw new IFB_TestException(EXCEPTION_INVALID_OPTION + '[opt:' + opt.name() + ']');
		}

		return permissionSetAssignment;
	}
}