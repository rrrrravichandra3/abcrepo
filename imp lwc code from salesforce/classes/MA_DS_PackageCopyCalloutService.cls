/**
 * W-12456766
 * Extends MA_DS_AbstractCalloutService class to enqueue itslef to make Docusign CLM API Callout to start Master and Custom Package Copy workflow.
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         02/03/2023      Chakshu Malhotra        W-12456766 - Adds logic to make a callout to start Master and Custom Package Copy workflow.
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_PackageCopyCalloutService extends MA_DS_AbstractCalloutService {
    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set the CalloutRequest & ResponseCallback instance along with the Source Record Id for the Package Copy API request.
    * Asynchronously sends an API Request within a Queueable job.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                    DESCRIPTION (Data Type Id, Source Record Id from where the API Request is sent)
    * @param    calloutRequest	                DESCRIPTION (Data Type MA_DS_CalloutFramework.CalloutRequest, CalloutRequest instance)
    * @param    responseCallback	            DESCRIPTION (Data Type MA_DS_CalloutFramework.ResponseCallback, ResponseCallback instance)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void asyncCallout(Id srcRecordId, MA_DS_CalloutFramework.CalloutRequest calloutRequest, MA_DS_CalloutFramework.ResponseCallback responseCallback) {
        super.asyncCallout(srcRecordId, calloutRequest, responseCallback);
        MA_DS_QueueableUtil.execute(this);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable interface method to send an API request to Docusign CLM for the Package Copy workflow.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void execute(System.QueueableContext qContext) {
        Http httpInstance = new Http();
        HttpRequest clmAPIRequest = this.calloutRequest.initHttpRequest();
        this.startPackageCopyWorkflow(httpInstance, clmAPIRequest);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sends HttpRequest to Docusign CLM to initiate the Package Copy workflow. In case of CalloutException, the request is retried based on the Callout Config.
    * If request fails after all retries, the Exception is thrown and handled in the ResponseCallback implementation.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    httpInstance	                DESCRIPTION (Data Type Http, Http instance used to send the API request)
    * @param    clmAPIRequest	                DESCRIPTION (Data Type HttpRequest, Http API Request instance)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void startPackageCopyWorkflow(Http httpInstance, HttpRequest clmAPIRequest) {
        try {
            this.currentRetryNumber++;
            HttpResponse clmAPIResponse = httpInstance.send(clmAPIRequest);
            this.responseCallback.handleResponse(this.srcRecordId, clmAPIRequest, clmAPIResponse);
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
            this.startPackageCopyWorkflow(httpInstance, clmAPIRequest);
        }else {
            this.responseCallback.setCalloutException(this.getCalloutServiceException(exType, clmAPIRequest))
                                 .handleResponse(this.srcRecordId, null, null);
        }
    } 
}