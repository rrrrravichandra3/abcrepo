/**
 * @description       : 
 * @author            : Urvish Shah (ushah)
 * @group             : 
 * @last modified on  : 03-24-2023
 * @last modified by  : Urvish Shah (ushah)
**/
public with sharing class tcrm_SyncInternalCandidatesOneTime implements Database.Batchable<SObject>,  Schedulable, Database.AllowsCallouts, Database.Stateful {
    tcrm_ConsentBatchSettings__c settings = tcrm_ConsentBatchSettings__c.getOrgDefaults();
    public tcrm_BeameryAPIService apiService = new tcrm_BeameryAPIService();
    TCRM_BatchUtil batchUtil = new TCRM_BatchUtil();
    List<PF_Debug_Log__c> logs = new List<PF_Debug_Log__c>();
    public static Integer recordsProcessed = 0;
    static final string employeeRecordTypeId;
    static final String successCode = '200';

    static{
        employeeRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee').getRecordTypeId(); 
    }  

    private Talent_CRM_Internal_Applicants_Batch__mdt employeeDataUpdateToBeameryScopeMetadataFromCandidates = [Select Historical_Data_Scope__c,Historical_Data_From__c from Talent_CRM_Internal_Applicants_Batch__mdt where DeveloperName='Internal_Candidates' WITH SECURITY_ENFORCED];
    DateTime historicalDataFromDateForCandidates = employeeDataUpdateToBeameryScopeMetadataFromCandidates.Historical_Data_From__c;

    public void execute(SchedulableContext sc) {
        Integer batchSize = Integer.valueof(settings.BatchSize__c);
        Database.executeBatch(this,batchSize);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String customQuery = employeeDataUpdateToBeameryScopeMetadataFromCandidates.Historical_Data_Scope__c ;
        return Database.getQueryLocator(customQuery);
    }

    public void execute(Database.BatchableContext bc,List<SObject> employeesScope){
        List<Contact> employees = (List<Contact>)employeesScope;    
        TCRM_BatchUtil.EmployeeCandidateMappingEnabler employeeCandidateEnabler = batchUtil.prepareEmployeeCandidateMapping(employees);
        Map<Id, Contact> wdCandidatesMap = employeeCandidateEnabler.wdCandidatesMap;
        Map<Id,Id> employeeToCandidateMap = employeeCandidateEnabler.employeeToCandidateMap;
        String currentDateString = string.valueof(datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
        String dateString = '';
        for(Contact employee : employees ){
            tcrm_BeameryContacts.Contacts contact = new tcrm_BeameryContacts.Contacts();
            tcrm_BeameryContacts.Location contactLocation = new tcrm_BeameryContacts.Location();
            if(!wdCandidatesMap.isEmpty() &&  !employeeToCandidateMap.isEmpty() && employeeToCandidateMap.containsKey(employee.ID)){
                contact.id = apiService.getContactIdByWorkdayCandidateId(wdCandidatesMap.get(employeeToCandidateMap.get(employee.ID)).WD_Candidate_WDI__c);
                contact.emails = new List<String>{employee.Email};
                String address = batchUtil.formatCandidateAddress(employee);

                if(!String.isBlank(address)){
                    contactLocation.address = address;
                }

                if(employee.MailingCountry != null){
                    contactLocation.country = employee.MailingCountry;
                }

                if(contactLocation.address != null && contactLocation.country != null){
                    contact.location = contactLocation;
                }

                // set Internal Contacts - Consent Information
                String recruitingOptInc = (String) wdCandidatesMap.get(employeeToCandidateMap.get(employee.ID)).Recruiting_Opt_In__c;
                String marketingOptInc  = (String) wdCandidatesMap.get(employeeToCandidateMap.get(employee.ID)).Marketing_Opt_In__c;
                if((recruitingOptInc != null && recruitingOptInc != '') || (marketingOptInc != null && marketingOptInc != '')){
                    Datetime lidate = (Datetime) wdCandidatesMap.get(employeeToCandidateMap.get(employee.ID)).Last_Interaction_Date__c;
                    Datetime mrsDate =  wdCandidatesMap.get(employeeToCandidateMap.get(employee.ID)).MRS_App__r != null ? (Datetime) wdCandidatesMap.get(employeeToCandidateMap.get(employee.ID)).MRS_App__r.get('Application_Date__c'): null;
                    String lastInteractionDate = string.valueOf(lidate != null ? lidate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''):'');
                    String mrsDateString = string.valueOf(mrsDate != null ? mrsDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''):'');
                    dateString = (lastInteractionDate != null && lastInteractionDate != '') ? lastInteractionDate : mrsDateString;
                    dateString = dateString != ''? dateString: currentDateString;
                    contact.gdprConsent =  true;
                    List<tcrm_BeameryContacts.CustomFields> customFieldsCont = new List<tcrm_BeameryContacts.CustomFields>();
                    customFieldsCont.addall(batchUtil.setMarketConsentCustomFields(marketingOptInc,dateString));
                    customFieldsCont.addall(batchUtil.setRecruitingConsentCustomFields(recruitingOptInc,dateString));
                    contact.customFields = customFieldsCont;
                } 

                if(contact != null && contact.id != null){
                    HttpResponse finalresp = apiService.updateContact(contact);
                    if(String.Valueof(finalresp.getStatusCode()) == successCode){
                        recordsProcessed ++;
                    }else{
                        PF_Logger.log('TCRM', 'ERROR',null,null, + 'Error during Internal Candidate Data Update , Response ::'+String.valueof(finalresp.getBody()),'tcrm_SyncInternalCandidatesOneTime');
                    }
                }
            } 
        } 
        logs.addall(PF_Logger.logs);
    }
    
    public void finish(Database.BatchableContext bc){
        PF_Logger.log('TCRM', 'INFO',null,null,recordsProcessed + 'Employee Data updated through one time data update','tcrm_SyncInternalCandidatesOneTime');
        logs.addall(PF_Logger.logs);
        logPFLogger();
    }

    public void logPFLogger(){
        if(!logs.isEmpty()){
            PF_Logger.createLogs(logs);
        }
    }
}