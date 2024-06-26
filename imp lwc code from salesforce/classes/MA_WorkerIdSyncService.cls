/**
 * W-11134167
 * Apex REST service class used by EI PWTI to sync Workday Worker Id by updating acquisition contact records.
 * 
 * Version      Date            Author                  Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         20/05/2022      Chakshu Malhotra        Initial Version - implements the logic to sync Workday Worker Id
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@RestResource(urlMapping='/ma/v1/other/workers')
global with sharing class MA_WorkerIdSyncService {

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Http PATCH method to initiate sync of workday worker Ids.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @HttpPatch
    global static void syncWorkerIds() {
        handleSync(RestContext.request, RestContext.response);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to handle the sync operation invoking methods of service handler class.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    request         DESCRIPTION (Data type RestRequest, RestContext.request instance to access data as received from EI PWT adapter)
    * @param    response        DESCRIPTION (Data type RestResponse, RestContext.response instance to pass response data back to EI)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void handleSync(RestRequest request, RestResponse response) {
        initResponseHeaders(response);

        try {
            MA_WorkerIdSyncHandler.checkIfValidURI(request.requestURI);
            MA_WorkerIdSyncHandler.parseRestRequestBody(request);
            MA_WorkerIdSyncHandler.checkIfPermittedVolume();
            MA_WorkerIdSyncHandler.prepareAcquiredContactsToUpdate();
            MA_WorkerIdSyncHandler.bulkUpdateAcquiredContacts(response);
        }catch(MA_RestExceptions.HttpException httpEx) {
            response.statusCode = httpEx.statusCode;
            response.responseBody = httpEx.getBlobErrorResponse();
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to set required headers for RestResponse instance.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    response        DESCRIPTION (Data type RestResponse, RestContext.response instance to pass response data back to EI)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void initResponseHeaders(RestResponse response) {
        response.headers.put(MA_RestConstants.HEADER_CONTENT_TYPE, MA_RestConstants.CONTENT_TYPE_APPLICATION_JSON);
    }
}