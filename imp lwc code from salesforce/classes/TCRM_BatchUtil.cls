/**
 * @description       : 
 * @author            : Urvish Shah (ushah)
 * @group             : 
 * @last modified on  : 06-13-2024
 * @last modified by  : Urvish Shah (ushah)
**/
public with sharing class TCRM_BatchUtil {

    public tcrm_BeameryAPIService apiService = new tcrm_BeameryAPIService();

    static List<Talent_CRM_Custom_Fields_Settting__mdt> listFieldsID = Talent_CRM_Custom_Fields_Settting__mdt.getAll().values();

    static List<Talent_CRM_Custom_Fields_Values_Setting__mdt> listFieldsValuesID = Talent_CRM_Custom_Fields_Values_Setting__mdt.getAll().values();

    static Map<String, String> mapFieldsID = new Map<String, String>(); 

    static Map<String, String> mapFieldsValues = new Map<String, String>(); 

    static List<Beamery_To_CEMCI_Lead_Mapping__mdt> beameryToCEMCILeadMapping;
    static final string candidateRecordTypeId;  
    static String linkedInURL;
    static Map<String,String> beameryContactCustomFieldsValueMap;
    
    static{
        candidateRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('WDR_Candidate').getRecordTypeId();
        beameryToCEMCILeadMapping = [Select Beamery_Object__c,Beamery_Attribute_Name__c,CEMCI_Lead_Attribute__c from Beamery_To_CEMCI_Lead_Mapping__mdt WITH SECURITY_ENFORCED];
        linkedInURL = System.Label.CEMCI_Valid_LinkedIn_URL;
        beameryContactCustomFieldsValueMap = new Map<String,String>{
            'Yes'=>'Opt In',
            'No'=>'Opt Out',
            'Software Engineering' => 'Tech - Engineering',
            'Corporate' => 'Administrative Support',
            'Customer Success' => 'Customer Success Group',
            'Employee Success' => 'Employee Success Group',
            'Development & Strategy' => 'Corporate Development',
            'Finance' => 'Finance and Operations',
            'Legal & Global Affairs' => 'Legal',
            'Marketing & Communications' => 'Marketing',
            'Operations' => 'Operations',
            'Product' => 'Products and Technology',
            'Program & Project Management' => 'Program/Project Management',
            'Sales' => 'Sales',
            'User Experience' => 'User Experience',
            'Compliance' => 'Compliance',
            'Data' => 'Data',
            'Real Estate & Facility Management' => 'Real Estate & Facility Management',
            'Enterprise Technology & Infrastructure' => 'Enterprise Technology & Infrastructure',
            'Other' => 'Other'
        };
    }   

    public static void populateFieldMap() {

        for(Talent_CRM_Custom_Fields_Settting__mdt fieldObj: listFieldsID){
            mapFieldsID.put(fieldObj.DeveloperName, fieldObj.Field_ID__c);
        }
        for(Talent_CRM_Custom_Fields_Values_Setting__mdt fieldObj: listFieldsValuesID){
            mapFieldsValues.put(fieldObj.DeveloperName, fieldObj.Id__c);
        }
    }   

    static {
        populateFieldMap();
      }

    public  tcrm_BeameryContacts.Contacts setBeameryContact(SObject sobj,Boolean isBulkLoad){
        Id id = (Id) sobj.get('Id');
        String sObjectType = String.valueOf(id.getSobjectType());
        Object contactFromContactHistory;
        String email;
        String recruitingOptInc;
        String marketingOptInc;
        String workerId;
        
        if(sObjectType == 'ContactHistory'){
            contactFromContactHistory = getContactAttributes(sobj);
            Map<String, Object> contact = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(contactFromContactHistory));
            email = (String) contact.get('Email');
            recruitingOptInc = (String) contact.get('Recruiting_Opt_In__c');
            marketingOptInc = (String) contact.get('Marketing_Opt_In__c');
            workerId = (String) contact.get('WD_Candidate_WDI__c');
        }
        else{
            email = (String) sobj.get('Email');
            recruitingOptInc = (String) sobj.get('Recruiting_Opt_In__c');
            marketingOptInc = (String) sobj.get('Marketing_Opt_In__c');
            if(sObjectType == 'Contact'){
                workerId = (String) sobj.get('WD_Candidate_WDI__c');
            }
        }

        tcrm_BeameryContacts.Contacts contact = new tcrm_BeameryContacts.Contacts();
        String conId;
        
        switch on sObjectType {
            when 'Contact','ContactHistory' {
                conId = apiService.getContactIdByWorkdayCandidateId(workerId);
            }
            when 'Lead' {
                conId = apiService.getContactIdByEmail(email);
            }
            when else {
                conId = null;
            }
        }
        String dateString = string.valueof(datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
        if(isBulkLoad && sobj.getSObjectType().getDescribe().getName() == 'Contact'){
            Datetime lidate =  sobj.get('Last_Interaction_Date__c') != null ? (Datetime)sobj.get('Last_Interaction_Date__c') : null;
            String lastInteractionDate = string.valueOf(lidate != null ? lidate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''):'');
            String mrsDateString = '';
            if(sobj.getSobject('MRS_App__r') != null){
                Datetime mrsDate =  sobj.getSobject('MRS_App__r').get('Application_Date__c') != null ? (Datetime)sobj.getSobject('MRS_App__r').get('Application_Date__c') : null;
                mrsDateString = string.valueOf(mrsDate != null ? mrsDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''):'');
            }
            dateString = (lastInteractionDate != null && lastInteractionDate != '') ? lastInteractionDate : mrsDateString;
           
        }
        else if(isBulkLoad && sobj.getSObjectType().getDescribe().getName() == 'Lead'){
            Datetime leadLidate =  sobj.get('Last_Interaction_Date__c') != null ? (Datetime)sobj.get('Last_Interaction_Date__c') : null;
            String leadLastInteractionDateString = string.valueOf(leadLidate != null ? leadLidate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''):'');
            Datetime leadCreatedDate =  sobj.get('CreatedDate') != null ? (Datetime)sobj.get('CreatedDate') : null;
            String leadCreatedDateString = string.valueOf(leadCreatedDate != null ? leadCreatedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''):'');
            dateString = (leadLastInteractionDateString != null && leadLastInteractionDateString != '') ? leadLastInteractionDateString : leadCreatedDateString;
            
        }

        if(conId != null){ 
            contact.Id = conId;
            contact.gdprConsent =  true;
            List<tcrm_BeameryContacts.CustomFields> customFieldsCont = new List<tcrm_BeameryContacts.CustomFields>();
            customFieldsCont.addall(setMarketConsentCustomFields(marketingOptInc,dateString));
            customFieldsCont.addall(setRecruitingConsentCustomFields(recruitingOptInc,dateString));
            contact.customFields = customFieldsCont;
        }else{
            PF_Logger.log('TCRM', 'ERROR',null,null,'Email not found in Beamery :: '+ email + ' :: ID :: ' + id,'tcrm_BatchSyncConsent');
            return null;
        }
    return contact;
}

