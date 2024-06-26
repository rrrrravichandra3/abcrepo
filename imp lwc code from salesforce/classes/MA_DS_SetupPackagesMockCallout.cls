@isTest
global class MA_DS_SetupPackagesMockCallout implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{"statusMessage":"Created"}');
        res.setStatusCode(201);
        return res;
    }
}