public with sharing class CEMCI_LeadTriggerHandler {
  //*****************************************************************************
  // Method called on before Insert of Leads
  //****************************************************************************/
  public static void onBeforeInsert(List<Lead> newList) {
    if (!CEMCI_CheckGDPRRecursion.getdoNotRunLeadMergeFlow() && !CEMCI_CheckGDPRRecursion.getdoNotRunLeadTriggers()) {
      CEMCI_Leads.newLeads = newList;
      CEMCI_Leads.setIsValidLinkedInURL();
      CEMCI_Leads.setLinkedInSubstring();
      CEMCI_Leads.createIndividualRecordsforLeads();
      CEMCI_Leads.isEligibleForDupeService();
      CEMCI_Leads.mapLinkedinCountryToSfCountry();
      CEMCI_Leads.updateOwnerIfRMMorSysAdmin();
      CEMCI_Leads.updateAddressFields();
    }
  }
  //*****************************************************************************
  // Method called on before Update of Leads
  //****************************************************************************/
  public static void onBeforeUpdate(
    List<Lead> newList,
    Map<Id, Lead> newMap,
    List<Lead> oldList,
    Map<Id, Lead> oldMap
  ) {
    if (!CEMCI_CheckGDPRRecursion.getdoNotRunLeadTriggers()) {
      CEMCI_Leads.newLeads = newList;
      CEMCI_Leads.oldLeads = oldList;
      CEMCI_Leads.newLeadMap = newMap;
      CEMCI_Leads.oldLeadMap = oldMap;
      CEMCI_Leads.setIsValidLinkedInURL();
      CEMCI_Leads.setLinkedInSubstring();
      CEMCI_Leads.isEligibleForDupeService();
      CEMCI_Leads.createIndividualRecordsforLeads();
      CEMCI_Leads.updateOwnerIfRMMorSysAdmin();
      CEMCI_Leads.updateAddressFields();
    }
  }

  //*****************************************************************************
  // Method called on After Insert of Leads
  //****************************************************************************/
  public static void onAfterInsert(Map<Id, Lead> newMap, List<Lead> oldList, Map<Id, Lead> oldMap, List<Lead> newList) {
    if (!CEMCI_CheckGDPRRecursion.getdoNotRunLeadMergeFlow() && !CEMCI_CheckGDPRRecursion.getdoNotRunLeadTriggers()) {
      CEMCI_Leads.oldLeads = oldList;
      CEMCI_Leads.newLeads = newList;
      CEMCI_Leads.newLeadMap = newMap;
      CEMCI_Leads.oldLeadMap = oldMap;
      CEMCI_Leads.createContactPointRecordsforLeads();
      CEMCI_Leads.createCampaignMemberforLinkedIn();
      CEMCI_Leads.mergeToContactsAndLeads();
    }
  }
  //*****************************************************************************
  // Method called on After Update of Leads
  //****************************************************************************/
  public static void onAfterUpdate(Map<Id, Lead> newMap, List<Lead> oldList, Map<Id, Lead> oldMap, List<Lead> newList) {
    if (!CEMCI_CheckGDPRRecursion.getdoNotRunLeadTriggers()) {
      CEMCI_Leads.oldLeads = oldList;
      CEMCI_Leads.newLeads = newList;
      CEMCI_Leads.newLeadMap = newMap;
      CEMCI_Leads.oldLeadMap = oldMap;
      CEMCI_Leads.createContactPointRecordsforLeads();
      if (CheckRecursion.runOnce())
        CEMCI_Leads.updateDisqualifiedLeadsConvertedContacts();
      if (!CEMCI_CheckGDPRRecursion.getdoNotRunLeadMergeFlow())
        CEMCI_Leads.mergeToContactsAndLeads();
      CEMCI_Leads.mergeGDPRRecordsforLeads();
      CEMCI_Leads.expireLeadConsentForOldEmailPhone();
      //CEMCI_Leads.updateCampaignMembers();
    }
  }

  //*****************************************************************************
  // Method called on After Delete of Leads
  //****************************************************************************/
  public static void onAfterDelete(List<Lead> oldList) {
    if (!CEMCI_CheckGDPRRecursion.getdoNotRunLeadTriggers()) {
      CEMCI_Leads.oldLeads = oldList;
      CEMCI_Leads.mergeGDPRRecordsforLeads();
    }
  }
}