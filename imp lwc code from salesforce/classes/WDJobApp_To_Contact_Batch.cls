global with sharing class WDJobApp_To_Contact_Batch implements Database.Batchable<sObject>, Database.RaisesPlatformEvents, Schedulable {
  private Confidential_WD_Candidate_Fields__mdt batchSetting = [
    SELECT List_of_Fields__c, Custom_Soql__c
    FROM Confidential_WD_Candidate_Fields__mdt
    WHERE DeveloperName = 'WDRJobApp'
  ];

  global database.queryLocator start(Database.BatchableContext BC) {
    Map<Id, AsyncApexJob> inProgressBatches = WDR_Util.checkForInProgressBatches(bc.getJobId());

    String query = batchSetting.Custom_Soql__c;
    if (inProgressBatches.size() > 0)
      query += ' Limit 0';

    return Database.getQueryLocator(query);
  }

  global void execute(SchedulableContext SC) {
    Integer batchSize = WDR_Util.getBatchSizeforWDRBatch('WDRJobApp');
    Database.executeBatch(this, batchSize);
  }

  global void execute(Database.BatchableContext BC, List<WDR_Application__c> WDJobapps) {
    Map<Id, WDR_Application__c> jobAppWithContactId = new Map<Id, WDR_Application__c>();
    Map<Id, contact> contactWithContactId = new Map<Id, contact>();
    List<contact> contactsForTheNewJobsForConsent = new List<contact>();
    List<WDR_Application__c> validJobApps = new List<WDR_Application__c>();
    Set<Id> Individuals = new Set<Id>();
    Set<Id> contactIds = new Set<Id>();
    List<contact> updatedContact;
    Map<Id, List<WDR_Application__c>> jobAppForContactId = new Map<Id, List<WDR_Application__c>>();

    //All New Job Apps Are Created will be Put in a Map with contactid. If Related Candidate does not have
    //Candidate Contact populated, Job app is removed from further processing
    for (WDR_Application__c jobapp : WDJobapps) {
      Id cId = jobapp.Candidate__r.Candidate_Contact__c;
      if (cId != null) {
        contactIds.add(cId);
        validJobApps.add(jobapp);
        if (!jobAppForContactId.containsKey(cId))
          jobAppForContactId.put(cId, new List<WDR_Application__c>{ jobapp });
        else
          jobAppForContactId.get(cId).add(jobapp);

        if (jobapp.is_New__c == true) {
          if (jobapp.Marketing_Opt_In__c != null) {
            if (!jobAppWithContactId.containsKey(cId))
              jobAppWithContactId.put(cId, jobapp);
          }
        }
      }
    }

    if (!validJobApps.isEmpty()) {
      String query = 'Select' + ' ' + batchSetting.List_of_Fields__c + ' ' + 'From Contact WHERE Id IN:contactIds';
      List<Contact> contactsBasedOnTheirJobApps = database.query(query);
      //This method will update the Lookup fields on the contact
      updatedContact = WDJobApp_To_Contact_BatchHandler.updateApplicationFields(
        contactsBasedOnTheirJobApps,
        jobAppWithContactId,
        validJobApps,
        contactIds,
        jobAppForContactId
      );
      Set<Id> authorzationFormIds = (new Map<Id, AuthorizationForm>(
          [SELECT Id FROM AuthorizationForm WHERE Source__c = 'Workday']
        )
        .keySet());
      for (Contact cont : contactsBasedOnTheirJobApps) {
        if (jobAppWithContactId.get(cont.id) != null) {
          contactsForTheNewJobsForConsent.add(cont);
          Individuals.add(cont.IndividualId);
        }
      }

      //This Method will Create the consents for the Job Application
      WDJobApp_To_Contact_BatchHandler.creatingAuthorizationConsentForJobAppLication(
        contactsForTheNewJobsForConsent,
        Individuals,
        authorzationFormIds,
        jobAppWithContactId
      );

      //This Method will update the Ready_to_Process__c and is_New fields to false
      WDJobApp_To_Contact_BatchHandler.postProcessingActions(validJobApps);
    }
  }

  global void finish(Database.BatchableContext BC) {
    List<User> updateUserList = [
      SELECT Id
      FROM User
      WHERE ProfileId = :CEMCI_Settings__c.getInstance().Account_Owner_Profile_Id__c AND UserRoleId = NULL
    ];
    if (updateUserList.size() > 0)
      System.enqueueJob(new CEMCI_AssignRoleToAccountOwner());

    if (WDR_Util.checkForInProgressBatches(bc.getJobId()).size() == 0) {
      Integer batchSize = WDR_Util.getBatchSizeforWDRBatch('WDComm_to_Task');
      Database.executeBatch(new WDCommunications_To_Task_Batch(), batchSize);
    }
  }
}