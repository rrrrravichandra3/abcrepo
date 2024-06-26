global without sharing class CaseConnector_PforceToSforceUtil {
	public static CaseConnectorResponse sendToDestination(Case caseToTransfer, String destination, String route, String subject, String description, String priority, boolean transferAttachments, boolean transferComments, String pii){
	 	Case_Connector_Settings__mdt config = getConfigurationForThisOrg();
	 	String transactionId = null;
	 	CaseConnectorUtil.CaseConnectorTransferModel caseTransfer = null;
	 	try{
	 		route = getInternalSupportCategory(caseToTransfer.Type, caseToTransfer.ES_DJC_Topic__c, caseToTransfer.ES_DJC_Sub_Topic__c);
	 		caseTransfer = new CaseConnectorUtil.CaseConnectorTransferModel(caseToTransfer.Id, destination, route, subject, description, priority, transferAttachments, transferComments);
	 		CaseConnectorUtil.CaseTransferResponseModal transfered = CaseConnectorUtil.sendToDestination(caseTransfer, config, new CaseConnectorPFtoSFException());
			transactionId = transfered.id;

		}catch(CaseConnectorPFtoSFException ccex){
			ccex.handle('Step 2: Transfer Case', JSON.serialize(caseTransfer), null, false, caseToTransfer.Id);
			if(ccex.getMessage().contains('"route":"may not be empty"')){
				return new CaseConnectorResponse(true, Label.SendToSupportforce_No_ISC_Defination);
			}else if(ccex.getMessage().contains('No contact found in the destination org for email')){
				return new CaseConnectorResponse(true, Label.SentToSupportforceContactNotFound);
			}else if(ccex.httpCode == null){
				return new CaseConnectorResponse(true, ccex.getMessage());
			}else{
				String responseString = ccex.getMessage();
	            String errorString = responseString;
	            if(responseString != null){
	                Map<String, Object> messageBody = (Map<String, Object>)JSON.deserializeUntyped(responseString);
	                errorString = (String)messageBody.get('message');
	            }
				return new CaseConnectorResponse(true, errorString);
			}
		}catch (Exception ex){
			return new CaseConnectorResponse(true, ex.getMessage());
		}

		try{
			CaseConnectorUtil.CaseConnectorTargetCaseModel tragetCaseDetails= CaseConnectorUtil.getTargetOrgCaseDetails(config, transactionId, new CaseConnectorPFtoSFException());
			
			// Update case with Internal support category, Status, Supportforce Case Number and Supportfoce Case Id
			caseToTransfer.ESDJC_Supportforce_Case_Number__c = tragetCaseDetails.destinationNumber;
			caseToTransfer.ESDJC_Supportforce_Case_Id__c = tragetCaseDetails.destinationId;
			caseToTransfer.PII__c = pii;
			caseToTransfer.Status='Closed';
			try{
				update caseToTransfer;
			}catch(Exception ex){
				CaseConnectorPFtoSFException ccex = new CaseConnectorPFtoSFException(ex.getMessage());
				Map<String, String> logDetails = new Map<String, String>();
				logDetails.put('Id', caseToTransfer.Id);
				logDetails.put('PII__c', pii);
				logDetails.put('ESDJC_Supportforce_Case_Number__c', tragetCaseDetails.destinationNumber);
				logDetails.put('ESDJC_Supportforce_Case_Id__c', tragetCaseDetails.destinationId);
				String log = JSON.serialize(logDetails);
				ccex.handle('Step 4: Update PF Case', log, transactionId, true, caseToTransfer.Id);
				return new CaseConnectorResponse(true, ex.getMessage());
			}
			
		}catch(CaseConnectorPFtoSFException ccex){
			Map<String, String> logDetails = new Map<String, String>();
				logDetails.put('Id', caseToTransfer.Id);
				logDetails.put('PII__c', pii);
				logDetails.put('url', config.Case_Transfer_URL__c +'/'+transactionId);
				String log = JSON.serialize(logDetails);
			ccex.handle('Step 3: Get Target Case Details', log, transactionId, true, caseToTransfer.Id);
			return new CaseConnectorResponse(true, ccex.getMessage());
		}catch (Exception ex){
			return new CaseConnectorResponse(true, ex.getMessage());
		}
		
		return new CaseConnectorResponse(false, Label.SentToSupportforceSuccessMessage);
	 }

	public static Case_Connector_Settings__mdt getConfigurationForThisOrg(){
        List<Case_Connector_Settings__mdt> settings = [SELECT Case_Transfer_Destination_URL__c,Case_Transfer_URL__c,
                                                       DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,
                                                       Org_External_URL__c,QualifiedApiName,Sandbox_Production__c 
                                                       FROM Case_Connector_Settings__mdt where Org_External_URL__c =: URL.getSalesforceBaseUrl().toExternalForm()];
        if(settings.isEmpty()) throw new CaseConnectorPFtoSFException('No Configurations found for this Org: '+URL.getSalesforceBaseUrl()+'. Please go to Case Connector Settings(Case_Connector_Settings__mdt) add configuration this Org.');
        else if(settings.size() > 1) throw new CaseConnectorPFtoSFException('Multiple Configurations found for this Org: '+URL.getSalesforceBaseUrl().toExternalForm()+'. Please go to Case Connector Settings(Case_Connector_Settings__mdt) keep only one config and remove extra configurations this Org.');
        return settings.get(0);
    }

    public static String getInternalSupportCategory(String type, String topic, String subtopic){
        List<Internal_Support_Category_Translation__mdt> iscTranslationTable = [SELECT Type__c, Topic__c, SubTopic__c, Internal_Support_Category__c from Internal_Support_Category_Translation__mdt where Target_Org__c ='SupportForce' order by Rank__c asc];
        for(Internal_Support_Category_Translation__mdt translationRow: iscTranslationTable){
            if(
                (translationRow.Type__c == type || (translationRow.Type__c != null && translationRow.Type__c.equalsIgnoreCase(type))) &&
                (translationRow.Topic__c == topic || (translationRow.Topic__c != null && translationRow.Topic__c.equalsIgnoreCase(topic))) &&
                (translationRow.SubTopic__c == subtopic || (translationRow.SubTopic__c != null && translationRow.SubTopic__c.equalsIgnoreCase(subtopic)))
              ){
                return translationRow.Internal_Support_Category__c;
            }
        }
        for(Internal_Support_Category_Translation__mdt translationRow: iscTranslationTable){
            if(
                (translationRow.Type__c == type || (translationRow.Type__c != null && translationRow.Type__c.equalsIgnoreCase(type))) &&
                (translationRow.Topic__c == topic || (translationRow.Topic__c != null && translationRow.Topic__c.equalsIgnoreCase(topic)))
              ){
                return translationRow.Internal_Support_Category__c;
            }
        }
        throw new CaseConnectorPFtoSFException(Label.SendToSupportforce_No_ISC_Defination);
    }

	global class CaseConnectorResponse {
    	public CaseConnectorResponse(Boolean errored, String message){
    		this.errored = errored;
    		this.message = message;
    	}
    	public CaseConnectorResponse(){
    	}
    	public Boolean errored{get; set;}
    	public String message{get; set;}
    }
}