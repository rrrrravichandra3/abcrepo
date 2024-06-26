public with sharing class CEMCI_Contacts {
  public static List<Contact> newContacts;
  public static List<Contact> oldContacts;
  public static Map<Id, Contact> newContactMap;
  public static Map<Id, Contact> oldContactMap;

  //*****************************************************************************
  // Method to set IsValid LinkedIn URL Field
  //****************************************************************************/

  public static void setIsValidLinkedInURL() {
    String linkedInURL = System.Label.CEMCI_Valid_LinkedIn_URL;

    if (!String.isBlank(linkedInURL)) {
      for (Contact con : newContacts) {
        con.IsValid_LinkedIn_URL__c = false;

        if (con.LinkedIn_Profile_URL__c != null) {
          String inputURL = con.LinkedIn_Profile_URL__c;

          Pattern linkedInURLPattern = Pattern.compile(linkedInURL);

          Matcher inputURLMatcher = linkedInURLPattern.matcher(inputURL);

          con.IsValid_LinkedIn_URL__c = inputURLMatcher.matches();
        }
      }
    }
  }

  public static void createIndividualforContacts() {
    if (!CEMCI_CheckGDPRRecursion.getExecutionVariable()) {
      List<Contact> contactsForProcessing = new List<Contact>();
      List<Contact> contactsForIndividual = new List<Contact>();
      contactsForProcessing = isValidForGDPRProcessing();

      for (integer i = 0; i < contactsForProcessing.size(); i++) {
        if (contactsForProcessing[i].IndividualId == null)
          contactsForIndividual.add(contactsForProcessing[i]);
      }

      if (contactsForIndividual.size() > 0)
        newContacts = CEMCI_GDPR_DispatcherClass.createIndividualRecordsForsObject(contactsForIndividual, 'Contact');
    }
  }
  /**
   * @description Method to Check whether  email Is updated Or not If so call the mergeDuplicateContacts.
   **/
  public static void processRecordsForContactMerge() {
    List<Contact> contactWithUpdatedEmail = new List<Contact>();
    Set<Id> contactIds = new Set<Id>();
    Id recTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('WDR Candidate').getRecordTypeId();
    for (Contact con : newContacts) {
      if (
        con.RecordTypeId == recTypeId &&
        con.Email != null &&
        (oldContactMap != null &&
        oldContactMap.get(con.Id) != null &&
        oldContactMap.get(con.Id).Email != con.Email)
      ) {
        contactIds.add(con.id);
        contactWithUpdatedEmail.add(con);
      }
    }
    if (contactWithUpdatedEmail.size() > 0) {
      //Contact Merge
      CEMCI_ContactMerge cntMerge = new CEMCI_ContactMerge(contactWithUpdatedEmail);
      cntMerge.ProcessRecordsBasedOnDuplicateContacts();
      cntMerge.processMasterRecordWithDuplicates();
      //Check for the Duplicate Lead and convert lead to contact
      WDR_Util.processContactsForLeadConvertion(contactIds);
    }
  }
  public static void createContactPointRecordsforContacts() {
    if (!CEMCI_CheckGDPRRecursion.getExecutionVariable()) {
      List<Contact> contactsForProcessing = new List<Contact>();
      List<Contact> contactsForContactPoint = new List<Contact>();

      contactsForProcessing = isValidForGDPRProcessing();

      for (integer i = 0; i < contactsForProcessing.size(); i++) {
        if (contactsForProcessing[i].IndividualId != null)
          contactsForContactPoint.add(contactsForProcessing[i]);
      }
      if (contactsForContactPoint.size() > 0) {
        CEMCI_GDPR_DispatcherClass.createContactPointRecordsForsObject(contactsForContactPoint);
      }
    }
  }
  public static List<Contact> isValidForGDPRProcessing() {
    List<Contact> contactsForProcessing = new List<Contact>();
    Id wdrContactRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
      .get('WDR_Candidate')
      .getRecordTypeId();

    for (Contact con : newContacts) {
      if (
        con.RecordTypeId == wdrContactRTId &&
        (con.Phone != null ||
        con.Email != null ||
        (con.Phone != null &&
        oldContactMap.get(con.Id).Phone != con.Phone) ||
        (con.Email != null &&
        oldContactMap.get(con.Id).Email != con.Email))
      )
        contactsForProcessing.add(con);
    }

    return contactsForProcessing;
  }
  public static void mergeGDPRRecordsforContacts() {
    if (!CEMCI_CheckGDPRRecursion.getExecutionVariable()) {
      List<Contact> contactsForProcessing = new List<Contact>();

      //when record is merged MasterRecordId field on Contact gets populated with Contact identified as master
      for (Contact conRec : oldContacts) {
        if (conRec.MasterRecordId != null) {
          contactsForProcessing.add(conRec);
        }
      }

      if (contactsForProcessing.size() > 0)
        CEMCI_GDPR_DispatcherClass.mergeGDPRRecordsForSObject(contactsForProcessing);
    }
  }

  public static void updateDisqualifiedContacts() {
    for (Contact cntct : newContacts) {
      if (cntct.Do_Not_Hire__c) {
        cntct.Status__c = 'Disqualified';
        cntct.Qualification_Details__c = 'Workday Do Not Hire';
      }
    }
  }

  public static void setConfidentialTextField() {
    for (Contact cont : newContacts) {
      cont.Confidential_Text__c = String.valueOf(cont.Confidential__c);
    }
  }

  /**
   * Method evaluates Marketing and Recruiting Opt in Fields to determine the setting of hasoptedoutofemail.
   */
  public static void setHardOptOut() {
    String optIn = 'Opt In';
    String optOut = 'Opt Out';

    for (Contact c : newContacts) {
      if (c.Recruiting_Opt_In__c == optOut && c.Marketing_Opt_In__c == optOut && c.HasOptedOutOfEmail == false) {
        c.HasOptedOutOfEmail = true;
      } else if ((c.Recruiting_Opt_In__c == optIn || c.Marketing_Opt_In__c == optIn) && c.HasOptedOutOfEmail == true) {
        c.HasOptedOutOfEmail = false;
      }
    }
  }

  /**
   * Method will set Owner for Contact based on Lead upon conversion.
   */
  public static void setContactOwneronLeadConvert() {
    for (Contact c : newContacts) {
      if (c.Lead_OwnerId_at_Conversion__c != null) {
        Id ownerId = CEMCI_Util.setLeadOwnerValidforContactOwner(c.Lead_OwnerId_at_Conversion__c);
        if (ownerId != null) {
          c.OwnerId = ownerId;
        }
      }
    }
  }
  /**
   * Sets the linkedIn Substring value on Contact for unique matching between leads/contact
   */
  public static void setLinkedInSubstring() {
    String linkedInURL = System.Label.CEMCI_Valid_LinkedIn_URL;

    for (Contact c : newContacts) {
      if (c.LinkedIn_Profile_URL__c != null) {
        c.LinkedIn_Substring__c = CEMCI_Util.generateLinkedInSubstring(c.LinkedIn_Profile_URL__c);
      }
    }
  }

  public static void expireContactConsentForOldEmailPhone() {
    List<String> emailPhoneListToExpireConsent = new List<String>();
    // List<String> phoneListToExpireConsent= new List<String>();

    for (Id conId : newContactMap.keySet()) {
      if (newContactMap.get(conId).Email != oldContactMap.get(conId).Email)
        emailPhoneListToExpireConsent.add(oldContactMap.get(conId).Email);

      if (newContactMap.get(conId).Phone != oldContactMap.get(conId).Phone)
        emailPhoneListToExpireConsent.add(oldContactMap.get(conId).Phone);
    }

    if (emailPhoneListToExpireConsent != null && !emailPhoneListToExpireConsent.isEmpty()) {
      CEMCI_Util.expireConsentsForOldEmailPhone(emailPhoneListToExpireConsent);
    }
  }
}