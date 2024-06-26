global class ESDJC_Reimbusrement_UpdateCaseBatch implements Database.Batchable<sObject> {
    public set<Id> caseIdsToUpdate;
    private PF_UpdateCaseBatch_Job_Tune_Config__mdt caseBatchSetting = ESDJC_Reimbursement_Integrations_Service.caseConfig;
    public ESDJC_Reimbusrement_UpdateCaseBatch(set<id> caseIdsToUpdate){
	        this.caseIdsToUpdate = caseIdsToUpdate;
	    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(caseBatchSetting.SOQL_Query__c);     
    }
    global void execute(Database.BatchableContext BC,  List<case> casesToBeUpdated){
        ESDJC_Reimbursement_Integrations_Service.updateCaseStatus(casesToBeUpdated);
    }
        global void finish(Database.BatchableContext BC){   

}
	    	
	    
    
}