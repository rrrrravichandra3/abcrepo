public abstract class DJC_WellnessManagerFactory {

    public Reimbursement_Policy__mdt policy {get; private set;}
    
    public Reimbursement_Category__mdt category {get; private set;}

	protected DJC_Region region;
    
    protected Contact contact;

    protected DJC_WellnessManagerFactory(DJC_Region region, Reimbursement_Policy__mdt policy, Contact contact, 
                                        Reimbursement_Category__mdt category){
        this.policy = policy;
        this.region = region;
        this.contact = contact;
		this.category = category;
    }

    public static DJC_WellnessManagerFactory getInstance(DJC_Region region, Reimbursement_Policy__mdt policy,
                                                         Reimbursement_Category__mdt category,
                                                         Contact contact){

        if(policy.Organization__c.equalsIgnoreCase('Salesforce')){                                                 
            if(category.Group__c.equalsIgnoreCase(DJC_Wellness_Type.WELLNESS.name())){
                return new DJC_QuarterWellnessManagerFactory(region, policy, contact, category);
            }else if(category.Group__c.equalsIgnoreCase(DJC_Wellness_Type.HEALTH.name())){
                return new DJC_YearWellnessManagerFactory(region, policy, contact, category);
            }else if(category.Group__c.equalsIgnoreCase(DJC_Wellness_Type.EDUCATION.name())){
                return new DJC_YearEducationManagerFactory(region, policy, contact, category);
            }
        }else if(policy.Organization__c.equalsIgnoreCase('Foundation')){
            if(category.Group__c.equalsIgnoreCase(DJC_Wellness_Type.WELLNESS.name())){
                return new DJC_WellnessManagerFactory_Fndt(region, policy, contact, category);
            }else if(category.Group__c.equalsIgnoreCase(DJC_Wellness_Type.HEALTH.name())){
                return null;
            }else if(category.Group__c.equalsIgnoreCase(DJC_Wellness_Type.EDUCATION.name())){
                return new DJC_YearEducationManagerFactory_Fndt(region, policy, contact, category);
            }
        }
		return null;
	}

	public abstract DJC_ClaimManager getClaimManager();

	public abstract DJC_TimeRangeManager getTimeRangeManager();
    
    public abstract DJC_ReimbursementLabelFactory getLabelFactory();
}