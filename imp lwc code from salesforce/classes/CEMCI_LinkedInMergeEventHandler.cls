/**
 * Created by kmoseley on 10/13/21.
 */

public with sharing class CEMCI_LinkedInMergeEventHandler {
  public static void processEvents(List<CEMCI_LinkedInMerge__e> events) {
    List<SObject> recordsToProcess = new List<SObject>();
    Set<String> linkedInStrings = new Set<String>();
    for (CEMCI_LinkedInMerge__e e : events) {
      if (e.LinkedIn_Substring__c != null)
        linkedInStrings.add(e.LinkedIn_Substring__c);
    }

    if (!linkedInStrings.isEmpty()) {
      String query = 'Select Id,Email,Confidential__c,OwnerId,IndividualId,Linked_In_URL__c,LinkedIn_Substring__c from Lead where IsConverted = false and LinkedIn_Substring__c IN: linkedInStrings';
      recordsToProcess = Database.query(query);

      CEMCI_DuplicateService dupeService = new CEMCI_DuplicateService(recordsToProcess, 'LinkedIn');
      dupeService.findDuplicates();
    }
  }
}