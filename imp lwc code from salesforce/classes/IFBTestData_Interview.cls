@isTest
public class IFBTestData_Interview {
	public enum Option { CSG_TECHNICAL, CSG_CONSULTING, CSG_PANEL, SALES_FIRST }
	public static Map<String, Id> recordTypeMap;

	// Record Type Names
	public static final String RECORDTYPE_CSG_TECHNICAL = 'CSG - Technical/First';
	public static final String RECORDTYPE_CSG_CONSULTING = 'CSG - Consulting/Second';
	public static final String RECORDTYPE_CSG_PANEL = 'CSG - Panel Interview';
	public static final String RECORDTYPE_SALES_FIRST = 'Sales - 1st stage interview (HM phone screen/onsite, chrono/panel)';

	// Data setup exception messages
	private static final String EXCEPTION_INVALID_RECRUIT = 'The provided Recruit record can not be used for the test Interview setup because it does not have an Id value.';
	private static final String EXCEPTION_INVALID_INTERVIEWER = 'The provided User record for the Interviewer field, can not be used for the test Interview setup because it does not have an Id value.';
	private static final String EXCEPTION_INVALID_INTERVIEWER_2 = 'The provided User record for the Interviewer 2 field, can not be used for the test Interview setup because it does not have an Id value.';
	private static final String EXCEPTION_INVALID_INTERVIEWER_3 = 'The provided User record for the Interviewer 3 field, can not be used for the test Interview setup because it does not have an Id value.';
	private static final String EXCEPTION_INVALID_INTERVIEWER_4 = 'The provided User record for the Interviewer 4 field, can not be used for the test Interview setup because it does not have an Id value.';
	private static final String EXCEPTION_INVALID_INTERVIEWER_5 = 'The provided User record for the Interviewer 5 field, can not be used for the test Interview setup because it does not have an Id value.';
	private static final String EXCEPTION_INVALID_HIRING_MANAGER = 'The provided User record for the Hiring Manager field, can not be used for the test Interview setup because it does not have an Id value.';
	private static final String EXCEPTION_INVALID_OPTION = 'Could not create the test Interview. We do not know how to interpret the option provided.';

	static {
		recordTypeMap = new Map<String, Id>();
		for (RecordType rt : [select Id, Name  from RecordType where sobjectType = :'IFB_Interview__c']) {
			recordTypeMap.put(rt.Name, rt.Id);
		}
	}

	public static IFB_Interview__c getInterview(IFB_Interview__c interview,
												Option opt,
												IFB_Interview_Candidate__c recruit, 
												User interviewer,
												User interviewer2,
												User interviewer3,
												User interviewer4,
												User interviewer5, 
												User hiringManager) {
		//Standard Recruit setup
		if (interview == null) {
			interview = new IFB_Interview__c();
		}

		interview.Scheduled_Interview_Date__c = (interview.Scheduled_Interview_Date__c == null) ? DateTime.now().addDays(3) : interview.Scheduled_Interview_Date__c;

		if (interview.Group__c == null || interview.Group__c == '') {
			if (opt == Option.CSG_TECHNICAL || opt == Option.CSG_CONSULTING || opt == Option.CSG_PANEL){
				interview.Group__c = 'CSG';
			} else if (opt == Option.SALES_FIRST) {
				interview.Group__c = 'Sales';
			}
		}

		// If related records are provided, those are used.	
		if ( recruit != null && recruit.Id != null) {
			interview.Candidate__c = recruit.Id;
		} else if (recruit != null) {
			throw new IFB_TestException(EXCEPTION_INVALID_RECRUIT + '[recruit:' + recruit + ']');
		} 

		if ( interviewer != null && interviewer.Id != null) {
			interview.Interviewer__c = interviewer.Id;
		} else if (interviewer != null) {
			throw new IFB_TestException(EXCEPTION_INVALID_INTERVIEWER + '[interviewer:' + interviewer + ']');
		}

		if ( interviewer2 != null && interviewer2.Id != null) {
			interview.Interviewer2__c = interviewer2.Id;
		} else if (interviewer2 != null) {
			throw new IFB_TestException(EXCEPTION_INVALID_INTERVIEWER_2 + '[interviewer2:' + interviewer2 + ']');
		}

		// If related records are provided, those are used.
		if ( interviewer3 != null && interviewer3.Id != null) {
			interview.Interviewer3__c = interviewer3.Id;
		} else if (interviewer3 != null) {
			throw new IFB_TestException(EXCEPTION_INVALID_INTERVIEWER_3 + '[interviewer3:' + interviewer3 + ']');
		}

		// If related records are provided, those are used.
		if ( interviewer4 != null && interviewer4.Id != null) {
			interview.Interviewer4__c = interviewer4.Id;
		} else if (interviewer4 != null) {
			throw new IFB_TestException(EXCEPTION_INVALID_INTERVIEWER_4 + '[interviewer4:' + interviewer4 + ']');
		}

		// If related records are provided, those are used.
		if ( interviewer5 != null && interviewer5.Id != null) {
			interview.Interviewer5__c = interviewer5.Id;
		} else if (interviewer5 != null) {
			throw new IFB_TestException(EXCEPTION_INVALID_INTERVIEWER_5 + '[interviewer5:' + interviewer5 + ']');
		}

		// If related records are provided, those are used.
		if ( hiringManager != null && hiringManager.Id != null) {
			interview.Hiring_Manager__c = hiringManager.Id;
		} else if (hiringManager != null) {
			throw new IFB_TestException(EXCEPTION_INVALID_HIRING_MANAGER + '[hiringManager:' + hiringManager + ']');
		}

		// Values provided as parameters take precendence over option specific settings
		if (interview.RecordTypeId == null) {
			// Recruit setup specific for the provided option
			if (opt == Option.CSG_TECHNICAL) {
				interview.RecordTypeId = recordTypeMap.get(RECORDTYPE_CSG_TECHNICAL);
			} else if (opt == Option.CSG_CONSULTING) {
				interview.RecordTypeId = recordTypeMap.get(RECORDTYPE_CSG_CONSULTING);
			} else if (opt == Option.CSG_PANEL) {
				interview.RecordTypeId = recordTypeMap.get(RECORDTYPE_CSG_PANEL);			
			} else if (opt == Option.SALES_FIRST) {
				interview.RecordTypeId = recordTypeMap.get(RECORDTYPE_SALES_FIRST);	
			} else {
				throw new IFB_TestException(EXCEPTION_INVALID_OPTION + '[opt:' + opt.name() + ']');
			}
		}

		return interview;
	}
}