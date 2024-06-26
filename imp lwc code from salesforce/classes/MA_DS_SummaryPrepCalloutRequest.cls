/**
 * W-12578116
 * Extends MA_DS_AbstractCalloutRequest class to invoke serialization of Params attribute content and set body of the HttpRequest.
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         30/03/2023      Chakshu Malhotra        W-12578116 - Adds logic to set body of the HttpRequest after converting content to CLM accepted format.
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_SummaryPrepCalloutRequest extends MA_DS_AbstractCalloutRequest {
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create payload for the HttpRequest, by serializing the Manager Summary Prep Params into XML format & wrapping it within a Root Element.
    * Sets HttpRequest body using the serialized Params & the Resource / Instance Name of the Manager Summary Prep workflow.
    * Stores MA_DS_CalloutFramework.CalloutRequestParams instance, to be used later in the ResponseCallback implementation.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    resourceInstance	            DESCRIPTION (Data Type String, Workflow instance / resource name)
    * @param    calloutRequestParams	        DESCRIPTION (Data Type MA_DS_CalloutFramework.CalloutRequestParams, CalloutRequestParams instance)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void setCalloutRequestBody(String resourceInstance, MA_DS_CalloutFramework.CalloutRequestParams calloutRequestParams) {
        String xmlSerializedParams = calloutRequestParams?.serializeToXML(false, MA_DS_AbstractCalloutRequest.ROOT_ELEMENT_PARAMS);
        this.setRequestBody(resourceInstance, xmlSerializedParams);
        this.requestParams = calloutRequestParams.getRequestParams();
    }
}