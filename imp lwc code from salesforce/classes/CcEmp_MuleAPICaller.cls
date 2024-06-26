/**
 * ******************************************** W-12535956 : CcEmp_MuleAPICaller ********************************************
 *
 * Implementation class to call mule API
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         03/04/2024      Ashutosh Belwal        W-12535956 - <Career Connect> OrgEmployee API service - Job Req
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class CcEmp_MuleAPICaller extends CcEmp_CalloutService{

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set additional headers to http request from custom metadata
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    Map<String, String>      DESCRIPTION(headers  Map of headers to be set)
    * @return   CcEmp_MuleAPICaller      DESCRIPTION (return CcEmp_CalloutService instance)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public CcEmp_MuleAPICaller buildHeaders(Map<String, String> headers){
        setHeader(headers);
        return this;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set additional headers to http request from custom metadata
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    Map < String, String >      DESCRIPTION(Map of query parms to add into http request)
     * @return  CcEmp_MuleAPICaller         DESCRIPTION (return CcEmp_MuleAPICaller instance)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public CcEmp_MuleAPICaller buildQuery(Map<String, String> params){

        String queryParams = concatParams(params);
        if (queryParams != '') {
            queryParams = '?' + queryParams;
        }
        
        setQueryParams(queryParams);
        return this;
    }


    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set additional headers to http request from custom metadata
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    Map < String, String >      DESCRIPTION(Map of query parms to add into http request)
     * @return  CcEmp_MuleAPICaller         DESCRIPTION (return CcEmp_MuleAPICaller instance)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public CcEmp_MuleAPICaller buildPostParams(Map<String, String> params){

        String body = concatParams(params);
        setRequestBody(body);
        return this;
    }


    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set additional headers to http request from custom metadata
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    Map < String, String >      DESCRIPTION(Map of query parms to add into http request)
     * @return  String                      DESCRIPTION (Query string)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public String concatParams(Map<String, String> params){
        String queryParams = '';
        if (params == null || params.isEmpty()) {
            return '';
        }
        
        
        for (String key : params.keySet()) {
            if (params.get(key) != null) {
                queryParams += '&' + EncodingUtil.urlEncode(key, 'UTF-8') + '=' + EncodingUtil.urlEncode(params.get(key), 'UTF-8');
            }
        }
        if (queryParams != '') {
            queryParams = queryParams.removeStart('&');
        }
        return queryParams;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set additional headers to http request from custom metadata
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    String                  DESCRIPTION(Developer name of config name in custom metadata)
     * @return  CcEmp_MuleAPICaller     DESCRIPTION (return CcEmp_MuleAPICaller instance)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public CcEmp_MuleAPICaller setConfigName(String configName){
        setCalloutConfig(configName);
        return this;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set additional headers to http request from custom metadata
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param   
     * @return   String                  DESCRIPTION(JSON response of API)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override String init(){
        buildHttpRequest();
        CcEmp_CalloutService.CalloutResponse  response = super.initRequest();
        return JSON.serialize(response);
    }

    
}