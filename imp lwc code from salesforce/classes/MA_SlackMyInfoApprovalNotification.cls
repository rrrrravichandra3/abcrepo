/**
 * MA_SlackMyInfoApprovalNotification Class is used to create messages and send them to Slack after MY Info Updates were Approved/Rejected
 * Ver   Date         Author            Modification
 * 1.0   02-07-2021   Sergey Mihalyuk   Initial Version
 */
public class MA_SlackMyInfoApprovalNotification {
    
    @InvocableMethod(label='Notify Slack Users' description='If My Info Updates Approved or Rejected, then send notification to Slack')
    public static void notifySlackUsers(List<List<MA_My_Info_Updates__c>> myInfoUpdates) {
        Set<Id> userIds = new Set<Id>();
        List<MA_SlackWayfinderService.SlackMessageBody> messages = new List<MA_SlackWayfinderService.SlackMessageBody>();

        for(MA_My_Info_Updates__c myInfos : myInfoUpdates[0]) {
            userIds.add(myInfos.CreatedById);
        }

        for(User user : [SELECT Id, Contact.M_A_Community_URL__c, Contact.Acquisition_Contacts__r.Id, Contact.Acquisition_Contacts__r.Email_Address_Target__c FROM User WHERE Id IN: userIds]) {
            String messageText = '';
            String titleStatus;
            for (MA_My_Info_Updates__c myInfos : myInfoUpdates[0]) {
                if (user.Id == myInfos.CreatedById) {
                    if (myInfos.Mass_Approval__c || myInfos.Status__c == 'Accepted') {
                        titleStatus = 'Approved';
                    } else if (myInfos.Mass_Rejection__c || myInfos.Status__c == 'Rejected') {
                        titleStatus = 'Rejected';
                    }
                    if (String.isNotBlank(myInfos.Approver_Comments__c)) {
                        messageText = myInfos.Approver_Comments__c;
                        break;
                    } else {
                        messageText = messageText == '' ? myInfos.Field_Label__c + ' ' + System.Label.MA_Msg_has_been_updated : myInfos.Field_Label__c + ', ' + messageText;
                    }
                }
            }
            messageText = String.format(System.Label.MA_Msg_Your_info_change_request_has_been, new String[]{titleStatus}) + ' ' + messageText;
            messages.add(new MA_SlackWayfinderService.SlackMessageBody(
                user.Contact.Acquisition_Contacts__r.Email_Address_Target__c,
                messageText,
                user.Contact.M_A_Community_URL__c + 's/myinfo',
                System.Label.MA_Btn_Slack_Your_Info
            ));
        }

        if(!messages.isEmpty()){
            MA_SlackWayfinderService.sendMessagestoSlackWayfinderBot(messages, true); 
        }

    }     
}