public class PF_ReimbursementRequestFormManager extends PF_FormManager {
    
    private DJC_WellnessManagerFactory managerFactory = null;
    
    protected override Map<String,Object> getFormSpecificInformation(Map<String,Object> parameters){
        
        Map<String,Object> specificInformation = new Map<String,Object>();
        
        Integer policyId = null;
        Integer categoryId = null;
        Case reimbursementCase = null;
        
        if(parameters.containsKey('CASEID')){
            reimbursementCase = DJC_Wellness_Util.getWellnessCaseById((String)parameters.get('CASEID'));
            policyId = Integer.valueOf(reimbursementCase.Reimbursement_Policy_Id__c);
            categoryId = Integer.valueOf(reimbursementCase.Reimbursement_Category_Id__c);
        }else{
            policyId = Integer.valueOf(parameters.get('POLICYID'));
            categoryId = Integer.valueOf(parameters.get('CATEGORYID'));
        }

        Reimbursement_Policy__mdt policy = DJC_Wellness_Util.getWellnessPolicyById(policyId);
        Reimbursement_Category__mdt category = DJC_Wellness_Util.getWellnessCategoryById(categoryId);
        
        managerFactory = getWellnessManagerFactory(
            DJC_Wellness_Util.getRegion(currentUser.Contact.Division__c),
            policy, category, currentUser.Contact);
        
        PF_ReimbursementRequestCategoryHandler handler = PF_ReimbursementCategoryHandlerFactory.getCategoryHandler(category.Group__c, managerFactory);
        
        String caseStatus = null;
        
        if(reimbursementCase != null){
            specificInformation.put('CASEINFO', handler.getCaseInformation(reimbursementCase));
            caseStatus = (String)((Map<String,Object>)specificInformation.get('CASEINFO')).get('STATUS');
        }
        
        specificInformation.put('CONFIG', getConfigInformation(policy, category, handler, caseStatus));
        
        return specificInformation;
    }
        
    private Map<String,Object> getConfigInformation(Reimbursement_Policy__mdt policy, Reimbursement_Category__mdt category, PF_ReimbursementRequestCategoryHandler handler, String caseStatus){

        Map<String,Object> configInformation = new Map<String,Object>();
        
        configInformation.put('TEMPLATE', handler.getClaimTemplate());
        configInformation.put('FORM', handler.getFormName());
        configInformation.put('CURRENCY', policy.Currency__c);
        configInformation.put('REQUEST_INFO', handler.getRequestInformation(policy, category, caseStatus));
        configInformation.put('CATEGORY_INFO', handler.getCategoryInformation());
        
        return configInformation;
    }

    private DJC_WellnessManagerFactory getWellnessManagerFactory(DJC_Region region, Reimbursement_Policy__mdt policy,
                                                                 Reimbursement_Category__mdt category, Contact contact){
                                                                     return DJC_WellnessManagerFactory.getInstance(region, policy, category, contact);
                                                                 }
    
    protected override List<String> getUserFields(){
        return null;
    }
    
