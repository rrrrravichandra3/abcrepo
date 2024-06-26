@isTest
global class Test_MA_SlackWayfinderHTTPMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status": "ok"}');
        response.setStatusCode(200);
        return response; 
    }
}