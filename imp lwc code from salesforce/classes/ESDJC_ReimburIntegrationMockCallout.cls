@isTest
global class ESDJC_ReimburIntegrationMockCallout implements HttpCalloutMock{
  Boolean isMockResponseSuccessful;
  Integer statusCode;
  String status;
  List<Id> claimids = new List<Id>(); 
  Private PF_Batch_Job_Tune_Config__mdt batchSetting = ESDJC_Reimbursement_Integrations_Service.claimConfig;
  public ESDJC_ReimburIntegrationMockCallout(Boolean isMockResponseSuccessful,Integer statusCode,String status,List<id> claimids) {
    this.isMockResponseSuccessful  = isMockResponseSuccessful;
    this.statusCode = statusCode;
    this.status = status;
    this.claimids = claimids;  
  }
  global HTTPResponse respond(HTTPRequest request) {
       Database.QueryLocator q = claimids!=NULL?Database.getQueryLocator(batchSetting.SOQL_Query__c):Database.getQueryLocator(batchSetting.Soql__c);
       JSONGenerator claimWrapperJSON = JSON.createGenerator(false);
       Database.QueryLocatorIterator claimRecords = q.iterator();
       List<DJC_Wellness_Reimbursement_Claim__c> claims = new List<DJC_Wellness_Reimbursement_Claim__c>();
       List<ESDJC_WDPayroll_Service.ReimbursementPapiResponseClaimWrapper> responseWrappers = new List<ESDJC_WDPayroll_Service.ReimbursementPapiResponseClaimWrapper>();
       while (claimRecords.hasNext())
        {
         DJC_Wellness_Reimbursement_Claim__c claim = (DJC_Wellness_Reimbursement_Claim__c)claimRecords.next();
         claims.add(claim);
        }
        List<ESDJC_WDPayroll_Service.ReimbursementPapiRequestClaimWrapper> claimWrappers = ESDJC_Reimbursement_Integrations_Service.prepareRequestsToWDReimbursementPAPI(claims);
      for(ESDJC_WDPayroll_Service.ReimbursementPapiRequestClaimWrapper claimWrapper : claimWrappers){
          ESDJC_WDPayroll_Service.ReimbursementPapiResponseClaimWrapper responseWrapper = new ESDJC_WDPayroll_Service.ReimbursementPapiResponseClaimWrapper();
          responseWrapper.code = statusCode;
          responseWrapper.employeeId = claimWrapper.employeeId;
          responseWrapper.status = status;
          responseWrapper.uniqueId =claimWrapper.uniqueId;
          responseWrapper.reimbursementName = claimWrapper.reimbursementName;
          responseWrappers.add(responseWrapper);
      }
        claimWrapperJSON.writeObject(responseWrappers);
        HttpResponse response = new HttpResponse();
        if (this.isMockResponseSuccessful){
        response.setHeader('Content-Type', 'application/json');
        response.setBody(claimWrapperJSON.getAsString());
        response.setStatusCode(200);
        }
        else{
         response.setStatusCode(400);
         response.setBody('[{"error": {"code": 400,"status": "Error During callout","uniqueId": "1qwertyud324567gfe","reimbursementName": "Wellness","employeeId": "100001"}}]');
        }
        return response; 
    }
}