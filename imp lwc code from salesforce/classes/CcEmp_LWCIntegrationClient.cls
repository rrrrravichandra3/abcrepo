/**
 * ******************************************** W-12535956 : CcEmp_LWCIntegrationClient ********************************************
 *
 * Controller class to call mule APIs from LWC components
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         03/04/2024      Ashutosh Belwal        W-12535956 - <Career Connect> OrgEmployee API service - Job Req
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class CcEmp_LWCIntegrationClient {
	/**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initiate the GET request to Mulesoft and get the response JSON format
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    Map<String, String> queryParams     DESCRIPTION(Map of query params to add into http request url)
    * @param    String jobName                      DESCRIPTION(Developer name of CcEmp_API_Callout_Config__mdt to get the http request config)
    * @return   String                              DESCRIPTION (return JSON response)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static string getData(Map<String, String> queryParams, String jobName) {
        try{
            return new CcEmp_MuleAPICaller()
                        .setConfigName(jobName)
                        .buildQuery(queryParams)
                        .init();
        } catch (Exception ex){            
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initiate the POST request to Mulesoft and get the response JSON format
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    Map<String, String> bodyParams      DESCRIPTION(Map of post params to add into http request body)
    * @param    String jobName                      DESCRIPTION(Developer name of CcEmp_API_Callout_Config__mdt to get the http request config)
    * @return   String                              DESCRIPTION (return JSON response)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static string putData(Map<String, String> bodyParams, String jobName) {
        try{
            return new CcEmp_MuleAPICaller()
                        .setConfigName(jobName)
                        .buildPostParams(bodyParams)
                        .init();
        } catch (Exception ex){            
            throw new AuraHandledException(ex.getMessage());
        }
    }
}