@isTest
public class PF_PublishCaseToCaseConnectorTest {
    @isTest
    public static void validateGetAppSettings() {
        Object expectedSettings = PF_PublishCaseToCaseConnector.getAppSettings();
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
        Object actualSettings = JSON.serialize(settings);

        System.assertEquals(expectedSettings, actualSettings);
    }

    @isTest
    public static void validateGetDestinations() {
        Test.setMock(HttpCalloutMock.class, new PF_DestOrgMockHttpResponse());
        HttpResponse res = PF_MockHttpCallout.getResponse();
        Object expectedDestinations = PF_PublishCaseToCaseConnector.getDestinations();
        List<CaseConnectorUtil.CaseConnectorDestinationResponse> destinations = (List<CaseConnectorUtil.CaseConnectorDestinationResponse>)JSON.deserialize(res.getBody(), List<CaseConnectorUtil.CaseConnectorDestinationResponse>.class);
        Object actualDestinations = JSON.serialize(new CaseConnector_PeopelforceToSupportforce.CaseConnectorDestinationResponseModal(false, null, destinations));
        System.assertEquals(expectedDestinations, actualDestinations);
    }

    @isTest
    public static void validateSendToDestination() {
        Case caseObj = createCase();
        String destinationOrg = 'SupportForce';
        String description = 'Test desc';
        String priority = 'Low';
        Boolean transferAttachments = true;
        Boolean transferComments = true;
        String caseId = String.valueOf(caseObj.Id);
        Object expectedObj = PF_PublishCaseToCaseConnector.sendToDestination(caseId, destinationOrg, '', caseObj.Subject, description, priority.toUpperCase(), transferAttachments, transferComments, caseObj.PII__c);
        CaseConnector_PforceToSforceUtil.CaseConnectorResponse response =  CaseConnector_PforceToSforceUtil.sendToDestination(caseObj, destinationOrg, '', caseObj.Subject, description, priority.toUpperCase(), transferAttachments, transferComments, caseObj.PII__c);
        Object actualObj = JSON.serialize(response);
        System.assertEquals(expectedObj, actualObj);
    }

    @isTest
    public static void validateGetCaseRecord() {
        Case caseObj = createCase();
        String caseId = String.valueOf(caseObj.Id);
        System.assertEquals((PF_PublishCaseToCaseConnector.getCaseRecord(caseId)).caseRecord.Id, caseObj.Id);
        System.assertEquals(PF_PublishCaseToCaseConnector.getCaseRecord(null), null);
    }

    public static Case createCase(){
        Account acc = new Account();
        acc.Name = 'Test acc';
        insert acc;
        Contact c = new Contact();
        c.LastName = 'Test Cont Last';
        c.AccountId = acc.Id;
        insert c;
        
        String subject = 'Test ticket';
        String priority = 'Low';
        String pII = 'No';
        Case caseObj = new Case();
        caseObj.Subject = subject;
        caseObj.ContactId = c.Id;
        caseObj.Origin = 'Phone';
        caseObj.PII__c = pII;
        caseObj.Priority = priority;
        caseObj.Status = 'New';
        caseObj.Type = 'NH Recruiting';
        caseObj.ES_DJC_Topic__c = 'Changes';
        insert caseObj;
        return caseObj;
    }
}