public class DJC_Wellness_Controller extends BaseDJCController {

    private static final Integer MAX_CLAIM_RECORDS = 10;
    
    private DJC_Wellness_Health_Policy__c policy{get; set;}
    
    private DJC_Wellness_Category__c  category{get; set;}
    
    private DJC_Region region{get; set;}
    
    public boolean[] renderClaim {get;set;}
    
    public Integer visibleIndex{get;set;}
    
    public DJC_Wellness_Controller() {

        super();
        Id caseId = ApexPages.currentPage().getParameters().get('caseId');
        String edit  = ApexPages.currentPage().getParameters().get('edit');
        editMode = (String.isNotEmpty(edit) && (Decimal.valueOf(edit) == 1));
        region = DJC_Wellness_Util.getRegion(division);

        visibleIndex = 0;

        Integer claimsSize = 1;
        
        if (String.isNotEmpty(caseId)) {
            newCase = DJC_Wellness_Util.getWellnessCaseById(caseId);
            claimsSize = newCase.Wellness_Reimbursement_Claims__r.size();
            headermsg = newCase.DJC_Wellness_Category__r.name + ' Reimbursement Request';
            editMode = editMode && isCaseStatusEditable;
            loadPolicyAndCategoryFromCase();
        } else {
            newCase.status = 'New';
            editMode = true;
            
            if(!isblank(ApexPages.currentPage().getParameters().get('policyId'))){
                //policy = DJC_Wellness_Util.getWellnessPolicyById(ApexPages.currentPage().getParameters().get('policyId'));
            }
            if(!isblank(ApexPages.currentPage().getParameters().get('categoryId'))){
                //category = DJC_Wellness_Util.getWellnessCategoryById(ApexPages.currentPage().getParameters().get('categoryId'));
            }
            
            headermsg = category.name + ' Reimbursement Request';
            newCase.ES_DJC_Sub_Topic__c = timeRangeManager.getCurrentTimeRange();
        }
        renderClaimWidgets(claimsSize);
    }
    
    public String getCategoryForm(){
        return this.category.Form__c;
    }

    public String getCategoryGroup(){
        return this.category.Group__c;
    }
    
    private void renderClaimWidgets(Integer claimsSize) {                
        renderClaim = new boolean[MAX_CLAIM_RECORDS];
        renderClaim[0] = true;
        for (integer i = 1; i < claimsSize ; i++) {
            renderClaim[i] = true;
        }
        for (integer i = claimsSize; i < MAX_CLAIM_RECORDS; i++) {
            renderClaim[i] = false;
        }            
    }
    
    private DJC_WellnessManagerFactory wellnessManagerFactory{
        get{
            if(wellnessManagerFactory == null){
                //wellnessManagerFactory = DJC_WellnessManagerFactory.getInstance(region, policy, currentUser.Contact);
            }
            return wellnessManagerFactory;
        }
        private set;
    }
    
    public DJC_ClaimManager claimManager{
        get{
            if(claimManager == null){
                claimManager = wellnessManagerFactory.getClaimManager();
            }
            return claimManager;
        }
        private set;
    }
    
    private DJC_TimeRangeManager timeRangeManager{
        get{
            if(timeRangeManager == null){
                timeRangeManager = wellnessManagerFactory.getTimeRangeManager();
            }
            return timeRangeManager;
        }
        private set;
    }
    
    public DJC_ReimbursementLabelFactory labelFactory{
        get{
            if(labelFactory == null){
                labelFactory = wellnessManagerFactory.getLabelFactory();
            }
            return labelFactory;
        }
        private set;
    }
    
    public Boolean isCaseStatusEditable{
        get{
            return !(newCase.IsClosed || newCase.Status.equalsIgnoreCase('Approved')
            || newCase.Status.equalsIgnoreCase('Approved for Partial Payment')
            || newCase.Status.equalsIgnoreCase('Extracted for Payment'));
        }
        private set;
    }
    
    public String defaultCurrencyCode {get {return policy.CurrencyIsoCode;} private set;}
    
    public String requestQuarter{
        get{
            if(category.Group__c == 'Education'){
                return timeRangeManager.getCurrentTimeRange(System.today());
            }else{
                return timeRangeManager.getQuarter(System.today());
            }
        } private set;
    }
    
    public String timeRange{get{return policy.Time_Range__c;} private set;}
    
    public Boolean agreementAccepted{get;set;}
    
    public Boolean informationProvidedAccurate{get;set;}
    
