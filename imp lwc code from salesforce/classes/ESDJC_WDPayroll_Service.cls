public class ESDJC_WDPayroll_Service {
    
    
    public static List<ReimbursementPapiResponseClaimWrapper> calloutToWDReimbursementPAPI(List<ReimbursementPapiRequestClaimWrapper> claimWrappers){
        String claimWrapper;
        JSONGenerator claimWrapperJSON = JSON.createGenerator(false);
        claimWrapperJSON.writeObject(claimWrappers);
        List<ReimbursementPapiResponseClaimWrapper> responseWrappers = new List<ReimbursementPapiResponseClaimWrapper>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse res = new HttpResponse();
        request.setEndpoint('callout:Mulesoft_Cloudhub_for_Reimbursement_Integration');
        request.setMethod('POST');
        request.setTimeout(Integer.valueOf(ESDJC_Reimbursement_Integrations_Service.claimConfig.Time_Out__c));
        request.setHeader('Content-Type', 'application/json');
        claimWrapper = claimWrapperJSON.getAsString().replace('effectiveDate','date');
        request.setBody(claimWrapper.replace('claimCurrency','currency'));
        try {
            res = http.send(request);
        } catch (Exception e) {
            PF_Logger.log('ESDJC','ERROR',e.getMessage(),'Callout Error',e.getStackTraceString(),'ESDJC_Reimbursement_Integrations_Service');
        } 
        if(res.getStatusCode() == 200){
            responseWrappers = (List<ReimbursementPapiResponseClaimWrapper>)System.JSON.deserialize(res.getBody(), List<ReimbursementPapiResponseClaimWrapper>.class);
        }else{
            PF_Logger.log('ESDJC','ERROR',res.getBody(),'Callout Error',String.valueOf(res.getStatusCode()),'ESDJC_Reimbursement_Integrations_Service');
        }
        if(!PF_Logger.logs.isEmpty()){
            PF_Logger.createLogs(PF_Logger.logs);
        }
        return responseWrappers;
    }
    public class ReimbursementPapiRequestClaimWrapper{
        public String uniqueId{get; set;}
        public String employeeId {get; set;}
        public Date effectiveDate{ get; set;}
        public String reimbursementName { get; set;}
        public Decimal amount{ get; set;}
        public String claimCurrency{ get; set;}
        public boolean isTaxable{get;set;}
        public String region{get;set;}
        
    }
    public class ReimbursementPapiResponseClaimWrapper{
        public String uniqueId;
        public integer code;
        public String status;
        public String reimbursementName;
        public String employeeId;
    }       
}