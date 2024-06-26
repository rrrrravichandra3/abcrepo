/**
 * @description       : 
 * @author            : Urvish Shah (ushah)
 * @group             : 
 * @last modified on  : 04-20-2023
 * @last modified by  : Urvish Shah (ushah)
**/
public with sharing class tcrm_BulkConsentOneTimeSync implements Database.Batchable<SObject>,  Schedulable, Database.AllowsCallouts, Database.Stateful {
    
    tcrm_ConsentBatchSettings__c settings = tcrm_ConsentBatchSettings__c.getOrgDefaults();

    private Talent_CRM_Consent_Batch_Setting__mdt batchSettingCustom = [Select Custom_Soql__c from Talent_CRM_Consent_Batch_Setting__mdt where DeveloperName='tcrm_consent_one_time' WITH SECURITY_ENFORCED];
     
    public tcrm_BeameryAPIService apiService = new tcrm_BeameryAPIService();

    DateTime start_time = System.now();
    static final String successCode = '200';
    public Integer recordsProcessed = 0;
    public Integer recordsErrored = 0;
    List<PF_Debug_Log__c> logs = new List<PF_Debug_Log__c>();
    Static Id MCProfileId;
    static{
        MCProfileId = [Select id,name from profile where name = 'API Internal - NHW MC' WITH SECURITY_ENFORCED].id;
    }

    public void execute(SchedulableContext sc) {
        Integer batchSize = Integer.valueof(settings.BatchSize__c);
        Database.executeBatch(this,batchSize);
    }


    public Database.QueryLocator start(Database.BatchableContext bc) {
        String customQuery = batchSettingCustom.Custom_Soql__c ;
        return Database.getQueryLocator(customQuery);
    }

    public void execute(Database.BatchableContext bc,List<SObject> consentChangeList){
        TCRM_BatchUtil batchUtil = new TCRM_BatchUtil();
        for(SObject sobj : consentChangeList ){
               tcrm_BeameryContacts.Contacts contact = new tcrm_BeameryContacts.Contacts();
               contact = batchUtil.setBeameryContact(sobj,true);
               if(contact != null && contact.id != null){
                   try{
                        HttpResponse finalresp = apiService.updateContact(contact);
                        if(String.Valueof(finalresp.getStatusCode()) == successCode){
                            recordsProcessed ++;
                        }
                        else{
                            recordsErrored++;
                        }
                    }
                    catch(Exception e){
                        recordsErrored++;
                    }
               }
           }
           logs.addall(PF_Logger.logs);
   } 

   public void finish(Database.BatchableContext bc){
    PF_Logger.log('TCRM', 'INFO',null,null,recordsProcessed + ' ::: Consents updated in Beamery through One Time Data Intergation','tcrm_BulkConsentOneTimeSync');
    PF_Logger.log('TCRM', 'INFO',null,null,recordsErrored + ' ::: Consents updates Failed in Beamery through One Time Data Intergation','tcrm_BulkConsentOneTimeSync');
    logs.addall(PF_Logger.logs);
    logPFLogger();
    }

    public void logPFLogger(){
        if(!logs.isEmpty()){
            PF_Logger.createLogs(logs);
        }
    }
}