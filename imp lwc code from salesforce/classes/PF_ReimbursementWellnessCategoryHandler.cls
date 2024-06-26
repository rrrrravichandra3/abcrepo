public class PF_ReimbursementWellnessCategoryHandler extends PF_ReimbursementRequestCategoryHandler{
    
    private static String FORM_NAME = 'WELL';
    
    public PF_ReimbursementWellnessCategoryHandler(DJC_WellnessManagerFactory managerFactory){
        super(managerFactory);
    }
    
    public override String getClaimTemplate(){
        return '{"sobjectType" : "DJC_Wellness_Reimbursement_Claim__c","DJC_Wellness_Activity__c" : "","DJC_Wellness_Provider__c" : "","DJC_Wellness_Start_Date_of_Activity__c" : null,"DJC_Wellness_End_Date_of_Activity__c" : null,"DJC_Wellness_Amount_Requested__c" : 0.0,"CurrencyIsoCode" : "","DJC_Wellness_Request_Comments__c" : ""}';
    }
    
    public override String getFormName(){
        return FORM_NAME;
    }
    
    public override String getCaseType(){
        return 'Wellness Reimbursement Request';
    }
    
    public override Id getClaimRecordType(){
        if(managerFactory.policy.Organization__c == 'Foundation'){
            return Schema.SObjectType.DJC_Wellness_Reimbursement_Claim__c.getRecordTypeInfosByName().get('Foundation Wellness Claim').getRecordTypeId();
        }
        return Schema.SObjectType.DJC_Wellness_Reimbursement_Claim__c.getRecordTypeInfosByName().get('Wellness Claim').getRecordTypeId();
    }
    
    public override String getTier(DJC_Division division){
        if(division == DJC_Division.EMEA){
            return 'Tier 2';
        }
        return 'Tier 1';
    }
    
    public override Map<String,Object> getCategoryInformation(){
        
        Map<String,Object> information = new Map<String,Object>();
        DJC_ReimbursementLabelFactory labelFactory = managerFactory.getLabelFactory();
        DJC_TimeRangeManager periodManager = managerFactory.getTimeRangeManager();
        
        Date minActivityDate = periodManager.getMinDateInCurrentPeriod();
        Date maxActivityDate = periodManager.getMaxDateInCurrentPeriod();

        information.put('MIN_ACT_DATE', PF_AuraUtil.getStringFromDate(minActivityDate));
        information.put('MAX_ACT_DATE', PF_AuraUtil.getStringFromDate(maxActivityDate));
        
        maxActivityDate = maxActivityDate.addYears(3);
        
        information.put('MIN_ACT_TO_DATE', PF_AuraUtil.getStringFromDate(minActivityDate));
        information.put('MAX_ACT_TO_DATE', PF_AuraUtil.getStringFromDate(maxActivityDate));
        information.put('CAT_NAME', managerFactory.category.MasterLabel);
        information.put('CONFIRMATION_TEXT', labelFactory.getConfirmationLabels());
        information.put('THANKYOU_TEXT', labelFactory.getCaseSubmittedMessage());

        return information;
    }
    
    protected override List<Map<String,Object>> getClaims(List<DJC_Wellness_Reimbursement_Claim__c> claims){
        
        List<Map<String,Object>> claimMaps = new List<Map<String,Object>>();
        
        for(DJC_Wellness_Reimbursement_Claim__c claim:claims){
            Map<String,Object> claimMap = new Map<String,Object>();
            claimMap.put('sobjectType', 'DJC_Wellness_Reimbursement_Claim__c');
            claimMap.put('Id', claim.Id);
            claimMap.put('DJC_Wellness_Activity__c', claim.DJC_Wellness_Activity__c);
            claimMap.put('DJC_Wellness_Provider__c', claim.DJC_Wellness_Provider__c);
            claimMap.put('DJC_Wellness_Start_Date_of_Activity__c', PF_HelperAuraServices.getDateAsString(claim.DJC_Wellness_Start_Date_of_Activity__c));
            claimMap.put('DJC_Wellness_End_Date_of_Activity__c', PF_HelperAuraServices.getDateAsString(claim.DJC_Wellness_End_Date_of_Activity__c));
            claimMap.put('DJC_Wellness_Amount_Requested__c', claim.DJC_Wellness_Amount_Requested__c);
            claimMap.put('CurrencyIsoCode', claim.CurrencyIsoCode);
            claimMap.put('DJC_Wellness_Request_Comments__c', claim.DJC_Wellness_Request_Comments__c);
            claimMap.put('DJC_Wellness_Request_Status__c', claim.DJC_Wellness_Request_Status__c);
            
            claimMaps.add(claimMap);
        }
        
        return claimMaps;
    }
    
    protected override PF_AuraAdditionalInformationItem getBalanceInformation(DJC_ClaimManager claimManager, DJC_ReimbursementLabelFactory labelFactory){
        
        PF_AuraAdditionalInformationItem requestInformation = new PF_AuraAdditionalInformationItem('Balance', 'two');
        
        requestInformation.addInformationField(labelFactory.getClaimTotalsThisPeriodLabel() + ' Claim Totals' , claimManager.getClaimsForCurrentTimeRange(), PF_AuraAdditionalInformationItem.FieldType.NumberField, '0.00', null);
        requestInformation.addInformationField(labelFactory.getClaimTotalsThisPeriodLabel() + ' Balance' , claimManager.getBalanceForCurrentTimeRange(), PF_AuraAdditionalInformationItem.FieldType.NumberField, '0.00', null);
        
        requestInformation.addInformationField(labelFactory.getClaimTotalsLastPeriodLabel() + ' Claim Totals' , claimManager.getClaimsForPreviousTimeRange(), PF_AuraAdditionalInformationItem.FieldType.NumberField, '0.00', null);
        requestInformation.addInformationField(labelFactory.getClaimTotalsLastPeriodLabel() + ' Balance' , claimManager.getBalanceForPreviousTimeRange(), PF_AuraAdditionalInformationItem.FieldType.NumberField, '0.00', null);
        
        return requestInformation;
    }
    
    public override void validateClaims(List<Map<String,Object>> claims){
        
    }
    
}