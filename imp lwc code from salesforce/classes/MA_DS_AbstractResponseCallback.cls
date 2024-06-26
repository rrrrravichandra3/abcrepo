/**
 * ******************************************** W-12535956 : API CALLOUT FRAMEWORK ********************************************
 * 
 * Implements Abstract Class for ResponseCallback to handle HttpResponse for the CLM API request.
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         26/02/2023      Chakshu Malhotra        W-12535956 - Adds an abstract class to handle response for the API request.
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_AbstractResponseCallback implements MA_DS_CalloutFramework.ResponseCallback {

    public Id srcRecordId {get; private set;}
    public Object responseBody {get; private set;}
    public String statusMessage {get; private set;}
    public Integer responseStatusCode {get; private set;}
    private MA_DS_CalloutFramework.CalloutServiceException calloutServiceExType;

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set MA_DS_CalloutFramework.CalloutServiceException in case of CalloutException while sending the API request.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    exType	                                    DESCRIPTION (Data Type MA_DS_CalloutFramework.CalloutServiceException, Exception instance)
    * @return   MA_DS_CalloutFramework.ResponseCallback     DESCRIPTION (return the ResponseCallback instance)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public MA_DS_CalloutFramework.ResponseCallback setCalloutException(MA_DS_CalloutFramework.CalloutServiceException exType) {
        this.calloutServiceExType = exType;
        return this;
    }
    
    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to handle the CLM API Response, throws error if CalloutException is set already or the Status Code > 300.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                            DESCRIPTION (Data Type Id, Source Record Id from where the API Request is sent)
    * @param    clmAPIRequest	                        DESCRIPTION (Data Type HttpRequest, CLM API Request)
    * @param    clmAPIResponse	                        DESCRIPTION (Data Type HttpResponse, CLM API Response)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public virtual void handleResponse(Id srcRecordId, HttpRequest clmAPIRequest, HttpResponse clmAPIResponse) {
        this.srcRecordId = srcRecordId;
        
        if(this.calloutServiceExType != null) {
            throw this.calloutServiceExType;
        }else {
            initResponseCallbackParams(clmAPIRequest, clmAPIResponse);
        }
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to store the CLM Response and throws CalloutResponseException exception if Status Code > 300.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    clmAPIRequest	                        DESCRIPTION (Data Type HttpRequest, CLM API Request)
    * @param    clmAPIResponse	                        DESCRIPTION (Data Type HttpResponse, CLM API Response)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void initResponseCallbackParams(HttpRequest clmAPIRequest, HttpResponse clmAPIResponse) {
        this.statusMessage = clmAPIResponse.getStatus();
        this.responseStatusCode = clmAPIResponse.getStatusCode();
        this.responseBody = JSON.deserializeUntyped(clmAPIResponse.getBody());

        if(this.responseStatusCode > 300) {
            throw new MA_DS_CalloutFramework.CalloutResponseException(this.responseStatusCode, this.statusMessage, this.responseBody, clmAPIRequest.getBody());
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to handle Error Response, in case an Exception is thrown. Logs exception to PF Debug Log object.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    exType	                        DESCRIPTION (Data Type Exception, Exception type instance)
    * @param    exIdentifier	                DESCRIPTION (Data Type String, Exception Identifier to be logged to PF Debug Log)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    protected virtual void handleErrorResponse(Exception exType, String exIdentifier) {
        MA_AbstractLogger.logException(exType, exIdentifier);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to notify user in case an exception is thrown while sending the API Request or when Status Code > 300 or any other exception.
    * Also logs exception to PF Debug Log object.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    exType	                        DESCRIPTION (Data Type Exception, Exception type instance)
    * @param    exIdentifier	                DESCRIPTION (Data Type String, Exception Identifier to be logged to PF Debug Log)
    * @param    messagingConfig	                DESCRIPTION (Data Type String, Messaging Config type to fetch the custom metadata type record)
    * @param    title	                        DESCRIPTION (Data Type String, Title of the Messaging Notification)
    * @param    body	                        DESCRIPTION (Data Type String, Body of the Messaging Notification)
    * @param    target	                        DESCRIPTION (Data Type String, Target / Landing Record Page for the Messaging Notification)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public virtual void handleErrorResponse(Exception exType, String exIdentifier, String messagingConfig, String title, String body, Id target) {
        this.notifyTarget(messagingConfig, title, body, target);
        this.handleErrorResponse(exType, exIdentifier);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to notify user in case an exception is thrown while sending the API Request or when Status Code > 300 or any other exception.
    * Also used to send success notification to the Target user, if no error is encountered while sending the API Request or no errors in the HttpResponse.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    messagingConfig	                DESCRIPTION (Data Type String, Messaging Config type to fetch the custom metadata type record)
    * @param    title	                        DESCRIPTION (Data Type String, Title of the Messaging Notification)
    * @param    body	                        DESCRIPTION (Data Type String, Body of the Messaging Notification)
    * @param    target	                        DESCRIPTION (Data Type String, Target / Landing Record Page for the Messaging Notification)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public virtual void notifyTarget(String messagingConfig, String title, String body, Id target) {
        Set<String> userIds = new Set<String> {String.valueOf(UserInfo.getUserId())};
        MA_MessageProcessing.initNotificationMessaging(messagingConfig, title, body, String.valueOf(target), userIds, MA_Messaging.NotificationTargetType.RECORD_ID_TYPE);
        MA_MessageProcessing.processMessages(MA_MessageProcessing.ExecutionType.NOTIFICATION_JOB);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to be overridden by the sub-class, to handle the CLM API Response for the HttpRequest.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public virtual void handleResponse(Id srcRecordId, MA_DS_CalloutFramework.RequestParams requestParams, HttpRequest clmAPIRequest, HttpResponse clmAPIResponse) {}
}