@isTest
global class Test_CaseConnector_PFToSF {
	
	@testSetup
	public static void createtestData(){
		Contact cnt = new Contact(EMail = 'Test@test.com', FirstName='Test', LastName='Test');
		insert cnt;
		List<Case> cases = new List<Case>{new Case(ContactId=cnt.Id, Subject='Case Subject', Description='Case Description', PII__c='No', Origin='Chatter', Type='Talentforce', ES_DJC_Topic__c='Alert ES of Change', ES_DJC_Sub_Topic__c='Change Data', RecordTypeId='012700000005qHn'),
										new Case(ContactId=cnt.Id, Subject='Case Subject', Description='Case Description', PII__c='No', Origin='Chatter', Type='Talentforce', ES_DJC_Topic__c='Alert ES of Change', ES_DJC_Sub_Topic__c='Change Data', RecordTypeId='012700000005qHn'), 
										new Case(ContactId=cnt.Id, Subject='Case Subject', Description='Case Description', PII__c='No', Origin='Chatter', Type='Talentforce', ES_DJC_Topic__c='Alert ES of Change', ES_DJC_Sub_Topic__c='Change Data', RecordTypeId='012700000005qHn')};
		insert cases;
	}
	
	@isTest static void testISCCalculation() {
		String isc = CaseConnector_PforceToSforceUtil.getInternalSupportCategory('V2MOM Support', 'V2MOM Support','');
		List<Internal_Support_Category_Translation__mdt> iscTranslationTable = [SELECT Type__c, Topic__c, SubTopic__c, Internal_Support_Category__c from Internal_Support_Category_Translation__mdt 
																					WHERE Target_Org__c ='SupportForce' AND Type__c='V2MOM Support' AND Topic__c='V2MOM Support' ORDER BY Rank__c ASC];
		System.assert(!iscTranslationTable.isEmpty(), 'There should be atleast Work.com ISC');
		System.assertEquals(iscTranslationTable[0].Internal_Support_Category__c, isc, 'ISC sholuld match with first ISC in the list when there is Subtopic');

		String talentForceISC = CaseConnector_PforceToSforceUtil.getInternalSupportCategory('Talentforce', 'Alert ES of Change', 'Cancel Placement');

		List<Internal_Support_Category_Translation__mdt> iscTranslationTable2 = [SELECT Type__c, Topic__c, SubTopic__c, Internal_Support_Category__c from Internal_Support_Category_Translation__mdt 
																					WHERE Target_Org__c ='SupportForce' AND Type__c='Talentforce' AND Topic__c= 'Alert ES of Change' AND Subtopic__c = 'Cancel Placement' ORDER BY Rank__c ASC];

		System.assert(!iscTranslationTable2.isEmpty(), 'There should be atleast Work.com ISC');
		System.assertEquals(iscTranslationTable2[0].Internal_Support_Category__c, talentForceISC, 'ISC sholuld match with first ISC in the list when there is Subtopic');
		Case_Connector_Settings__mdt metadata = CaseConnector_PforceToSforceUtil.getConfigurationForThisOrg();
		System.assert(metadata != null);

	}
	
	@isTest static void successfullTransferSingleCase() {
		List<Case> cases = [SELECT Id FROM Case];
		String dest = '[{"name":"SupportForce","routes":["Frank Internal Support","Internal Salesforce.com App: New User/User Maintenance","Security: Access Badge","IT - Finance Systems: Software","ESAS - Sales GTM","IT Helpdesk - Other","Security: Enterprise Security: Security Architecture/Design Review","Talentforce Internal Support","Internal Work.com App - New User Access"]},{"name":"Org62","routes":["Frank Internal Support","Internal Salesforce.com App: New User/User Maintenance","Security: Access Badge","IT - Finance Systems: Software","ESAS - Sales GTM","IT Helpdesk - Other","Security: Enterprise Security: Security Architecture/Design Review","Talentforce Internal Support","Internal Work.com App - New User Access"]}]';
		String transfer = '{"id":"cfff9bc6-6a5a-417a-bf37-a0fe900333bb"}';
		String otherOrg = '{"id":"tracking id","timestamp":"transfer date","source":"PeopleForce","sourceId":"'+cases[0].Id+'","destination":"SupportForce","destinationId":"500n0000006bolx","destinationNumber":"1234567890"}';
		Test.setMock(HttpCalloutMock.class, new CaseConnectorServiceMock(dest, transfer, otherOrg));
		Test.startTest();
		CaseConnectorMultiCaseTransferCtrl ctrl = new CaseConnectorMultiCaseTransferCtrl(new ApexPages.StandardSetController(cases));
		ctrl.selectedCases = [SELECT Id, CaseNumber, PII__c, Origin, ContactId, Status, Subject, Description, Type, ES_DJC_Topic__c, ES_DJC_Sub_Topic__c, 
                                        ESDJC_Supportforce_Case_Id__c, ESDJC_Supportforce_Case_Number__c, Priority FROM Case];
		Boolean validationFailedFlag = ctrl.anyValidationFailed;
		System.assertEquals(false, validationFailedFlag);
		List<SelectOption> destinations = ctrl.destinations;
		System.assertEquals(2, destinations.size());
		CaseConnector_PforceToSforceUtil.CaseConnectorResponse response = CaseConnectorMultiCaseTransferCtrl.transferThisCase(cases[0].Id, 'V2MOM Support', 'V2MOM Support', 'No', 'SupportForce');
		Case cse = [SELECT Id, ESDJC_Supportforce_Case_Number__c, ESDJC_Supportforce_Case_Id__c FROM Case where Id=: cases[0].Id];
		System.assertEquals('500n0000006bolx', cse.ESDJC_Supportforce_Case_Id__c);
		System.assertEquals('1234567890', cse.ESDJC_Supportforce_Case_Number__c);
		Test.stopTest();
	}

	@isTest static void validationFailed() {
		List<Case> cases = [SELECT Id, PII__c, Origin, ESDJC_Supportforce_Case_Number__c, ESDJC_Supportforce_Case_Id__c  FROM Case];
		String dest = '[{"name":"SupportForce","routes":["Frank Internal Support","Internal Salesforce.com App: New User/User Maintenance","Security: Access Badge","IT - Finance Systems: Software","ESAS - Sales GTM","IT Helpdesk - Other","Security: Enterprise Security: Security Architecture/Design Review","Talentforce Internal Support","Internal Work.com App - New User Access"]},{"name":"Org62","routes":["Frank Internal Support","Internal Salesforce.com App: New User/User Maintenance","Security: Access Badge","IT - Finance Systems: Software","ESAS - Sales GTM","IT Helpdesk - Other","Security: Enterprise Security: Security Architecture/Design Review","Talentforce Internal Support","Internal Work.com App - New User Access"]}]';
		String transfer = '{"id":"cfff9bc6-6a5a-417a-bf37-a0fe900333bb"}';
		String otherOrg = '{"id":"tracking id","timestamp":"transfer date","source":"PeopleForce","sourceId":"'+cases[0].Id+'","destination":"SupportForce","destinationId":"500n0000006bolx","destinationNumber":"1234567890"}';
		Test.setMock(HttpCalloutMock.class, new CaseConnectorServiceMock(dest, transfer, otherOrg));
		cases[0].PII__c = 'Yes';
		cases[1].Origin = null;
		cases[2].ESDJC_Supportforce_Case_Number__c = 'xyz';
		update cases;

		Test.startTest();
		CaseConnectorMultiCaseTransferCtrl ctrl = new CaseConnectorMultiCaseTransferCtrl(new ApexPages.StandardSetController(cases));
		ctrl.selectedCases = [SELECT Id, CaseNumber, PII__c, Origin, ContactId, Status, Subject, Description, Type, ES_DJC_Topic__c, ES_DJC_Sub_Topic__c, 
                                        ESDJC_Supportforce_Case_Id__c, ESDJC_Supportforce_Case_Number__c, Priority FROM Case];
		Boolean validationFailedFlag = ctrl.anyValidationFailed;
		System.assertEquals(true, validationFailedFlag);
		System.assert(ctrl.message.contains(Label.Case_Connector_PII_Case_Transfer_Message));
		System.assert(ctrl.message.contains(Label.Case_Connector_Validation_Message));
		System.assert(ctrl.message.contains(Label.Case_Connector_Multiple_Cases_already_Transferred_Message));
		Test.stopTest();
	}

	global class CaseConnectorServiceMock implements HttpCalloutMock {
		private String transferResponseJSON{get; set;}
		private String otherOrgDetails{get; set;}
		private String destinationResponseJSON{get; set;}
		private String whichCallout{get; set;}
		public CaseConnectorServiceMock(String dest, String transfer, String otherOrg){
			this.destinationResponseJSON = dest;
			this.transferResponseJSON = transfer;
			this.otherOrgDetails = otherOrg;

		}
	    global HTTPResponse respond(HTTPRequest req) {
	        
	        HttpResponse res = new HttpResponse();
	        res.setHeader('Content-Type', 'application/json');
	        if(whichCallout == null){
	        	res.setBody(destinationResponseJSON);
	        	whichCallout='Transfer';
        	}else if(whichCallout == 'Transfer'){
        		res.setBody(transferResponseJSON);
        		whichCallout = 'otehrOrg';
        	}else{
        		res.setBody(otherOrgDetails);
        	}
	        
	        res.setStatusCode(200);
	        return res;
	    }
	}
}