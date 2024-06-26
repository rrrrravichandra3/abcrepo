/**
 * ******************************************** W-12535956 : API CALLOUT FRAMEWORK ********************************************
 *
 * Mule callout service class to dynamically call the mule endpoints and generate the reponse with dynamical apex class instances
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         03/04/2024      Ashutosh Belwal        W-12535956 - <Career Connect> OrgEmployee API service - Job Req
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract with sharing class CcEmp_CalloutService{
    
    
    private String requestBody;
    private String calloutConfig;
    private String queryParams;
    @TestVisible
    private HttpRequest apiRequest;
    @TestVisible
    private CcEmp_API_Callout_Config__mdt apiCalloutConfig;
    
    private Map<String, String> requestHeaders;
    protected abstract String init();
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to build the HTTP request dynamically and set the request body and headers for the HTTP request
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    
    * @return   CcEmp_CalloutService     DESCRIPTION (return CcEmp_CalloutService instance)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    protected virtual CcEmp_CalloutService buildHttpRequest() {
        apiRequest = new HttpRequest();
        apiRequest.setMethod(apiCalloutConfig.CcEmp_HTTP_Method__c);
        apiRequest.setTimeout(Integer.valueOf(apiCalloutConfig.CcEmp_Request_Timeout__c));
        apiRequest.setEndpoint(getCalloutEndpoint());
        buildHeaders();
        
        if(String.isNotBlank(this.requestBody)) {
            apiRequest.setBody(this.requestBody);
        }
        return this;
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to generate the endpoint from Named credentials and api resource stored into custom metadata
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    
    * @return   String     DESCRIPTION (return API callout url)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    protected virtual String getCalloutEndpoint() {
        return 'callout:'+apiCalloutConfig.CcEmp_Named_Credential__c + apiCalloutConfig.CcEmp_API_Resource__c + queryParams;
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set default headers to http request from custom metadata
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void buildHeaders(){
        if( !String.isBlank(apiCalloutConfig.CcEmp_Default_Headers__c) ){
            List<String> headers = apiCalloutConfig.CcEmp_Default_Headers__c.split(',');
            for(String header : headers){
                List<String> keyValue = header.split(':');
                apiRequest.setHeader(keyValue[0],keyValue[1]);
            }
        }
        if(requestHeaders != null && !requestHeaders?.isEmpty()){
            for(String key: requestHeaders.keySet()){
                apiRequest.setHeader(key, requestHeaders.get(key));
            }
        }
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set additional headers to http request from custom metadata
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    Map<String, String>      DESCRIPTION(headers  Map of headers to be set)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    protected void setHeader(Map<String, String> headers) {
        this.requestHeaders = headers;
    }
    
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set query parameters to http request
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    Map<String, String>      DESCRIPTION(Map of query parms to add into http request)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    protected void setQueryParams(String queryParams) {
        this.queryParams = queryParams;
    }


    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set body params to http request
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    Map<String, String>      DESCRIPTION(Map of query parms to add into http request)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    protected void setRequestBody(String body) {
        this.requestBody = body;
    }
    
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set the API Callout Config based on the given type of the Callout Config, used by CalloutStrategy to identify which all implementation classes to initialize for the Callout.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    calloutConfig            DESCRIPTION (Data Type String, The Callout Config to uniquely identify the API Callout Config metadata type record)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    protected void setCalloutConfig(String calloutConfig) {
        
        this.calloutConfig = calloutConfig;
        List<CcEmp_API_Callout_Config__mdt> configList = this.getAPICalloutConfigList(calloutConfig);
        this.apiCalloutConfig = (configList.size() > 0) ? configList[0] : null;
        this.throwExceptionIfUnknownCalloutConfig();
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to throw custom exception CcEmp_UnknownCalloutConfigException if API Callout Config is unknown and doesn't map to any metadata type record.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void throwExceptionIfUnknownCalloutConfig() {
        if(this.apiCalloutConfig == null) {
            throw new CcEmp_CalloutServiceException(CcEmp_CalloutServiceException.class.getName() + ' : Config Not Available ' + this.calloutConfig);
        }
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initiate the http request based on the Callout Config metadata record.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    
    * @return   CalloutResponse     DESCRIPTION (return CalloutResponse instance)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public CalloutResponse initRequest(){
        String httpRequestImp = this.apiCalloutConfig.CcEmp_Callout_Request_Impl__c;
        ICalloutRequest objRequest = (ICalloutRequest)Type.forName(httpRequestImp).newInstance();
        objRequest.initRequest(apiRequest);
        return objRequest.getResponse();
    }
    
    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception to be thrown when API Callout Config is not known or doesn't exist in the metadata type record.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class CcEmp_CalloutServiceException extends Exception {
        

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method overrides the getMessage() method of the Exception class to return the custom exception message.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getMessage() {
            String exceptionMessage = super.getMessage();
            CalloutResponse objResponse = new CalloutResponse();
            objResponse.isSuccess = false;
            objResponse.response = exceptionMessage;
            objResponse.statusCode = 400;
            return JSON.serialize(objResponse);
        }
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the custom metadata type record for the API Callout Config type passed to it.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    calloutConfig                              DESCRIPTION (Data Type String, The Callout Config to uniquely identify the API Callout Config metadata type record)
    * @return   List<CcEmp_API_Callout_Config__mdt>        DESCRIPTION (return List of CcEmp_API_Callout_Config__mdt records)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private List<CcEmp_API_Callout_Config__mdt> getAPICalloutConfigList(String calloutConfig) {
        
        return [SELECT Id, CcEmp_Is_Active__c, CcEmp_Named_Credential__c, CcEmp_HTTP_Method__c, CcEmp_Request_Timeout__c,
                CcEmp_Default_Headers__c, CcEmp_Callout_Request_Impl__c, CcEmp_API_Resource__c
                FROM CcEmp_API_Callout_Config__mdt 
                WHERE DeveloperName = :calloutConfig];
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Interface implemented by each Callout Config, to perform actions on the requestParams and convert it to API accepted format.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public interface ICalloutRequest{
       ICalloutRequest initRequest(HTTPRequest request);
       CalloutResponse getResponse();
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to return the response in same format from all the Implementation class
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class CalloutResponse{
        public Boolean isSuccess;
        public String response;
        public Integer statusCode;
        
    }

}