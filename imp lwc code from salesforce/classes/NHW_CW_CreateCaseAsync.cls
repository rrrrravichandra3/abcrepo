/**
 * Created by kmoseley on 3/1/21.
 */

public with sharing class NHW_CW_CreateCaseAsync implements Queueable{
    Set<Id> contractorIds = new Set<Id>();
    Map<Id, case> mContactsWithValidExistingCase = new Map<Id,case>();
    public NHW_CW_CreateCaseAsync(Set<Id> contractorIds){
        this.contractorIds = contractorIds;
    }
    public void execute(QueueableContext context) {
        try {
            Id caseRecordTypeId = NHW_Util.getnhwCaseRecordTypeId();

            List<Contact> contactRecsEligibleToCreateCase= new List<Contact>();
            List<Contact> contactRecsEligibleForCaseUpdate= new List<Contact>();
            map<Id,Case> mContactsWithCaseUpdate= new map<Id,Case>();

            List<Contact> contractorContacts = NHW_CW_Service.getContactsWithFieldsRequiredForCaseMapping(contractorIds);
            //Given this is Async thread - there could be mutiple updates from EI before the first Async create thread executed.
            //So we should check if these contacts are still eligible to CREATE new case
            //Else invoke update async.
            mContactsWithValidExistingCase = NHW_CW_DecisionService.contactWithValidRelatedCaseMap( contractorIds ,new map<Id,Contact>(contractorContacts));//Async context hence oldcontactmap is same as current contacts queried
            for(Contact contractorContact:contractorContacts){
                // if contact has existing case - route to  update flow  else route to create process.
                if(mContactsWithValidExistingCase.containsKey(contractorContact.Id)){
                    mContactsWithCaseUpdate.put(contractorContact.Id,mContactsWithValidExistingCase.get(contractorContact.Id));
                    contactRecsEligibleForCaseUpdate.add(contractorContact);
                //Check if the Contact meets eligble criteria for case create
                }else if(NHW_CW_DecisionService.standardCriteriaForCWCaseCreate(contractorContact)
                        )
                {
                    contactRecsEligibleToCreateCase.add(contractorContact);
                }
            }
            if(contactRecsEligibleToCreateCase.size()>0){
                NHW_CW_Service.createCasesFromContacts(null,contactRecsEligibleToCreateCase,context.getJobId());
            }
            if(contactRecsEligibleForCaseUpdate.size()>0){
                NHW_CW_Service.updateCasesRelatedToContacts(mContactsWithCaseUpdate,contactRecsEligibleForCaseUpdate,context.getJobId());
            }
        }catch(Exception err){
            String Description = 'Error message : ' + err.getMessage() + '\n'
                    + ' Stack Trace  : ' + err.getStackTraceString() + '\n'
                    + ' Line Number : ' + err.getLineNumber() + '\n'
                    + ' Error Type : ' + err.getTypeName();
            String ErrorMessage = 'Error message is : ' + err.getMessage() ;
            String ErrorType = 'Error while creating tickets in NHW_CW_CreateCaseAsync';
            //PF_Logger.log('NHW', 'ERROR', ErrorMessage, ErrorType, Description, 'NHW_Contractor_To_Case_Processes');
            EventBus.publish(
                    new PF_Logging_Channel__e(
                        ApplicationName__c = 'NHW',
                        LogLevel__c = 'Error',
                        ErrorType__c = ErrorType,
                        Stack_Trace__c = 'NHW_CW_CreateCaseAsync',
                        Message__c = ErrorMessage,
                        Error__c = Description
                        )
                );
        }
        NHW_Util.insertNHWLogs();
    }
    
}