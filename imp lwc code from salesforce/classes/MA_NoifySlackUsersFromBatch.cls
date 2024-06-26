/**
 * @description       : Class uset to call future method for sending Notification to Slack from MA_TaskEmailReminderBatch about uncompleted Tasks based on criteria
 * @author            : Sergey Mihalyuk
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   13-07-2021   Sergey Mihalyuk   Initial Version
**/
public with sharing class MA_NoifySlackUsersFromBatch {
    public static void sendMessagesToSlack(List<MA_SlackWayfinderService.SlackMessageBody> messages) {
        MA_SlackWayfinderService.sendMessagestoSlackWayfinderBot(messages, true); 
    }
}