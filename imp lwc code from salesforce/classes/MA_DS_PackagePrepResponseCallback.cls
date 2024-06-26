/**
 * W-13011399
 * Extends MA_DS_AbstractResponseCallback class to handle success & error response for the CLM API request to Package Prep Workflow.
 * 
 * Version      Date            Author                  Description
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         30/04/2023      Chakshu Malhotra        W-13011399 - Adds logic to handle response for the CLM API request to Package Prep Workflow.
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_PackagePrepResponseCallback extends MA_DS_AbstractResponseCallback {

    private static final String STATUS_OK = Label.MA_DS_Status_Code_OK;
    private static final String STATUS_OBJECT_CREATED = Label.MA_DS_Status_Code_Object_Created;
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to parse HttpResponse and invoke success / failure handler based on the Status code received in the response.
    * Provides handler for CalloutException (if any) during API callout.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                    DESCRIPTION (Data Type Id, Source Record Id from where the API Request is sent)
    * @param    requestParams	                DESCRIPTION (Data Type MA_DS_CalloutFramework.RequestParams , RequestParams type Params that is added in the API callout payload)
    * @param    clmAPIRequest	                DESCRIPTION (Data Type HttpRequest, Http API Request instance)
    * @param    clmAPIResponse	                DESCRIPTION (Data Type HttpResponse, Http API Response instance)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void handleResponse(Id srcRecordId, MA_DS_CalloutFramework.RequestParams requestParams, HttpRequest clmAPIRequest, HttpResponse clmAPIResponse) {
        try {
            super.handleResponse(srcRecordId, clmAPIRequest, clmAPIResponse);
            if(this.responseStatusCode == Integer.valueOf(STATUS_OBJECT_CREATED) || this.responseStatusCode == Integer.valueOf(STATUS_OK)) {
                this.handleSuccessResponse(requestParams);
            }
        }catch(MA_DS_CalloutFramework.CalloutServiceException exType) {
            this.handleErrorResponse(exType, MA_DS_CalloutFramework.CalloutServiceException.class.getName(), requestParams);
        }catch(MA_DS_CalloutFramework.CalloutResponseException exType) {
            this.handleErrorResponse(exType, MA_DS_CalloutFramework.CalloutResponseException.class.getName(), requestParams);
        }catch(Exception exType) {
            this.handleErrorResponse(exType, exType.getTypeName(), requestParams);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to handle Error response, sets "successResponse" as false in MA_DS_CalloutFramework.RequestParams instance.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    exType	                        DESCRIPTION (Data Type Exception, Exception type instance)
    * @param    exIdentifier	                DESCRIPTION (Data Type String, Exception Identifier to be logged to PF Debug Log)
    * @param    requestParams	                DESCRIPTION (Data Type MA_DS_CalloutFramework.RequestParams , RequestParams type Params that is added in the API callout payload)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void handleErrorResponse(Exception exType, String exIdentifier, MA_DS_CalloutFramework.RequestParams requestParams) {
        super.handleErrorResponse(exType, exIdentifier);
        requestParams.setSuccessResponse(false);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to handle Success response, sets "successResponse" as true in MA_DS_CalloutFramework.RequestParams instance.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    requestParams	                DESCRIPTION (Data Type MA_DS_CalloutFramework.RequestParams , RequestParams type Params that is added in the API callout payload)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void handleSuccessResponse(MA_DS_CalloutFramework.RequestParams requestParams) {
        requestParams.setSuccessResponse(true);
    }
}