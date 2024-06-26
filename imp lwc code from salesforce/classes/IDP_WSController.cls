/**
 * Controller for IDP conponents
 * Test Class: IDP_WSControllerTest
 */
public without sharing class IDP_WSController {
public static final string GENERAL_ERROR_MESSAGE = System.Label.IDP_GeneralErrorMessage;

// Method for initial load IDP payload from Peopleforce 
@AuraEnabled(cacheable=false)
public static IDP_WSControllerDTO getIDPList(String v2momEmpNum) {
	HttpRequest req = new HttpRequest();
	req.setEndpoint('callout:IDP_PF/services/apexrest/IDP/' + v2momEmpNum);
	req.setHeader('Content-Type', 'application/json');
	req.setMethod('GET');
	Http http = new Http();
	IDP_WSControllerDTO deserializedResponse = new IDP_WSControllerDTO();
	try {
		HTTPResponse res = http.send(req);
		if (res.getStatusCode() == 200) {
			deserializedResponse = IDP_WSControllerDTO.parse(res.getBody());
			deserializedResponse.sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
		} else {
			deserializedResponse.errorMessage = GENERAL_ERROR_MESSAGE;
		}
	} catch (Exception e) {
		System.debug('Exception' + e.getMessage());
		deserializedResponse.errorMessage = GENERAL_ERROR_MESSAGE;
	}
	return deserializedResponse;
}

// Method to use salesforce standard apis and update a field
// Used to update IDP fields directly (like Long term and short term goals) and for deletion i.e. updates isDeleted field
@AuraEnabled(cacheable=false)
public static Boolean updateText(String fieldName, String fieldValue, String recordId, String objectName) {
	HttpRequest req = new HttpRequest();
	req.setEndpoint('callout:IDP_PF/services/data/v50.0/sobjects/' + objectName + '/' + recordId);
	req.setHeader('Content-Type', 'application/json');
	req.setMethod('PATCH');

	if (fieldValue == 'True') {
		Map<String, Boolean> fieldNValue = new Map<String, Boolean>();
		fieldNValue.put(fieldName, true);
		if(objectName == 'IDP_Action__c'){
		fieldNValue.put('Synced__c', false);
		}
		req.setBody(JSON.serialize(fieldNValue));
	} else {
		Map<String, String> fieldNValue = new Map<String, String>();
		fieldNValue.put(fieldName, fieldValue);
		req.setBody(JSON.serialize(fieldNValue));
	}
	Http http = new Http();
	boolean bool;
	try {
		HTTPResponse res = http.send(req);
		if (res.getStatusCode() == 200 || res.getStatusCode() == 204) {
			bool = true;
		}
	} catch (exception ex) {
		System.debug('Exception' + ex.getMessage());
		bool = false;
	}
	return bool;
}

// Method to call custom webservice in peopleforce org
// Update an entire Objective with all Actions
@AuraEnabled(cacheable=false)
public static IDP_ObjectivePatchWSDTO patchObjectives(String payload) {
	Map<String, Object> payloadMap = (Map<String, Object>) JSON.deserializeUntyped(payload);
	IDP_ObjectivePatchWSDTO patchRequestBody = new IDP_ObjectivePatchWSDTO();
	String objectiveId = String.valueOf(payloadMap.get('objectiveId'));
	patchRequestBody.idpRecordId = String.valueOf(payloadMap.get('idpId'));
	if (objectiveId instanceof Id) {
		patchRequestBody.recordId = objectiveId;
	} else {
		patchRequestBody.recordId = null;
	}

	patchRequestBody.objectiveName = (String) payloadMap.get('objectiveName');
	List<IDP_ObjectivePatchWSDTO.Actions> newActions = new List<IDP_ObjectivePatchWSDTO.Actions>();
	patchRequestBody.actions = new List<IDP_ObjectivePatchWSDTO.Actions>();
	if (payloadMap.containsKey('actions') && payloadMap.get('actions') != null) {
		patchRequestBody.actions = IDP_ObjectivePatchWSDTO.parseActions(JSON.serialize(payloadMap.get('actions')));
	}

	if (payloadMap.containsKey('newActions') && payloadMap.get('newActions') != null) {
		newActions = IDP_ObjectivePatchWSDTO.parseActions(JSON.serialize(payloadMap.get('newActions')));
	}

	if (!newActions.isEmpty()) {
		for (IDP_ObjectivePatchWSDTO.Actions eachNewAction : newActions) {
			eachNewAction.recordId = null;
			patchRequestBody.actions.add(eachNewAction);
		}
	}

	String ipdId = (String) payloadMap.get('idpId');

	HttpRequest req = new HttpRequest();
	req.setEndpoint('callout:IDP_PF/services/apexrest/IDP/' + ipdId);
	req.setHeader('Content-Type', 'application/json');
	req.setMethod('PATCH');

	req.setBody(JSON.serialize(patchRequestBody));
	Http http = new Http();
	IDP_ObjectivePatchWSDTO deserializedResponse = new IDP_ObjectivePatchWSDTO();
	try {
		HTTPResponse res = http.send(req);
		if (res.getStatusCode() == 200 || res.getStatusCode() == 204) {
			deserializedResponse = IDP_ObjectivePatchWSDTO.parse(res.getBody());
		} else {
			deserializedResponse.errorMessage = GENERAL_ERROR_MESSAGE;
		}
	} catch (Exception ex) {
		System.debug('Exception' + ex.getMessage());
		deserializedResponse.errorMessage = GENERAL_ERROR_MESSAGE;
	}
	return deserializedResponse;
}
}