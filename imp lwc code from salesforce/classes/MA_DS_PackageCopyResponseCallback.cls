/**
 * W-12456766
 * Extends MA_DS_AbstractResponseCallback class to handle success & error response for the CLM API request to Package Copy Workflow.
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         01/03/2023      Chakshu Malhotra        W-12456766 - Adds logic to handle response for the CLM API request to Package Copy Workflow.
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_PackageCopyResponseCallback extends MA_DS_AbstractResponseCallback {

    private static final String STATUS_OK = Label.MA_DS_Status_Code_OK;
    private static final String STATUS_OBJECT_CREATED = Label.MA_DS_Status_Code_Object_Created;
    private static final String WORKFLOW_STATUS_KEY = Label.MA_DS_Workflow_Object_Attribute_Status;
    private static final String MESSAGING_CONFIG = Label.MA_DS_Messaging_Config_Package_Copy_Callout;

    private static final String ERROR_UNKNOWN_TITLE = Label.MA_DS_Unknown_Error_Title;
    private static final String ERROR_CONTACT_ADMIN_BODY = Label.MA_DS_Error_Contact_Admin_Body;
    private static final String CALLOUT_EXCEPTION_TITLE = Label.MA_DS_Package_Copy_Callout_Exception_Title;
    private static final String SUCCESS_NOTIFICATION_BODY= Label.MA_DS_Package_Copy_Callout_Notification_Body;
    private static final String SUCCESS_NOTIFICATION_TITLE = Label.MA_DS_Package_Copy_Callout_Notification_Title;
    private static final String ERROR_NOTIFICATION_TITLE = Label.MA_DS_Package_Copy_Callout_Notification_Error_Title;
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to parse HttpResponse and invoke success / failure handler based on the Status code received in the response.
    * Provides handler for CalloutException (if any) during API callout.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                    DESCRIPTION (Data Type Id, Source Record Id from where the API Request is sent)
    * @param    clmAPIRequest	                DESCRIPTION (Data Type HttpRequest, Http API Request instance)
    * @param    clmAPIResponse	                DESCRIPTION (Data Type HttpResponse, Http API Response instance)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void handleResponse(Id srcRecordId, HttpRequest clmAPIRequest, HttpResponse clmAPIResponse) {
        try {
            super.handleResponse(srcRecordId, clmAPIRequest, clmAPIResponse);
            if(this.responseStatusCode == Integer.valueOf(STATUS_OBJECT_CREATED) || this.responseStatusCode == Integer.valueOf(STATUS_OK)) {
                this.handleSuccessResponse();
            }
        }catch(MA_DS_CalloutFramework.CalloutServiceException exType) {
            this.handleErrorResponse(exType, MA_DS_CalloutFramework.CalloutServiceException.class.getName(), MESSAGING_CONFIG, CALLOUT_EXCEPTION_TITLE, ERROR_CONTACT_ADMIN_BODY, srcRecordId);
        }catch(MA_DS_CalloutFramework.CalloutResponseException exType) {
            this.handleErrorResponse(exType, MA_DS_CalloutFramework.CalloutResponseException.class.getName(), MESSAGING_CONFIG, ERROR_NOTIFICATION_TITLE, ERROR_CONTACT_ADMIN_BODY, srcRecordId);
        }catch(Exception exType) {
            this.handleErrorResponse(exType, exType.getTypeName(), MESSAGING_CONFIG, ERROR_UNKNOWN_TITLE, ERROR_CONTACT_ADMIN_BODY, srcRecordId);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to handle Success response, sends Custom Notification to the user.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void handleSuccessResponse() {
        Map<String, Object> clmWorkflow = (Map<String, Object>)this.responseBody;
        String workflowStatus = clmWorkflow.containsKey(WORKFLOW_STATUS_KEY) ? (String)clmWorkflow.get(WORKFLOW_STATUS_KEY) : '';
        this.notifyTarget(MESSAGING_CONFIG, SUCCESS_NOTIFICATION_TITLE, String.format(SUCCESS_NOTIFICATION_BODY, new String[]{workflowStatus}), this.srcRecordId);
    }
}