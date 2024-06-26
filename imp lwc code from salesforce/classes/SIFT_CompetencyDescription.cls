public class SIFT_CompetencyDescription {
    public Id siftInterviewId {get; set;}
    public Map<String,String> comps {set; get{
        if(siftInterviewId==null){
            return new Map<String,String>();
        }
        List<IFB_Interview__c> interviews = [SELECT Id, Name, Candidate__r.SIFT_Group__r.Name, Candidate__r.SIFT_Position__r.Name,Candidate__r.Name, Interview_Type__r.Name FROM IFB_Interview__c  where Id = :siftInterviewId];   
        List<IFB_Interview_Evaluation__c> evaluations = [SELECT Id, Name,Interview_Question__r.Competency__c FROM IFB_Interview_Evaluation__c where Interview__c = :interviews[0].Id ORDER BY Interview_Question__r.Sort_Order__c];
        List<String> competenciesNames = new List<String>();
        for(IFB_Interview_Evaluation__c evaluation:evaluations){
            competenciesNames.add(evaluation.Interview_Question__r.Competency__c);               
        }
        Map<String,String> nameToDescriptionMap = new Map<String,String>();
		for(String compName:competenciesNames){
          nameToDescriptionMap.put(compName, '');
    	} 
        List<IFB_Competency_Description__c> descriptions = IFB_CompetencyDescription_DAO.getRecordsFromCompetencyNames(competenciesNames, interviews[0].Candidate__r.SIFT_Group__r.Name, interviews[0].Interview_Type__r.Name, interviews[0].Candidate__r.SIFT_Position__r.Name);
        for(IFB_Competency_Description__c description : descriptions){
           IFB_CompetencyDescriptionSorter competencySorter = new IFB_CompetencyDescriptionSorter(descriptions, interviews[0].Candidate__r.SIFT_Group__r.Name, interviews[0].Interview_Type__r.Name, interviews[0].Candidate__r.SIFT_Position__r.Name); 
           Map<String, IFB_Competency_Description__c> competencyNameTodecriptionRecMap = competencySorter.getCompetencyByNameMap();
           for(IFB_Competency_Description__c currentDesc : competencyNameTodecriptionRecMap.values()){
                nameToDescriptionMap.put(currentDesc.Name,currentDesc.Competency_Description__c);
           }
        } 
       return nameToDescriptionMap;
      }
    }


}