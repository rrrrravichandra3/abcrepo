public with sharing class HttpRequestService implements IHttpRequestService {
    public HttpRequestService() {

    }
    public HttpResponse doPost(String namedCredential, String relativePath, Map<String,String> params) {
        
        String endpoint = 'callout:{0}{1}'; 
        // TODO - validate parameters. Escape/encode values to prevent injection.
        // See possible values of a Named Credential 'Name': https://help.salesforce.com/articleView?id=named_credentials_define.htm&type=5
        endpoint = String.format(endpoint, new List<String> {namedCredential, relativePath});

        String body = this.convertParamsMapToPostBody(params);
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(body);
        req.setHeader('Content-Type','application/json');
        res = h.send(req);    
        
        return res;
    }

    private String convertParamsMapToPostBody(Map<String,String> params) {
      System.PageReference pageReference = new System.PageReference('');
      pageReference.getParameters().putAll(params);
      return pageReference.getUrl().removeStart('?');
    }
}