    public String agreementLabelName{get{return 'DJC_Wellness_Agreement_' + region.name();} private set;}
    
    private List<DJC_Wellness_Reimbursement_Claim__c> claimsToDelete = new List<DJC_Wellness_Reimbursement_Claim__c>();
    
    private void loadPolicyAndCategoryFromCase(){
        if(newCase.DJC_Wellness_Category__r != null){
            //category = DJC_Wellness_Util.getWellnessCategoryById(newCase.DJC_Wellness_Category__r.Id);
        }
        if(newCase.DJC_Wellness_Health_Policy__r != null){
            //policy = DJC_Wellness_Util.getWellnessPolicyById(newCase.DJC_Wellness_Health_Policy__r.Id);
        }
    }
    
    public DJC_Wellness_Controller controller {get{return this;} private set;}
    
    public boolean editMode {get; set;}
    
    public Boolean policyAllowed{
        get{
            return currentUser.Contact.ES_DJC_Contact_Country__c != null && policy.DJC_Wellness_Country__c != null
          && currentUser.Contact.ES_DJC_Contact_Country__c == policy.DJC_Wellness_Country__r.Name;
        }

        private set;
    }

    public Integer selectedClaimIndex{get;set;}
    
    public void addMore(){
        renderClaim[visibleIndex] = true;
    }
    
    public override string getRecordType() {
        return [SELECT Id, developername FROM RecordType where developername = 'All_Expense_Cases'].id;
    }
    
    private RecordType claimRecordType{
        get{
            if(claimRecordType == null){
                if(getCategoryGroup() == 'Education'){
                    claimRecordType = [SELECT Id, developername FROM RecordType where developername = 'Education_Claim'];
                }else{
                    claimRecordType = [SELECT Id, developername FROM RecordType where developername = 'Wellness_Claim'];
                }
            }
            return claimRecordType;
        }
        set;
    }

    public String claimPolicyText{get;set;}
    
    public override void setType() {
        super.setType();           
        newCase.status = 'New';
    }

    public List<SelectOption> providers {
        get {
            if (providers == null) {
                providers = new List<SelectOption>();     
                providers.add(new SelectOption('','--SELECT--'));
                
                for (DJC_Wellness_Provider__c sobj : [select id, name from DJC_Wellness_Provider__c where DJC_Contact__c = :currentUser.contactId and Category__c = :getCategoryGroup() order by name]) {
                    providers.add(new SelectOption(sobj.id, sobj.name));                    
                }
            }
            return providers;
        }                           
        set;
    }
    
    
    public String getUrl() {
        return ESDJC_Util.getSSOURL()+'/apex/DJC_ES_Reimbursement_Request?thanks=';
    }

    public Integer claimsCount{
        get{
            return claims.size();
        }
        private set;
    }
    
    public List<DJC_Wellness_Claim> claims {
        get {
            if (claims == null) {
                
                claims = new List<DJC_Wellness_Claim>();
                Map<Id,List<Attachment>>  existingAttachments = DJC_Wellness_Util.getExistingAttachments(newCase.Wellness_Reimbursement_Claims__r);
                if (newCase.Wellness_Reimbursement_Claims__r != null) {
                    for (DJC_Wellness_Reimbursement_Claim__c existingClaim : newCase.Wellness_Reimbursement_Claims__r) {                        
                        claims.add(new DJC_Wellness_Claim(existingClaim, false, existingAttachments.get(existingClaim.Id), policy.CurrencyIsoCode));
                    }
                }
                for (integer i = claims.size(); i < MAX_CLAIM_RECORDS; i++) {
                    claims.add(new DJC_Wellness_Claim(new DJC_Wellness_Reimbursement_Claim__c(), true, defaultCurrencyCode));
                }
            }
            return claims;
        }
        set;
    }

    public String providerName {
        get;        
        set;
    }
    public boolean displayProviderPopUp {
        get;         
        set;
    }
    
    public void addProvider() {
        displayProviderPopUp = true;        
    }
    
    public void hideProvider() {
        displayProviderPopUp = false;
    }    
    
    public void updateProviderSettings() {
        displayProviderPopUp = false;
        DJC_Wellness_Provider__c provider = new DJC_Wellness_Provider__c();
        provider.Name = providerName;
        provider.DJC_Contact__c = currentUser.contactId;
        provider.Category__c = getCategoryGroup();
        insert provider;
        if (providers.size() > 1) {
            providers.add(1,new SelectOption(provider.Id, provider.Name));          
        } else {
            providers.add(new SelectOption(provider.Id, provider.Name));          
        }        
        providerName = null;
    }
    
