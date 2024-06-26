public with sharing class CEMCI_AuthFormConsentTriggerHandler {
  // Method called on before Insert of AuthorizationFormConsent
  public static void onBeforeInsert(List<AuthorizationFormConsent> newList) {
  }

  // Method called on before Update of AuthorizationFormConsent
  public static void onBeforeUpdate(
    List<AuthorizationFormConsent> newList,
    Map<Id, AuthorizationFormConsent> newMap,
    List<AuthorizationFormConsent> oldList,
    Map<Id, AuthorizationFormConsent> oldMap
  ) {
  }

  // Method called on After Insert of AuthorizationFormConsent
  public static void onAfterInsert(
    Map<Id, AuthorizationFormConsent> newMap,
    List<AuthorizationFormConsent> oldList,
    Map<Id, AuthorizationFormConsent> oldMap,
    List<AuthorizationFormConsent> newList
  ) {
    CEMCI_AuthForm_ContactPoint_Consent.newAuthorizationFormConsents = newList;
    CEMCI_AuthForm_ContactPoint_Consent.newAuthorizationFormConsentMap = newMap;
    CEMCI_AuthForm_ContactPoint_Consent.createOptInOptOutContactPointConsent();
  }

  // Method called on After Update of AuthorizationFormConsent

  public static void onAfterUpdate(
    Map<Id, AuthorizationFormConsent> newMap,
    List<AuthorizationFormConsent> oldList,
    Map<Id, AuthorizationFormConsent> oldMap,
    List<AuthorizationFormConsent> newList
  ) {
  }
}