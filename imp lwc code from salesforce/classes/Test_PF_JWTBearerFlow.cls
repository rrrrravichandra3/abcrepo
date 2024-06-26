@isTest
public class Test_PF_JWTBearerFlow {

    @istest
    public static void validateSuccessCallout() {
        PF_JWT jwt = new PF_JWT('HS256');
        jwt.iss = 'testKey';
        jwt.aud = 'testAudienceUrl';
        jwt.sub = 'testSubject';
        Map<String,String> claims = new Map<String,String>();
        claims.put('prn','testUsername');
        jwt.claims = claims;
        jwt.privateKey = 'testKey';
        Test.setMock(HttpCalloutMock.class, new Test_PF_JWTBearerFlowMock(true));
        Test.startTest();
        String access_token = PF_JWTBearerFlow.getAccessToken('/testEndPoint',jwt);
        Test.stopTest();
        System.assert(access_token!=null);
    }
    
    @istest
    public static void validateFailedCallout() {
        PF_JWT jwt = new PF_JWT('HS256');
        jwt.iss = 'testKey';
        jwt.aud = 'testAudienceUrl';
        jwt.sub = 'testSubject';
        Map<String,String> claims = new Map<String,String>();
        claims.put('prn','testUsername');
        jwt.claims = claims;
        jwt.privateKey = 'testKey';
        Test.setMock(HttpCalloutMock.class, new Test_PF_JWTBearerFlowMock(false));
        Test.startTest();
        String access_token = PF_JWTBearerFlow.getAccessToken('/testEndPoint',jwt);
        Test.stopTest();
        System.assert(access_token==null);
    }
    
}