private Object getContactAttributes(SObject sobj){
    Map<String, Object> contactHistory = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(sobj));
    return contactHistory.get('Contact');
}

public  List<tcrm_BeameryContacts.CustomFields> setMarketConsentCustomFields(String marketingOptInc,String dateString){
    List<tcrm_BeameryContacts.CustomFields> customFieldsCont = new  List<tcrm_BeameryContacts.CustomFields>();
    tcrm_BeameryContacts.CustomFields customFieldsMarketOpt = new tcrm_BeameryContacts.CustomFields();
   
    customFieldsMarketOpt.id = mapFieldsID.get('Compliance_Marketing_Consent');
    if(marketingOptInc == 'Opt In'){
        customFieldsMarketOpt.value =  mapFieldsValues.get('Marketing_Yes');
    }else if(marketingOptInc == 'Opt Out'){
        customFieldsMarketOpt.value =  mapFieldsValues.get('Marketing_No');
    }
    
    if(marketingOptInc != null && marketingOptInc != ''){
        customFieldsCont.add(customFieldsMarketOpt);
        
    }

    tcrm_BeameryContacts.CustomFields customFieldsMarketOptDate = new tcrm_BeameryContacts.CustomFields();
            customFieldsMarketOptDate.id = mapFieldsID.get('Compliance_Marketing_Consent_Date') ;
            if(marketingOptInc != null && marketingOptInc != ''){
                customFieldsMarketOptDate.value = dateString;
                customFieldsCont.add(customFieldsMarketOptDate);
            }
    return customFieldsCont;
}

