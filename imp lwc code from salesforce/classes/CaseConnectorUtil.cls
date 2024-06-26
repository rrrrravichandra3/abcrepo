@RestResource(urlMapping='/case-transfer-registration')
global with sharing class CaseConnectorUtil {
	@HttpGet
    global static CaseTransferRegistrationModel getTransferRegistration(){
        List<Case_Connector_Acceptance__mdt> caseConnectorAccepts = [SELECT DeveloperName,Id,Label,Language,MasterLabel,
                                                                     NamespacePrefix,QualifiedApiName,Type__c, Enabled__c 
                                                                     FROM Case_Connector_Acceptance__mdt where Enabled__c = true];
        CaseTransferRegistrationModel caseTransferRegModel = new CaseTransferRegistrationModel();
        for(Case_Connector_Acceptance__mdt ccAcceptsMdt: caseConnectorAccepts){
            caseTransferRegModel.routes.add(ccAcceptsMdt.Type__c);
        }
        return caseTransferRegModel;
    }
	public static CaseTransferResponseModal sendToDestination(CaseConnectorTransferModel transferDetails, Case_Connector_Settings__mdt config, CaseConnectorException exceptionToThrow){
        Http httpService = new Http();
        HttpRequest httpRequest = getHttpRequest(config.Case_Transfer_URL__c, 'POST', 'application/json', 30000, JSON.serialize(transferDetails));
        System.debug(JSON.serialize(transferDetails));
        HttpResponse res = httpService.send(httpRequest);
        JSONParser parser = JSON.createParser(res.getBody());
        System.debug(res.getBody());
        CaseTransferResponseModal response = null;
        if(res.getStatusCode() == 200){
            try{
                response = (CaseTransferResponseModal)JSON.deserialize(res.getBody(), CaseTransferResponseModal.class);
            }catch (System.JSONException ex){
               exceptionToThrow.setMessage(ex.getMessage());
               exceptionToThrow.additionalDetails = res.getBody();
               exceptionToThrow.httpCode = null;
               throw exceptionToThrow;
            }catch(CalloutException cex){
               exceptionToThrow.setMessage(cex.getMessage());
               exceptionToThrow.additionalDetails = res.getBody();
               exceptionToThrow.httpCode = null;
               throw exceptionToThrow;
            }
        }else{
            exceptionToThrow.setMessage(res.getBody());
            exceptionToThrow.additionalDetails = res.getBody();
            exceptionToThrow.httpCode = res.getStatusCode();
            throw exceptionToThrow;
        }
        return response;
    }

    public static List<CaseConnectorDestinationResponse> getDestinations(Case_Connector_Settings__mdt config, CaseConnectorException exceptionToThrow){
        Http httpService = new Http();
        HttpRequest httpRequest = getHttpRequest(config.Case_Transfer_Destination_URL__c, 'GET', null, 30000, null);
        System.debug(config.Case_Transfer_Destination_URL__c);
        HttpResponse res = httpService.send(httpRequest);
        System.debug(res.getBody());
        List<CaseConnectorDestinationResponse> destinations = null;
        if(res.getStatusCode() == 200){
            try{
                destinations = (List<CaseConnectorDestinationResponse>)JSON.deserialize(res.getBody(), List<CaseConnectorDestinationResponse>.class);
                return destinations;
            }catch (System.JSONException ex){
               exceptionToThrow.setMessage(ex.getMessage());
               exceptionToThrow.additionalDetails = res.getBody();
               exceptionToThrow.httpCode = null;
               throw exceptionToThrow;
            }catch(CalloutException cex){
               exceptionToThrow.setMessage(cex.getMessage());
               exceptionToThrow.additionalDetails = res.getBody();
               exceptionToThrow.httpCode = null;
               throw exceptionToThrow;
            }
        }else{
           exceptionToThrow.setMessage(res.getBody());
           exceptionToThrow.additionalDetails = res.getBody();
           exceptionToThrow.httpCode = res.getStatusCode();
           throw exceptionToThrow;
        }
    }

    public static CaseConnectorTargetCaseModel getTargetOrgCaseDetails(Case_Connector_Settings__mdt config, String trasactionId, CaseConnectorException exceptionToThrow){
    	String detailsUrl = config.Case_Transfer_URL__c+'/'+trasactionId;
    	System.debug(detailsUrl);
        Http httpService = new Http();
        HttpRequest httpRequest = getHttpRequest(detailsUrl, 'GET', null, 30000, null);
        HttpResponse res = httpService.send(httpRequest);
        CaseConnectorTargetCaseModel targetOrgCaseDtails = null;
        if(res.getStatusCode() == 200){
            try{
                targetOrgCaseDtails = (CaseConnectorTargetCaseModel)JSON.deserialize(res.getBody(), CaseConnectorTargetCaseModel.class);
                return targetOrgCaseDtails;
            }catch (System.JSONException ex){
               exceptionToThrow.setMessage(ex.getMessage());
               exceptionToThrow.additionalDetails = res.getBody();
               exceptionToThrow.httpCode = null;
               throw exceptionToThrow;
            }catch(CalloutException cex){
               exceptionToThrow.setMessage(cex.getMessage());
               exceptionToThrow.additionalDetails = res.getBody();
               exceptionToThrow.httpCode = null;
               throw exceptionToThrow;
            }
        }else{
            exceptionToThrow.setMessage(res.getBody());
            exceptionToThrow.additionalDetails = res.getBody();
            exceptionToThrow.httpCode = res.getStatusCode();
            throw exceptionToThrow;
        }
    }

    private static HttpRequest getHttpRequest(String destination, String method, String contentType, Integer timeout,  String body){
        HttpRequest req = new HttpRequest();
        req.setHeader('Access-Token', UserInfo.getSessionId());
        req.setHeader('Instance-Url', URL.getSalesforceBaseUrl().toExternalForm().toLowerCase()+'');
        req.setEndpoint(destination);
        if(method != null) req.setMethod(method);
        if(timeout != null || timeout != 0) req.setTimeout(timeout);
        if(contentType != null) req.setHeader('Content-Type', contentType);
        if(body != null) req.setBody(body);
        return req;
    }

    global class TransferDetails{
    	public String caseId{get; set;}
    	public String destination{get; set;}
    	public String route{get; set;}
    	public String subject{get; set;}
    	public String description{get; set;}
    	public String priority{get; set;} 
    	public boolean transferAttachments{get; set;}
    	public boolean transferComments{get; set;}
    }

    public class CaseConnectorTargetCaseModel {
        public String id{get; set;}
        public String timestamp{get; set;}
        public String source{get; set;}
        public String sourceId{get; set;}
        public String destination{get; set;}
        public String destinationId{get; set;}
        public String destinationNumber{get; set;}
    }

    public class CaseTransferResponseModal{
        public String id{get; set;}
    }

    public class CaseConnectorTransferModel {
        public String destination{get; set;}
        public String route{get; set;}
        public String subject{get; set;}
        public String description{get; set;}
        public String priority{get; set;}
        public boolean transferAttachments{get; set;}
        public boolean transferComments{get; set;}
        public String ticketId{get; set;}
        public CaseConnectorTransferModel(String caseId, String destination, String route, String subject, String description, String priority, boolean transferAttachments, boolean transferComments){
            this.ticketId = caseId;
            this.destination = destination;
            this.route = route;
            this.subject = subject;
            this.description = description;
            this.priority = priority;
            this.transferAttachments = transferAttachments;
            this.transferComments = transferComments;
        }
    }
    global class CaseConnectorDestinationResponse {
	  //Destination Org Name
	  public String name{get; set;}
	  //Destination Org accepts
	  public List<String> routes{
	    get{
	      if(routes == null) routes= new List<String>();
	      return routes;
	    } 
	    set;
	  }
	}
    global class CaseTransferRegistrationModel {
        public List<String> routes{
            get{
                if(routes == null) routes = new List<String>();
                return routes;
            } 
            set;
        }
    }

}