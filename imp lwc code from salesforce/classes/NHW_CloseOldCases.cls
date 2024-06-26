/*
 * $Author: Kshitiz Srivastava
 * $DateTime: Oct 30 2017
 * $File: 
 * $Revision: 
 * $Description: Batch process to clean up old NHW records. Records that are 40 days past the start date are closed
 *               To be run once whenever needed. Keep batch size low (around 10), example -> Id batchJobId = Database.executeBatch(new NHW_CloseOldCases(), 10);
*/

global with sharing class NHW_CloseOldCases implements Database.Batchable<sObject>, Database.Stateful{

    global Map<String, String> caseNumberToErrorMap;
    private final String DEFAULT_EMAIL = 'ksrivastava@salesforce.com';
    
    global NHW_CloseOldCases(){
        caseNumberToErrorMap = new Map<String, String>();
    }

    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        Id recTypeIdNHW = NHW_Util.getnhwCaseRecordTypeId();
        Date expirationDate = Date.Today().addDays(-40);
        return Database.getQueryLocator([Select Id, CaseNumber, Status from Case where isClosed=false AND Status!='Sent to Supportforce' AND RecordTypeId = :recTypeIdNHW AND NHW_Start_Date__c!=null AND NHW_Start_Date__c < :expirationDate]);
    }


    // Execute Logic
    global void execute(Database.BatchableContext BC, List<Case> scope){
        for(Case currentCase : scope){
            currentCase.Status = 'Closed - Cancelled';
        }
        if(Case.sObjectType.getDescribe().isUpdateable()){
            try {	
                List<Database.SaveResult> updateResults = Database.update(scope, false);
                    for(Integer i=0;i<updateResults.size();i++){
                        if (!updateResults.get(i).isSuccess()){
                            // DML operation failed
                            Database.Error error = updateResults.get(i).getErrors().get(0);
                            String failedDML = error.getMessage();
                            caseNumberToErrorMap.put(String.valueOf(scope.get(i).CaseNumber),failedDML);
                        }
                    }
                } catch (DmlException ex) { 
                    system.debug('The following exception has occurred: ' + 
                                ex.getDmlStatusCode(0) + ex.getMessage());
                }
        }
    }

    //finish block to send email with failed records
    global void finish(Database.BatchableContext BC){
        //get email address from custom settings
        String emailRecipients = ESDJC_Settings__c.getOrgDefaults().DJC_Batchjob_Support_Email__c;
        String[] toAddresses = new String[]{};
        if(String.isBlank(emailRecipients)){
            toAddresses.add(DEFAULT_EMAIL);
        }else{
            List<String> allEmailAddresses = emailRecipients.split(',');
            for(String currEmail : allEmailAddresses){
                toAddresses.add(currEmail);
            }
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] ccAddresses = new String[] {DEFAULT_EMAIL};
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(ccAddresses);
        mail.setReplyTo(DEFAULT_EMAIL);
        mail.setSubject('Results of Batch Process NHW_CloseOldCases run on '+Date.Today());
        mail.setBccSender(false);
        mail.setUseSignature(false);

        if(caseNumberToErrorMap.isEmpty()){
            mail.setHtmlBody('All Records were processed successfully');
        }else{
            String msgBody = 'Following Records Failed <br></br>';
            for(String currCaseNumber : caseNumberToErrorMap.keySet()){
                msgBody = msgBody + '<b>Case Number '+currCaseNumber+'</b> : '+ caseNumberToErrorMap.get(currCaseNumber) + '<br></br>';
            }
            mail.setHtmlBody(msgBody);
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}