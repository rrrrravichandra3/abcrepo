public without sharing class ReimbursementPolicyInfoController {

    private final Case reimbursementCase;

    public String policyCountry{
        get{
            if(policyCountry == null){
                if(reimbursementCase.Reimbursement_Policy_Id__c != null){
                    policyCountry = [SELECT Country__c FROM Reimbursement_Policy__mdt WHERE Id__c = :reimbursementCase.Reimbursement_Policy_Id__c].Country__c;
                }else{
                    policyCountry = '---';
                }
            }
            return policyCountry;
        }
        private set;
    }
    
    public String category{
        get{
            if(category == null){
                if(reimbursementCase.Reimbursement_Category_Id__c != null){
                    category = [SELECT MasterLabel  FROM Reimbursement_Category__mdt WHERE Id__c = :reimbursementCase.Reimbursement_Category_Id__c].MasterLabel;
                }else{
                    category = '---';
                }
            }
            return category;
        }
        private set;
    }
    
    public ReimbursementPolicyInfoController(ApexPages.StandardController stdController){
        reimbursementCase = [SELECT Reimbursement_Policy_Id__c, Reimbursement_Category_Id__c FROM Case WHERE Id = :((Case)stdController.getRecord()).Id];
    }    
}