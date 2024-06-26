public with sharing class CEMCI_ContactTriggerHandler {
  //*****************************************************************************
  // Method called on before Insert of Contacts
  //****************************************************************************/

  public static void onBeforeInsert(List<Contact> newList) {
    CEMCI_Contacts.newContacts = newList;
    CEMCI_Contacts.updateDisqualifiedContacts();
    CEMCI_Contacts.setIsValidLinkedInURL();
    CEMCI_Contacts.setConfidentialTextField();
    CEMCI_Contacts.setContactOwneronLeadConvert();
    CEMCI_Contacts.setHardOptOut();
    CEMCI_Contacts.setLinkedInSubstring();
    if (!CEMCI_CheckGDPRRecursion.getdoNotRunGDPRFlow())
      CEMCI_Contacts.createIndividualforContacts();
  }

  //*****************************************************************************
  // Method called on before Update of Contacts
  //****************************************************************************/

  public static void onBeforeUpdate(
    List<Contact> newList,
    Map<Id, Contact> newMap,
    List<Contact> oldList,
    Map<Id, Contact> oldMap
  ) {
    CEMCI_Contacts.newContacts = newList;
    CEMCI_Contacts.oldContacts = oldList;
    CEMCI_Contacts.newContactMap = newMap;
    CEMCI_Contacts.oldContactMap = oldMap;
    CEMCI_Contacts.updateDisqualifiedContacts();
    CEMCI_Contacts.setIsValidLinkedInURL();
    CEMCI_Contacts.setConfidentialTextField();
    CEMCI_Contacts.setHardOptOut();
    CEMCI_Contacts.setLinkedInSubstring();
    if (!CEMCI_CheckGDPRRecursion.getdoNotRunGDPRFlow())
      CEMCI_Contacts.createIndividualforContacts();
  }

  //*****************************************************************************
  // Method called on After Insert of Contacts
  //****************************************************************************/

  public static void onAfterInsert(Map<Id, Contact> newMap, List<Contact> oldList, Map<Id, Contact> oldMap) {
    CEMCI_Contacts.oldContacts = oldList;
    CEMCI_Contacts.newContactMap = newMap;
    CEMCI_Contacts.oldContactMap = oldMap;
    if (!CEMCI_CheckGDPRRecursion.getdoNotRunGDPRFlow())
      CEMCI_Contacts.createContactPointRecordsforContacts();
  }

  //*****************************************************************************
  // Method called on After Update of Contacts
  //****************************************************************************/

  public static void onAfterUpdate(Map<Id, Contact> newMap, List<Contact> oldList, Map<Id, Contact> oldMap) {
    CEMCI_Contacts.oldContacts = oldList;
    CEMCI_Contacts.newContactMap = newMap;
    CEMCI_Contacts.oldContactMap = oldMap;
    if (!CEMCI_CheckGDPRRecursion.getdoNotRunGDPRFlow()) {
      CEMCI_Contacts.createContactPointRecordsforContacts();
      CEMCI_Contacts.processRecordsForContactMerge();
    }
    CEMCI_Contacts.expireContactConsentForOldEmailPhone();
  }

  //*****************************************************************************
  // Method called on After Delete of Contacts
  //****************************************************************************/

  public static void onAfterDelete(List<Contact> oldList) {
    CEMCI_Contacts.oldContacts = oldList;
    if (!CEMCI_CheckGDPRRecursion.getdoNotRunGDPRFlow())
      CEMCI_Contacts.mergeGDPRRecordsforContacts();
  }
}