public with sharing class CEMCI_GDPR_DispatcherClass {
  public static List<sObject> createIndividualRecordsForsObject(
    List<SObject> recordsWithoutIndividual,
    String objectType
  ) {
    List<sObject> resultList;

    CEMCI_GDPR_Handler handleRecord = new CEMCI_GDPR_Handler();
    resultList = handleRecord.createIndividual(recordsWithoutIndividual);

    return resultList;
  }

  public static void createContactPointRecordsForsObject(List<SObject> recordsWithIndividual) {
    CEMCI_GDPR_Handler handleRecord = new CEMCI_GDPR_Handler();
    handleRecord.createContactPoint(recordsWithIndividual);
  }

  public static void createSourceSpecificConsentRecordsForsObject(
    List<SObject> recordsWithIndividual,
    String objectType
  ) {
    CEMCI_GDPR_Handler handleRecord = new CEMCI_GDPR_Handler();
    handleRecord.createConsentRecords(recordsWithIndividual, objectType);
  }

  public static void mergeGDPRRecordsForSObject(List<SObject> recordsToProcess) {
    CEMCI_GDPR_Handler.mergeGDPRRecords(recordsToProcess);
  }

  public static void createOptInOptOutConsentRecords(
    Set<Id> individualIds,
    Map<Id, Map<Id, Id>> dataUsePurposeMap,
    Map<Id, Map<Id, String>> contactPointTypeMap,
    Map<Id, Map<Id, String>> consentCategoryMap,
    Map<Id, DateTime> mapOfAuthFormConIdMemResDT
  ) {
    CEMCI_GDPR_Handler handleRecord = new CEMCI_GDPR_Handler();
    handleRecord.createOptInOptOutContactPointConsentRecords(
      individualIds,
      dataUsePurposeMap,
      contactPointTypeMap,
      consentCategoryMap,
      mapOfAuthFormConIdMemResDT
    );
  }
}