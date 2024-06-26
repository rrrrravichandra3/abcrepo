public with sharing class IFB_CandidateCompetencySummary {
    @AuraEnabled
    public static List<IFB_Interview_Evaluation__c> getCompetencyDetails(Id interviewId){
    return [Select Comments__c,Interview_Question__r.Competency__c,Interview__r.Recommendation__c,Interview_Question__r.Domain__c,Interview_Question__r.Question__c, Rating__c, Interview__r.Candidate__r.Name,Interview__r.Name
                from IFB_Interview_Evaluation__c
                where Interview__c = :interviewId];
    }
    
}