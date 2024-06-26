public class DJC_QuarterWellnessManagerFactory extends DJC_WellnessManagerFactory{

	public DJC_QuarterWellnessManagerFactory(DJC_Region region, Reimbursement_Policy__mdt policy, Contact contact, Reimbursement_Category__mdt category){
		super(region, policy, contact, category);
	}

	public override DJC_ClaimManager getClaimManager(){
		return new DJC_QuarterClaimManager(region, policy, new DJC_QuarterTimeRangeManager(region), contact);
	}

	public override DJC_TimeRangeManager getTimeRangeManager(){
		return new DJC_QuarterTimeRangeManager(region);
	}
    
    public override DJC_ReimbursementLabelFactory getLabelFactory(){
        return new DJC_WellnessLabelFactory(region);
    }

}