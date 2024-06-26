@RestResource(urlMapping='/CloseReimbursementCases/*')
global without sharing class DJC_CloseCasesIntegrationController{

//public for unit tests only
    public static final String ENDPOINT_ERROR = 'ERROR - Invalid Request. Please make sure the endpoint is /CloseReimbursementCases';
   
    @HttpPost
    global static String getcloseReimbursementClaims(List<String> caseIds) {
    	
    	string reimbursmentType ;
    	set<id> reimbursementCaseIds = new set<id>();
    	ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance(); 
    	Integer Batchsize = (Integer)((settings.DJC_Integration_Batch_Size__c == null) ? 200 :settings.DJC_Integration_Batch_Size__c);
    	
        for(String caseId : caseIds){
            System.debug('Case Id from WD: ' + caseId);
        }
        
        if(caseIds != null && !caseIds.isEmpty()){
            
            List<Case> casesToUpdate = [SELECT Id, Status,type FROM Case 
            							WHERE Id IN :caseIds];
            							// AND status ='Extracted for Payment']; The status check happens in the Batch job.
            
           /* for(Case c : casesToUpdate){
                if(c.Status == 'Extracted for Payment'){
                    c.Status = 'Closed';
                }
            }
            
            UPDATE casesToUpdate;*/
            for(Case c : casesToUpdate){
            	reimbursementCaseIds.add(c.id);
            }
            if(casesToUpdate.size()>0){
              //Based on first case assign reimbursmentType for batch job.Assumption - only reimbursments of same type will be closed at once.            	
            	reimbursmentType =casesToUpdate[0].type.tolowercase().contains('education')? 'Education':'Wellness';
              //W-3393679 moving the case status update to batch class to avoid 101 limit exception       
	           DJC_Integration_UpdateCaseBatch updateCasebatchobj = new DJC_Integration_UpdateCaseBatch(reimbursementCaseIds,'Closed',reimbursmentType);
	           Database.executebatch(updateCasebatchobj,Batchsize);          	
            }

        }
        
        return '{"result":"Success"}';
        
       
    }
    
  

}