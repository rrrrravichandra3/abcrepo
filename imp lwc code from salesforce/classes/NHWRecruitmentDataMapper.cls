public Interface NHWRecruitmentDataMapper{
    
    NHWRecruitmentModel getNHWRecruitmentModelObjectById(Id ObjectId);
    list<NHWRecruitmentModel> getAllNHWRecruitmentModelObjectsForMger(set<id> userId);
        
}