public without sharing class NHW_CW_DecisionService {
	static Id contractorRecordTypeId = NHW_Util.getContractorContactRecordTypeId();
    static Map<String, Set<String>> cwWorkOrderStatusMap = NHW_Util.getCWWorkOrderStatusMap();

	public static Boolean isRecordTypeContractor(Contact c){
		if(c.recordTypeId == contractorRecordTypeId){
			return true;
		}else{
			return false;
		}
	}

	public static Boolean contactStartDateInOnboardingWindow(Contact c){
		Integer preboardingDays= (NHW_Util.CONTRACTOR_START_WINDOW == null ? 15 :NHW_Util.CONTRACTOR_START_WINDOW);
        Integer backDateDays = (NHW_Util.CONTRACTOR_BACKDATE_WINDOW == null ? 0 :NHW_Util.CONTRACTOR_BACKDATE_WINDOW);
		Date n_days = System.today() + preboardingDays;
		Date n_days_inPast = System.today() - backDateDays;
		if(c.Start_Date__c != null
			&&(
				(c.Start_Date__c <= n_days
				&&
				c.Start_Date__c >= System.today())
			||
				//Accounts for contacts that are created today with a back dated start date.
				//Supports if records get hung up in integration or fieldglass approvals to still create cases.
				/*(Date.newInstance(c.CreatedDate.year(),c.CreatedDate.month(),c.CreatedDate.day()) == System.today()
				&&*/
				(c.Start_Date__c < System.today()
				&&
				c.Start_Date__c >= n_days_inPast)
			)
		){
			return true;
		}else{
			return false;
		}
	}

	public static Boolean hasValidCWTypeWorkOrderStatusMapping(Contact newContactState) {
        if(!cwWorkOrderStatusMap.isEmpty() && String.isNotBlank(newContactState.CW_Type__c) && String.isNotBlank(newContactState.CW_Work_Order_Status__c)
           && cwWorkOrderStatusMap.containsKey(newContactState.CW_Type__c) && cwWorkOrderStatusMap.get(newContactState.CW_Type__c).contains(newContactState.CW_Work_Order_Status__c))
        {
            return True;
        }else{
            return False;
        }
	}
    
    public static Boolean shouldCloseCancelRelatedCase(Contact newContactState, Contact oldContactState) {
		if(isRecordTypeContractor(newContactState) && newContactState.CW_Work_Order_Status__c != oldContactState.CW_Work_Order_Status__c
           && newContactState.CW_Work_Order_Status__c == 'Closed' && newContactState.Start_Date__c >= System.today()){
			return True;
		}else{
			return False;
		}
	}
    
    public static Boolean noChangeToStartDate(Contact newContactState, Contact oldContactState) {
		if(newContactState.Start_Date__c == oldContactState.Start_Date__c){
			return True;
		}else{
			return False;
		}
	}
    
    public static Boolean validRehire(Contact newContactState, Contact oldContactState) {
		if(newContactState.Previous_SF_Worker__c != oldContactState.Previous_SF_Worker__c && newContactState.Previous_SF_Worker__c){
			return True;
		}else{
			return False;
		}
	}
    
    public static Boolean OldStartDateNotInPast(Contact newContactState, Contact oldContactState) {
		if(newContactState.Start_Date__c != oldContactState.Start_Date__c && oldContactState.Start_Date__c > system.today()){
			return True;
		}else{
			return False;
		}
	}
    
     public static Boolean isStartDateGapMoreThanOneDay(Contact newContactState, Contact oldContactState) {
		if(newContactState.Start_Date__c != null && newContactState.Start_Date__c != oldContactState.Start_Date__c && oldContactState.Term_Date__c != null && oldContactState.Term_Date__c.daysBetween(newContactState.Start_Date__c) > 1){
			return True;
		}else{
			return False;
		}
	}
    
     public static Boolean validStartDateGapLessThanThreshold(Contact newContactState, Contact oldContactState) {
		if(newContactState.Start_Date__c != oldContactState.Start_Date__c && oldContactState.Start_Date__c.daysBetween(newContactState.Start_Date__c) <= 30){
			return True;
		}else{
			return False;
		}
	}
    
    public static Boolean isOnboardingFirstTimeForTheTenure(Contact newContactState, Contact oldContactState) {
		if((oldContactState.CW_Work_Order_Status__c == 'Closed' 
			|| oldContactState.CW_Work_Order_Status__c == 'Confirmed' 
			|| String.IsBlank(oldContactState.CW_Work_Order_Status__c))
           && hasValidCWTypeWorkOrderStatusMapping(newContactState)){
               return True;
           }else{
               return False;
           }
    } 
    
    public static Boolean isHireReasonChangingFromBadgeOnlyToStandard(Contact newContactState, Contact oldContactState) {
		if(newContactState.CW_Hire_Reason__c != oldContactState.CW_Hire_Reason__c 
           && oldContactState.CW_Hire_Reason__c == 'Badge-Only' && newContactState.CW_Hire_Reason__c == 'Standard'){
			return True;
		}else{
			return False;
		}
	}
    
    public static Map<Id, Boolean> hasContactValidRelatedCasesMap(Map<Id,Case> mapContactIdtoValidCase){
		Map<Id, Boolean> contactIdWithValidRelatedCases = new Map<Id, Boolean>();
        //Getting the Query from contactWithValidRelatedCaseMap for every ContactId in the Map.keyset() it contains a valid case
        if(!mapContactIdtoValidCase.isEmpty()) {
            for (Id contactId: mapContactIdtoValidCase.keySet()) {
				contactIdWithValidRelatedCases.put(contactId,true);
            }
        }
        return contactIdWithValidRelatedCases;
    }
    
    public static Map<Id, case> contactWithValidRelatedCaseMap(Set<Id> contactIds, Map<Id, Contact> oldContactMap){
        List<Contact> contractorContacts = PF_NHW_ContactStore.getCW_ContactsWithRelatedCases(contactIds);
        Map<Id, case> contactIdWithValidRelatedCases = new Map<Id, case>();

        if(contractorContacts != null) {
            for (Contact c : contractorContacts) {
				List<Case> existingCases = c.EmlpoyeeCases__r;
                //Check to see if this contact already has an existing case
                if ((!existingCases.isEmpty() || existingCases.size() > 0) 
                    && doesCWStartDateMatchCaseStartDate(oldContactMap.get(c.Id), existingCases[0])) {
                        contactIdWithValidRelatedCases.put(c.Id, existingCases[0]);
                    }
            }
        }
        return contactIdWithValidRelatedCases;
    }
    
    public static Map<Id, Boolean> contactMapWithValidRelatedNonClosedCases(Set<Id> contactIds){
        List<Contact> contractorContacts = PF_NHW_ContactStore.getCW_ContactsWithRelatedCases(contactIds);
        Map<Id, Boolean> contactIdWithValidRelatedCases = new Map<Id, Boolean>();
        
        if(contractorContacts != null) {
            for (Contact c : contractorContacts) {
                Case provisioningCase = new Case();
                List<Case> existingCases = c.EmlpoyeeCases__r;
                //Check to see if this contact already has an existing case
                if ((!existingCases.isEmpty() || existingCases.size() > 0) 
                    && !existingCases[0].isClosed && existingCases[0].NHW_Start_Date__c == c.Start_Date__c) {
                        contactIdWithValidRelatedCases.put(c.Id, True);
                    } else {
                        contactIdWithValidRelatedCases.put(c.Id, False);
                    }
            }
        }
        return contactIdWithValidRelatedCases;
    }
    
    public static Boolean basicCriteriaForCWCaseCreateAndUpdates(Contact newContactState){

        if(
            isRecordTypeContractor(newContactState) 
           	&&
			isStandardHireReason(newContactState)
           ) 
        {
            return true;
        }
        return false;
	}

	public static Boolean standardCriteriaForCWCaseCreate(Contact newContactState){

        if(
            contactStartDateInOnboardingWindow(newContactState) 
           	&&
			hasValidCWTypeWorkOrderStatusMapping(newContactState)
           ) 
        {
            return true;
        }
        return false;
	}

	public static Boolean didMetadataFieldsChanged(Contact newContactState, Contact oldContactState){
		List<NH_DataMapping__mdt> dataMappings = NHW_Util.getCWContactToCaseMappingData();
		Set<String> sourceFields = NHW_Util.getSourceObjectFieldsUsingNHDataMappingMDT(dataMappings);


		for(String fieldNameFromMetadata : sourceFields) {
			String sanitizedFieldName = fieldNameFromMetadata;
			//if we have a feild like Field1__r.Field2__c, we want to see if Field1__c changed
			if(fieldNameFromMetadata.contains('.')){
				String[] fieldsChain = fieldNameFromMetadata.trim().split('\\.');
				if(fieldsChain[0].endsWith('__r')){
					sanitizedFieldName = (fieldsChain[0].removeEnd('__r'))+'__c';
				}else{
					//This is a standard field and standard fields add Id to the reference.
					sanitizedFieldName = fieldsChain[0]+'Id';
				}
			}
			String oldFieldStringValue = String.valueOf(oldContactState.get(sanitizedFieldName));
			String newFieldStringValue = String.valueOf(newContactState.get(sanitizedFieldName));
			if (oldFieldStringValue != newFieldStringValue) {
				return true;
			}
        }
        return false;
	}

	public static Boolean doesCWStartDateMatchCaseStartDate (Contact c, Case provisioningCase){
		if(c.Start_Date__c == provisioningCase.NHW_Start_Date__c){
			return true;
		}else{
			return false;
		}
	}

	public static Boolean isStandardHireReason(Contact newContactState){
		if(newContactState.CW_Hire_Reason__c == 'Standard'){
			return true;
		}else{
			return false;
		}
	}
}