public abstract class DJC_ReimbursementLabelFactory {
    
    protected DJC_Region region;
    
    public DJC_ReimbursementLabelFactory(DJC_Region region){
        this.region = region;
    }
    
    public abstract String getProviderPopupTitle();
    
    public abstract String getProviderNameFieldLabel();
    
    public abstract String getAddProviderActionLabel();
    
    public abstract String getPeriodLabel();
    
    public abstract String getClaimTotalsThisPeriodLabel();
    
    public abstract String getClaimTotalsLastPeriodLabel();
    
    public abstract List<String> getConfirmationLabels();

    public abstract String getCaseSubmittedMessage();

    public abstract String getCaseApprovedMessage();

    public abstract String getCaseClosedMessage();
}