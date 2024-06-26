/**
 * @description       :
 * @author            : Urvish Shah (ushah)
 * @group             :
 * @last modified on  : 08-18-2022
 * @last modified by  : Urvish Shah (ushah)
 **/
public with sharing class CEMCI_Leads {
  public static List<Lead> newLeads;
  public static List<Lead> oldLeads;
  public static Map<Id, Lead> newLeadMap;
  public static Map<Id, Lead> oldLeadMap;
  public static Map<String, Lead> nonConvertedLeads = new Map<String, Lead>();
  public static Map<String, Lead> nonConvertedConfidentialLeads = new Map<String, Lead>();
  private static Boolean isEligible = false;
  public static Map<String, SObjectField> leadToContactFields;
  public static Map<String, SObjectField> leadCheckboxes;
  public static Boolean IsLinkedInUser = FeatureManagement.checkPermission('CEMCI_LinkedIn_Integration_User');
  public static CEMCI_Settings__c cs = CEMCI_Settings__c.getInstance();

  static {
    String leadToContactFieldSetName = 'CEMCILeadToContactMapping';
    String leadCheckboxesFieldSetName = 'CEMCILeadCheckboxes';
    Schema.FieldSet leadToContactFieldSet = Schema.SObjectType.Contact.fieldSets.getMap()
      .get(leadToContactFieldSetName);
    Schema.FieldSet leadCheckboxesFieldSet = Schema.SObjectType.Lead.fieldSets.getMap().get(leadCheckboxesFieldSetName);
    leadToContactFields = WDR_Util.getFieldMap(leadToContactFieldSet);
    leadCheckboxes = WDR_Util.getFieldMap(leadCheckboxesFieldSet);
  }

  //*****************************************************************************
  // Method to set IsValid LinkedIn URL Field
  //****************************************************************************/

  public static void setIsValidLinkedInURL() {
    String linkedInURL = System.Label.CEMCI_Valid_LinkedIn_URL;
    if (!String.isBlank(linkedInURL)) {
      for (Lead l : newLeads) {
        l.IsValid_LinkedIn_URL__c = false;
        if (l.Linked_In_URL__c != null) {
          String inputURL = l.Linked_In_URL__c;

          Pattern linkedInURLPattern = Pattern.compile(linkedInURL);

          Matcher inputURLMatcher = linkedInURLPattern.matcher(inputURL);

          l.IsValid_LinkedIn_URL__c = inputURLMatcher.matches();
        }
      }
    }
  }

  public static void updateDisqualifiedLeads() {
    for (Lead ld : newLeads) {
      if (ld.Do_Not_Hire__c) {
        ld.Status = 'Disqualified';
        ld.Qualification_Details__c = 'Workday Do Not Hire';
      }
    }
  }

  public static void setOriginalLeadSource() {
    for (Lead l : newLeads) {
      if (l.LeadSource != null && l.Original_Lead_Source__c == null)
        l.Original_Lead_Source__c = l.LeadSource;
    }
  }

  public static void setConfidentialTextField() {
    for (Lead ld : newLeads) {
      ld.Confidential_Text__c = String.valueOf(ld.Confidential__c);
    }
  }

  public static void setLinkedInSubstring() {
    String linkedInURL = System.Label.CEMCI_Valid_LinkedIn_URL;

    for (Lead ld : newLeads) {
      if (ld.Linked_In_URL__c != null) {
        ld.LinkedIn_Substring__c = CEMCI_Util.generateLinkedInSubstring(ld.Linked_In_URL__c);
      }
    }
  }

  public static void createIndividualRecordsforLeads() {
    if (!CEMCI_CheckGDPRRecursion.getExecutionVariable()) {
      List<Lead> leadsForProcessing = new List<Lead>();
      List<Lead> leadsForCreatingIndividual = new List<Lead>();

      leadsForProcessing = isValidForGDPRProcessing();
      for (integer i = 0; i < leadsForProcessing.size(); i++) {
        if (leadsForProcessing[i].IndividualId == null)
          leadsForCreatingIndividual.add(leadsForProcessing[i]);
      }
      if (leadsForCreatingIndividual.size() > 0) {
        newLeads = CEMCI_GDPR_DispatcherClass.createIndividualRecordsForsObject(leadsForCreatingIndividual, 'Lead');
      }
    }
  }

  public static void createContactPointRecordsforLeads() {
    if (!CEMCI_CheckGDPRRecursion.getExecutionVariable()) {
      List<Lead> leadsForProcessing = new List<Lead>();
      List<Lead> leadsForConsentProcessing = new List<Lead>();
      List<Lead> leadsForCreatingContactPoint = new List<Lead>();

      leadsForProcessing = isValidForGDPRProcessing();
      leadsForConsentProcessing = isValidForSourceSpecficConsentProcessing();

      for (integer i = 0; i < leadsForProcessing.size(); i++) {
        if (leadsForProcessing[i].IndividualId != null)
          leadsForCreatingContactPoint.add(leadsForProcessing[i]);
      }

      if (leadsForCreatingContactPoint.size() > 0) {
        CEMCI_GDPR_DispatcherClass.createContactPointRecordsForsObject(leadsForCreatingContactPoint);
      }

      if (leadsForConsentProcessing != null && leadsForConsentProcessing.size() > 0) {
        CEMCI_GDPR_DispatcherClass.createSourceSpecificConsentRecordsForsObject(leadsForConsentProcessing, 'Lead');
      }
    }
  }

  public static List<Lead> isValidForGDPRProcessing() {
    List<Lead> leadsForProcessing = new List<Lead>();
    for (Lead ldRec : newLeads) {
      if (
        (!ldRec.isConverted && (ldRec.Phone != null || ldRec.Email != null)) ||
        (ldRec.Phone != null &&
        oldLeadMap != null &&
        oldLeadMap.get(ldRec.Id).Phone != ldRec.Phone) ||
        (ldRec.Email != null &&
        oldLeadMap != null &&
        oldLeadMap.get(ldRec.Id).Email != ldRec.Email)
      )
        leadsForProcessing.add(ldRec);
    }

    return leadsForProcessing;
  }

  public static List<Lead> isValidForSourceSpecficConsentProcessing() {
    List<Lead> leadsForConsentProcessing = new List<Lead>();

    for (Lead ldRec : newLeads) {
      if (
        ldRec.IndividualId != null &&
        ((oldLeadMap == null &&
        ldRec.LeadSource != null &&
        ldRec.Mailing_Country_Global__c != null) ||
        (oldLeadMap != null &&
        ldRec.LeadSource != null &&
        oldLeadMap.get(ldRec.Id).LeadSource != ldRec.LeadSource) ||
        (oldLeadMap != null &&
        ldRec.Mailing_Country_Global__c != null &&
        oldLeadMap.get(ldRec.Id).Mailing_Country_Global__c != ldRec.Mailing_Country_Global__c))
      )
        leadsForConsentProcessing.add(ldRec);
    }

    return leadsForConsentProcessing;
  }

  public static void mergeGDPRRecordsforLeads() {
    if (!CEMCI_CheckGDPRRecursion.getMergeRecordRunonce()) {
      List<Lead> leadsForProcessing = new List<Lead>();

      //when record is merged MasterRecordId field on Lead gets populated with Lead identified as master
      for (Lead ldRec : oldLeads) {
        if (ldRec.MasterRecordId != null) {
          leadsForProcessing.add(ldRec);
        } else if (newLeadMap != null && (ldRec.IsConverted == false && newLeadMap.get(ldRec.Id).IsConverted == true)) {
          leadsForProcessing.add(newLeadMap.get(ldRec.Id));
        }
      }

      if (leadsForProcessing.size() > 0)
        CEMCI_GDPR_DispatcherClass.mergeGDPRRecordsForSObject(leadsForProcessing);
    }
  }

  public static void updateDisqualifiedLeadsConvertedContacts() {
    Set<String> disqualifiedLeadEmailSet = new Set<String>();
    List<Contact> contactListToUpdate = new List<Contact>();
    for (Lead ld : newLeads) {
      if (ld.Do_Not_Hire__c && ld.IsConverted && ld.Email != null) {
        disqualifiedLeadEmailSet.add(ld.Email);
      }
    }
    for (Contact cntct : [SELECT Id, Do_Not_Hire__c FROM Contact WHERE email IN :disqualifiedLeadEmailSet]) {
      if (!cntct.Do_Not_Hire__c) {
        cntct.Do_Not_Hire__c = true;
        contactListToUpdate.add(cntct);
      }
    }

    if (contactListToUpdate.size() > 0) {
      Boolean contactFieldsAccessible = PF_AccessibilityUtils.checkFLS(
        'Contact',
        PF_AccessibilityUtils.PermissionType.UPDATEABLE,
        new List<string>{ 'Do_Not_Hire__c' }
      );
      if (contactFieldsAccessible) {
        Database.SaveResult[] srList = Database.update(contactListToUpdate, false);
        for (Database.SaveResult sr : srList) {
          if (!sr.isSuccess()) {
            for (Database.Error err : sr.getErrors()) {
              PF_Logger.log(
                'CEMCI',
                'ERROR',
                err.getMessage(),
                '' + err.getFields(),
                'Error during updating disqualified Leads converted Contacts',
                'CEMCI_Leads'
              );
            }
          }
        }
      } else {
        PF_Logger.log(
          'CEMCI',
          'ERROR',
          'User does not have sufficient access on Contact fields',
          '',
          ' Error during updateDisqualifiedLeadsConvertedContacts ' + UserInfo.getUserId(),
          ''
        );
      }

      if (PF_Logger.logs.size() > 0)
        PF_Logger.createLogs(PF_Logger.logs);
    }
  }

  public static void mergeToContactsAndLeads() {
    if (isEligible) {
      CEMCI_DuplicateService dupeService = new CEMCI_DuplicateService(newLeads, 'Email');
      dupeService.findDuplicates();
    }
  }

  public static void isEligibleForDupeService() {
    if (!System.isBatch()) {
      if (newLeads.size() == 1)
        isEligible = true;
      else if (!cs.Bypass_Lead_Dedupe__c) {
        //Custom setting on CEMCI Settings. If true we do not mark leads in bulk creates/updates for awaiting de dupe.
        for (Lead ldRec : newLeads)
          ldRec.Awaiting_Lead_De_duplication__c = true;
      }
    }
  }

  public static void assignConvertedLeadValuesToContact(Database.LeadConvertResult[] convertedRecords) {
    List<Id> convertedLeadIds = getConvertedLeadsIds(convertedRecords);

    List<Lead> convertedLeadsAndContacts = getConvertedLeadsAndContacts(convertedLeadIds);

    List<Contact> convertedContacts = assignConvertedLeadValues(convertedLeadsAndContacts);

    Database.SaveResult[] convertedContactsResult = Database.update(convertedContacts, false);

    checkForErrors(convertedContactsResult);
  }

  private static void checkForErrors(Database.SaveResult[] convertedContactsResult) {
    for (Database.SaveResult convertedRecord : convertedContactsResult) {
      if (!convertedRecord.isSuccess()) {
        for (Database.Error err : convertedRecord.getErrors()) {
          PF_Logger.log(
            'CEMCI',
            'ERROR',
            err.getMessage(),
            '',
            'Error during auto-merge leads to contact on these checkbox fields ' + err.getFields(),
            'CEMCI_Leads'
          );
        }
      }
    }
  }

  @TestVisible
  private static List<Contact> assignConvertedLeadValues(List<Lead> convertedLeads) {
    List<String> leadToContactMappingFieldNames = new List<String>(leadToContactFields.keySet());

    Map<Id, Contact> convertedContactsMap = new Map<Id, Contact>();
    Map<Id, Id> mapConvertedLeadToContact = new Map<Id, Id>();

    for (Lead convertedLead : convertedLeads) {
      Contact convertedContact = new Contact(Id = convertedLead.ConvertedContactId, Converted_from_Lead__c = true);
      // W-9492332 - Automates carrying the lead owner over after conversion to the contact.
      Id ownerId = CEMCI_Util.setLeadOwnerValidforContactOwner(convertedLead.OwnerId);
      if (ownerId != null) {
        convertedContact.OwnerId = ownerId;
      }
      for (String fieldName : leadToContactMappingFieldNames) {
        if (leadCheckboxes.get(fieldName) != null && leadToContactFields.get(fieldName) != null) {
          if ((Boolean) convertedLead.get(fieldName)) {
            convertedContact.put(fieldName, (Boolean) convertedLead.get(fieldName));
          }
        }
      }
      convertedContactsMap.put(convertedContact.Id, convertedContact);
      mapConvertedLeadToContact.put(convertedLead.Id, convertedContact.Id);
    }
    createTagsForContactsFromConvetredLeads(mapConvertedLeadToContact);
    return convertedContactsMap.values();
  }

  public static void createTagsForContactsFromConvetredLeads(Map<Id, Id> mapConvertedLeadToContact) {
    List<Id> listConvertedLeadIds = new List<Id>(mapConvertedLeadToContact.keySet());
    Map<Id, Set<String>> mapConvertedLeadToExistingTags = CEMCI_TagsService.getTagAssignmentsMap(
      listConvertedLeadIds,
      'Lead'
    );
    Map<Id, Set<String>> mapConvertedContactToExistingTags = CEMCI_TagsService.getTagAssignmentsMap(
      mapConvertedLeadToContact.values(),
      'Contact'
    );
    Map<Id, Set<String>> mapContactToNewTags = new Map<Id, Set<String>>();

    for (Id leadId : mapConvertedLeadToContact.keySet()) {
      //if lead doesn't have any tags skip
      if (!mapConvertedLeadToExistingTags.containsKey(leadId)) {
        continue;
      }
      if (!mapConvertedContactToExistingTags.containsKey(mapConvertedLeadToContact.get(leadId))) {
        mapContactToNewTags.put(
          mapConvertedLeadToContact.get(leadId),
          new Set<String>(mapConvertedLeadToExistingTags.get(leadId))
        );
      } else {
        for (Id tagId : mapConvertedLeadToExistingTags.get(leadId)) {
          if (!mapConvertedContactToExistingTags.get(mapConvertedLeadToContact.get(leadId)).contains(tagId)) {
            if (!mapContactToNewTags.containsKey(mapConvertedLeadToContact.get(leadId))) {
              mapContactToNewTags.put(mapConvertedLeadToContact.get(leadId), new Set<String>{});
            }
            mapContactToNewTags.get(mapConvertedLeadToContact.get(leadId)).add(tagId);
          }
        }
      }
    }
    CEMCI_TopicsController.createTagAssignments(mapContactToNewTags);
  }

  @TestVisible
  private static List<Lead> getConvertedLeadsAndContacts(List<Id> convertedLeadIds) {
    String query = 'SELECT ';
    String leadQueryFields = 'Id' + getQueryCheckboxFields(leadCheckboxes, '');
    String contactQueryFields =
      ', ConvertedContactId, OwnerId' + getQueryCheckboxFields(leadCheckboxes, 'ConvertedContact.');
    query += leadQueryFields + contactQueryFields + ' FROM Lead WHERE Id IN :convertedLeadIds';
    List<Lead> convertedLeadsAndContacts = Database.query(String.escapeSingleQuotes(query));
    return convertedLeadsAndContacts;
  }
  @TestVisible
  private static List<Id> getConvertedLeadsIds(Database.LeadConvertResult[] convertedRecords) {
    List<Id> convertedLeadIds = new List<Id>();
    for (Database.LeadConvertResult record : convertedRecords) {
      if (record.isSuccess()) {
        convertedLeadIds.add(record.getLeadId());
      }
    }
    return convertedLeadIds;
  }

  @TestVisible
  private static String getQueryCheckboxFields(Map<String, SObjectField> checkboxFieldsMap, String prefix) {
    String queryFields = '';
    List<String> leadToContactMappingFieldNames = new List<String>(leadToContactFields.keySet());
    for (String fieldName : leadToContactMappingFieldNames) {
      if (checkboxFieldsMap.get(fieldName) != null) {
        queryFields += ', ' + prefix + fieldName;
      }
    }
    return queryFields;
  }

  // For linkedin Integration
  public static void createCampaignMemberforLinkedIn() {
    if (IsLinkedInUser) {
      List<campaignMember> upsertCampaignMem = new List<campaignMember>();
      Map<Id, String> mapOfLeadIdLeadCampIDString = new Map<Id, String>();
      Map<String, List<campaignMember>> mapOfLeadIdCampIdCampMemList = new Map<String, List<campaignMember>>();
      for (Lead leadRec : newLeads) {
        mapOfLeadIdLeadCampIDString.put(leadRec.id, leadRec.id + '' + leadRec.LinkedIn_Hidden_Field_Value_1__c);
      }

      List<campaignMember> listOfCampaignMember = [
        SELECT id, CampaignId, LeadId, Marketing_Opt_In__c, Member_Responded_Datetime__c, Recruiting_Opt_In__c, Status
        FROM campaignMember
        WHERE Lead_Campaign_Id__c IN :mapOfLeadIdLeadCampIDString.values()
      ];

      for (campaignMember campMem : listOfCampaignMember) {
        List<campaignMember> listOfCampMem = new List<campaignMember>();
        if (mapOfLeadIdCampIdCampMemList.containsKey(campMem.Lead_Campaign_Id__c)) {
          listOfCampMem = mapOfLeadIdCampIdCampMemList.get(campMem.Lead_Campaign_Id__c);
        }
        listOfCampMem.add(campMem);
        mapOfLeadIdCampIdCampMemList.put(campMem.Lead_Campaign_Id__c, listOfCampMem);
      }

      for (Lead leadRec : newLeads) {
        Id leadId = leadRec.Id;
        Id campaignId = leadRec.LinkedIn_Hidden_Field_Value_1__c;
        String leadIdCampId = leadId + '' + campaignId;
        if (!mapOfLeadIdCampIdCampMemList.containsKey(leadIdCampId)) {
          campaignMember campMem = new campaignMember();
          campMem.CampaignId = leadRec.LinkedIn_Hidden_Field_Value_1__c;
          campMem.LeadId = leadRec.Id;
          campMem.Marketing_Opt_In__c = leadRec.Marketing_Opt_In__c;
          campMem.Member_Responded_Datetime__c = leadRec.Last_Interaction_Date__c;
          campMem.Recruiting_Opt_In__c = leadRec.Recruiting_Opt_In__c;
          campMem.Status = 'Responded';
          upsertCampaignMem.add(campMem);
        } else {
          for (CampaignMember CampM : mapOfLeadIdCampIdCampMemList.get(leadIdCampId)) {
            CampM.Marketing_Opt_In__c = leadRec.Marketing_Opt_In__c;
            CampM.Member_Responded_Datetime__c = leadRec.Last_Interaction_Date__c;
            CampM.Recruiting_Opt_In__c = leadRec.Recruiting_Opt_In__c;
            upsertCampaignMem.add(CampM);
          }
        }
      }
      upsert upsertCampaignMem;
    }
  }

  public static void mapLinkedinCountryToSfCountry() {
    if (IsLinkedInUser) {
      Boolean matchFound = false;
      Map<String, String> countryMappingMap = new Map<String, String>();

      List<CEMCI_Linkedin_Country_Mapping__mdt> countryMappingMdt = [
        SELECT DeveloperName, Linkedin_Country_Values__c
        FROM CEMCI_Linkedin_Country_Mapping__mdt
      ];
      for (CEMCI_Linkedin_Country_Mapping__mdt countryMapping : countryMappingMdt) {
        String countryValues = countryMapping.Linkedin_Country_Values__c.remove('"');
        for (String value : countryValues.split(','))
          countryMappingMap.put(value, countryMapping.DeveloperName);
      }
      for (Lead ld : newLeads) {
        if (countryMappingMap.containsKey(ld.Mailing_Country__c))
          ld.Mailing_Country_Global__c = countryMappingMap.get(ld.Mailing_Country__c);
        else
          ld.Mailing_Country_Global__c = 'XX';
      }
    }
  }

  public static void updateOwnerIfRMMorSysAdmin() {
    for (Lead l : newLeads) {
      l.OwnerId = CEMCI_Util.setValidLeadOwner(l.OwnerId, l.confidential__c);
    }
  }

  public static void updateCampaignMembers() {
    List<CampaignMember> campaignMembers = [
      SELECT id, LeadId, CampaignId
      FROM CampaignMember
      WHERE LeadId IN :newLeadMap.keySet()
    ];
    for (CampaignMember c : campaignMembers) {
      c.Lead_Campaign_Id__c = c.LeadId + '' + c.CampaignId;
    }
    update campaignMembers;
  }

  public static void updateAddressFields() {
    List<Schema.PicklistEntry> lstCountryValues = Lead.Mailing_Country_Global__c.getDescribe().getPickListValues();

    for (Lead l : newLeads) {
      if (l.street == null && l.Mailing_Street__c != null) {
        l.street = l.Mailing_Street__c;
      }
      if (l.city == null && l.Mailing_City__c != null) {
        l.city = l.Mailing_City__c;
      }
      if (l.state == null && l.Mailing_State_Province__c != null) {
        l.state = l.Mailing_State_Province__c;
      }
      if (l.PostalCode == null && l.Mailing_Zip_Postal_Code__c != null) {
        l.PostalCode = l.Mailing_Zip_Postal_Code__c;
      }
      if (l.country == null && l.Mailing_Country_Global__c != null) {
        for (Schema.PicklistEntry p : lstCountryValues) {
          if (p.getValue() == l.Mailing_Country_Global__c)
            l.country = p.getLabel();
        }
      }

      if (l.street != null && l.Mailing_Street__c == null) {
        l.Mailing_Street__c = l.street;
      }
      if (l.city != null && l.Mailing_City__c == null) {
        l.Mailing_City__c = l.city;
      }
      if (l.state != null && l.Mailing_State_Province__c == null) {
        l.Mailing_State_Province__c = l.state;
      }
      if (l.PostalCode != null && l.Mailing_Zip_Postal_Code__c == null) {
        l.Mailing_Zip_Postal_Code__c = l.PostalCode;
      }
      if (l.country != null && l.Mailing_Country_Global__c == null) {
        for (Schema.PicklistEntry p : lstCountryValues) {
          if (p.getLabel() == l.country)
            l.Mailing_Country_Global__c = p.getValue();
        }
      }
    }
  }

  public static void expireLeadConsentForOldEmailPhone() {
    List<String> emailPhoneListToExpireConsent = new List<String>();
    // List<String> phoneListToExpireConsent= new List<String>();

    for (Id leadId : newLeadMap.keySet()) {
      if (newLeadMap.get(leadId).Email != oldLeadMap.get(leadId).Email)
        emailPhoneListToExpireConsent.add(oldLeadMap.get(leadId).Email);

      if (newLeadMap.get(leadId).Phone != oldLeadMap.get(leadId).Phone)
        emailPhoneListToExpireConsent.add(oldLeadMap.get(leadId).Phone);
    }

    if ((emailPhoneListToExpireConsent != null && !emailPhoneListToExpireConsent.isEmpty())) {
      CEMCI_Util.expireConsentsForOldEmailPhone(emailPhoneListToExpireConsent);
    }
  }
}