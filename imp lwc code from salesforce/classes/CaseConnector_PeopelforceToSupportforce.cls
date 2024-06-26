global with sharing class CaseConnector_PeopelforceToSupportforce {
	webservice static String getDestinations(){
		Case_Connector_Settings__mdt config = CaseConnector_PforceToSforceUtil.getConfigurationForThisOrg();
	 	try{
	 		return JSON.serialize(new CaseConnectorDestinationResponseModal(false, null, CaseConnectorUtil.getDestinations(config, new CaseConnectorPFtoSFException())));
	 	}catch(CaseConnectorPFtoSFException ccex){
 			ccex.handle('Step 1: Get Destinations', null, null, false, null);
 			return JSON.serialize(new CaseConnectorDestinationResponseModal(true, ccex.getMessage(), null));
 		}catch (Exception ex){
 			return JSON.serialize(new CaseConnectorDestinationResponseModal(true, ex.getMessage(), null));
 		}
	}

	webservice static String sendToDestination(String caseId, String destination, String route, String subject, String description, String priority, boolean transferAttachments, boolean transferComments, String pii){
        Case caseToTransfer = [SELECT Id, Type, ES_DJC_Topic__c, ES_DJC_Sub_Topic__c, Status, ESDJC_Supportforce_Case_Id__c, ESDJC_Supportforce_Case_Number__c, PII__c from Case where Id =: caseId];
	 	CaseConnector_PforceToSforceUtil.CaseConnectorResponse response =  CaseConnector_PforceToSforceUtil.sendToDestination(caseToTransfer, destination, route, subject, description, priority, transferAttachments, transferComments, pii);
        return JSON.serialize(response);
	}


    global class CaseConnectorResponse {
    	public CaseConnectorResponse(Boolean errored, String message){
    		this.errored = errored;
    		this.message = message;
    	}
    	public Boolean errored{get; set;}
    	public String message{get; set;}
    }
    global class CaseConnectorDestinationResponseModal {
    	public CaseConnectorDestinationResponseModal(Boolean errored, String message, List<CaseConnectorUtil.CaseConnectorDestinationResponse> destinations){
    		this.errored = errored;
    		this.message = message;
    		this.destinations = destinations;
    	}
    	public Boolean errored{get; set;}
    	public String message{get; set;}
    	public List<CaseConnectorUtil.CaseConnectorDestinationResponse> destinations{get; set;}
    }

    webservice static String appSettings(){
        List<Case_Connector_PF_to_SF_Settings__mdt> trasferSettings = [SELECT DeveloperName, Setting_Type__c, Value1__c, Value2__c  
                                                                                                FROM Case_Connector_PF_to_SF_Settings__mdt];
        Map<String, Object> settings =  new Map<String, Object>();
        for(Case_Connector_PF_to_SF_Settings__mdt setting : trasferSettings){
            if(setting.DeveloperName == 'Success_Message_Display_Timeout'){
                settings.put('displayTimeout', setting.Value1__c);
            }else{
                if(setting.Setting_Type__c == 'Eligibility'){
                    if(setting.Value2__c != null){
                        settings.put(setting.DeveloperName.toLowerCase(), setting.Value1__c+ setting.Value2__c);
                    }else{
                        settings.put(setting.DeveloperName.toLowerCase(), setting.Value1__c);
                    }                    
                }
            }
        }
        return JSON.serialize(settings);
    }

}