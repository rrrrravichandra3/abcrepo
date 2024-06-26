public with sharing class GDPR_Compliance_Batch implements Database.Batchable<SObject>, Schedulable {
  // instance member to retain state across transactions
  public Integer recordsProcessed = 0;
  private Confidential_WD_Candidate_Fields__mdt batchSettingContact = [
    SELECT Custom_Soql__c
    FROM Confidential_WD_Candidate_Fields__mdt
    WHERE DeveloperName = 'CEMCI_GDPR_Expire_Contact'
  ];

  private Confidential_WD_Candidate_Fields__mdt batchSettingLead = [
    SELECT Custom_Soql__c
    FROM Confidential_WD_Candidate_Fields__mdt
    WHERE DeveloperName = 'CEMCI_GDPR_Expire_Lead'
  ];

  private String leadOrContact;

  public GDPR_Compliance_Batch(String leadOrCont) {
    leadOrContact = leadOrCont;
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    Id rtId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('WDR_Candidate').getRecordTypeId();
    PF_Logger.log('CEMCI', 'INFO', null, null, 'RecordType::' + rtId, 'GDPR_Compliance_Batch');

    String contactQuery = batchSettingContact.Custom_Soql__c + ' and RecordTypeId= :rtId';
    String leadQuery = batchSettingLead.Custom_Soql__c;

    if (leadOrContact == 'Contact') {
      return Database.getQueryLocator(contactQuery);
    } else {
      return Database.getQueryLocator(leadQuery);
    }
  }

  public void execute(Database.BatchableContext bc, List<SObject> expiryCandidateList) {
    Set<Id> individualids = new Set<Id>();
    List<Contact> contactIndividualidList = new List<Contact>();
    List<Lead> leadIndividualidList = new List<Lead>();

    for (SObject sobj : expiryCandidateList) {
      if (sobj.getSObjectType().getDescribe().getName() == 'Lead') {
        leadIndividualidList.add((Lead) sobj);
      } else {
        contactIndividualidList.add((Contact) sobj);
      }
    }
    PF_Logger.log(
      'CEMCI',
      'INFO',
      null,
      null,
      'GDPR - ContactList::' +
      contactIndividualidList.size() +
      '  ::: LeadList ::: ' +
      leadIndividualidList.size(),
      'CEMCI_GDPR_Batch'
    );
    for (Contact contactid : contactIndividualidList) {
      contactid.Marketing_Opt_In__c = contactid.Marketing_Opt_In__c == 'Opt In' ? null : contactid.Marketing_Opt_In__c;
      contactid.Recruiting_Opt_In__c = contactid.Recruiting_Opt_In__c == 'Opt In'
        ? null
        : contactid.Recruiting_Opt_In__c;
      individualids.add(contactid.individualid);
    }
    for (Lead leadId : leadIndividualidList) {
      leadId.Marketing_Opt_In__c = leadId.Marketing_Opt_In__c == 'Opt In' ? null : leadId.Marketing_Opt_In__c;
      leadId.Recruiting_Opt_In__c = leadId.Recruiting_Opt_In__c == 'Opt In' ? null : leadId.Recruiting_Opt_In__c;
      individualids.add(leadId.individualid);
    }
    PF_Logger.log('CEMCI', 'INFO', null, null, ' GDPR Individualids ::: ' + individualids, 'CEMCI_GDPR_Batch');
    //Remove Consent Point Consent
    removeContactPointConsent(individualids);
    removeAuthorizationFormConsent(individualids);
    if (contactIndividualidList != null & contactIndividualidList.size() > 0) {
      updateRecordsinDatabase(contactIndividualidList);
    }
    if (leadIndividualidList != null & leadIndividualidList.size() > 0) {
      updateRecordsinDatabase(leadIndividualidList);
    }
    recordsProcessed = leadIndividualidList.size() + contactIndividualidList.size();
    logErrors();
    PF_Logger.log('CEMCI', 'INFO', null, null, 'GDPR Batch Sucess', 'CEMCI_GDPR_Batch');
  }

  public void execute(SchedulableContext sc) {
    Integer batchSize = WDR_Util.getBatchSizeforWDRBatch('CEMCI_GDPR_Compliance_Batch');
    PF_Logger.log('CEMCI', 'INFO', null, null, 'CEMCI_GDPR_Compliance_Batch Size ' + batchSize, 'CEMCI_GDPR_Batch');
    Database.executeBatch(this, batchSize);
  }

  public void removeContactPointConsent(Set<Id> individualids) {
    Map<Id, ContactPointEmail> cPEmailConsents = new Map<Id, ContactPointEmail>(
      [
        SELECT
          Id,
          (
            SELECT Id, ContactPointId
            FROM ContactPointConsents
            WHERE DataUsePurpose.Opt_In__c IN ('Opt In') AND (EffectiveTo = NULL OR EffectiveTo > TODAY)
          )
        FROM ContactPointEmail
        WHERE ParentId IN :individualids
      ]
    );

    Map<Id, ContactPointPhone> cPPhoneConsents = new Map<Id, ContactPointPhone>(
      [
        SELECT
          Id,
          (
            SELECT Id, ContactPointId
            FROM ContactPointConsents
            WHERE DataUsePurpose.Opt_In__c IN ('Opt In') AND (EffectiveTo = NULL OR EffectiveTo > TODAY)
          )
        FROM ContactPointPhone
        WHERE ParentId IN :individualids
      ]
    );

    List<ContactPointConsent> cpConsentrecordsToUpdate = new List<ContactPointConsent>();
    for (Id cpeKey : cPEmailConsents.keySet()) {
      for (ContactPointConsent cpeConsent : cPEmailConsents.get(cpeKey).ContactPointConsents) {
        if (cpeConsent != null) {
          cpeConsent.EffectiveTo = System.now();
          cpConsentrecordsToUpdate.add(cpeConsent);
        }
      }
    }
    for (Id cppKey : cPPhoneConsents.keySet()) {
      for (ContactPointConsent cpConsent : cPPhoneConsents.get(cppKey).ContactPointConsents) {
        if (cpConsent != null) {
          cpConsent.EffectiveTo = System.now();
          cpConsentrecordsToUpdate.add(cpConsent);
        }
      }
    }
    PF_Logger.log(
      'CEMCI',
      'INFO',
      null,
      null,
      'GDPR Consent Update Size ::' +
      cpConsentrecordsToUpdate.size() +
      ' ::: List' +
      cpConsentrecordsToUpdate,
      'CEMCI_GDPR_Batch'
    );

    if (cpConsentrecordsToUpdate.size() > 0) {
      updateRecordsinDatabase(cpConsentrecordsToUpdate);
    }
  }

  private static void updateRecordsinDatabase(List<sObject> recordsToUpdate) {
    Database.SaveResult[] sObjectUpdateResult = Database.update(recordsToUpdate, false);

    for (Integer i = 0; i < sObjectUpdateResult.size(); i++) {
      Database.SaveResult s = sObjectUpdateResult[i];
      if (!s.isSuccess()) {
        Id recordId = recordsToUpdate[i].Id;
        String objectAPIName = recordId.getSObjectType().getDescribe().getName();
        PF_Logger.log(
          'CEMCI',
          'ERROR',
          null,
          null,
          'Error during  update on ' +
          objectAPIName +
          ' with RecordId ' +
          recordId +
          ' with Error :: ' +
          String.valueOf(s.getErrors()),
          'CEMCI_GDPR_Batch'
        );
      }
    }
  }

  public void finish(Database.BatchableContext bc) {
    PF_Logger.log('CEMCI', 'INFO', null, null, recordsProcessed + ' GDPR records processed !', 'CEMCI_GDPR_Batch');
    Integer leadBatchSize = WDR_Util.getBatchSizeforWDRBatch('CEMCI_GDPR_Compliance_Batch');

    if (leadOrContact == 'Contact') {
      Id batchId = Database.executeBatch(new GDPR_Compliance_Batch('Lead'), leadBatchSize);
    }
  }

  public void logErrors() {
    if (!PF_Logger.logs.isEmpty()) {
      PF_Logger.createLogs(PF_Logger.logs);
    }
  }

  public void removeAuthorizationFormConsent(Set<Id> individualids) {
    List<AuthorizationFormConsent> authconsentsList = new List<AuthorizationFormConsent>(
      [
        SELECT ConsentGiverId
        FROM AuthorizationFormConsent
        WHERE ConsentGiverId IN :individualids AND IsActive__c = TRUE AND AuthorizationFormText.Opt_In_Out__c = 'Opt In'
      ]
    );
    List<AuthorizationFormConsent> updateAuthConsentsList = new List<AuthorizationFormConsent>();
    for (AuthorizationFormConsent authconsent : authconsentsList) {
      authconsent.IsActive__c = false;
      updateAuthConsentsList.add(authconsent);
    }
    PF_Logger.log(
      'CEMCI',
      'INFO',
      null,
      null,
      'Auth Consents List Size:: ' + updateAuthConsentsList.size(),
      'CEMCI_GDPR_Batch'
    );
    updateRecordsinDatabase(updateAuthConsentsList);
  }
}