public  List<tcrm_BeameryContacts.CustomFields> setRecruitingConsentCustomFields(String recruitingOptInc,String dateString){
    List<tcrm_BeameryContacts.CustomFields> customFieldsCont = new  List<tcrm_BeameryContacts.CustomFields>();
    tcrm_BeameryContacts.CustomFields customFieldsRecOpt = new tcrm_BeameryContacts.CustomFields();
            customFieldsRecOpt.id = mapFieldsID.get('Compliance_Sourcing_Consent');
            if(recruitingOptInc == 'Opt In'){
                customFieldsRecOpt.value =  mapFieldsValues.get('Sourcing_Yes');
            }else if(recruitingOptInc == 'Opt Out'){
                customFieldsRecOpt.value =   mapFieldsValues.get('Sourcing_No');
            }
            if(recruitingOptInc != null && recruitingOptInc != ''){
                customFieldsCont.add(customFieldsRecOpt);
                
            }
            tcrm_BeameryContacts.CustomFields customFieldsRecOptDate = new tcrm_BeameryContacts.CustomFields();
            customFieldsRecOptDate.id = mapFieldsID.get('Compliance_Sourcing_Consent_Date');
            
            if(recruitingOptInc != null && recruitingOptInc != ''){
                customFieldsRecOptDate.value = dateString;
                customFieldsCont.add(customFieldsRecOptDate);
            }
    return customFieldsCont;
}

public EmployeeCandidateMappingEnabler prepareEmployeeCandidateMapping(List<Contact> employees){
    Set<String> employeeIds = new Set<String>();
    Map<String,Id> employeeIdToInternalCandidateIdMap = new Map<String,Id>();
    Map<String,Id> employeeIdToWDCandidateIdMap = new Map<String,Id>();
    Map<Id,Id> employeeToCandidateMap = new Map<Id,Id>();
    
    //Prepare a map of Employee Number to Employee Record Id
    for(Contact employee : employees){
        employeeIds.add(employee.EmployeeNumber__c); 
        employeeIdToInternalCandidateIdMap.put(employee.EmployeeNumber__c,employee.Id);
    }

    //Get a map of WD candidates related to Employees based on Employee Number
    Map<Id, Contact> wdCandidatesMap = new Map<Id,Contact>([SELECT Id,Email,CreatedDate,WD_Candidate_WDI__c,EmployeeNumber__c,Recruiting_Opt_In__c,Marketing_Opt_In__c,Last_Interaction_Date__c,MRS_App__r.Application_Date__c 
                                                            FROM Contact 
                                                            WHERE RecordType.ID = :candidateRecordTypeId AND EmployeeNumber__c IN :employeeIds AND WD_Candidate_WDI__c != null WITH SECURITY_ENFORCED]
                                                        );
    
    //Prepare a map of Employee Number to WD Candidate Record Id                                                                  
    for(Contact wdCandidate : wdCandidatesMap.values()){
        employeeIdToWDCandidateIdMap.put(wdCandidate.EmployeeNumber__c,wdCandidate.Id);
    }

    /*Prepare a map of Employee Record ID => Related WD Candidate Record ID
    Beamery Contact lookup will be done based on "CA" id which is found on WD Candidate Record and relevant data updates (Email,Location) 
    for the candidate has to be taken from Employee Reord*/

    for(String employeeId : employeeIdToInternalCandidateIdMap.keySet()){
        if(employeeIdToWDCandidateIdMap.containsKey(employeeId)){
            employeeToCandidateMap.put(employeeIdToInternalCandidateIdMap.get(employeeId), employeeIdToWDCandidateIdMap.get(employeeId));
        }
    }

    return new TCRM_BatchUtil.EmployeeCandidateMappingEnabler(wdCandidatesMap,employeeToCandidateMap);
}

//Format address from different attributes to send as a string to beamery
public String formatCandidateAddress(Contact employee){
    String address = '';
    if(!String.isBlank(employee.MailingStreet)){
        address += employee.MailingStreet;
    }
    if(!String.isBlank(employee.MailingCity)){
        address += address == '' ? employee.MailingCity : ', '+employee.MailingCity;
    }
    if(!String.isBlank(employee.MailingState)){
        address += address == '' ? employee.MailingState : ', '+employee.MailingState;
    }
    if(!String.isBlank(employee.MailingCountry)){
        address += address == '' ? employee.MailingCountry : ', '+employee.MailingCountry;
    }
    return address;
}

