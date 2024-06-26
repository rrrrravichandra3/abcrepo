public without sharing abstract class DJC_ClaimManager {

	protected DJC_TimeRangeManager timeRangeManager{get; private set;}

	protected Reimbursement_Policy__mdt policy{get; private set;}

	protected DJC_Region region{get; private set;}
    
    protected Contact contact{get;private set;}

	public DJC_ClaimManager(DJC_Region region, Reimbursement_Policy__mdt policy, DJC_TimeRangeManager timeRangeManager, Contact contact){
		this.timeRangeManager = timeRangeManager;
		this.policy = policy;
		this.region = region;
        this.contact = contact;
	}

    public Reimbursement_Policy_Limit__mdt getLimitForPeriodAndPolicy(String period){
        
        List<Reimbursement_Policy_Limit__mdt> limits = [SELECT Limit__c, Period__c, Policy_Id__c, Created_Date__c FROM Reimbursement_Policy_Limit__mdt WHERE Policy_Id__c = :policy.Id__c AND Period__c = :period];
		
        if(limits.isEmpty()){
            limits = [SELECT Limit__c, Period__c, Policy_Id__c, Created_Date__c FROM Reimbursement_Policy_Limit__mdt WHERE Policy_Id__c = :policy.Id__c order by Created_Date__c DESC];
        }
        return limits.get(0);
    }           
    
    public abstract Decimal getClaimsForPreviousTimeRange();
    
    public abstract Decimal getClaimsForCurrentTimeRange();
    
	public abstract Decimal getClaimTotalsForGivenStatusRange(String status ,String Range); 
    public abstract Decimal getBalanceForCurrentTimeRange();
    
    public abstract Decimal getBalanceForPreviousTimeRange();
}