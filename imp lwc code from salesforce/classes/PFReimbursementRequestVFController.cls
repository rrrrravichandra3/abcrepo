public without sharing class PFReimbursementRequestVFController{
        
    public List<ReimbursementAttachment> attachmentGroup1{get; private set;}
    
    public List<ReimbursementAttachment> attachmentGroup2{get; private set;}
    
    public PageReference onLoad(){
        
        if((policyId == null || categoryId == null) && (caseId == null)){
            PageReference pg = new PageReference('/apex/DJC_ES_Requests');
            pg.setRedirect(true);
            return pg;
        }

        return null;
    }
    
    public class ReimbursementAttachment{
        public transient blob attach{get;set;}
        public String fileName{get;set;}
    }

    public Boolean allowedAccess{
        get{
            if(allowedAccess == null){
                
                allowedAccess = false;
                
                User currentUser = [SELECT ContactId, contact.ES_DJC_Contact_Country__c, contact.Department FROM User WHERE Id = :UserInfo.getUserId()];
                
                if(policyId != null && categoryId != null){
                    List<Reimbursement_Category_Policy_Assoc__mdt> assoc = [SELECT Id FROM Reimbursement_Category_Policy_Assoc__mdt WHERE Policy_Id__c = :Decimal.valueOf(policyId) AND Category_Id__c = :Decimal.valueOf(categoryId)];                    
                    allowedAccess = assoc != null && !assoc.isEmpty();
                    if(allowedAccess){
                        Reimbursement_Policy__mdt policy = [SELECT Country__c, Organization__c FROM Reimbursement_Policy__mdt WHERE Id__c = :Decimal.valueOf(policyId)];
                        allowedAccess = policy != null && policy.Country__c == currentUser.contact.ES_DJC_Contact_Country__c
                                        && ((policy.Organization__c == 'Salesforce' && (currentUser.contact.Department == null || !ESDJC_Util.isFoundationDepartment(currentUser.contact.Department)))
                                            || (policy.Organization__c == 'Foundation' && currentUser.contact.Department != null && ESDJC_Util.isFoundationDepartment(currentUser.contact.Department)));
                    }
                }else if(caseId != null){
                    Case c = [SELECT ContactId FROM Case WHERE Id = :caseId];
                    allowedAccess = c != null && c.ContactId == currentUser.ContactId;
                }
            }
            return allowedAccess;
        }
        private set;
    }
    
    public Boolean successfulOperation{
        get{
            if(successfulOperation == null){
                successfulOperation = false;
            }
            return successfulOperation;
        }
        set;
    }
    
    public PFReimbursementRequestVFController(){
        attachmentGroup1 = new List<ReimbursementAttachment>();
        for(Integer i = 0; i < 10; i++){
            attachmentGroup1.add(new ReimbursementAttachment());
        }
        attachmentGroup2 = new List<ReimbursementAttachment>();
        for(Integer i = 0; i < 10; i++){
            attachmentGroup2.add(new ReimbursementAttachment());
        }
    }
    
    public String policyId{
        get{
            if(policyId == null){
                policyId = ApexPages.currentPage().getParameters().get('policyId');
            }
            return policyId;
        }
        private set;
    }
    
    public String categoryId{
        get{
            if(categoryId == null){
                categoryId = ApexPages.currentPage().getParameters().get('categoryId');
            }
            return categoryId;
        }
        private set;
    }
    
    public String caseId{
        get{
            if(caseId == null){
                caseId = ApexPages.currentPage().getParameters().get('caseId');
            }
            return caseId;
        }
        set;
    }
    
    public String filesInfo{get;set;}
    
    public void saveFiles(){
        
        System.debug('Files info: ' + filesInfo);
        System.debug('Case Id: ' + caseId);
        
        List<Attachment> attachmentList = new List<Attachment>();

        List<String> filesInfoArray = filesInfo.split(';');
        
        for(String fileInfo : filesInfoArray){
            if(!String.isEmpty(fileInfo)){
                String[] fileInfoValues = fileInfo.split('_');
                ReimbursementAttachment attach = attachmentGroup1.get(Integer.valueOf(fileInfoValues[0]));
                if(attach != null && attach.fileName != null && attach.attach != null){
                    attachmentList.add(new Attachment(Name = attach.fileName, body = attach.attach, parentId = fileInfoValues[1], OwnerId = UserInfo.getUserId(),
                                                     Description = 'Receipt'));
                }
                
                attach = attachmentGroup2.get(Integer.valueOf(fileInfoValues[0]));
                
                if(attach != null && attach.fileName != null && attach.attach != null){
                    attachmentList.add(new Attachment(Name = attach.fileName, body = attach.attach, parentId = fileInfoValues[1], OwnerId = UserInfo.getUserId(),
                                                     Description = 'Confirmation_of_completion'));
                }
            }
        }
        
        if(!attachmentList.isEmpty()){            
            insert attachmentList;
        }
        
        successfulOperation = true;
    }
}