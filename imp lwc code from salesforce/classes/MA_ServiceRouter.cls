@RestResource(urlMapping='/ma/v1/acquired-contacts')
global with sharing class MA_ServiceRouter {
    
    @HttpPatch
    global static void syncWorkerIds() {
        handleSync(RestContext.request, RestContext.response);
    }

    private static void handleSync(RestRequest request, RestResponse response) {
        initResponseHeaders(response);

        try {
            MA_WorkerIdSyncHandler.checkIfValidURI(request.requestURI);
            MA_WorkerIdSyncHandler.parseRestRequestBody(request);
            MA_WorkerIdSyncHandler.checkIfPermittedVolume();
            List<Acquisition_Contacts__c> acqContacts = MA_WorkerIdSyncHandler.getAcquiredContactsToUpsert();
            MA_WorkerIdSyncHandler.bulkUpsertAcquiredContacts(acqContacts, response);
        }catch(MA_RestExceptions.HttpException httpEx) {
            response.statusCode = httpEx.statusCode;
            response.responseBody = httpEx.getBlobErrorResponse();
        }catch(Exception exType) {

        }
    }

    private static void initResponseHeaders(RestResponse response) {
        response.headers.put(MA_RestConstants.HEADER_CONTENT_TYPE, MA_RestConstants.CONTENT_TYPE_APPLICATION_JSON);
    }
}