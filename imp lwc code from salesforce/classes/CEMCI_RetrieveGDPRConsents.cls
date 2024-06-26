/**
 * @description       : 
 * @author            : Urvish Shah (ushah)
 * @group             : 
 * @last modified on  : 03-09-2023
 * @last modified by  : Urvish Shah (ushah)
**/
public with sharing class CEMCI_RetrieveGDPRConsents {
  private static Set<Id> contactPointIdSet;
  private static Map<Id, List<ConsentUIWrapper>> contactPointEmailToConsentMap;
  private static Map<Id, List<ConsentUIWrapper>> contactPointPhoneToConsentMap;
  private static Map<Id, String> contactPointIdToNameMap;
  private static Map<String, String> allConsents;
  private static Id recordId;
  private static List<Map<String, Object>> resultList;
  private static final List<Schema.PicklistEntry> consentCategories = DataUsePurpose.Consent_Category__c.getDescribe()
    .getPicklistValues();

  public static List<Map<String, Object>> getConsents(Id recId, Id individualId) {
    resultList = new List<Map<String, Object>>();
    contactPointIdSet = new Set<Id>();
    contactPointIdToNameMap = new Map<Id, String>();
    recordId = recId;

    //If there are contact point records linked to Lead/ Contact then show component with consents
    //Every Contact point email should have one consent per category - currently Marketing and Recruiting
    //Every Contact point phone should have one consent for Recruiting
    //Consents are retrieved in the following order:
    //1. Retrieve all consents from system
    //2. If not all consents are in system - retrieve country defaults
    //3. If country blank on Lead/Contact or not all consents found for country - retrieve global defaults

    populateContactPoints(individualId);
    populateConsentFromSystem();
    populateCountryDefaultConsents();
    populateGlobalDefaultConsents();
    populateResultList();

    return resultList;
  }

  private static void populateConsentFromSystem() {
    if (!contactPointIdSet.isEmpty()) {
      contactPointEmailToConsentMap = new Map<Id, List<ConsentUIWrapper>>();
      contactPointPhoneToConsentMap = new Map<Id, List<ConsentUIWrapper>>();
      allConsents = new Map<String, String>();

      List<ContactPointConsent> cpConsentList = [
        SELECT
          Id,
          DataUsePurpose.Name,
          DataUsePurpose.Description,
          DataUsePurpose.Consent_Category__c,
          EffectiveTo,
          DataUsePurpose.Consent_Type__c,
          CreatedDate,
          PrivacyConsentStatus,
          CaptureContactPointType,
          ContactPoint.Name,
          ContactPointId,
          DataUsePurpose.Opt_In__c
        FROM ContactPointConsent
        WHERE ContactPointId = :contactPointIdSet AND EffectiveTo = NULL
        ORDER BY ContactPointId, DataUsePurpose.Consent_Category__c
      ];

      contactPointEmailToConsentMap = populateConsentMap(cpConsentList, 'ContactPointEmail');
      contactPointPhoneToConsentMap = populateConsentMap(cpConsentList, 'ContactPointPhone');
      checkForValidConsents();
    }
  }

  private static void populateCountryDefaultConsents() {
    if (!contactPointIdSet.isEmpty()) {
      String sObjectCountry = getsObjectCountry();
      if (sObjectCountry != null) {
        List<DataUsePurpose> dUPList = [
          SELECT Id, Name, Description, Consent_Category__c, Consent_Type__c, CreatedDate, Opt_In__c
          FROM DataUsePurpose
          WHERE Country_ies__c INCLUDES (:sObjectCountry) AND Default__c = TRUE AND Effective_To__c = NULL
          ORDER BY Consent_Category__c
        ];

        populateDefaultConsents(dUPList);
        checkForValidConsents();
      }
    }
  }

  private static void populateGlobalDefaultConsents() {
    if (!contactPointIdSet.isEmpty()) {
      List<DataUsePurpose> dUPList = [
        SELECT Id, Name, Description, Consent_Category__c, Consent_Type__c, CreatedDate, Opt_In__c
        FROM DataUsePurpose
        WHERE
          Country_ies__c = ''
          AND Default__c = TRUE
          AND Effective_To__c = NULL
          AND LegalBasis.Name = :Label.CEMCI_GlobalLegalBasisName
        ORDER BY Consent_Category__c
      ];

      populateDefaultConsents(dUPList);
    }
  }

  private static void populateDefaultConsents(List<DataUsePurpose> dUPList) {
    Map<String, List<DataUsePurpose>> cpTypetoDUPLMap = new Map<String, List<DataUsePurpose>>();
    for (DataUsePurpose dUP : dUPList) {
      if (!cpTypetoDUPLMap.containsKey(dUP.Consent_Type__c))
        cpTypetoDUPLMap.put(dUP.Consent_Type__c, new List<DataUsePurpose>{ dUP });
      else {
        List<DataUsePurpose> tempList = cpTypetoDUPLMap.get(dUP.Consent_Type__c);
        tempList.add(dUP);
        cpTypetoDUPLMap.put(dUP.Consent_Type__c, tempList);
      }
    }

    for (Id cpId : contactPointIdSet) {
      String objectType = String.valueOf(cpId.getSobjectType());
      if (objectType.contains('Email')) {
        populateDUPConsents(contactPointEmailToConsentMap, cpTypetoDUPLMap, 'Email', cpId);
      }

      if (objectType.contains('Phone')) {
        populateDUPConsents(contactPointPhoneToConsentMap, cpTypetoDUPLMap, 'Phone', cpId);
      }
    }
  }

  private static void populateContactPoints(Id individualId) {
    List<ContactPointEmail> cpEmailList = [
      SELECT Id, EmailAddress
      FROM ContactPointEmail
      WHERE ParentId = :individualId
      ORDER BY createdDate DESC
    ];
    List<ContactPointPhone> cpPhoneList = [
      SELECT Id, TelephoneNumber
      FROM ContactPointPhone
      WHERE ParentId = :individualId
      ORDER BY createdDate DESC
    ];

    if(!cpEmailList.isEmpty()){
      ContactPointEmail cpEmail = cpEmailList[0];
      contactPointIdSet.add(cpEmail.Id);
      contactPointIdToNameMap.put(cpEmail.Id, cpEmail.EmailAddress);
    }

    if(!cpPhoneList.isEmpty()){
      ContactPointPhone cpPhone = cpPhoneList[0];
      contactPointIdSet.add(cpPhone.Id);
      contactPointIdToNameMap.put(cpPhone.Id, cpPhone.TelephoneNumber);
    }
  }

  private static void checkForValidConsents() {
    Integer categoryCount = consentCategories != null ? consentCategories.size() : 0;
    for (Id cpId : contactPointEmailToConsentMap.keySet()) {
      if (contactPointEmailToConsentMap.get(cpId).size() == categoryCount)
        contactPointIdSet.remove(cpId);
    }
    for (Id cpId : contactPointPhoneToConsentMap.keySet()) {
      if (contactPointPhoneToConsentMap.get(cpId).size() == categoryCount - 1)
        contactPointIdSet.remove(cpId);
    }
  }

  private static String getsObjectCountry() {
    String objectType = String.valueOf(recordId.getSobjectType());
    String sObjectCountry;

    if (objectType == 'Lead')
      sObjectCountry = [SELECT Mailing_Country_Global__c FROM Lead WHERE Id = :recordId LIMIT 1]
      .Mailing_Country_Global__c;
    else if (objectType == 'Contact')
      sObjectCountry = [SELECT Mailing_Country__c FROM Contact WHERE Id = :recordId LIMIT 1].Mailing_Country__c;

    return sObjectCountry;
  }

  private static Map<Id, List<ConsentUIWrapper>> populateConsentMap(
    List<ContactPointConsent> cpConsentList,
    String sObjectType
  ) {
    Map<Id, List<ConsentUIWrapper>> contactPointToConsentMap = new Map<Id, List<ConsentUIWrapper>>();
    for (ContactPointConsent cpConsent : cpConsentList) {
      if (string.valueof(cpConsent.ContactPointId.getSObjectType()) == sObjectType) {
        if (!contactPointToConsentMap.containsKey(cpConsent.ContactPointId)) {
          ConsentUIWrapper uiInfo = populateConsentUIWrapper(
            cpConsent.ContactPoint.Name,
            cpConsent.Id,
            cpConsent.DataUsePurpose.Consent_Category__c,
            cpConsent.DataUsePurpose.Consent_Type__c,
            cpConsent.DataUsePurpose.Description,
            null,
            cpConsent.DataUsePurpose.Opt_In__c
          );
          contactPointToConsentMap.put(cpConsent.ContactPointId, new List<ConsentUIWrapper>{ uiInfo });
        } else {
          List<ConsentUIWrapper> tempList = contactPointToConsentMap.get(cpConsent.ContactPointId);
          tempList.add(
            populateConsentUIWrapper(
              cpConsent.ContactPoint.Name,
              cpConsent.Id,
              cpConsent.DataUsePurpose.Consent_Category__c,
              cpConsent.DataUsePurpose.Consent_Type__c,
              cpConsent.DataUsePurpose.Description,
              null,
              cpConsent.DataUsePurpose.Opt_In__c
            )
          );
          contactPointToConsentMap.put(cpConsent.ContactPointId, tempList);
        }
        String mapData =
          cpConsent.ContactPointId +
          cpConsent.DataUsePurpose.Consent_Category__c +
          cpConsent.DataUsePurpose.Consent_Type__c;
        allConsents.put(mapData, mapData);
      }
    }
    return contactPointToConsentMap;
  }

  private static void populateDUPConsents(
    Map<Id, List<ConsentUIWrapper>> contactPointToConsentMap,
    Map<String, List<DataUsePurpose>> cpTypetoDUPLMap,
    String consentCategory,
    Id cpId
  ) {
    List<ConsentUIWrapper> tempList = contactPointToConsentMap.get(cpId);

    if (cpTypetoDUPLMap.containsKey(consentCategory)) {
      if (tempList == null) {
        List<ConsentUIWrapper> consentList = new List<ConsentUIWrapper>();
        for (DataUsePurpose dUP : cpTypetoDUPLMap.get(consentCategory)) {
          ConsentUIWrapper uiInfo = populateConsentUIWrapper(
            contactPointIdToNameMap.get(cpId),
            null,
            dUP.Consent_Category__c,
            dUP.Consent_Type__c,
            dUP.Description,
            dUP.Id,
            dUP.Opt_In__c
          );
          consentList.add(uiInfo);
          String mapData = cpId + dUP.Consent_Category__c + dUP.Consent_Type__c;
          allConsents.put(mapData, mapData);
        }
        contactPointToConsentMap.put(cpId, consentList);
      } else {
        for (DataUsePurpose dUP : cpTypetoDUPLMap.get(consentCategory)) {
          if (!allConsents.containsKey(cpId + dUP.Consent_Category__c + dUP.Consent_Type__c)) {
            ConsentUIWrapper uiInfo = populateConsentUIWrapper(
              contactPointIdToNameMap.get(cpId),
              null,
              dUP.Consent_Category__c,
              dUP.Consent_Type__c,
              dUP.Description,
              dUP.Id,
              dUP.Opt_In__c
            );
            tempList.add(uiInfo);
            contactPointToConsentMap.put(cpId, tempList);
            String mapData = cpId + dUP.Consent_Category__c + dUP.Consent_Type__c;
            allConsents.put(mapData, mapData);
          }
        }
      }
    }
  }

  private static void populateResultList() {
    if (!contactPointEmailToConsentMap.isEmpty()) {
      resultList.addAll(populateResults('Email', 'utility:email', contactPointEmailToConsentMap));
    }
    if (!contactPointPhoneToConsentMap.isEmpty()) {
      resultList.addAll(populateResults('Phone', 'utility:call', contactPointPhoneToConsentMap));
    }
  }
  private static List<Map<String, Object>> populateResults(
    String consentCategory,
    String iconName,
    Map<Id, List<ConsentUIWrapper>> contactPointToConsentMap
  ) {
    List<Map<String, Object>> resultList = new List<Map<String, Object>>();
    Map<String, Object> consentMap = new Map<String, Object>();

    String cpTypeListDescription = ConsentCaptureService.getContactPointTypeDescription(consentCategory);
    consentMap.put('iconName', iconName);
    consentMap.put('type', consentCategory);
    consentMap.put('description', cpTypeListDescription);

    List<ConsentUIWrapper> consentList = new List<ConsentUIWrapper>();
    for (Id cpId : contactPointToConsentMap.keySet())
      consentList.addAll(contactPointToConsentMap.get(cpId));

    consentMap.put('data', consentList);
    resultList.add(consentMap);

    return resultList;
  }

  private static ConsentUIWrapper populateConsentUIWrapper(
    String cpName,
    Id cpId,
    String consentCategory,
    String consentType,
    String description,
    String dpId,
    String iconOption
  ) {
    ConsentUIWrapper uiInfo = new ConsentUIWrapper();
    uiInfo.contactPointName = cpName;
    uiInfo.consentId = cpId;
    uiInfo.consentCategory = consentCategory;
    uiInfo.consentType = consentType;
    uiInfo.dataUsePurposeDescription = description;
    uiInfo.dataUsePurposeId = dpId;
    uiInfo.consentIcon = iconOption;

    return uiInfo;
  }

  private class ConsentUIWrapper {
    @AuraEnabled
    public String contactPointName { get; set; }
    @AuraEnabled
    public String consentId { get; set; }
    @AuraEnabled
    public String consentCategory { get; set; }
    @AuraEnabled
    public String consentType { get; set; }
    @AuraEnabled
    public String dataUsePurposeDescription { get; set; }
    @AuraEnabled
    public String dataUsePurposeId { get; set; }
    @AuraEnabled
    public String consentIcon { get; set; }
  }
}