    public void deleteClaim() {
        renderClaim[visibleIndex] = false;
    }
    
    public PageReference doSubmit() {
        try{
            
            Boolean errorsFound = false;
            
            if (!agreementAccepted) {
                if(getCategoryGroup() == 'Education'){
	                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please confirm the Education Reimbursement policy.'));                    
                }else{
	                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please confirm the ' + region + ' Reimbursement policy.'));
                }
				errorsFound = true;
            }
            if(getCategoryGroup() == 'Education' && !informationProvidedAccurate){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please confirm the information provided is accurate.'));
                errorsFound = true;
            }
            
            upsertCaseAndClaims('Submitted', errorsFound);
            
            if(errorsFound){
                return null;
            }
            
        } catch(exception ex) {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            System.debug('Error submitting reimbursement claim '+ex.getMessage());
            return null;
        }
        PageReference pg = new PageReference('/apex/DJC_ES_Requests');
        pg.getParameters().put('thanks', 'true');
        pg.setRedirect(true);
        return pg;     
    }
    
    public PageReference doSave() {
        try{
            upsertCaseAndClaims('Saved', false);
        } catch(exception ex) {
            System.debug('Error saving reimbursement claim '+ex.getMessage());
            return null;
        }
        PageReference pg = new PageReference('/apex/DJC_ES_Reimbursement_Request?caseId='+newCase.id);
        pg.getParameters().put('message', 'Successfully Saved');
        pg.setRedirect(true);
        return pg;        
    }
   
