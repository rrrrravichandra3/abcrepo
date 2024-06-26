/**
* @description       : Apex class used to send notification when new task is added for Acquisition Contact. It is called from MA Slack Task Notifications flow
* @author            : Satyam Kumar
* Modifications Log 
* Ver   Date         Author          Modification
* 1.0   05-06-2021   Satyam Kumar   Initial Version
**/

public with sharing class MA_SlackNewTask {
    
    @InvocableMethod(label='New Task Notification' description='Sends new task notification')
    public static void newTaskNotification(List<Id> ids){
        MA_Util.processTaskNotification(ids, true);
    }
}