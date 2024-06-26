public without sharing class NHWRecruitmentModelObjectsStore {
    
    private static NHWRecruitmentJobApplicationDataMapper jobApplicationDataMapper = new NHWRecruitmentJobApplicationDataMapper();
    
    private static NHWRecruitmentPlacementDataMapper placementDataMapper = new NHWRecruitmentPlacementDataMapper();
    
    public static List<NHWRecruitmentModel> getAllNHWRecruitmentModelObjectsForMger(Set<Id> userIds){
        
        List<NHWRecruitmentModel> modelObjects = new List<NHWRecruitmentModel>();
        modelObjects.addAll(jobApplicationDataMapper.getAllNHWRecruitmentModelObjectsForMger(userIds));
        //if current user is member of Executive onboarding team, get all applications attached to SVP Job reqs, where JOb Level>=12
        if(NHW_Util.isCurrentUserExecutive()){
            modelObjects.addAll(jobApplicationDataMapper.getAllNHWRecruitmentModelObjectsForExecOnboardingTeam());
        }
        return modelObjects;
    }
    
    public static Id getModelIdByCaseId(Id caseId){
        Case c = [select NHW_Job_Application__c FROM Case WHERE Id = :caseId];
        return c.NHW_Job_Application__c;
    }
    
    public static NHWRecruitmentModel getNHWRecruitmentModelObjectById(Id modelId){
        NHWRecruitmentModel model = jobApplicationDataMapper.getNHWRecruitmentModelObjectById(modelId);
        if(model != null){
            return model;
        }
        return placementDataMapper.getNHWRecruitmentModelObjectById(modelId);
    }
}