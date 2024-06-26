/**
 * W-12218399
 * Abstract Wrapper class to hold JobParams, used while post-processing of Package Stage update on Acquisition Contact.
 * Holds JobParams type used to process Action updates of Enum Type MA_DS_PackageStageHandlerService.HandlerAction.
 * 
 * Version      Date            Author                  Description
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         13/11/2023      Chakshu Malhotra        W-12218399 - Adds logic to hold JobParams, used while post-processing of Package Stage update on Acquisition Contact.
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_PackageStageHandlerWrapper {

    private static final Integer DEFAULT_ZERO = 0;
    @TestVisible private static final Integer LIST_AUDIT_EVENTS_CALLOUT_COUNT = 5;

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold serialized state of properties used to fetch the Client IP Address of the Signer, via callout to DocuSign eSignature API.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class GetClientIPAddressHandlerParams implements MA_DS_PackageStageHandlerService.JobParams {
        public Integer currentIndex = DEFAULT_ZERO;
        public Integer maxAPICalloutCount = LIST_AUDIT_EVENTS_CALLOUT_COUNT;
        
        public List<Id> acqContactIds {get; set;}
        public Map<Id, String> envelopeIdsMap {get; set;}
    }
}