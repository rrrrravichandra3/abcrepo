public without sharing  class NHW_CW_Service {
    public static List<NH_DataMapping__mdt> dataMappings = NHW_Util.getSourceFieldsFromNHDataMappingMDT('Contact', 'Case', 'CW Contact to Case');

    public static void doCaseDML(List<Case> cases, String OPERATION,String ProcessName, String ContextInfo){
    try{
            List<Database.SaveResult> srList = new List<Database.SaveResult>();
            if(OPERATION == 'Insert'){
                srList = Database.insert(cases, false);
            }else if(OPERATION == 'Update'){
                srList = Database.update(cases, false);
            }
            Integer i = 0;
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        String Description = 'Error message : ' + err.getMessage() + '\n'
                                + ' Status code  : ' + err.getStatusCode() + '\n'
                                + ' Fields errored : ' + err.getFields() + '\n'
                                + ' Related Contractor id : ' + cases[i].NHW_Employee__c + '\n'
                                + ' Scheduled job id : ' + ContextInfo;
                        String ErrorMessage = 'Error message is : ' + err.getMessage() ;
                        String ErrorType = 'Error while cases ' + OPERATION + ' in '+  ProcessName ;//NHW_CW_CreateCaseAsync
                         //PF_Logger.log('NHW', 'ERROR', ErrorMessage, ErrorType, Description, 'NHW_Contractor_To_Case_Processes');//NHW_Contractor_To_Case_Processes
                            EventBus.publish(
                            new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'Error',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = ErrorType,
                                Stack_Trace__c = 'NHW_CW_Service',
                                Message__c = ErrorMessage,
                                Error__c = Description
                                )
                        );
                    }
                }
                i = i + 1;
            }
            
        }catch(Exception err){
            String Description = 'Error message : ' + err.getMessage() + '\n'
                    + ' Stack Trace  : ' + err.getStackTraceString() + '\n'
                    + ' Line Number : ' + err.getLineNumber() + '\n'
                    + ' Error Type : ' + err.getTypeName();
            String ErrorMessage = 'Error message is : ' + err.getMessage() ;
             String ErrorType = 'Error while cases ' + OPERATION + ' in '+  ProcessName ;//NHW_CW_CreateCaseAsync
              //PF_Logger.log('NHW', 'ERROR', ErrorMessage, ErrorType, Description, 'NHW_Contractor_To_Case_Processes');//NHW_Contractor_To_Case_Processes
                EventBus.publish(
                            new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'Error',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = ErrorType,
                                Stack_Trace__c = 'NHW_CW_Service',
                                Message__c = ErrorMessage,
                                Error__c = Description
                                )
                        );
        }
        NHW_Util.insertNHWLogs();
    
    }
    public static void createCasesFromContacts(set<Id> ContactIds,List<Contact> ContactRecs,string AnyInfoAboutInvokingContext){
        List<Contact> contractorContacts = new List<Contact>();
        List<Case> casesToCreate = new List<Case>();
        String ProvisioningCaseRecordTypeId = NHW_Util.getnhwCaseRecordTypeId();


        if(ContactRecs != null){
            contractorContacts = ContactRecs;
        }else{ 
            contractorContacts = getContactsWithFieldsRequiredForCaseMapping(ContactIds);
        }

        for (Contact contractor : contractorContacts) {
            Case provisioningCase = new Case();
                //Default values to be assigned on create. These will not change on case but are required to build the case correctly.
                provisioningCase.Subject = 'New Hire Provisioning Request for ' + contractor.FirstName + ' ' + contractor.LastName;
                provisioningCase.RecordTypeId = ProvisioningCaseRecordTypeId ;
                provisioningCase.NHW_Employee_Type__c = 'contractor';
                provisioningCase.NHW_Page_Number__c = 0;
                provisioningCase.Origin = 'NHW';
                provisioningCase.Type = 'NHW';
                provisioningCase.Status = 'New';
                provisioningCase.ContactId = contractor.ReportsToId;
                provisioningCase.Description = '';
                provisioningCase.NHW_Employee__c = contractor.Id;
                provisioningCase.Job_Status__c = '';

                NHW_Util.updateValuesusingNHDataMappingMDT(contractor, provisioningCase, dataMappings);

            casesToCreate.add(provisioningCase);
        }

        doCaseDML(casesToCreate,'Insert','NHW_CW_CreateCaseAsync',AnyInfoAboutInvokingContext);
       

    }

    public static void updateCasesRelatedToContacts(Map<Id, case> mContactIdToCaseWithUpdates, List<Contact> ContactRecs,String AnyInfoAboutInvokingContext){
       List<Contact> contractorContacts = new List<Contact>();
       List<Case> casesToUpdate = new List<Case>();

        if(ContactRecs != null){
            contractorContacts = ContactRecs; 
        }else{
            contractorContacts = getContactsWithFieldsRequiredForCaseMapping(mContactIdToCaseWithUpdates.keySet());
        }

        for(Contact contractorContact:contractorContacts){
            Case provisioningCase = mContactIdToCaseWithUpdates.get(contractorContact.Id);
            NHW_Util.updateValuesusingNHDataMappingMDT(contractorContact, provisioningCase, dataMappings);
            casesToUpdate.add(provisioningCase);
        }
        doCaseDML(casesToUpdate,'Update','NHW_CW_UpdateCaseAsync',AnyInfoAboutInvokingContext);

    }
    public static List<Contact> getContactsWithFieldsRequiredForCaseMapping(set<id> contactIds){

        List<Contact> contractorContacts  = PF_NHW_ContactStore.getCW_ContactsWithRelatedCases(contactIds);
        return contractorContacts;
    }
}