global class updateScheduledInterviewDateInterview implements Database.Batchable<sObject>, Database.Stateful{

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([Select Id, Scheduled_Interview_Date__c, Scheduled_Interview_Date_only__c FROM IFB_Interview__c where Scheduled_Interview_Date_only__c = null and Scheduled_Interview_Date__c != null]);
    }
    
    global void execute(Database.BatchableContext BC, List<IFB_Interview__c> ifbInterview){
        List<IFB_Interview__c> lstUpdateInterview = new List<IFB_Interview__C>();

        DateTime schDate;
        for(IFB_Interview__c interview : ifbInterview){
            if(IFB_AccessibilityUtils.checkFLS('IFB_Interview__c',
                    IFB_AccessibilityUtils.PermissionType.UPDATEABLE,
                    new List<String> {'Scheduled_Interview_Date_only__c'})){
                interview.Scheduled_Interview_Date_only__c =  date.newInstance(schDate.year(),schDate.month(),schDate.day());
            }else{
                throw new PF_SecurityCheckException(Label.SIFT_Exception_Update_IFB_Interview);
            }
            schDate = interview.Scheduled_Interview_Date__c;
            lstUpdateInterview.add(interview);
        }

        if(lstUpdateInterview.size() > 0){
            Database.SaveResult[] sR = Database.Update(lstUpdateInterview, false);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        //dont need to do anything
    }
}