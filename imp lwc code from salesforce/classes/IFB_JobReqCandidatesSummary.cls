public with sharing class IFB_JobReqCandidatesSummary {
    @AuraEnabled
    public static List<candidateOption> getcandidateIds(Id jobReqId){
        List<IFB_Interview_Candidate__c> candidates= new List<IFB_Interview_Candidate__c>();
        List<Id> candidateIds = new List<Id>();
        List<candidateOption> candidateOptions= new List<candidateOption>();
        for(WDR_Application__c application: [Select id,SIFT_Recruit__c,SIFT_Recruit__r.Name from WDR_Application__c where Job__c =: jobReqId ]){
            if(application.SIFT_Recruit__c!=null){
                candidateIds.add(application.SIFT_Recruit__c);
            }
        }
        if(!candidateIds.isEmpty()){
            for(IFB_Interview_Candidate__c  candidate :[Select Id,name,Job_Application_WDR__r.Candidate_Stage__c from IFB_Interview_Candidate__c where id in : candidateIds]){
                candidateOption can= new candidateOption();
                //can.candidateName = candidate.name;
                //can.candidateId = candidate.Id;
                can.label = candidate.name;
                can.value = candidate.Id;
                can.candidateStage = candidate.Job_Application_WDR__r.Candidate_Stage__c;
                candidateOptions.add(can);
            }
        }
      return candidateOptions;
    }

    public class candidateOption{
        @AuraEnabled public String label {get; set;} 
        @AuraEnabled public Id value {get; set;} 
        @AuraEnabled public String candidateStage {get; set;} 
    }
}