public with sharing class PF_NHW_CreateContractorCaseController {
    /**
     * @param recordId
     * Using Methods stored in NHW_CW_DecisionService
     * determine if this contractor contact already has an existing case
     * @return boolean
     */
    @AuraEnabled
    public static Boolean hasExistingValidCase (Id recordId){
        Boolean hasExistingValidCase;
        Set<Id> contactIds = new Set<Id>();
        contactIds.add(recordId);
        Map<Id,Contact> conMap = new Map<Id,Contact>();
        for(Contact c:[SELECT id, Start_Date__c FROM Contact WHERE id =: recordId]){
            conMap.put(c.Id,c);
        }
        Map<Id,Case> contactWithValidExistingCase = NHW_CW_DecisionService.contactWithValidRelatedCaseMap(contactIds, conMap);
        Map<Id,Boolean> isContactHasValidExistingCase = NHW_CW_DecisionService.hasContactValidRelatedCasesMap(contactWithValidExistingCase);


            if((isContactHasValidExistingCase != null && isContactHasValidExistingCase.containsKey(recordId)
                    && isContactHasValidExistingCase.get(recordId))){
                hasExistingValidCase = true;
            }else if(conMap.get(recordId).Start_Date__c <= System.today()){
                hasExistingValidCase = true;
            }else{
                hasExistingValidCase = false;
            }

        return hasExistingValidCase;
    }

    /**
     * @param recordId
     * Validate again that the contact doesn't have an existing case (Return to cmp that Case already exists)
     * Call Queueable Action for Contractor Case and return to cmp the action was queued and jobId
     *
     * @return String Message - From the Controller
     */
    @AuraEnabled
    public static String callQueableClass(Id recordId){
        String responseMessage;
        Set<Id> createContractorContactIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        contactIds.add(recordId);
        Map<Id,Contact> conMap = new Map<Id,Contact>();
        for(Contact c:[SELECT id, Start_Date__c FROM Contact WHERE id IN: contactIds]){
            conMap.put(c.Id,c);
        }
        Map<Id,Case> contactWithValidExistingCase = NHW_CW_DecisionService.contactWithValidRelatedCaseMap(contactIds, conMap);
        Map<Id,Boolean> isContactHasValidExistingCase = NHW_CW_DecisionService.hasContactValidRelatedCasesMap(contactWithValidExistingCase);
        
		        
        for(Id i: contactIds){
            if(isContactHasValidExistingCase != null && isContactHasValidExistingCase.containsKey(i) 
                               && isContactHasValidExistingCase.get(i)){
                responseMessage = 'Case already exists for this Contact';
            }else{
                createContractorContactIds.add(i);
            }
            System.debug(createContractorContactIds);
        }
        if(!createContractorContactIds.isEmpty()){
        	ID jobID = System.enqueueJob(new NHW_CW_CreateCaseAsync(createContractorContactIds));
            system.debug(LOGGINGLEVEL.INFO,'Create Cases Async jobID -'+jobID);
            responseMessage = 'Contractor Case Create has been queued. Job Id : ' + jobId;
        }

        return responseMessage;
    }
}