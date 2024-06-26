/**
 * W-13484430 & W-13576017
 * Extends MA_DS_AbstractResponseCallback class to handle success & error response for the CLM API request to Package Mass Recall Workflow.
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         21/06/2023      Chakshu Malhotra        W-13484430 & W-13576017 - Adds logic to handle response for the CLM API request to Package Mass Recall Workflow.
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_PackageRecallResponseCallback extends MA_DS_AbstractResponseCallback {

    private static final String STATUS_OK = Label.MA_DS_Status_Code_OK;
    private static final String STATUS_OBJECT_CREATED = Label.MA_DS_Status_Code_Object_Created;
    private static final String WORKFLOW_STATUS_KEY = Label.MA_DS_Workflow_Object_Attribute_Status;
    private static final String MESSAGING_CONFIG = Label.MA_DS_Messaging_Config_Package_Mass_Recall_Callout;

    private static final String ERROR_UNKNOWN_TITLE = Label.MA_DS_Unknown_Error_Title;
    private static final String ERROR_CONTACT_ADMIN_BODY = Label.MA_DS_Error_Contact_Admin_Body;
    private static final String CALLOUT_EXCEPTION_TITLE = Label.MA_DS_Package_Mass_Recall_Callout_Exception_Title;
    private static final String SUCCESS_NOTIFICATION_BODY= Label.MA_DS_Package_Mass_Recall_Callout_Notification_Body;
    private static final String SUCCESS_NOTIFICATION_TITLE = Label.MA_DS_Package_Mass_Recall_Callout_Notification_Title;
    private static final String ERROR_NOTIFICATION_TITLE = Label.MA_DS_Package_Mass_Recall_Callout_Notification_Error_Title;

    private static final String PD_STATUS_RECALLING = Label.MA_DS_PD_Status_Recalling;
    private static final String INTEGRATION_STATUS_NONE = Label.MA_DS_Eligible_Integration_Status;
    
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
                this.handleSuccessResponse(srcRecordId);
            }
        }catch(MA_DS_CalloutFramework.CalloutServiceException exType) {
            this.handleErrorResponse(exType, MA_DS_CalloutFramework.CalloutServiceException.class.getName(), CALLOUT_EXCEPTION_TITLE, srcRecordId);
        }catch(MA_DS_CalloutFramework.CalloutResponseException exType) {
            this.handleErrorResponse(exType, MA_DS_CalloutFramework.CalloutResponseException.class.getName(), ERROR_NOTIFICATION_TITLE, srcRecordId);
        }catch(Exception exType) {
            this.handleErrorResponse(exType, exType.getTypeName(), ERROR_UNKNOWN_TITLE, srcRecordId);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to handle Error response, triggers notification to user and updates srcRecord's Integration Status.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    exType	                        DESCRIPTION (Data Type Exception, Exception type instance)
    * @param    exIdentifier	                DESCRIPTION (Data Type String, Exception Identifier to be logged to PF Debug Log)
    * @param    exNotificationTitle	            DESCRIPTION (Data Type String, Title of the Messaging Notification in case of Exception)
    * @param    srcRecordId	                    DESCRIPTION (Data Type Id, Source Record Id from where the API Request is sent)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void handleErrorResponse(Exception exType, String exIdentifier, String exNotificationTitle, Id srcRecordId) {
        super.handleErrorResponse(exType, exIdentifier, MESSAGING_CONFIG, exNotificationTitle, ERROR_CONTACT_ADMIN_BODY, srcRecordId);
        MA_DS_PackageRecallResponseCallback.updateSourceRecord(srcRecordId, false);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the "Integration Status" & "Status" of the srcRecord (Package Distribution) processed for Package Mass Recall.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                    DESCRIPTION (Data Type Id, Source Record Id from where the API Request is sent)
    * @param    successResponse	                DESCRIPTION (Data Type Boolean, True if API callout returns success response)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateSourceRecord(Id srcRecordId, Boolean successResponse) {
        List<MA_DS_Package_Distribution__c> pkgDistributions = [SELECT Id, MA_DS_Integration_Status__c, MA_DS_Status__c
                                                                FROM MA_DS_Package_Distribution__c
                                                                WHERE Id = :srcRecordId];

        for(MA_DS_Package_Distribution__c pkgDistribution : pkgDistributions) {
            pkgDistribution.MA_DS_Integration_Status__c = INTEGRATION_STATUS_NONE;
            pkgDistribution.MA_DS_Status__c = successResponse ? PD_STATUS_RECALLING : pkgDistribution.MA_DS_Status__c;
        }

        if(pkgDistributions.size() > 0) {
            MA_DS_PackageDistributionTriggerHandler.triggerDisabled = true;
            Database.SaveResult[] pkgDistributionsSRList = Database.update(pkgDistributions, false);
            MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(pkgDistributionsSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to handle Success response, sends Custom Notification to the user.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                    DESCRIPTION (Data Type Id, Source Record Id from where the API Request is sent)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void handleSuccessResponse(Id srcRecordId) {
        MA_DS_PackageRecallResponseCallback.updateSourceRecord(srcRecordId, true);
        Map<String, Object> clmWorkflow = (Map<String, Object>)this.responseBody;
        String workflowStatus = clmWorkflow.containsKey(WORKFLOW_STATUS_KEY) ? (String)clmWorkflow.get(WORKFLOW_STATUS_KEY) : '';
        this.notifyTarget(MESSAGING_CONFIG, SUCCESS_NOTIFICATION_TITLE, String.format(SUCCESS_NOTIFICATION_BODY, new String[]{workflowStatus}), this.srcRecordId);
    }
}