/**
 * W-13484430 & W-13576017
 * Extends MA_DS_AbstractCalloutRequestParams class to Serialize value of Params attribute for the Package Mass Recall callout.
 * 
 * Version      Date            Author                  Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         21/06/2023      Chakshu Malhotra        W-13484430 & W-13576017 - Adds logic to convert the set of Package Distribution record Ids to accepted format of Package Mass Recall API callout.
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_PackageRecallCalloutRequestParams extends MA_DS_AbstractCalloutRequestParams {
    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to convert the requestParams & wrap it in a ParamsWrapper instance, as per the accepted Payload format for the Package Mass Recall API Request.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    requestParams	    DESCRIPTION (Data Type Object, Object type Params that need to be added in the API callout payload)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void deserializeParams(Object requestParams) {
        Id packageRecallPDId = (Id)requestParams;

        ParamsWrapper wrapperInstance = new ParamsWrapper();
        wrapperInstance.PackageDistributionId = packageRecallPDId;

        super.deserializedParams = JSON.deserializeUntyped(JSON.serialize(wrapperInstance));
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold details of Params attribute of the API payload for the Package Mass Recall process.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class ParamsWrapper {
        String PackageDistributionId;
    }
}