/**
 * @description       : 
 * @author            : Urvish Shah (ushah)
 * @group             : 
 * @last modified on  : 04-20-2023
 * @last modified by  : Urvish Shah (ushah)
**/
public with sharing class tcrm_BatchSyncConsent implements Database.Batchable<SObject>,  Schedulable, Database.AllowsCallouts, Database.Stateful {
    tcrm_ConsentBatchSettings__c settings = tcrm_ConsentBatchSettings__c.getOrgDefaults();
    DateTime start_time = System.now();
    Boolean isSuccess = false;
    public tcrm_BeameryAPIService apiService = new tcrm_BeameryAPIService();
    static final String successCode = '200';
    public Integer recordsProcessed = 0;
    public Integer recordsErrored = 0;
    List<PF_Debug_Log__c> logs = new List<PF_Debug_Log__c>();
    Static Id MCProfileId;
            
    private Talent_CRM_Consent_Batch_Setting__mdt batchSettingContactHistory = [Select Custom_Soql__c from Talent_CRM_Consent_Batch_Setting__mdt where DeveloperName='tcrm_consent_contact_history' WITH SECURITY_ENFORCED];
        
    private Talent_CRM_Consent_Batch_Setting__mdt batchSettingLeadCreated = [Select Custom_Soql__c from Talent_CRM_Consent_Batch_Setting__mdt where DeveloperName='tcrm_consent_lead_created' WITH SECURITY_ENFORCED];
            
    private Talent_CRM_Consent_Batch_Setting__mdt batchSettingLeadHistory = [Select Custom_Soql__c from Talent_CRM_Consent_Batch_Setting__mdt where DeveloperName='tcrm_consent_lead_history' WITH SECURITY_ENFORCED];
    
    static{
        MCProfileId = [Select id,name from profile where name = 'API Internal - NHW MC' WITH SECURITY_ENFORCED].id;
    }

    public void execute(SchedulableContext sc) {
        Integer batchSize = Integer.valueof(settings.BatchSize__c);

        Database.executeBatch(this,batchSize);
    }
    
    public Iterable<SObject> start(Database.BatchableContext bc) {
        settings = tcrm_ConsentBatchSettings__c.getOrgDefaults();
        isSuccess = false;
        start_time = System.now();
        logs = new List<PF_Debug_Log__c>();
        DateTime lastSuccessfulRun = settings.LastSuccessfulRun__c;
        Date lastSuccessfulRunDate = lastSuccessfulRun.date();
        List <SObject> leadHistoryList = Database.Query(batchSettingLeadHistory.Custom_Soql__c);
        List <SObject> contactHistoryList = Database.Query(batchSettingContactHistory.Custom_Soql__c);
        Set<String> leadIds = new Set<String>();
        for(SObject leadObj : leadHistoryList){
            leadIds.add((String) leadObj.get('Id'));
        }
        List <SObject> createdLeadList = Database.Query(batchSettingLeadCreated.Custom_Soql__c);
        Set<String> contactIds = new Set<String>();
        for(SObject contactObj : contactHistoryList){
            contactIds.add((String)  contactObj.get('Id'));
        }

        List <SObject> consentChangeList = new List<SObject>();
        consentChangeList.addall(leadHistoryList);
        consentChangeList.addall(contactHistoryList);
        consentChangeList.addall(createdLeadList);
        PF_Logger.log('TCRM', 'INFO',null,null, + ' Consent Change Started with Lead History Records ::'+leadHistoryList.size() + 
        ' , Contact History :: '+contactHistoryList.size() + ' , created Lead List :: ' +   createdLeadList.size() 
        ,'tcrm_BatchSyncConsent');
        logs.addall(PF_Logger.logs);
        return consentChangeList;
    }  

    public void execute(Database.BatchableContext bc,List<SObject> consentChangeList){
       TCRM_BatchUtil batchUtil = new TCRM_BatchUtil();
         for(SObject sobj : consentChangeList ){
                tcrm_BeameryContacts.Contacts contact = new tcrm_BeameryContacts.Contacts();
                contact = batchUtil.setBeameryContact(sobj,false);
                if(contact != null && contact.id != null){
                    try{
                        HttpResponse finalresp = apiService.updateContact(contact);
                        if(String.Valueof(finalresp.getStatusCode()) == successCode){
                            recordsProcessed ++;
                        }else{
                            recordsErrored++;
                            PF_Logger.log('TCRM', 'ERROR',null,null, + 'Error during Consent Update , Response ::'+String.valueof(finalresp.getBody()),'tcrm_BatchSyncConsent');
                        }
                    }
                    catch(Exception e){
                        recordsErrored++;
                        PF_Logger.log('TCRM', 'ERROR',null,null, + 'Exception during Consent Update , Exception ::'+e.getMessage(),'tcrm_BatchSyncConsent');
                    }
                }  
            }
        isSuccess = true;
        logs.addall(PF_Logger.logs);
    } 

    public void finish(Database.BatchableContext bc){
        PF_Logger.log('TCRM', 'INFO',null,null,recordsProcessed + ' ::: Consent records processed , Last Successful Time!'+start_time+'::: Success ::'+ isSuccess ,'tcrm_BatchSyncConsent');
        PF_Logger.log('TCRM', 'INFO',null,null,recordsErrored + ' ::: Consent updates failed','tcrm_BatchSyncConsent');
        logs.addall(PF_Logger.logs);
        if (Schema.sObjectType.tcrm_ConsentBatchSettings__c.fields.LastSuccessfulRun__c.isUpdateable() && isSuccess) {
            settings.LastSuccessfulRun__c = start_time;
            update settings;
        }
        logPFLogger();
    }

    public void logPFLogger(){
        if(!logs.isEmpty()){
            PF_Logger.createLogs(logs);
        }
    }
    
}