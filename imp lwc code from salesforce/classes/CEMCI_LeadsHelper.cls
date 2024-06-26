public without sharing class CEMCI_LeadsHelper {
  //*****************************************************************************
  // Method to convert leads to contacts in system context
  //****************************************************************************/

  public static Database.LeadConvertResult[] convertRecords(List<Database.LeadConvert> leadConverts) {
    return Database.convertLead(leadConverts, false);
  }

  public static Database.MergeResult[] mergeLeadToLead(Lead masterLead, List<Lead> duplicateLeads) {
    Database.MergeResult[] results = new List<Database.MergeResult>{};
    return Database.merge(masterLead, duplicateLeads, false);
  }

  public static Database.MergeResult[] mergeContactToContact(Contact masterContact, List<Contact> duplicateContacts) {
    Database.MergeResult[] results = new List<Database.MergeResult>{};
    return Database.merge(masterContact, duplicateContacts, false);
  }
}