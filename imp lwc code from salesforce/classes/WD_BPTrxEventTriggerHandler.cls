/* This handler class houses the logic for worker events processing
 - Gets the workerIds from incoming events
    - Only events with workerIds for picked downstream processing
 - The events are mapped and upserted as respective sObjects determined for the BP.
    - The primary key is workday WID.
 - Given this is Platform event subscriber, Used without sharing as it runs in context of Automated user  and not end user.

*/
public Without Sharing class WD_BPTrxEventTriggerHandler {
    
    public static void createRelatedPFRecsForTheEvents(List<SCC_Worker_Event__e> workerEvents){
        try{
            Set<String> employeeIds = new Set<String>();
            Contact workerContact,InitiatorContact;
            List<sobject> createSobjects = new List<sobject>();

            for(SCC_Worker_Event__e workerEvent : workerEvents){
                if(!string.isBlank(workerEvent.WD_BusProc_Trx_aboutWorker_EmpID_Text_CF__c) ){
                    employeeIds.add(workerEvent.WD_BusProc_Trx_aboutWorker_EmpID_Text_CF__c);          
                }
                if(!string.isBlank(workerEvent.WD_BusProc_Trx_Initiator_EmpID__c) ){
                    employeeIds.add(workerEvent.WD_BusProc_Trx_Initiator_EmpID__c);          
                }
            }
            system.debug('Incoming Worker Ids' + employeeIds);
            if(employeeIds.size() >0){
                Map<String,Contact> contactByWorkerId = WD_BPTrxnService.getContactBasedOnEmployeeId(employeeIds);
                for(SCC_Worker_Event__e workerEvent : workerEvents){
                    workerContact = contactByWorkerId.get(workerEvent.WD_BusProc_Trx_aboutWorker_EmpID_Text_CF__c);
                    InitiatorContact = contactByWorkerId.get(workerEvent.WD_BusProc_Trx_Initiator_EmpID__c);
                    if(workerContact != null){
                        createSobjects.add(WD_BPTrxnService.populateSobjectRecs('WD_Worker_Event__c',workerContact,InitiatorContact,workerEvent)); 
                    }
                }
            system.debug('Related PF Records count :'+createSobjects.size());
            if(createSobjects.size() > 0){
                WD_BPTrxnService.upsertSobjectRecords(createSobjects);
            }
            }
        }
        catch(exception ex){
           system.debug('Got  Exception when processing the events - WD_BPTrxEventTriggerHandler :'+ex);
           PF_Logger.log('ESDJC','ERROR',ex.getMessage(),'DML Error',ex.getMessage(),'WD_BPTrxnService');

        }
        if(!PF_Logger.logs.isEmpty()){
            PF_Logger.createLogs(PF_Logger.logs);
        }
    }

}