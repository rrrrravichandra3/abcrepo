/**
 * ******************************************** W-12535956 : API CALLOUT FRAMEWORK ********************************************
 * 
 * Implements Callout Framework to make API calls to DocuSign CLM APIs. Exposes public Interfaces to implement Abstract Classes for CalloutRequestParams, CalloutRequest, 
 * ResponseCallback & CalloutService.
 *  
 * Exposes singleton instance of CalloutStrategy & its methods to dynamically setup instances of CalloutRequestParams, CalloutRequest, ResponseCallback & CalloutService 
 * and initiate Callout using Callout Config metadata.
 * 
 * Implements custom Apex Exceptions thrown while initializing framework / implementation classes or while sending Http Request or while reading Http Response.
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         21/02/2023      Chakshu Malhotra        W-12535956 - Adds a Framework to provide a common strategy to make Docusign CLM API callouts.
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_CalloutFramework {

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to set & hold the final singleton instance of CalloutStrategy.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static final CalloutStrategy calloutStrategy {
        get {
            if(calloutStrategy == null) {
                objectTypeToInstanceMap.put(CalloutStrategy.class, new CalloutStrategy());
            }
            return (CalloutStrategy)objectTypeToInstanceMap.get(CalloutStrategy.class);
        }private set;
    }

    private static final Map<Type, Object> objectTypeToInstanceMap = new Map<Type, Object>();

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create singleton instances of CalloutRequestParams, CalloutRequest, ResponseCallback & CalloutService implementation classes.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    objectType	    DESCRIPTION (Data Type Type, Class type for which singleton instance is to be created)
    * @return   Object          DESCRIPTION (return Object instance of implementation class)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Object getSingletonInstance(Type objectType) {
        if(!objectTypeToInstanceMap.containsKey(objectType)) {
            objectTypeToInstanceMap.put(objectType, objectType.newInstance());
        }
        return objectTypeToInstanceMap.get(objectType);
    }
    
    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Strategy class to dynamically setup instances of CalloutRequestParams, CalloutRequest, ResponseCallback & CalloutService and initiate Callout using Callout Config metadata.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class CalloutStrategy {
        private String myDomain;
        private Id sourceRecordId;
        private String calloutConfig;
        private CalloutRequest calloutRequest;
        private ResponseCallback responseCallback;
        private CalloutRequestParams calloutRequestParams;
        private MA_DS_Docusign_CLM_API_Account__mdt apiAccount;
        private MA_DS_Docusign_CLM_API_Callout_Config__mdt apiCalloutConfig;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Private default constructor of CalloutStrategy class to enforce the singleton design.
        * Fetches the Docusign CLM API Account information from the Custom Metadata Type, based on the My Domain of the Org.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private CalloutStrategy() {
            this.myDomain = URL.getOrgDomainUrl().toExternalForm().substringAfter('https://').substringBefore('.');
            List<MA_DS_Docusign_CLM_API_Account__mdt> apiAccountList = [SELECT Id, MA_DS_Account_Id__c, MA_DS_Environment__c
                                                                        FROM MA_DS_Docusign_CLM_API_Account__mdt
                                                                        WHERE MA_DS_My_Domain__c = :myDomain];
            this.apiAccount = (apiAccountList.size() > 0) ? apiAccountList[0] : null;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the API Callout Config based on the given type of the Callout Config, used by CalloutStrategy to identify which all implementation classes to initialize for the Callout.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    calloutConfig	    DESCRIPTION (Data Type String, The Callout Config to uniquely identify the API Callout Config metadata type record)
        * @return   CalloutStrategy     DESCRIPTION (return CalloutStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public CalloutStrategy setCalloutConfig(String calloutConfig) {
            try {
                this.throwExceptionIfMissingAPIAccount();
                this.calloutConfig = calloutConfig;
                List<MA_DS_Docusign_CLM_API_Callout_Config__mdt> configList = this.getAPICalloutConfigList(calloutConfig);
                this.apiCalloutConfig = (configList.size() > 0) ? configList[0] : null;
                this.throwExceptionIfUnknownCalloutConfig();
            }catch(MA_DS_MissingAPIAccountForMyDomainException exType) {
                MA_AbstractLogger.logException(exType, MA_DS_MissingAPIAccountForMyDomainException.class.getName());
            }catch(MA_DS_UnknownCalloutConfigException exType) {
                MA_AbstractLogger.logException(exType, MA_DS_UnknownCalloutConfigException.class.getName());
            }
            return this;
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to throw custom exception MA_DS_MissingAPIAccountForMyDomainException if API account details are missing for the Org.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void throwExceptionIfMissingAPIAccount() {
            if(this.apiAccount == null) {
                throw new MA_DS_MissingAPIAccountForMyDomainException(MA_DS_MissingAPIAccountForMyDomainException.class.getName() + ' : ' + this.myDomain);
            }
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the custom metadata type record for the API Callout Config type passed to it.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    calloutConfig	                                        DESCRIPTION (Data Type String, The Callout Config to uniquely identify the API Callout Config metadata type record)
        * @return   List<MA_DS_Docusign_CLM_API_Callout_Config__mdt>        DESCRIPTION (return List of MA_DS_Docusign_CLM_API_Callout_Config__mdt records)
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private List<MA_DS_Docusign_CLM_API_Callout_Config__mdt> getAPICalloutConfigList(String calloutConfig) {
            return [SELECT Id, MA_DS_Is_Active__c, MA_DS_Docusign_CLM_API_Endpoint__r.MA_DS_API_Version__c, MA_DS_Docusign_CLM_API_Endpoint__r.MA_DS_API_Endpoint_Formatted_String__c, 
                    MA_DS_Docusign_CLM_API_Endpoint__r.MA_DS_API_Resource__c, MA_DS_Docusign_CLM_API_Endpoint__r.MA_DS_Named_Credential__c, MA_DS_API_Resource_Instance__c, MA_DS_HTTP_Method__c, 
                    MA_DS_Request_Timeout__c, MA_DS_Callout_Request_Impl__c, MA_DS_Callout_Request_Params_Impl__c, MA_DS_Callout_Response_Callback_Impl__c, MA_DS_Callout_Service_Impl__c, MA_DS_Number_Of_Retries__c
                    FROM MA_DS_Docusign_CLM_API_Callout_Config__mdt
                    WHERE DeveloperName = :calloutConfig];
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to throw custom exception MA_DS_UnknownCalloutConfigException if API Callout Config is unknown and doesn't map to any metadata type record.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void throwExceptionIfUnknownCalloutConfig() {
            if(this.apiCalloutConfig == null) {
                throw new MA_DS_UnknownCalloutConfigException(MA_DS_UnknownCalloutConfigException.class.getName() + ' : ' + this.calloutConfig);
            }
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to dynamically initialize the class of type CalloutRequestParams, based on the API Callout config metadata type record.
        * The Framework also deserializes the Params in an XML string format (accepted by Docusign API payload).
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    requestParams	    DESCRIPTION (Data Type Object, Object type Params that need to be added in the API callout payload)
        * @return   CalloutStrategy     DESCRIPTION (return CalloutStrategy instance)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public CalloutStrategy setCalloutRequestParams(Object requestParams) {
            if(requestParams != null && this.apiCalloutConfig.MA_DS_Is_Active__c) {
                initCalloutRequestParams();
                this.calloutRequestParams.deserializeParams(requestParams);
            }
            return this;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to dynamically initialize the class of type CalloutRequestParams, based on the API Callout config metadata type record.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void initCalloutRequestParams() {
            String httpRequestParamsImpl = this.apiCalloutConfig.MA_DS_Callout_Request_Params_Impl__c;
            this.calloutRequestParams = (CalloutRequestParams)getSingletonInstance(Type.forName(httpRequestParamsImpl));
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to dynamically initialize the class of type CalloutRequestParams, based on the API Callout config metadata type record.
        * The Framework also deserializes the Params in an XML string format (accepted by Docusign API payload).
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    requestParams	    DESCRIPTION (Data Type RequestParams, RequestParams type Params that need to be added in the API callout payload)
        * @return   CalloutStrategy     DESCRIPTION (return CalloutStrategy instance)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public CalloutStrategy setCalloutRequestParams(RequestParams requestParams) {
            if(requestParams != null && this.apiCalloutConfig.MA_DS_Is_Active__c) {
                initCalloutRequestParams();
                this.calloutRequestParams.deserializeParams(requestParams);
            }
            return this;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to dynamically initialize the class of type CalloutRequest, based on the API Callout config metadata type record.
        * The Framework also initializes the properties that are needed to form the HttpRequest instance.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   CalloutStrategy     DESCRIPTION (return CalloutStrategy instance)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public CalloutStrategy setCalloutRequest() {
            if(this.apiCalloutConfig.MA_DS_Is_Active__c) {
                this.initCalloutRequest();
                String requestEndpoint = this.calloutRequest.getCalloutEndpoint(this.apiAccount.MA_DS_Account_Id__c, this.apiCalloutConfig.MA_DS_Docusign_CLM_API_Endpoint__r.MA_DS_API_Endpoint_Formatted_String__c, 
                                                                                this.apiCalloutConfig.MA_DS_Docusign_CLM_API_Endpoint__r.MA_DS_Named_Credential__c, this.apiCalloutConfig.MA_DS_Docusign_CLM_API_Endpoint__r.MA_DS_API_Version__c, 
                                                                                this.apiCalloutConfig.MA_DS_Docusign_CLM_API_Endpoint__r.MA_DS_API_Resource__c);
                this.prepCalloutRequest(requestEndpoint);

                if(String.isNotBlank(this.apiCalloutConfig.MA_DS_API_Resource_Instance__c) && this.calloutRequestParams != null) {
                    this.calloutRequest.setCalloutRequestBody(this.apiCalloutConfig.MA_DS_API_Resource_Instance__c, this.calloutRequestParams);
                }
            }
            return this;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to dynamically initialize the class of type CalloutRequest, based on the API Callout config metadata type record.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void initCalloutRequest() {
            String httpRequestImpl = this.apiCalloutConfig.MA_DS_Callout_Request_Impl__c;
            this.calloutRequest = (CalloutRequest)getSingletonInstance(Type.forName(httpRequestImpl));
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to dynamically initialize the class of type CalloutRequest, based on the API Callout config metadata type record.
        * The Framework also initializes the properties that are needed to form the HttpRequest instance.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    apiResourceInstanceId	    DESCRIPTION (Data Type String, Instance / Record Id for the CLM / e-Sign API)
        * @return   CalloutStrategy             DESCRIPTION (return CalloutStrategy instance)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public CalloutStrategy setCalloutRequest(String apiResourceInstanceId) {
            if(String.isNotBlank(apiResourceInstanceId) && this.apiCalloutConfig.MA_DS_Is_Active__c) {
                this.initCalloutRequest();
                String requestEndpoint = this.calloutRequest.getCalloutEndpoint(apiResourceInstanceId, this.apiAccount.MA_DS_Account_Id__c, this.apiCalloutConfig.MA_DS_Docusign_CLM_API_Endpoint__r.MA_DS_API_Endpoint_Formatted_String__c, 
                                                                                this.apiCalloutConfig.MA_DS_Docusign_CLM_API_Endpoint__r.MA_DS_Named_Credential__c, this.apiCalloutConfig.MA_DS_Docusign_CLM_API_Endpoint__r.MA_DS_API_Version__c, 
                                                                                this.apiCalloutConfig.MA_DS_Docusign_CLM_API_Endpoint__r.MA_DS_API_Resource__c);
                this.prepCalloutRequest(requestEndpoint);
            }
            return this;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to initializes the properties that are needed to form the HttpRequest instance, used by class of type CalloutRequest.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    requestEndpoint	                    DESCRIPTION (Data Type String, The Endpoint for the HttpRequest)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void prepCalloutRequest(String requestEndpoint) {
            Integer requestTimeout = Integer.valueOf(this.apiCalloutConfig.MA_DS_Request_Timeout__c);
            this.calloutRequest.prepCalloutRequest(this.apiCalloutConfig.MA_DS_HTTP_Method__c, requestTimeout, requestEndpoint);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to dynamically initialize the class of type ResponseCallback, based on the API Callout config metadata type record.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   CalloutStrategy     DESCRIPTION (return CalloutStrategy instance)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public CalloutStrategy setResponseCallback() {
            if(this.apiCalloutConfig.MA_DS_Is_Active__c) {
                String httpResponseImpl = this.apiCalloutConfig.MA_DS_Callout_Response_Callback_Impl__c;
                this.responseCallback = (ResponseCallback)getSingletonInstance(Type.forName(httpResponseImpl));
            }
            return this;
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to dynamically initialize the class of type CalloutService, based on the API Callout config metadata type record.
        * The Framework also sets the number of retries for the callout (in case of failure during sending the API Request).
        * The Framework also sends the API Request synchronously using callout() method in CalloutService.
        * Caller must invoke this method from asynchronous context, using @future(callout=true) or from a Queueable context that implements Database.AllowsCallouts interface.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    sourceRecordId	    DESCRIPTION (Data Type Id, The source record Id from where the callout is initiated, used by the ResponseCallback type to perform post callout action (if any))
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void initCallout(Id sourceRecordId) {
            if(this.apiCalloutConfig.MA_DS_Is_Active__c) {
                this.sourceRecordId = sourceRecordId;
                String calloutServiceImpl = this.apiCalloutConfig.MA_DS_Callout_Service_Impl__c;
                
                CalloutService calloutService = (CalloutService)getSingletonInstance(Type.forName(calloutServiceImpl));
                calloutService.setNumberOfRetries(Integer.valueOf(this.apiCalloutConfig.MA_DS_Number_Of_Retries__c))
                              .callout(this.sourceRecordId, this.calloutRequest, this.responseCallback);
            }
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to dynamically initialize the class of type CalloutService, based on the API Callout config metadata type record.
        * The Framework also sets the number of retries for the callout (in case of failure during sending the API Request).
        * The Framework also sends the API Request asynchronously (within a Queueable Job) using callout() method in CalloutService.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    sourceRecordId	    DESCRIPTION (Data Type Id, The source record Id from where the callout is initiated, used by the ResponseCallback type to perform post callout action (if any))
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void initAsyncCallout(Id sourceRecordId) {
            if(this.apiCalloutConfig.MA_DS_Is_Active__c) {
                this.sourceRecordId = sourceRecordId;
                String calloutServiceImpl = this.apiCalloutConfig.MA_DS_Callout_Service_Impl__c;
                
                CalloutService calloutService = (CalloutService)getSingletonInstance(Type.forName(calloutServiceImpl));
                calloutService.setNumberOfRetries(Integer.valueOf(this.apiCalloutConfig.MA_DS_Number_Of_Retries__c))
                              .asyncCallout(this.sourceRecordId, this.calloutRequest, this.responseCallback);
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Interface implemented by each Callout Config, to perform actions on the requestParams and convert it to API accepted format.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public interface CalloutRequestParams {
        RequestParams getRequestParams();
        void deserializeParams(Object requestParams);
        void deserializeParams(RequestParams requestParams);
        String serializeToXML(Boolean serializeNulls, String rootElement);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Interface implemented by each Callout Config, to perform actions on the HttpRequest properties along with the Payload of the HttpRequest.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public interface CalloutRequest {
        HttpRequest initHttpRequest();
        RequestParams getRequestParams();
        void prepCalloutRequest(String httpMethod, Integer requestTimeout, String requestEndpoint);
        void setCalloutRequestBody(String resourceInstance, CalloutRequestParams calloutRequestParams);
        String getCalloutEndpoint(String apiAccountId, String apiEndpointFormattedStr, String namedCredential, String apiVersion, String apiResource);
        String getCalloutEndpoint(String apiResourceInstanceId, String apiResource, String apiEndpointFormattedStr, String namedCredential, String apiVersion, String apiAccountId);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Interface implemented by each Callout Config, to perform post Callout actions or to handle the HttpResponse of the API callout.
    * handleResponse()  : @throws CalloutServiceException & @throws CalloutResponseException
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public interface ResponseCallback {
        ResponseCallback setCalloutException(CalloutServiceException exType);
        void notifyTarget(String messagingConfig, String title, String body, Id target);
        void handleResponse(Id srcRecordId, HttpRequest clmAPIRequest, HttpResponse clmAPIResponse);
        void handleResponse(Id srcRecordId, RequestParams requestParams, HttpRequest clmAPIRequest, HttpResponse clmAPIResponse);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Interface implemented by each Callout Config, to send API Request synchronously / asynchronously and invokes handleResponse() method of ResponseCallback.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public interface CalloutService extends Database.AllowsCallouts {
        CalloutService setNumberOfRetries(Integer numberOfRetries);
        void callout(Id srcRecordId, CalloutRequest calloutRequest, ResponseCallback responseCallback);
        void asyncCallout(Id srcRecordId, CalloutRequest calloutRequest, ResponseCallback responseCallback);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Interface to be implemented by wrapper classes that are passed as requestParams to the Callout Framework.
    * The CalloutRequestParams handles the requestParams, type casts it into actual implementation of the RequestParams before converting it into the API accepted format.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public interface RequestParams {
        void setSuccessResponse(Boolean successResponse);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception to be thrown when Docusign CLM API account details are missing for the Org.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class MA_DS_MissingAPIAccountForMyDomainException extends Exception {}

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception to be thrown when API Callout Config is not known or doesn't exist in the metadata type record.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class MA_DS_UnknownCalloutConfigException extends Exception {}

    private static final String STATUS_CODE_KEY = Label.MA_DS_Status_Code_Key;
    private static final String STACK_TRACE_KEY = Label.MA_DS_Stack_Trace_Key;
    private static final String STATUS_MESSAGE_KEY = Label.MA_DS_Status_Message_Key;
    private static final String CALLOUT_SERVICE_EXCEPTION_KEY = CalloutServiceException.class.getName();
    private static final String CALLOUT_RESPONSE_EXCEPTION_KEY = CalloutResponseException.class.getName();

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception to override the message for the exception thrown while sending the API Request, after all attempts of retries are finished.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class CalloutServiceException extends Exception {
        private Object clmRequestBody;
        private String exceptionMessage;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the CalloutServiceException class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public CalloutServiceException(String exceptionMessage, String clmRequestBody) {
            this.exceptionMessage = exceptionMessage;
            this.clmRequestBody = String.isBlank(clmRequestBody) ? null : JSON.deserializeUntyped(clmRequestBody);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method overrides the getMessage() method of the Exception class to return the custom exception message.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getMessage() {
            return exceptionMessage;
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method overrides the getStackTraceString() method of the Exception class to return the Stack Trace of the custom exception.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getStackTraceString() {
            Map<String, Object> stackTrace = new Map<String, Object> {CALLOUT_SERVICE_EXCEPTION_KEY => JSON.serialize(this), STACK_TRACE_KEY => super.getStackTraceString()};
            return JSON.serialize(stackTrace);
        }
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception to override the message for the exception thrown while sending the Status Code returned in the HttpResponse is greater than 300.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class CalloutResponseException extends Exception {
        private Integer statusCode;
        private String statusMessage;
        private Object clmRequestBody;
        private Object errorResponseBody;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the CalloutResponseException class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public CalloutResponseException(Integer statusCode, String statusMessage, Object errorResponseBody, String clmRequestBody) {
            this.statusCode = statusCode;
            this.statusMessage = statusMessage;
            this.errorResponseBody = errorResponseBody;
            this.clmRequestBody = String.isBlank(clmRequestBody) ? null : JSON.deserializeUntyped(clmRequestBody);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method overrides the getMessage() method of the Exception class to return the custom exception message.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getMessage() {
            Map<String, Object> message = new Map<String, Object> {STATUS_CODE_KEY => this.statusCode, STATUS_MESSAGE_KEY => this.statusMessage};
            return JSON.serialize(message);
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method overrides the getStackTraceString() method of the Exception class to return the Stack Trace of the custom exception.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getStackTraceString() {
            Map<String, Object> stackTrace = new Map<String, Object> {CALLOUT_RESPONSE_EXCEPTION_KEY => JSON.serialize(this), STACK_TRACE_KEY => super.getStackTraceString()};
            return JSON.serialize(stackTrace);
        }
    }
}