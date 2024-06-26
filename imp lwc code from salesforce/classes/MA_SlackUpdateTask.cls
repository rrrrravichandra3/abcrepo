/**
* @description       : Apex class used to send notification when task is updated for Acquisition Contact. It is called from MA Slack Task Notifications flow
* @author            : Satyam Kumar
* Modifications Log 
* Ver   Date         Author          Modification
* 1.0   05-06-2021   Satyam Kumar   Initial Version
**/

public with sharing class MA_SlackUpdateTask {
    
    @InvocableMethod(label='Update Task Notification' description='Sends task update notification')
    public static void updateTaskNotification(List<Id> ids){
        MA_Util.processTaskNotification(ids, false);
    }

}