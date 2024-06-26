@isTest
global class CaseConnectorUtilsTest {
	
	@isTest static void successsfulGetDestinations() {
		
		String body = '[{"name":"SupportForce","routes":["Frank Internal Support","Internal Salesforce.com App: New User/User Maintenance","Security: Access Badge","IT - Finance Systems: Software","ESAS - Sales GTM","IT Helpdesk - Other","Security: Enterprise Security: Security Architecture/Design Review","Talentforce Internal Support","Internal Work.com App - New User Access"]},{"name":"Org62","routes":["Frank Internal Support","Internal Salesforce.com App: New User/User Maintenance","Security: Access Badge","IT - Finance Systems: Software","ESAS - Sales GTM","IT Helpdesk - Other","Security: Enterprise Security: Security Architecture/Design Review","Talentforce Internal Support","Internal Work.com App - New User Access"]}]';
		Test.setMock(HttpCalloutMock.class, new CaseConnectorServiceMock(body, 200));
		// This is custom metadata, Query is allowed in Test Classes
		List<Case_Connector_Settings__mdt> settings = [SELECT Case_Transfer_Destination_URL__c,Case_Transfer_URL__c,
                                                       DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,
                                                       Org_External_URL__c,QualifiedApiName,Sandbox_Production__c 
                                                       FROM Case_Connector_Settings__mdt where Org_External_URL__c =: URL.getSalesforceBaseUrl().toExternalForm()];
        if(settings.isEmpty()) throw new CaseConnectorExampleException('No Configurations found for this Org: '+URL.getSalesforceBaseUrl()+'. Please go to Case Connector Settings(Case_Connector_Settings__mdt) add configuration this Org.');
        else if(settings.size() > 1) throw new CaseConnectorExampleException('Multiple Configurations found for this Org: '+URL.getSalesforceBaseUrl().toExternalForm()+'. Please go to Case Connector Settings(Case_Connector_Settings__mdt) keep only one config and remove extra configurations this Org.');
        Case_Connector_Settings__mdt setting =  settings.get(0);
		List<CaseConnectorUtil.CaseConnectorDestinationResponse> casesDestinations = CaseConnectorUtil.getDestinations(setting, new CaseConnectorExampleException());
		System.assertEquals(2, casesDestinations.size(), 'THere should be 2 destinations as per mock');

	}

	@isTest static void failedGetDestinations() {
		
		String body = '{"message":"Mocking Error from Case Connector"}';
		Test.setMock(HttpCalloutMock.class, new CaseConnectorServiceMock(body, 400));
		// This is custom metadata, Query is allowed in Test Classes
		List<Case_Connector_Settings__mdt> settings = [SELECT Case_Transfer_Destination_URL__c,Case_Transfer_URL__c,
                                                       DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,
                                                       Org_External_URL__c,QualifiedApiName,Sandbox_Production__c 
                                                       FROM Case_Connector_Settings__mdt where Org_External_URL__c =: URL.getSalesforceBaseUrl().toExternalForm()];
        if(settings.isEmpty()) throw new CaseConnectorExampleException('No Configurations found for this Org: '+URL.getSalesforceBaseUrl()+'. Please go to Case Connector Settings(Case_Connector_Settings__mdt) add configuration this Org.');
        else if(settings.size() > 1) throw new CaseConnectorExampleException('Multiple Configurations found for this Org: '+URL.getSalesforceBaseUrl().toExternalForm()+'. Please go to Case Connector Settings(Case_Connector_Settings__mdt) keep only one config and remove extra configurations this Org.');
        Case_Connector_Settings__mdt setting =  settings.get(0);
		try{
			List<CaseConnectorUtil.CaseConnectorDestinationResponse> casesDestinations = CaseConnectorUtil.getDestinations(setting, new CaseConnectorExampleException());
			System.assert(false, 'Execution should not reach here...');
		}catch(Exception ex){
			System.assertEquals( true, ex instanceof CaseConnectorExampleException);
			CaseConnectorExampleException ccException = (CaseConnectorExampleException)ex;
			System.assertEquals(400, ccException.httpCode, 'Status httpcode should be 400');
		}
	}
	
	@isTest static void successTransfer() {
		String body = '{"id":"cfff9bc6-6a5a-417a-bf37-a0fe900333bb"}';
		Test.setMock(HttpCalloutMock.class, new CaseConnectorServiceMock(body, 200));
		// This is custom metadata, Query is allowed in Test Classes
		List<Case_Connector_Settings__mdt> settings = [SELECT Case_Transfer_Destination_URL__c,Case_Transfer_URL__c,
                                                       DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,
                                                       Org_External_URL__c,QualifiedApiName,Sandbox_Production__c 
                                                       FROM Case_Connector_Settings__mdt where Org_External_URL__c =: URL.getSalesforceBaseUrl().toExternalForm()];
        if(settings.isEmpty()) throw new CaseConnectorExampleException('No Configurations found for this Org: '+URL.getSalesforceBaseUrl()+'. Please go to Case Connector Settings(Case_Connector_Settings__mdt) add configuration this Org.');
        else if(settings.size() > 1) throw new CaseConnectorExampleException('Multiple Configurations found for this Org: '+URL.getSalesforceBaseUrl().toExternalForm()+'. Please go to Case Connector Settings(Case_Connector_Settings__mdt) keep only one config and remove extra configurations this Org.');
        Case_Connector_Settings__mdt setting =  settings.get(0);

		CaseConnectorUtil.CaseTransferResponseModal transferResponse = CaseConnectorUtil.sendToDestination(new CaseConnectorUtil.CaseConnectorTransferModel('caseId', 'destination', 'route', 'subject', 'description', 'priority', true, true) , setting, new CaseConnectorExampleException());
		System.assertNotEquals(null, transferResponse);
		System.assertNotEquals(null, transferResponse.id);

	}

	@isTest static void failedTransfer() {
		
		String body = '{"message":"Mocking Error from Case Connector"}';
		Test.setMock(HttpCalloutMock.class, new CaseConnectorServiceMock(body, 400));
		// This is custom metadata, Query is allowed in Test Classes
		List<Case_Connector_Settings__mdt> settings = [SELECT Case_Transfer_Destination_URL__c,Case_Transfer_URL__c,
                                                       DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,
                                                       Org_External_URL__c,QualifiedApiName,Sandbox_Production__c 
                                                       FROM Case_Connector_Settings__mdt where Org_External_URL__c =: URL.getSalesforceBaseUrl().toExternalForm()];
        if(settings.isEmpty()) throw new CaseConnectorExampleException('No Configurations found for this Org: '+URL.getSalesforceBaseUrl()+'. Please go to Case Connector Settings(Case_Connector_Settings__mdt) add configuration this Org.');
        else if(settings.size() > 1) throw new CaseConnectorExampleException('Multiple Configurations found for this Org: '+URL.getSalesforceBaseUrl().toExternalForm()+'. Please go to Case Connector Settings(Case_Connector_Settings__mdt) keep only one config and remove extra configurations this Org.');
        Case_Connector_Settings__mdt setting =  settings.get(0);
		try{
			CaseConnectorUtil.CaseTransferResponseModal transferResponse = CaseConnectorUtil.sendToDestination(new CaseConnectorUtil.CaseConnectorTransferModel('caseId', 'destination', 'route', 'subject', 'description', 'priority', true, true) , setting, new CaseConnectorExampleException());
			System.assert(false, 'Execution should not reach here...');
		}catch(Exception ex){
			System.assertEquals( true, ex instanceof CaseConnectorExampleException);
			CaseConnectorExampleException ccException = (CaseConnectorExampleException)ex;
			System.assertEquals(400, ccException.httpCode, 'Status httpcode should be 400');
		}
	}

	@isTest static void successsfulGetTargetCaseDetails() {
		String body = '{"id":"tracking id","timestamp":"transfer date","source":"PeopleForce","sourceId":"500n0000006bolR","destination":"SupportForce","destinationId":"500n0000006bolx","destinationNumber":"1234567890"}';
		Test.setMock(HttpCalloutMock.class, new CaseConnectorServiceMock(body, 200));
		// This is custom metadata, Query is allowed in Test Classes
		List<Case_Connector_Settings__mdt> settings = [SELECT Case_Transfer_Destination_URL__c,Case_Transfer_URL__c,
                                                       DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,
                                                       Org_External_URL__c,QualifiedApiName,Sandbox_Production__c 
                                                       FROM Case_Connector_Settings__mdt where Org_External_URL__c =: URL.getSalesforceBaseUrl().toExternalForm()];
        if(settings.isEmpty()) throw new CaseConnectorExampleException('No Configurations found for this Org: '+URL.getSalesforceBaseUrl()+'. Please go to Case Connector Settings(Case_Connector_Settings__mdt) add configuration this Org.');
        else if(settings.size() > 1) throw new CaseConnectorExampleException('Multiple Configurations found for this Org: '+URL.getSalesforceBaseUrl().toExternalForm()+'. Please go to Case Connector Settings(Case_Connector_Settings__mdt) keep only one config and remove extra configurations this Org.');
        Case_Connector_Settings__mdt setting =  settings.get(0);

        CaseConnectorUtil.CaseConnectorTargetCaseModel targetCaseDetails = CaseConnectorUtil.getTargetOrgCaseDetails(setting, 'trasactionId', new CaseConnectorExampleException());
        System.assertNotEquals(null, targetCaseDetails);
        System.assertNotEquals(null, targetCaseDetails.destinationId);
        System.assertNotEquals(null, targetCaseDetails.destinationNumber);

	}

	@isTest static void failedGetTargetCaseDetails() {
		String body = '{"message":"Mocking Error from Case Connector"}';
		Test.setMock(HttpCalloutMock.class, new CaseConnectorServiceMock(body, 400));
		// This is custom metadata, Query is allowed in Test Classes
		List<Case_Connector_Settings__mdt> settings = [SELECT Case_Transfer_Destination_URL__c,Case_Transfer_URL__c,
                                                       DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,
                                                       Org_External_URL__c,QualifiedApiName,Sandbox_Production__c 
                                                       FROM Case_Connector_Settings__mdt where Org_External_URL__c =: URL.getSalesforceBaseUrl().toExternalForm()];
        if(settings.isEmpty()) throw new CaseConnectorExampleException('No Configurations found for this Org: '+URL.getSalesforceBaseUrl()+'. Please go to Case Connector Settings(Case_Connector_Settings__mdt) add configuration this Org.');
        else if(settings.size() > 1) throw new CaseConnectorExampleException('Multiple Configurations found for this Org: '+URL.getSalesforceBaseUrl().toExternalForm()+'. Please go to Case Connector Settings(Case_Connector_Settings__mdt) keep only one config and remove extra configurations this Org.');
        Case_Connector_Settings__mdt setting =  settings.get(0);
		try{
			CaseConnectorUtil.CaseConnectorTargetCaseModel targetCaseDetails = CaseConnectorUtil.getTargetOrgCaseDetails(setting, 'trasactionId', new CaseConnectorExampleException());
			System.assert(false, 'Execution should not reach here...');
		}catch(Exception ex){
			System.assertEquals( true, ex instanceof CaseConnectorExampleException);
			CaseConnectorExampleException ccException = (CaseConnectorExampleException)ex;
			System.assertEquals(400, ccException.httpCode, 'Status httpcode should be 400');
		}
	}
    
    @isTest static void successRegistration() {
        CaseConnectorUtil.CaseTransferRegistrationModel registrations= CaseConnectorUtil.getTransferRegistration();
        System.assert(registrations != null, 'Registrations must be configured.');
    }

	global class CaseConnectorServiceMock implements HttpCalloutMock {
		public CaseConnectorServiceMock(String body, Integer httpCode){
			this.body = body;
			this.httpCode = httpCode;
		}
		public String body{get; set;}
		public Integer httpCode{get; set;}
	    global HTTPResponse respond(HTTPRequest req) {
	    	HttpResponse res = new HttpResponse();
	        res.setHeader('Content-Type', 'application/json');
	        res.setBody(body);
	        res.setStatusCode(httpCode);
	        return res;
	    }
	}
}