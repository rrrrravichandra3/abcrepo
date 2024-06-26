public class NHW_CreateContactsAsync implements Queueable{
    list<contact> candidateContacts = new list<contact>();
    public NHW_CreateContactsAsync(list<contact> candidateContacts){
        this.candidateContacts = candidateContacts;
    }
    public void execute(QueueableContext context) {
        
        Database.SaveResult[] srList = Database.insert(candidateContacts,false);
        Integer i = 0;
        for(Database.SaveResult sr:srList){

            if(!sr.isSuccess()){
              for(Database.Error err : sr.getErrors()){
                  String Description = 'Error message : '+ err.getMessage() 
                                     + ' Status code  : ' + err.getStatusCode()
                                     + ' Fields errored : ' + err.getFields()
                                     + ' Related Candidate id ' + candidateContacts[i].NHW_Candidate__c
                                     + ' Candidate Contact generated ' +  candidateContacts[i]
                                     + ' Scheduled job id  ' + context.getJobID();
                  String ErrorMessage = 'Error message is : '+ err.getMessage() ;
                  String ErrorType = 'Error while creating Candidate Contacts in NHW_CreateContactsAsync';
                  //PF_Logger.log('NHW','ERROR',ErrorMessage,ErrorType,Description,'NHW_CreateContactsAsync');
                  EventBus.publish(
                                new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'Error',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = ErrorType,
                                Stack_Trace__c = 'NHW_CreateContactsAsync',
                                Message__c = ErrorMessage,
                                Error__c = Description
                                )
                            );
              }
            } 
            i = i+1;
        }
        NHW_Util.insertNHWLogs();	     
    }
}