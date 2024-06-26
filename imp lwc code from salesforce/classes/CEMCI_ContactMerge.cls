public with sharing class CEMCI_ContactMerge {
  private List<Sobject> recordsForProcessing;
  private Map<String, DateTime> contactEmailToInitialInteractionDate = new Map<String, DateTime>();
  private Map<String, DateTime> contactEmailToLastInteractionDate = new Map<String, DateTime>();
  private Map<String, String> contactEmailToOriginalLeadSource = new Map<String, String>();
  private List<Contact> contactsProcessedBasedOnConfidential = new List<Contact>();
  private Map<String, Contact> winningRecordForTheContact = new Map<String, Contact>();
  private Map<Id, List<Contact>> winningRecordWithDuplicateContacts = new Map<Id, List<Contact>>();
  private Map<Contact, List<Contact>> winningRecordWithDuplicateContForBatch = new Map<Contact, List<Contact>>();
  private List<Contact> duplicateContactsForComparing = new List<Contact>();
  private String query;

  public CEMCI_ContactMerge(List<Sobject> recordsForProcessing) {
    this.recordsForProcessing = recordsForProcessing;
  }

  public void ProcessRecordsBasedOnDuplicateContacts() {
    Map<String, Contact> recordsWithSameEmail = new Map<String, Contact>();
    Map<String, List<Contact>> duplicatesContactByEmail = new Map<String, List<Contact>>();
    List<Contact> duplicateContactIds = new List<Contact>();
    Id recTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('WDR Candidate').getRecordTypeId();
    Confidential_WD_Candidate_Fields__mdt batchSetting = [
      SELECT Custom_Soql__c
      FROM Confidential_WD_Candidate_Fields__mdt
      WHERE DeveloperName = 'Cemci_ContactMerge'
    ];
    query = batchSetting.Custom_Soql__c;
    Set<String> sameEmail;
    //Maintaining Contacts With Same Email Which are Updated In the Current transaction
    for (SObject record : recordsForProcessing) {
      if (record.getSObjectType() == Contact.sObjectType) {
        recordsWithSameEmail.put((String) record.get('email'), (Contact) record);
      }
    }
    /*We are Adding the contacts in to a list based on the Following Rules
        1)When the Email of the Contact was updated and it was Confidential and if there was a duplicate Contacts which are Confidential then we process those contacts For merge.
        2)When the Email of the Contact was updated and it Was Non-Confidential and if there was a duplicate Contacts Which are Non-Confidential then we Process those contacts For merge. 
        3)When the Email of the Contact was update and it was Confidential  and if there are duplicates which  is non-confidential or viceversa then we don't process those contacts For merge.
        */
    sameEmail = recordsWithSameEmail.keyset();
    for (Contact con : Database.query(query + ' where email in :sameEmail and RecordTypeId=:recTypeId')) {
      if (con.Confidential__c == recordsWithSameEmail.get(con.Email).Confidential__c) {
        duplicateContactIds.add(con);
        if (duplicatesContactByEmail.containsKey(con.Email)) {
          duplicatesContactByEmail.get(con.Email).add(con);
        } else {
          duplicatesContactByEmail.put(con.Email, new List<Contact>{ con });
        }
      }
    }
    for (contact con : duplicateContactIds) {
      if (duplicatesContactByEmail.get(con.Email).size() > 1) {
        contactsProcessedBasedOnConfidential.add(con);
      }
    }
  }

  public void processMasterRecordWithDuplicates() {
    /* If We have a Duplicate Contacts For the corresponding Contacts email Which are Updated in current Transaction
     Then Only We will process those contacts for merge*/
    if (contactsProcessedBasedOnConfidential.size() > 0) {
      for (Contact con : [
        SELECT email, Initial_Interaction_Date__c
        FROM Contact
        WHERE Id IN :contactsProcessedBasedOnConfidential AND Initial_Interaction_Date__c != NULL
        ORDER BY Initial_Interaction_Date__c ASC
      ]) {
        if (!contactEmailToInitialInteractionDate.containsKey(con.Email))
          contactEmailToInitialInteractionDate.put(con.email, con.Initial_Interaction_Date__c);
      }

      for (Contact con : [
        SELECT email, Last_Interaction_Date__c
        FROM Contact
        WHERE Id IN :contactsProcessedBasedOnConfidential AND Last_Interaction_Date__c != NULL
        ORDER BY Last_Interaction_Date__c DESC
      ]) {
        if (!contactEmailToLastInteractionDate.containsKey(con.Email))
          contactEmailToLastInteractionDate.put(con.Email, con.Last_Interaction_Date__c);
      }

      for (Contact con : [
        SELECT email, Original_Lead_Source__c
        FROM Contact
        WHERE Id IN :contactsProcessedBasedOnConfidential AND Original_Lead_Source__c != NULL
        ORDER BY createdDate ASC
      ]) {
        if (!contactEmailToOriginalLeadSource.containsKey(con.Email))
          contactEmailToOriginalLeadSource.put(con.Email, con.Original_Lead_Source__c);
      }

      //winning Record For the Contacts that need to be processed based on the Most recently Updated Application.
      for (
        contact con : Database.query(
          query +
          ' WHERE Id In :contactsProcessedBasedOnConfidential order by MRU_App__r.LAST_WD_Update__c DESC NULLS LAST'
        )
      ) {
        if (!winningRecordForTheContact.containsKey(con.Email)) {
          winningRecordForTheContact.put(con.Email, con);
        }
      }
      /* For Merge We can only merge three records  one master Record and two duplicates records so here we are Placing it in the map with masterrecord and
       there Two duplicate Records*/

      for (contact con : contactsProcessedBasedOnConfidential) {
        contact masterRecordContact = winningRecordForTheContact.get(con.Email);
        if (con.Id != masterRecordContact.id) {
          if (winningRecordWithDuplicateContacts.containsKey(masterRecordContact.Id)) {
            if (winningRecordWithDuplicateContacts.get(masterRecordContact.id).size() < 2) {
              winningRecordWithDuplicateContacts.get(masterRecordContact.id).add(con);
              duplicateContactsForComparing.add(con);
            }
          } else {
            duplicateContactsForComparing.add(con);
            winningRecordWithDuplicateContacts.put(masterRecordContact.id, new List<contact>{ con });
          }
        }
      }

      updateMasterRecordValuesWithDuplicates();
      mergeContactsWithDuplicates();
    }
  }

  private void updateMasterRecordValuesWithDuplicates() {
    for (Contact duplicateContact : duplicateContactsForComparing) {
      contact winningContact = winningRecordForTheContact.get(duplicateContact.Email);

      if (winningContact.Email == duplicateContact.Email) {
        /*Field merge rule: True value on any of the records should update the Master Record to True*/
        for (Schema.FieldSetMember f : SObjectType.Contact.fieldSets.CEMCI_ContactMergeRules.getFields()) {
          if (f.getType() == Schema.DisplayType.BOOLEAN) {
            if (winningContact.get(f.getFieldPath()) == true || duplicateContact.get(f.getFieldPath()) == true) {
              winningContact.put(f.getFieldPath(), true);
            }
          } else {
            if (winningContact.get(f.getFieldPath()) == null) {
              winningContact.put(f.getFieldPath(), duplicateContact.get(f.getFieldPath()));
            }
          }
        }
        /*Field merge rule: Always keep oldest date*/
        winningContact.Initial_Interaction_Date__c = contactEmailToInitialInteractionDate.get(duplicateContact.email);
        /*Field merge rule: Always keep newest date*/
        winningContact.Last_Interaction_Date__c = contactEmailToLastInteractionDate.get(duplicateContact.email);
        /*Field merge rule: Always keep the value from the oldest record (not blank)*/
        winningContact.Original_Lead_Source__c = contactEmailToOriginalLeadSource.get(duplicateContact.email);
      }
    }
  }
  private void mergeContactsWithDuplicates() {
    Database.MergeResult[] results = new List<Database.MergeResult>{};
    Set<Id> mergeContactIds = new Set<Id>();
    if (!winningRecordWithDuplicateContacts.isEmpty()) {
      try {
        for (Contact winningContact : winningRecordForTheContact.Values()) {
          List<Contact> duplicateContacts = winningRecordWithDuplicateContacts.get(winningContact.Id);
          CEMCI_Settings__c cs = CEMCI_Settings__c.getOrgDefaults();
          if (
            Limits.getQueries() <= cs.Auto_Merge_Lead_to_Lead_Limits__c * Limits.getLimitQueries() &&
            Limits.getDMLStatements() <= cs.Auto_Merge_Lead_to_Lead_Limits__c * Limits.getLimitDMLStatements()
          ) {
            winningContact = populateValuesonWinningContact(winningContact, duplicateContacts);
            results.addall(CEMCI_LeadsHelper.mergeContactToContact(winningContact, duplicateContacts));
          } else {
            winningRecordWithDuplicateContForBatch.put(winningContact, duplicateContacts);
          }
        }
      } catch (Exception e) {
        PF_Logger.log(
          'CEMCI',
          'ERROR',
          e.getMessage(),
          e.getTypeName(),
          e.getLineNumber() +
          ' Error during auto-merge Contact to Contact ' +
          ' UserId ' +
          UserInfo.getUserId(),
          'CEMCI_ContactMerge'
        );
      }

      if (!winningRecordWithDuplicateContForBatch.isEmpty() && !System.isBatch()) {
        CEMCI_ContactMergeBatch cntmrgeBtch = new CEMCI_ContactMergeBatch(winningRecordWithDuplicateContForBatch);
        Database.executeBatch(cntmrgeBtch);
      }
    }
    if (!results.isEmpty()) {
      for (Database.MergeResult res : results) {
        if (res.isSuccess()) {
          mergeContactIds.add(res.getId());
        } else {
          for (Database.Error err : res.getErrors()) {
            PF_Logger.log(
              'CEMCI',
              'ERROR',
              err.getMessage(),
              ' Error during auto-merge Contact to Contact ',
              ' UserId ' + UserInfo.getUserId(),
              'CEMCI_Contacts'
            );
          }
        }
      }
    }
    if (!PF_Logger.logs.isEmpty()) {
      PF_Logger.createLogs(PF_Logger.logs);
    }
    if (!mergeContactIds.isEmpty()) {
      WDR_Util.updateApplicationFields(mergeContactIds);
    }
  }

  public Contact populateValuesonWinningContact(Contact masterContact, List<Contact> duplicateContacts) {
    if (!masterContact.URM__c) {
      for (Contact cc : duplicateContacts) {
        if (cc.URM__c)
          masterContact.URM__c = true;
      }
    }

    if (!masterContact.URG__c) {
      for (Contact cc : duplicateContacts) {
        if (cc.URG__c)
          masterContact.URG__c = true;
      }
    }
    return masterContact;
  }
}