public without sharing class DJC_Wellness_ClaimBuilder {
    
    private DJC_Wellness_Reimbursement_Claim__c claim;
    private Reimbursement_Policy__mdt policy;
    private Reimbursement_Category__mdt category;
    private Case claimCase;
    private Contact contact;
    public String timeRange{get; private set;}

    
    public DJC_Wellness_ClaimBuilder(DJC_Wellness_Reimbursement_Claim__c claim, Contact contact) {
        this.claim = claim;
        this.contact = contact;
    }
    
    public DJC_Wellness_ClaimBuilder(Contact contact) {
        this(new DJC_Wellness_Reimbursement_Claim__c(), contact);
    }
    
    public DJC_Wellness_ClaimBuilder addCase(Case claimCase){
        this.claimCase = claimCase;
        this.policy = [SELECT Id__c, Active__c, Country__c, Currency__c, Organization__c FROM Reimbursement_Policy__mdt WHERE Id__c = :this.claimCase.Reimbursement_Policy_Id__c];
        this.category = [SELECT Id__c, Group__c, MasterLabel FROM Reimbursement_Category__mdt WHERE Id__c = :this.claimCase.Reimbursement_Category_Id__c];
        return this;
    }
    
    public DJC_Wellness_Reimbursement_Claim__c build(){

        if (this.claim.DJC_Wellness_Case__c == null && claimCase == null) {
            claim.addError('Unknown case');
            return this.claim;
        }
        
        if(this.claim.DJC_Wellness_Case__c == null){
            this.claim.DJC_Wellness_Case__c = this.claimCase.Id;
        }

        if (claim.DJC_Wellness_Amount_Requested__c == null) {
            claim.DJC_Wellness_Amount_Requested__c.addError('value is required');
            return this.claim;
        }
        
        if(category.Group__c == 'Education'){
            if (claim.DJC_Education_Date_Completed__c == null) {                
                claim.DJC_Education_Date_Completed__c.addError('value is required');
                return this.claim;
            }
        }else{
            if (claim.DJC_Wellness_Start_Date_of_Activity__c == null) {                
                claim.DJC_Wellness_Start_Date_of_Activity__c.addError('value is required');
                return this.claim;
            }            
        }
        
        DJC_Region region = null;

        if(this.claimCase.Division__c != null){
            region = DJC_Wellness_Util.getRegion(this.claimCase.Division__c);
        } else{
            region = DJC_Wellness_Util.getRegion(this.claimCase.Division_Lookup__c);
        }

        DJC_WellnessManagerFactory wellnessManagerFactory = 
            DJC_WellnessManagerFactory.getInstance(
                region, policy, category, contact);
        
        DJC_TimeRangeManager trm = wellnessManagerFactory.getTimeRangeManager();
        trm.setContactCountry(contact.ES_DJC_Contact_Country__c);
        
        if(category.Group__c == 'Education'){

            if(claim.DJC_Education_Policy__c != null && claim.DJC_Education_Policy__c != ''){
                if(claim.DJC_Reimbursement_Claim_Detail__c == null || claim.DJC_Reimbursement_Claim_Detail__c == ''){
                    claim.DJC_Reimbursement_Claim_Detail__c.addError('Value is required');
                    return this.claim;
                }
            }
            Date createdDate = System.today();
            
            if(claim.CreatedDate != null){
                createdDate = Date.newinstance(claim.CreatedDate.year(), claim.CreatedDate.month(), claim.CreatedDate.day());
            }else{
                createdDate = System.today();
            }
            
            claim.DJC_Wellness_Claim_Quarter__c = trm.getQuarter(createdDate);
            claim.DJC_Wellness_Claim_Fiscal_Year_Start__c = trm.getCurrentTimeRange(createdDate);
            this.timeRange = trm.getCurrentTimeRange(createdDate);
        }else{
            if(this.claim.DJC_Wellness_Request_Status__c == 'Saved' || this.claim.DJC_Wellness_Request_Status__c == 'Submitted'){
                if(trm.isDateMorethanOnePeriodBack(claim.DJC_Wellness_Start_Date_of_Activity__c) && !Test.isRunningTest()){
                    claim.DJC_Wellness_Start_Date_of_Activity__c.addError(trm.getDateOutOfPeriodErrorMessage());
                    return this.claim;
                }
            }
            calculateClaimTimeRanges();
            this.timeRange = trm.getCurrentTimeRange(claim.DJC_Wellness_Start_Date_of_Activity__c);
        }
            
        return this.claim;
    }

    private void calculateClaimTimeRanges(){
        
        DJC_Region region = null;

        if(this.claimCase.Division__c != null){
            region = DJC_Wellness_Util.getRegion(this.claimCase.Division__c);
        } else{
            region = DJC_Wellness_Util.getRegion(this.claimCase.Division_Lookup__c);
        }

        DJC_QuarterTimeRangeManager quarterTimeRangeManager = new DJC_QuarterTimeRangeManager(region);
        quarterTimeRangeManager.setContactCountry(contact.ES_DJC_Contact_Country__c);
        DJC_YearTimeRangeManager yearTimeRangeManager = new DJC_YearTimeRangeManager(region);
        yearTimeRangeManager.setContactCountry(contact.ES_DJC_Contact_Country__c);

        claim.DJC_Wellness_Claim_Quarter__c = quarterTimeRangeManager.getCurrentTimeRange(claim.DJC_Wellness_Start_Date_of_Activity__c);
        claim.DJC_Wellness_Claim_Fiscal_Year_Start__c = yearTimeRangeManager.getCurrentTimeRange(claim.DJC_Wellness_Start_Date_of_Activity__c);
    }
}