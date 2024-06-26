/**
 * @description       : 
 * @author            : Urvish Shah (ushah)
 * @group             : 
 * @last modified on  : 05-03-2023
 * @last modified by  : Urvish Shah (ushah)
**/
public with sharing class tcrm_BatchSyncBeameryLeadUpdates implements Database.Batchable<tcrm_BeameryContacts.Contacts>,  Schedulable, Database.AllowsCallouts, Database.Stateful{
    TCRM_BatchUtil batchUtil = new TCRM_BatchUtil();
    tcrm_BeameryAPIService apiService = new tcrm_BeameryAPIService();
    static List<tcrm_BeameryContacts.Contacts> beameryContacts = new List<tcrm_BeameryContacts.Contacts>();
    Integer offset;
    tcrm_ConsentBatchSettings__c settings;
    String lastSuccessfulRunStr;
    DateTime start_time;
    List<PF_Debug_Log__c> logs = new List<PF_Debug_Log__c>();
    Integer recordsProcessed = 0;
    Integer recordsErrored = 0;
    long totalContactsFromBeamery = 0;

    public void execute(SchedulableContext sc) {
        Database.executeBatch(this);
    }

    public tcrm_BatchSyncBeameryLeadUpdates(Integer offset){
        this.offset = offset;
    }

    public Iterable<tcrm_BeameryContacts.Contacts> start(Database.BatchableContext context) {
        settings = tcrm_ConsentBatchSettings__c.getOrgDefaults();
        lastSuccessfulRunStr = String.valueOf(settings.lsrt_beameryToCEMCILeadsUpdate__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
        start_time = System.now();
        TCRM_BatchUtil.BeameryGetContactsResponseWrapper response = apiService.getBeameryLeadUpdates(lastSuccessfulRunStr,offset);
        if(response != null && response.statusCode == 200 && response.totalCount != null){
            totalContactsFromBeamery = response.totalCount;
            processBeameyContactsAPIResponse(response);
            while(offset + 200 < totalContactsFromBeamery &&  offset < 9800){
                offset += 200;
                TCRM_BatchUtil.BeameryGetContactsResponseWrapper res = apiService.getBeameryLeadUpdates(lastSuccessfulRunStr,offset);
                if(res != null && response.statusCode == 200){
                    processBeameyContactsAPIResponse(res);
                }
            }
        }
        return (Iterable<tcrm_BeameryContacts.Contacts>)beameryContacts;
    }

    public void execute(Database.BatchableContext context, tcrm_BeameryContacts.Contacts[] beameryContacts) {
        if(!beameryContacts.isEmpty()){
            List<Lead> leads = batchUtil.syncUpdatedBeameryLeads(beameryContacts);
            if(!leads.isEmpty()){
                Database.SaveResult[] leadUpdateStatus = Database.update(leads,false,AccessLevel.SYSTEM_MODE);
                for(Database.SaveResult sr : leadUpdateStatus){
                    if(!sr.isSuccess()){
                        recordsErrored++;
                        PF_Logger.log('TCRM', 'ERROR',null,null,sr.getErrors()[0].getMessage(),'tcrm_BatchSyncBeameryLeadUpdates');
                    }
                    else{
                        recordsProcessed++;
                    }
                }
                logs.addall(PF_Logger.logs);
            }
        }
    }

    public void finish(Database.BatchableContext context) {
        updateLastSuccessfulRunTime();
        PF_Logger.log('TCRM', 'INFO',null,null,recordsProcessed + ' Leads updated from Beamery','tcrm_BatchSyncBeameryLeadUpdates');
        PF_Logger.log('TCRM', 'INFO',null,null,recordsErrored + ' records failed to be updated as Lead From Beamery','tcrm_BatchSyncBeameryLeadUpdates');
        logs.addall(PF_Logger.logs);
        logPFLogger();
    }

    private void updateLastSuccessfulRunTime(){
        settings.lsrt_beameryToCEMCILeadsUpdate__c = start_time;
        update as System settings;
    }

    public void logPFLogger(){
        if(!logs.isEmpty()){
            PF_Logger.createLogs(logs);
        }
    }

    private void processBeameyContactsAPIResponse(TCRM_BatchUtil.BeameryGetContactsResponseWrapper response){
        if(!response.beameryContacts.isEmpty()){
            for(tcrm_BeameryContacts.Contacts contact : response.beameryContacts){
                if(contact.integrations.workday != null || isFutureForce(contact)){
                    continue;
                }
                beameryContacts.add(contact);
            }
        }
    }

    private boolean isFutureForce(tcrm_BeameryContacts.Contacts contact){
        boolean isFF = false;
        if(contact.globalTags != null){
            for(tcrm_BeameryContacts.CreationSource gt : contact.globalTags){
                if(gt.value == 'Futureforce'){
                    isFF = true;
                    break;
                }
            }
        }
        return isFF;
    }
}