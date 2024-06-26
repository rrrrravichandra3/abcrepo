public abstract class PF_ReimbursementRequestCategoryHandler {
    
    protected DJC_WellnessManagerFactory managerFactory;
    
    public abstract String getClaimTemplate();
    
    public abstract String getFormName();
    
    public abstract void validateClaims(List<Map<String,Object>> claims);
    
    public abstract Map<String,Object> getCategoryInformation();
    
    public abstract String getCaseType();
    
    public abstract String getTier(DJC_Division division);
    
    public abstract Id getClaimRecordType();
    
    protected abstract List<Map<String,Object>> getClaims(List<DJC_Wellness_Reimbursement_Claim__c> claims);
    
    public Map<String,Object> getCaseInformation(Case reimbursementCase){
        Boolean isAppzenGA = ESDJC_Settings__c.getOrgDefaults().Is_Appzen_GA__c;
        
        Map<String,Object> caseInformation = new Map<String,Object>();
        caseInformation.put('CASEID', reimbursementCase.Id);
        if(isAppzenGA){
            caseInformation.put('EDITABLE', reimbursementCase.Status == 'New');
        }
        else{
            caseInformation.put('EDITABLE', reimbursementCase.Status == 'New' || reimbursementCase.Status == 'Submitted');
        }
        caseInformation.put('STATUS', reimbursementCase.Status == 'Not Processed' ? 'Submitted' : reimbursementCase.Status);
		caseInformation.put('CLAIMS', getClaims(reimbursementCase.Wellness_Reimbursement_Claims__r));
        
        DJC_ReimbursementLabelFactory labelFactory = managerFactory.getLabelFactory();
        
        if(reimbursementCase.Status == 'Approved' || reimbursementCase.Status == 'Approved for Partial Payment'){
	        caseInformation.put('TOP_MESSAGE', labelFactory.getCaseApprovedMessage());
        }else if(reimbursementCase.Status == 'Closed'){
	        caseInformation.put('TOP_MESSAGE', labelFactory.getCaseClosedMessage());
        }else if(reimbursementCase.Status == 'Submitted' || reimbursementCase.Status == 'Not Processed'){
	        caseInformation.put('TOP_MESSAGE', labelFactory.getCaseSubmittedMessage());
        }
        
        Map<Id, List<Attachment>> attachments = DJC_Wellness_Util.getExistingAttachments(reimbursementCase.Wellness_Reimbursement_Claims__r);
        caseInformation.put('ATTACHMENTS', attachments);
        
        return caseInformation;
    }
    
    public PF_ReimbursementRequestCategoryHandler(DJC_WellnessManagerFactory managerFactory){
        this.managerFactory = managerFactory;
    }

    public List<PF_AuraAdditionalInformationItem> getRequestInformation(Reimbursement_Policy__mdt policy, Reimbursement_Category__mdt category, String caseStatus){
        
        List<PF_AuraAdditionalInformationItem> additionalInformation = new List<PF_AuraAdditionalInformationItem>();
        
        DJC_ReimbursementLabelFactory labelFactory = managerFactory.getLabelFactory();
        DJC_TimeRangeManager periodManager = managerFactory.getTimeRangeManager();
        DJC_ClaimManager claimManager = managerFactory.getClaimManager();
        
        PF_AuraAdditionalInformationItem requestInformation = new PF_AuraAdditionalInformationItem('Request Information', 'two');
        requestInformation.addInformationField(labelFactory.getPeriodLabel(), periodManager.getCurrentTimeRange(), PF_AuraAdditionalInformationItem.FieldType.StringField, null, null);
        requestInformation.addInformationField('Request Status', caseStatus == null ? 'New' : caseStatus, PF_AuraAdditionalInformationItem.FieldType.StringField, null, null);
        requestInformation.addInformationField('Request Type', category.MasterLabel, PF_AuraAdditionalInformationItem.FieldType.StringField, null, null);
        requestInformation.addInformationField('Currency', policy.Currency__c, PF_AuraAdditionalInformationItem.FieldType.StringField, null, null);
        
        additionalInformation.add(requestInformation);
        additionalInformation.add(getBalanceInformation(claimManager, labelFactory));
        
        return additionalInformation;
    }
    
    protected abstract PF_AuraAdditionalInformationItem getBalanceInformation(DJC_ClaimManager claimManager, DJC_ReimbursementLabelFactory labelFactory);
}