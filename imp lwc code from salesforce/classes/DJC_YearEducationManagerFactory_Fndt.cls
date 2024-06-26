public class DJC_YearEducationManagerFactory_Fndt extends DJC_WellnessManagerFactory{

	public DJC_YearEducationManagerFactory_Fndt(DJC_Region region,
                                                Reimbursement_Policy__mdt policy, Contact contact,
                                                Reimbursement_Category__mdt category){
		super(region, policy, contact, category);
	}

	public override DJC_ClaimManager getClaimManager(){
		return new DJC_YearEducationClaimManager_Fndt
            (region, policy, new DJC_YearEducationTimeRangeManager_Fndt(region), contact);
	}

	public override DJC_TimeRangeManager getTimeRangeManager(){
		return new DJC_YearEducationTimeRangeManager_Fndt(region);
	}
    
    public override DJC_ReimbursementLabelFactory getLabelFactory(){
        return new DJC_EducationLabelFactory_Fndt(region);
    }   
}