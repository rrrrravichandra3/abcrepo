/**
 * Created by kmoseley on 3/1/21.
 */

public with sharing class NHW_CW_UpdateCaseAsync implements Queueable{
    Map<Id, case> mContactIdToCaseWithUpdates = new map<Id,case>();
    public NHW_CW_UpdateCaseAsync(Map<Id, case> mContactIdToCaseWithUpdates){
        this.mContactIdToCaseWithUpdates = mContactIdToCaseWithUpdates;

    }

    public void execute(QueueableContext context) {
        try {           
            if(mContactIdToCaseWithUpdates.size()>0){
                NHW_CW_Service.updateCasesRelatedToContacts(mContactIdToCaseWithUpdates,null,context.getJobId());
            }
        }catch(Exception err){
            String Description = 'Error message : ' + err.getMessage() + '\n'
                    + ' Stack Trace  : ' + err.getStackTraceString() + '\n'
                    + ' Line Number : ' + err.getLineNumber() + '\n'
                    + ' Error Type : ' + err.getTypeName();
            String ErrorMessage = 'Error message is : ' + err.getMessage() ;
            String ErrorType = 'Error while creating/updating tickets in NHW_CW_UpdateCaseAsync';
            //PF_Logger.log('NHW', 'ERROR', ErrorMessage, ErrorType, Description, 'NHW_Contractor_To_Case_Processes');
            EventBus.publish(
                            new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'Error',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = ErrorType,
                                Stack_Trace__c = 'NHW_CW_UpdateCaseAsync',
                                Message__c = ErrorMessage,
                                Error__c = Description
                                )
                        );
        }
        NHW_Util.insertNHWLogs();
    }
}