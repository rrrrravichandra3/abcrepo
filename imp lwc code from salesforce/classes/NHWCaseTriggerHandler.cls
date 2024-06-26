@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
public without sharing class NHWCaseTriggerHandler {

  private static boolean isFutureCalled = false; 
  public static boolean afterCallsExecuted = false;
  private static Onboarding_Setting__c onBoardingSetting = Onboarding_Setting__c.getInstance(); 
  private static NH_Settings__c NHSettings = NH_Settings__c.getInstance(); 
  private static List<String> SYSTEM_FIELDS = String.isBlank(NHSettings.Case_Fields_Do_Not_Fire_Jitterbit__c) == false ? NHSettings.Case_Fields_Do_Not_Fire_Jitterbit__c.split(';') : new List<String>();

  private static final Id nhwPreBoardCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Hire Process').getRecordTypeId();
  public static List<String> ValidADEmailDomains = new List<String>();
  
  public static boolean isValidADEmailDomain(String emailAddress)
  {
    if(NHSettings.Valid_AD_Email_Domains__c != NULL)
         {
          ValidADEmailDomains = NHSettings.Valid_AD_Email_Domains__c.split(',');
         }
    String emailSubstring = (emailAddress!= NULL) ? emailAddress.substringAfter('@') : NULL ;
      if(emailSubstring != NULL)
      {
          return ValidADEmailDomains.contains(emailSubstring.toLowerCase());
      }
      return false; //email substring is null
}

  private static final String RECORD_TYPE_NEW_HIRE_PROCCESS = 'New Hire Process';
  private static final String RECORD_TYPE_APINAME_NEW_HIRE_PROCESS = 'New_Hire_Process';
  private static final String RECORD_TYPE_APINAME_NEW_HIRE_PROCESS_ONBOARDING = 'New_Hire_Process_Onboarding';
  private static final String RECORD_TYPE_NEW_HIRE_PROCCESS_ONBOARDING = 'New Hire Process - Onboarding';
  private static Id senderId = NHW_Util.getOrgWideEmail('noreply_nhw@salesforce.com');
  private static final String PF_DEBUG_LOG_TYPE_DATA_ERROR = 'Data Error';
  private static final String CASE_STATUS_SENT_TO_SUPPORTFORCE = 'Sent to Supportforce';
  private static final String CASE_STATUS_CLOSED = 'Closed';
  private static final String CASE_STATUS_ACC_IN_PROGRESS = 'Accounts in Progress - Supportforce';
  private static final String CASE_STATUS_CLOSED_CANCELLED = 'Closed - Cancelled';

 

  //populate NH Employee id 
  public static void populateNHEmployeeId(List<Case> newCases){

    set<Id> caseRecordTypeIdSet = new set<Id>();
    Set<Id> newhirecaseSet = new Set<Id>();
    Map<Id,String> candidateToEmployeeMap = new Map<Id,String>();
    Set<Id> candidateIds =new Set<Id>();
    for (Schema.RecordTypeInfo s : 
      Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().values()) {
      if (s.getName().contains(RECORD_TYPE_NEW_HIRE_PROCCESS)) {     
        caseRecordTypeIdSet.add(s.getRecordTypeId());
      }
    }

    for(Case c : newCases){
      if(caseRecordTypeIdSet.contains(c.recordTypeId)){
        candidateIds.add(c.NHW_Employee__c); 
        newhirecaseSet.add(c.Id);
      }
    }

    if(candidateIds.size()>0){
      for(Contact con : [select employeenumber__c from contact where id in : candidateIds]){
        candidateToEmployeeMap.put(con.Id,con.employeenumber__c); 
      }

      for(Case c : newCases){
        if((c.NHW_Employee__c!=null) && candidateToEmployeeMap.containsKey(c.NHW_Employee__c) && newhirecaseSet.contains(c.Id)){
            String EmpIdOnContact = candidateToEmployeeMap.get(c.NHW_Employee__c);
            Boolean empIdHasValue = !String.isBlank(EmpIdOnContact);
            Boolean empIdIsDifferent = (EmpIdOnContact != c.NH_Employee_Id__c) ? true : false;
            if(empIdHasValue && empIdIsDifferent){
              c.NH_Employee_Id__c=EmpIdOnContact; 
            } 
        }
      }
    }
  }

  public static void populateEntitlements(List<Case> cases) {
    for (Case c : cases) {
      if (NHSettings.Preboarding_Entitlement_Record_Id__c != null && c.recordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_APINAME_NEW_HIRE_PROCESS).getRecordTypeId()) {
        c.EntitlementId = NHSettings.Preboarding_Entitlement_Record_Id__c;
      } else if (NHSettings.Provisioning_Entitlement_Record_Id__c != null && c.recordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_APINAME_NEW_HIRE_PROCESS_ONBOARDING).getRecordTypeId()) {
        c.EntitlementId = NHSettings.Provisioning_Entitlement_Record_Id__c;
      }
    }
  }

  /*
Okta generates Email and creates a worker in EDH Worker (Worker Id is primary key)- When this flows to PF as part of PWTI EI transaction(s),we close the preboarding case to indicate to the hiring manager to start the NHW.
Both Email and WorkerId are required to close the case as downstream provisioning systems would require both.
*/
  public static void closeCasesWithEmailAndWorkerId(Map<Id,Case> oldMap, List<Case> cases) {
    for (Case c : cases) {
        if(c.recordTypeId == nhwPreBoardCaseRecordTypeId && !c.Status.contains('Closed') && c.NH_Employee_Id__c != NULL && isValidADEmailDomain(c.Email_Address__c)  && !c.Status.contains('On Hold')){
			// added On Hold to the code as part of W-15308729 // code added for SD changes > 30 requirements
            c.Status = 'Closed';
        }
    }
}

  public static void defaultCaseStatus(List<Case> cases) {
      for (Case c : cases) {
          if ((c.NHW_Employee__r.SF_Work_Email__c == NULL || c.NH_Employee_Id__c == NULL) && c.recordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Hire Process').getRecordTypeId() && !c.Status.contains('Closed')) {
              c.Status = 'Accounts in Progress - Peopleforce';
            }
      }
  }
  public static void setNhSlaDueDate(List<Case> cases) {
    for (Case c : cases) {
      String shippingCountry = c.Shipping_Country__c == null ? c.Office_Country__c : c.Shipping_Country__c;
      Date slaDate = NHW_MilestoneTimeCalculator.getNHShippingSLADate(shippingCountry, c.NHW_Start_Date__c, c.RecordTypeId);
      c.NH_SLA_Due_Date__c = slaDate < System.today() ? System.today() : slaDate;
    }
  }

  public static void populateProfile(List<Case> cases){
        
        List<Case> nhwCases = new List<Case>();
        
        //Commenting this logic - as NH profile needs to be populated for both onboarding and preboarding as below emails need the same
        //Last chance to set you new hire up && We had to set your new hire without you.
        
        for(Case c:cases){
            if(c.recordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_APINAME_NEW_HIRE_PROCESS).getRecordTypeId()
               || c.recordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_APINAME_NEW_HIRE_PROCESS_ONBOARDING).getRecordTypeId()
             ){
                   nhwCases.add(c);
               }
        }
        
       if(!nhwCases.isEmpty()){
            
            Map<String,String> ccToProfileMap = new Map<String,String>();
            Map<String,Set<String>> buToProfileMap = new Map<String,Set<String>>();
            
            for(NHW_DP_Cost_Centers__c ccRec:NHW_DP_Cost_Centers__c.getall().values()){
                if(ccRec.Cost_Centers_id__c != null){
                    ccToProfileMap.put(ccRec.Cost_Centers_id__c, ccRec.Profile_Name__c);
                }
                else if(ccRec.Business_Unit_Id__c != null){
                    if(!buToProfileMap.containsKey(ccRec.Business_Unit_Id__c)){
                        buToProfileMap.put(ccRec.Business_Unit_Id__c, new Set<String>());
                    }
                    buToProfileMap.get(ccRec.Business_Unit_Id__c).add(ccRec.Profile_Name__c);
                }
            }
            
            for(Case c:nhwCases){
               String costCenter ;
               String businessUnit; 

                if(c.Cost_Center_NHW__c!= null && c.Business_Unit_NHW__c!= null){ //FTE flow
                  costCenter= c.Cost_Center_NHW__c.split('-')[0];
                  businessUnit = c.Business_Unit_NHW__c.split('-')[0];
                }
                //This still says as commented as only FTE flow has Last chance to set you new hire and We had to set your new hire without you.
                /* Commenting this as - 
                    -And it has the BU/CC text fields populated in both McLaren and Jobscience flows
                    -Getting Name for BU/CC id is runaway SOQL and needs to be fixed.
                    -When we deprecate the Cost_Center_NHW__c,Business_Unit_NHW__c text fields we need to refactor the below.
                    -Otherwise we will run into get SOQL limit.            
                else  if(c.NHW_Business_Unit__c!= null && c.NHW_Cost_Center__c!= null ){//Contractor & reloc flow
                   String businessUnitName= NHW_Util.getBusinessUnitIdToName(c.NHW_Business_Unit__c);
                   String costCenterName = NHW_Util.getCostCenterIdToName(c.NHW_Cost_Center__c);
                   if(costCenterName != null){
                    costCenter= costCenterName.split('-')[0];
                   }
                   if(businessUnitName != null){
                    businessUnit= businessUnitName.split('-')[0];
                   }
                }*/
                
                if(ccToProfileMap.containsKey(costCenter) && buToProfileMap.containsKey(businessUnit)
                   && buToProfileMap.get(businessUnit).contains(ccToProfileMap.get(costCenter))){
                       c.NH_Profile__c = ccToProfileMap.get(costCenter);
                   }else{
                       c.NH_Profile__c = 'Other';
                   }
           }
        }
    }

    public static void updateSSTUserClone(List<Case> newCases){
      Set<id> caseIds = new Set<Id>();
      for(case onBoardCase : newCases){
        List<NHW_AccessCode> accessCodeList = new List<NHW_AccessCode>();
        caseIds.add(onBoardCase.Id);
        if((onBoardingSetting!=null && onBoardingSetting.Onboarding_Record_Type_Id__c!=null && onBoardCase.RecordTypeId == Id.valueOf(onBoardingSetting.Onboarding_Record_Type_Id__c))&&(onBoardCase.status == CASE_STATUS_SENT_TO_SUPPORTFORCE )){
            for(NHW_AccessCode accessC : (List<NHW_AccessCode>) JSON.deserialize(onBoardCase.NHW_Access_Code__c,List<NHW_AccessCode>.class)){
              for(NHW_AccessDetails accessD: accessC.accessDetailList){
                try{
                    if(accessD.name == System.Label.NHW_Org62_SST) {
                      List<String> sfSStList = new List<String>();
                      List<String> nameParsed = new List<String>();
                      String userName = '';
                      if(accessD.org62SST != NULL){
                          sfSStList = accessD.org62SST.split(';');
                          nameParsed = sfSStList[1].split(':');
                          userName = nameParsed[1];
                          accessD.userToClone = userName;
                      }
                  } else if(accessD.name == System.Label.NHW_GUS_SST && onBoardCase.NH_GUS_SST_User__c!=null) {
                    accessD.userToClone = NHW_Util.getSSTUserName(onBoardCase.NH_GUS_SST_User__c);
                  } else if(accessD.name == System.Label.NHW_Supportforce_SST && onBoardCase.NH_Supportforce_SST_User__c!=null){
                    accessD.userToClone = NHW_Util.getSSTUserName(onBoardCase.NH_Supportforce_SST_User__c);
                  }
                } catch (Exception ex){
                    //PF_Logger.log('NHW','ERROR',ex.getMessage(),ex.getTypeName(), ex.getLineNumber()+' Error in the updateSSTUserClone method for caseIds ' + caseIds, 'NHWCaseTriggerHandler');
                    EventBus.publish(
                        new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'ERROR',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = ex.getTypeName(),
                                Stack_Trace__c = 'NHWCaseTriggerHandler',
                                Message__c = ex.getMessage(),
                                Error__c = ex.getLineNumber()+' Error in the updateSSTUserClone method for caseIds ' + caseIds
                                )
                        );  
                }
                finally{
                  NHW_Util.insertNHWLogs();  
                }
              }
              accessCodeList.add(accessC);
            }
          onBoardCase.NHW_Access_Code__c = Json.serialize(accessCodeList);
        }
      }
    }


  public static void afterInsert(list<Case> newList) {
    NH_Settings__c settings = NH_Settings__c.getInstance();
    if (!settings.Disable_Jitterbit_Service__c){
    NHWCaseTriggerHandler.sendCaseToSalesforceOrg(newList, null, 
        'Salesforce.com IT');
    }
  }

  public static void afterUpdate(list<Case> newList, list<Case> oldList) {
    NH_Settings__c settings = NH_Settings__c.getInstance();
    if (!settings.Disable_Jitterbit_Service__c){
    NHWCaseTriggerHandler.sendCaseToSalesforceOrg(newList, oldList, 
        'Salesforce.com IT');
      }
    NHWCaseTriggerHandler.IdentifyChangedContactInfo(newList,oldList); 
  
  }


    public static void IdentifyChangedContactInfo(list<Case> newList, list<Case> oldList)
  {
    //Traces any changes to contact's start date (or) hiring manager info (or) business unit it has to be updated to Org62        

    String org62ContactId = '';
    String org62CaseContactId;
    String newHireName = '';
    map<Id, Case> oldMap = new map<Id, Case>();   
    map<Id, Case> newPlacementProvMap = new map<Id, Case>();

    if (oldList != null) {
      oldMap = new map<Id, Case>(oldList);
    }

    if (newList != null) 
    {
      for (Case c: newList)
      {
        if(c.recordTypeId  ==  NHW_Util.getnhwCaseRecordTypeId())
        {
          newPlacementProvMap.put(c.NHW_Job_Application__c, c);
        }
      }         


    }      

    for (Case c : newList) { 

      if((oldMap.containsKey(c.Id) && 
        (((c.NHW_Start_Date__c != null) && (c.NHW_Start_Date__c != oldMap.get(c.Id).NHW_Start_Date__c)) || ((c.Manager_s_Email__c != null) && c.Manager_s_Email__c != oldMap.get(c.Id).Manager_s_Email__c)) || 
        ((c.Business_Unit_NHW__c != null) && (c.Business_Unit_NHW__c != oldMap.get(c.Id).Business_Unit_NHW__c)) ||
        c.Office_Address__c != oldMap.get(c.Id).Office_Address__c ||
        c.Office_City__c != oldMap.get(c.Id).Office_City__c ||
        c.Office_State_Province__c != oldMap.get(c.Id).Office_State_Province__c ||
        c.Office_Zip_Postal_Code__c != oldMap.get(c.Id).Office_Zip_Postal_Code__c ||
        c.Office_Country__c != oldMap.get(c.Id).Office_Country__c) && (c.recordTypeId  ==  NHW_Util.getnhwPreBoardCaseRecordTypeId() && (newPlacementProvMap.get(c.NHW_Job_Application__c)!=null)))
        {
          org62CaseContactId =  c.Email_address__c + ';' +                        
          c.NHW_Start_Date__c  + ';' +
          (c.Manager_s_Email__c != null ? c.Manager_s_Email__c : '')  + ';' + 
          (c.Business_Unit_NHW__c != null ? c.Business_Unit_NHW__c : '') + ';' + 
          c.NH_Is_Exact_Target__c+ ';' + 
          (c.Office_Address__c != null ? c.Office_Address__c : '') + ';' + 
          (c.Office_City__c != null ? c.Office_City__c : '') + ';' + 
          (c.Office_State_Province__c != null ? c.Office_State_Province__c : '') + ';' + 
          (c.Office_Zip_Postal_Code__c != null ? c.Office_Zip_Postal_Code__c : '') + ';' + 
          (c.Office_Country__c != null ? NHW_Util.getCountryISOCode(c.Office_Country__c) : '');
          newHireName = c.First_Name__c + ' ' + c.Last_Name__c;
          if(String.isNotEmpty(org62ContactId))
          {
            org62ContactId = org62ContactId + '~' + org62CaseContactId;
          }
          else
          {
            org62ContactId = org62CaseContactId ;
          }            
      }
    }   

    if((org62ContactId !=null) && (String.isNotEmpty(org62ContactId)))
    { 

      SendContactInfo(org62ContactId,newHireName);
    }
  }

  public static void populateHMDelegateEmails(list<Case> newList, Map<Id,Case> oldMap)
   {
       Set<id> managerIds = new Set<id>();
       Map<Id, string> delegateMap = new Map<Id, String>();
            
        for(Case c: newList){
            if(oldMap != null && (c.Manager_Name__c <> null && (c.Manager_Name__c <> oldMap.get(c.id).Manager_Name__c))){               
                managerIds.add(c.Manager_Name__c);                   
            }else{           
               if(oldMap == null && c.Manager_Name__c <> null){              
                   managerIds.add(c.Manager_Name__c);                    
               }           
            }         
        }
               
        if(!managerIds.isEmpty()){  
            for(Delegate__c del: [SELECT Id, Manager__c , Delegate__c,Delegate__r.Email FROM delegate__c WHERE Manager__c IN: managerIds]){
               if(del.Delegate__c <> null){
                  if(delegateMap.containsKey(del.Manager__c)){
                        string emailids = delegateMap.get(del.Manager__c);
                        if(!emailids.contains(del.delegate__r.Email)){
                            emailids = emailids+';'+del.delegate__r.Email;
                            delegateMap.put(del.Manager__c, emailids);
                        }
                   }else{
                        delegateMap.put(del.Manager__c, del.delegate__r.Email);
                   } 
               }
            }
            
            for(Case c: newList){
               if((c.recordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('New_Hire_Process_Onboarding').getRecordTypeId()
               || c.recordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('New_Hire_Process').getRecordTypeId()) 
               && c.NHW_Start_Date__c>Date.Today()){        
                    c.NH_Manager_Delegate_Email_Addresses__c  = delegateMap.containsKey(c.Manager_Name__c)?delegateMap.get(c.Manager_Name__c):'';
                }
            }
        }
   }

  public static void SendContactInfo(string ContactId,string NH_Name)
  {

    try
    {
      NHW_Org62Service.org62CallOut(
          'UpdateContactInfo',null,ContactId,NH_Name);
    }

    catch(Exception ex)
    {
      System.debug('Trigger error while passing Contact Info to Web Service');
      System.debug('Corresponding error message is ' + ex.getMessage() );
      //PF_Logger.log('NHW','ERROR',ex.getMessage(),ex.getTypeName(), ex.getLineNumber()+' Error in the SendContactInfo method for contactId  = ' + ContactId, 'NHWCaseTriggerHandler',NH_Name);
      EventBus.publish(
                        new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'ERROR',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = ex.getTypeName(),
                                Stack_Trace__c = 'NHWCaseTriggerHandler',
                                Message__c = ex.getMessage(),
                                Error__c = ex.getLineNumber()+' Error in the SendContactInfo method for contactId  = ' + ContactId
                                )
                        );   
    }
    finally{
        NHW_Util.insertNHWLogs();  
    }

  }
 
  private static void sendCaseToSalesforceOrg(
    list<Case> newList, list<Case> oldList, String connectionName) {
    NH_Settings__c settings = NH_Settings__c.getInstance();
    if(settings.Disable_Jitterbit_Enable_S2S__c){
          set<Id> caseRecordTypeIdSet = new set<Id>();
      map<Id, Case> oldMap = new map<Id, Case>();
      List<Id> caseIds = new List<Id>();
      PartnerNetworkConnection connection;
      PartnerNetworkRecordConnection newrecord;
      list<PartnerNetworkRecordConnection> casesToSendList = 
          new list<PartnerNetworkRecordConnection>();

      if (oldList != null) {
        oldMap = new map<Id, Case>(oldList);
      }
      
      for (Schema.RecordTypeInfo s : 
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().values()) {
        if (s.getName().contains(RECORD_TYPE_NEW_HIRE_PROCCESS)) {     
          caseRecordTypeIdSet.add(s.getRecordTypeId());
        }
      }

      try {
        connection = [Select Id 
                      From PartnerNetworkConnection
                      Where ConnectionStatus = 'Accepted'
                      And ConnectionName = :connectionName];
      }
      catch (QueryException qe) {
        return;
      }

      for (Case c : newList) {
        caseIds.add(c.Id); 
        if ((caseRecordTypeIdSet.contains(c.RecordTypeId)) && (c.Status == CASE_STATUS_SENT_TO_SUPPORTFORCE && 
              (!oldMap.containsKey(c.Id) || 
                  c.Status != oldMap.get(c.Id).Status))) {
            newRecord = new PartnerNetworkRecordConnection();
            newRecord.ConnectionId = connection.Id;
            newRecord.LocalRecordId = c.Id;  
            newRecord.SendClosedTasks = false;
            newRecord.SendOpenTasks = false;
            newRecord.SendEmails = false; 
            casesToSendList.add(newRecord);
        }                                     
      }

      if (casesToSendList != null && !casesToSendList.isEmpty()) {
        try {
          insert casesToSendList;
        }
        catch (DmlException ex) { 
          system.debug('The following exception has occurred: ' + 
              ex.getDmlStatusCode(0) + ex.getMessage());
          //PF_Logger.log('NHW','ERROR',ex.getMessage(),ex.getTypeName(), ex.getLineNumber()+' Error in the sendCaseToSalesforceOrg method for caseIds' + caseIds, 'NHWCaseTriggerHandler');
            EventBus.publish(
                        new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'ERROR',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = ex.getTypeName(),
                                Stack_Trace__c = 'NHWCaseTriggerHandler',
                                Message__c = ex.getMessage(),
                                Error__c = ex.getLineNumber()+' Error in the sendCaseToSalesforceOrg method for caseIds' + caseIds
                                )
                        ); 
        }
        finally{
          NHW_Util.insertNHWLogs();  
        }
      }
    }else{ // Jitterbit functionality
      set<Id> caseRecordTypeIdSet = new set<Id>();
      map<Id, Case> oldMap = new map<Id, Case>();
      if (oldList != null) {
        oldMap = new map<Id, Case>(oldList);
      }

      for (Schema.RecordTypeInfo s : 
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().values()) {
        if (s.getName().contains(RECORD_TYPE_NEW_HIRE_PROCCESS_ONBOARDING)) {     
          caseRecordTypeIdSet.add(s.getRecordTypeId());
        }
      }
      List<Id> caseIdsToSend = new List<Id>();

  // ES-Next Changes : Added status check "Accounts in Progress - Supportforce"
      for (Case c : newList) {
        if (caseRecordTypeIdSet.contains(c.RecordTypeId)) {    
          Boolean isNeedToSendCase = true;    
          if ((c.Status == CASE_STATUS_SENT_TO_SUPPORTFORCE || c.Status == CASE_STATUS_ACC_IN_PROGRESS) ||
              ( oldMap.containsKey(c.Id) && 
                c.Status != oldMap.get(c.Id).Status && 
                (oldMap.get(c.Id).Status == CASE_STATUS_CLOSED || oldMap.get(c.Id).Status == CASE_STATUS_SENT_TO_SUPPORTFORCE || oldMap.get(c.Id).Status == CASE_STATUS_ACC_IN_PROGRESS) && 
                c.Status == CASE_STATUS_CLOSED_CANCELLED
              )
            ) {
              if (!oldMap.isEmpty() && oldMap.containsKey(c.Id)) {
                isNeedToSendCase = checkIsNeedToSendCase(c, oldMap.get(c.Id));
              }
              if (isNeedToSendCase) {
                caseIdsToSend.add(c.Id);
              }
          }
        }                                     
      }
      if(!caseIdsToSend.isEmpty() && 
          !UserInfo.getUserName().startsWith('nhw_jitterbit_user@peopleforce.com')) //NOTE: TO AVOID CIRCULAR TRANSFER, WE DON'T WANT TO TRANFER THE UPDATE TO SUPPORTFORCE, IF THAT UPDATE IS COMMING FROM SUPPORTFORCE
        callJitterbitAPItoTransfer(caseIdsToSend);
    }
    
  }

  /** 
   * W-11058994
   * Given we have 2 min timeout for Jitterbit, and Milestones update status async within that window, 
   * to avoid two jitterbit calls per transaction within 2 mins, we exclude cases with only Milestone Status 
   * and system field changes.
   */
  public static Boolean checkIsNeedToSendCase(Case newCase, Case oldCase) {
    List<String> changedFields = new List<String>();

    for (String key : newCase.getPopulatedFieldsAsMap().keySet()) {
      if (SYSTEM_FIELDS.contains(key)) continue;
      if (newCase.get(key) != oldCase.get(key)) {
        changedFields.add(key);
      }
    }

    if (changedFields.isEmpty()) {
      return false;
    } else {
      return true;
    }
  }
  
  public static void callJitterbitAPItoTransfer(List<Id> caseIds){
    ID jobID = System.enqueueJob(new JitterbitCalloutQueuebleJob(caseIds));

  }

  public static String jitterbitApiCallUtil(List<Id> caseIds){
    String errorMessageToReturn = '';
    List<Case> caseToSend = null;
    try{
      caseToSend = [ SELECT Id, ESDJC_djc_case__c, NH_Business_Site_Lookup__c, Subject, ES_DJC_Business_Justification__c, 
                                Origin, NH_Profile__c ,
                                ESDJC_Case_Owner_Email__c, Type, ESDJC_Contact_Email__c, Description, Division__c,
                                Internal_Support_Category__c, Business_Title__c, Business_Unit_NHW__c, 
                                Computer_Type__c, Contractor_Hire_Reason__c, Cost_Center_NHW__c, 
                                Email_Address__c, NH_Employee_Id__c, 
                                NHW_Employee_Type__c, End_Date__c, Existing_Equipment__c, First_Name__c, 
                                Floor_Location_Cube_Location__c, HR_Approved__c, NH_Is_Exact_Target__c, 
                                Job_Status__c, Laptop_Type__c, Last_Name__c, Location_Type__c, 
                                Manager_Name__c, Manager_Name__r.Name, Manager_s_Email__c, Mobile_Phone_Required__c, 
                    		      	Offer_Type__c, Office_Address__c, 
                                Office_City__c, Office_Country__c, Office_State_Province__c, Office_Zip_Postal_Code__c, 
                                Onboarding_Buddy_Email__c, Onboarding_Buddy_Name__c, NH_Personal_Email__c, 
                                Primary_Coverage_Country__c, Resource_Type__c, NHW_Role__c, Company__c, Company__r.Name, Same_as_Office_Location__c, 
                                NH_Setup_Similar_To__c,NH_Shipping_Local_Contact_Info__c, Shipping_Address__c, Shipping_City__c, Shipping_Country__c, Shipping_State__c, 
                                Shipping_Zip_Postal__c, NHW_Start_Date__c, NH_Training_Email_Merge__c,
                                NHW_Access_Code__c, Priority, ESDJC_Private_Case_Comment__c, Status, ES_DJC_Sub_Topic__c, 
                                ES_DJC_Topic__c, Nhw_Submitter__c FROM Case where Id in : caseIds];
      String caseJSON = JSON.serialize(caseToSend);
      System.debug(caseJSON);
      Http h = new Http();
      HttpRequest req = new HttpRequest();
      String serviceUrl = NH_Settings__c.getInstance().Jitterbit_PF_To_SF_Service_URL__c;
      if(serviceUrl == null){
          throw new NHWCaseTransferException('NH Setting\'s Jitterbit_PF_To_SF_Service_URL__c is required.');
      }
      String basicAuthText = NH_Settings__c.getInstance().JitterbitAuthText__c;
      if(basicAuthText == null){
         throw new NHWCaseTransferException('NH Setting\'s JitterbitAuthText__c is required.');
      }
      req.setEndpoint(serviceUrl);
      req.setHeader('Content-Type', 'application/json');
      req.setHeader('authorization', 'Basic ' + basicAuthText);
      req.setMethod('POST');
      req.setBody(caseJSON);
      req.setTimeout(60000);
      HttpResponse res = h.send(req);
      String response = res.getBody();
      if(res.getStatusCode() != 200){
        throw new NHWCaseTransferException('Jitterbit API Service returned status code : ' + res.getStatusCode() +' '+res.getStatus());
      }
      if(response == '' || response== null){
        throw new NHWCaseTransferException('Jitterbit Service returned null.');
      }else{
        List<String> recordsInserted = response.split('\n');
        List<Case> casesToUpdate = new List<Case>();
        List<JitterbitResponse> failedTransactions = new List<JitterbitResponse>();

        for(String sfRecords : recordsInserted){
          List<String> recordResponsesTokens = sfRecords.split(',');
          if(recordResponsesTokens.size() >= 5 ){
            JitterbitResponse jitterbitResp = new JitterbitResponse(recordResponsesTokens);
            if(jitterbitResp.success){
              casesToUpdate.add(jitterbitResp.getCase());
            }else{
              failedTransactions.add(jitterbitResp);
              errorMessageToReturn+='Case ' +jitterbitResp.peopelforceCaseNumber +' failed with Message : '+ jitterbitResp.message + '<br/>';
            }
          }
        }
        if(!casesToUpdate.isEmpty()){
           update casesToUpdate;
        }
        if(!failedTransactions.isEmpty()){
            NHWCaseTriggerHandler.sendEmailOnTransferFailure(failedTransactions, null, caseToSend);
        }
      }
    }catch(Exception ex){
      NHWCaseTriggerHandler.sendEmailOnTransferFailure(null, ex.getMessage(), caseToSend);
      errorMessageToReturn+= 'Jitterbit API call failed with exception message : ' +  ex.getMessage();
    }
    return errorMessageToReturn;
  }

  private static void sendEmailOnTransferFailure(List<JitterbitResponse> failedTransactions, String errorText, List<Case> transactionCases){
      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      NH_Settings__c settings = NH_Settings__c.getInstance();
      message.toAddresses = new String[] { settings.Support_Email__c};
      if(settings.BCC_Email_Addresses__c != null){
         message.setCcAddresses( settings.BCC_Email_Addresses__c.split(';') );
      }
      
      message.subject = 'New Hire Provisioning Case Transfer to Supportforce Failed.';
      if(failedTransactions == null && errorText != null){
         message.htmlBody = 'Error Message: <b><i>' + errorText +'</i></b><br/>';
      }else if(failedTransactions != null){
          String messageText = '<br/>Following peopleforce cases transfer Failed :';
          for(JitterbitResponse jitterbitResp : failedTransactions){
              messageText += '<br/> Case Number : <b>'+ jitterbitResp.peopelforceCaseNumber + ' </b> with Error Message : <b><i>' + jitterbitResp.message +'</b></i>';
          }
          message.htmlBody = messageText;
      }
      message.htmlBody += '<br/><br/>Following Cases are transfered in this transaction : <br/>';
     for(Case cse : transactionCases){
        message.htmlBody += URL.getSalesforceBaseUrl().toExternalForm() +'/'+cse.Id +'<br/>';
     }
     message.htmlBody += '<br/><br/><b>Please look at exception/error message and resolve the issue, then go to individual cases in the transction, send case to supportforce by clicking "Send to Supportforce" button.</b><br/>';
    Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
    if(!Test.isRunningTest()){
      Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }
  }


  /*create admin records which is a child object for delegate__c*/
  public static void createAdminProvisioningRecords(List<Case> cases,Map<Id,Case> caseOldMap){

    List<NHW_Admin_Provisioning__c> adminProvisioning = new List<NHW_Admin_Provisioning__c>();
    Map<String,Delegate__c> delegateMap = new Map<String,Delegate__c>();
    Id onBoardingRecId = NHW_Util.getNHWRecordTypeId('New_Hire_Process_Onboarding');
    boolean isAdmin;
    List<Case> validCases = new List<Case>();
    List<Id> caseIds = new List<Id>();
    Set<Id> emailSet = new Set<Id>();
    Map<String,Id> adminEmailMap = new Map<String,Id>();
    for(Case c : cases){
      if(c.recordTypeId!=null && c.recordTypeId == onBoardingRecId && c.status==CASE_STATUS_SENT_TO_SUPPORTFORCE && c.status!=caseOldMap.get(c.Id).status){
        validCases.add(c);
        caseIds.add(c.Id);
      }
    }
    // process only for onboarding cases.. 
    if(validCases.size()>0){
      //W-3433695 - NH Admins are defined by role not queue.
      //List<Contact> adminContacts = NHW_Util.getAdminContactsByQueue('NHW_Autoprovisioning_Admin');
      List<Contact> adminContacts = NHW_Util.getAdminContactsByRole('IT NH Admin'); 
      for(Contact c : adminContacts){
        adminEmailMap.put(c.Email,c.Id);
      }
      for(Delegate__c del : [select Id,Manager__c,Delegate__c,NHW_Is_NWH_Admin__c,key__c from Delegate__c where Delegate__r.email = :UserInfo.getUserEmail()]){
        if(del.Delegate__c!=null && del.Manager__c!=null){
          delegateMap.put(del.key__c,del);
        }

      }
      Map<Id,boolean> adminReceivedCases = NHW_Util.CheckCasesAdminProvisioned(validCases);
      for(Case c : validCases){
        emailSet.add(c.Id);
        if(c.Manager_Name__c!=null && UserInfo.getUserEmail() != c.Manager_s_Email__c && adminEmailMap.containsKey(UserInfo.getUserEmail())){   // is logged in user an admin delegate
          isAdmin = true;
          //if logged in user is both delegate for the hiring manager and also an admin
          if((delegateMap.containsKey(String.valueOf(adminEmailMap.get(userInfo.getUserEmail()))+String.valueOf(c.Manager_Name__c)+'false')) && (adminReceivedCases!=null && adminReceivedCases.get(c.Id)!=null && !adminReceivedCases.get(c.Id))){
              isAdmin = false;
          }

          if(isAdmin){
            try{
              NHW_Admin_Provisioning__c  nhwAdminPro= new NHW_Admin_Provisioning__c(); 
              nhwAdminPro.Case__c = c.Id;
              nhwAdminPro.Delegate__c = delegateMap.get(String.valueOf(adminEmailMap.get(userInfo.getUserEmail()))+String.valueOf(c.Manager_Name__c)+'true').Id;
              adminProvisioning.add(nhwAdminPro);
            }
            catch(exception ex){
              //PF_Logger.log('NHW','ERROR',ex.getMessage(),ex.getTypeName(), ex.getLineNumber()+' Error in the createAdminProvisioningRecords method for caseIds = ' + caseIds, 'NHWCaseTriggerHandler');
              EventBus.publish(
                        new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'ERROR',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = ex.getTypeName(),
                                Stack_Trace__c = 'NHWCaseTriggerHandler',
                                Message__c = ex.getMessage(),
                                Error__c = ex.getLineNumber()+' Error in the createAdminProvisioningRecords method for caseIds = ' + caseIds
                                )
                        );
            }
            finally{
              NHW_Util.insertNHWLogs();  
            }
          } 
        }

      }
      try{
        if(adminProvisioning!=null && adminProvisioning.size()>0){
          insert adminProvisioning;
        }  
      }
      catch (DmlException ex) { 
       //PF_Logger.log('NHW','ERROR',ex.getMessage(),ex.getTypeName(), ex.getLineNumber()+' Error in the createAdminProvisioningRecords method for caseIds = ' + caseIds, 'NHWCaseTriggerHandler');
       EventBus.publish(
                        new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'ERROR',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = ex.getTypeName(),
                                Stack_Trace__c = 'NHWCaseTriggerHandler',
                                Message__c = ex.getMessage(),
                                Error__c = ex.getLineNumber()+' Error in the createAdminProvisioningRecords method for caseIds = ' + caseIds
                                )
                        );  
      }
      finally{
        NHW_Util.insertNHWLogs();  
      }

      //send emails 
      if(!isFutureCalled){
        isFutureCalled=true;
      }
    }

  }


  @Future(callout=true)
  public static void sendEmails (Set<Id> caseIds,boolean isAdmin,Id adminContactId){

    List<Case> cases = [select id,CaseNumber,Resource_Type__c, Manager_Name__c,Manager_Name__r.Email,Manager_Name__r.Phone,Manager_Name__r.Name,Onboarding_Buddy_Email__c,NHW_Employee_Type__c,First_Name__c,Last_Name__c, NH_Division__c, Division__c from case where id in : caseIds ]; 
    List<Case> sendEmailToManagerCases = new List<Case>();
    List<Case> sendEmailToManagerAboutDefault = new List<Case>();
    List<Case> sendEmailToAdminAboutNHWCompletion = new List<Case>();
    List<Case> sendEmailtoBuddy = new List<Case>();
    
    for(Case c : cases){
      if(isAdmin!=null && isAdmin){
        sendEmailToManagerAboutDefault.add(c);
        sendEmailToAdminAboutNHWCompletion.add(c);
      }
      else{
        sendEmailToManagerCases.add(c);
      }
      if(c.Onboarding_Buddy_Email__c != null){
        sendEmailtoBuddy.add(c);
      }
    }
    try{
      if(sendEmailToManagerCases != null && sendEmailToManagerCases.size() > 0){
        sendManagerConfirmationEmail(sendEmailToManagerCases,false);
      }
    }
    catch(Exception ex){
        //PF_Logger.log('NHW','ERROR',ex.getMessage(),ex.getTypeName(), ex.getLineNumber()+' Error in the sendManagerConfirmationEmail method for caseIds' + caseIds, 'NHWCaseTriggerHandler');
        EventBus.publish(
                        new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'ERROR',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = ex.getTypeName(),
                                Stack_Trace__c = 'NHWCaseTriggerHandler',
                                Message__c = ex.getMessage(),
                                Error__c = ex.getLineNumber()+' Error in the sendManagerConfirmationEmail method for caseIds' + caseIds
                                )
                        );
    }      
    try{
      if(sendEmailToManagerAboutDefault != null && sendEmailToManagerAboutDefault.size() > 0){
        sendManagerConfirmationEmail(sendEmailToManagerAboutDefault,true);
      }  
    }
    catch(Exception ex){
      //PF_Logger.log('NHW','ERROR',ex.getMessage(),ex.getTypeName(), ex.getLineNumber()+' Error in the sendManagerConfirmationEmail for default method for caseIds ' + caseIds, 'NHWCaseTriggerHandler');
      EventBus.publish(
                        new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'ERROR',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = ex.getTypeName(),
                                Stack_Trace__c = 'NHWCaseTriggerHandler',
                                Message__c = ex.getMessage(),
                                Error__c = ex.getLineNumber()+' Error in the sendManagerConfirmationEmail for default method for caseIds ' + caseIds
                                )
                        );
    }
    try{
      if(sendEmailtoBuddy != null && sendEmailtoBuddy.size() > 0){
        sendonBoardingBuddyConfirmationEmail(sendEmailtoBuddy);
      }  
    }
    catch(Exception ex){
      //PF_Logger.log('NHW','ERROR',ex.getMessage(),ex.getTypeName(), ex.getLineNumber()+' Error in the sendonBoardingBuddyConfirmationEmail method for caseIds ' + caseIds, 'NHWCaseTriggerHandler'); 
      EventBus.publish(
                        new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'ERROR',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = ex.getTypeName(),
                                Stack_Trace__c = 'NHWCaseTriggerHandler',
                                Message__c = ex.getMessage(),
                                Error__c = ex.getLineNumber()+' Error in the sendonBoardingBuddyConfirmationEmail method for caseIds ' + caseIds
                                )
                        ); 
    }
    //We are deprecating sending email to admin.
    /*try{
      if(sendEmailToAdminAboutNHWCompletion != null && sendEmailToAdminAboutNHWCompletion.size() > 0){
        sendAdminConfirmationEmail(sendEmailToAdminAboutNHWCompletion,adminContactId);
      }  
    }
    catch(Exception ex){
      PF_Logger.log('NHW','ERROR',ex.getMessage(),ex.getTypeName(), ex.getLineNumber()+' Error in the sendAdminConfirmationEmail method for caseIds ' + caseIds, 'NHWCaseTriggerHandler');    
    }*/
    NHW_Util.insertNHWLogs();

  }


  public static void sendManagerConfirmationEmail(List<Case> cases, boolean isAdmin){
    List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
    List<Messaging.Email> allMails = new List<Messaging.Email>();
    Boolean isSandbox = URL.getSalesforceBaseUrl().getHost().contains('.cs');
    Id emailTemplateRecId;
    Id AMER_Template_ID;
    Id EMEA_Template_ID;
    Id APAC_Template_ID;
    Id JAPAN_Template_ID;
    List<Id> caseIds = new List<Id>();
    if(!isAdmin){
      AMER_Template_ID = NHW_Util.getEmailTemplateId('NHW_Your_New_Hire_Is_Good_to_Go_AMER');
      EMEA_Template_ID = NHW_Util.getEmailTemplateId('NHW_Your_New_Hire_Is_Good_to_Go_EMEA');
      APAC_Template_ID = NHW_Util.getEmailTemplateId('NHW_Your_New_Hire_Is_Good_to_Go_APAC');
      JAPAN_Template_ID = NHW_Util.getEmailTemplateId('NHW_Your_New_Hire_Is_Good_to_Go_Japan');
    }
    else {
      emailTemplateRecId = NHW_Util.getEmailTemplateId('NHW_HiringManager_Admin_Completion_html');
    }

    for(Case c:cases){
      caseIds.add(c.Id);
      if(c.Manager_Name__c != null && (emailTemplateRecId!=null || AMER_Template_ID != null || EMEA_Template_ID != null || APAC_Template_ID != null || JAPAN_Template_ID != null) && senderId!=null){
        Messaging.SingleEmailMessage mailRec = new Messaging.SingleEmailMessage();                                 
        mailRec.setTargetObjectId(c.Manager_Name__c);
        mailRec.setWhatId(c.id);
        mailRec.setOrgWideEmailAddressId(senderId);
        if(!isAdmin){

          //If flow is Contractor or Relocation, Division__c is used.  If flow is FTE, NH_Division__c is used instead.
          String division = (c.NHW_Employee_Type__c == 'Regular Employee') ? c.NH_Division__c : (c.NHW_Employee_Type__c == 'Contractor' || c.NHW_Employee_Type__c == 'Relocation') ? c.Division__c : '';

          if(division.containsIgnoreCase('AMER')){
            mailRec.setTemplateId(AMER_Template_ID);
          }else if(division.containsIgnoreCase('EMEA')){
            mailRec.setTemplateId(EMEA_Template_ID);
          }else if(division.containsIgnoreCase('APAC')){
            mailRec.setTemplateId(APAC_Template_ID);
          }else if(division.containsIgnoreCase('Japan')){
            mailRec.setTemplateId(JAPAN_Template_ID);
          }else {
            mailRec.setTemplateId(AMER_Template_ID);
          }
        }else{
          if(c.NH_Division__c == 'Japan'){
            continue;
        }else{
          mailRec.setTemplateId(emailTemplateRecId);
          }
        }
        mailRec.setSaveAsActivity(false);
        if(isSandbox)
            mailRec.setCCAddresses(new String[]{'itscrum-onboarding@salesforce.com'});
        else
            mailRec.setCCAddresses(new String[]{'noreply_nhw@salesforce.com'});
        emailList.add(mailRec);      
      }

    }
    if(emailList != null && emailList.size()>0){
      List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailList);
      if (!results.get(0).isSuccess()) {
        System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();
        String errorMessage = results.get(0).getErrors()[0].getMessage();
        //PF_Logger.log('NHW','ERROR',errorMessage,String.valueOf(results.get(0).getErrors()[0].getStatusCode()),'Error in the sendManagerConfirmationEmail method for caseIds = ' + caseIds, 'NHWCaseTriggerHandler');
        EventBus.publish(
                        new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'ERROR',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = String.valueOf(results.get(0).getErrors()[0].getStatusCode()),
                                Stack_Trace__c = 'NHWCaseTriggerHandler',
                                Message__c = errorMessage,
                                Error__c = 'Error in the sendManagerConfirmationEmail method for caseIds = ' + caseIds
                                )
                        );
      }
    }
    else{
      //PF_Logger.log('NHW',PF_DEBUG_LOG_TYPE_DATA_ERROR,null,null,'Received empty emailList in the sendManagerConfirmationEmail method for caseIds = ' + caseIds, 'NHWCaseTriggerHandler');
      EventBus.publish(
                        new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = PF_DEBUG_LOG_TYPE_DATA_ERROR,
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = PF_DEBUG_LOG_TYPE_DATA_ERROR,
                                Stack_Trace__c = 'NHWCaseTriggerHandler',
                                Message__c = 'Received empty emailList in the sendManagerConfirmationEmail method for caseIds = ' + caseIds,
                                Error__c = 'Received empty emailList in the sendManagerConfirmationEmail method for caseIds = ' + caseIds
                                )
                        );    
    }
    NHW_Util.insertNHWLogs(); 

  }



  public static void sendAdminConfirmationEmail(List<case> cases, Id adminContactEmailId){
    List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

    Id emailTemplateRecId;
    emailTemplateRecId = NHW_Util.getEmailTemplateId('NHW_HiringManager_Buddy_Completion_html');
    List<Id> caseIds = new List<Id>();
    for(Case c:cases){
      caseIds.add(c.Id);
      if(adminContactEmailId != null && emailTemplateRecId!=null && senderId!=null && c.Manager_Name__c != null){
        Messaging.SingleEmailMessage mailRec = new Messaging.SingleEmailMessage();                                 
        mailRec.setTargetObjectId(adminContactEmailId);
        mailRec.setWhatId(c.id);
        mailRec.setOrgWideEmailAddressId(senderId);   
        mailRec.setTemplateId(emailTemplateRecId);
        mailRec.setSaveAsActivity(false);
        emailList.add(mailRec);      
      }

    }
    if(emailList != null && emailList.size()>0){
      List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailList);
      if (!results.get(0).isSuccess()) {
        System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();
        String errorMessage = results.get(0).getErrors()[0].getMessage();
        //PF_Logger.log('NHW','ERROR',errorMessage,String.valueOf(results.get(0).getErrors()[0].getStatusCode()),'Error in the sendAdminConfirmationEmail method for casesIds = ' + caseIds, 'NHWCaseTriggerHandler');
        EventBus.publish(
                        new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'ERROR',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = String.valueOf(results.get(0).getErrors()[0].getStatusCode()),
                                Stack_Trace__c = 'NHWCaseTriggerHandler',
                                Message__c = errorMessage,
                                Error__c = 'Error in the sendAdminConfirmationEmail method for casesIds = ' + caseIds
                                )
                        );
      }
    }
    else{
      //PF_Logger.log('NHW',PF_DEBUG_LOG_TYPE_DATA_ERROR,null,null,'Received empty emailList in the sendAdminConfirmationEmail method for caseIds = ' + caseIds, 'NHWCaseTriggerHandler');
      EventBus.publish(
                        new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = PF_DEBUG_LOG_TYPE_DATA_ERROR,
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = PF_DEBUG_LOG_TYPE_DATA_ERROR,
                                Stack_Trace__c = 'NHWCaseTriggerHandler',
                                Message__c = 'Received empty emailList in the sendAdminConfirmationEmail method for caseIds = ' + caseIds,
                                Error__c = 'Received empty emailList in the sendAdminConfirmationEmail method for caseIds = ' + caseIds
                                )
                        );  
    }
    NHW_Util.insertNHWLogs(); 
  }



  public static void sendonBoardingBuddyConfirmationEmail(List<Case> cases){
    List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
    List<Messaging.Email> allMails = new List<Messaging.Email>();
    Id emailTemplateRecId;
    List<Id> caseIds = new List<Id>();
    Map<Id,String> buddyIdEmailMap = new Map<Id,String>();
    Map<String,Id> buddyEmailIdMap = new Map<String,Id>();
    emailTemplateRecId = NHW_Util.getEmailTemplateId('NHW_Onboarding_Buddy_Completion_html');
    for(Case c:cases){
      if(c.Onboarding_Buddy_Email__c != null || c.Onboarding_Buddy_Email__c != '' )
        buddyIdEmailMap.put(c.Id,c.Onboarding_Buddy_Email__c);
    }
    for(Contact c:[select Id,Email from Contact where Email in:buddyIdEmailMap.Values()]){
      if(c.Email != null || c.Email != '')
        buddyEmailIdMap.put(c.Email,c.Id);
    }

    for(Case c:cases){
      caseIds.add(c.Id);
      Id onboardingBuddyId = buddyEmailIdMap.get(c.Onboarding_Buddy_Email__c);
      if(onboardingBuddyId != null && senderId!=null && emailTemplateRecId!=null && c.Manager_Name__c != null){
        Messaging.SingleEmailMessage mailRec = new Messaging.SingleEmailMessage();                                 
        mailRec.setTargetObjectId(buddyEmailIdMap.get(c.Onboarding_Buddy_Email__c));
        mailRec.setWhatId(c.id);
        mailRec.setOrgWideEmailAddressId(senderId);   
        mailRec.setTemplateId(emailTemplateRecId);
        mailRec.setSaveAsActivity(false);
        emailList.add(mailRec);      
      }

    }
    if(emailList != null && emailList.size()>0){
      List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailList);
      if (!results.get(0).isSuccess()) {
        System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();
        String errorMessage = results.get(0).getErrors()[0].getMessage();
        System.Debug('Error Message ' + errorMessage);
        //PF_Logger.log('NHW','ERROR',errorMessage,String.valueOf(results.get(0).getErrors()[0].getStatusCode()),'Error in the sendonBoardingBuddyConfirmationEmail method for caseIds = ' + caseIds, 'NHWCaseTriggerHandler');
        EventBus.publish(
                        new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'ERROR',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = String.valueOf(results.get(0).getErrors()[0].getStatusCode()),
                                Stack_Trace__c = 'NHWCaseTriggerHandler',
                                Message__c = errorMessage,
                                Error__c = 'Error in the sendonBoardingBuddyConfirmationEmail method for caseIds = ' + caseIds
                                )
                        );
      }
    }
    else{
      //PF_Logger.log('NHW',PF_DEBUG_LOG_TYPE_DATA_ERROR,null,null,'Received empty emailList in the sendonBoardingBuddyConfirmationEmail method for caseIds = ' + caseIds, 'NHWCaseTriggerHandler');
      EventBus.publish(
                        new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = PF_DEBUG_LOG_TYPE_DATA_ERROR,
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = PF_DEBUG_LOG_TYPE_DATA_ERROR,
                                Stack_Trace__c = 'NHWCaseTriggerHandler',
                                Message__c = 'Received empty emailList in the sendonBoardingBuddyConfirmationEmail method for caseIds = ' + caseIds,
                                Error__c = 'Received empty emailList in the sendonBoardingBuddyConfirmationEmail method for caseIds = ' + caseIds
                                )
                        );  

    }
    NHW_Util.insertNHWLogs(); 
  }
  public class NHWCaseTransferException extends Exception{}
  public class JitterbitResponse{
    public JitterbitResponse(List<String> responseTokens){
        if(responseTokens[0] != '""'){
          peopelforceCaseId=responseTokens[0];
        }else{
          peopelforceCaseId=null;
        }
        if(responseTokens[1] != '""'){
          peopelforceCaseNumber=responseTokens[1];
        }else{
          peopelforceCaseNumber=null;
        }
        if(responseTokens[2] != '""'){
          supportforceCaseId=responseTokens[2];
        }else{
          supportforceCaseId = null;
        }
        if(responseTokens[3] != '""'){
          success=Boolean.valueOf(responseTokens[3]);
        }else{
          success= false;
        }
        if(responseTokens[4] != '""'){
          message=responseTokens[4];
        }else{
          message = null;
        }
    }
    public String peopelforceCaseId{get; set;}
    public String peopelforceCaseNumber{get; set;}
    public String supportforceCaseId{get; set;}
    public Boolean success{get; set;}
    public String message{get; set;}
    public Case getCase(){
      Case cse = new Case(Id=peopelforceCaseId, ESDJC_Supportforce_Case_Id__c=supportforceCaseId);
      return cse;
    }
  }

  public class JitterbitCalloutQueuebleJob implements Queueable, Database.AllowsCallouts{
    public List<Id> caseIds{get; set;}
    public JitterbitCalloutQueuebleJob(List<Id> caseIds){
      this.caseIds = caseIds;
    }
    public void execute(QueueableContext context) {
      NHWCaseTriggerHandler.afterCallsExecuted = true;
      NHWCaseTriggerHandler.jitterbitApiCallUtil(caseIds);
    }
  }
}