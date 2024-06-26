public class DJC_YearWellnessManagerFactory extends DJC_WellnessManagerFactory{

	public DJC_YearWellnessManagerFactory(DJC_Region region, Reimbursement_Policy__mdt policy, Contact contact,
                                          Reimbursement_Category__mdt category){
		super(region, policy, contact, category);
	}

	public override DJC_ClaimManager getClaimManager(){
		return new DJC_YearClaimManager(region, policy, new DJC_YearTimeRangeManager(region), contact);
	}

	public override DJC_TimeRangeManager getTimeRangeManager(){
		return new DJC_YearTimeRangeManager(region);
	}
    
    public override DJC_ReimbursementLabelFactory getLabelFactory(){
        return new DJC_HealthLabelFactory(region);
    }
}