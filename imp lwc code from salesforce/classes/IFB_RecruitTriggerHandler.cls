public class IFB_RecruitTriggerHandler {

    public static void deleteRecruitInterviews(Map<Id,IFB_Interview_Candidate__c> recruits){
        
        List<IFB_Interview__c> interviews = new List<IFB_Interview__c>();
        if (recruits != null) {
            interviews = [SELECT Id, Status__c, Candidate__c FROM IFB_Interview__c WHERE Candidate__c IN :recruits.keySet()];
        }
        
        Set<Id> idsRecordsWithErrors = new Set<Id>();
        List<IFB_Interview__c> interviewsToDelete = new List<IFB_Interview__c>();
        
        for(IFB_Interview__c interview:interviews){
            if(interview.Status__c != 'New'){
                recruits.get(interview.Candidate__c).addError('Recruits with interviews submitted or in progress cannot be deleted');
                idsRecordsWithErrors.add(interview.Candidate__c);
            }
        }
        
        for(IFB_Interview__c interview:interviews){
            if(!idsRecordsWithErrors.contains(interview.Candidate__c)){
                interviewsToDelete.add(interview);
            }
        }
        
        if(!interviewsToDelete.isEmpty()){
            Boolean canDeleteInterviews = false;
            canDeleteInterviews = IFB_AccessibilityUtils.checkFLS('IFB_Interview__c',
                                  IFB_AccessibilityUtils.PermissionType.DELETABLE,
                                  new List<String>());

            if (canDeleteInterviews == true) {
                DELETE interviewsToDelete;    
            } else {
                throw new PF_SecurityCheckException(Label.SIFT_Exception_Delete_Interviews);
            }       
        }
    }
}