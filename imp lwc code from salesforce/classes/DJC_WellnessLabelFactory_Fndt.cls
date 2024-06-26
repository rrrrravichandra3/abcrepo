public class DJC_WellnessLabelFactory_Fndt extends DJC_ReimbursementLabelFactory{

    public DJC_WellnessLabelFactory_Fndt(DJC_Region region){
        super(region);
    }
    
    public override String getProviderPopupTitle(){
        return 'Add Wellness Provider';
    }
    
    public override String getProviderNameFieldLabel(){
        return 'Provider Name';
    }
    
    public override String getAddProviderActionLabel(){
        return 'Add Provider';
    }
    
    public override String getPeriodLabel(){
        return 'Request Quarter';
    }
    
    public override String getClaimTotalsThisPeriodLabel(){
        return 'This Quarter';
    }
    
    public override String getClaimTotalsLastPeriodLabel(){
        return 'Last Quarter';
    }

    public override List<String> getConfirmationLabels(){
        ESDJC_Settings__c settings = ESDJC_Settings__c.getOrgDefaults();
        return new String[]{String.format(System.Label.DJC_Wellness_Agreement_Fndt, new String[]{settings.Foundation_Wellness_Policy__c})};
    }
    
    public override String getCaseSubmittedMessage(){
        ESDJC_Settings__c settings = ESDJC_Settings__c.getOrgDefaults();
        return String.format(System.Label.DJC_Wellness_Case_Submitted_Message_Fndt, new String[]{settings.Foundation_Wellness_Policy__c});
    }

    public override String getCaseApprovedMessage(){
        return System.Label.DJC_Wellness_Case_Approved_Message_Fndt;
    }

    public override String getCaseClosedMessage(){
        return System.Label.DJC_Wellness_Case_Closed_Message_Fndt;
    }
}