public with sharing class CEMCI_DuplicateService {
  private static final CEMCI_Settings__c cs = CEMCI_Settings__c.getOrgDefaults();
  private static final List<Schema.FieldSetMember> checkboxFieldList = SObjectType.Lead.fieldSets.CEMCILeadMergeCheckBoxes.getFields();
  private static final List<Schema.FieldSetMember> nonCheckboxFieldList = SObjectType.Lead.fieldSets.CEMCILeadMergeFieldSet.getFields();
  private static final Boolean IsCEMCIUser = FeatureManagement.checkPermission('CEMCI_Auto_Merge');
  String emailOrLinkedin;
  List<SObject> recordsToProcess = new List<SObject>();
  Map<String, SObject> recordMap = new Map<String, SObject>();
  Map<String, SObject> convertRecordMap = new Map<String, SObject>();
  Map<String, List<SObject>> mergeRecordMap = new Map<String, List<SObject>>();
  List<Lead> recordsToMarkComplete = new List<Lead>();
  String sObjType;

  public CEMCI_DuplicateService(List<sObject> recordsToProcess, String emailOrLinkedIn) {
    this.recordsToProcess = recordsToProcess;
    this.emailOrLinkedIn = emailOrLinkedIn;
  }

  public void findDuplicates() {
    if (!CEMCI_CheckGDPRRecursion.getExecutionVariable()) {
      if (IsCEMCIUser) {
        startProcessing();
      } else if (emailOrLinkedin == 'LinkedIn') {
        startProcessing();
      }
    }
  }

  public void startProcessing() {
    List<sObject> confidentialRecords = new List<sObject>();
    List<sObject> nonConfidentialRecords = new List<sObject>();
    try {
      if (!recordsToProcess.isEmpty()) {
        for (sObject record : recordsToProcess) {
          if (record.get('Confidential__c') != null) {
            Boolean confidential = (Boolean) record.get('Confidential__c');
            if (confidential) {
              confidentialRecords.add(record);
            } else {
              nonConfidentialRecords.add(record);
            }
          }
        }

        if (!confidentialRecords.isEmpty() && confidentialRecords.size() > 0) {
          System.debug('Processing Confidential Records');
          processRecords(confidentialRecords, true);
          mergeRecordMap.clear();
          convertRecordMap.clear();
        }
        if (!nonConfidentialRecords.isEmpty() && nonConfidentialRecords.size() > 0) {
          System.debug('Processing NON-Confidential Records');
          processRecords(nonConfidentialRecords, false);
        }
      }
    } catch (Exception e) {
      PF_Logger.log(
        'CEMCI',
        'ERROR',
        e.getMessage(),
        String.valueof(e.getStackTraceString()),
        ' Error during duplicate service execution ran with user ' + UserInfo.getUserId(),
        'CEMCI_DuplicateService'
      );
    }
  }

  public void processRecords(List<sObject> records, Boolean confidential) {
    List<sObject> duplicateRecords = new List<sObject>();
    List<String> keyList = new List<String>();
    List<sObject> existingContacts;
    List<sObject> existingLeads;
    String rtName = 'WDR_Candidate';
    String contactQueryStr, leadQueryStr;
    String leadToContactMapping = System.Label.CEMCI_Lead_to_Contact_Mapping;
    List<String> mergedLeadobjectFields = new List<String>();
    List<CEMCI_LinkedInMerge__e> linkedInMerges = new List<CEMCI_LinkedInMerge__e>();

    for (CEMCI_Merged_Lead_to_Lead_Field_Mapper__c lm : CEMCI_Merged_Lead_to_Lead_Field_Mapper__c.getall().values()) {
      mergedLeadobjectFields.add(lm.Merged_Lead_Field__c);
    }

    Boolean areContactFieldsUpdatable = PF_AccessibilityUtils.checkFLS(
      'Contact',
      PF_AccessibilityUtils.PermissionType.UPDATEABLE,
      leadToContactMapping.split(',')
    );
    Boolean areLeadFieldsUpdatable = PF_AccessibilityUtils.checkFLS(
      'Lead',
      PF_AccessibilityUtils.PermissionType.UPDATEABLE,
      new List<string>{
        'OwnerId',
        'Original_Lead_Source__c',
        'Initial_Interaction_Date__c',
        'Last_Interaction_Date__c'
      }
    );
    Boolean mergeLeadFieldsAccessible = PF_AccessibilityUtils.checkFLS(
      'Merged_Lead__c',
      PF_AccessibilityUtils.PermissionType.CREATEABLE,
      mergedLeadobjectFields
    );

    if (areContactFieldsUpdatable && areLeadFieldsUpdatable && mergeLeadFieldsAccessible) {
      for (sObject record : records) {
        sObjType = record.getSObjectType().getDescribe().getName();
        String fieldValue;
        if (emailOrLinkedin == 'Email') {
          fieldValue = String.valueOf(record.get('Email'));
          linkedInMerges.add(
            new CEMCI_LinkedInMerge__e(LinkedIn_Substring__c = String.valueOf(record.get('LinkedIn_Substring__c')))
          );
        } else {
          String linkedinValue = String.valueOf(record.get('LinkedIn_Substring__c'));
          if (String.isNotBlank(linkedinValue))
            fieldValue = linkedinValue;
        }
        if (String.isNotBlank(fieldValue) && !keyList.contains(fieldValue))
          keyList.add(fieldValue);

        recordMap.put(fieldValue, record);
      }

      if (emailOrLinkedin == 'Email') {
        contactQueryStr =
          'Select Id, Email, AccountId From Contact Where RecordType.DeveloperName = \'' +
          rtName +
          '\' And Email IN:keyList And Confidential__c =:confidential Order By Email';
        leadQueryStr = 'Select Id, Email,IndividualId From Lead Where IsConverted = false And Email IN:keyList And Confidential__c =:confidential Order By Email';
      } else {
        contactQueryStr =
          'Select Id, Email,LinkedIn_Profile_URL__c,LinkedIn_Substring__c, AccountId From Contact Where RecordType.DeveloperName = \'' +
          rtName +
          '\' And LinkedIn_Substring__c IN :keyList And Confidential__c =:confidential  Order By LinkedIn_Profile_URL__c';
        leadQueryStr = 'Select Id, Email,Linked_In_URL__c,LinkedIn_Substring__c,IndividualId From Lead Where IsConverted = false And LinkedIn_Substring__c IN :keyList And Confidential__c =:confidential Order By Linked_In_URL__c';
      }
      existingContacts = Database.query(contactQueryStr);
      existingLeads = Database.query(leadQueryStr);

      duplicateRecords.addAll(existingContacts);
      duplicateRecords.addAll(existingLeads);

      if (!duplicateRecords.isEmpty()) {
        for (sObject record : duplicateRecords) {
          sObjType = record.getSObjectType().getDescribe().getName();
          String keyValue, linkedin;
          if (emailOrLinkedin == 'Email')
            keyValue = String.valueOf(record.get('Email'));

          if (sObjType == 'Contact') {
            if (emailOrLinkedin != 'Email') {
              linkedin = String.valueOf(record.get('LinkedIn_Substring__c')); // change the variable
              keyValue = linkedin;
            }
            if (!convertRecordMap.containsKey(keyValue))
              convertRecordMap.put(keyValue, record);
          } else if (sObjType == 'Lead') {
            if (emailOrLinkedin != 'Email') {
              linkedin = String.valueOf(record.get('LinkedIn_Substring__c')); // change the variable
              keyValue = linkedin;
            }
            if (!mergeRecordMap.containsKey(keyValue))
              mergeRecordMap.put(keyValue, new List<sObject>{ record });
            else
              mergeRecordMap.get(keyValue).add(record);
          }
          //leadrecordMap.remove(keyValue);
        }

        mergeLeadsToContacts();
        mergeLeadsToLeads();
      }
      if (!linkedInMerges.isEmpty()) {
        List<Database.SaveResult> eventResults = EventBus.publish(linkedInMerges);
      }
      removeDeDupeFlag();
    } else
      PF_Logger.log(
        'CEMCI',
        'ERROR',
        'User does not have sufficient access on Contact, Lead or Merged Lead object fields',
        '',
        ' Error during Lead merge ' + UserInfo.getUserId(),
        ''
      );
    logErrors();
  }

  public void mergeLeadsToContacts() {
    List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
    Map<Id, Id> leadToIndividualMap = new Map<Id, Id>();

    if (!convertRecordMap.isEmpty()) {
      for (String key : convertRecordMap.keySet()) {
        Database.LeadConvert lc = new Database.LeadConvert();

        Lead ldRec = (Lead) recordMap.get(key);
        Contact matchedContact = (Contact) convertRecordMap.get(key);

        lc.setLeadId(ldRec.Id);
        if (String.valueOf(ldRec.Ownerid).substring(0, 3) == '00G')
          lc.setOwnerId(cs.CEMCI_Default_Lead_Owner__c);
        lc.setContactId(matchedContact.Id);
        lc.setAccountId(matchedContact.AccountId);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus(cs.Converted_Lead_Status__c);
        leadsToConvert.add(lc);

        if (String.isNotBlank(ldRec.IndividualId))
          leadToIndividualMap.put(ldRec.Id, ldRec.IndividualId);
      }

      if (!leadsToConvert.isEmpty()) {
        CEMCI_CheckGDPRRecursion.setExecutionVariable();
        if (!leadToIndividualMap.isEmpty())
          CEMCI_CheckGDPRRecursion.setleadToIndividualMap(leadToIndividualMap);
        Database.LeadConvertResult[] lcrList = CEMCI_LeadsHelper.convertRecords(leadsToConvert);
        for (Database.LeadConvertResult lcr : lcrList) {
          if (!lcr.isSuccess()) {
            for (Database.Error objErr : lcr.getErrors())
              PF_Logger.log(
                'CEMCI',
                'ERROR',
                objErr.getMessage(),
                String.valueof(objErr.getStatusCode()),
                ' Error during auto-merge leads to contact ' +
                lcr.getLeadId() +
                ' with UserId ' +
                UserInfo.getUserId() +
                ' in ' +
                emailOrLinkedin +
                ' context',
                'CEMCI_DuplicateService'
              );
          } else {
            recordsToMarkComplete.add(new Lead(Id = lcr.getLeadId(), Awaiting_Lead_De_duplication__c = false));
          }
        }
        CEMCI_Leads.assignConvertedLeadValuesToContact(lcrList);
      }
    }
  }

  public void mergeLeadsToLeads() {
    Map<Lead, List<Lead>> winningLeadToDuplicatesMap = new Map<Lead, List<Lead>>();
    Database.MergeResult[] results = new List<Database.MergeResult>{};
    Map<String, Id> winningLeadMap = new Map<String, Id>();
    List<Lead> leadRecordsForMerging = new List<Lead>();
    Map<Id, Lead> winningRecord = new Map<Id, Lead>();
    Map<String, List<Lead>> dupeRecordMap = new Map<String, List<Lead>>();
    Map<Id, String> leadIdToKeyMap = new Map<Id, String>();
    Map<String, String> keyToOriginalLeadSourceMap = new Map<String, String>();
    List<Id> leadIds = new List<Id>();
    List<Merged_Lead__c> mergedLeadsList = new List<Merged_Lead__c>();
    String leadFields = '';
    List<String> tempIds = new List<String>();
    List<CEMCI_Lead_Merge__e> leadMergeEvents = new List<CEMCI_Lead_Merge__e>();

    for (CEMCI_Merged_Lead_to_Lead_Field_Mapper__c lm : CEMCI_Merged_Lead_to_Lead_Field_Mapper__c.getall().values()) {
      leadFields += lm.Lead_Field__c + ', ';
    }

    //existing
    if (!mergeRecordMap.isEmpty()) {
      for (String key : mergeRecordMap.keySet()) {
        for (sObject rec : mergeRecordMap.get(key)) {
          Id recId = (Id) rec.get('Id');
          leadIds.add(recId);
          leadIdToKeyMap.put(recId, key);
        }
      }
      //new
      //winning lead could be the record in transaction
      //hence include record in map
      for (String key : recordMap.keySet()) {
        Id recId = (Id) recordMap.get(key).get('Id');
        leadIds.add(recId);
        leadIdToKeyMap.put(recId, key);
      }

      /*Identifying winning master record (Rule-1): Lead record having recent activity in last six months and status as Completed*/
      for (Task relatedTask : [
        SELECT Whoid, LastModifiedDate
        FROM Task
        WHERE Status = 'Completed' AND LastModifiedDate = LAST_N_DAYS:180 AND WhoId IN :leadIds
        ORDER BY LastModifiedDate DESC
      ]) {
        //check for single winning lead for a given lead email (with Task)
        String keyValue = leadIdToKeyMap.get(relatedTask.WhoId);
        if (!winningLeadMap.containsKey(keyValue)) {
          winningLeadMap.put(keyValue, relatedTask.whoid);
        }
      }

      /*Identifying winning master record (Rule-2: in case of leads not complying to Rule-1): Lead record with recent lastmodified date*/
      //Current lead in service context will always be latest as the record that initiated this flow
      for (String key : mergeRecordMap.keySet()) {
        if (!winningLeadMap.containsKey(key))
          winningLeadMap.put(key, (Id) recordMap.get(key).get('Id'));
      }

      String queryStr = 'SELECT ';
      for (Schema.FieldSetMember f : checkboxFieldList)
        queryStr += f.getFieldPath() + ', ';
      for (Schema.FieldSetMember f : nonCheckboxFieldList)
        queryStr += f.getFieldPath() + ', ';
      queryStr += 'Id, email, Initial_Interaction_Date__c, Last_Interaction_Date__c,Original_Lead_Source__c,OwnerId,LinkedIn_Substring__c FROM Lead WHERE id IN : leadIds   Order By Email,CreatedDate ASC';

      for (Lead ldRec : Database.query(queryStr)) {
        String key;
        if (emailOrLinkedin == 'Email')
          key = ldRec.Email;
        else
          key = ldRec.LinkedIn_Substring__c;

        if (ldRec.Id == winningLeadMap.get(key))
          winningRecord.put(ldRec.Id, ldRec);
        else {
          //Database.merge can only merge 2 duplicate records to a master at max
          if (dupeRecordMap.containsKey(key) && dupeRecordMap.get(key).size() < 2) {
            dupeRecordMap.get(key).add(ldRec);
          } else if (!dupeRecordMap.containsKey(key))
            dupeRecordMap.put(key, new List<Lead>{ ldRec }); // done
        }

        if (!keyToOriginalLeadSourceMap.containsKey(key) && String.isNotBlank(ldRec.Original_Lead_Source__c))
          keyToOriginalLeadSourceMap.put(key, ldRec.Original_Lead_Source__c);
      }
      for (String key : winningLeadMap.keySet()) {
        Lead winningLead = winningRecord.get(winningLeadMap.get(key));
        if (dupeRecordMap.containsKey(key)) {
          for (Lead dupeLead : dupeRecordMap.get(key)) {
            /*Field merge rule: True value on any of the records should update the Master Record to True*/
            for (Schema.FieldSetMember f : checkboxFieldList) {
              if (dupeLead.get(f.getFieldPath()) == true || winningLead.get(f.getFieldPath()) == true)
                winningLead.put(f.getFieldPath(), true);
            }

            /*Field merge rule: Use master record, but do not replace with a blank value*/
            for (Schema.FieldSetMember f : nonCheckboxFieldList) {
              if (winningLead.get(f.getFieldPath()) == null)
                winningLead.put(f.getFieldPath(), dupeLead.get(f.getFieldPath()));
            }

            if (winningLead.email == null && dupeLead.email != null)
              winningLead.email = dupeLead.email;

            /*Field merge rule: Always keep oldest date*/
            if (
              winningLead.Initial_Interaction_Date__c != null &&
              dupeLead.Initial_Interaction_Date__c != null &&
              winningLead.Initial_Interaction_Date__c > dupeLead.Initial_Interaction_Date__c
            )
              winningLead.Initial_Interaction_Date__c = dupeLead.Initial_Interaction_Date__c;

            /*Field merge rule: Always keep newest date*/
            if (
              winningLead.Last_Interaction_Date__c != null &&
              dupeLead.Last_Interaction_Date__c != null &&
              winningLead.Last_Interaction_Date__c < dupeLead.Last_Interaction_Date__c
            )
              winningLead.Last_Interaction_Date__c = dupeLead.Last_Interaction_Date__c;

            /*Field merge rule: Update Company if value null or [Not Provided]*/
            if (
              (winningLead.company == null ||
              (winningLead.company != null &&
              winningLead.company == System.Label.CEMCI_Lead_Company_Not_Provided_Label)) &&
              (dupeLead.company != null &&
              dupeLead.company != System.Label.CEMCI_Lead_Company_Not_Provided_Label)
            )
              winningLead.company = dupeLead.company;

            /*Field merge rule: Always keep value from oldest record (not blank)*/
            winningLead.Original_Lead_Source__c = keyToOriginalLeadSourceMap.get(key);
          }
          winningLeadToDuplicatesMap.put(winningLead, dupeRecordMap.get(key));
        } else {
          //If there was no matching records in the dupemap update the checkbox to false
          recordsToMarkComplete.add(new Lead(Id = winningLead.Id, Awaiting_Lead_De_duplication__c = false));
        }
      }

      for (Lead winnerLead : winningLeadToDuplicatesMap.keySet()) {
        if (
          Limits.getQueries() <= cs.Auto_Merge_Lead_to_Lead_Limits__c * Limits.getLimitQueries() &&
          Limits.getDMLStatements() <= cs.Auto_Merge_Lead_to_Lead_Limits__c * Limits.getLimitDMLStatements()
        )
          results.addall(CEMCI_LeadsHelper.mergeLeadToLead(winnerLead, winningLeadToDuplicatesMap.get(winnerLead)));
        else {
          PF_Logger.log(
            'CEMCI',
            'INFO',
            '',
            '',
            ' Close to governor limits for current transaction. Lead merge suspended ',
            'CEMCI_DuplicateService'
          );
          break;
        }
      }

      for (Database.MergeResult res : results) {
        String id = res.getId();
        tempIds.addAll(res.getMergedRecordIds());
        for (String s : tempIds) {
          leadMergeEvents.add(new CEMCI_Lead_Merge__e(Winning_Lead_Id__c = id, Loosing_Lead_Id__c = s));
        }
      }

      String queryy = 'Select ' + leadFields + ' id from lead where id in: tempIds all rows';
      List<Lead> mergedLeadList = Database.query(queryy);
      tempIds.clear();
      for (Database.MergeResult res : results) {
        recordsToMarkComplete.add(new Lead(Id = res.getId(), Awaiting_Lead_De_duplication__c = false));
        for (Lead mrgdLead : mergedLeadList) {
          Id ldId = mrgdLead.id;
          recordsToMarkComplete.add(new Lead(Id = ldId, Awaiting_Lead_De_duplication__c = false));

          if (res.getMergedRecordIds().contains(ldId)) {
            Merged_Lead__c ml = new Merged_Lead__c();
            for (
              CEMCI_Merged_Lead_to_Lead_Field_Mapper__c fieldMap : CEMCI_Merged_Lead_to_Lead_Field_Mapper__c.getall()
                .values()
            ) {
              if (fieldMap.Lead_Field__c != 'OwnerId')
                ml.put(fieldMap.Merged_Lead_Field__c, mrgdLead.get(fieldMap.Lead_Field__c));
              else if (
                fieldMap.Lead_Field__c == 'OwnerId' &&
                string.valueOf(mrgdLead.get(fieldMap.Lead_Field__c)).startsWith('005')
              ) {
                ml.put(fieldMap.Merged_Lead_Field__c, mrgdLead.get(fieldMap.Lead_Field__c));
              }
            }
            ml.Lead__c = res.getId();
            mergedLeadsList.add(ml);
          }
        }
      }
      insert mergedLeadsList;
    }
    EventBus.publish(leadMergeEvents);
  }
  public void removeDeDupeFlag() {
    //Generate a set of leads to ensure that there accidentally a duplicate lead
    Set<Lead> uniqueLeads = new Set<Lead>();
    uniqueLeads.addAll(recordsToMarkComplete);
    List<Lead> leadsToUpdate = new List<Lead>();
    leadsToUpdate.addAll(uniqueLeads);
    CEMCI_CheckGDPRRecursion.setdoNotRunLeadTriggers();
    Database.SaveResult[] updateLeads = Database.update(leadsToUpdate, false);
  }

  public void logErrors() {
    if (!PF_Logger.logs.isEmpty()) {
      PF_Logger.createLogs(PF_Logger.logs);
    }
  }
}