    public override Id createCase(Map<String, Object> caseInformation, String attachmentsStoreId){
        
        Integer policyId = null;
        Integer categoryId = null;
        Boolean sendCaseCreationAlert = false;
        Case reimbursementCase = null;
        
        if(caseInformation.containsKey('CaseId')){
            reimbursementCase = DJC_Wellness_Util.getWellnessCaseById((String)caseInformation.get('CaseId'));
            policyId = Integer.valueOf(reimbursementCase.Reimbursement_Policy_Id__c);
            categoryId = Integer.valueOf(reimbursementCase.Reimbursement_Category_Id__c);
        }else{
            policyId = Integer.valueOf(caseInformation.get('PolicyId'));
            categoryId = Integer.valueOf(caseInformation.get('CategoryId'));
        }
        
        List<Object> rawClaims = (List<Object>)caseInformation.get('Claims');
        List<Object> rawClaimsToDelete = (List<Object>)caseInformation.get('ClaimsToDelete');

        List<DJC_Wellness_Reimbursement_Claim__c> claims = new List<DJC_Wellness_Reimbursement_Claim__c>();
        List<DJC_Wellness_Reimbursement_Claim__c> claimsToDelete = new List<DJC_Wellness_Reimbursement_Claim__c>();
        
        Reimbursement_Policy__mdt policy = DJC_Wellness_Util.getWellnessPolicyById(Integer.valueOf(policyId));
        Reimbursement_Category__mdt category = DJC_Wellness_Util.getWellnessCategoryById(Integer.valueOf(categoryId));
        
        managerFactory = getWellnessManagerFactory(
            DJC_Wellness_Util.getRegion(currentUser.Contact.Division__c),
            policy, category, currentUser.Contact);
        
        PF_ReimbursementRequestCategoryHandler handler = PF_ReimbursementCategoryHandlerFactory.getCategoryHandler(category.Group__c, managerFactory);
        Id claimRecordTypeId = handler.getClaimRecordType();
        
        for(Object rawClaim:rawClaims){
            DJC_Wellness_Reimbursement_Claim__c claim = (DJC_Wellness_Reimbursement_Claim__c)JSON.deserialize((String)rawClaim, DJC_Wellness_Reimbursement_Claim__c.class);
            claim.RecordTypeId = claimRecordTypeId;
            claims.add(claim);
        }
        
        for(Object rawClaim:rawClaimsToDelete){
            DJC_Wellness_Reimbursement_Claim__c claim = (DJC_Wellness_Reimbursement_Claim__c)JSON.deserialize((String)rawClaim, DJC_Wellness_Reimbursement_Claim__c.class);
            claimsToDelete.add(claim);
        }
        
        DJC_TimeRangeManager periodManager = managerFactory.getTimeRangeManager();
        
        if(reimbursementCase == null){
            reimbursementCase = new Case();
            reimbursementCase.ContactId = currentUser.contactId;
            reimbursementCase.ES_DJC_Sub_Topic__c = periodManager.getCurrentTimeRange();
            reimbursementCase.status = 'Submitted';
            reimbursementCase.Subject = category.MasterLabel + ' Reimbursement Request for ' + currentUser.Contact.Name;
            reimbursementCase.Type = handler.getCaseType();
            reimbursementCase.Tier__c = handler.getTier(DJC_Division.getDivisionByName(currentUser.contact.Division__c));
            reimbursementCase.Reimbursement_Policy_Id__c = policy.Id__c;
            reimbursementCase.Reimbursement_Category_Id__c = category.Id__c;
            reimbursementCase.ES_DJC_Topic__c = category.MasterLabel;
            reimbursementCase.CurrencyIsoCode = policy.Currency__c;
            reimbursementCase.Division__c = currentUser.Contact.Division__c;
            reimbursementCase.Origin = 'Employee Success - Web';
            reimbursementCase.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Expense Cases').getRecordTypeId();
        }
        
        Savepoint wellnessSp = Database.setSavepoint();

        try{
            reimbursementCase.setOptions(ESDJC_Util.getAssignmentRulesDMLOption(null));

            if (reimbursementCase.id == null) {
                sendCaseCreationAlert = true;
                reimbursementCase.Email_to_send__c = 'Created';
                insert reimbursementCase;
            } else {
                reimbursementCase.Email_to_send__c = 'Updated by user';
                update reimbursementCase;
            }
            
            if(claimsToDelete != null && !claimsToDelete.isEmpty()){
                delete claimsToDelete;
            }
            
            List<DJC_Wellness_Reimbursement_Claim__c> newClaims = new List<DJC_Wellness_Reimbursement_Claim__c>();
            List<DJC_Wellness_Reimbursement_Claim__c> existingClaims = new List<DJC_Wellness_Reimbursement_Claim__c>();
            
            for(DJC_Wellness_Reimbursement_Claim__c claim:claims){
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

            moveAttachmentsToClaims(claims, attachmentsStoreId);
            createPDFAttachment(reimbursementCase.Id, reimbursementCase.Subject);

            if (sendCaseCreationAlert) {
                Map<String, Object> params = new Map<String, Object> {
                    'CaseId' => reimbursementCase.Id
                };

                Flow.Interview alertFlow = Flow.Interview.createInterview('Reimbursement_Case_Creation_Email_Alert', params);

                alertFlow.start();
            }
        }catch (DMLException e){
            system.debug('DML Error '+e.getMessage()+' cause: '+e.getCause());
            Database.rollback(wellnessSp);
            String message = e.getDmlMessage(0);
            if(message.contains('cannot be less than') || message.contains('amount is over')){
                throw new AuraHandledException(e.getdmlMessage(0));
            }
            throw e;
        }

        Boolean isAppzenGA = ESDJC_Settings__c.getOrgDefaults().Is_Appzen_GA__c;
        if(isAppzenGA){
            sendWellnessReimbursementCaseToAppzen(reimbursementCase);
        }
        
        return reimbursementCase.Id;
    }

    public static void sendWellnessReimbursementCaseToAppzen(Case reimbursementCase){
        
        List<String> enabledReimbursementTypes = ESDJC_Settings__c.getOrgDefaults().Appzen_Enabled_Reimbursement_Types__c.split(';');
        List<String> enabledDivisions = ESDJC_Settings__c.getOrgDefaults().Appzen_Enabled_Divisions__c.split(';');
        List<String> enabledTopic = ESDJC_Settings__c.getOrgDefaults().Appzen_Enabled_Topic__c.split(';');
        if((enabledReimbursementTypes != null && enabledDivisions != null) && (enabledReimbursementTypes.contains(reimbursementCase.Type) 
           && enabledDivisions.contains(reimbursementCase.Division__c) && enabledTopic.contains(reimbursementCase.ES_DJC_Topic__c)))
        {
            List<DJC_Wellness_Reimbursement_Claim__c> reimbursementClaims = new List<DJC_Wellness_Reimbursement_Claim__c>();
            List<Id> reimbursementClaimIds = new List<Id>();
            Map<Id, Blob> claimToAttachmentMap = new Map<Id, Blob>();
            Map<String, String> contactCountryCodeMap = new Map<String, String>();
            List<ReimbursementClaimWrapper> claimWrapperRecords = new List<ReimbursementClaimWrapper>();

            Case eligibleReimbursementCase = [SELECT Id, CaseNumber, CurrencyIsoCode, Type, Total_Claims_Amount_Submitted__c, Division__c, Contact.Name, Contact.Email, Contact.ES_DJC_Contact_Country__c, LastModifiedDate, CreatedDate FROM Case WHERE Id =: reimbursementCase.Id];

            for(DJC_Wellness_Reimbursement_Claim__c claim : [SELECT Id,ConnectionReceivedId,ConnectionSentId,CreatedById,CreatedDate,CurrencyIsoCode,DJC_Education_Course_Description__c,DJC_Education_Course_Justification__c,DJC_Education_Date_Completed__c,DJC_Education_Institution__c,DJC_Education_Policy__c,DJC_Reimbursement_Claim_Detail__c,DJC_Wellness_Activity__c,DJC_Wellness_Amount_Requested__c,DJC_Wellness_Case__c,DJC_Wellness_Claim_Fiscal_Year_Start__c,DJC_Wellness_Claim_Last_Submitted__c,DJC_Wellness_Claim_Quarter__c,DJC_Wellness_End_Date_of_Activity__c,DJC_Wellness_Provider__c,DJC_Wellness_Request_Comments__c,DJC_Wellness_Request_Status__c,DJC_Wellness_Start_Date_of_Activity__c,IsDeleted,IsLocked,LastActivityDate,LastModifiedById,LastModifiedDate,local_id__c,MayEdit,Name,RecordTypeId,SystemModstamp,Time_Range__c FROM DJC_Wellness_Reimbursement_Claim__c WHERE DJC_Wellness_Case__c =: eligibleReimbursementCase.Id]){
                reimbursementClaimIds.add(claim.Id);
                reimbursementClaims.add(claim);
            }

            for(Attachment a : [SELECT Id, ParentId, Name, Body from Attachment WHERE ParentId In : reimbursementClaimIds]) {
                if(!claimToAttachmentMap.containsKey(a.ParentId)){
                    claimToAttachmentMap.put(a.ParentId, a.Body);
                }
            }

            Schema.DescribeFieldResult fieldResult = Contact.Mailing_Country__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f : ple){
                contactCountryCodeMap.put(f.getLabel(), f.getValue());
            }

            
            for(DJC_Wellness_Reimbursement_Claim__c claim : reimbursementClaims){
                ReimbursementClaimWrapper claimWrapperObj = new ReimbursementClaimWrapper();
                claimWrapperObj.claimRecord = claim;
                claimWrapperObj.attachmentRecord = claimToAttachmentMap.get(claim.Id);
                claimWrapperRecords.add(claimWrapperObj);
            }
            ReimbursementCaseWrapper caseWrapperObj = new ReimbursementCaseWrapper();
            Contact con = eligibleReimbursementCase.Contact;
            caseWrapperObj.countryCode = contactCountryCodeMap.containsKey(con.ES_DJC_Contact_Country__c)?contactCountryCodeMap.get(con.ES_DJC_Contact_Country__c):'';
            caseWrapperObj.caseRecord = eligibleReimbursementCase;
            caseWrapperObj.claimWrapperRecords = claimWrapperRecords;

            Id jobId = System.enqueueJob(new PF_To_Appzen_CalloutQueueableJob(caseWrapperObj));
        }
    }
    
