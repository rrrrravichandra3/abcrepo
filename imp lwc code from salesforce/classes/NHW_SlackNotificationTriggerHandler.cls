public class NHW_SlackNotificationTriggerHandler implements PF_SlackNotificationTriggerHandler {
    
    public static void invokeSlackTaskHubAPIService(List<Slack_Taskhub_Notification__e> evts) {
        Map<String,List<Slack_Taskhub_Notification__e>> activityToEventMap = new Map<String,List<Slack_Taskhub_Notification__e>>();
        List<Slack_Taskhub_Notification__e> contactNHEvents = new List<Slack_Taskhub_Notification__e>();
        List<Slack_Taskhub_Notification__e> completeNHWEvents = new List<Slack_Taskhub_Notification__e>();
        List<Slack_Taskhub_Notification__e> redHotEvents = new List<Slack_Taskhub_Notification__e>();
        //use activity type passed in event to decide type to notitfication
        for(Slack_Taskhub_Notification__e evt:evts) {
            if(evt.activity_type__c == 'nhw-contact-new-hire-activity') {
                contactNHEvents.add(evt);
            } else if(evt.activity_type__c == 'nhw-complete-new-hire-wizard-activity') {
                completeNHWEvents.add(evt);                       
            } else if (evt.activity_type__c == 'nhw-red-hot-new-hire-activity'){
                redHotEvents.add(evt);
            }
        }
        if(contactNHEvents.size()>0) {
            activityToEventMap.put(PF_TaskHub_Activity_Type_HM_Contact_NH.class.getName(),contactNHEvents);
        }
        if(completeNHWEvents.size()>0) {
            activityToEventMap.put(PF_TaskHub_Activity_Type_HM_Complete_NHW.class.getName(),completeNHWEvents);
        }
        if(redHotEvents.size()>0) {
            activityToEventMap.put(PF_TaskHub_Activity_Type_HM_RedHot_NH.class.getName(),redHotEvents);
        }

        Id id = System.enqueueJob(new PF_SlackTaskhubServiceCalloutUtil(activityToEventMap,'NHW'));
    }
    
}