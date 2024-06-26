/**
 * Created by kmoseley on 3/10/21.
 */

public with sharing class PF_Debug_Log_SendEmail {

    @InvocableMethod (Label='Send PF Debug Log')
    public static void sendNotificationInvocable(List<Id> ids){
        sendEmailAlert(ids);
    }

    @Future
    public static void sendEmailAlert(List<Id> ids){

        List<PF_Debug_Log__c> logs = [SELECT Id, Description__c,Error_Message__c,Error_Type__c FROM PF_Debug_Log__c WHERE id IN: ids];
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        NH_Settings__c settings = NH_Settings__c.getInstance();
        if(settings.EmailToCase_Address__c != null) {
            message.toAddresses = settings.EmailToCase_Address__c.split(';');

            message.subject = 'Contractor Contact to Case Sync Failed';
            if (!logs.isEmpty()) {
                String messageText = '<br/>Following Contractor Contact Records transfer Failed when syncing data to cases: ';
                for (PF_Debug_Log__c log : logs) {
                    messageText += '<br/> Error Type : ' + log.Error_Type__c + '<br/> <i>' + log.Description__c + '</i><br/>';
                    message.htmlBody +='Log URL : '+ URL.getSalesforceBaseUrl().toExternalForm() +'/'+log.Id +'<br/>';
                }
                message.htmlBody = messageText;
            }
            message.htmlBody += '<br/><br/><b>Please look at exception/error message and resolve the issue, and the automated process will attempt again.</b><br/>';
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
                    message
            };
            if (!Test.isRunningTest()) {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            }
        }
    }
}