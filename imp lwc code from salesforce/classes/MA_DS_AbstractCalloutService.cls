/**
 * ******************************************** W-12535956 : API CALLOUT FRAMEWORK ********************************************
 * 
 * Implements Abstract Class for CalloutService to asynchronously initiate a callout to CLM API within a Queueable job.
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         27/02/2023      Chakshu Malhotra        W-12535956 - Adds an abstract class to make CLM API callout within a Queueable job.
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_AbstractCalloutService implements MA_DS_CalloutFramework.CalloutService, System.Queueable {
    
    public Id srcRecordId {get; private set;}
    public Integer currentRetryNumber {get; set;}
    public Integer numberOfRetries {get; private set;}
    
    protected MA_DS_CalloutFramework.RequestParams requestParams {get; set;}

    public MA_DS_CalloutFramework.CalloutRequest calloutRequest {get; private set;}
    public MA_DS_CalloutFramework.ResponseCallback responseCallback {get; private set;}
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set the CalloutRequest & ResponseCallback instance along with the Source Record Id for the API request.
    * Method overridden by the sub-class to synchronously sends an API Request from an asynchrnous context.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                    DESCRIPTION (Data Type Id, Source Record Id from where the API Request is sent)
    * @param    calloutRequest	                DESCRIPTION (Data Type MA_DS_CalloutFramework.CalloutRequest, CalloutRequest instance)
    * @param    responseCallback	            DESCRIPTION (Data Type MA_DS_CalloutFramework.ResponseCallback, ResponseCallback instance)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public virtual void callout(Id srcRecordId, MA_DS_CalloutFramework.CalloutRequest calloutRequest, MA_DS_CalloutFramework.ResponseCallback responseCallback) {
        this.initCalloutParams(srcRecordId, calloutRequest, responseCallback);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set the CalloutRequest & ResponseCallback instance along with the Source Record Id for the API request.
    * Method overridden by the sub-class to asynchronously sends an API Request within a Queueable job.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                    DESCRIPTION (Data Type Id, Source Record Id from where the API Request is sent)
    * @param    calloutRequest	                DESCRIPTION (Data Type MA_DS_CalloutFramework.CalloutRequest, CalloutRequest instance)
    * @param    responseCallback	            DESCRIPTION (Data Type MA_DS_CalloutFramework.ResponseCallback, ResponseCallback instance)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public virtual void asyncCallout(Id srcRecordId, MA_DS_CalloutFramework.CalloutRequest calloutRequest, MA_DS_CalloutFramework.ResponseCallback responseCallback) {
        this.initCalloutParams(srcRecordId, calloutRequest, responseCallback);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set the CalloutRequest & ResponseCallback instance along with the Source Record Id for the API request.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                    DESCRIPTION (Data Type Id, Source Record Id from where the API Request is sent)
    * @param    calloutRequest	                DESCRIPTION (Data Type MA_DS_CalloutFramework.CalloutRequest, CalloutRequest instance)
    * @param    responseCallback	            DESCRIPTION (Data Type MA_DS_CalloutFramework.ResponseCallback, ResponseCallback instance)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void initCalloutParams(Id srcRecordId, MA_DS_CalloutFramework.CalloutRequest calloutRequest, MA_DS_CalloutFramework.ResponseCallback responseCallback) {
        this.currentRetryNumber = -1;
        this.srcRecordId = srcRecordId;
        this.calloutRequest = calloutRequest;
        this.responseCallback = responseCallback;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set the Number of Retries (in case of CalloutException) for the API request, based on the API Callout Config.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    numberOfRetries	                            DESCRIPTION (Data Type Integer, Number of Retries of the API Callout Request, based on API Callout Config)
    * @return   MA_DS_CalloutFramework.CalloutService       DESCRIPTION (return the CalloutService instance)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public virtual MA_DS_CalloutFramework.CalloutService setNumberOfRetries(Integer numberOfRetries) {
        this.numberOfRetries = numberOfRetries;
        return this;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & return an instance of custom exception of type MA_DS_CalloutFramework.CalloutServiceException.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    exType	                                            DESCRIPTION (Data Type Exception, Exception type instance)
    * @param    clmAPIRequest	                                    DESCRIPTION (Data Type HttpRequest, HttpRequest instance)
    * @return   MA_DS_CalloutFramework.CalloutServiceException      DESCRIPTION (return the CalloutService instance)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    protected MA_DS_CalloutFramework.CalloutServiceException getCalloutServiceException(Exception exType, HttpRequest clmAPIRequest) {
        return new MA_DS_CalloutFramework.CalloutServiceException(exType.getMessage(), clmAPIRequest.getBody());
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to be overridden by the sub-class, to synchronously execute the API Callout Request.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public virtual void execute() {}
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to be overridden by the sub-class, to asynchronously execute the API Callout Request from within a Queueable context.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public virtual void execute(System.QueueableContext qContext) {}
}