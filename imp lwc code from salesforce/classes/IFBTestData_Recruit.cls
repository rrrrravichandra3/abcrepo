@isTest
public class IFBTestData_Recruit {
	public enum Option { CSG_PA, SALES_EBU }
	private static final String EXCEPTION_INVALID_REFERRER = 'The provided Refererrer (Contact) record can not be used for the test Recruit setup because it does not have an Id value.';
	private static final String EXCEPTION_INVALID_OPTION = 'Could not create the test Recruit. We do not know how to interpret the option provided.';
	// Groups
	private static final String GROUP_CSG = 'CSG';
	private static final String GROUP_SALES = 'Sales';
	// Positions
	private static final String POSITION_PA = 'Program Architect';
	private static final String POSITION_EBU = 'Enterprise Business Unit';

	public static IFB_Interview_Candidate__c getRecruit(IFB_Interview_Candidate__c recruit,
														Option opt, Contact referredBy) {
		//Standard Recruit setup
		if (recruit == null) {
			recruit = new IFB_Interview_Candidate__c();

		}

		recruit.First_Name__c = (recruit.First_Name__c == null) ? 'Recruit' : recruit.First_Name__c;
		recruit.Last_Name__c = (recruit.Last_Name__c == null) ? 'Test' : recruit.Last_Name__c;
		recruit.Region__c = (recruit.Region__c == null) ? 'AMER' : recruit.Region__c;
		recruit.Zone__c = (recruit.Zone__c == null) ? 'AMER West' : recruit.Zone__c;
		recruit.City__c = (recruit.City__c == null) ? 'San Francisco' : recruit.City__c;
		recruit.State__c = (recruit.State__c == null) ? 'CA' : recruit.State__c;
		recruit.Email__c = (recruit.Email__c == null) ? 'recruit.test@example.com' : recruit.Email__c;

		// If related records are provided, those are used.
		if ( referredBy != null && referredBy.Id != null) {
			recruit.Referred_By__c = referredBy.Id;
		} else if (referredBy != null) {
			throw new IFB_TestException(EXCEPTION_INVALID_REFERRER + '[referredBy:' + referredBy + ']');
		}

		// Recruit setup specific for the provided option
		if (opt == Option.SALES_EBU) {
			// Values provided as parameters take precendence over option specific settings
			recruit.Group__c = (recruit.Group__c  == null) ? GROUP_SALES : recruit.Group__c ;
			recruit.Position__c = (recruit.Position__c  == null) ? POSITION_EBU : recruit.Position__c ;

		} else if (opt == Option.CSG_PA) {
			// Values provided as parameters take precendence over option specific settings
			recruit.Group__c = (recruit.Group__c  == null) ? GROUP_CSG : recruit.Group__c ;
			recruit.Position__c = (recruit.Position__c  == null) ? POSITION_PA : recruit.Position__c ;

		} else {
			throw new IFB_TestException(EXCEPTION_INVALID_OPTION + '[opt:' + opt.name() + ']');
		}

		return recruit;
	}

}