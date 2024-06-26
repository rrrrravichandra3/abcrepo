public without sharing class ESDJC_UpdateCaseStatusController {
    private final static String MESSAGE_ERROR_NOT_SUPPORTED_RT = 'Change Status is only available to the “All Expense Cases” and “All Cases except ER” Case Record Type.';
    private final static String MESSAGE_ERROR_MIXED_SUPPORTED_RTS = 'Records with “All Expense Cases” record type can\'t be mixed with records based on “All Cases except ER” record types';
    private final static String CASE_RT_ALL_EXPENSE_CASES = 'All Expense Cases';
    private final static String CASE_RT_ALL_CASE_TYPES_EXCEPT_ER_AMER = 'All Case Types except ER - AMER';
    private final static String CASE_RT_ALL_CASE_TYPES_EXCEPT_ER_APAC = 'All Case Types except ER - APAC';
    private final static String CASE_RT_ALL_CASE_TYPES_EXCEPT_ER_EMEA = 'All Case Types except ER - EMEA';
    private final static String CASE_RT_ALL_CASE_TYPES_EXCEPT_ER_JAPAN = 'All Case Types except ER - Japan';
    private final static String SO_APPROVED = 'Approved';
    private final static String SO_APPROVED_PARTIAL = 'Approved for Partial Payment';
    private final static String SO_CLOSED = 'Closed';
    private final static String SO_WAITING_RESPONSE = 'Waiting for Response';
    private final static String SO_NOT_A_CASE = 'Not a Case';

    private final static List<SelectOption> ALL_EXPENSE_CASE_STATUS_OPTIONS = new List<SelectOption> {
        new SelectOption(SO_APPROVED, SO_APPROVED),
        new SelectOption(SO_APPROVED_PARTIAL, SO_APPROVED_PARTIAL),
        new SelectOption(SO_CLOSED, SO_CLOSED)
    };
    private final static List<SelectOption> ALL_CASE_TYPES_EXCEPT_ER_STATUS_OPTIONS = new List<SelectOption> {
        new SelectOption(SO_WAITING_RESPONSE, SO_WAITING_RESPONSE),
        new SelectOption(SO_NOT_A_CASE, SO_NOT_A_CASE)
    };
    private final static List<String> ALL_CASE_TYPES_EXCEPT_ER_RT_LIST = new List<String> {
        CASE_RT_ALL_CASE_TYPES_EXCEPT_ER_AMER,
        CASE_RT_ALL_CASE_TYPES_EXCEPT_ER_APAC,
        CASE_RT_ALL_CASE_TYPES_EXCEPT_ER_EMEA,
        CASE_RT_ALL_CASE_TYPES_EXCEPT_ER_JAPAN
    };
    private final static List<String> SUPPORTED_CASE_RECORD_TYPE_NAMES = new List<String> {
        CASE_RT_ALL_EXPENSE_CASES,
        CASE_RT_ALL_CASE_TYPES_EXCEPT_ER_AMER,
        CASE_RT_ALL_CASE_TYPES_EXCEPT_ER_APAC,
        CASE_RT_ALL_CASE_TYPES_EXCEPT_ER_EMEA,
        CASE_RT_ALL_CASE_TYPES_EXCEPT_ER_JAPAN
    };
    private final static Map<String, List<SelectOption>> CASE_STATUS_OPTIONS_BY_RT_NAME = new Map<String, List<SelectOption>> {
        CASE_RT_ALL_EXPENSE_CASES               => ALL_EXPENSE_CASE_STATUS_OPTIONS,
        CASE_RT_ALL_CASE_TYPES_EXCEPT_ER_AMER   => ALL_CASE_TYPES_EXCEPT_ER_STATUS_OPTIONS,
        CASE_RT_ALL_CASE_TYPES_EXCEPT_ER_APAC   => ALL_CASE_TYPES_EXCEPT_ER_STATUS_OPTIONS,
        CASE_RT_ALL_CASE_TYPES_EXCEPT_ER_EMEA   => ALL_CASE_TYPES_EXCEPT_ER_STATUS_OPTIONS,
        CASE_RT_ALL_CASE_TYPES_EXCEPT_ER_JAPAN  => ALL_CASE_TYPES_EXCEPT_ER_STATUS_OPTIONS
    };
    private final static Map<String, List<String>> MIXED_RT_BY_RT_NAME = new Map<String, List<String>> {
        CASE_RT_ALL_EXPENSE_CASES               => new List<String> { CASE_RT_ALL_EXPENSE_CASES },
        CASE_RT_ALL_CASE_TYPES_EXCEPT_ER_AMER   => ALL_CASE_TYPES_EXCEPT_ER_RT_LIST,
        CASE_RT_ALL_CASE_TYPES_EXCEPT_ER_APAC   => ALL_CASE_TYPES_EXCEPT_ER_RT_LIST,
        CASE_RT_ALL_CASE_TYPES_EXCEPT_ER_EMEA   => ALL_CASE_TYPES_EXCEPT_ER_RT_LIST,
        CASE_RT_ALL_CASE_TYPES_EXCEPT_ER_JAPAN  => ALL_CASE_TYPES_EXCEPT_ER_RT_LIST
    };
    
    private final List<Case> cases; 
    private String mainRecordType;
    public boolean isErrorOccured{get;set;}
    public String selectedStatus {get;set;} 
    public String piiValue {get;set;}  
    public String filterId {get;set;} 
	public ESDJC_UpdateCaseStatusController(ApexPages.StandardSetController controller) {
        isErrorOccured = false;
        this.cases = [select Id,Status,RecordType.Name,Type,PII__c from case where id in : controller.getSelected()];
        filterId = controller.getFilterId();
        this.mainRecordType = this.cases.isEmpty()
            ? CASE_RT_ALL_EXPENSE_CASES
            : this.cases[0].RecordType.Name;
    }
    
    public List<SelectOption> getCaseStatusValues() {
        return CASE_STATUS_OPTIONS_BY_RT_NAME.containsKey(this.mainRecordType)
            ? CASE_STATUS_OPTIONS_BY_RT_NAME.get(this.mainRecordType)
            : new List<SelectOption> { new SelectOption('', '--None--') };
    }

    public List<SelectOption> getPIIValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> PIIPicklistValues= Schema.SObjectType.Case.fields.PII__c.getPicklistValues();
        options.add(new SelectOption('', '--None--'));
        for(Schema.PicklistEntry PIIPicklistValue: PIIPicklistValues){
            options.add(new SelectOption(PIIPicklistValue.getValue(), PIIPicklistValue.getLabel()));
        }    
        return options;
    }
    
        public void updateCaseStatus(){
            // Moved page navigation to Javascript.
        if(selectedStatus != null){
            for(Case c : cases){
            	c.status = selectedStatus;
                c.PII__c = piiValue;
        	}
            try{
                update cases;
            } catch(Exception e){
                isErrorOccured = true;
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            }
        }
        
       
    }
    
    public PageReference cancel(){
        PageReference returnPage = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
        return returnPage;
    }
    
    public PageReference validateOnLoad(){
        if(cases == null || cases.size() == 0 ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select at least one record.'));
            isErrorOccured = true;
            return null;
        } else {
            List<String> supportedRecordTypeIds = getSupportedRecordTypeIds();
            List<String> supportedRecordTypesForMix = MIXED_RT_BY_RT_NAME.get(this.mainRecordType);
            for(Case c : cases){
                if (!supportedRecordTypeIds.contains(c.RecordTypeId)) {
                    isErrorOccured = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MESSAGE_ERROR_NOT_SUPPORTED_RT));
     				return null;
                }

                if (!supportedRecordTypesForMix.contains(c.RecordType.Name)) {
                    this.isErrorOccured = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MESSAGE_ERROR_MIXED_SUPPORTED_RTS));
                    return null;
                }
            }
        }

        return null;
    }

    private static List<String> getSupportedRecordTypeIds() {
        List<String> supportedRecordTypeIds = new List<String>();
        Map<String, RecordTypeInfo> recordTypeByName = Schema.SObjectType.Case.getRecordTypeInfosByName();

        for (String name : recordTypeByName.keySet()) {
            if (!SUPPORTED_CASE_RECORD_TYPE_NAMES.contains(name)) continue;

            supportedRecordTypeIds.add(recordTypeByName.get(name).recordTypeId);
        }

        return supportedRecordTypeIds;
    }
}