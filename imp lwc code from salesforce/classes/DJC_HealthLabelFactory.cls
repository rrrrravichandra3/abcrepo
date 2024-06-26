public class DJC_HealthLabelFactory extends DJC_ReimbursementLabelFactory{

    public DJC_HealthLabelFactory(DJC_Region region){
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
        return 'This Year';
    }
    
    public override String getClaimTotalsLastPeriodLabel(){
        return 'Last Year';
    }
    
    public override List<String> getConfirmationLabels(){
        if (region == DJC_Region.EMEA){
            return new String[]{System.Label.DJC_Wellness_Agreement_EMEA};
		}else if(region == DJC_Region.APAC){
            return new String[]{System.Label.DJC_Wellness_Agreement_APAC};
        }else if(region == DJC_Region.JAPAN){
            return new String[]{System.Label.DJC_Wellness_Agreement_Japan};
        }
        return new String[0];
    }

    public override String getCaseSubmittedMessage(){
        if(region == DJC_Region.LACA){
            return System.Label.DJC_Health_Case_Submitted_Message_LACA;
        }else{
            return System.Label.DJC_Health_Case_Submitted_Message;
        }
    }

    public override String getCaseApprovedMessage(){
        return '';
    }

    public override String getCaseClosedMessage(){
        return '';
    }
}