public with sharing class PFReimbursementRequestAuraService {
    
    @AuraEnabled
    public static User getCurrentUser(){
        
        List<User> users = [select contactid, contact.Division__c, contact.ES_DJC_Work_Location__c, contact.ES_DJC_Contact_Country__c,
                            contact.DJC_Contact_Floor__c,contact.DJC_Contact_Building__c, contact.DJC_Contact_Cube_Workstation__c, Contact.Name, Contact.recordType.name,
                            Contact.Email, Contact.Phone, Contact.Department,Contact.Start_Date__c
                            from user where id = :UserInfo.getUserId()];
        
        if(users.isEmpty()){
            throw new AuraHandledException('User not found');
        }
        return users.get(0);
    }
    
    @AuraEnabled
    public static Reimbursement_Policy__mdt getReimbursementPolicyById(Integer policyId){
        
        Reimbursement_Policy__mdt policy = DJC_Wellness_Util.getWellnessPolicyById(policyId);
        
        if(policy == null){
            throw new AuraHandledException('Reimbursement policy not found');
        }
        return policy;
    }
    
    @AuraEnabled
    public static Reimbursement_Category__mdt getReimbursementCategoryById(Integer categoryId){
        
        Reimbursement_Category__mdt category = DJC_Wellness_Util.getWellnessCategoryById(categoryId);
        
        if(category == null){
            throw new AuraHandledException('Reimbursement category not found');
        }
        
        return category;
    }
    
    @AuraEnabled
    public static String getRequestPeriod(String categoryGroup, String division, Date referenceDate){
        
        DJC_TimeRangeManager timeRangeManager = getTimeRangeManager(categoryGroup, DJC_Wellness_Util.getRegion(division));
        return timeRangeManager.getCurrentTimeRange(referenceDate);
    }
    
    @AuraEnabled
    public static String getRequestPeriodForCurrentDate(String categoryGroup, String division){
        DateTime currentDateTime = System.now();
        return getRequestPeriod(categoryGroup, division, Date.newInstance(currentDateTime.year(), currentDateTime.month(), currentDateTime.day()));
    }
    
    @AuraEnabled
    public static Map<String,Decimal> getBalance(Integer policyId, Integer categoryId, String contactId){
        
        Contact currentContact = getCurrentUser().Contact;
        
        DJC_ClaimManager claimManager = getClaimManager(DJC_Wellness_Util.getRegion(currentContact.Division__c),
                                                        DJC_Wellness_Util.getWellnessPolicyById(policyId),
                                                        DJC_Wellness_Util.getWellnessCategoryById(categoryId),
                                                        currentContact);
        
        Map<String,Decimal> balance = new Map<String,Decimal>();
        
        balance.put('CPCT', claimManager.getClaimsForCurrentTimeRange());
        balance.put('CPB', claimManager.getBalanceForCurrentTimeRange());
        balance.put('LPCT', claimManager.getClaimsForPreviousTimeRange());
        balance.put('LPB', claimManager.getBalanceForPreviousTimeRange());
        
        return balance;
    }
    
    private static DJC_WellnessManagerFactory getWellnessManagerFactory(DJC_Region region, Reimbursement_Policy__mdt policy,
                                                                        Reimbursement_Category__mdt category, Contact contact){
        return DJC_WellnessManagerFactory.getInstance(region, policy, category, contact);
    }
    
    private static DJC_ClaimManager getClaimManager(DJC_Region region, Reimbursement_Policy__mdt policy,
                                                    Reimbursement_Category__mdt category, Contact contact){
        return getWellnessManagerFactory(region, policy, category, contact).getClaimManager();
    }
    
    private static DJC_TimeRangeManager getTimeRangeManager(String categoryGroup, DJC_Region region){
        
        User currentUser = getCurrentUser();
        
        String organization = 'Salesforce';
            
        if(currentUser.contact.Department != null &&
          ESDJC_Util.isFoundationDepartment(currentUser.contact.Department)){
            organization = 'Foundation';
        }
        
        if(organization.equals('Salesforce')){
            if(categoryGroup.equalsIgnoreCase(DJC_Wellness_Type.WELLNESS.name())){
                return new DJC_QuarterTimeRangeManager(region);
            }else if(categoryGroup.equalsIgnoreCase(DJC_Wellness_Type.HEALTH.name())){
                return new DJC_YearTimeRangeManager(region);
            }else if(categoryGroup.equalsIgnoreCase(DJC_Wellness_Type.EDUCATION.name())){
                return new DJC_YearEducationTimeRangeManager(region);
            }
        }else if(organization.equals('Foundation')){
            if(categoryGroup.equalsIgnoreCase(DJC_Wellness_Type.WELLNESS.name())){
                return new DJC_WellnessTimeRangeManager_Fndt(region);
            }else if(categoryGroup.equalsIgnoreCase(DJC_Wellness_Type.HEALTH.name())){
                return null;
            }else if(categoryGroup.equalsIgnoreCase(DJC_Wellness_Type.EDUCATION.name())){
                return new DJC_YearEducationTimeRangeManager_Fndt(region);
            }
        }
        return null;
    }
    
    private static DJC_ReimbursementLabelFactory getLabelFactory(DJC_Region region, Reimbursement_Policy__mdt policy,
                                                                        Reimbursement_Category__mdt category, Contact contact){
        return getWellnessManagerFactory(region, policy, category, contact).getLabelFactory();
    }
    
    @AuraEnabled
    public static List<Case> getMyCases(String status){
        
        String soql = 'SELECT Id, CaseNumber, Subject, Status, LastModifiedDate FROM Case WHERE ContactId = \'' + getCurrentUser().ContactId + '\' AND RecordType.DeveloperName = \'All_Expense_Cases\' ';
        
        if(status == 'open'){
            soql += ' AND isClosed = false ';
        }else if(status == 'closed'){
            soql += ' AND isClosed = true ';
        }
        
        soql += 'ORDER BY createdDate DESC';
        
        return Database.query(soql);
    }
    
    @AuraEnabled
    public static List<SelectOption> getCurrencyOptions(){
        
        List<Schema.PicklistEntry> entries = DJC_Wellness_Reimbursement_Claim__c.CurrencyIsoCode.getDescribe().getPicklistValues();
        List<SelectOption> options = new List<SelectOption>();
        
        for(Schema.PicklistEntry entry : entries){
            options.add(new SelectOption(entry.getLabel(), entry.getValue()));
        }
        
        return options;
    }
    
    @AuraEnabled
    public static List<SelectOption> getWellnessActivities(){
        
        List<Schema.PicklistEntry> entries = DJC_Wellness_Reimbursement_Claim__c.DJC_Wellness_Activity__c.getDescribe().getPicklistValues();
        List<SelectOption> options = new List<SelectOption>();
        
        for(Schema.PicklistEntry entry : entries){
            options.add(new SelectOption(entry.getLabel(), entry.getValue()));
        }
        
        return options;
    }
    
    @AuraEnabled
    public static List<Provider> getProviders(String categoryGroup){
        
        Map<Id,Provider> providers = new Map<Id,Provider>();
        
        for (DJC_Wellness_Provider__c sobj : [select id, name from DJC_Wellness_Provider__c where DJC_Contact__c = :getCurrentUser().contactId and Category__c = :categoryGroup order by name]) {
            providers.put(sobj.Id, new Provider(sobj.name, sobj.id));
        }

        if(categoryGroup == 'Education'){
            for(AggregateResult count : [SELECT Count(Id) numClaims, DJC_Education_Institution__c FROM DJC_Wellness_Reimbursement_Claim__c WHERE DJC_Education_Institution__c  IN :providers.keySet() GROUP BY DJC_Education_Institution__c]){
                if(((Integer)count.get('numClaims')) > 0){
                    providers.get((Id)count.get('DJC_Education_Institution__c')).removable = false;
                }
            }
        }else{   
            for(AggregateResult count : [SELECT Count(Id) numClaims, DJC_Wellness_Provider__c FROM DJC_Wellness_Reimbursement_Claim__c WHERE DJC_Wellness_Provider__c IN :providers.keySet() GROUP BY DJC_Wellness_Provider__c]){
                if(((Integer)count.get('numClaims')) > 0){
                    providers.get((Id)count.get('DJC_Wellness_Provider__c')).removable = false;
                }
            }
        }
        
        return providers.values();
    }
    
    @AuraEnabled
    public static List<ClaimPolicy> getPolicies(){
        
        List<ClaimPolicy> policies = new List<ClaimPolicy>();
        
        User currentUser = getCurrentUser();

        String organization = 'Salesforce';

        if(currentUser.contact.Department != null &&
         ESDJC_Util.isFoundationDepartment(currentUser.contact.Department)){
            organization = 'Foundation';
        }

        for(Reimbursement_Policy__mdt policy : [SELECT Id__c, Currency__c FROM Reimbursement_Policy__mdt WHERE Country__c = :currentUser.contact.ES_DJC_Contact_Country__c AND Active__c = true AND Organization__c = :organization]){
            for(Reimbursement_Category_Policy_Assoc__mdt association : 
                [SELECT Category_Id__c FROM Reimbursement_Category_Policy_Assoc__mdt WHERE Policy_Id__c = :policy.Id__c and IsTaxable__c = FALSE]){
                    
                    Reimbursement_Category__mdt category = [SELECT MasterLabel FROM Reimbursement_Category__mdt WHERE Id__c = :association.Category_Id__c];
                    policies.add(new ClaimPolicy(category.MasterLabel, policy.Id__c.intValue(), association.Category_Id__c.intValue()));
            }
        }
        
        return policies;
    }
    
    @AuraEnabled
    public static Map<String,String> getBalanceLabels(Integer policyId, Integer categoryId){

        Contact currentContact = getCurrentUser().Contact;
        
        DJC_ReimbursementLabelFactory labelFactory = getLabelFactory(DJC_Wellness_Util.getRegion(currentContact.Division__c),
                                                                     DJC_Wellness_Util.getWellnessPolicyById(policyId),
                                                                     DJC_Wellness_Util.getWellnessCategoryById(categoryId),
                                                                     currentContact);
        
        Map<String,String> balanceLabels = new Map<String,String>();
        
        balanceLabels.put('PL', labelFactory.getPeriodLabel());
        balanceLabels.put('CTTPL', labelFactory.getClaimTotalsThisPeriodLabel());
        balanceLabels.put('CTLPL', labelFactory.getClaimTotalsLastPeriodLabel());
        
        return balanceLabels;
    }
    
    @AuraEnabled
    public static void saveProviders(List<DJC_Wellness_Provider__c> providerList, List<DJC_Wellness_Provider__c> removedProviders){
        
        User currentUser = getCurrentUser();
        
        List<DJC_Wellness_Provider__c> newProviders = new List<DJC_Wellness_Provider__c>();
        List<DJC_Wellness_Provider__c> providersToUpdate = new List<DJC_Wellness_Provider__c>();
        
        for(DJC_Wellness_Provider__c provider:providerList){
            
            provider.DJC_Contact__c = currentUser.contactId;
            
            if(provider.Id == null){
                newProviders.add(provider);
            }else{
                providersToUpdate.add(provider);
            }
        }
        
        if(!newProviders.isEmpty()){
            INSERT newProviders;
        }
        
        if(!providersToUpdate.isEmpty()){
            UPDATE providersToUpdate;
        }
        
        if(!removedProviders.isEmpty()){
            DELETE removedProviders;
        }
    }
    
    @AuraEnabled
    public static ReimbursementLabels getConfirmationTexts(Integer policyId, Integer categoryId){
        
        Contact currentContact = getCurrentUser().Contact;
        
        DJC_ReimbursementLabelFactory labelFactory = getLabelFactory(DJC_Wellness_Util.getRegion(currentContact.Division__c),
                                                                     DJC_Wellness_Util.getWellnessPolicyById(policyId),
                                                                     DJC_Wellness_Util.getWellnessCategoryById(categoryId),
                                                                     currentContact);
        return new ReimbursementLabels(labelFactory.getConfirmationLabels(),
                                    labelFactory.getCaseSubmittedMessage(),
                                    labelFactory.getCaseApprovedMessage(),
                                    labelFactory.getCaseClosedMessage());
    }
    
    @AuraEnabled
    public static CaseWrapper getCaseById(String caseId){
        
        Case reimbursementCase = DJC_Wellness_Util.getWellnessCaseById(caseId);
        Map<Id, List<Attachment>> attachments = DJC_Wellness_Util.getExistingAttachments(reimbursementCase.Wellness_Reimbursement_Claims__r);
        
        CaseWrapper result = new CaseWrapper(reimbursementCase, attachments);
        return result;
    }
    
    @AuraEnabled
    public static Case submitRequest(Case reimbursementCase, List<DJC_Wellness_Reimbursement_Claim__c> claimsToSave, List<DJC_Wellness_Reimbursement_Claim__c> claimsToDelete){
        
        Contact currentContact = getCurrentUser().Contact;
        DJC_Region region = DJC_Wellness_Util.getRegion(currentContact.Division__c);
        
        Savepoint wellnessSp = Database.setSavepoint();
        
        reimbursementCase.ContactId = currentContact.Id;        
        reimbursementCase.ES_DJC_Sub_Topic__c = getRequestPeriodForCurrentDate([SELECT Group__c FROM Reimbursement_Category__mdt WHERE Id__c = :reimbursementCase.Reimbursement_Category_Id__c].Group__c, currentContact.Division__c);
        reimbursementCase.status = 'Submitted';
        reimbursementCase.recordTypeId = [SELECT Id, developername FROM RecordType where developername = 'All_Expense_Cases'].id;

        try{
            
            String emailToSend = null;
            
            if (reimbursementCase.id == null) {
                emailToSend = 'Created';
                insert reimbursementCase;
            } else {
                emailToSend = 'Updated by user';
                update reimbursementCase;
            }
            
            if(claimsToDelete != null && !claimsToDelete.isEmpty()){
                delete claimsToDelete;
            }
            
            List<DJC_Wellness_Reimbursement_Claim__c> newClaims = new List<DJC_Wellness_Reimbursement_Claim__c>();
            List<DJC_Wellness_Reimbursement_Claim__c> existingClaims = new List<DJC_Wellness_Reimbursement_Claim__c>();
            
            for(DJC_Wellness_Reimbursement_Claim__c claim:claimsToSave){
                if(claim.Id == null){
                    claim.DJC_Wellness_Case__c = reimbursementCase.Id;
                    claim.DJC_Wellness_Claim_Last_Submitted__c = System.today();
                    claim.DJC_Wellness_Request_Status__c = reimbursementCase.status;
                    newClaims.add(claim);                    
                }else{
                    existingClaims.add(claim);
                }

            }
            
            if(newClaims != null && !newClaims.isEmpty()){
                insert newClaims;
            }
            
            if(existingClaims != null && !existingClaims.isEmpty()){
                update existingClaims;
            }

            reimbursementCase.setOptions(ESDJC_Util.getAssignmentRulesDMLOption(null));
            reimbursementCase.Email_to_send__c = emailToSend;
            update reimbursementCase;
            createPDFAttachment(reimbursementCase.Id, reimbursementCase.Subject);

        }catch (Exception e){
            system.debug('DML Error '+e.getMessage()+' cause: '+e.getCause());
            Database.rollback(wellnessSp);
            throw new AuraHandledException(e.getdmlMessage(0));
        }

        return DJC_Wellness_Util.getWellnessCaseById(reimbursementCase.Id);
    }
    
    @Future(callout=true)
    private static void createPDFAttachment(String caseId, String fileName){
        PageReference pdf = Page.DJC_ReimbursementPDFPage;
        pdf.getParameters().put('caseId', caseId);
        pdf.setRedirect(false);
        Attachment attach = new Attachment();
        attach.ParentId = caseId;
        attach.name = fileName + '-' + Datetime.now().format('MM-dd-yyyy KK-mm a') + '.pdf';
        attach.ContentType = 'application/pdf';
        attach.body = pdf.getContentAsPDF();
        insert attach;
    }
    
    @AuraEnabled
    public static Map<String,Date> getLimitsInCurrentPeriod(String categoryGroup, String division){
        
        DJC_TimeRangeManager timeRangeManager = getTimeRangeManager(categoryGroup, DJC_Wellness_Util.getRegion(division));
        
        Map<String,Date> limits = new Map<String,Date>();
        limits.put('MIN', timeRangeManager.getMinDateInCurrentPeriod());
        limits.put('MAX', timeRangeManager.getMaxDateInCurrentPeriod());
        
        return limits;
    }
    
    @AuraEnabled
    public static String getClaimRecordTypeId(String categoryGroup, String organization){
        
        String claimRecordTypeId = null;
        if(categoryGroup == 'Education' && organization == 'Salesforce'){
            claimRecordTypeId = [SELECT Id FROM RecordType where developername = 'Education_Claim'].Id;
        }else if(categoryGroup == 'Education' && organization == 'Foundation'){
            claimRecordTypeId = [SELECT Id FROM RecordType where developername = 'Foundation_Education_Claim'].Id;
        }else if(organization == 'Salesforce'){
            claimRecordTypeId = [SELECT Id FROM RecordType where developername = 'Wellness_Claim'].Id;
        }else if(organization == 'Foundation'){
            claimRecordTypeId = [SELECT Id FROM RecordType where developername = 'Foundation_Wellness_Claim'].Id;
        }
        return claimRecordTypeId;
    }    
    
    @AuraEnabled
    public static List<SelectOption> getCourseTypes(){
        
        List<Schema.PicklistEntry> entries = DJC_Wellness_Reimbursement_Claim__c.DJC_Education_Policy__c.getDescribe().getPicklistValues();
        List<SelectOption> options = new List<SelectOption>();
        
        for(Schema.PicklistEntry entry : entries){
            options.add(new SelectOption(entry.getLabel(), entry.getValue()));
        }
        
        return options;
    }
    
    public class CaseWrapper{
        
        @AuraEnabled
        public Case reimbursementCase{public get; private set;}
        @AuraEnabled
        public Map<Id,List<Attachment>> attachments{public get; private set;}
        
        public CaseWrapper(Case rCase, Map<Id, List<Attachment>> attach){
            this.reimbursementCase = rCase;
            this.attachments = attach;
        }
    }
    
    public class ClaimPolicy {
        
        @AuraEnabled
        public String policyText {public get; private set;}
        @AuraEnabled
        public Integer policyId {public get; private set;}
        @AuraEnabled
        public Integer categoryId {public get; private set;}
        
        public ClaimPolicy(String text, Integer policyId, Integer categoryId) {
            this.policyText = text;
            this.policyId = policyId;
            this.categoryId = categoryId;
        }
    }
    
    public class Provider{
        
        @AuraEnabled
        public String name;
        
        @AuraEnabled
        public String providerId;
        
        @AuraEnabled
        public Boolean removable;
        
        public Provider(String name, String providerId){
            this.name = name;
            this.providerId = providerId;
            this.removable = true;
        }
    }
    
    public class SelectOption{
        
        @AuraEnabled
        public String label;
        
        @AuraEnabled
        public String value;
        
        public SelectOption(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
    
    public class ReimbursementLabels{
        
        @AuraEnabled
        public List<String> confirmationMessage;
        @AuraEnabled
        public String caseSubmittedMessage;
        @AuraEnabled
        public String caseApprovedMessage;
        @AuraEnabled
        public String caseClosedMessage;
        
        public ReimbursementLabels(List<String> confirmationMessage,
                                  String caseSubmittedMessage,
                                  String caseApprovedMessage,
                                  String caseClosedMessage){
            this.confirmationMessage = confirmationMessage;
            this.caseSubmittedMessage = caseSubmittedMessage;
            this.caseApprovedMessage = caseApprovedMessage;
            this.caseClosedMessage = caseClosedMessage;
        }
    }
}