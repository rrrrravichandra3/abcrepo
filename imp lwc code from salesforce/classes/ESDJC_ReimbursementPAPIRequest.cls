public class ESDJC_ReimbursementPAPIRequest {

    public static HttpResponse calloutToWDReimbursementPAPI(String claimWrapper){
       
            String errMessage;
            List<Case> lstUpdatedCases = new List<Case>();
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse res = new HttpResponse();
            request.setEndpoint('callout:Mulesoft_Cloudhub_for_Reimbursement_Integration');
            request.setMethod('POST');
            request.setTimeout(30000);
            request.setHeader('Content-Type', 'application/json');
            request.setBody(claimWrapper);
            try {
                  res = http.send(request);
                } catch (Exception e) {
                    PF_Logger.log('ESDJC','ERROR',e.getMessage(),'Callout Error',e.getStackTraceString(),'DJC_Integration_UpdateCaseStatus_BatchHandler');
                } 
           return res;
    }

}