public class EmployeeCandidateMappingEnabler{
    public Map<Id, Contact> wdCandidatesMap = new Map<Id,Contact>();
    public Map<Id,Id> employeeToCandidateMap = new Map<Id,Id>();

    public EmployeeCandidateMappingEnabler(Map<Id, Contact> wdCandidatesMap, Map<Id,Id> employeeToCandidateMap){
        this.wdCandidatesMap = wdCandidatesMap;
        this.employeeToCandidateMap = employeeToCandidateMap;
    }

}

public class BeameryGetContactsResponseWrapper{
    public List<tcrm_BeameryContacts.Contacts> beameryContacts = new List<tcrm_BeameryContacts.Contacts>();
    public Long totalCount;
    public Integer statusCode;

    public beameryGetContactsResponseWrapper(List<tcrm_BeameryContacts.Contacts> beameryContacts, Long totalCount, Integer statusCode){
        this.beameryContacts = beameryContacts;
        this.totalCount = totalCount;
        this.statusCode = statusCode;
    }
}

public List<Lead> syncUpdatedBeameryLeads(List<tcrm_BeameryContacts.Contacts> beameryContacts){
    List<Lead> leads = new List<Lead>();
    Map<String,TCRM_BatchUtil.BeameryUpdatedLeadData> updatedBeameryLeadMap = new Map<String, TCRM_BatchUtil.BeameryUpdatedLeadData>();
    String sorcingConsent;
    String marketingConsent;
    for(tcrm_BeameryContacts.Contacts contact : beameryContacts){
        if(contact.customFields != null){
            for(tcrm_BeameryContacts.CustomFields cf : contact.customFields){
                if(cf.displayName == 'Compliance - Sourcing Consent'){
                    sorcingConsent = beameryContactCustomFieldsValueMap.get(cf.displayValue);
                }
                if(cf.displayName == 'Compliance - Marketing Consent'){
                    marketingConsent = beameryContactCustomFieldsValueMap.get(cf.displayValue);
                }
            }
        } 
        if(!String.isBlank(contact.primaryEmail) && (!String.isBlank(sorcingConsent) || !String.isBlank(marketingConsent))){
            updatedBeameryLeadMap.put(contact.primaryEmail.toLowerCase(),new TCRM_BatchUtil.BeameryUpdatedLeadData(sorcingConsent,marketingConsent));
        }
    }

    if(!updatedBeameryLeadMap.isEmpty()){
        leads = updateCEMCILeads(updatedBeameryLeadMap);
    }
    
    return leads;
}

public List<Lead> updateCEMCILeads(Map<String,TCRM_BatchUtil.BeameryUpdatedLeadData> updatedBeameryLeadMap){
    List<Lead> leads = new List<Lead>();
    for(Lead lead : [SELECT id,Marketing_Opt_In__c,Recruiting_Opt_In__c,Email
                    FROM Lead
                    WHERE email IN: updatedBeameryLeadMap.keySet() WITH SECURITY_ENFORCED]){
        Lead leadUpdate = new Lead();
        leadUpdate.put('Id',lead.id);
        String leadEmail = lead.email.toLowerCase();
        if(updatedBeameryLeadMap.containsKey(leadEmail) && updatedBeameryLeadMap.get(leadEmail).marketingConsent != null){
            leadUpdate.put('Marketing_Opt_In__c',updatedBeameryLeadMap.get(leadEmail).marketingConsent);
        }
        if(updatedBeameryLeadMap.containsKey(leadEmail) && updatedBeameryLeadMap.get(leadEmail).sourcingConsent != null){
            leadUpdate.put('Recruiting_Opt_In__c',updatedBeameryLeadMap.get(leadEmail).sourcingConsent);
        }
        leads.add(leadUpdate);
    }
    return leads;
}

public class BeameryUpdatedLeadData{
    public String sourcingConsent;
    public String marketingConsent;

    public BeameryUpdatedLeadData(String sourcingConsent, String marketingConsent){
        this.sourcingConsent = sourcingConsent;
        this.marketingConsent = marketingConsent;
    }
}

public List<Lead> processBeameryContactsToCreateLeads(List<tcrm_BeameryContacts.Contacts> beameryContacts){
    //Logic to process  beamery contact to map to CEMCI Leads
    List<Lead> leads = new List<Lead>();
    for(tcrm_BeameryContacts.Contacts contact : beameryContacts){
        leads.add(mapBeameryContactToCEMCILead(contact));
    }
    return leads;
}

