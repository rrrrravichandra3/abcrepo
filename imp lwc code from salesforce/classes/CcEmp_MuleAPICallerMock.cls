@isTest
public class CcEmp_MuleAPICallerMock implements HttpCalloutMock {
    public CcEmp_MuleAPICallerMock(String body, Integer httpCode){
        this.body = body;
        this.httpCode = httpCode;
    }
    public String body{get; set;}
    public Integer httpCode{get; set;}
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(body);
        res.setStatusCode(httpCode);
        return res;
    }
}