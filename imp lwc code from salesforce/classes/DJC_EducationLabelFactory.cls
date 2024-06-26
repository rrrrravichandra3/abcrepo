public class DJC_EducationLabelFactory extends DJC_ReimbursementLabelFactory{

    public DJC_EducationLabelFactory(DJC_Region region){
        super(region);
    }
    
	public override String getProviderPopupTitle(){
        return 'Add Institution';
    }
    
    public override String getProviderNameFieldLabel(){
        return 'Institution Name';
    }
    
    public override String getAddProviderActionLabel(){
        return 'Add to List';
    }
    
    public override String getPeriodLabel(){
        return 'Request Year';
    }
    
    public override String getClaimTotalsThisPeriodLabel(){
        return 'This Year';
    }
    
    public override String getClaimTotalsLastPeriodLabel(){
        return 'Last Year';
    }
    
    public override List<String> getConfirmationLabels(){
        
        ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
        String policy = settings.Education_Reimbursement_Policy__c;
        
        return new String[]{
            'To claim Education Reimbursement for the current calendar year\'s benefit, claims will need to be submitted by November 30th to be processed for the current year. Claims submitted after November 30th will be deducted from the following year\'s benefit. Please see the Education Reimbursement Policy for full details.',
            'I confirm that as per the <a href="' + policy + '" style="color: #00F;" target="_blank">policy guidelines</a>, my manager approved my attendance of this program.',
            'I confirm that all of the information provided is accurate.'};
    }

    public override String getCaseSubmittedMessage(){
        return System.Label.DJC_Education_Case_Submitted_Message;
    }

    public override String getCaseApprovedMessage(){
        return '';
    }

    public override String getCaseClosedMessage(){
        return '';
    }
}