public Lead mapBeameryContactToCEMCILead(tcrm_BeameryContacts.Contacts beameryContact){
    Lead lead = new Lead();
    lead.put('Created_From_Beamery__c',true);
    mapBeameryContactRootDataToLead(beameryContact,lead);
    mapBeameryContactCustomFieldsDataToLead(beameryContact,lead);
    mapBeameryContactRelatedDataToLead(beameryContact,lead);

    return lead;
}

private Lead mapBeameryContactRootDataToLead(tcrm_BeameryContacts.Contacts beameryContact,Lead lead){
    for(Beamery_To_CEMCI_Lead_Mapping__mdt mapping : beameryToCEMCILeadMapping){
        if(mapping.Beamery_Object__c == 'root'){
            if(mapping.Beamery_Attribute_Name__c == 'links' && beameryContact.links != null){
                for(String link : beameryContact.links){
                    if(link.startsWithIgnoreCase('https://www.linkedin.com/in/') && isValidLinkedInURL(link)){
                        lead.put(mapping.CEMCI_Lead_Attribute__c,link); 
                        break;
                    }
                }
            }
            else if(mapping.Beamery_Attribute_Name__c != 'links' && beameryContact.getX(mapping.Beamery_Attribute_Name__c) != null){
                lead.put(mapping.CEMCI_Lead_Attribute__c,beameryContact.getX(mapping.Beamery_Attribute_Name__c));
            }
        }
    }
    return lead;
}

private Lead mapBeameryContactCustomFieldsDataToLead(tcrm_BeameryContacts.Contacts beameryContact,Lead lead){
    for(Beamery_To_CEMCI_Lead_Mapping__mdt mapping : beameryToCEMCILeadMapping){
        if(mapping.Beamery_Object__c == 'customFields'){
            if(beameryContact.customFields != null){
                for(tcrm_BeameryContacts.CustomFields cf : beameryContact.customFields){
                    if(cf.displayName == mapping.Beamery_Attribute_Name__c && beameryContactCustomFieldsValueMap.containsKey(cf.displayValue)){
                        lead.put(mapping.CEMCI_Lead_Attribute__c,beameryContactCustomFieldsValueMap.get(cf.displayValue)); 
                    }
                }
            } 
        }
    }
    return lead;
}

private Lead mapBeameryContactRelatedDataToLead(tcrm_BeameryContacts.Contacts beameryContact,Lead lead){
    String orgName = '[Not Provided]';
    for(Beamery_To_CEMCI_Lead_Mapping__mdt mapping : beameryToCEMCILeadMapping){
        if(mapping.Beamery_Object__c != 'customFields' && mapping.Beamery_Object__c != 'root'){
            if(mapping.Beamery_Object__c == 'languages' && beameryContact.languages != null){
                lead.put(mapping.CEMCI_Lead_Attribute__c,beameryContact.languages[0].value);
                if(beameryContact.languages.size() > 1){
                    lead.put('Language_2__c',beameryContact.languages[1].value);
                } 
            } 
            if(mapping.Beamery_Object__c == 'experience' && beameryContact.experience != null){
                for(tcrm_BeameryContacts.Experience exp : beameryContact.experience){
                    if(exp.current != null && exp.current){
                        orgName = exp.organisationName;
                        break;
                    }
                }
            } 
            if(mapping.Beamery_Object__c == 'location' && beameryContact.location != null){
                lead.put(mapping.CEMCI_Lead_Attribute__c,beameryContact.location.country);
            }
            if(mapping.Beamery_Object__c == 'pools' && beameryContact.lists != null){
                String pools = '';
                for(tcrm_BeameryContacts.Pool pool : beameryContact.lists){
                    if(pools != ''){
                        pools += ','+pool.name;
                    }
                    else{
                        pools += pool.name;
                    }
                }
                lead.put(mapping.CEMCI_Lead_Attribute__c,pools); 
            }
        }
    }
    lead.put('Company',orgName); 
    return lead;
}

private boolean isValidLinkedInURL(String incomingLinkedInURL){
    Pattern linkedInURLPattern = Pattern.compile(linkedInURL);
    Matcher inputURLMatcher = linkedInURLPattern.matcher(incomingLinkedInURL);
    return inputURLMatcher.matches();
}

public void logPFLogger(){

    if(!PF_Logger.logs.isEmpty()){
        PF_Logger.createLogs(PF_Logger.logs);
    }
}

}