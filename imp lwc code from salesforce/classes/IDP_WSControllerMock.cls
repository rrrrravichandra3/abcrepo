@isTest
global class IDP_WSControllerMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        if (request.getEndpoint().contains('error')) {
            response.setStatusCode(401);
            response.setStatus('ERROR');
            response.setBody('{}');
        } else{
            response.setStatusCode(200);
            response.setStatus('OK');
            if (request.getEndpoint().contains('oauth2/token')) {
                response.setBody('{"Name":"ttt"}');
            } else if (request.getEndpoint().contains('services/apexrest/IDP') && request.getMethod().contains('GET')) {
                IDP_WSControllerDTO responseBody = new IDP_WSControllerDTO();
                responseBody.recordId='test';
                response.setBody(JSON.serialize(responseBody));
                response.setStatusCode(200);
            } else if (request.getEndpoint().contains('services/apexrest/IDP') && request.getMethod().contains('PATCH')){
                IDP_ObjectivePatchWSDTO responseBody = new IDP_ObjectivePatchWSDTO();
                responseBody.idpRecordId='test';
                response.setBody(JSON.serialize(responseBody));
                response.setStatusCode(200);
            } else if (request.getEndpoint().contains('/services/data/v50.0/sobjects/') && request.getMethod().contains('PATCH')){
                response.setStatusCode(200);
            }
        }
        return response;
    }
}