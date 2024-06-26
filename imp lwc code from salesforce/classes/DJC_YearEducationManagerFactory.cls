public with sharing class DJC_YearEducationManagerFactory extends DJC_WellnessManagerFactory {
	
	public DJC_YearEducationManagerFactory(DJC_Region region, Reimbursement_Policy__mdt policy, Contact contact,
                                          Reimbursement_Category__mdt category){
		super(region, policy, contact, category);
	}

	public override DJC_ClaimManager getClaimManager(){
		return new DJC_YearEducationClaimManager(region, policy, new DJC_YearEducationTimeRangeManager(region), contact);
	}

	public override DJC_TimeRangeManager getTimeRangeManager(){
		return new DJC_YearEducationTimeRangeManager(region);
	}
    
    public override DJC_ReimbursementLabelFactory getLabelFactory(){
        return new DJC_EducationLabelFactory(region);
    }
}