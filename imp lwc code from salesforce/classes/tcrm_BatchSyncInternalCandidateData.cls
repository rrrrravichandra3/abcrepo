/**
 * @description       : 
 * @author            : Urvish Shah (ushah)
 * @group             : 
 * @last modified on  : 03-24-2023
 * @last modified by  : Urvish Shah (ushah)
**/
public with sharing class tcrm_BatchSyncInternalCandidateData implements Database.Batchable<SObject>,  Schedulable, Database.AllowsCallouts, Database.Stateful {
    tcrm_ConsentBatchSettings__c settings = tcrm_ConsentBatchSettings__c.getOrgDefaults();
    public tcrm_BeameryAPIService apiService = new tcrm_BeameryAPIService();

    List<PF_Debug_Log__c> logs = new List<PF_Debug_Log__c>();
    static final string employeeRecordTypeId;
    public static Integer recordsProcessed = 0;
    static final String successCode = '200';
    static{
        employeeRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee').getRecordTypeId(); 
    }   

    private Talent_CRM_Internal_Applicants_Batch__mdt employeeDataUpdateToBeameryScopeMetadataFromCandidates = [Select Daily_Batch_Scope__c,Nested_SOQL__c from Talent_CRM_Internal_Applicants_Batch__mdt where DeveloperName='Internal_Candidates' WITH SECURITY_ENFORCED];
    private Talent_CRM_Internal_Applicants_Batch__mdt employeeDataUpdateToBeameryScopeMetadataFromApplications = [Select Daily_Batch_Scope__c from Talent_CRM_Internal_Applicants_Batch__mdt where DeveloperName='Internal_Applications' WITH SECURITY_ENFORCED];

    

    public void execute(SchedulableContext sc) {
        Integer batchSize = Integer.valueof(settings.BatchSize__c);

        Database.executeBatch(this,batchSize);
    }
    
    public Iterable<SObject> start(Database.BatchableContext bc) {
        //Apex schedule batch is not initialization settings variable, so we have get settings again in start method
        settings = tcrm_ConsentBatchSettings__c.getOrgDefaults();
        DateTime lastSuccessfulRun = settings.LastSuccessfulRun__c;
        List <SObject> employeeDataUpdateToBeameryScopeFromCandidates = new List <SObject>();
        List <SObject> employeeDataUpdateToBeameryScopeFromApplications = new List <SObject>();
        List<SObject> aggregatedInternalCandidatesScope = new List<SObject>();
        Set<Id> candidateIds = new Set<Id>();

        //Get existing internal candidates scope 
        employeeDataUpdateToBeameryScopeFromCandidates = Database.Query(employeeDataUpdateToBeameryScopeMetadataFromCandidates.Daily_Batch_Scope__c);

        //Get existing internal job applications scope
        employeeDataUpdateToBeameryScopeFromApplications = Database.Query(employeeDataUpdateToBeameryScopeMetadataFromApplications.Daily_Batch_Scope__c);

        for(SObject obj : employeeDataUpdateToBeameryScopeFromApplications){
            candidateIds.add((Id)obj.getSobject('Candidate__r').get('Candidate_Contact__c'));
        }

        List<SObject> candidatesFromInternalApplications = new List<SObject>();
        //Get contact for internal job applications to get "CA" Id to lookup in Beamery
        if(!candidateIds.isEmpty()){
            candidatesFromInternalApplications = Database.Query(employeeDataUpdateToBeameryScopeMetadataFromCandidates.Nested_SOQL__c);
        }

        //Prepare a aggregated scope of contacts from Employee records & Internal Job Applications
        if(!employeeDataUpdateToBeameryScopeFromCandidates.isEmpty()){
            aggregatedInternalCandidatesScope.addAll(employeeDataUpdateToBeameryScopeFromCandidates);
        }
        if(!candidatesFromInternalApplications.isEmpty()){
            aggregatedInternalCandidatesScope.addAll(candidatesFromInternalApplications);
        }
        
        return aggregatedInternalCandidatesScope;
    }  

    public void execute(Database.BatchableContext bc,List<SObject> employeesScope){
        TCRM_BatchUtil batchUtil = new TCRM_BatchUtil();
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
                        PF_Logger.log('TCRM', 'ERROR',null,null, + 'Error during Internal Candidate Data Update , Response ::'+String.valueof(finalresp.getBody()),'tcrm_BatchSyncInternalCandidateData');
                    }
                }
            }
        } 
        logs.addall(PF_Logger.logs);
    }

    public void finish(Database.BatchableContext bc){
        PF_Logger.log('TCRM', 'INFO',null,null,recordsProcessed + 'Employee Data updated','tcrm_BatchSyncInternalCandidateData');
        logs.addall(PF_Logger.logs);
        logPFLogger();
        //Chain Batch Class for Consents
        tcrm_BatchSyncConsent ob = new tcrm_BatchSyncConsent();
        Database.executeBatch(ob,Integer.valueof(settings.BatchSize__c));
    }

    public void logPFLogger(){
        if(!logs.isEmpty()){
            PF_Logger.createLogs(logs);
        }
    }
}