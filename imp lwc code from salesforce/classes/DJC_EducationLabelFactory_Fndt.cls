public class DJC_EducationLabelFactory_Fndt extends DJC_ReimbursementLabelFactory{

    public DJC_EducationLabelFactory_Fndt(DJC_Region region){
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
        return new String[]{System.Label.DJC_Education_Agreement_Fndt};
    }

    public override String getCaseSubmittedMessage(){
        ESDJC_Settings__c settings = ESDJC_Settings__c.getOrgDefaults();
        return String.format(System.Label.DJC_Education_Case_Submitted_Message_Fndt, new String[]{settings.Foundation_Education_Policy__c});
    }

    public override String getCaseApprovedMessage(){
        return System.Label.DJC_Education_Case_Approved_Message_Fndt;
    }

    public override String getCaseClosedMessage(){
        return System.Label.DJC_Education_Case_Closed_Message_Fndt;
    } 
}