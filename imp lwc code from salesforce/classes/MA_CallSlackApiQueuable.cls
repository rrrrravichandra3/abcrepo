/**
* @description       : Queueable Apex class used to make callout to Slack for Task Notifications when executed from Batch or Future method
* @author            : Satyam Kumar
* Modifications Log 
* Ver   Date         Author          Modification
* 1.0   05-07-2021   Satyam Kumar   Initial Version
**/

public class MA_CallSlackApiQueuable implements Queueable, Database.AllowsCallouts {
    String body;
    public MA_CallSlackApiQueuable(string bodyStr) {
        body = bodyStr;
    }
    
    public void execute(QueueableContext context) {
        HttpResponse res = MA_SlackWayfinderService.workatoWayfinderServiceCallout(body);
        boolean success = MA_SlackWayfinderService.workatoWayfinderResponseHandler(res);
        if (success){
            System.debug('Successfully sent message to slack');
        } else {
            System.debug('Failed to send message to slack');
        }
        PF_Logger.createLogs(PF_Logger.logs);
    }
}