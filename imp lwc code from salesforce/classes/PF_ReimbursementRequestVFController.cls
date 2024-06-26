public without sharing class PF_ReimbursementRequestVFController{
    
    public PageReference onLoad(){
        
        if((policyId == null || categoryId == null) && (caseId == null)){
            PageReference pg = new PageReference('/apex/DJC_ES_Requests');
            pg.setRedirect(true);
            return pg;
        }

        return null;
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
}