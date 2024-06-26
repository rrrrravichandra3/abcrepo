/**
 * @description       :
 * @author            : Urvish Shah (ushah)
 * @group             :
 * @last modified on  : 08-26-2022
 * @last modified by  : Urvish Shah (ushah)
 **/
public with sharing class WDR_Util {
  static final Id accountOwnerProfileId = CEMCI_Settings__c.getInstance() != null
    ? CEMCI_Settings__c.getInstance().Account_Owner_Profile_Id__c
    : null;
  static final Integer accountOwnership = CEMCI_Settings__c.getInstance() != null
    ? Integer.valueOf(CEMCI_Settings__c.getInstance().Account_Ownership_Limit__c)
    : null;

  static List<User> ownerList;
  static List<User> allUsers;
  static Map<Id, Integer> accountOwnerToCountMap = new Map<Id, Integer>();
  Map<Id, Id> candidateToAccountMap = new Map<Id, Id>();
  Map<String, Set<ID>> candNametoIDMap = new Map<String, Set<ID>>();

  public static void populateOwnerList() {
    if (accountOwnerProfileId != null) {
      ownerList = [
        SELECT Id
        FROM User
        WHERE
          ProfileId = :accountOwnerProfileId
          AND isActive = TRUE
          AND Available_for_CEMCI_Account_Assignment__c = TRUE
      ];
      allUsers = [SELECT Id FROM User WHERE ProfileId = :accountOwnerProfileId];
    }
  }

  public static void populateCountMap() {
    if (ownerList != null && System.isBatch()) {
      for (AggregateResult ar : [
        SELECT count(Id) cnt, OwnerId
        FROM Account
        WHERE ownerid IN :ownerList
        GROUP BY OwnerId
      ]) {
        if (ar.get('cnt') != null)
          accountOwnerToCountMap.put((Id) ar.get('OwnerId'), Integer.valueOf(ar.get('cnt')));
        else
          accountOwnerToCountMap.put((Id) ar.get('OwnerId'), 0);
      }
    }
  }

  static {
    populateOwnerList();
    populateCountMap();
  }

  public Map<Id, Id> populateAccountonContact(List<WDR_Candidate__c> wdCandidates) {
    Set<String> accountWDI = new Set<String>();
    Set<String> accountName = new Set<String>();
    Set<Id> defaultAccCandIdSet = new Set<Id>();
    Set<String> createAccountSet = new Set<String>();
    Map<String, ID> accountWDItoIDMap = new Map<String, ID>();
    Map<String, ID> accountNametoIDMap = new Map<String, ID>();
    List<Account> candidateAccounts;

    //find matching Accounts
    for (WDR_Candidate__c candidate : wdCandidates) {
      if (candidate.WD_Company_WDI__c != null)
        accountWDI.add(candidate.WD_Company_WDI__c.tolowercase());
      if (candidate.Current_Company__c != null)
        accountName.add(candidate.Current_Company__c.tolowercase());

      if (candidate.WD_School_WDI__c != null)
        accountWDI.add(candidate.WD_School_WDI__c.tolowercase());
      if (candidate.Last_School_Attended__c != null)
        accountName.add(candidate.Last_School_Attended__c.tolowercase());
    }

    if (accountWDI.size() > 0 || accountName.size() > 0) {
      candidateAccounts = [
        SELECT Id, Name, WD_Account_WDI__c
        FROM Account
        WHERE WD_Account_WDI__c IN :accountWDI OR Name IN :accountName
      ];
    }

    if (candidateAccounts != null && candidateAccounts.size() > 0) {
      for (Account acc : candidateAccounts) {
        if (acc.WD_Account_WDI__c != null)
          accountWDItoIDMap.put(acc.WD_Account_WDI__c.tolowercase(), acc.Id);
        if (acc.Name != null)
          accountNametoIDMap.put(acc.Name.tolowercase(), acc.Id);
      }
    }

    //Account will be linked based on Current Company / School fields of Candidate.
    //Find a matching Account based on Company WDI on Candidate. If the Account does not exist, find a match
    //based on Company Name on Candidate. If there is no Account based on Company, repeat the same logic
    //using Last School Attended. If neither is successfull, create an Account with Company Name if exists, or
    //School name if exists. If both fields are blank, link the Contact to WDR Candidate Account.

    for (WDR_Candidate__c candidate : wdCandidates) {
      if (
        candidate.WD_Company_WDI__c != null &&
        accountWDItoIDMap != null &&
        accountWDItoIDMap.get(candidate.WD_Company_WDI__c.tolowercase()) != null
      )
        candidateToAccountMap.put(candidate.Id, accountWDItoIDMap.get(candidate.WD_Company_WDI__c.tolowercase()));
      else if (
        candidate.Current_Company__c != null &&
        accountNametoIDMap != null &&
        accountNametoIDMap.get(candidate.Current_Company__c.tolowercase()) != null
      )
        candidateToAccountMap.put(candidate.Id, accountNametoIDMap.get(candidate.Current_Company__c.tolowercase()));
      else if (candidate.Current_Company__c != null) {
        if (candNametoIDMap.containsKey(candidate.Current_Company__c.tolowercase())) {
          Set<Id> tempCandIdSet = candNametoIDMap.get(candidate.Current_Company__c.tolowercase());
          tempCandIdSet.add(candidate.Id);
          candNametoIDMap.put(candidate.Current_Company__c.tolowercase(), tempCandIdSet);
        } else {
          Set<Id> candIdSet = new Set<Id>();
          candIdSet.add(candidate.Id);
          candNametoIDMap.put(candidate.Current_Company__c.tolowercase(), candIdSet);
        }
        createAccountSet.add(candidate.Current_Company__c.tolowercase());
      } else if (
        candidate.WD_School_WDI__c != null &&
        accountWDItoIDMap != null &&
        accountWDItoIDMap.get(candidate.WD_School_WDI__c.tolowercase()) != null
      )
        candidateToAccountMap.put(candidate.Id, accountWDItoIDMap.get(candidate.WD_School_WDI__c.tolowercase()));
      else if (
        candidate.Last_School_Attended__c != null &&
        accountNametoIDMap != null &&
        accountNametoIDMap.get(candidate.Last_School_Attended__c.tolowercase()) != null
      )
        candidateToAccountMap.put(
          candidate.Id,
          accountNametoIDMap.get(candidate.Last_School_Attended__c.tolowercase())
        );
      else if (candidate.Last_School_Attended__c != null) {
        if (candNametoIDMap.containsKey(candidate.Last_School_Attended__c.tolowercase())) {
          Set<Id> tempCandIdSet = candNametoIDMap.get(candidate.Last_School_Attended__c.tolowercase());
          tempCandIdSet.add(candidate.Id);
          candNametoIDMap.put(candidate.Last_School_Attended__c.tolowercase(), tempCandIdSet);
        } else {
          Set<Id> candIdSet = new Set<Id>();
          candIdSet.add(candidate.Id);
          candNametoIDMap.put(candidate.Last_School_Attended__c.tolowercase(), candIdSet);
        }
        createAccountSet.add(candidate.Last_School_Attended__c.tolowercase());
      } else
        defaultAccCandIdSet.add(candidate.Id);
    }

    populateDefaultAccount(defaultAccCandIdSet);
    if (createAccountSet.size() > 0)
      createAccount(createAccountSet);

    return candidateToAccountMap;
  }

  public void createAccount(Set<String> createAccountSet) {
    List<Account> newAccountList = new List<Account>();
    RecordType accountRT = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Account' AND developername = 'WDR_Candidate'
    ];

    for (String accountName : createAccountSet) {
      Account acc = new Account();
      String tempName = '';
      for (String nameString : accountName.split(' '))
        tempName += nameString.capitalize() + ' ';
      acc.Name = tempName.left(tempName.length() - 1);
      acc.RecordTypeId = accountRT.Id;
      acc.OwnerId = getAccountOwner();
      newAccountList.add(acc);
    }

    if (newAccountList.size() > 0) {
      Boolean accountFieldsAccessible = PF_AccessibilityUtils.checkFLS(
        'Account',
        PF_AccessibilityUtils.PermissionType.CREATEABLE,
        new List<string>{ 'Name' }
      );
      if (accountFieldsAccessible) {
        Database.SaveResult[] sObjectInsertResult = Database.insert(newAccountList, false);
        for (Database.SaveResult result : sObjectInsertResult) {
          if (!result.isSuccess()) {
            PF_Logger.log(
              'CEMCI',
              'ERROR',
              String.valueOf(result.getErrors()),
              null,
              ' Error creating Account for Workday candidate while run as user' + UserInfo.getUserId(),
              'WDR_Util'
            );
          }
        }
      } else {
        PF_Logger.log(
          'CEMCI',
          'ERROR',
          'User does not have sufficient access on Account fields',
          '',
          'Error during Account creation ' + UserInfo.getUserId(),
          ''
        );
      }

      for (Account acc : newAccountList) {
        if(candNametoIDMap.containsKey(acc.Name.tolowercase())){
          for (Id candId : candNametoIDMap.get(acc.Name.tolowercase())) {
            candidateToAccountMap.put(candId, acc.Id);
          }
        }
      }
      if (!PF_Logger.logs.isEmpty()) {
        PF_Logger.createLogs(PF_Logger.logs);
      }
      NHW_Util.insertNHWLogs();
    }
  }

  public void populateDefaultAccount(Set<Id> candidateIds) {
    Account wdrAccount = [
      SELECT Id
      FROM Account
      WHERE RecordType.DeveloperName = 'WDR_Candidate' AND Name = 'WDR Candidates'
      LIMIT 1
    ];

    if (wdrAccount != null) {
      for (Id candId : candidateIds) {
        candidateToAccountMap.put(candId, wdrAccount.Id);
      }
    }
  }

  //Accounts won't be owned by a specific team. The solution is to create dummy users in Peopleforce
  //under a profile we define (Peopleforce Account Owners(APEX Only))who will own these accounts.
  //This will help get around the data skew issue in the long term.
  //Also we need to ensure we are not assigning newly created Accounts to just one user.
  //There are two ways we considered to handle this (a) Round-robin assignment (b) random assignment.
  //Round-robin has a limitation around parallel processing. The next viable option is random assignment.
  //This ensures accounts are spread across all users with this profile reducing chances of running into data-skew situations.
  public Id getAccountOwner() {
    Id accountOwnerId;

    if (ownerList.size() == 0) {
      WDR_System_Util processUsers = new WDR_System_Util();
      processUsers.handleCEMCIAccountUser(null, accountOwnerProfileId, allUsers.size());
      populateOwnerList();
      populateCountMap();
    }
    Integer ownerIndex = (Integer) math.abs((math.random() * ownerList.size()));
    accountOwnerId = ownerList[ownerIndex].Id;
    preProcessAccountOwner(accountOwnerId);

    return accountOwnerId;
  }

  public Id preProcessAccountOwner(Id accountOwnerId) {
    Integer accountRecordCount = accountOwnerToCountMap.get(accountOwnerId);
    if (accountRecordCount == null)
      accountRecordCount = 0;
    accountRecordCount++;
    if (accountRecordCount >= accountOwnership) {
      accountOwnerToCountMap.remove(accountOwnerId);
      ownerList.remove(ownerList.indexOf(new User(Id = accountOwnerId)));
      WDR_System_Util processUsers = new WDR_System_Util();
      processUsers.handleCEMCIAccountUser(accountOwnerId, accountOwnerProfileId, allUsers.size());
      populateOwnerList();
      populateCountMap();
    } else
      accountOwnerToCountMap.put(accountOwnerId, accountRecordCount);

    return accountOwnerId;
  }

  public static void processContactsForLeadConvertion(Set<Id> contactIds) {
    Map<string, Contact> nonConfidentialContactByEmail = new Map<string, Contact>();
    Map<string, Contact> confidentialContactByEmail = new Map<string, Contact>();
    List<contact> updatedContacts = [
      SELECT Id, Name, Email, Confidential__c, AccountId
      FROM Contact
      WHERE Id IN :contactIds
    ];
    for (contact con : updatedContacts) {
      if (con.Confidential__c)
        confidentialContactByEmail.put(con.email, con);
      else
        nonConfidentialContactByEmail.put(con.email, con);
    }

    WDRCandidate_To_Contact_BatchHandler handleRecord = new WDRCandidate_To_Contact_BatchHandler();
    handleRecord.updateCandidateMap = getMapUpdatedEmailToWDCandidate(updatedContacts);

    //Process non-confidential records
    if (!nonConfidentialContactByEmail.isEmpty()) {
      handleRecord.convertLeads(nonConfidentialContactByEmail, false);
    }
    //Process confidential records
    if (!confidentialContactByEmail.isEmpty()) {
      handleRecord.convertLeads(confidentialContactByEmail, true);
    }
    handleRecord.updateCandidates(handleRecord.updateCandidateMap.values());
  }

  public static Map<String, WDR_Candidate__c> getMapUpdatedEmailToWDCandidate(List<contact> updatedContacts) {
    Map<String, WDR_Candidate__c> updatedCandidateMap = new Map<String, WDR_Candidate__c>();
    for (WDR_Candidate__c candidate : [
      SELECT Email__c, Candidate_Contact__c, Ready_to_Process__c, Id
      FROM WDR_Candidate__c
      WHERE Candidate_Contact__c IN :updatedContacts
    ]) {
      updatedCandidateMap.put(candidate.Email__c, candidate);
    }
    return updatedCandidateMap;
  }

  public static void updateApplicationFields(Set<Id> contactIds) {
    Map<Id, List<WDR_Application__c>> cntctIdToWDAppList = new Map<Id, List<WDR_Application__c>>();
    Map<Id, Id> contactWithRecSubmitJobApp = new Map<Id, Id>();
    Map<Id, Id> contactWithRecUpdateJobApp = new Map<Id, Id>();
    Map<String, Decimal> stageOrderMap = new Map<String, Decimal>();
    Set<Id> activeApps = new Set<Id>();
    Set<Id> appIds = new Set<Id>();
    List<Contact> updateContacts = new List<contact>();

    CEMCI_Settings__c cs = CEMCI_Settings__c.getOrgDefaults();
    CEMCI_WD_App_Stage_order__mdt[] stageOrders = [
      SELECT MasterLabel, Order__c, New_Stage_Value__c
      FROM CEMCI_WD_App_Stage_order__mdt
    ];
    for (CEMCI_WD_App_Stage_order__mdt stg : stageOrders) {
      if (cs.ScaleR_Changes_Live__c) {
        if (stg.New_Stage_Value__c != null)
          stageOrderMap.put(stg.New_Stage_Value__c, stg.Order__c);
        else
          stageOrderMap.put(stg.MasterLabel, stg.Order__c);
      } else
        stageOrderMap.put(stg.MasterLabel, stg.Order__c);
    }

    //All applications to be considered For the Contacts
    List<WDR_Application__c> appList = new List<WDR_Application__c>(
      [
        SELECT
          Id,
          Candidate__c,
          Candidate__r.Candidate_Contact__c,
          Candidate__r.WD_Candidate_Reference_Id__c,
          CreatedDate,
          Candidate_Stage__c,
          Application_Date__c,
          Last_Recruiting_Stage__c
        FROM WDR_Application__c
        WHERE Candidate__r.Candidate_Contact__c IN :contactIds
        ORDER BY createddate DESC
      ]
    );
    // All Applications related to a Contact that are come From the Batch Job
    for (WDR_Application__c app : appList) {
      if (cntctIdToWDAppList.containsKey(app.Candidate__r.Candidate_Contact__c)) {
        cntctIdToWDAppList.get(app.Candidate__r.Candidate_Contact__c).add(app);
      } else {
        cntctIdToWDAppList.put(app.Candidate__r.Candidate_Contact__c, new List<WDR_Application__c>{ app });
      }
      if (!contactWithRecSubmitJobApp.containsKey(app.Candidate__r.Candidate_Contact__c)) {
        contactWithRecSubmitJobApp.put(app.Candidate__r.Candidate_Contact__c, app.Id);
      }
    }
    //All recently updated applications
    for (WDR_Application__c app : [
      SELECT Id, LAST_WD_Update__C, Candidate__r.Candidate_Contact__c
      FROM WDR_Application__c
      WHERE Candidate__r.Candidate_Contact__c IN :contactIds
      ORDER BY LAST_WD_Update__C DESC
    ]) {
      if (!contactWithRecUpdateJobApp.containsKey(app.Candidate__r.Candidate_Contact__c)) {
        contactWithRecUpdateJobApp.put(app.Candidate__r.Candidate_Contact__c, app.Id);
      }
    }

    for (id conid : cntctIdToWDAppList.keyset()) {
      contact cont = new contact(id = conid);
      Decimal appStageOrder = 0;
      for (WDR_Application__c a : cntctIdToWDAppList.get(cont.Id)) {
        //Total Active Application and Most Progressed Job
        if (a.Candidate_Stage__c != 'Declined by Candidate' && a.Candidate_Stage__c != 'Rejected') {
          activeApps.add(a.Id);
          if (stageOrderMap.get(a.Candidate_Stage__c) > appStageOrder) {
            cont.MPA_App__c = a.id;
            cont.Most_Progressed_Candidate_ID__c = a.Candidate__r.WD_Candidate_Reference_Id__c;
            appStageOrder = stageOrderMap.get(a.Candidate_Stage__c);
          }
        }

        //Hired checkbox
        if (a.Candidate_Stage__c == 'Placement' || a.Candidate_Stage__c == 'Pre-Placement') {
          cont.Hired__c = true;
        }
      }
      //Most Recently Submitted Application
      cont.MRS_App__c = contactWithRecSubmitJobApp.get(cont.id);
      //
      cont.MRU_App__c = contactWithRecUpdateJobApp.get(cont.id);
      //Total Application Count
      if (cntctIdToWDAppList.get(cont.Id).size() > 0) {
        cont.Total_Job_Applications__c = cntctIdToWDAppList.get(cont.Id).size();
      }
      //Active Application Count
      if (activeApps.size() > 0) {
        cont.Active_Job_Applications__c = activeApps.size();
        activeApps.clear();
      }
      updateContacts.add(cont);
    }
    if (updateContacts.size() > 0) {
      updateRecordAfterProcessing(updateContacts);
    }
  }
  public static void updateRecordAfterProcessing(List<sObject> records) {
    if (records != null && !records.isEmpty()) {
      Database.SaveResult[] srList = Database.update(records, false);
      for (Database.SaveResult sr : srList) {
        if (!sr.isSuccess()) {
          for (Database.Error err : sr.getErrors()) {
            PF_Logger.log('CEMCI', 'Job App Fields On Contact', err.getMessage(), '' + err.getFields(), '', '');
          }
        }
      }
      if (PF_Logger.logs.size() > 0)
        PF_Logger.createLogs(PF_Logger.logs);
    }
  }
  public List<Contact> populateSourceofTruthFieldsonContact(Set<Id> applicationIds, List<Contact> contactList) {
    List<WDR_Application__c> appList;
    Set<Id> contactIds = new Set<Id>();
    Set<Id> candidateIds = new Set<Id>();
    List<sObject> contactsToUpdate = new List<sObject>();
    Map<Id, WDR_Application__c> contactToJobAppMap = new Map<Id, WDR_Application__c>();
    Map<Id, Id> candidateToNewAccountMap = new Map<Id, Id>();
    Map<Id, Id> contactToCandidateMap = new Map<Id, Id>();

    List<Field_Mapping__mdt> candidatefieldMappingList = [
      SELECT To_Field__c, Is_Active__c
      FROM Field_Mapping__mdt
      WHERE
        From_Object__c = :Schema.SObjectType.WDR_Candidate__c.getName()
        AND To_Object__c = :Schema.SObjectType.WDR_Candidate__c.getName()
        AND Mapping_Category__c = 'CEMCI_Candidate_Source_of_Truth'
        AND Is_Active__c = TRUE
    ];

    List<Field_Mapping__mdt> contactfieldMappingList = [
      SELECT From_Object__c, From_Field__c, To_Field__c, Is_Active__c, To_Length_Limit__c
      FROM Field_Mapping__mdt
      WHERE
        To_Object__c = :Schema.SObjectType.Contact.getName()
        AND Mapping_Category__c = 'CEMCI_Candidate_Source_of_Truth'
        AND Is_Active__c = TRUE
    ];

    String queryString = 'Select Id, Candidate__c,Candidate__r.Candidate_Contact__c,Candidate__r.WD_Company_WDI__c,Candidate__r.Current_Company__c,Candidate__r.WD_School_WDI__c,Candidate__r.Last_School_Attended__c';
    for (Field_Mapping__mdt mapping : candidatefieldMappingList)
      queryString += ',Candidate__r.' + mapping.To_Field__c;

    queryString += ' from WDR_Application__c where is_New__c = true and Id IN:applicationIds';

    appList = Database.query(queryString);
    List<WDR_Candidate__c> wdCandidates = new List<WDR_Candidate__c>();

    for (WDR_Application__c app : appList) {
      contactToCandidateMap.put(app.Candidate__r.Candidate_Contact__c, app.Candidate__c);
      if (!contactToJobAppMap.containsKey(app.Candidate__r.Candidate_Contact__c))
        contactToJobAppMap.put(app.Candidate__r.Candidate_Contact__c, app);

      WDR_Candidate__c wdCandidate = new WDR_Candidate__c(
        Id = app.Candidate__c,
        WD_Company_WDI__c = app.Candidate__r.WD_Company_WDI__c,
        Current_Company__c = app.Candidate__r.Current_Company__c,
        WD_School_WDI__c = app.Candidate__r.WD_School_WDI__c,
        Last_School_Attended__c = app.Candidate__r.Last_School_Attended__c
      );
      wdCandidates.add(wdCandidate);
    }

    candidateToNewAccountMap = populateAccountonContact(wdCandidates);

    for (Contact appContact : contactList) {
      for (Field_Mapping__mdt mapping : contactfieldMappingList) {
        WDR_Application__c app = contactToJobAppMap.get(appContact.Id);
        Object appFieldValue = app != null ? app.getSObject(mapping.From_Object__c).get(mapping.From_Field__c) : null;
        if (mapping.From_Field__c == 'New_Current_Company__c') {
          if (
            !candidateToNewAccountMap.isEmpty() &&
            !contactToCandidateMap.isEmpty() &&
            contactToCandidateMap.get(appContact.Id) != null &&
            candidateToNewAccountMap.containsKey(contactToCandidateMap.get(appContact.Id)) &&
            candidateToNewAccountMap.get(contactToCandidateMap.get(appContact.Id)) != null
          )
            appContact.put('AccountId', candidateToNewAccountMap.get(contactToCandidateMap.get(appContact.Id)));
        } else {
          if (appFieldValue != null) {
            //Truncate if value longer than CRM field length
            if (mapping.To_Length_Limit__c != null) {
              String dataValue = String.valueOf(appFieldValue);
              dataValue = dataValue.length() > mapping.To_Length_Limit__c
                ? dataValue.left(Integer.valueOf(mapping.To_Length_Limit__c))
                : dataValue;
              appFieldValue = dataValue;
            }
            appContact.put(mapping.To_Field__c, appFieldValue);
          }
        }
      }
    }
    return contactList;
  }
  public void changeCandidateType(List<WDR_Application__c> validJobApplications) {
    List<WDR_Candidate__c> updateCandidateList = new List<WDR_Candidate__c>();
    for (WDR_Application__c validJobApplication : validJobApplications) {
      WDR_Candidate__c cand = new WDR_Candidate__c(Id = validJobApplication.Candidate__c);
      cand.Candidate_Type__c = 'Candidate';
      cand.Ready_to_Process__c = true;
      updateCandidateList.add(cand);
    }
    if (!updateCandidateList.isEmpty()) {
      Database.SaveResult[] saveResults = Database.update(updateCandidateList, false);
      for (Database.SaveResult result : saveResults) {
        if (!result.isSuccess()) {
          PF_Logger.log(
            'CEMCI',
            'ERROR',
            String.valueOf(result.getErrors()),
            null,
            ' Error updating candidate type while run as user' + UserInfo.getUserId(),
            ' from method changeCandidateType() WDR_Util'
          );
        }
      }
      NHW_Util.insertNHWLogs();
    }
  }

  public static Integer getBatchSizeforWDRBatch(String batchName) {
    Integer batchSize;
    Confidential_WD_Candidate_Fields__mdt batchSettingRec = [
      SELECT Batch_Size__c
      FROM Confidential_WD_Candidate_Fields__mdt
      WHERE DeveloperName = :batchName
    ];
    if (batchSettingRec != null && batchSettingRec.Batch_Size__c != null)
      batchSize = (Integer) batchSettingRec.Batch_Size__c;
    batchSize = batchSize > 0 ? batchSize : 200;

    return batchSize;
  }

  public static Map<Id, AsyncApexJob> checkForInProgressBatches(Id batchId) {
    Map<Id, AsyncApexJob> inProgressBatches = new Map<Id, AsyncApexJob>(
      [
        SELECT ApexClassId, ApexClass.Name, JobType, Status, TotalJobItems
        FROM AsyncApexJob
        WHERE
          (ApexClass.Name LIKE 'WDRCandidate%'
          OR ApexClass.Name LIKE 'WDJobApp%'
          OR ApexClass.Name LIKE 'WDCommunications%'
          OR ApexClass.Name LIKE 'CEMCI_ConvertLeadstoContacts%'
          OR ApexClass.Name LIKE 'CEMCI_DeDupeBatch%')
          AND Status IN ('Holding', 'Preparing', 'Processing')
      ]
    );
    if (inProgressBatches.containsKey(batchId))
      inProgressBatches.remove(batchId);
    return inProgressBatches;
  }

  public static String getSchedule() {
    DateTime nextRunTime = Datetime.now().addMinutes(5);

    String hour = String.valueOf(nextRunTime.hour());
    String min = String.valueOf(nextRunTime.minute());
    String ss = String.valueOf(nextRunTime.second());
    String formattedMonth = nextRunTime.format('MMM');
    //parse to cron expression
    String nextFireTime =
      ss +
      ' ' +
      min +
      ' ' +
      hour +
      ' ' +
      nextRunTime.day() +
      ' ' +
      formattedMonth +
      ' ?' +
      ' ' +
      nextRunTime.year();

    return nextFireTime;
  }

  public static Map<String, SObjectField> getFieldMap(Schema.FieldSet fieldSet) {
    Map<String, SObjectField> fieldMap = new Map<String, SObjectField>();
    List<Schema.FieldSetMember> fieldMembers = fieldSet.getFields();

    for (Schema.FieldSetMember member : fieldMembers) {
      Schema.SObjectField fieldObject = member.getSObjectField();
      fieldMap.put(fieldObject.getDescribe().getName(), fieldObject);
    }

    return fieldMap;
  }
}