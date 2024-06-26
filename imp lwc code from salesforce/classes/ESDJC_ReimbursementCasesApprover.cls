public without sharing class ESDJC_ReimbursementCasesApprover {
    
    @InvocableMethod(label='Reimbursement Cases Approver' description='Changes a set of reimbursement cases status to Approved')
    public static void approveCases(List<Case> cases){
        
        List<Id> casesIds = new List<Id>();
        
        for(Case c:cases){
            casesIds.add(c.Id);
        }
        
        List<Case> editableCases = [SELECT Id, Status, PII__c FROM Case WHERE Id IN :casesIds];
        List<Case> casesToUpdate = new List<Case>();
        
        for(Case c:editableCases){
            if(c.Status == 'Submitted'){
                c.Status = 'Approved';
                c.PII__c = 'Yes';
                casesToUpdate.add(c);
            }
        }

        Database.SaveResult[] results = Database.update(casesToUpdate, false);
        
        List<Case> unsuccesfulCases = new List<Case>();
        
        for(Integer i = 0; i < casesToUpdate.size(); i++){
            Database.SaveResult result = results[i];
            if(!result.isSuccess()){
                casesToUpdate[i].status = 'Not Processed';
                unsuccesfulCases.add(casesToUpdate[i]);
            }
        }
        
        if(!unsuccesfulCases.isEmpty()){
            UPDATE unsuccesfulCases;
        }
    }
}