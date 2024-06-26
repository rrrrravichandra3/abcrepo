/**
 * Created by kmoseley on 2/25/21.
 */

public with sharing class MA_SlackCaseClosed {

    @InvocableMethod(label='Slack Case Closed' description='Sends notification of case closure')
    public static void caseClosed (List<Id> ids){
        List<MA_SlackWayfinderService.SlackMessageBody> messages = new List<MA_SlackWayfinderService.SlackMessageBody>();

        String messageText = System.label.MA_Slack_Case_Closure;
        List<Case> maCases = MA_SlackWayfinderService.getCaseInfo(ids);

        if(!maCases.isEmpty()){
            for(Case c: maCases){
                if(c.Acquisition_Contact__r.Email_Address_Target__c.contains('slack-corp.com')){
                    String communityurl = c.Contact.M_A_Community_URL__c+'s/my-cases?caseid='+c.Id;
                    MA_SlackWayfinderService.SlackMessageBody message = new MA_SlackWayfinderService.SlackMessageBody(c.Acquisition_Contact__r.Email_Address_Target__c,
                            messageText + ' '+ c.CaseNumber,
                            communityurl,
                            System.label.MA_Slack_Button_Text);

                    messages.add(message);
                }
            }
        }
        if(!messages.isEmpty()){
            MA_SlackWayfinderService.sendMessagestoSlackWayfinderBot(messages,true); 
        }
    }

}