    private void upsertCaseAndClaims(string status, Boolean onlyValidation) {
        Savepoint wellnessSp = Database.setSavepoint();
        if(!onlyValidation){
	        newCase.status = status;
        }
        boolean isInserted = false;
        try{            
            newCase.setOptions(ESDJC_Util.getAssignmentRulesDMLOption(null));                                
            if (Status == 'Submitted') {
                if(getCategoryGroup() != 'Education'){
                    if (region == DJC_Region.APAC) {
                        newCase.Tier__c = 'Tier 1';
                    }
                    else if (region == DJC_Region.EMEA) {
                        newCase.Tier__c = 'Tier 2';
                    }
                }else{
                    newCase.Tier__c = 'Tier 1';
                }
            }
			
            if(!onlyValidation){
            
                if (newCase.id == null) {
                    newCase.subject = headermsg+' for '+contactName;
                    if(getCategoryGroup() == 'Education'){
                        newCase.Type = 'Education Reimbursement Request';
                    }else{
                        newCase.Type = 'Wellness Reimbursement Request';
                    }
                    newCase.DJC_Wellness_Health_Policy__c = policy.Id;
                    newCase.DJC_Wellness_Category__c = category.Id;
                    newCase.ES_DJC_Topic__c = category.name;
                    newCase.currencyIsoCode = policy.CurrencyIsoCode;
                    newCase.Division__c = currentUser.Contact.Division__c;
                    newCase.origin = 'Employee Success - Web';
                    insert newCase;
                    isInserted = true;
                } else {
                    update newCase;
                }
            }
                
            List<DJC_Wellness_Reimbursement_Claim__c> claimsToBeSaved = new List<DJC_Wellness_Reimbursement_Claim__c>();            
            List<DJC_Wellness_Reimbursement_Claim__c> claimsToBeDeleted = new List<DJC_Wellness_Reimbursement_Claim__c>();            
            List<Attachment> attachments = new List<Attachment>();
            
            Boolean validClaims = true;
            
            for (integer i = 0; i < MAX_CLAIM_RECORDS; i++) {
                if (renderClaim[i] == null) {
                    continue;
                }                            
                if (!renderClaim[i]) {
                    if (!claims[i].isNew) {
                        claimsToBeDeleted.add(claims[i].claim);
                    }                        
                }
                
                Boolean filesAreValidForAllTheClaims = true;
                
                if (renderClaim[i]) {
                    
                    Boolean validClaim = validateClaim(claims[i]);
                    
                    if (!claims[i].validateAttachments()) {
                        if(filesAreValidForAllTheClaims){
                            if(getCategoryGroup() == 'Education'){
								ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please upload confirmation of completion for all the claims.'));
                            }else{
								ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please upload receipts for all the claims.'));
                            }
                        }
                        filesAreValidForAllTheClaims = false;
						validClaim = false;
                    }
                    
                    validClaims = validClaims && validClaim;
                    
                    if(validClaim){
                        if (claims[i].isNew) {
                            claims[i].claim.DJC_Wellness_Case__c = newCase.id;
                        }    
                        claims[i].claim.DJC_Wellness_Claim_Last_Submitted__c = system.today();
                        claims[i].claim.DJC_Wellness_Request_Status__c = status;
                        claims[i].claim.recordTypeId = claimRecordType.Id;
                        claimsToBeSaved.add(claims[i].claim);
                    }
                }
            }
            if(!onlyValidation){
                if(validClaims){
                    
                    delete claimsToBeDeleted;
                    upsert claimsToBeSaved;
                    
                    if(claimsToBeSaved.isEmpty()){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'At least one claim must be added to the request'));
                        throw new ApplicationException('At least one claim must be added to the request');
                    }
                    
                    for (integer i = 0; i < MAX_CLAIM_RECORDS; i++) {
                        if ((renderClaim[i] != null) && renderClaim[i]) {
                            Attachment attachmentRec = claims[i].getNewAttachment();
                            if (attachmentRec != null) {
                                attachments.add(attachmentRec);    
                            }                    
                        }
                    }
                    if (!attachments.isEmpty()) {
                        insert(attachments);
                    }
                }else{
                    throw new ApplicationException('Errors found when validating claims');
                }
            }
        }catch (Exception e){
            system.debug('DML Error '+e.getMessage()+' cause: '+e.getCause());
            Database.rollback(wellnessSp);
            if (isInserted) {
                newCase.id = null;
                newCase.status = 'New';
            }
            throw new ApplicationException(e.getMessage());
        }        
    }
    
    private Boolean validateClaim(DJC_Wellness_Claim claimToValidate){
        
        Boolean result = true;
        
        if(getCategoryGroup() == 'Education'){
            if(isBlank(claimToValidate.claim.DJC_Education_Institution__c)){
                claimToValidate.claim.DJC_Education_Institution__c.addError('Please select an institution.');
                result = false;
            }
            if(!isBlank(claimToValidate.claim.DJC_Education_Policy__c)){
                if(isBlank(claimToValidate.claim.DJC_Reimbursement_Claim_Detail__c)){
                    claimToValidate.claim.DJC_Reimbursement_Claim_Detail__c.addError('Please provide the course name.');
					result = false;
                }
            }
            if (isBlank(claimToValidate.claim.DJC_Education_Date_Completed__c)) {
                claimToValidate.claim.DJC_Education_Date_Completed__c.addError('Please provide the date completed.');
                result = false;
            }else if(claimToValidate.claim.DJC_Education_Date_Completed__c > System.today()){
                claimToValidate.claim.DJC_Education_Date_Completed__c.addError('Please submit for a claim with a completed date of today or in the past.');
                result = false;
            }            
        }else{
            if(getCategoryGroup() == 'Wellness'){
                
                if(isBlank(claimToValidate.claim.DJC_Wellness_Activity__c)){
                    claimToValidate.claim.DJC_Wellness_Activity__c.addError('Please select a wellness activity.');
                    result = false;
                }
                    
                if(isBlank(claimToValidate.claim.DJC_Wellness_Provider__c)){
                    claimToValidate.claim.DJC_Wellness_Provider__c.addError('Please select a provider.');
                    result = false;
                }
            }
            if (isBlank(claimToValidate.claim.DJC_Wellness_Start_Date_of_Activity__c)) {
                claimToValidate.claim.DJC_Wellness_Start_Date_of_Activity__c.addError('Please provide a date of activity.');
                result = false;
            }
        }
        
        if (isBlank(claimToValidate.claim.DJC_Wellness_Amount_Requested__c)) {
            claimToValidate.claim.DJC_Wellness_Amount_Requested__c.addError('Please provide the amount requested for reimbursement.');
			result = false;
        }
        
        return result;
    }
    
    public PageReference doEdit() {
        return goToPage('/apex/DJC_ES_Reimbursement_Request?edit=1&caseId='+newCase.id);
    }
    
    public PageReference doCancel() {
        return goToPage('/apex/DJC_ES_Requests');
    }
    
    private PageReference goToPage(String url) {
        PageReference pg = new PageReference(url);            
        pg.setRedirect(true);
        return pg;        
    }
}