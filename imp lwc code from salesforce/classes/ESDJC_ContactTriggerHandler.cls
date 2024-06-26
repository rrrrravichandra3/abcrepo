@SuppressWarnings('PMD.ExcessiveParameterList')
public without sharing class ESDJC_ContactTriggerHandler {
    public static boolean AlreadyRun = false;
    public static R2H_Community_Settings__c settings = R2H_Community_Settings__c.getInstance();
    public static Set<id> employeeRTId = ESDJC_Util.getDJCContactRecordTypeIds();
    public static Onboarding_Setting__c onboardingSettings = Onboarding_Setting__c.getInstance(); 
    
    public static void beforeInsert(list<Contact> newRecords){
        
        Set<String> ContactEmail = new Set<String>(); 
        for (Contact c: [select email from contact where recordtype.name IN ('Employee','Contractor') and Status__c = 'Active' and employeenumber__c like 'c%' ]){
            ContactEmail.add(c.email);
        }
        String salesforceAccountIdText = onboardingSettings.salesforce_accountId__c;
        id accid = (String.isBlank(salesforceAccountIdText))?[select id from account where name = 'salesforce.com' limit 1].id : Id.valueOf(salesforceAccountIdText);
        id recid = [select id from RecordType WHERE developername='Contractor' AND sobjecttype='Contact'].id;
                
        for (Contact c: newRecords){
            if (c.REWS_Supportforce_Resource_Type__c!=null){        
                if(ContactEmail.contains(c.email)){
                    c.adderror('Contractor record already exists. Skipping!');
                }               
                if (c.REWS_Supportforce_Resource_Type__c.equalsIgnoreCase('SFDC Employee') && 
                                    c.REWS_Supportforce_Resource_Type__c.equalsIgnoreCase('Intern')){
                    c.adderror('Cannot create an employee or an intern through S2S connector');                 
                }
                c.RecordTypeId = recid;
                c.Division__c = c.REWS_Supportforce_Division__c;
                c.ES_DJC_Work_Location__c = c.MailingCity;
                c.AccountId = accid;
                c.ES_DJC_Record_Status__c = 'New';          
                c.Resource_Type__c = c.REWS_Supportforce_Resource_Type__c;      
                c.Primary_Country_of_Coverage_PCC__c = c.REWS_SF_Primary_Coverage_Country__c;                                       
            }
        }
    }
    public static void beforeUpdate(List<Contact> newRecords,list<Contact> oldRecords,Map<Id,Contact> newRecordsMap,Map<Id, Contact> oldRecordsMap){                
        id accid = [select id from account where name = 'salesforce.com' limit 1].id;
        id recid = [select id from RecordType WHERE developername='Employee' AND sobjecttype='Contact'].id;
        
        
                            
        for (Contact c: newRecords){
            if (c.REWS_Supportforce_Resource_Type__c!=null){
                c.Division__c = c.REWS_Supportforce_Division__c;
                c.Resource_Type__c = c.REWS_Supportforce_Resource_Type__c;      
                c.Primary_Country_of_Coverage_PCC__c = c.REWS_SF_Primary_Coverage_Country__c;                           
                c.ES_DJC_Work_Location__c = c.MailingCity;
                c.AccountId = accid;
                c.Resource_Type__c = c.REWS_Supportforce_Resource_Type__c;          
                c.ES_DJC_Record_Status__c = 'Updated';                                                                                          
                //If converted from contractor to FTE
                if(oldRecordsMap.get(c.id).REWS_Supportforce_Resource_Type__c != newRecordsMap.get(c.id).REWS_Supportforce_Resource_Type__c){
                    if (c.REWS_Supportforce_Resource_Type__c.equalsIgnoreCase('SFDC Employee')){
                        //if email changed then deactivate                          
                        if(oldRecordsMap.get(c.id).email != newRecordsMap.get(c.id).email){
                            c.Status__c = 'Deactive';                   
                        //else convert to employee record type
                        }else{
                            c.RecordTypeId = recid;
                        }                                       
                    }
                }                               
            }
        }       
    }
    
    public static void handleContactsWithoutPortalUsers(List<Contact> newRecords,list<Contact> oldRecords,
                                        Map<Id,Contact> newRecordsMap,Map<Id, Contact> oldRecordsMap){
        Set<Id> contactsWithPortalUsers = new Set<Id>();                                            
        //Check if portal user exists for the contacts
        for (User u : [select ContactId from User where ContactId IN :newRecordsMap.keySet() AND Contact.recordtypeid IN :employeeRTId]) {
            contactsWithPortalUsers.add(u.ContactId);
        }
        for (Contact c: newRecords){
            if (employeeRTId.contains(c.recordTypeId) && c.ES_DJC_Record_Status__c!=null && c.ES_DJC_Record_Status__c.equalsIgnoreCase('Updated')){
                if (!contactsWithPortalUsers.contains(c.id)){
                    c.ES_DJC_Record_Status__c = 'New';
                }               
            }
        }       
    }

    static boolean isFieldChanged(Contact newRecord,Contact oldRecord, String fieldName) {
        if (newRecord.get(fieldName) != oldRecord.get(fieldName)){
            return true;				          		
        }
        return false;
    }

    
    public static void validatedUpdatedContacts(List<Contact> newRecords,list<Contact> oldRecords,
                                        Map<Id,Contact> newRecordsMap,Map<Id, Contact> oldRecordsMap){
        if ((newRecords==null) || (oldRecords==null)){
        	return;
        }                                	          
    	for (integer i=0; i<newRecords.size(); i++){
          	boolean updated = false;

            if(isFieldChanged(newRecords.get(i), oldRecords.get(i), 'Status__c') || 
                isFieldChanged(newRecords.get(i), oldRecords.get(i), 'Division__c') || 
                isFieldChanged(newRecords.get(i), oldRecords.get(i), 'Email') || 
                isFieldChanged(newRecords.get(i), oldRecords.get(i), 'FirstName') || 
                isFieldChanged(newRecords.get(i), oldRecords.get(i), 'LastName') || 
                isFieldChanged(newRecords.get(i), oldRecords.get(i), 'EmployeeNumber__c') || 
                isFieldChanged(newRecords.get(i), oldRecords.get(i), 'Title') || 
                isFieldChanged(newRecords.get(i), oldRecords.get(i), 'ES_DJC_Business_Unit__c') || 
                isFieldChanged(newRecords.get(i), oldRecords.get(i), 'ES_DJC_Cost_Center__c') || 
                isFieldChanged(newRecords.get(i), oldRecords.get(i), 'Primary_Country_of_Coverage_PCC__c') || 
                isFieldChanged(newRecords.get(i), oldRecords.get(i), 'Start_Date__c') || 
                isFieldChanged(newRecords.get(i), oldRecords.get(i), 'Hiring_Manager__c'))
                {
                    updated = true;
                }
        	
          	if (employeeRTId.contains(newRecords.get(i).recordTypeId) && newRecords.get(i).ES_DJC_Record_Status__c!=null && newRecords.get(i).ES_DJC_Record_Status__c.equalsIgnoreCase('Updated') && !updated ){
          		newRecords.get(i).ES_DJC_Record_Status__c = oldRecords.get(i).ES_DJC_Record_Status__c;
          	}          		                    	          	
         }                              	
	  }

    /*
    * Post SSOR (targeted May 2021), S2S connection with supportforce will be disconnected
    * Contractor records will be brought in by EI 
    * we need to make sure that ES_DJC_Record_Status__c continues to be set to New or Updated for contractor contacts
    * so that their portal user creation is not affected
    */
    public static void setRecordStatusForContractors(List<Contact> newRecords,list<Contact> oldRecords,
                                        Map<Id,Contact> newRecordsMap,Map<Id, Contact> oldRecordsMap){
      //this functionality only available when feature flag is set to true
      //we are prepping for May release of SSOR. In May release, we will check the feature flag and below code will become active
      if(!onboardingSettings.SSOR_Feature_Flag__c){return;}
      Id contractorContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contractor').getRecordTypeId();
      //Logic for insert trigger
      if(oldRecordsMap == null){
        for(Contact c : newRecords){
          if(c.recordTypeId == contractorContactRecordTypeId && String.isBlank(c.ES_DJC_Record_Status__c)){
            c.ES_DJC_Record_Status__c = 'New';
          }
        }
        return;
      }
      //Logic for update trigger
      if(oldRecordsMap!=null && newRecordsMap!=null){
        for(Contact c : newRecords){
          if(c.recordTypeId == contractorContactRecordTypeId 
            && //We only want to execute this code if some other field on contact changed
            oldRecordsMap.get(c.Id).ES_DJC_Record_Status__c == c.ES_DJC_Record_Status__c){
              c.ES_DJC_Record_Status__c = 'Updated';
          }
        }
        return;
      }
    }
}