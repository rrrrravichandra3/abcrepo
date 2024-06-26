public with sharing class CEMCI_ConvertedLeadController {
  @AuraEnabled
  public static List<Lead> getLeads(Id cId) {
    Boolean hasAccessToConvertedLeads = FeatureManagement.checkPermission('CEMCI_View_Converted_Leads');

    if (hasAccessToConvertedLeads) {
      return [
        SELECT Id, Name, LastModifiedDate
        FROM Lead
        WHERE IsConverted = TRUE AND ConvertedContactId = :cId
        ORDER BY LastModifiedDate DESC
      ];
    }

    return null;
  }
}