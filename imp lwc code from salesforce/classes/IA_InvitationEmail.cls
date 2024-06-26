/*
 * @author Lucas Olivera
 * @date 12/23/2020
 *
 * @description Class used to enqueue "IA_InvitationEmailQueueableClass" to send Invitation Email
 *              to valid Candidates from Insiders Invitation Email Flow.
 *
 * Modifications Log
 * Ver   Date         Author                          Modification
 * 1.0   12/23/2020   lolivera@salesforce.com         Initial Version
 * 1.1   7/25/2022    kmoseley@salesforce.com         Migrate to Platform Event for sending notification
 */
public with sharing class IA_InvitationEmail {
    @InvocableMethod
/*
@description : sending email to canditates
@params : jobApplications List<WDR_Application__c>
*/

    public static void sendEmailToCandidates(List<WDR_Application__c> jobApplications) {
        List<IA_Send_Invitation_Email__e> events = new List<IA_Send_Invitation_Email__e>();
        List<String> errorMessages = new List<string>();
        for(WDR_Application__c a: jobApplications){
            events.add(new IA_Send_Invitation_Email__e(JobAppId__c = a.Id));
        }

        Database.SaveResult[] saveResultList = Eventbus.publish(events);

        for(Database.SaveResult sr: saveResultList){
            if(!sr.isSuccess()){
                System.debug('Failed to generate Platform Event for Email Notification'); 
            }
        }
        /*
        try {
            System.enqueueJob(new IA_InvitationEmailQueueableClass(jobApplications));
        } catch (Exception exp) {
            errorMessages.add(IA_Util.buildErrorMessage(UserInfo.getUserEmail(), jobApplications[0].id, 'Send Email To Candidates', exp.getMessage(), exp.getStackTraceString()));
        } finally {
            IA_Util.notifyErrors(errorMessages);
        }
        */
    }
}