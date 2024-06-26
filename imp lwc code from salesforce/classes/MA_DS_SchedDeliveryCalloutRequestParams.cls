/**
 * W-13182461
 * Extends MA_DS_AbstractCalloutRequestParams class to Serialize value of Params attribute for the Scheduled Delivery API callout.
 * 
 * Version      Date            Author                  Description
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         31/05/2023      Chakshu Malhotra        W-13182461 - Adds logic to convert MA_DS_ScheduledDeliveryHelper.ScheduledDeliveryParams to an accepted format of Scheduled Delivery API callout.
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_SchedDeliveryCalloutRequestParams extends MA_DS_AbstractCalloutRequestParams {
    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to convert the requestParams & wrap it in a ParamsWrapper instance, as per the accepted Payload format for the Scheduled Delivery API Request.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    requestParams	    DESCRIPTION (Data Type MA_DS_CalloutFramework.RequestParams , RequestParams type Params that need to be added in the API callout payload)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void deserializeParams(MA_DS_CalloutFramework.RequestParams requestParams) {
        this.requestParams = requestParams;
        MA_DS_ScheduledDeliveryHelper.ScheduledDeliveryParams scheduledDeliveryParams = (MA_DS_ScheduledDeliveryHelper.ScheduledDeliveryParams)requestParams;

        ParamsWrapper wrapperInstance = new ParamsWrapper();

        if(scheduledDeliveryParams.unscheduledSummaryDeliveryPDIds.size() > 0 || scheduledDeliveryParams.scheduledSummaryDeliveryMap.size() > 0) {
            wrapperInstance.ManagerDeliveryPayload = getManagerDeliveryPayloadWrapper(scheduledDeliveryParams.unscheduledSummaryDeliveryPDIds, scheduledDeliveryParams.scheduledSummaryDeliveryMap);
        }
        if(scheduledDeliveryParams.unscheduledPackageDeliveryPDIds.size() > 0 || scheduledDeliveryParams.scheduledPackageDeliveryMap.size() > 0) {
            wrapperInstance.PackageDeliveryPayload = getPackageDeliveryPayloadWrapper(scheduledDeliveryParams.unscheduledPackageDeliveryPDIds, scheduledDeliveryParams.scheduledPackageDeliveryMap);
        }

        super.deserializedParams = JSON.deserializeUntyped(JSON.serialize(wrapperInstance));
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & wrap details of Scheduled / Unscheduled Manager Summary Delivery jobs within ManagerDeliveryPayloadWrapper instance, based on the details in "requestParams".
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    unscheduledSummaryDeliveryPDIds	        DESCRIPTION (Data Type Set<Id>, Package Distribution Ids that need to be unscheduled for Manager Summary Delivery jobs)
    * @param    scheduledSummaryDeliveryMap	            DESCRIPTION (Data Type Map<Id, String>, Map of Package Distribution Id to the Manager Summary Delivery Scheduled Date/Time in GMT)
    * @return   ManagerDeliveryPayloadWrapper           DESCRIPTION (return ManagerDeliveryPayloadWrapper instance containing details of Scheduled / Unscheduled Manager Summary Delivery jobs)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static ManagerDeliveryPayloadWrapper getManagerDeliveryPayloadWrapper(Set<Id> unscheduledSummaryDeliveryPDIds, Map<Id, String> scheduledSummaryDeliveryMap) {
        ManagerDeliveryPayloadWrapper managerDeliveryPayloadWrapper = new ManagerDeliveryPayloadWrapper();
        if(unscheduledSummaryDeliveryPDIds.size() > 0) {
            managerDeliveryPayloadWrapper.Unschedule = getUnscheduleWrapper(unscheduledSummaryDeliveryPDIds);
        }
        if(scheduledSummaryDeliveryMap.size() > 0) {
            managerDeliveryPayloadWrapper.ScheduledItems = getNewScheduleItemsWrapper(scheduledSummaryDeliveryMap);
        }
        return managerDeliveryPayloadWrapper;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & wrap details of Unscheduled Manager Summary / Package Delivery jobs within UnscheduleWrapper instance, based on the details in "requestParams".
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    unscheduledDeliveryPDIds	        DESCRIPTION (Data Type Set<Id>, Package Distribution Ids that need to be unscheduled for Manager Summary / Package Delivery jobs)
    * @return   UnscheduleWrapper                   DESCRIPTION (return UnscheduleWrapper instance containing details of Unscheduled Manager Summary / Package Delivery jobs)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static UnscheduleWrapper getUnscheduleWrapper(Set<Id> unscheduledDeliveryPDIds) {
        UnscheduleWrapper unscheduleWrapper = new UnscheduleWrapper();
        unscheduleWrapper.PackageDistId = new List<Id>(unscheduledDeliveryPDIds);
        return unscheduleWrapper;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & wrap details of Scheduled Manager Summary / Package Delivery jobs within NewScheduleItemsWrapper instance, based on the details in "requestParams".
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    scheduledDeliveryMap	            DESCRIPTION (Data Type Map<Id, String>, Map of Package Distribution Id to the Manager Summary / Package Delivery Scheduled Date/Time in GMT)
    * @return   NewScheduleItemsWrapper             DESCRIPTION (return NewScheduleItemsWrapper instance containing details of Scheduled Manager Summary / Package Delivery jobs)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static NewScheduleItemsWrapper getNewScheduleItemsWrapper(Map<Id, String> scheduledDeliveryMap) {
        List<NewScheduleItemWrapper> newScheduleItemWrapperList = new List<NewScheduleItemWrapper>();

        for(Id scheduledPkgDistributionId : scheduledDeliveryMap.keySet()) {
            NewScheduleItemWrapper newScheduleItemWrapper = new NewScheduleItemWrapper();
            newScheduleItemWrapper.PackageDistId = scheduledPkgDistributionId;
            newScheduleItemWrapper.ScheduledTimeUtc = scheduledDeliveryMap.get(scheduledPkgDistributionId);
            newScheduleItemWrapperList.add(newScheduleItemWrapper);
        }

        NewScheduleItemsWrapper newScheduleItemsWrapper = new NewScheduleItemsWrapper();
        newScheduleItemsWrapper.NewScheduleItem = newScheduleItemWrapperList;
        
        return newScheduleItemsWrapper;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & wrap details of Scheduled / Unscheduled Package Delivery jobs within PackageDeliveryPayloadWrapper instance, based on the details in "requestParams".
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    unscheduledPackageDeliveryPDIds	        DESCRIPTION (Data Type Set<Id>, Package Distribution Ids that need to be unscheduled for Package Delivery jobs)
    * @param    scheduledPackageDeliveryMap	            DESCRIPTION (Data Type Map<Id, String>, Map of Package Distribution Id to the Package Delivery Scheduled Date/Time in GMT)
    * @return   PackageDeliveryPayloadWrapper           DESCRIPTION (return PackageDeliveryPayloadWrapper instance containing details of Scheduled / Unscheduled Package Delivery jobs)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static PackageDeliveryPayloadWrapper getPackageDeliveryPayloadWrapper(Set<Id> unscheduledPackageDeliveryPDIds, Map<Id, String> scheduledPackageDeliveryMap) {
        PackageDeliveryPayloadWrapper packageDeliveryPayloadWrapper = new PackageDeliveryPayloadWrapper();
        if(unscheduledPackageDeliveryPDIds.size() > 0) {
            packageDeliveryPayloadWrapper.Unschedule = getUnscheduleWrapper(unscheduledPackageDeliveryPDIds);
        }
        if(scheduledPackageDeliveryMap.size() > 0) {
            packageDeliveryPayloadWrapper.ScheduledItems = getNewScheduleItemsWrapper(scheduledPackageDeliveryMap);
        }
        return packageDeliveryPayloadWrapper;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold details of Params attribute of the API payload for the Scheduled Delivery process.
    * Holds details of Scheduled / Unscheduled Delivery Jobs (Manager Summaries & Packages) for the Package Distributions.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class ParamsWrapper {
        ManagerDeliveryPayloadWrapper ManagerDeliveryPayload;
        PackageDeliveryPayloadWrapper PackageDeliveryPayload;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the details of Scheduled / Unscheduled Manager Summary Delivery Jobs for the Package Distributions.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class ManagerDeliveryPayloadWrapper {
        UnscheduleWrapper Unschedule;
        NewScheduleItemsWrapper ScheduledItems;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the details of Scheduled / Unscheduled Package Delivery Jobs for the Package Distributions.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class PackageDeliveryPayloadWrapper {
        UnscheduleWrapper Unschedule;
        NewScheduleItemsWrapper ScheduledItems;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the List of Package Distribution Ids being processed for unscheduling their Scheduled Delivery jobs in Docusign CLM.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class UnscheduleWrapper {
        List<Id> PackageDistId;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the List of NewScheduleItemWrapper instances, to wrap it within NewScheduleItemsWrapper node.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class NewScheduleItemsWrapper {
        List<NewScheduleItemWrapper> NewScheduleItem;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the Package Distribution Id and the Delivery Schedule (Date/Time in GMT).
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class NewScheduleItemWrapper {
        Id PackageDistId;
        String ScheduledTimeUtc;
    }
}