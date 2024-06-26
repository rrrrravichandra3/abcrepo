public with sharing class CEMCI_AuthForm_ContactPoint_Consent {
  public static List<AuthorizationFormConsent> newAuthorizationFormConsents;
  public static Map<Id, AuthorizationFormConsent> newAuthorizationFormConsentMap;

  //*****************************************************************************
  // Method to create contact point consent
  //****************************************************************************/

  public static void createOptInOptOutContactPointConsent() {
    Set<Id> individualIds = new Set<Id>();
    Map<Id, Map<Id, Id>> dataUsePurposeMap = new Map<Id, Map<Id, Id>>();
    Map<Id, Map<Id, String>> contactPointTypeMap = new Map<Id, Map<Id, String>>();
    Map<Id, Map<Id, String>> consentCategoryMap = new Map<Id, Map<Id, String>>();
    Map<Id, DateTime> mapOfAuthFormConIdMemResDT = new Map<Id, DateTime>();

    for (AuthorizationFormConsent authFormconsent : newAuthorizationFormConsents) {
      if (!contactPointTypeMap.containskey(authFormconsent.Id))
        contactPointTypeMap.put(authFormconsent.Id, new Map<Id, String>());

      contactPointTypeMap.get(authFormconsent.Id).put(authFormconsent.ConsentGiverId, authFormconsent.Name);
    }

    for (AuthorizationFormConsent authFormconsent : [
      SELECT
        Id,
        ConsentGiverId,
        AuthorizationFormText.Data_Use_Purpose__c,
        AuthorizationFormText.Data_Use_Purpose__r.Consent_Category__c,
        Member_Responded_Datetime__c
      FROM AuthorizationFormConsent
      WHERE Id IN :newAuthorizationFormConsentMap.keySet()
    ]) {
      individualIds.add(authFormconsent.ConsentGiverId);

      if (!dataUsePurposeMap.containskey(authFormconsent.Id))
        dataUsePurposeMap.put(authFormconsent.Id, new Map<Id, Id>());

      dataUsePurposeMap.get(authFormconsent.Id)
        .put(authFormconsent.ConsentGiverId, authFormconsent.AuthorizationFormText.Data_Use_Purpose__c);

      if (!consentCategoryMap.containskey(authFormconsent.Id))
        consentCategoryMap.put(authFormconsent.Id, new Map<Id, String>());

      consentCategoryMap.get(authFormconsent.Id)
        .put(
          authFormconsent.ConsentGiverId,
          authFormconsent.AuthorizationFormText.Data_Use_Purpose__r.Consent_Category__c
        );

      mapOfAuthFormConIdMemResDT.put(authFormconsent.Id, authFormconsent.Member_Responded_Datetime__c);
    }

    CEMCI_GDPR_DispatcherClass.createOptInOptOutConsentRecords(
      individualIds,
      dataUsePurposeMap,
      contactPointTypeMap,
      consentCategoryMap,
      mapOfAuthFormConIdMemResDT
    );
  }
}