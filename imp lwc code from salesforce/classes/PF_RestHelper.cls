public class PF_RestHelper {
    
    public static PF_REST_Config__c config = PF_REST_Config__c.getOrgDefaults();
    
    public Static String getToolingAPIToken(){
        
        return getAccessToken(config.Tooling_API_username__c,
                                         config.Tooling_API_JWT_URL__c,
                                         config.Tooling_API_Token_endpoint__c,
                                         config.Tooling_API_Client_ID__c,
                                         config.Tooling_API_Digital_certificate_name__c);
    }
    
    private static String getAccessToken(String username, String loginURL, String tokenEndpoint, String consumerKey, String certName){
        
        Auth.JWT jwt = new Auth.JWT();
        jwt.setSub(username); 
        jwt.setAud(loginURL); 
        jwt.setIss(consumerKey);
        
        Auth.JWS jws = new Auth.JWS(jwt, certName);
        String token = jws.getCompactSerialization();
        
        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(tokenEndpoint, jws);
        
        return bearer.getAccessToken();
    }
}