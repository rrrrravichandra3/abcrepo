/**
 * ******************************************** W-12535956 : CcEmp_GetJobs ********************************************
 *
 * Controller class for LWC component to get the data from mule and return into JSON response
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         03/04/2024      Ashutosh Belwal        W-12535956 - <Career Connect> OrgEmployee API service - Job Req
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public inherited sharing class CcEmp_GetJobs implements CcEmp_CalloutService.ICalloutRequest{
    private CcEmp_CalloutService.CalloutResponse calloutResponse;

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to build the HTTP request dynamically and set the request body and headers for the HTTP request
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    HttpRequest apiRequest                   DESCRIPTION (Instance of HTTPrequest to trigger the API callout)
    * @return   CcEmp_CalloutService.ICalloutRequest     DESCRIPTION (return CcEmp_CalloutService.ICalloutRequest instance)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public CcEmp_CalloutService.ICalloutRequest initRequest(HttpRequest apiRequest){
        calloutResponse = new CcEmp_CalloutService.CalloutResponse();
        try{
            Http http = new Http();
            HttpResponse response = http.send(apiRequest);
            calloutResponse.statusCode = response.getStatusCode();
            calloutResponse.response = response.getBody();
            calloutResponse.isSuccess = calloutResponse.statusCode == 200;
            
        } catch(Exception ex){
            calloutResponse.statusCode = 400;
            calloutResponse.response = ex.getMessage();
            calloutResponse.isSuccess = false;
        }
        return this;
    }
    public CcEmp_CalloutService.CalloutResponse getResponse(){
        return calloutResponse;
    }
}