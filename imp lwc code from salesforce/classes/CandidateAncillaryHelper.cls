public with sharing class CandidateAncillaryHelper {
    public Id candidateId {get; private set;}
    
    public CandidateAncillaryHelper(){
        candidateId = ApexPages.currentPage().getParameters().get('Id');
    }
}