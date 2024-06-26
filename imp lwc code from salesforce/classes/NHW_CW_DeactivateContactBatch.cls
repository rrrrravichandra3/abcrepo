/**
 * Created by kmoseley on 4/12/21.
 */

global without sharing class NHW_CW_DeactivateContactBatch implements Database.Batchable<sObject>,Schedulable{

    global Database.QueryLocator start(Database.BatchableContext BC){
        Id contractorRTId = NHW_Util.getContractorContactRecordTypeId();

        return Database.getQueryLocator([SELECT Id, Status__c, Start_Date__c,Term_Date__c, CW_Work_Order_Status__c
        FROM Contact
        WHERE RecordTypeId =:contractorRTId
        AND Status__c = 'Active'
        AND Term_Date__c != NULL
        AND Term_Date__c <=: System.today()]);
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope){
        Database.SaveResult[] failedResults = new Database.SaveResult[]{};

        for(Contact c: scope){
            c.CW_Work_Order_Status__c = 'Closed';
        }
        if(Contact.sObjectType.getDescribe().isUpdateable()){
            try {
                Database.SaveResult[] srList = Database.update(scope,false);

                Integer i = 0;
                for(Database.SaveResult sr:srList){
                    if(!sr.isSuccess()){
                        failedResults.add(sr);
                    }
                    i = i+1;
                }
                if(!failedResults.isEmpty()) {
                    sendEmailforFailedRecords(failedResults);
                }
            } catch (DmlException ex) { 
                system.debug('The following exception has occurred: ' + 
                            ex.getDmlStatusCode(0) + ex.getMessage());
            }
        }
    }

    global void finish(Database.BatchableContext BC){
        // Logic to be Executed at finish
    }

    global void execute(SchedulableContext SC){
        NHW_CW_DeactivateContactBatch deactivateContractors = new NHW_CW_DeactivateContactBatch();
        database.executebatch(deactivateContractors,200);
    }

    private static void sendEmailforFailedRecords(List<Database.SaveResult> failedRecords){

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        NH_Settings__c settings = NH_Settings__c.getInstance();
        message.toAddresses = new String[] { settings.Support_Email__c};
        if(settings.BCC_Email_Addresses__c != null){
            message.setCcAddresses( settings.BCC_Email_Addresses__c.split(';') );
        }

        message.subject = 'De-Activation of Contractor Contacts Failed';
            String messageText = '<br/>Following Contractor Contact failed to be updated to Deactive :';
            for(Database.SaveResult fResult : failedRecords){
                messageText += '<br/> Contact Id : <b>'+ fResult.getId() + ' </b> with Error Message : <b><i>' + fResult.getErrors() +'</b></i>';
            }
            message.htmlBody = messageText;


        message.htmlBody += '<br/><br/><b>Please look at exception/error message and resolve the issue, then go to individual contacts in the transction, and set Status to "Deactive".</b><br/>';
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        if(!Test.isRunningTest()){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }
    }
}