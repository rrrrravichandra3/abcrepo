/**
 * @description       :
 * @author            : Urvish Shah (ushah)
 * @group             :
 * @last modified on  : 08-26-2022
 * @last modified by  : Urvish Shah (ushah)
 **/
public with sharing class WDRCandidate_To_Contact_BatchHandler {
  public String candidateType;
  public Map<String, WDR_Candidate__c> updateCandidateMap = new Map<String, WDR_Candidate__c>();
  static final List<Field_Mapping__mdt> fieldMappingList;
  static final Id cntctRecTypeId = [
    SELECT Id
    FROM RecordType
    WHERE sobjecttype = 'Contact' AND developername = 'WDR_Candidate'
  ]
  .Id;
  private Set<String> linkedInSubstrings = new Set<String>();

  public static List<Field_Mapping__mdt> populatefieldMappingList() {
    return [
      SELECT
        From_Field__c,
        From_Object__c,
        To_Field__c,
        To_Object__c,
        Is_Active__c,
        Mapping_Category__c,
        To_Length_Limit__c
      FROM Field_Mapping__mdt
      WHERE
        From_Object__c = :Schema.SObjectType.WDR_Candidate__c.getName()
        AND To_Object__c = :Schema.SObjectType.Contact.getName()
        AND Mapping_Category__c = 'CEMCI'
        AND Is_Active__c = TRUE
    ];
  }

  static {
    fieldMappingList = populatefieldMappingList();
  }

  public void processBatchRecords(List<sObject> WDCandidates) {
    Map<String, WDR_Candidate__c> nonConfidentialCandidateMap = new Map<String, WDR_Candidate__c>();
    Map<String, WDR_Candidate__c> confidentialCandidateMap = new Map<String, WDR_Candidate__c>();
    String linkedInURL = System.Label.CEMCI_Valid_LinkedIn_URL;

    for (sObject sObj : WDCandidates) {
      WDR_Candidate__c cand = (WDR_Candidate__c) sObj;
      if (cand.Email__c != null) {
        if (cand.Confidential__c)
          confidentialCandidateMap.put(cand.Email__c, cand);
        else
          nonConfidentialCandidateMap.put(cand.Email__c, cand);
      }
      if (cand.LinkedIn_URL__c != null) {
        String substring = CEMCI_Util.generateLinkedInSubstring(cand.LinkedIn_URL__c);
        if (substring != null) {
          linkedInSubstrings.add(substring);
        }
      }
    }

    //Process non-confidential Candidates
    if (!nonConfidentialCandidateMap.isEmpty())
      processRecords(nonConfidentialCandidateMap, false);

    //Process confidential Candidates
    if (!confidentialCandidateMap.isEmpty())
      processRecords(confidentialCandidateMap, true);
  }

  public void processRecords(Map<String, WDR_Candidate__c> emailToWDCandidateMap, Boolean confidential) {
    Map<String, Contact> ContactEmailtoIdMap = new Map<String, Contact>();
    List<WDR_Candidate__c> wdCandList = emailToWDCandidateMap.values();

    ContactEmailtoIdMap = wdCandidateToContactUpdate(emailToWDCandidateMap, confidential);

    createContactsforWDCandidates(ContactEmailtoIdMap, emailToWDCandidateMap, 'Contact');

    linkContactstoWDCandidates(ContactEmailtoIdMap, candidateType, confidential);

    //commenting this method call to avoid creation of additional phone consent getting created
    //createContactPointPhone(ContactEmailtoIdMap,wdCandList);

    convertLeads(ContactEmailtoIdMap, confidential);

    updateCandidates(updateCandidateMap.values());
  }
  public Map<String, Contact> wdCandidateToContactUpdate(
    Map<String, WDR_Candidate__c> emailToWDCandidateMap,
    Boolean confidential
  ) {
    List<Contact> contactsToUpdate = new List<Contact>();
    Set<String> wdcEmails = emailToWDCandidateMap.keyset();
    Map<Id, WDR_Candidate__c> contactIdTolinkedCandidateMap = new Map<Id, WDR_Candidate__c>();
    List<Contact> contactList = new List<Contact>();
    Map<String, Contact> ContactEmailtoIdMap = new Map<String, Contact>();
    Map<Id, String> contactIdtoCandidateIdMap = new Map<Id, String>();

    for (WDR_Candidate__c cand : emailToWDCandidateMap.values()) {
      if (cand.Candidate_Contact__c != null) {
        contactIdTolinkedCandidateMap.put(cand.Candidate_Contact__c, cand);
        wdcEmails.remove(cand.Email__c); // unnecessary
      }
    }

    Set<Id> linkedContactsIdSet = contactIdTolinkedCandidateMap.keyset();

    String query = 'Select Id, accountId, LinkedIn_Substring__c';
    for (Field_Mapping__mdt mapping : fieldMappingList) {
      query += ' ,' + mapping.To_Field__c;
    }
    if (!linkedContactsIdSet.isEmpty()) {
      String query1 = query + ' from Contact where id IN :linkedContactsIdSet';
      contactList = Database.query(query1);
    }
    for (Contact c : contactList)
      wdcEmails.remove(c.Email);

    if (!wdcEmails.isEmpty()) {
      query =
        query +
        ' from Contact where email IN :wdcEmails and Confidential__c =:confidential and recordtypeid =:cntctRecTypeId';
      List<Contact> tempCntctList = Database.query(query);
      contactList.addAll(tempCntctList);
    }

    for (Contact cntct : contactList) {
      Boolean isUpdatedContact = false;
      WDR_Candidate__c cand = contactIdTolinkedCandidateMap.keyset().contains(cntct.id)
        ? contactIdTolinkedCandidateMap.get(cntct.id)
        : emailToWDCandidateMap.get(cntct.email);

      //Process updates if Candidate is already linked to a Contact or if Candidate doesn't have Contact created
      if (
        (cand != null && cand.Candidate_Contact__c != null && cand.Candidate_Contact__c == cntct.Id) ||
        (cand != null &&
        cand.Candidate_Contact__c == null)
      ) {
        for (Field_Mapping__mdt mapping : fieldMappingList) {
          Object data = cand.get(mapping.From_Field__c);
          if ((cntct.get(mapping.To_Field__c) == null || cntct.get(mapping.To_Field__c) == false) && data != null) {
            //Truncate if value longer than CRM field length
            if (mapping.To_Length_Limit__c != null && data != null) {
              String dataValue = String.valueOf(data);
              dataValue = dataValue.length() > mapping.To_Length_Limit__c
                ? dataValue.left(Integer.valueOf(mapping.To_Length_Limit__c))
                : dataValue;
              data = dataValue;
            }
            cntct.put(mapping.To_Field__c, data);
            isUpdatedContact = true;
            contactIdtoCandidateIdMap.put(cntct.Id, String.valueOf(cand.get('Id')));
          }
        }
      }
      if (isUpdatedContact == true)
        contactsToUpdate.add(cntct);

      ContactEmailtoIdMap.put(cntct.email, cntct);
    }
    if (contactsToUpdate.size() > 0) {
      Database.SaveResult[] srList = Database.update(contactsToUpdate, false);

      for (Integer i = 0; i < contactsToUpdate.size(); i++) {
        Database.SaveResult sr = srList[i];
        if (!sr.isSuccess()) {
          for (Database.Error err : sr.getErrors()) {
            PF_Logger.log(
              'CEMCI',
              'ERROR',
              err.getMessage(),
              '' + err.getFields(),
              'Error updating existing Contacts from WD Candidates',
              'WDR Candidate to Contact Batch'
            );
          }
        } else {
          WDR_Candidate__c updateCand = new WDR_Candidate__c();
          Boolean areFieldsAccessible = PF_AccessibilityUtils.checkFLS(
            'WDR_Candidate__c',
            PF_AccessibilityUtils.PermissionType.UPDATEABLE,
            new List<string>{ 'Candidate_Contact__c', 'Ready_to_Process__c' }
          );
          if (areFieldsAccessible) {
            updateCand.Id = contactIdtoCandidateIdMap.get(sr.getId());
            updateCand.Candidate_Contact__c = sr.getId();
            updateCand.Ready_to_Process__c = false;

            if (!updateCandidateMap.containsKey(contactsToUpdate[i].email)) {
              updateCandidateMap.put(contactsToUpdate[i].email, updateCand);
            }
            if (!updateCandidateMap.containsKey(contactsToUpdate[i].LinkedIn_Substring__c)) {
              updateCandidateMap.put(contactsToUpdate[i].LinkedIn_Substring__c, updateCand);
            }
          } else {
            PF_Logger.log(
              'CEMCI',
              'ERROR',
              'User does not have sufficient access on Candidate fields',
              '',
              ' Error during Candidate to Contact update ' + UserInfo.getUserId(),
              ''
            );
          }
        }
      }

      if (PF_Logger.logs.size() > 0)
        PF_Logger.createLogs(PF_Logger.logs);
    }

    return ContactEmailtoIdMap;
  }

  public void createContactsforWDCandidates(
    Map<String, Contact> ContactEmailtoIdMap,
    Map<String, WDR_Candidate__c> emailToWDCandidateMap,
    String typeName
  ) {
    List<Contact> contacts = new List<Contact>();
    Map<Id, Id> candidateToAccountMap = new Map<Id, Id>();
    Set<Id> candidateIds = new Set<Id>();

    for (WDR_Candidate__c candidate : emailToWDCandidateMap.values())
      candidateIds.add(candidate.Id);

    WDR_Util handleRecords = new WDR_Util();
    candidateToAccountMap = handleRecords.populateAccountonContact(emailToWDCandidateMap.values());

    Boolean areFieldsAccessible = PF_AccessibilityUtils.checkFLS(
      'Contact',
      PF_AccessibilityUtils.PermissionType.CREATEABLE,
      new List<string>{ 'LeadSource', 'accountId' }
    );
    Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
    String defaultLeadSource = System.Label.CEMCI_Lead_Source_Label;
    String mailingCountryField = System.Label.CEMCI_Mailing_Country_Field_Name_Label;

    for (WDR_Candidate__c candidate : emailToWDCandidateMap.values()) {
      if (
        typeName == 'Contact' &&
        !ContactEmailtoIdMap.keyset().contains(candidate.email__c) &&
        candidate.Candidate_Contact__c == null
      ) {
        Schema.DescribeFieldResult dfrCName = Contact.LastName.getDescribe();

        if (areFieldsAccessible) {
          Contact cntct = (Contact) targetType.newSObject();
          cntct.RecordTypeId = cntctRecTypeId;
          cntct.accountId = candidateToAccountMap.get(candidate.Id);

          for (Field_Mapping__mdt mapping : fieldMappingList) {
            if (mapping.From_Field__c == mailingCountryField && candidate.get(mapping.From_Field__c) == null) {
              continue;
            } else {
              Object data = candidate.get(mapping.From_Field__c);
              //Truncate if value longer than CRM field length
              if (mapping.To_Length_Limit__c != null && data != null) {
                String dataValue = String.valueOf(data);
                dataValue = dataValue.length() > mapping.To_Length_Limit__c
                  ? dataValue.left(Integer.valueOf(mapping.To_Length_Limit__c))
                  : dataValue;
                data = dataValue;
              }
              cntct.put(mapping.To_Field__c, data);
            }
          }

          cntct.LeadSource = defaultLeadSource;
          contacts.add(cntct);
        } else {
          PF_Logger.log(
            'CEMCI',
            'ERROR',
            'User does not have sufficient access on Contact fields',
            '',
            ' Error during Contact creation from WD Candidate ' + UserInfo.getUserId(),
            ''
          );
        }
        if (!PF_Logger.logs.isEmpty()) {
          PF_Logger.createLogs(PF_Logger.logs);
        }
      }
    }

    if (contacts.size() > 0) {
      CEMCI_CheckGDPRRecursion.setdoNotRunGDPRFlow();
      CEMCI_Contacts.newContacts = contacts;
      CEMCI_Contacts.setLinkedInSubstring();
      CEMCI_Contacts.createIndividualforContacts();
      contacts = CEMCI_Contacts.newContacts;
      Database.SaveResult[] srList = Database.insert(contacts, false);
      for (Integer i = 0; i < srList.size(); i++) {
        if (srList[i].isSuccess()) {
          ContactEmailtoIdMap.put(contacts.get(i).email, contacts.get(i));
        } else {
          for (Database.Error err : srList[i].getErrors()) {
            PF_Logger.log(
              'CEMCI',
              'ERROR',
              err.getMessage(),
              '' + err.getFields(),
              'Error during creating new Contacts',
              'WDR Candidate to Contact Batch'
            );
          }
        }
      }
      CEMCI_Contacts.newContacts = contacts;
      CEMCI_Contacts.createContactPointRecordsforContacts();
      if (PF_Logger.logs.size() > 0)
        PF_Logger.createLogs(PF_Logger.logs);
    }
  }
  public void createContactPointPhone(Map<String, Contact> ContactEmailtoIdMap, List<WDR_Candidate__c> wdCandList) {
    Map<Id, Set<String>> individualToPhoneMap = new Map<Id, Set<String>>();
    Map<String, Set<String>> emailToWDCandidatePhoneMap = new Map<String, Set<String>>();
    List<Id> IdList = new List<Id>();
    List<ContactPointPhone> cpPhoneRecordsToInsert = new List<ContactPointPhone>();
    List<Contact> contactsWithIndividual = [
      SELECT Id, email, phone, individualId
      FROM Contact
      WHERE individualId != NULL AND email IN :ContactEmailtoIdMap.keyset()
    ];

    for (Contact cntct : contactsWithIndividual) {
      IdList.add(cntct.individualId);
    }
    List<ContactPointPhone> cpPhoneList = [
      SELECT Id, ParentId, TelephoneNumber
      FROM ContactPointPhone
      WHERE ParentId IN :IdList
    ];
    for (ContactPointPhone cpPhone : cpPhoneList) {
      if (!individualToPhoneMap.containsKey(cpPhone.ParentId))
        individualToPhoneMap.put(cpPhone.ParentId, new Set<String>{ cpPhone.TelephoneNumber });
      else {
        Set<String> tempSet = individualToPhoneMap.get(cpPhone.ParentId);
        tempSet.add(cpPhone.TelephoneNumber);
        individualToPhoneMap.put(cpPhone.ParentId, tempSet);
      }
    }

    for (WDR_Candidate__c wdCand : wdCandList) {
      if (!emailToWDCandidatePhoneMap.containsKey(wdCand.email__c))
        emailToWDCandidatePhoneMap.put(wdCand.email__c, new Set<String>{ wdCand.phone__c });
      else {
        Set<String> tempSet = emailToWDCandidatePhoneMap.get(wdCand.email__c);
        tempSet.add(wdCand.phone__c);
        emailToWDCandidatePhoneMap.put(wdCand.email__c, tempSet);
      }
    }
    for (Contact cntct : contactsWithIndividual) {
      if (emailToWDCandidatePhoneMap.containsKey(cntct.Email))
        for (String wdcPhone : emailToWDCandidatePhoneMap.get(cntct.Email)) {
          if (cntct.Phone != null && wdcPhone != null) {
            if (individualToPhoneMap.containsKey(cntct.IndividualId)) {
              Set<String> tempSet = individualToPhoneMap.get(cntct.IndividualId);
              if (!tempSet.contains(wdcPhone)) {
                ContactPointPhone cpPhone = new ContactPointPhone();
                cpPhone.TelephoneNumber = wdcPhone;
                cpPhone.ParentId = cntct.IndividualId;
                cpPhone.ActiveFromDate = System.today();
                cpPhoneRecordsToInsert.add(cpPhone);
              }
            }
          }
        }
    }

    if (cpPhoneRecordsToInsert.size() > 0) {
      Database.SaveResult[] sObjectCPPhoneResultList = Database.insert(cpPhoneRecordsToInsert, false);
      for (Database.SaveResult sr : sObjectCPPhoneResultList) {
        if (!sr.isSuccess()) {
          for (Database.Error err : sr.getErrors()) {
            PF_Logger.log(
              'CEMCI',
              'ERROR',
              err.getMessage(),
              '' + err.getFields(),
              'Error during creating Contact Point Phone',
              'WDR Candidate to Contact Batch'
            );
          }
        }
      }
      if (PF_Logger.logs.size() > 0)
        PF_Logger.createLogs(PF_Logger.logs);
    }
  }

  public void convertLeads(Map<String, Contact> ContactEmailtoIdMap, Boolean confidential) {
    List<Lead> leadList = [
      SELECT Id, email, LinkedIn_Substring__c
      FROM Lead
      WHERE
        (Email IN :ContactEmailtoIdMap.keyset()
        OR LinkedIn_Substring__c IN :linkedInSubstrings)
        AND IsConverted = FALSE
        AND Confidential__c = :confidential
    ];
    for (Lead ld : leadList) {
      if (updateCandidateMap.get(ld.email) != null) {
        WDR_Candidate__c cand = updateCandidateMap.get(ld.email);
        cand.Awaiting_Lead_Conversion__c = true;
        updateCandidateMap.put(ld.email, cand);
      } else if (
        updateCandidateMap.containsKey(ld.LinkedIn_Substring__c) &&
        updateCandidateMap.get(ld.LinkedIn_Substring__c) != null
      ) {
        WDR_Candidate__c cand = updateCandidateMap.get(ld.LinkedIn_Substring__c);
        cand.Awaiting_Lead_Conversion__c = true;
        updateCandidateMap.put(ld.LinkedIn_Substring__c, cand);
      }
    }
  }
  public Map<String, Contact> convertExistingLeads(Map<String, Contact> ContactEmailtoIdMap, Boolean confidential) {
    Id cemciDefaultLeadOwnerId = CEMCI_Settings__c.getOrgDefaults().CEMCI_Default_Lead_Owner__c;
    LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
    List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
    Map<Id, Id> leadToIndividualMap = new Map<Id, Id>();
    Map<String, Contact> failedRecords = new Map<String, Contact>();
    Map<Id, String> idToEmailMap = new Map<Id, String>();

    List<Lead> leadList = [
      SELECT Id, email, IndividualId, ownerId
      FROM Lead
      WHERE Email IN :ContactEmailtoIdMap.keyset() AND IsConverted = FALSE AND Confidential__c = :confidential
    ];
    for (Lead l : leadList) {
      string leadEmail = l.email.toLowerCase();
      if (!ContactEmailtoIdMap.containsKey(leadEmail)) {
        PF_Logger.log(
          'CEMCI',
          'ERROR',
          'Couldnt find matching contact for lead with Id: ' + l.Id,
          'Null Pointer Exception',
          'Error during Lead coversion',
          'WDR Candidate to Contact Batch'
        );
        continue;
      }
      if (l.IndividualId != null) {
        leadToIndividualMap.put(l.id, l.IndividualId);
      }
      Database.LeadConvert tempLC = new Database.LeadConvert();
      tempLC.setLeadId(l.id);
      if (String.valueOf(l.ownerid).substring(0, 3) == '00G') {
        tempLC.setOwnerId(cemciDefaultLeadOwnerId);
      }
      tempLC.setContactId(ContactEmailtoIdMap.get(leadEmail).id);
      tempLC.setAccountId(ContactEmailtoIdMap.get(leadEmail).accountId);
      idToEmailMap.put(ContactEmailtoIdMap.get(leadEmail).id, l.email);
      tempLC.setDoNotCreateOpportunity(true);
      tempLC.setConvertedStatus(convertStatus.MasterLabel);
      leadsToConvert.add(tempLC);
    }

    if (leadsToConvert.size() > 0) {
      CEMCI_CheckGDPRRecursion.setExecutionVariable();
      if (!leadToIndividualMap.isEmpty())
        CEMCI_CheckGDPRRecursion.setleadToIndividualMap(leadToIndividualMap);
      list<Database.LeadConvertResult> lcrList = Database.convertLead(leadsToConvert, false);
      CEMCI_Leads.assignConvertedLeadValuesToContact(lcrList);
      for (Database.LeadConvertResult lcr : lcrList) {
        if (!lcr.isSuccess()) {
          for (Database.Error err : lcr.getErrors()) {
            PF_Logger.log(
              'CEMCI',
              'ERROR',
              err.getMessage(),
              '' + err.getStatusCode(),
              'Error during Lead coversion for lead id' +
              lcr.getLeadId() +
              ' into contact with id: ' +
              lcr.getContactId(),
              'WDR Candidate to Contact Batch'
            );
            failedRecords.put(lcr.getContactId(), ContactEmailtoIdMap.get(idToEmailMap.get(lcr.getContactId())));
          }
        }
      }
      if (PF_Logger.logs.size() > 0)
        PF_Logger.createLogs(PF_Logger.logs);
    }
    return failedRecords;
  }

  public void linkContactstoWDCandidates(
    Map<String, Contact> ContactEmailtoIdMap,
    String candidateType,
    Boolean confidential
  ) {
    List<WDR_Candidate__c> candList = [
      SELECT Id, Email__c, Candidate_Contact__c, LinkedIn_URL__c
      FROM WDR_Candidate__c
      WHERE
        Candidate_Contact__c = NULL
        AND email__c IN :ContactEmailtoIdMap.keyset()
        AND Candidate_Type__c = :candidateType
        AND Confidential__c = :confidential
    ];
    for (WDR_Candidate__c wdCand : candList) {
      wdCand.Candidate_Contact__c = ContactEmailtoIdMap.get(wdCand.email__c).id;
      wdCand.Ready_to_Process__c = false;
      if (!updateCandidateMap.containsKey(wdCand.Email__c))
        updateCandidateMap.put(wdCand.Email__c, wdCand);
      if (!updateCandidateMap.containsKey(wdCand.LinkedIn_URL__c) && wdCand.LinkedIn_URL__c != null) {
        String substring = CEMCI_Util.generateLinkedInSubstring(wdCand.LinkedIn_URL__c);
        if (substring != null)
          updateCandidateMap.put(substring, wdCand);
      }
    }
  }

  public void updateCandidates(List<WDR_Candidate__c> wdCandidatesToUpdate) {
    //Remove any potential duplicates by adding to a set
    Map<Id, WDR_Candidate__c> mapOfIdCand = new Map<Id, WDR_Candidate__c>();

    for (WDR_Candidate__c cand : wdCandidatesToUpdate) {
      mapOfIdCand.put(cand.id, cand);
    }
    if (mapOfIdCand.values().size() > 0) {
      Database.SaveResult[] srList = Database.update(mapOfIdCand.values(), false);
      for (Database.SaveResult sr : srList) {
        if (!sr.isSuccess()) {
          for (Database.Error err : sr.getErrors()) {
            PF_Logger.log(
              'CEMCI',
              'ERROR',
              err.getMessage(),
              '' + err.getFields(),
              'Error during linking Contacts with WD Candidates',
              'WDR Candidate to Contact Batch'
            );
          }
        }
      }
      if (PF_Logger.logs.size() > 0)
        PF_Logger.createLogs(PF_Logger.logs);
    }
    updateCandidateMap.clear();
  }
}