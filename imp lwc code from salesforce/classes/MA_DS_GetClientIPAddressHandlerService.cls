/**
 * W-12218399
 * Class to hold MA_DS_PackageStageHandlerService.PackageStageHandlerService implementation to fetch the Client IP Address of the Signer, via callout to DocuSign eSignature API.
 * Holds MA_DS_PackageStageHandlerService.PackageStageHandlerJobFinalizer implementation to provide actions for single / final job completion.
 * 
 * Version      Date            Author                  Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         12/11/2023      Chakshu Malhotra        W-12218399 - Adds logic to fetch the Client IP Address of the Signer, via callout to DocuSign eSignature API.
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_GetClientIPAddressHandlerService extends MA_DS_PackageStageHandlerService.PackageStageHandlerService {

    private static final String CALLOUT_CONFIG_LIST_AUDIT_EVENTS = Label.MA_DS_Callout_Config_List_Audit_Events;

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize the RecalledStatusHandler Job with JobParams & JobFinalizer to fetch the Client IP Address of the Signer, via callout to DocuSign eSignature API.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    envelopeIdsMap	        DESCRIPTION (Data Type Map<Id, String>, Map of Acquisition Contact Id to the Envelope Id)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void initPackageStageHandlerJob(Map<Id, String> envelopeIdsMap) {
        MA_DS_PackageStageHandlerWrapper.GetClientIPAddressHandlerParams jobParams = new MA_DS_PackageStageHandlerWrapper.GetClientIPAddressHandlerParams();
        jobParams.envelopeIdsMap = envelopeIdsMap;
        jobParams.acqContactIds = new List<Id>(envelopeIdsMap.keySet());
        this.packageStageHandlerJob = new GetClientIPAddressHandler(jobParams, new GetClientIPAddressHandlerFinalizer(jobParams));
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to fetch the Client IP Address of the Signer, via callout to DocuSign eSignature API.
    * Recursively self-chains itself to process all Acquisition Contact records as per the envelopeIdsMap. 
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class GetClientIPAddressHandler extends MA_DS_PackageStageHandlerService.PackageStageHandlerJob {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the GetClientIPAddressHandler class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the PackageStageHandlerJob type)
        * @param    jobFinalizer	    DESCRIPTION (Data Type JobFinalizer, JobFinalizer instance for the PackageStageHandlerJob type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public GetClientIPAddressHandler(MA_DS_PackageStageHandlerService.JobParams jobParams, MA_DS_PackageStageHandlerService.JobFinalizer jobFinalizer) {
            super(jobParams, jobFinalizer);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to fetch the Client IP Address of the Signer, via callout to DocuSign eSignature API.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void execute(QueueableContext qContext) {
            //System.debug('GetClientIPAddressHandler jobParams : ' + JSON.serialize(jobParams));
            MA_DS_PackageStageHandlerWrapper.GetClientIPAddressHandlerParams jobParams = (MA_DS_PackageStageHandlerWrapper.GetClientIPAddressHandlerParams)this.jobParams;
            
            Integer remainingCount = (jobParams.acqContactIds.size() - jobParams.currentIndex);
            Integer maxAPICalloutCount = (remainingCount < jobParams.maxAPICalloutCount) ? remainingCount : jobParams.maxAPICalloutCount;

            for(Integer startIndex=jobParams.currentIndex; startIndex < (jobParams.currentIndex + maxAPICalloutCount); startIndex++) {
                Id srcRecordId = jobParams.acqContactIds[startIndex];
                String envelopeId = jobParams.envelopeIdsMap.get(srcRecordId);
                MA_DS_CalloutFramework.calloutStrategy.setCalloutConfig(CALLOUT_CONFIG_LIST_AUDIT_EVENTS)
                                                      .setCalloutRequest(envelopeId)
                                                      .setResponseCallback()
                                                      .initCallout(srcRecordId);
            }

            jobParams.currentIndex += maxAPICalloutCount;

            this.invokeJobFinalizer(jobParams.currentIndex, jobParams.acqContactIds.size());
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to invoke JobFinalizer action to handle Single Job completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    currentIndex            DESCRIPTION (Data type Integer, Index of the last Acquisition Contact Id processed for List Audit Events API callout)
        * @param    totalAcqContactIds      DESCRIPTION (Data type Integer, Total number of Acquisition Contact Ids being processed)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void invokeJobFinalizer(Integer currentIndex, Integer totalAcqContactIds) {
            if(currentIndex == totalAcqContactIds) {
                this.jobFinalizer.handleFinalJobCompletion();
            }else {
                this.jobFinalizer.handleSingleJobCompletion();
            }
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of MA_DS_PackageStageHandlerService.PackageStageHandlerJobFinalizer to provide JobFinalizer implementation for GetClientIPAddressHandler Queueable job.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class GetClientIPAddressHandlerFinalizer extends MA_DS_PackageStageHandlerService.PackageStageHandlerJobFinalizer {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the GetClientIPAddressHandlerFinalizer class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the PackageStageHandlerJobFinalizer type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public GetClientIPAddressHandlerFinalizer(MA_DS_PackageStageHandlerService.JobParams jobParams) {
            super(jobParams);
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on each single job completion, initializes GetClientIPAddressHandler job & enqueues it.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion() {
            GetClientIPAddressHandler getClientIPAddressHandler = new GetClientIPAddressHandler(this.jobParams, new GetClientIPAddressHandlerFinalizer(this.jobParams));
            MA_DS_PackageStageHandlerService.execute(getClientIPAddressHandler);
        }
    }
}