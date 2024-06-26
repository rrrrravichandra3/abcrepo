@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
public without sharing class NHW_ContactHandler {
	
	public static boolean isExecuted = false; 
	private static Onboarding_Setting__c settings = Onboarding_Setting__c.getInstance(); 
	private static final String JOB_NAME = 'Create Cases Async jobID -'; 

	/*
	* This method should be used to perform updates on NHW Cases for FTE flow, after placement
	*/
	public static void updateContactsToNHWCase(Map<Id,Contact> triggerNewMap,Map<Id,Contact> triggerOldMap){
		
		NHW_contactToCaseUtil.performUpdatesToCase(triggerNewMap,triggerOldMap,settings);
        //W-15308729 code added for SD changes > 30 requirements
        NHW_contactToCaseUtil.performUpdatesToCaseIfEmployeeContact(triggerNewMap,triggerOldMap);
	}

	/*
	* When a contractor contact is inserted and start date is in preboarding window, create cases
	*/
	public static void createNHWContractorCaseOnInsert(List<Contact> newContacts){
		//this functionality only available when feature flag is set to true
		if(!settings.SSOR_Feature_Flag__c){return;}
		Set<Id> contractorContactIds = new Set<Id>();
		for(Contact c: newContacts){
            if(NHW_CW_DecisionService.basicCriteriaForCWCaseCreateAndUpdates(c)){
            	contractorContactIds.add(c.Id);
            }
		}
		if(!contractorContactIds.isEmpty()){
			ID jobID = System.enqueueJob(new NHW_CW_CreateCaseAsync(contractorContactIds));
            system.debug(LOGGINGLEVEL.INFO,JOB_NAME+jobID);
		}
	}
    
    /*
	* When a contractor contact is updated, create/update cases based on certain criteria
	*/
	public static void processNHWContractorCaseOnUpdate(Map<Id,Contact> newContactsMap,Map<Id,Contact> triggerOldMap){
		//this functionality only available when feature flag is set to true
		if(!settings.SSOR_Feature_Flag__c){return;}
		Set<Id> createContractorContactIds = new Set<Id>();
        Set<Id> updateContractorContactIds = new Set<Id>();
        Map<Id,Case> mContactIdToCaseWithUpdates = new Map<Id,Case>();
        List<Case> closeCancelCases = new List<Case>();
        Map<Id,Case> contactWithValidExistingCase = NHW_CW_DecisionService.contactWithValidRelatedCaseMap(newContactsMap.KeySet(), triggerOldMap);
        Map<Id,Boolean> isContactHasValidExistingCase = NHW_CW_DecisionService.hasContactValidRelatedCasesMap(contactWithValidExistingCase);
        for(Contact newContactState: newContactsMap.values()) {
            if(!NHW_CW_DecisionService.isRecordTypeContractor(newContactState)) {
                continue; 
            }
            Contact oldContactState;
            if(triggerOldMap != null && String.isNotBlank(newContactState.Id)) 
            {
                oldContactState = triggerOldMap.get(newContactState.Id);
            }
            if(NHW_CW_DecisionService.shouldCloseCancelRelatedCase(newContactState, oldContactState)) 
            {
                if(contactWithValidExistingCase.containsKey(newContactState.Id)){
                    closeCancelCases.add(contactWithValidExistingCase.get(newContactState.Id));
                    continue;
                }
            } 
            else 
            {
                if(NHW_CW_DecisionService.basicCriteriaForCWCaseCreateAndUpdates(newContactState))
                {
                    if(NHW_CW_DecisionService.noChangeToStartDate(newContactState, oldContactState)) 
                    {
                        if(isContactHasValidExistingCase != null && isContactHasValidExistingCase.containsKey(newContactState.Id) && isContactHasValidExistingCase.get(newContactState.Id)) 
                        {
                            if((contactWithValidExistingCase != null && contactWithValidExistingCase.containsKey(newContactState.Id) && !contactWithValidExistingCase.get(newContactState.Id).isClosed) && (NHW_CW_DecisionService.didMetadataFieldsChanged(newContactState, oldContactState)))
                             {
                                    
                                    mContactIdToCaseWithUpdates.put(newContactState.Id,contactWithValidExistingCase.get(newContactState.Id));
                                    continue;
                                
                            }
                        }
                        else
                        {
                            createContractorContactIds.add(newContactState.Id);
                            continue;
                        }
                    }
                    else
                    {
                        if(NHW_CW_DecisionService.OldStartDateNotInPast(newContactState, oldContactState)) 
                        {   
                            if(NHW_CW_DecisionService.validStartDateGapLessThanThreshold(newContactState, oldContactState)) 
                            {
                                if(isContactHasValidExistingCase != null && isContactHasValidExistingCase.containsKey(newContactState.Id) && 
                                   isContactHasValidExistingCase.get(newContactState.Id)) 
                                {
                                    
                                    mContactIdToCaseWithUpdates.put(newContactState.Id,contactWithValidExistingCase.get(newContactState.Id));
                                    
                                    continue;
                                    
                                }
                                else
                                {
                                    createContractorContactIds.add(newContactState.Id);
                                    continue;
                                }
                            } else {//If delta is more than 30, don't do anything
                                continue;
                            }
                        } 
                        //Old SD is in past flow
                        else if(NHW_CW_DecisionService.isOnboardingFirstTimeForTheTenure(newContactState, oldContactState))
                        {   // If WO Status Transitions to Correct Value ---> Create Case
                                createContractorContactIds.add(newContactState.Id);
                                continue;
                        
                        }
                        //SD updates for the existing tenure after old SD is past
                        else if(NHW_CW_DecisionService.validStartDateGapLessThanThreshold(newContactState, oldContactState))
                        {
                            if(isContactHasValidExistingCase != null && isContactHasValidExistingCase.containsKey(newContactState.Id) 
                               && isContactHasValidExistingCase.get(newContactState.Id))
                            {
                                if(NHW_CW_DecisionService.didMetadataFieldsChanged(newContactState, oldContactState))
                                {
                                    mContactIdToCaseWithUpdates.put(newContactState.Id,contactWithValidExistingCase.get(newContactState.Id));
                                    continue;
                                }
                            }
                            //New Hire Start date update after old SD  is past for a new tenure but NOT having an existing case.
                            else
                            {
                                createContractorContactIds.add(newContactState.Id);
                                continue;
                            }
                        }else{ //Fallback if Delta >30 - and SD change comes in we don't do anything
                            continue;
                        }
                    }
                } 
            }
        }
        if(!createContractorContactIds.isEmpty()){
            ID jobID = System.enqueueJob(new NHW_CW_CreateCaseAsync(createContractorContactIds));
            system.debug(LOGGINGLEVEL.INFO,JOB_NAME+jobID);
        }
        
        if(!mContactIdToCaseWithUpdates.isEmpty()){
            ID jobID = System.enqueueJob(new NHW_CW_UpdateCaseAsync(mContactIdToCaseWithUpdates));
            system.debug(LOGGINGLEVEL.INFO,JOB_NAME+jobID);
        }
        
        if(closeCancelCases!=null && !closeCancelCases.isEmpty()){
            ID jobID = System.enqueueJob(new NHW_CW_CloseCancelCasesAsync(closeCancelCases));
            system.debug(LOGGINGLEVEL.INFO,'CloseCancel Cases Async jobID -'+jobID);
		}
    }
    

}