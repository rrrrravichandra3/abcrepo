/**
 * W-13182461
 * Helper class to inititate the API callout to schedule jobs in Docusign CLM for Summary / Package Delivery.
 * 
 * Version      Date            Author                  Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         29/05/2023      Chakshu Malhotra        W-13182461 - Adds logic to inititate the API callout to schedule jobs in Docusign CLM for Summary / Package Delivery.
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_ScheduledDeliveryHelper {
    
    private static final String CALLOUT_CONFIG_SCHEDULED_DELIVERY = Label.MA_DS_Callout_Config_Scheduled_Delivery;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to inititate the API callout to schedule / unschedule Summary or Package Delivery jobs in Docusign CLM.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    unscheduledSummaryDeliveryPDIds	            DESCRIPTION (Data Type Set<Id>, Package Distribution Ids that need to be unscheduled for Summary Delivery job)
    * @param    unscheduledPackageDeliveryPDIds	            DESCRIPTION (Data Type Set<Id>, Package Distribution Ids that need to be unscheduled for Package Delivery job)
    * @param    scheduledSummaryDeliveryMap	                DESCRIPTION (Data Type Map<Id, String>, Map of Package Distribution Id to the Summary Delivery Scheduled Date/Time in GMT)
    * @param    scheduledPackageDeliveryMap	                DESCRIPTION (Data Type Map<Id, String>, Map of Package Distribution Id to the Package Delivery Scheduled Date/Time in GMT)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void initScheduledDelivery(Set<Id> unscheduledSummaryDeliveryPDIds, Set<Id> unscheduledPackageDeliveryPDIds, Map<Id, String> scheduledSummaryDeliveryMap, Map<Id, String> scheduledPackageDeliveryMap) {
        ScheduledDeliveryParams requestParams = new ScheduledDeliveryParams();
        requestParams.scheduledSummaryDeliveryMap = scheduledSummaryDeliveryMap;
        requestParams.scheduledPackageDeliveryMap = scheduledPackageDeliveryMap;
        requestParams.unscheduledSummaryDeliveryPDIds = unscheduledSummaryDeliveryPDIds;
        requestParams.unscheduledPackageDeliveryPDIds = unscheduledPackageDeliveryPDIds;

        MA_DS_CalloutFramework.calloutStrategy.setCalloutConfig(CALLOUT_CONFIG_SCHEDULED_DELIVERY)
                                              .setCalloutRequestParams(requestParams)
                                              .setCalloutRequest()
                                              .setResponseCallback()
                                              .initAsyncCallout(null);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the Params for Scheduled Delivery API callout to send Package Distribution Ids & scheduled date/time details to Docusign CLM to initiate delivery job(s) on set schedule.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class ScheduledDeliveryParams implements MA_DS_CalloutFramework.RequestParams {
        public Boolean successResponse {get; private set;}

        public Set<Id> unscheduledSummaryDeliveryPDIds {get; set;}
        public Set<Id> unscheduledPackageDeliveryPDIds {get; set;}
        public Map<Id, String> scheduledSummaryDeliveryMap {get; set;}
        public Map<Id, String> scheduledPackageDeliveryMap {get; set;}

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the successResponse property of the ScheduledDeliveryParams. 
        * Method is called from the ResponseCallback implementation used to send Http API Request for the Scheduled Delivery.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    successResponse	                DESCRIPTION (Data Type Boolean, True if API response returned no errors)
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void setSuccessResponse(Boolean successResponse) {
            this.successResponse = successResponse;
        }
    }
}