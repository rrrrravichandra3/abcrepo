public without sharing class closedCaseNotificationTiggerHandler {
    
    public Static void closedCaseNotification(List<caseNotificationEvent__e> caseNotifications){
        List<Id> surveyCaseIds = new List<Id>();
        List<Id> notificationCaseIds = new List<Id>();
        for(caseNotificationEvent__e Notificationevent :caseNotifications){
            if(Notificationevent.IsSurvey__c == true){
                surveyCaseIds.add(Notificationevent.caseId__c);
            }else{
                notificationCaseIds.add(Notificationevent.caseId__c);
            }
        }
        if (surveyCaseIds.size() > 0){
            DJC_Survey_Notification_Async.closedCaseNotificationWithSurvey(surveyCaseIds, false);
        }
        if (notificationCaseIds.size() > 0){
            DJC_Survey_Notification_Async.closedCaseNotificationWithoutSurvey(notificationCaseIds);
        }
        
    }
}