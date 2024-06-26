global class ESDJC_Reimbursement_UpdateCaseBatch implements Database.Batchable<sObject> {
    public set<id> processedClaimIds;
    private PF_Batch_Job_Tune_Config__mdt caseBatchSetting = ESDJC_Reimbursement_Integrations_Service.caseConfig;
    public ESDJC_Reimbursement_UpdateCaseBatch(set<id> processedClaimIds){
	        this.processedClaimIds = processedClaimIds;
	    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        set<Id> caseIdsToUpdate = ESDJC_Reimbursement_Integrations_Service.getCaseIdsToClose(processedClaimIds);
        return Database.getQueryLocator(caseBatchSetting.SOQL_Query__c);      
    }
    global void execute(Database.BatchableContext BC,  List<case> casesToBeUpdated){
        try{
            ESDJC_Reimbursement_Integrations_Service.updateCaseStatus(casesToBeUpdated);
        }catch(Exception ex){
            String errorDesc = ex.getMessage() + ex.getStackTraceString() + ' \n for Cases';
            PF_Logger.log('ESDJC','ERROR','Unexpected exception when updating the cases in current batch','Exception',errorDesc,'Reimbursement Integration');
        }finally{
            if(!PF_Logger.logs.isEmpty()){
                PF_Logger.createLogs(PF_Logger.logs);
            }
        }
    }
        global void finish(Database.BatchableContext BC){   

}
	    	
	    
    
}