public class DJC_WellnessManagerFactory_Fndt extends DJC_WellnessManagerFactory{

	public DJC_WellnessManagerFactory_Fndt(DJC_Region region,
                                           Reimbursement_Policy__mdt policy, Contact contact,
                                           Reimbursement_Category__mdt category){
		super(region, policy, contact, category);
	}

	public override DJC_ClaimManager getClaimManager(){
		return new DJC_WellnessClaimManager_Fndt(region, policy, new DJC_WellnessTimeRangeManager_Fndt(region), contact);
	}

	public override DJC_TimeRangeManager getTimeRangeManager(){
		return new DJC_WellnessTimeRangeManager_Fndt(region);
	}
    
    public override DJC_ReimbursementLabelFactory getLabelFactory(){
        return new DJC_WellnessLabelFactory_Fndt(region);
    }
}