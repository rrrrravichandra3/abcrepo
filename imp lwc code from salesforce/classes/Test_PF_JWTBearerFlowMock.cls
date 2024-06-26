@istest
public class Test_PF_JWTBearerFlowMock implements HttpCalloutMock {
    Boolean successResponse;
    
    public Test_PF_JWTBearerFlowMock(Boolean successResponse) {
        this.successResponse = successResponse;
    }
    
    public HTTPResponse respond(HTTPRequest request) {
        
        HTTPResponse response = new HTTPResponse();
        if(successResponse) {
            response.setStatusCode(200);
        } else {
            response.setStatusCode(404);
        }
        
        JSONGenerator responseGen =  JSON.createGenerator(false);
        if(successResponse){
            responseGen.writeStartObject();
            responseGen.writeStringField('access_token', 'testToken');
            responseGen.writeEndObject();
        }else{
            responseGen.writeStartObject();
            responseGen.writeStringField('error', 'An error has occured: Error: Invalid Request Body');
            responseGen.writeEndObject();
        }
        response.setBody(responseGen.getAsString());
        return response;
    }
}