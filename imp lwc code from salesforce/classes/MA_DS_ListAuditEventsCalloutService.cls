/**
 * W-12218399
 * Extends MA_DS_AbstractCalloutService class to make synchronous API Callout to Docusign eSignature API to fetch the ClientIPAddress of the Signer.
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         15/11/2023      Chakshu Malhotra        W-12218399 - Adds logic to make a callout to fetch the ClientIPAddress of the Signer.
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_ListAuditEventsCalloutService extends MA_DS_AbstractCalloutService {
    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set the CalloutRequest & ResponseCallback instance along with the Source Record Id for the List Audit Events API request.
    * Synchronously sends an API Request from.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                    DESCRIPTION (Data Type Id, Source Record Id for which the API Request is sent)
    * @param    calloutRequest	                DESCRIPTION (Data Type MA_DS_CalloutFramework.CalloutRequest, CalloutRequest instance)
    * @param    responseCallback	            DESCRIPTION (Data Type MA_DS_CalloutFramework.ResponseCallback, ResponseCallback instance)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void callout(Id srcRecordId, MA_DS_CalloutFramework.CalloutRequest calloutRequest, MA_DS_CalloutFramework.ResponseCallback responseCallback) {
        super.callout(srcRecordId, calloutRequest, responseCallback);
        this.execute();
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Send an API request to Docusign eSignature to fetch the ClientIPAddress of the Signer.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void execute() {
        Http httpInstance = new Http();
        HttpRequest eSignAPIRequest = this.calloutRequest.initHttpRequest();
        this.getListAuditEvents(httpInstance, eSignAPIRequest);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sends HttpRequest to get List of Audit Events for the Envelope Id. In case of CalloutException, the request is retried based on the Callout Config.
    * If request fails after all retries, the Exception is thrown and handled in the ResponseCallback implementation.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    httpInstance	                DESCRIPTION (Data Type Http, Http instance used to send the API request)
    * @param    eSignAPIRequest	                DESCRIPTION (Data Type HttpRequest, Http API Request instance)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void getListAuditEvents(Http httpInstance, HttpRequest eSignAPIRequest) {
        try {
            this.currentRetryNumber++;
            HttpResponse eSignAPIResponse = httpInstance.send(eSignAPIRequest);
            this.responseCallback.handleResponse(this.srcRecordId, eSignAPIRequest, eSignAPIResponse);
        }catch(Exception exType) {
            this.handleCalloutException(exType, httpInstance, eSignAPIRequest);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Handles CalloutException that might occur while sending the Http API Request to Docusign eSignature. Method to attempt retry, based on Callout Config.
    * If request fails after all retries, CalloutServiceException instance is created and set in the ResponseCallback implementation.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    exType	                        DESCRIPTION (Data Type Exception, Exception type instance)
    * @param    httpInstance	                DESCRIPTION (Data Type Http, Http instance used to send the API request)
    * @param    eSignAPIRequest	                DESCRIPTION (Data Type HttpRequest, Http API Request instance)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void handleCalloutException(Exception exType, Http httpInstance, HttpRequest eSignAPIRequest) {
        if(this.currentRetryNumber < this.numberOfRetries) {
            this.getListAuditEvents(httpInstance, eSignAPIRequest);
        }else {
            this.responseCallback.setCalloutException(this.getCalloutServiceException(exType, eSignAPIRequest))
                                 .handleResponse(this.srcRecordId, null, null);
        }
    }
}