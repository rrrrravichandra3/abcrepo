public without sharing class CEMCI_GDPR_Handler {
  List<SObject> contactPointEmailRecordsToInsert = new List<SObject>();
  List<SObject> contactPointPhoneRecordsToInsert = new List<SObject>();
  private static List<ContactPointConsent> sourceSpecificcontactPointConsentsToInsert = new List<ContactPointConsent>();

  public List<SObject> createIndividual(List<SObject> recordsWithoutIndividual) {
    Map<Integer, SObject> individualtoSObjectMap = new Map<Integer, SObject>();
    List<Individual> newIndividualList = new List<Individual>();
    List<SObject> sObjectUpdateList = new List<SObject>();
    String objectType = '';
    Integer recReference = 0;

    for (SObject record : recordsWithoutIndividual) {
      Individual newRecord = new Individual();
      newRecord.FirstName = String.valueOf(record.get('FirstName'));
      newRecord.LastName = String.valueOf(record.get('LastName'));
      newIndividualList.add(newRecord);
      individualtoSObjectMap.put(recReference, record);
      recReference++;
    }

    Database.SaveResult[] individualResultList = Database.insert(newIndividualList, false);
    recordsWithoutIndividual.clear();
    for (Integer i = 0; i < individualResultList.size(); i++) {
      Database.SaveResult result = individualResultList.get(i);
      if (result.isSuccess()) {
        sObject updateRec = individualtoSObjectMap.get(i);
        updateRec.put('IndividualId', newIndividualList[i].Id);
        recordsWithoutIndividual.add(updateRec);
      } else {
        PF_Logger.log(
          'CEMCI',
          'ERROR',
          String.valueOf(result.getErrors()),
          null,
          ' Error during Individual record creation on ' +
          objectType +
          'run as user ' +
          UserInfo.getUserId(),
          'CEMCI_GDPR_Handler'
        );
      }
    }

    if (PF_Logger.logs.size() > 0)
      PF_Logger.createLogs(PF_Logger.logs);

    return recordsWithoutIndividual;
  }

  public List<SObject> createContactPoint(List<SObject> recordsWithIndividual) {
    Map<Id, Set<String>> individualToEmailMap = new Map<Id, Set<String>>();
    Map<Id, Set<String>> individualToPhoneMap = new Map<Id, Set<String>>();
    List<Id> IdList = new List<Id>();
    List<ContactPointEmail> existngCPEmails;
    List<ContactPointPhone> existngCPPhones;

    for (SObject record : recordsWithIndividual) {
      Id individualId = (Id) record.get('IndividualId');
      IdList.add(individualId);
    }

    existngCPEmails = [SELECT Id, ParentId, EmailAddress FROM ContactPointEmail WHERE ParentId IN :IdList];
    existngCPPhones = [SELECT Id, ParentId, TelephoneNumber FROM ContactPointPhone WHERE ParentId IN :IdList];

    for (ContactPointEmail cpEmail : existngCPEmails) {
      if (!individualToEmailMap.containsKey(cpEmail.ParentId))
        individualToEmailMap.put(cpEmail.ParentId, new Set<String>{ cpEmail.EmailAddress });
      else {
        Set<String> tempSet = individualToEmailMap.get(cpEmail.ParentId);
        tempSet.add(cpEmail.EmailAddress);
        individualToEmailMap.put(cpEmail.ParentId, tempSet);
      }
    }

    for (ContactPointPhone cpPhone : existngCPPhones) {
      if (!individualToPhoneMap.containsKey(cpPhone.ParentId))
        individualToPhoneMap.put(cpPhone.ParentId, new Set<String>{ cpPhone.TelephoneNumber });
      else {
        Set<String> tempSet = individualToPhoneMap.get(cpPhone.ParentId);
        tempSet.add(cpPhone.TelephoneNumber);
        individualToPhoneMap.put(cpPhone.ParentId, tempSet);
      }
    }

    //Once we have a map of all existing contact points, see if the incoming CP is a new one, if so insert
    for (SObject record : recordsWithIndividual) {
      if (record.get('Email') != null) {
        if (individualToEmailMap.containsKey((Id) record.get('IndividualId'))) {
          Set<String> tempSet = individualToEmailMap.get((Id) record.get('IndividualId'));

          if (!tempSet.contains((String) record.get('Email'))) {
            populateSObjectRecordsforInsert(record, 'ContactPointEmail', 'EmailAddress', 'Email');
          }
        } else {
          populateSObjectRecordsforInsert(record, 'ContactPointEmail', 'EmailAddress', 'Email');
        }
      }
      if (record.get('Phone') != null) {
        if (individualToPhoneMap.containsKey((Id) record.get('IndividualId'))) {
          Set<String> tempSet = individualToPhoneMap.get((Id) record.get('IndividualId'));

          if (!tempSet.contains((String) record.get('Phone'))) {
            populateSObjectRecordsforInsert(record, 'ContactPointPhone', 'TelephoneNumber', 'Phone');
          }
        } else {
          populateSObjectRecordsforInsert(record, 'ContactPointPhone', 'TelephoneNumber', 'Phone');
        }
      }
    }

    Database.SaveResult[] sObjectPhoneResultList = Database.insert(contactPointPhoneRecordsToInsert, false);
    Database.SaveResult[] sObjectEmailResultList = Database.insert(contactPointEmailRecordsToInsert, false);

    for (Integer i = 0; i < sObjectPhoneResultList.size(); i++) {
      Database.SaveResult result = sObjectPhoneResultList.get(i);
      if (!result.isSuccess()) {
        PF_Logger.log(
          'CEMCI',
          'ERROR',
          String.valueOf(result.getErrors()),
          null,
          ' Error during Contact Point record creation run as user ' + UserInfo.getUserId(),
          'CEMCI_GDPR_Handler'
        );
      }
    }
    for (Integer i = 0; i < sObjectEmailResultList.size(); i++) {
      Database.SaveResult result = sObjectEmailResultList.get(i);
      if (!result.isSuccess()) {
        PF_Logger.log(
          'CEMCI',
          'ERROR',
          String.valueOf(result.getErrors()),
          null,
          ' Error during Contact Point record creation run as user ' + UserInfo.getUserId(),
          'CEMCI_GDPR_Handler'
        );
      }
    }

    if (PF_Logger.logs.size() > 0)
      PF_Logger.createLogs(PF_Logger.logs);

    return recordsWithIndividual;
  }

  /*
    Salesforce standard privacy record merge during Database.merge retains either all master's privacy records or all child's privacy records.
    For CMECI we wanted to retain a combination of master and child's records. 

    When two Lead records are merged, Privacy records are compared between master and child. If there are common
    records, retain master's privacy records and delete child's records. If there are records under child that
    are not in master (ex: additional email or phone on child) then reparent this record to master.

    Objects used - Contact Point Email,Contact Point Phone, Individual
    DML Operations - Update, Delete
    Logs - PF Debug Logs

    */

  public static void mergeGDPRRecords(List<SObject> recordsToProcess) {
    Map<Id, Individual> mastersGDPRRecords = new Map<Id, Individual>();
    Map<Id, Individual> duplicatesGDPRRecords = new Map<Id, Individual>();
    Set<Id> masterRecordIdList = new Set<Id>();
    Set<Id> dupeRecordIdList = new Set<Id>();
    Map<Id, Id> dupetoMasterMap = new Map<Id, Id>();
    Map<Id, Id> sObjectToIndividualMap = new Map<Id, Id>();
    List<ContactPointEmail> cpEmailrecordsToUpdate = new List<ContactPointEmail>();
    List<ContactPointPhone> cpPhonerecordsToUpdate = new List<ContactPointPhone>();
    List<AuthorizationFormConsent> authConsentrecordsToUpdate = new List<AuthorizationFormConsent>();
    List<ContactPointConsent> cpConsentrecordsToUpdate = new List<ContactPointConsent>();
    List<Id> recordsToDelete = new List<Id>();

    String objectType = '';
    String queryIdString = '';

    for (SObject record : recordsToProcess) {
      if (record.get('MasterRecordId') != null) {
        dupeRecordIdList.add((Id) record.get('Id'));
        masterRecordIdList.add((Id) record.get('MasterRecordId'));
        dupetoMasterMap.put((Id) record.get('Id'), (Id) record.get('MasterRecordId'));
        objectType = String.valueOf(((Id) record.get('MasterRecordId')).getSobjectType());
        queryIdString += '\'' + String.valueOf(record.get('MasterRecordId')) + '\',';
        queryIdString += '\'' + String.valueOf(record.get('Id')) + '\',';
      } else {
        masterRecordIdList.add((Id) record.get('ConvertedContactId'));
        dupetoMasterMap.put((Id) record.get('Id'), (Id) record.get('ConvertedContactId'));
        objectType = 'Contact';
        queryIdString += '\'' + String.valueOf(record.get('ConvertedContactId')) + '\',';
      }
    }

    queryIdString = queryIdString.substring(0, queryIdString.length() - 1);
    String query = 'Select Id,IndividualId from ' + objectType + ' Where Id IN (' + queryIdString + ') ALL ROWS';

    for (SObject record : Database.query(query)) {
      if (record.get('IndividualId') != null) {
        sObjectToIndividualMap.put((Id) record.get('Id'), (Id) record.get('IndividualId'));
      }
    }

    Map<Id, Id> leadToIndividualMap = CEMCI_CheckGDPRRecursion.getleadToIndividualMap();

    if (leadToIndividualMap != null) {
      for (Id leadId : leadToIndividualMap.keySet()) {
        if (dupetoMasterMap != null && sObjectToIndividualMap != null && dupetoMasterMap.containsKey(leadId)) {
          Id masterId = dupetoMasterMap.get(leadId);
          if (sObjectToIndividualMap.get(masterId) != null) {
            //When lead is converted to contact, the Individual and Contact point records are automatically carried over to Converted contact,
            //if Contact doesn't already have individual. Below code removes such records from further processing
            if (sObjectToIndividualMap.get(masterId) == leadToIndividualMap.get(leadId))
              sObjectToIndividualMap.remove(masterId);
            else {
              sObjectToIndividualMap.put(leadId, leadToIndividualMap.get(leadId));
              dupeRecordIdList.add(leadId);
            }
          }
        }
      }
    }

    List<Id> masterRecordIndividualIds = new List<Id>();
    List<Id> dupeRecordIndividualIds = new List<Id>();
    Map<Id, ContactPointEmail> dupeCPEmailConsents;
    Map<Id, ContactPointPhone> dupeCPPhoneConsents;

    if (sObjectToIndividualMap.size() > 0 && dupeRecordIdList.size() > 0) {
      for (Id recId : masterRecordIdList) {
        masterRecordIndividualIds.add(sObjectToIndividualMap.get(recId));
      }
      for (Id recId : dupeRecordIdList) {
        dupeRecordIndividualIds.add(sObjectToIndividualMap.get(recId));
      }
      mastersGDPRRecords = new Map<Id, Individual>(
        [
          SELECT
            Id,
            (SELECT Id, EmailAddress, ParentId FROM ContactPointEmails),
            (SELECT Id, TelephoneNumber, ParentId FROM ContactPointPhones)
          FROM Individual
          WHERE Id IN :masterRecordIndividualIds
        ]
      );

      duplicatesGDPRRecords = new Map<Id, Individual>(
        [
          SELECT
            Id,
            (SELECT Id, EmailAddress, ParentId FROM ContactPointEmails),
            (SELECT Id, TelephoneNumber, ParentId FROM ContactPointPhones),
            (SELECT Id, ConsentGiverId FROM AuthorizationFormConsents)
          FROM Individual
          WHERE Id IN :dupeRecordIndividualIds
        ]
      );

      dupeCPEmailConsents = new Map<Id, ContactPointEmail>(
        [
          SELECT Id, (SELECT Id, ContactPointId FROM ContactPointConsents)
          FROM ContactPointEmail
          WHERE ParentId IN :dupeRecordIndividualIds
        ]
      );

      dupeCPPhoneConsents = new Map<Id, ContactPointPhone>(
        [
          SELECT Id, (SELECT Id, ContactPointId FROM ContactPointConsents)
          FROM ContactPointPhone
          WHERE ParentId IN :dupeRecordIndividualIds
        ]
      );

      Map<Id, Set<String>> masterRecordEmailMap = new Map<Id, Set<String>>();
      Map<Id, Set<String>> masterRecordPhoneMap = new Map<Id, Set<String>>();
      Map<String, Id> masterRecordContactPointMap = new Map<String, Id>();

      if (mastersGDPRRecords.size() > 0 && duplicatesGDPRRecords.size() > 0) {
        for (Id recId : masterRecordIndividualIds) {
          for (ContactPointEmail cpEmail : mastersGDPRRecords.get(recId).ContactPointEmails) {
            if (masterRecordEmailMap.containsKey(recId)) {
              Set<String> tempSet = masterRecordEmailMap.get(recId);
              tempSet.add(cpEmail.EmailAddress);
              masterRecordEmailMap.put(recId, tempSet);
            } else {
              masterRecordEmailMap.put(recId, new Set<String>{ cpEmail.EmailAddress });
            }
            masterRecordContactPointMap.put(cpEmail.EmailAddress, cpEmail.Id);
          }
          for (ContactPointPhone cpPhone : mastersGDPRRecords.get(recId).ContactPointPhones) {
            if (masterRecordPhoneMap.containsKey(recId)) {
              Set<String> tempSet = masterRecordPhoneMap.get(recId);
              tempSet.add(cpPhone.TelephoneNumber);
              masterRecordPhoneMap.put(recId, tempSet);
            } else {
              masterRecordPhoneMap.put(recId, new Set<String>{ cpPhone.TelephoneNumber });
            }
            masterRecordContactPointMap.put(cpPhone.TelephoneNumber, cpPhone.Id);
          }
        }

        Set<Id> deleteRecordSet = new Set<Id>();
        for (Id dupeRecId : dupetoMasterMap.keySet()) {
          Id masterRecId = dupetoMasterMap.get(dupeRecId);
          Id masterRecIndId = sObjectToIndividualMap.get(masterRecId);

          //delete duplicate Individual
          if (sObjectToIndividualMap.get(dupeRecId) != null)
            deleteRecordSet.add(sObjectToIndividualMap.get(dupeRecId));

          //delete any common contact point records in dupe compared to master, move all consent records to master
          //reparent any uncommon contact point records
          if (duplicatesGDPRRecords.get(sObjectToIndividualMap.get(dupeRecId)) != null) {
            for (
              ContactPointEmail dupeCPEmail : duplicatesGDPRRecords.get(sObjectToIndividualMap.get(dupeRecId))
                .ContactPointEmails
            ) {
              if (
                !masterRecordEmailMap.isEmpty() &&
                masterRecordEmailMap.get(masterRecIndId) != null &&
                masterRecordEmailMap.get(masterRecIndId).contains(dupeCPEmail.EmailAddress)
              ) {
                if (!dupeCPEmailConsents.isEmpty()) {
                  for (ContactPointConsent cpConsent : dupeCPEmailConsents.get(dupeCPEmail.Id).ContactPointConsents) {
                    if (!masterRecordContactPointMap.isEmpty()) {
                      cpConsent.ContactPointId = masterRecordContactPointMap.get(dupeCPEmail.EmailAddress);
                      cpConsentrecordsToUpdate.add(cpConsent);
                    }
                  }
                }
                if (!deleteRecordSet.contains(dupeCPEmail.ParentId))
                  recordsToDelete.add(dupeCPEmail.Id);
              } else {
                dupeCPEmail.ParentId = masterRecIndId;
                cpEmailrecordsToUpdate.add(dupeCPEmail);
              }
            }

            for (
              ContactPointPhone dupeDPPhone : duplicatesGDPRRecords.get(sObjectToIndividualMap.get(dupeRecId))
                .ContactPointPhones
            ) {
              if (
                !masterRecordPhoneMap.isEmpty() &&
                masterRecordPhoneMap.get(masterRecIndId) != null &&
                masterRecordPhoneMap.get(masterRecIndId).contains(dupeDPPhone.TelephoneNumber)
              ) {
                if (!dupeCPPhoneConsents.isEmpty()) {
                  for (ContactPointConsent cpConsent : dupeCPPhoneConsents.get(dupeDPPhone.Id).ContactPointConsents) {
                    if (!masterRecordContactPointMap.isEmpty()) {
                      cpConsent.ContactPointId = masterRecordContactPointMap.get(dupeDPPhone.TelephoneNumber);
                      cpConsentrecordsToUpdate.add(cpConsent);
                    }
                  }
                }
                if (!deleteRecordSet.contains(dupeDPPhone.ParentId))
                  recordsToDelete.add(dupeDPPhone.Id);
              } else {
                dupeDPPhone.ParentId = masterRecIndId;
                cpPhonerecordsToUpdate.add(dupeDPPhone);
              }
            }

            for (
              AuthorizationFormConsent dupeAuthFormConsent : duplicatesGDPRRecords.get(
                  sObjectToIndividualMap.get(dupeRecId)
                )
                .AuthorizationFormConsents
            ) {
              dupeAuthFormConsent.ConsentGiverId = masterRecIndId;
              authConsentrecordsToUpdate.add(dupeAuthFormConsent);
            }
          }
        }
        recordsToDelete.addAll(deleteRecordSet);
        recordsToDelete.sort();
        if (cpEmailrecordsToUpdate.size() > 0)
          updateRecordsinDatabase(cpEmailrecordsToUpdate);

        if (cpPhonerecordsToUpdate.size() > 0)
          updateRecordsinDatabase(cpPhonerecordsToUpdate);

        if (authConsentrecordsToUpdate.size() > 0)
          updateRecordsinDatabase(authConsentrecordsToUpdate);

        if (cpConsentrecordsToUpdate.size() > 0)
          updateRecordsinDatabase(cpConsentrecordsToUpdate);

        Database.DeleteResult[] sObjectDeleteResult = Database.delete(recordsToDelete, false);
        for (Database.DeleteResult result : sObjectDeleteResult) {
          if (!result.isSuccess()) {
            PF_Logger.log(
              'CEMCI',
              'ERROR',
              String.valueOf(result.getErrors()),
              null,
              ' Error during Individual and Contact Point record deletion run as user ' + UserInfo.getUserId(),
              'CEMCI_GDPR_Handler'
            );
          }
        }
        if (PF_Logger.logs.size() > 0)
          PF_Logger.createLogs(PF_Logger.logs);
      }
    }
  }

  private void populateSObjectRecordsforInsert(
    SObject objectRecord,
    String objectType,
    String cpField,
    String sobjectField
  ) {
    sObject insertRec = Schema.getGlobalDescribe().get(objectType).newSObject();
    insertRec.put(cpField, (String) objectRecord.get(sobjectField));
    insertRec.put('ParentId', (Id) objectRecord.get('IndividualId'));
    insertRec.put('ActiveFromDate', System.today());
    if (objectType == 'ContactPointPhone') {
      contactPointPhoneRecordsToInsert.add(insertRec);
    } else if (objectType == 'ContactPointEmail') {
      contactPointEmailRecordsToInsert.add(insertRec);
    }
  }

  private static void updateRecordsinDatabase(List<sObject> recordsToUpdate) {
    Database.SaveResult[] sObjectUpdateResult = Database.update(recordsToUpdate, false);
    for (Database.SaveResult result : sObjectUpdateResult) {
      if (!result.isSuccess()) {
        PF_Logger.log(
          'CEMCI',
          'ERROR',
          String.valueOf(result.getErrors()),
          null,
          ' Error during Contact Point record updation run as user ' + UserInfo.getUserId(),
          'CEMCI_GDPR_Handler'
        );
      }
    }
  }

  public void createConsentRecords(List<SObject> recordsWithIndividual, String objectType) {
    Map<Id, String> individualToMailingCountryMap = new Map<Id, String>();
    Map<Id, String> individualToSourceMap = new Map<Id, String>();
    Set<Id> individualIds = new Set<Id>();

    //create source specific consent records
    if (recordsWithIndividual != null && !recordsWithIndividual.isEmpty()) {
      for (sObject record : recordsWithIndividual) {
        Id individualId = (Id) record.get('IndividualId');
        individualIds.add(individualId);

        if (record.get('LeadSource') != null) {
          String source = String.valueOf(record.get('LeadSource'));
          individualToSourceMap.put(individualId, source);
        }

        if (objectType == 'Lead' && record.get('Mailing_Country_Global__c') != null) {
          String country = String.valueOf(record.get('Mailing_Country_Global__c'));
          individualToMailingCountryMap.put(individualId, country);
        }
        if (objectType == 'Contact' && record.get('Mailing_Country__c') != null) {
          String country = String.valueOf(record.get('Mailing_Country__c'));
          individualToMailingCountryMap.put(individualId, country);
        }
      }

      createSourceSpecificContactPointConsentRecords(
        individualIds,
        individualToSourceMap,
        individualToMailingCountryMap
      );
    }
  }

  // Method to create Source Specific Contact Point Consent

  public static void createSourceSpecificContactPointConsentRecords(
    Set<Id> individualIds,
    Map<Id, String> individualToSourceMap,
    Map<Id, String> individualToMailingCountryMap
  ) {
    Set<Id> contactPointIds = new Set<Id>();
    Map<Id, String> consentCategoryMap = new Map<Id, String>();
    Map<Id, List<ContactPointPhone>> individualtoContactPointPhoneMap = new Map<Id, List<ContactPointPhone>>();
    Map<Id, List<ContactPointEmail>> individualtoContactPointEmailMap = new Map<Id, List<ContactPointEmail>>();
    List<ContactPointPhone> conPhoneList;
    List<ContactPointEmail> conEmailList;
    List<DataUsePurpose> sourceSpecificDataUsePurposeForContactPointPhone;
    List<DataUsePurpose> sourceSpecificDataUsePurposeForContactPointEmail;
    List<ContactPointConsent> sourceSpecificcontactPointConsentsToUpdate = new List<ContactPointConsent>();

    if (individualIds != null && !individualIds.isEmpty()) {
      sourceSpecificDataUsePurposeForContactPointPhone = getSourceSpecificDataUsePurpose(
        'Phone',
        individualToSourceMap.values(),
        individualToMailingCountryMap.values()
      );

      sourceSpecificDataUsePurposeForContactPointEmail = getSourceSpecificDataUsePurpose(
        'Email',
        individualToSourceMap.values(),
        individualToMailingCountryMap.values()
      );

      for (ContactPointPhone conPhone : [
        SELECT Id, ParentId, TelephoneNumber
        FROM ContactPointPhone
        WHERE ParentId IN :individualIds
      ]) {
        contactPointIds.add(conPhone.Id);

        if (!individualtoContactPointPhoneMap.containskey(conPhone.ParentId))
          individualtoContactPointPhoneMap.put(conPhone.ParentId, new List<ContactPointPhone>());

        individualtoContactPointPhoneMap.get(conPhone.ParentId).add(conPhone);
      }

      for (ContactPointEmail conEmail : [
        SELECT Id, ParentId, EmailAddress
        FROM ContactPointEmail
        WHERE ParentId IN :individualIds
      ]) {
        contactPointIds.add(conEmail.Id);

        if (!individualtoContactPointEmailMap.containskey(conEmail.ParentId))
          individualtoContactPointEmailMap.put(conEmail.ParentId, new List<ContactPointEmail>());

        individualtoContactPointEmailMap.get(conEmail.ParentId).add(conEmail);
      }

      if (contactPointIds != null && !contactPointIds.isEmpty()) {
        for (ContactPointConsent consent : [
          SELECT Id, Name, ContactPointId, ContactPoint.Name, CaptureSource, CaptureContactPointType, EffectiveTo
          FROM ContactPointConsent
          WHERE ContactPointId IN :contactPointIds AND EffectiveTo = NULL
        ]) {
          String consentName = consent.Name;
          String consentSource = consent.CaptureSource;
          String formBasedConsentSource = System.Label.CEMCI_Consent_Capture_Source;

          if (consentSource.equals(formBasedConsentSource)) {
            String consentCategory = consentName.substringAfterLast(' ');
            consentCategoryMap.put(consent.ContactPointId, consentCategory);
          } else {
            consent.EffectiveTo = System.now();
            sourceSpecificcontactPointConsentsToUpdate.add(consent);
          }
        }
      }

      for (Id individualId : individualIds) {
        String source, country;

        if (individualToSourceMap.get(individualId) != null) {
          source = individualToSourceMap.get(individualId);
        }

        if (individualToMailingCountryMap.get(individualId) != null) {
          country = individualToMailingCountryMap.get(individualId);
        }

        if (individualtoContactPointPhoneMap.get(individualId) != null) {
          conPhoneList = individualtoContactPointPhoneMap.get(individualId);
          createSourceSpecificContactPointPhoneConsentList(
            source,
            country,
            consentCategoryMap,
            conPhoneList,
            sourceSpecificDataUsePurposeForContactPointPhone
          );
        }

        if (individualtoContactPointEmailMap.get(individualId) != null) {
          conEmailList = individualtoContactPointEmailMap.get(individualId);
          createSourceSpecificContactPointEmailConsentList(
            source,
            country,
            consentCategoryMap,
            conEmailList,
            sourceSpecificDataUsePurposeForContactPointEmail
          );
        }
      }

      if (sourceSpecificcontactPointConsentsToInsert != null && !sourceSpecificcontactPointConsentsToInsert.isEmpty()) {
        Database.SaveResult[] srList = Database.insert(sourceSpecificcontactPointConsentsToInsert, false);

        for (Database.SaveResult sr : srList) {
          if (!sr.isSuccess()) {
            for (Database.Error objErr : sr.getErrors()) {
              PF_Logger.log(
                'CEMCI',
                'ERROR',
                objErr.getMessage(),
                String.valueof(objErr.getStatusCode()),
                'Error during source specific consent insert ' +
                sr.getId() +
                ' UserId ' +
                UserInfo.getUserId(),
                'CEMCI_GDPR_Handler'
              );
            }
          }
        }
        sourceSpecificcontactPointConsentsToInsert.clear();
        NHW_Util.insertNHWLogs();
      }

      if (sourceSpecificcontactPointConsentsToUpdate != null && !sourceSpecificcontactPointConsentsToUpdate.isEmpty()) {
        Database.SaveResult[] srList = Database.update(sourceSpecificcontactPointConsentsToUpdate, false);

        for (Database.SaveResult sr : srList) {
          if (!sr.isSuccess()) {
            for (Database.Error objErr : sr.getErrors()) {
              PF_Logger.log(
                'CEMCI',
                'ERROR',
                objErr.getMessage(),
                String.valueof(objErr.getStatusCode()),
                'Error during source specific consent update ' +
                sr.getId() +
                ' UserId ' +
                UserInfo.getUserId(),
                'CEMCI_GDPR_Handler'
              );
            }
          }
        }
        NHW_Util.insertNHWLogs();
      }
    }
  }

  // Method to create Opt In / Opt Out Contact Point Consent

  public void createOptInOptOutContactPointConsentRecords(
    Set<Id> individualIds,
    Map<Id, Map<Id, Id>> dataUsePurposeMap,
    Map<Id, Map<Id, String>> contactPointTypeMap,
    Map<Id, Map<Id, String>> consentCategoryMap,
    Map<Id, DateTime> mapOfAuthFormConIdMemResDT
  ) {
    Map<String, ContactPointPhone> conPhoneMap;
    Map<String, ContactPointEmail> conEmailMap;
    Map<Id, Map<String, ContactPointPhone>> individualtoContactPhoneMap = new Map<Id, Map<String, ContactPointPhone>>();
    Map<Id, Map<String, ContactPointEmail>> individualtoContactEmailMap = new Map<Id, Map<String, ContactPointEmail>>();
    Map<String, ContactPointConsent> consentMap = new Map<String, ContactPointConsent>();
    Set<Id> contactPointIds = new Set<Id>();
    Map<String, ContactPointConsent> OptInOptOutContactPointConsentsToInsert = new Map<String, ContactPointConsent>();
    Map<Id, ContactPointConsent> OptInOptOutContactPointConsentsToUpdate = new Map<Id, ContactPointConsent>();

    if (individualIds != null && !individualIds.isEmpty()) {
      for (ContactPointPhone conPhone : [
        SELECT Id, ParentId, TelephoneNumber
        FROM ContactPointPhone
        WHERE ParentId IN :individualIds
      ]) {
        if (!individualtoContactPhoneMap.containskey(conPhone.ParentId))
          individualtoContactPhoneMap.put(conPhone.ParentId, new Map<String, ContactPointPhone>());

        individualtoContactPhoneMap.get(conPhone.ParentId).put(conPhone.TelephoneNumber, conPhone);
      }

      for (ContactPointEmail conEmail : [
        SELECT Id, ParentId, EmailAddress
        FROM ContactPointEmail
        WHERE ParentId IN :individualIds
      ]) {
        if (!individualtoContactEmailMap.containskey(conEmail.ParentId))
          individualtoContactEmailMap.put(conEmail.ParentId, new Map<String, ContactPointEmail>());

        individualtoContactEmailMap.get(conEmail.ParentId).put(conEmail.EmailAddress, conEmail);
      }

      for (Id authFormconsentId : dataUsePurposeMap.keySet()) {
        Map<Id, Id> individualToDataUsePurposeMap;
        Map<Id, String> individualToContactPointTypeMap;
        Map<Id, String> individualToConsentCategoryMap;

        if (dataUsePurposeMap.get(authFormconsentId) != null) {
          individualToDataUsePurposeMap = dataUsePurposeMap.get(authFormconsentId);
        }

        if (contactPointTypeMap.get(authFormconsentId) != null) {
          individualToContactPointTypeMap = contactPointTypeMap.get(authFormconsentId);
        }

        if (consentCategoryMap.get(authFormconsentId) != null) {
          individualToConsentCategoryMap = consentCategoryMap.get(authFormconsentId);
        }

        for (Id individualId : individualToDataUsePurposeMap.keySet()) {
          ContactPointPhone conPhone;
          ContactPointEmail conEmail;
          String contactPointType, dataPurposeId, consentCateogry;

          if (individualToDataUsePurposeMap.get(individualId) != null) {
            dataPurposeId = individualToDataUsePurposeMap.get(individualId);
          }

          if (individualToContactPointTypeMap.get(individualId) != null) {
            contactPointType = individualToContactPointTypeMap.get(individualId);
          }

          if (individualToConsentCategoryMap.get(individualId) != null) {
            consentCateogry = individualToConsentCategoryMap.get(individualId);
          }

          if (individualtoContactPhoneMap.get(individualId) != null) {
            conPhoneMap = individualtoContactPhoneMap.get(individualId);
          }

          if (individualtoContactEmailMap.get(individualId) != null) {
            conEmailMap = individualtoContactEmailMap.get(individualId);
          }

          //memberRespondedDateTime
          DateTime mrdt;
          if (
            mapOfAuthFormConIdMemResDT.containsKey(authFormconsentId) &&
            mapOfAuthFormConIdMemResDT.get(authFormconsentId) != null
          )
            mrdt = mapOfAuthFormConIdMemResDT.get(authFormconsentId);
          else
            mrdt = null;

          if (conPhoneMap != null && !conPhoneMap.isEmpty()) {
            if (conPhoneMap.get(contactPointType) != null) {
              conPhone = conPhoneMap.get(contactPointType);

              if (conPhone != null) {
                contactPointIds.add(conPhone.Id);

                ContactPointConsent consent = createOptInOptOutContactPointPhoneConsent(
                  dataPurposeId,
                  conPhone.Id,
                  consentCateogry,
                  conPhone.TelephoneNumber,
                  mrdt
                );

                OptInOptOutContactPointConsentsToInsert.put(consent.name, consent);
              }
            }
          }

          if (conEmailMap != null && !conEmailMap.isEmpty()) {
            if (conEmailMap.get(contactPointType) != null) {
              conEmail = conEmailMap.get(contactPointType);

              if (conEmail != null) {
                contactPointIds.add(conEmail.Id);

                ContactPointConsent consent = createOptInOptOutContactPointEmailConsent(
                  dataPurposeId,
                  conEmail.Id,
                  consentCateogry,
                  conEmail.EmailAddress,
                  mrdt
                );

                OptInOptOutContactPointConsentsToInsert.put(consent.name, consent);
              }
            }
          }
        }
      }

      if (contactPointIds != null && !contactPointIds.isEmpty()) {
        for (ContactPointConsent consent : [
          SELECT Id, Name, ContactPointId, EffectiveTo, DataUsePurposeId, Member_Responded_Datetime__c
          FROM ContactPointConsent
          WHERE ContactPointId IN :contactPointIds AND EffectiveTo = NULL
        ]) {
          consentMap.put(consent.Name, consent);
        }
      }

      if (consentMap != null && !consentMap.isEmpty()) {
        for (Id authFormconsentId : dataUsePurposeMap.keySet()) {
          Map<Id, Id> individualToDataUsePurposeMap;
          Map<Id, String> individualToContactPointTypeMap;
          Map<Id, String> individualToConsentCategoryMap;

          if (dataUsePurposeMap.get(authFormconsentId) != null) {
            individualToDataUsePurposeMap = dataUsePurposeMap.get(authFormconsentId);
          }

          if (contactPointTypeMap.get(authFormconsentId) != null) {
            individualToContactPointTypeMap = contactPointTypeMap.get(authFormconsentId);
          }

          if (consentCategoryMap.get(authFormconsentId) != null) {
            individualToConsentCategoryMap = consentCategoryMap.get(authFormconsentId);
          }

          for (Id individualId : individualToDataUsePurposeMap.keySet()) {
            String contactPointType, dataPurposeId, consentCategory;

            if (individualToDataUsePurposeMap.get(individualId) != null) {
              dataPurposeId = individualToDataUsePurposeMap.get(individualId);
            }

            if (individualToContactPointTypeMap.get(individualId) != null) {
              contactPointType = individualToContactPointTypeMap.get(individualId);
            }

            if (individualToConsentCategoryMap.get(individualId) != null) {
              consentCategory = individualToConsentCategoryMap.get(individualId);
            }

            String consentMapKey = contactPointType + ' ' + consentCategory;

            if (consentMap.containskey(consentMapKey)) {
              ContactPointConsent oldConsent = consentMap.get(consentMapKey);
              if (
                OptInOptOutContactPointConsentsToInsert.containsKey(consentMapKey) &&
                OptInOptOutContactPointConsentsToInsert.get(consentMapKey) != null
              ) {
                ContactPointConsent newConsent = OptInOptOutContactPointConsentsToInsert.get(consentMapKey);
                if (oldConsent.Member_Responded_Datetime__c > newConsent.Member_Responded_Datetime__c) {
                  newConsent.EffectiveTo = System.now();
                  OptInOptOutContactPointConsentsToInsert.put(consentMapKey, newConsent);
                } else {
                  oldConsent.EffectiveTo = System.now();
                  if (!OptInOptOutContactPointConsentsToUpdate.containsKey(oldConsent.Id))
                    OptInOptOutContactPointConsentsToUpdate.put(oldConsent.Id, oldConsent);
                }
              }
            }
          }
        }
      }

      if (OptInOptOutContactPointConsentsToInsert != null && !OptInOptOutContactPointConsentsToInsert.isEmpty()) {
        Database.SaveResult[] srList = Database.insert(OptInOptOutContactPointConsentsToInsert.values(), false);

        for (Database.SaveResult sr : srList) {
          if (!sr.isSuccess()) {
            for (Database.Error objErr : sr.getErrors()) {
              PF_Logger.log(
                'CEMCI',
                'ERROR',
                objErr.getMessage(),
                String.valueof(objErr.getStatusCode()),
                'Error during Opt in / Opt out consent insert ' +
                sr.getId() +
                ' UserId ' +
                UserInfo.getUserId(),
                'CEMCI_GDPR_Handler'
              );
            }
          }
        }
        NHW_Util.insertNHWLogs();
      }

      if (OptInOptOutContactPointConsentsToUpdate != null && !OptInOptOutContactPointConsentsToUpdate.isEmpty()) {
        Database.SaveResult[] srList = Database.update(OptInOptOutContactPointConsentsToUpdate.values(), false);

        for (Database.SaveResult sr : srList) {
          if (!sr.isSuccess()) {
            for (Database.Error objErr : sr.getErrors()) {
              PF_Logger.log(
                'CEMCI',
                'ERROR',
                objErr.getMessage(),
                String.valueof(objErr.getStatusCode()),
                'Error during Opt in / Opt out consent update ' +
                sr.getId() +
                ' UserId ' +
                UserInfo.getUserId(),
                'CEMCI_GDPR_Handler'
              );
            }
          }
        }
        NHW_Util.insertNHWLogs();
      }
    }
  }

  public static List<DataUsePurpose> getSourceSpecificDataUsePurpose(
    String consentType,
    List<String> leadSources,
    List<String> countries
  ) {
    List<String> dataUsePurposeCountries = new List<String>();
    String dataUsePurposeCountry;

    if (countries != null && !countries.isEmpty()) {
      for (String country : countries) {
        dataUsePurposeCountries.add('\'' + country + '\'');
      }
    }
    List<DataUsePurpose> sourceSpecificDataUsePurpose = new List<DataUsePurpose>();

    if (dataUsePurposeCountries != null && !dataUsePurposeCountries.isEmpty()) {
      dataUsePurposeCountry = String.join(dataUsePurposeCountries, ',');
    } else {
      dataUsePurposeCountry = '\'\'';
    }

    String queryString =
      'Select Id, Active__c, Country_ies__c,LegalBasisId,LegalBasis.Source,Consent_Category__c,Consent_Type__c from DataUsePurpose where LegalBasis.Source IN :leadSources and Consent_Type__c = :consentType and Country_ies__c includes (' +
      dataUsePurposeCountry +
      ') order by LegalBasis.Source desc';

    for (DataUsePurpose dataPurpose : Database.query(queryString)) {
      sourceSpecificDataUsePurpose.add(dataPurpose);
    }

    return sourceSpecificDataUsePurpose;
  }

  // Method to create Contact Point Consent List For Contact Point Type - Phone

  public static void createSourceSpecificContactPointPhoneConsentList(
    String leadSource,
    String mailingCountry,
    Map<Id, String> consentCategoryMap,
    List<ContactPointPhone> conPhoneList,
    List<DataUsePurpose> sourceSpecificDataUsePurposeForContactPointPhone
  ) {
    String dataPurposeCountry, dataPurposeSource, dataPurposeCategory, consentCategory;

    if (
      sourceSpecificDataUsePurposeForContactPointPhone != null &&
      !sourceSpecificDataUsePurposeForContactPointPhone.isEmpty()
    ) {
      for (DataUsePurpose dataPurpose : sourceSpecificDataUsePurposeForContactPointPhone) {
        dataPurposeCountry = dataPurpose.Country_ies__c;
        dataPurposeSource = dataPurpose.LegalBasis.Source;
        dataPurposeCategory = dataPurpose.Consent_Category__c;

        if (dataPurposeCountry.contains(mailingCountry) && dataPurposeSource.equals(leadSource)) {
          if (conPhoneList != null && !conPhoneList.isEmpty()) {
            for (ContactPointPhone conPhone : conPhoneList) {
              if (consentCategoryMap != null && !consentCategoryMap.isEmpty()) {
                Boolean isConsentCategoryPresent = false;

                if (consentCategoryMap.get(conPhone.Id) != null) {
                  consentCategory = consentCategoryMap.get(conPhone.Id);
                }

                if (consentCategory != null) {
                  isConsentCategoryPresent = dataPurposeCategory.equals(consentCategory);
                }

                if (!isConsentCategoryPresent) {
                  ContactPointConsent consent = createSourceSpecificContactPointPhoneConsent(
                    dataPurpose.Id,
                    conPhone.Id,
                    dataPurpose.LegalBasis.Source,
                    dataPurpose.Consent_Category__c,
                    conPhone.TelephoneNumber
                  );
                  sourceSpecificcontactPointConsentsToInsert.add(consent);
                }
              } else {
                ContactPointConsent consent = createSourceSpecificContactPointPhoneConsent(
                  dataPurpose.Id,
                  conPhone.Id,
                  dataPurpose.LegalBasis.Source,
                  dataPurpose.Consent_Category__c,
                  conPhone.TelephoneNumber
                );
                sourceSpecificcontactPointConsentsToInsert.add(consent);
              }
            }
          }
        }
      }
    }
  }

  // Method to create Contact Point Consent List For Contact Point Type - Email

  public static void createSourceSpecificContactPointEmailConsentList(
    String leadSource,
    String mailingCountry,
    Map<Id, String> consentCategoryMap,
    List<ContactPointEmail> conEmailList,
    List<DataUsePurpose> sourceSpecificDataUsePurposeForContactPointEmail
  ) {
    String dataPurposeCountry, dataPurposeSource, dataPurposeCategory, consentCategory;

    if (
      sourceSpecificDataUsePurposeForContactPointEmail != null &&
      !sourceSpecificDataUsePurposeForContactPointEmail.isEmpty()
    ) {
      for (DataUsePurpose dataPurpose : sourceSpecificDataUsePurposeForContactPointEmail) {
        dataPurposeCountry = dataPurpose.Country_ies__c;
        dataPurposeSource = dataPurpose.LegalBasis.Source;
        dataPurposeCategory = dataPurpose.Consent_Category__c;

        if (dataPurposeCountry.contains(mailingCountry) && dataPurposeSource.equals(leadSource)) {
          if (conEmailList != null && !conEmailList.isEmpty()) {
            for (ContactPointEmail conEmail : conEmailList) {
              if (consentCategoryMap != null && !consentCategoryMap.isEmpty()) {
                Boolean isConsentCategoryPresent = false;

                if (consentCategoryMap.get(conEmail.Id) != null) {
                  consentCategory = consentCategoryMap.get(conEmail.Id);
                }

                if (consentCategory != null) {
                  isConsentCategoryPresent = dataPurposeCategory.equals(consentCategory);
                }

                if (!isConsentCategoryPresent) {
                  ContactPointConsent consent = createSourceSpecificContactPointEmailConsent(
                    dataPurpose.Id,
                    conEmail.Id,
                    dataPurpose.LegalBasis.Source,
                    dataPurpose.Consent_Category__c,
                    conEmail.EmailAddress
                  );

                  sourceSpecificcontactPointConsentsToInsert.add(consent);
                }
              } else {
                ContactPointConsent consent = createSourceSpecificContactPointEmailConsent(
                  dataPurpose.Id,
                  conEmail.Id,
                  dataPurpose.LegalBasis.Source,
                  dataPurpose.Consent_Category__c,
                  conEmail.EmailAddress
                );

                sourceSpecificcontactPointConsentsToInsert.add(consent);
              }
            }
          }
        }
      }
    }
  }

  // Method to create Source Specific Contact Point Phone Consent

  public static ContactPointConsent createSourceSpecificContactPointPhoneConsent(
    Id dataPurposeId,
    Id conPhoneId,
    String captureSource,
    String category,
    String telePhoneNum
  ) {
    ContactPointConsent consent = new ContactPointConsent();
    consent.Name = telePhoneNum + ' ' + category;
    consent.DataUsePurposeId = dataPurposeId;
    consent.ContactPointId = conPhoneId;
    consent.CaptureSource = captureSource;
    consent.CaptureContactPointType = 'Phone';
    consent.PrivacyConsentStatus = 'NotSeen';
    consent.CaptureDate = System.now();
    consent.EffectiveFrom = System.now();

    return consent;
  }

  // Method to create Source Specific Contact Point Email Consent

  public static ContactPointConsent createSourceSpecificContactPointEmailConsent(
    Id dataPurposeId,
    Id conEmailId,
    String captureSource,
    String category,
    String emailAddress
  ) {
    ContactPointConsent consent = new ContactPointConsent();
    consent.Name = emailAddress + ' ' + category;
    consent.DataUsePurposeId = dataPurposeId;
    consent.ContactPointId = conEmailId;
    consent.CaptureSource = captureSource;
    consent.CaptureContactPointType = 'Email';
    consent.PrivacyConsentStatus = 'NotSeen';
    consent.CaptureDate = System.now();
    consent.EffectiveFrom = System.now();

    return consent;
  }

  // Method to create Opt In/Opt Out Contact Point Phone Consent

  public static ContactPointConsent createOptInOptOutContactPointPhoneConsent(
    Id dataPurposeId,
    Id conPhoneId,
    String category,
    String telePhoneNum,
    DateTime mrdt
  ) {
    ContactPointConsent consent = new ContactPointConsent();
    consent.Name = telePhoneNum + ' ' + category;
    consent.DataUsePurposeId = dataPurposeId;
    consent.ContactPointId = conPhoneId;
    consent.CaptureSource = System.Label.CEMCI_Consent_Capture_Source;
    consent.CaptureContactPointType = 'Phone';
    consent.PrivacyConsentStatus = 'Seen';
    consent.CaptureDate = System.now();
    consent.EffectiveFrom = System.now();
    consent.Member_Responded_Datetime__c = mrdt;

    return consent;
  }

  // Method to create Opt In/Opt Out Contact Point Email Consent

  public static ContactPointConsent createOptInOptOutContactPointEmailConsent(
    Id dataPurposeId,
    Id conEmailId,
    String category,
    String emailAddress,
    DateTime mrdt
  ) {
    ContactPointConsent consent = new ContactPointConsent();
    consent.Name = emailAddress + ' ' + category;
    consent.DataUsePurposeId = dataPurposeId;
    consent.ContactPointId = conEmailId;
    consent.CaptureSource = System.Label.CEMCI_Consent_Capture_Source;
    consent.CaptureContactPointType = 'Email';
    consent.PrivacyConsentStatus = 'Seen';
    consent.CaptureDate = System.now();
    consent.EffectiveFrom = System.now();
    consent.Member_Responded_Datetime__c = mrdt;

    return consent;
  }
}