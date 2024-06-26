/**
 * @description       : Service API Class for integration with Beamery API.
 * @custom settings   : tcrm_Settings__c controls api endpoints between sandbox and prod environment. 
 * @author            : Kyle Moseley (kmoseley)
 * @group             : 
 * @last modified on  : 01-22-2024
 * @last modified by  : Urvish Shah (ushah)
 */

 public with sharing class tcrm_BeameryAPIService {
    private static final String ACCESS_TOKEN = 'token';
    private static final String TOKEN_EXPIRY_TIME = 'expiry';
    private static final String httpRequestHeaderParamContentType = 'Content-Type';
    private static final String httpRequestHeaderParamContentTypeJson = 'application/json';
    private static tcrm_ConsentBatchSettings__c settings = tcrm_ConsentBatchSettings__c.getOrgDefaults();
    private static string token {
        get{
            if ( token == null ){
                if(!Test.isRunningTest()){
                token = getCachedAutheticationToken();
                }else{
                token = 'testToken';
                }
            }
            return token;
        }set;}
    /**
     * @description 
     * @param   
     * @param    
     * @return                
     */
    public static String doAuth(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Beamery_Auth');
        request.setMethod('POST');
        request.setHeader(httpRequestHeaderParamContentType,httpRequestHeaderParamContentTypeJson);
        string bdy = '{ "clientId" : "{!$Credential.Beamery_Auth.clientId}", "clientSecret" : "{!$Credential.Beamery_Auth.clientSecret}"}';
        request.setBody(bdy);
        try {
            HttpResponse response = http.send(request);
            Map<String,Object> token = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            String authToken = String.valueof(token.get('access_token'));
            DateTime expTime = System.now().addHours(23);
            tcrm_CacheService.putInOrgCache(ACCESS_TOKEN, authToken);
            tcrm_CacheService.putInOrgCache(TOKEN_EXPIRY_TIME, expTime);
            return authToken;
        }catch(Exception e){ 
            logError(e);
            return null;
        }
    }

    /**
     * @description 
     * @param   
     * @param    
     * @return                
     */
    public String getContactIdByEmail(String emailAddress){
        if(emailAddress.contains('+')){
            emailAddress = encodeEmail(emailAddress);
        }
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(settings.endpoint__c+'contacts?email='+emailAddress);
        request.setMethod('GET');
        request.setHeader(httpRequestHeaderParamContentType,httpRequestHeaderParamContentTypeJson);
        request.setHeader('Authorization', token);
        try {
            HttpResponse response = http.send(request);
            Integer statusCode = handleResponse(response);
            if(statusCode == 401){
                getContactIdByEmail(emailAddress);
            }
            tcrm_BeameryContacts cons = tcrm_BeameryContacts.parse(response.getBody());
            return cons.Contacts != null && cons.Contacts.size() > 0 ? cons.Contacts[0].id : null;
        }catch(Exception e){
            logError(e);
            return null;
        }
    }


    private String encodeEmail(String emailAddress){
        return emailAddress.replaceAll('[+]','%2b');
    }

    public String getContactIdByWorkdayCandidateId(String wdCandidateId){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(settings.endpoint__c+'contact/external/workday/'+wdCandidateId);
        request.setMethod('GET');
        request.setHeader(httpRequestHeaderParamContentType, httpRequestHeaderParamContentTypeJson);
        request.setHeader('Authorization', token);
        try {
            HttpResponse response = http.send(request);
            Integer statusCode = handleResponse(response);
            if(statusCode == 401){
                getContactIdByWorkdayCandidateId(wdCandidateId);
            }
            Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            return deserializedResponse.get('id').toString();
        }catch(Exception e){
            logError(e);
            return null;
        }
    }

    /**
     * @description 
     * @param   
     * @param    
     * @return                
     */
    public HttpResponse updateContact(tcrm_BeameryContacts.Contacts con){
        String body = JSON.serialize(con,true);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(settings.endpoint__c+'contact/'+con.id);
        request.setMethod('PATCH');
        request.setHeader(httpRequestHeaderParamContentType, httpRequestHeaderParamContentTypeJson);
        request.setHeader('Authorization', token);
        request.setBody(body);
        try {
            HttpResponse response = http.send(request);
            Integer statusCode = handleResponse(response);
            if(statusCode == 401){
                updateContact(con);
            }
            return response;
        }catch(Exception e){
            logError(e);
            return null;
        }
    }

    /**
     * @description 
     * @param   
     * @param    
     * @return                
     */
    public TCRM_BatchUtil.BeameryGetContactsResponseWrapper getBeameryLeads(String lastSuccessfulRun,Integer offset){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String op = 'gt';
        request.setEndpoint(settings.endpoint__c+'contacts?created_at='+lastSuccessfulRun+'&'+'created_at_op='+op+'&offset='+offset);
        request.setMethod('GET');
        request.setHeader(httpRequestHeaderParamContentType, httpRequestHeaderParamContentTypeJson);
        request.setHeader('Authorization', token);
        try {
            HttpResponse response = http.send(request);
            Integer statusCode = handleResponse(response);
            tcrm_BeameryContacts cons = tcrm_BeameryContacts.parse(response.getBody());
            return new TCRM_BatchUtil.BeameryGetContactsResponseWrapper(cons.Contacts,cons.total_count,statusCode);
        }catch(Exception e){
            logError(e);
            return null;
        }
    }

    public TCRM_BatchUtil.BeameryGetContactsResponseWrapper getBeameryLeadUpdates(String lastSuccessfulRun,Integer offset){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String op = 'gt';
        request.setEndpoint(settings.endpoint__c+'contacts?updated_at='+lastSuccessfulRun+'&'+'updated_at_op='+op+'&offset='+offset);
        request.setMethod('GET');
        request.setHeader(httpRequestHeaderParamContentType, httpRequestHeaderParamContentTypeJson);
        request.setHeader('Authorization', token);
        try {
            HttpResponse response = http.send(request);
            Integer statusCode = handleResponse(response);
            tcrm_BeameryContacts cons = tcrm_BeameryContacts.parse(response.getBody());
            return new TCRM_BatchUtil.BeameryGetContactsResponseWrapper(cons.Contacts,cons.total_count,statusCode);
        }catch(Exception e){
            logError(e);
            return null;
        }
    }

    

    /**
     * @description 
     * @param   
     * @param    
     * @return                
     */
    public static HttpResponse createContact (tcrm_BeameryContacts.Contacts con){
        String body = JSON.serialize(con,true);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(settings.endpoint__c+'contact');
        request.setMethod('POST');
        request.setHeader(httpRequestHeaderParamContentType,httpRequestHeaderParamContentTypeJson);
        request.setHeader('Authorization', token);
        request.setBody(body);
        try {
            HttpResponse response = http.send(request);
            Integer statusCode = handleResponse(response);
            if(statusCode == 401){
                createContact(con);
            }
            tcrm_BeameryContacts cons = tcrm_BeameryContacts.parse(response.getBody());
            return response;
        }catch(Exception e){
            logError(e);
            return null;
        }
    }

    /**
     * @description 
     * @param   
     * @param    
     * @return                
     */
    public static String getCachedAutheticationToken(){
        Datetime expiryTime = (Datetime)tcrm_CacheService.getFromOrgCache(TOKEN_EXPIRY_TIME);
        String cachedAuthenticationToken = (String)tcrm_CacheService.getFromOrgCache(ACCESS_TOKEN);
        if(cachedAuthenticationToken == null || expiryTime == null || System.now() > expiryTime){
            return doAuth();
        }else {
            return cachedAuthenticationToken;
        }
    }

    /**
     * 
     */
    public static Integer handleResponse(HttpResponse response){
        
        switch on response.getStatusCode(){
            when 401{
                token = null;
                doAuth();
            }
            when else{
                //TODO: Log Issue
            }
        }
        return response.getStatusCode();
    }    

    private static void logError(Exception e){
        PF_Logger.log('Beamery Integration', 'ERROR', e.getMessage(), '', 'Callout to beamery service failed.', 'Beamery Integration');
    }
}