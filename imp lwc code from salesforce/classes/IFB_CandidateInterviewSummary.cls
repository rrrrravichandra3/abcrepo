public with sharing class IFB_CandidateInterviewSummary {
    @AuraEnabled
    public static List<IFB_Interview__c> getInterviewDetails(Id candidateId){
      return [select Id,Candidate__r.Name,Candidate__r.Job_Application_WDR__r.Candidate_Stage__c, Actual_Interview_Date__c, Interviewer__r.Name, Interview_Type__r.Name, Comments__c, Recommendation__c, Overall_Interview_Score__c, Overall_Interview_Rating__c, RecordTypeId, Status__c, Interview_Language__c
                                         from IFB_Interview__c
                                         where Candidate__c = :CandidateId];
    }
    
}