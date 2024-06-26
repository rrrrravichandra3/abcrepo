/**
 * ******************************************** W-12535956 : API CALLOUT FRAMEWORK ********************************************
 * 
 * Implements Abstract Class for CalloutRequest to initialize all properties of Http Request.
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         25/02/2023      Chakshu Malhotra        W-12535956 - Adds an abstract class to initialize all properties of Http Request.
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_AbstractCalloutRequest implements MA_DS_CalloutFramework.CalloutRequest {
    
    public String httpMethod {get; private set;}
    public String requestBody {get; private set;}
    public String requestEndpoint {get; private set;}
    public Integer requestTimeout {get; private set;}
    protected MA_DS_CalloutFramework.RequestParams requestParams {get; set;}

    private static final String CALLOUT_FORMATTED_STR = Label.MA_DS_API_Callout_Formatted_Str;
    private static final String RESOURCE_INSTANCE_KEY = Label.MA_DS_CLM_API_Workflow_Instance_Key;
    public static final String ROOT_ELEMENT_PARAMS = Label.MA_DS_CLM_API_Workflow_Params_Root_Element;

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize the HttpRequest properties.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   HttpRequest             DESCRIPTION (return HttpRequest instance)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public virtual HttpRequest initHttpRequest() {
        HttpRequest clmApiRequest = new HttpRequest();
        clmApiRequest.setMethod(this.httpMethod);
        clmApiRequest.setTimeout(this.requestTimeout);
        clmApiRequest.setEndpoint(this.requestEndpoint);
        
        if(String.isNotBlank(this.requestBody)) {
            clmApiRequest.setBody(this.requestBody);
        }
        return clmApiRequest;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to form the Endpoint for the HttpRequest using API Endpoint Formatted String, Named Credential, API Version, API Account Id & the API resource.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    apiAccountId	                    DESCRIPTION (Data Type String, Account Id for the Docusign CLM user account)
    * @param    apiEndpointFormattedStr	            DESCRIPTION (Data Type String, The API endpoint formatted string to set the endpoint for HttpRequest callout)
    * @param    namedCredential	                    DESCRIPTION (Data Type String, API name of the Named Credential configured to store the API Endpoint details)
    * @param    apiVersion	                        DESCRIPTION (Data Type String, API version of the API resource)
    * @param    apiResource	                        DESCRIPTION (Data Type String, The API resource being called out)
    * @return   String                              DESCRIPTION (return the Endpoint for the HttpRequest)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public virtual String getCalloutEndpoint(String apiAccountId, String apiEndpointFormattedStr, String namedCredential, String apiVersion, String apiResource) {
        return String.format(apiEndpointFormattedStr, new String[] {namedCredential, apiVersion, apiAccountId, apiResource});
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to form the Endpoint for the HttpRequest using API Endpoint Formatted String, Named Credential, API Version, API Account Id, API resource & API Resource Instance Id.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    apiResourceInstanceId	            DESCRIPTION (Data Type String, Instance / Record Id for the CLM / e-Sign API)
    * @param    apiAccountId	                    DESCRIPTION (Data Type String, Account Id for the Docusign CLM user account)
    * @param    apiEndpointFormattedStr	            DESCRIPTION (Data Type String, The API endpoint formatted string to set the endpoint for HttpRequest callout)
    * @param    namedCredential	                    DESCRIPTION (Data Type String, API name of the Named Credential configured to store the API Endpoint details)
    * @param    apiVersion	                        DESCRIPTION (Data Type String, API version of the API resource)
    * @param    apiResource	                        DESCRIPTION (Data Type String, The API resource being called out)
    * @return   String                              DESCRIPTION (return the Endpoint for the HttpRequest)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public virtual String getCalloutEndpoint(String apiResourceInstanceId, String apiAccountId, String apiEndpointFormattedStr, String namedCredential, String apiVersion, String apiResource) {
        return String.format(apiEndpointFormattedStr, new String[] {namedCredential, apiVersion, apiAccountId, apiResource, apiResourceInstanceId});
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize the properties of type MA_DS_CalloutFramework.CalloutRequest, to setup the HttpRequest instance.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    httpMethod	                        DESCRIPTION (Data Type String, Http Method used to call the API)
    * @param    requestTimeout	                    DESCRIPTION (Data Type Integer, Request Timeour in milliseconds)
    * @param    requestEndpoint	                    DESCRIPTION (Data Type String, The Endpoint for the HttpRequest)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public virtual void prepCalloutRequest(String httpMethod, Integer requestTimeout, String requestEndpoint) {
        this.httpMethod = httpMethod;
        this.requestTimeout = requestTimeout;
        this.requestEndpoint = requestEndpoint;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create HttpRequest payload by setting the Workflow Instance name & the Request Params in serialized XML format.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    resourceInstance	                DESCRIPTION (Data Type String, Workflow instance / resource name)
    * @param    xmlSerializedParams	                DESCRIPTION (Data Type String, Request Params in serialized XML format)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    protected void setRequestBody(String resourceInstance, String xmlSerializedParams) {
        JSONGenerator jsonGen = JSON.createGenerator(false);
        jsonGen.writeStartObject();
        jsonGen.writeStringField(RESOURCE_INSTANCE_KEY, resourceInstance);
        jsonGen.writeStringField(ROOT_ELEMENT_PARAMS, xmlSerializedParams);
        jsonGen.writeEndObject();
        this.requestBody = jsonGen.getAsString();
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the MA_DS_CalloutFramework.RequestParams instance to be used by CalloutFramework in ResponseCallback implementation.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   MA_DS_CalloutFramework.RequestParams              DESCRIPTION (return MA_DS_CalloutFramework.RequestParams instance)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public virtual MA_DS_CalloutFramework.RequestParams getRequestParams() {
        return this.requestParams;
    }
    
    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to be overridden by the sub-class, to set the resource instance and initialize the HttpRequest properties based on the API Callout Config.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public virtual void setCalloutRequestBody(String resourceInstance, MA_DS_CalloutFramework.CalloutRequestParams calloutRequestParams) {}
}