    public class ReimbursementClaimWrapper{
        DJC_Wellness_Reimbursement_Claim__c claimRecord;
        Blob attachmentRecord;
    }
    
    public class ReimbursementCaseWrapper{
        String countryCode;
        Case caseRecord;
        List<ReimbursementClaimWrapper> claimWrapperRecords;
    }

    public class PF_To_Appzen_CalloutQueueableJob implements Queueable, Database.AllowsCallouts {

        ReimbursementCaseWrapper caseWrapperObj;
    
        public PF_To_Appzen_CalloutQueueableJob(ReimbursementCaseWrapper caseWrapperObj){
            this.caseWrapperObj = caseWrapperObj;
        }
    
        public void execute(QueueableContext context){
            
            JSONGenerator caseWrapperJSON = JSON.createGenerator(true);
            try{
                caseWrapperJSON.writeObject(caseWrapperObj);
            }
            catch(JSONException jsonExcp){
                PF_Logger.log('Service Cloud Console - Appzen', 'JSON string exceeds heap size limit because of reimbursement receipt(s) file(s) size(s) is more than 12MB', jsonExcp.getMessage(), '', ''+jsonExcp.getMessage(), '');
                PF_Logger.createLogs(PF_Logger.logs);

                caseWrapperObj.caseRecord.Status = System.Label.PF_Appzen_Error_Status_Label;
                try{
                    update caseWrapperObj.caseRecord;
                }
                catch(DMLException dmlExcp){
                    PF_Logger.log('Service Cloud Console - Appzen', 'Exception in updating case status', dmlExcp.getMessage(), '', ''+dmlExcp.getMessage(), '');
                    PF_Logger.createLogs(PF_Logger.logs);
                }
                return;
            }

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:Mulesoft_Cloudhub_for_Appzen');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('client_id', '{!$Credential.UserName}');
            request.setHeader('client_secret', '{!$Credential.Password}');
            request.setBody(caseWrapperJSON.getAsString());
            HttpResponse response;
            try{
                response = http.send(request);
            }
            catch(CalloutException e){
                PF_Logger.log('Service Cloud Console - Appzen', 'Exception in callout to mulesoft', e.getMessage(), '', ''+e.getMessage(), '');
                PF_Logger.createLogs(PF_Logger.logs);
            }
            
            Map<String, Object> respJSON = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                
            if(respJSON.get('Status') == 'Success'){
                caseWrapperObj.caseRecord.Status = System.Label.PF_Appzen_Success_Status_Label;
            }
            else{
                caseWrapperObj.caseRecord.Status = System.Label.PF_Appzen_Error_Status_Label;
            }
            
            try{
                update caseWrapperObj.caseRecord;
            }
            catch(DMLException e){
                PF_Logger.log('Service Cloud Console - Appzen', 'Exception in updating case status', e.getMessage(), '', ''+e.getMessage(), '');
                PF_Logger.createLogs(PF_Logger.logs);
            }
        }
    }
    
