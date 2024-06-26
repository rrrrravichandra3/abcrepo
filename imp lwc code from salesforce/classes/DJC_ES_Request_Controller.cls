public class DJC_ES_Request_Controller extends BaseDJCController{

    public String policyId{get;set;}
    
    public String categoryId{get;set;}
    
    public DJC_ES_Request_Controller(){
        headermsg = 'Select your wellness form';
    }
    
    public List<ClaimPolicy> policies{
        get{
            if (policies == null) {
                policies = new List<ClaimPolicy>();
                List<DJC_Wellness_Health_Policy__c> wellnessPolicies = [select id, DJC_Wellness_Quarterly_Limit__c, currencyISOCode,
                                                                DJC_Wellness_Country__r.name,DJC_Wellness_Annual_Limits_for_Health__c,
                                                                (select DJC_Wellness_Category__r.name, DJC_Wellness_Category__r.id from Wellness_Policy_Category_Associations__r)
                                                                from DJC_Wellness_Health_Policy__c 
                                                                where DJC_Wellness_Active__c = true
                                                                and DJC_Wellness_Policy_Start_Date__c <= today  
                                                                and (DJC_Wellness_Policy_End_Date__c = null OR DJC_Wellness_Policy_End_Date__c >= today)
                                                                and DJC_Wellness_Country__r.name = :contactCountry
                                                               ];

                for (DJC_Wellness_Health_Policy__c policy : wellnessPolicies) {
                    for (DJC_Wellness_Quarter_Category_Assn__c category : policy.Wellness_Policy_Category_Associations__r) {
                        policies.add(new ClaimPolicy(category.DJC_Wellness_Category__r.name, policy.id, category.DJC_Wellness_Category__r.id));    
                    }
                }
            }                                    
            return policies;
        }
        private set;
    }

    public PageReference selectForm(){
        return new PageReference('/apex/DJC_ES_Reimbursement_Request?policyId='+policyId+'&categoryId='+categoryId);
    }

    public class ClaimPolicy {

        public String policyText {public get; private set;}
        public Id policyId {public get; private set;}
        public Id categoryId {public get; private set;}

        public ClaimPolicy(String text, Id policyId, Id categoryId) {
            this.policyText = text;
            this.policyId = policyId;
            this.categoryId = categoryId;
        }                
    }
    
    public String getUrl() {
        return ESDJC_Util.getSSOURL()+'/apex/DJC_ES_Requests?thanks=';
    }
    
    public PageReference myReimbursementCases(){
	    PageReference pr = new PageReference('/apex/DJC_ES_MyReimbursementCases');
        pr.setRedirect(true);
        return pr;
    }
    
    public override String getRecordType(){
        return null;
    }
}