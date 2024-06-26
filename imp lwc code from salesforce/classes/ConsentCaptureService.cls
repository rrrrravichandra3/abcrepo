/**
 * Created by stephan.garcia on 2019-09-04.
 */

public with sharing class ConsentCaptureService {
  // Get the Consent records for a record Id passed from LWC
  @AuraEnabled
  public static List<Map<String, Object>> getIndividualConsent(Id recordId) {
    // Get the individual id based on the type of record the flow is accessed from
    Id individualId = IndividualUtilities.getIndividualId(recordId);

    List<Map<String, Object>> finalConsentList = new List<Map<String, Object>>();
    finalConsentList = CEMCI_RetrieveGDPRConsents.getConsents(recordId, individualId);

    return finalConsentList;
  }

  // Get the Description on the Contact Point Consent Type Records
  public static String getContactPointTypeDescription(String cpTypeListString) {
    List<CEMCI_Consent_Capture_Utility__mdt> consentCaptureSettings = [
      SELECT Id, Output_Value__c
      FROM CEMCI_Consent_Capture_Utility__mdt
      WHERE Setting_Type__c = 'description' AND Contact_Point_Consent_Type_Value__c = :cpTypeListString
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];

    CEMCI_Consent_Capture_Utility__mdt consentCaptureSetting = (consentCaptureSettings.size() == 1)
      ? consentCaptureSettings.get(0)
      : null;

    return consentCaptureSetting.Output_Value__c;
  }
}