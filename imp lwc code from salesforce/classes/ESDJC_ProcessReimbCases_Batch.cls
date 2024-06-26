global with sharing class ESDJC_ProcessReimbCases_Batch implements Database.Batchable<sObject>, Schedulable,Database.AllowsCallouts, Database.Stateful{
    
  private List<Id> claimIds = new List<Id>();
  private PF_Batch_Job_Tune_Config__mdt claimBatchSetting = ESDJC_Reimbursement_Integrations_Service.claimConfig;
  private PF_Batch_Job_Tune_Config__mdt caseBatchSetting = ESDJC_Reimbursement_Integrations_Service.caseConfig;
  public Set<Id> processedClaimIds =  new Set<Id>();
  global void execute(SchedulableContext SC) {
      Database.executeBatch(new ESDJC_ProcessReimbCases_Batch(),Integer.valueOf(claimBatchSetting.Batch_Size__c));
  }
  public ESDJC_ProcessReimbCases_Batch(){}
  public ESDJC_ProcessReimbCases_Batch(List<id> claimIds){
      this.claimIds = claimIds;
  }
  global Database.QueryLocator start(Database.BatchableContext BC){
      if(claimIds.size() >0){
          return Database.getQueryLocator(claimBatchSetting.Retry_Soql_Query__c);
      }else{
          return Database.getQueryLocator(claimBatchSetting.SOQL_Query__c);
      }
      
  }
  global void execute(Database.BatchableContext BC, List<sObject> claims){
      try{
          Set<Id> sucessfullyProcessedClaims = ESDJC_Reimbursement_Integrations_Service.processClaims(claims);
          if(sucessfullyProcessedClaims.size() >0){
              processedClaimIds.addAll(sucessfullyProcessedClaims);
          }
      }catch(Exception ex){
          String errorDesc = ex.getMessage() + ex.getStackTraceString() + ' \n for Claims :'+ JSON.serialize(claims);
          PF_Logger.log('ESDJC','ERROR','Unexpected exception when processing claims in current batch','Exception',errorDesc,'Reimbursement Integration');
      }
      finally {
          if(!PF_Logger.logs.isEmpty()){
              PF_Logger.createLogs(PF_Logger.logs);
          }
      }
      
  }
  
  global void finish(Database.BatchableContext BC){
      Database.executeBatch(new ESDJC_Reimbursement_UpdateCaseBatch(processedClaimIds),Integer.valueOf(caseBatchSetting.Batch_Size__c));
  }
}