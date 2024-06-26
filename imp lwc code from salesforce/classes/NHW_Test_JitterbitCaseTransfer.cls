@isTest
global class NHW_Test_JitterbitCaseTransfer {


	private static final String SENT_TO_SUPPORTFORCE = 'Sent to Supportforce';

	@TestSetup
	private static void setupData(){
		NH_Settings__c setting = new NH_Settings__c(Jitterbit_PF_To_SF_Service_URL__c ='https://test-salesforce.jitterbit.net/PF_Service_Cloud__Onboarding-Dev/NHWCasesPFtoSF', 
													JitterbitAuthText__c='testauthtext',
													NoOfDaysBeforeStartDateToSendRemindEmail__c = 15);
		insert setting;
		Contact candidateId = NHW_TestFactory.createCandidate('fName', 'lName', 'email2@mailinator.com');
		Id preboardingCaseRecTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('New_Hire_Process').getRecordTypeId();
		Case cse = new Case(RecordTypeId = preboardingCaseRecTypeId, Origin='NHW', 
							Subject='New Hire Preboarding Request for Testing after preboarding transfer 2',
							Type='NHW', ContactId=candidateId.Id, Status='New');
		insert cse;
	}

	public static testMethod void preboardingCaseTransfer(){

		Case afterInsertCase = [SELECT Id, CaseNumber, Status FROM Case LIMIT 1];
		Test.startTest();
		afterInsertCase.Status=SENT_TO_SUPPORTFORCE;
        afterInsertCase.NHW_Start_Date__c = System.today().addDays(12);
		Test.setMock(HttpCalloutMock.class, new JitterbitRespnseMock(afterInsertCase.Id+','+afterInsertCase.CaseNumber+',supportforcesid,true," "'));
		NHWCaseTriggerHandler.afterCallsExecuted = false;
		update afterInsertCase;
		Test.stopTest();
		Case afterSentToSupportforce = [SELECT Id, CaseNumber, Status, ESDJC_Supportforce_Case_Id__c FROM Case where Id=: afterInsertCase.Id];
		System.assertEquals(null, afterSentToSupportforce.ESDJC_Supportforce_Case_Id__c, 'Case Supportforce Id should be null as case is not transferred (As mock service responds)');

    }
    
    public static testMethod void preboardingCaseTransferNoResponseSendEmail(){
		Contact candidateId = NHW_TestFactory.createCandidate('fName', 'lName', 'email@mailinator.com');
		Id preboardingCaseRecTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('New_Hire_Process').getRecordTypeId();
		Case cse = new Case(RecordTypeId = preboardingCaseRecTypeId, Origin='NHW', 
							Subject='New Hire Preboarding Request for Testing after preboarding transfer',
							Type='NHW', ContactId=candidateId.Id, Status='New');
		insert cse;
		Case afterInsertCase = [SELECT Id, CaseNumber, Status FROM Case where Id=: cse.Id];
		Test.startTest();
		afterInsertCase.Status=SENT_TO_SUPPORTFORCE;
		Test.setMock(HttpCalloutMock.class, new JitterbitRespnseMock(''));
		NHWCaseTriggerHandler.afterCallsExecuted = false;
		update afterInsertCase;
		Test.stopTest();
		Case afterSentToSupportforce = [SELECT Id, CaseNumber, Status, ESDJC_Supportforce_Case_Id__c FROM Case LIMIT 1];
		System.assertEquals(null, afterSentToSupportforce.ESDJC_Supportforce_Case_Id__c, 'Case Supportforce Id should be null (As mock service responds)');
    }

    public static testMethod void preboardingCaseTransferErrorInSupportforce(){
		Contact candidateId = NHW_TestFactory.createCandidate('fName', 'lName', 'email@mailinator.com');
		Id preboardingCaseRecTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('New_Hire_Process').getRecordTypeId();
		Case cse = new Case(RecordTypeId = preboardingCaseRecTypeId, Origin='NHW', 
							Subject='New Hire Preboarding Request for Testing after preboarding transfer',
							Type='NHW', ContactId=candidateId.Id, Status='New');
		insert cse;
		Case afterInsertCase = [SELECT Id, CaseNumber, Status FROM Case where Id=: cse.Id];
		Test.startTest();
		afterInsertCase.Status=SENT_TO_SUPPORTFORCE;
		Test.setMock(HttpCalloutMock.class, new JitterbitRespnseMock(afterInsertCase.Id+','+afterInsertCase.CaseNumber+',"",false,errored in supportforce'));
		NHWCaseTriggerHandler.afterCallsExecuted = false;
		update afterInsertCase;
		Test.stopTest();
		Case afterSentToSupportforce = [SELECT Id, CaseNumber, Status, ESDJC_Supportforce_Case_Id__c FROM Case LIMIT 1];
		System.assertEquals(null, afterSentToSupportforce.ESDJC_Supportforce_Case_Id__c, 'Jitterbit responds with error message from Supportforce. So Supportforce Case Id should be null');

    }
    global class JitterbitRespnseMock implements HttpCalloutMock {
    	public String response{get; set;}
    	public JitterbitRespnseMock( String expectedResponse){
			response = expectedResponse;
    	}
	    global HTTPResponse respond(HTTPRequest req) {
	        HTTPResponse responseObject = new HTTPResponse();
			responseObject.setStatusCode(200);
	        responseObject.setBody(this.response);
	        return responseObject;
	    }
	}

}