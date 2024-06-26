/**
 * Created by kmoseley on 3/3/21.
 */

public with sharing class NHW_CW_CloseCancelCasesAsync implements Queueable{
    List<Case> casesToCloseCancel = new List<Case>();
    public NHW_CW_CloseCancelCasesAsync(List<Case> casesToCloseCancel){
        this.casesToCloseCancel = casesToCloseCancel;
    }
    public void execute(QueueableContext context) {
        try {
            for(Case c: casesToCloseCancel ){
                c.Status = 'Closed - Cancelled';
            }

            Database.SaveResult[] srList = Database.update(casesToCloseCancel, false);
            Integer i = 0;
            for (Database.SaveResult sr : srList) {

                    if (!sr.isSuccess()) {
                        for (Database.Error err : sr.getErrors()) {
                            String Description = 'Error message : ' + err.getMessage() + '\n'
                                    + ' Status code  : ' + err.getStatusCode() + '\n'
                                    + ' Fields errored : ' + err.getFields() + '\n'
                                    + ' Preboarding Case id : ' + casesToCloseCancel[i].Id + '\n'
                                    + ' Scheduled job id : ' + context.getJobID();
                            String ErrorMessage = 'Error message is : ' + err.getMessage() ;
                            String ErrorType = 'Error while closing pre-boarding case in NHW_CW_CloseCancelCasesAsync';
                            //PF_Logger.log('NHW', 'ERROR', ErrorMessage, ErrorType, Description, 'NHW_Contractor_To_Case_Processes');
                            EventBus.publish(
                                new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'Error',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = ErrorType,
                                Stack_Trace__c = 'NHW_CW_CloseCancelCasesAsync',
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
                String ErrorType = 'Error while closing pre-boarding cases in NHW_CW_CloseCancelCasesAsync';
                //PF_Logger.log('NHW', 'ERROR', ErrorMessage, ErrorType, Description, 'NHW_Contractor_To_Case_Processes');
                EventBus.publish(
                    new PF_Logging_Channel__e(
                        ApplicationName__c = 'NHW',
                        LogLevel__c = 'Error',
                        //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                        ErrorType__c = ErrorType,
                        Stack_Trace__c = 'NHW_CW_CloseCancelCasesAsync',
                        Message__c = ErrorMessage,
                        Error__c = Description
                        )
                );
            }
            NHW_Util.insertNHWLogs();
        }
}