public class PF_ReimbursementEducationCategoryHandler extends PF_ReimbursementRequestCategoryHandler{
    
    private static String FORM_NAME = 'EDUC';
    
    public PF_ReimbursementEducationCategoryHandler(DJC_WellnessManagerFactory managerFactory){
        super(managerFactory);
    }
    
    public override String getClaimTemplate(){
        if(managerFactory.policy.Organization__c == 'Foundation'){
            return '{"sobjectType" : "DJC_Wellness_Reimbursement_Claim__c","DJC_Education_Institution__c" : "","DJC_Reimbursement_Claim_Detail__c" : "","DJC_Education_Policy__c" : "", "DJC_Education_Date_Completed__c" : null,"DJC_Wellness_Amount_Requested__c" : 0.0,"CurrencyIsoCode" : "", "DJC_Education_Course_Description__c" : "", "DJC_Education_Course_Justification__c" : "", "DJC_Wellness_Request_Comments__c" : "","DJC_Education_Taxable__c" : "","DJC_Education_Course_Duration__c" : ""}';
        }
        return '{"sobjectType" : "DJC_Wellness_Reimbursement_Claim__c","DJC_Education_Institution__c" : "","DJC_Reimbursement_Claim_Detail__c" : "","DJC_Education_Policy__c" : "", "DJC_Education_Date_Completed__c" : null,"DJC_Wellness_Amount_Requested__c" : 0.0,"CurrencyIsoCode" : "", "DJC_Wellness_Request_Comments__c" : "","DJC_Education_Taxable__c" : "","DJC_Education_Course_Duration__c" : ""}';
    }
    
    public override String getFormName(){
        
        if(managerFactory.policy.Organization__c == 'Foundation'){
            return 'EDUC_FNDT';
        }

        return FORM_NAME;
    }
    
    public override String getCaseType(){
        return 'Education Reimbursement Request';
    }

    public override String getTier(DJC_Division division){
        if(division == DJC_Division.EMEA || division == DJC_Division.APAC){
            return 'Tier 2';
        }
        return 'Tier 1';
    }
    
    public override Id getClaimRecordType(){
        if(managerFactory.policy.Organization__c == 'Foundation'){
            return Schema.SObjectType.DJC_Wellness_Reimbursement_Claim__c.getRecordTypeInfosByName().get('Foundation Education Claim').getRecordTypeId();
        }
        return Schema.SObjectType.DJC_Wellness_Reimbursement_Claim__c.getRecordTypeInfosByName().get('Education Claim').getRecordTypeId();
    }
    
    public override Map<String,Object> getCategoryInformation(){
        
        Map<String,Object> information = new Map<String,Object>();
        DJC_ReimbursementLabelFactory labelFactory = managerFactory.getLabelFactory();
        DJC_TimeRangeManager periodManager = managerFactory.getTimeRangeManager();
        
        information.put('MIN_COMP_DATE', PF_AuraUtil.getStringFromDate(periodManager.getMinDateInCurrentPeriod()));
        information.put('MAX_COMP_DATE', PF_AuraUtil.getStringFromDate(periodManager.getMaxDateInCurrentPeriod()));
        information.put('CAT_NAME', managerFactory.category.MasterLabel);
        information.put('CONFIRMATION_TEXT', labelFactory.getConfirmationLabels());
        information.put('THANKYOU_TEXT', labelFactory.getCaseSubmittedMessage());
        
        return information;
    }
    
    protected override PF_AuraAdditionalInformationItem getBalanceInformation(DJC_ClaimManager claimManager, DJC_ReimbursementLabelFactory labelFactory){
        
        PF_AuraAdditionalInformationItem requestInformation = new PF_AuraAdditionalInformationItem('Balance', 'one');
        
        requestInformation.addInformationField(labelFactory.getClaimTotalsThisPeriodLabel() + ' Claim Totals' , claimManager.getClaimsForCurrentTimeRange(), PF_AuraAdditionalInformationItem.FieldType.NumberField, '0.00', Label.DJC_Education_reimbursement_claim_amount_help_text);
        requestInformation.addInformationField(labelFactory.getClaimTotalsThisPeriodLabel() + ' Balance' , claimManager.getBalanceForCurrentTimeRange(), PF_AuraAdditionalInformationItem.FieldType.NumberField, '0.00', Label.DJC_Education_reimbursement_available_balance_help_text);
        
        return requestInformation;
    }
    
    protected override List<Map<String,Object>> getClaims(List<DJC_Wellness_Reimbursement_Claim__c> claims){
        
        List<Map<String,Object>> claimMaps = new List<Map<String,Object>>();
        
        for(DJC_Wellness_Reimbursement_Claim__c claim:claims){
            Map<String,Object> claimMap = new Map<String,Object>();
            claimMap.put('sobjectType', 'DJC_Wellness_Reimbursement_Claim__c');
            claimMap.put('Id', claim.Id);
            claimMap.put('DJC_Education_Institution__c', claim.DJC_Education_Institution__c);
            claimMap.put('DJC_Reimbursement_Claim_Detail__c', claim.DJC_Reimbursement_Claim_Detail__c);
            claimMap.put('DJC_Education_Policy__c', claim.DJC_Education_Policy__c);
            claimMap.put('DJC_Education_Date_Completed__c', PF_HelperAuraServices.getDateAsString(claim.DJC_Education_Date_Completed__c));
            claimMap.put('DJC_Wellness_Amount_Requested__c', claim.DJC_Wellness_Amount_Requested__c);
            claimMap.put('CurrencyIsoCode', claim.CurrencyIsoCode);
            claimMap.put('DJC_Wellness_Request_Comments__c', claim.DJC_Wellness_Request_Comments__c);
            claimMap.put('DJC_Wellness_Request_Status__c', claim.DJC_Wellness_Request_Status__c);
            claimMap.put('DJC_Education_Taxable__c', claim.DJC_Education_Taxable__c);
            claimMap.put('DJC_Education_Course_Duration__c', claim.DJC_Education_Course_Duration__c);
            
            if(managerFactory.policy.Organization__c == 'Foundation'){
                claimMap.put('DJC_Education_Course_Description__c', claim.DJC_Education_Course_Description__c);
                claimMap.put('DJC_Education_Course_Justification__c', claim.DJC_Education_Course_Justification__c);
            }

            claimMaps.add(claimMap);
        }
        
        return claimMaps;
    }
    
    public override void validateClaims(List<Map<String,Object>> claims){
        
    }
    
}