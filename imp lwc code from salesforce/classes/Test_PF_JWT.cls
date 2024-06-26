@isTest
public class Test_PF_JWT {

    static final string ALGORITHM = 'HS256';
    
    @isTest
    public static void validateJWTIssuance() {
        PF_JWT jwt = new PF_JWT(ALGORITHM);
        jwt.iss = 'testKey';
        jwt.aud = 'testAudienceUrl';
        jwt.sub = 'testSubject';
        jwt.exp = 'testexp';
        jwt.iat = 'testiat';
        jwt.cert = 'testcertname';
        Map<String,String> claims = new Map<String,String>();
        claims.put('prn','testUsername');
        jwt.claims = claims;
        jwt.privateKey = 'testKey';
        Test.startTest();
		string s= jwt.issue(); 
        Test.stopTest();    
        //decode and verify header
        System.assert(EncodingUtil.base64Decode(s.split('\\.')[0]).toString().contains(ALGORITHM));
        //decode and verify payload
        String payload = EncodingUtil.base64Decode(s.split('\\.')[1]).toString();
        System.assert(payload.contains('testAudienceUrl'));
        System.assert(payload.contains('testSubject'));
        System.assert(payload.contains('testKey'));

    }
}