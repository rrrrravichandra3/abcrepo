@isTest
global class PF_DestOrgMockHttpResponse implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"name":"SupportForce", "routes":[]}]');
        res.setStatusCode(200);
        return res;
    }
}