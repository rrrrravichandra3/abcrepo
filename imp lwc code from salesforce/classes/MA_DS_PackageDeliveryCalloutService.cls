/**
 * W-13465459
 * Extends MA_DS_AbstractCalloutService class to make synchronous API Callout to Docusign CLM API to start Package Delivery workflow.
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         27/05/2023      Chakshu Malhotra        W-13465459 - Adds logic to make a callout to start Package Delivery workflow.
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_PackageDeliveryCalloutService extends MA_DS_AbstractCalloutService {
    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set the CalloutRequest & ResponseCallback instance along with the Source Record Id for the Package Delivery API request.
    * Synchronously sends an API Request from.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                    DESCRIPTION (Data Type Id, Source Record Id from where the API Request is sent)
    * @param    calloutRequest	                DESCRIPTION (Data Type MA_DS_CalloutFramework.CalloutRequest, CalloutRequest instance)
    * @param    responseCallback	            DESCRIPTION (Data Type MA_DS_CalloutFramework.ResponseCallback, ResponseCallback instance)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void callout(Id srcRecordId, MA_DS_CalloutFramework.CalloutRequest calloutRequest, MA_DS_CalloutFramework.ResponseCallback responseCallback) {
        super.callout(srcRecordId, calloutRequest, responseCallback);
        this.requestParams = calloutRequest.getRequestParams();
        this.execute();
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Send an API request to Docusign CLM for the Package Delivery workflow.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void execute() {
        Http httpInstance = new Http();
        HttpRequest clmAPIRequest = this.calloutRequest.initHttpRequest();
        this.startPackageDeliveryWorkflow(httpInstance, clmAPIRequest);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sends HttpRequest to Docusign CLM to initiate the Package Delivery workflow. In case of CalloutException, the request is retried based on the Callout Config.
    * If request fails after all retries, the Exception is thrown and handled in the ResponseCallback implementation.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    httpInstance	                DESCRIPTION (Data Type Http, Http instance used to send the API request)
    * @param    clmAPIRequest	                DESCRIPTION (Data Type HttpRequest, Http API Request instance)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void startPackageDeliveryWorkflow(Http httpInstance, HttpRequest clmAPIRequest) {
        try {
            this.currentRetryNumber++;
            HttpResponse clmAPIResponse = httpInstance.send(clmAPIRequest);
            this.responseCallback.handleResponse(this.srcRecordId, this.requestParams, clmAPIRequest, clmAPIResponse);
        }catch(Exception exType) {
            this.handleCalloutException(exType, httpInstance, clmAPIRequest);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Handles CalloutException that might occur while sending the Http API Request to Docusign CLM. Method to attempt retry, based on Callout Config.
    * If request fails after all retries, CalloutServiceException instance is created and set in the ResponseCallback implementation.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    exType	                        DESCRIPTION (Data Type Exception, Exception type instance)
    * @param    httpInstance	                DESCRIPTION (Data Type Http, Http instance used to send the API request)
    * @param    clmAPIRequest	                DESCRIPTION (Data Type HttpRequest, Http API Request instance)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void handleCalloutException(Exception exType, Http httpInstance, HttpRequest clmAPIRequest) {
        if(this.currentRetryNumber < this.numberOfRetries) {
            this.startPackageDeliveryWorkflow(httpInstance, clmAPIRequest);
        }else {
            this.responseCallback.setCalloutException(this.getCalloutServiceException(exType, clmAPIRequest))
                                 .handleResponse(this.srcRecordId, this.requestParams, null, null);
        }
    }
}