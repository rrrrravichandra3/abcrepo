/*W-11622588 OKTA - Close preboarding case when worker id is available on WD candidate 
* Author - Ronak Bandwal
* CDC Event Handler -  iterates thru trigger context records and 
* getting the details into sobject recs and invoking a service class.
*/
public without sharing class NHW_WDRCand_ChangeEventTriggerHandler {
    
    /*
*  Updates email and worker id on related preboarding Case for CW->FTE conversion 
*	when worker Id is updated on WDR Candidate by OKTA
*/ 
    public static void updateRelatedPreboardingCases (List<WDR_Candidate__ChangeEvent> changeEvts) {
        
        List<WDR_Candidate__c> WDRcandList = new List<WDR_Candidate__c>();
        WDRcandList = getCandidatesWithWorkerIdChanges(changeEvts);
        if(WDRcandList.size()>0) {
            NHW_WDRCandidate_CDC_Service.updateIdentityInfoOnPreboardingCases(WDRcandList);        
            
        }
    }
    
    /*
* Generates generate in-memory WD candidate Sobject using events with (Id,Employee Number) populated
* parameters: List of Change Events
* return: List of WD_Candidate__c
*/
    public static List<WDR_Candidate__c> getCandidatesWithWorkerIdChanges(List<WDR_Candidate__ChangeEvent> changeEvts) {
        
        List<WDR_Candidate__c> WDRcandList = new List<WDR_Candidate__c>();
        //process change Event only when worker id is updated
        for(WDR_Candidate__ChangeEvent event : changeEvts) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            if(header.changeType == 'Update' && header.changedFields.contains('Employee_Number__c')) {
                if(!String.isBlank(event.Employee_Number__c)) {
                    for(Id candId : header.getRecordIds()) {
                        WDRcandList.add(new WDR_Candidate__c(id = candId, Employee_Number__c = event.Employee_Number__c));
                    }
                }
            }
            
        }
        
        return WDRCandList;
    }
}