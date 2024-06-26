public class AmplifyCalloutService implements Queueable,Database.AllowsCallouts {
    WD_Amplify_Audience_Relay__e event ;
    public class AmplifyPayload{
        public string DEST_SYS_Trx_Token;
        public string audience_name;
        public List<WQLFields> data;
    }
    public class WQLFields {
        public string employeeID;
        public string positionID;
        public string preferredFirstName;
        public string cf_CF_LRV_Worker_PrimaryWorkEmail = 'arajamathe@salesforce.com';
        public string email_PrimaryWork;
        public string preferredLastName;
        public string location_Name;
        public string yearsInCurrentPosition;
        public string onLeave;
        public string managementLevel_descriptor;
        public string workAddress_PostalCode;
        public string workerType_descriptor;
        public string supervisoryOrganization_PrimaryPosition_descriptor;
        public string numberOfDirectReportsEmployees;
        public string isManager;
        public string jobProfile_descriptor;
        public string timeZoneOfLocationOfWorkersPrimaryPosition_0_descriptor;
      
        
        
    }
    public AmplifyCalloutService(WD_Amplify_Audience_Relay__e event){
        this.event= event;
    }
    public  void execute(QueueableContext qc){

        AmplifyPayload payloadObj = new AmplifyPayload();
        payloadObj.DEST_SYS_Trx_Token = event.UUID__c;
        payloadObj.audience_name = 'From PF';
        payloadObj.data = (List<WQLFields>) JSON.deserialize(event.Audience_details__c,List<WQLFields>.class);
                if(payloadObj.data.size() > 0){

        for(WQLFields dataitem:payloadObj.data){
            if(dataItem.email_PrimaryWork == null){
                dataItem.cf_CF_LRV_Worker_PrimaryWorkEmail ='arajamathe@salesforce.com';
            }else{
                dataItem.cf_CF_LRV_Worker_PrimaryWorkEmail = dataItem.email_PrimaryWork;
      
            }
        }
        String payload = JSON.serialize(payloadObj);
        String access_token;
        system.debug('payload'+payload);
        
        //uuid=3ebd5b77-2ffe-4035-b326-80910eb877b7
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse response;
        
        req.setEndpoint('callout:AmplifyStage');
        req.setMethod('POST'); 
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        String body = 'grant_type=client_credentials';
        req.setBody(body);
        response = http.send(req);
        string responseBody = response.getBody();
        if(response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            System.debug(results);
            access_token = (String)results.get('access_token');
        } else { 
            System.debug('ERROR--'+response.getBody());
        }
        HttpRequest Audreq = new HttpRequest();
        HttpResponse Audresponse;
        Audreq.setEndpoint('https://sfos-gateway-stage.herokuapp.com/api/v1/messages/audiences');
        Audreq.setMethod('POST');
        Audreq.setHeader('Authorization', 'Bearer '+access_token);
        system.debug('accesstoke'+access_token);
        Audreq.setHeader('Content-Type','application/json');
        
        Audreq.setBody(payload);

        System.debug(Audreq);
        Audresponse = http.send(Audreq);
        String results=  Audresponse.getBody();
        System.debug(Audresponse);
        
        if(Audresponse.getStatusCode() == 200) {
            System.debug('Response: 200 OK');
        } else {
            System.debug('error posting audience'+results);
        }
        
    }
    }
    
    
}