/*W-11622588 OKTA - Close preboarding case when worker id is available on WD candidate 
* Author - Ronak Bandwal
* CDC Service - responsible for processing related preboarding cases when WDR Candidate is updated
*/
public without sharing class NHW_WDRCandidate_CDC_Service {
    public static Id ContractorContactRecordTypeId = 	
        Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contractor').getRecordTypeId();
    
    public static Id EmployeeContactRecordTypeId = 
        Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Employee').getRecordTypeId();
    
    public static Id NHWPreboardingRecordTypeId = 
        Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Hire Process').getRecordTypeId();
    
    
    
    //method for building related collection variables and subsequently updates cases.    
    public static void updateIdentityInfoOnPreboardingCases(List<WDR_Candidate__c> WDRcandList) { 
        
        Map<id,String> candIdToWorkerIdMap = new Map<id,String>();
        candIdToWorkerIdMap = getWorkerIdByWDCandidateRecId(WDRcandList);
        
        if(candIdToWorkerIdMap.keySet().size()>0) {
            
            try {
                List<Contact> existingRelatedContacts = getExistingContactsForWorkerIds(candIdToWorkerIdMap.values());
                if(existingRelatedContacts.size() > 0) {
                    Map<String,String> WorkerIdToEmailMap = getSFEmailByWorkerd(existingRelatedContacts);
                    List<Case> relatedPreboardingCases = getRelatedPreboardingCasesForCandidateContact(candIdToWorkerIdMap.keySet());
                    
                    //iterate over related preboarding cases and populate email and worker id
                    for(Case cse:relatedPreboardingCases) {
                        Id candId = cse.NHW_Job_Application__r.Candidate__c;
                        cse.NH_Employee_Id__c = cse.NHW_Job_Application__r.Candidate__r.Employee_Number__c;
                        cse.Email_Address__c = WorkerIdToEmailMap.get(cse.NH_Employee_Id__c);
                    }
                    
                    List<Database.SaveResult> saveResults =  Database.update(relatedPreboardingCases, false); // Allow partial success
                    
                    for (Database.SaveResult sr : saveResults) {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            System.debug('Successfully updated Email and WorkerId on Case id:' + sr.getId());
                            System.debug('-----------------');
                        }
                        else {
                            System.debug('NHW_WDRCandidate_CDC_Service.updateIdentityInfoOnPreboardingCases method: Error occurred for Case id: '+sr.getId());  
                            Database.Error err = sr.getErrors()[0];
                            PF_Logger.log('NHW','ERROR',err.getMessage(),'Type: '+err.getStatusCode(),
                                          'Error While Updating Preboarding Case id: '+sr.getId()+ ' in updateIdentityInfoOnPreboardingCases method',
                                          'NHW_WDRCandidate_CDC_Service','','','',sr.getId()+'+'+'NHW-CDC'+'+'+err.getStatusCode());                                     
                        }                
                    }      
                }
            }  catch(Exception ex) {
                System.debug('Caught Exception at NHW_WDRCandidate_CDC_Service.updateIdentityInfoOnPreboardingCases method when trying to process Candidates'+candIdToWorkerIdMap.keyset().toString());
                String description = 'Error when trying to process related cases for Candidate ids: '+candIdToWorkerIdMap.keyset().toString();
                //PF_Logger.log('NHW', 'ERROR' , ex.getMessage(), ex.getTypeName(), description, 'NHW_WDRCandidate_CDC_Service');
                EventBus.publish(
                        new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'ERROR',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = ex.getTypeName(),
                                Stack_Trace__c = 'NHW_WDRCandidate_CDC_Service',
                                Message__c = ex.getMessage(),
                                Error__c = description
                                )
                        );
            }        
        }
        
        NHW_Util.insertNHWLogs();
    }
    
    //Build Map of worker id to Candidate id
    public static Map<id,String> getWorkerIdByWDCandidateRecId(List<WDR_Candidate__c> WDRcandList) {
        Map<id,String> CandIdToworkerIdMap = new Map<id,String>();
        for(WDR_Candidate__c cand: WDRcandList) {
            CandIdToworkerIdMap.put(cand.Id,cand.Employee_Number__c);
        }
        return CandIdToworkerIdMap;
    }
    
    //return list existing contractor/employee contact for list of worker Ids
    //exclude contacts with Email 'badge-only' (W-11844687)
    //include contacts created before current day (W-11844794)
    public static List<Contact> getExistingContactsForWorkerIds(List<String> workerIds) {
        List<Contact> existingRelatedContacts = [Select Id,EmployeeNumber__c,Email from Contact 
                                                 where (recordtypeid =: ContractorContactRecordTypeId or recordtypeid =: EmployeeContactRecordTypeId)
                                                 and Email != null and (Email != 'badge-only@salesforce.com') and EmployeeNumber__c in :workerIds and
                                                 CreatedDate < Today ];
        
        return existingRelatedContacts;
    }
    
    //return Map of worker id to email id using existing list of related contacts
    public static Map<String,String> getSFEmailByWorkerd(List<Contact> existingRelatedContacts) {
        Map<String,String> WorkerIdToEmailMap = new Map<String,String>();
        for(Contact cnt:existingRelatedContacts) {
            WorkerIdToEmailMap.put(cnt.EmployeeNumber__c,cnt.Email);
        }
        return WorkerIdToEmailMap;
    }
    
    //returns list of related Preboarding cases using list of WDR Candidate id
    public static List<Case> getRelatedPreboardingCasesForCandidateContact(Set<Id> candIds) {
        List<Case> relatedPreBoardingCases = [select id,Email_Address__c, nh_employee_id__c,NHW_Employee__c,NHW_Job_Application__r.Candidate__r.Employee_number__c from Case 
                                              where recordtypeid = :NHWPreboardingRecordTypeId 
                                              and Status NOT In ('Closed','Closed - Cancelled')
                                              and NHW_Job_Application__r.Candidate__c in :candIds ];
        return relatedPreboardingCases;
    }
    
}