    private void moveAttachmentsToClaims(List<DJC_Wellness_Reimbursement_Claim__c> claimIds, String attachmentsStoreId){
        
        Map<Id,List<String>> attachmentsToUpdate = new Map<Id,List<String>>();
        
        if(!String.isBlank(attachmentsStoreId)){
            Attachment[] attachments = [SELECT Id, name, body, description from Attachment WHERE ParentId = :attachmentsStoreId];
            Attachment[] caseAttachments = new List<Attachment>();
            for(Attachment a:attachments){
                DJC_Wellness_Reimbursement_Claim__c claim = claimIds[
                    Integer.valueOf(a.description.substring(0, a.description.indexOf(':')))
                ];
                if(!attachmentsToUpdate.containsKey(claim.Id)){
                    attachmentsToUpdate.put(claim.Id, new List<String>());
                }
                attachmentsToUpdate.get(claim.Id).add(a.description.substring(a.description.indexOf(':') + 1, a.description.length()));
                caseAttachments.add(new Attachment(name = a.name, body = a.body, parentId = claim.Id, description = a.description.substring(a.description.indexOf(':') + 1, a.description.length())));
            }
            
            if(!attachmentsToUpdate.isEmpty()){
                List<Attachment> oldAttachmentsToUpdate = new List<Attachment>();
                Attachment[] oldAttachments = [SELECT Id, name, description, parentId from Attachment WHERE ParentId IN :attachmentsToUpdate.keySet() AND (NOT Name LIKE '#deleted_%')];
                List<String> attDescriptions = null;
                for(Id claimId : attachmentsToUpdate.keySet()){
                    attDescriptions = attachmentsToUpdate.get(claimId);
                    for(Attachment at:oldAttachments){
                        if(at.parentId == claimId){
                            for(String descr:attDescriptions){
                                if(descr == at.description){
                                    at.name = '#deleted_' + at.name;
                                    oldAttachmentsToUpdate.add(at);
                                }
                            }
                        }
                    }
                }
                UPDATE oldAttachmentsToUpdate;
            }
            
            INSERT caseAttachments;
        }
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
}