/**
 * @description       :
 * @author            : Urvish Shah (ushah)
 * @group             :
 * @last modified on  : 10-26-2022
 * @last modified by  : Urvish Shah (ushah)
 **/
public with sharing class WDJobApp_To_Contact_BatchHandler {
  public static List<Id> failedJobAppIdList;
  public static Set<Id> failedCandidateIdList;
  public static Map<Id, List<WDR_Application__c>> cntctIdToWDAppList = new Map<Id, List<WDR_Application__c>>();

  public static List<Contact> updateApplicationFields(
    List<Contact> updateContacts,
    Map<Id, WDR_Application__c> jobAppForContactId,
    List<WDR_Application__c> jobApps,
    Set<id> contactIds,
    Map<Id, List<WDR_Application__c>> contactToJobAppMap
  ) {
    List<Contact> contactsForUpdate = new List<Contact>();
    Map<Id, Id> contactWithRecSubmitJobApp = new Map<Id, Id>();
    Map<Id, WDR_Application__c> contactWithRecUpdateJobApp = new Map<Id, WDR_Application__c>();
    Map<String, Decimal> stageOrderMap = new Map<String, Decimal>();
    Set<Id> activeApps = new Set<Id>();
    Map<Id, WDR_Application__c> mapOfIdApplication = new Map<Id, WDR_Application__c>();
    Set<Id> appIdsforSoT = new Set<Id>();
    failedJobAppIdList = new List<Id>();
    failedCandidateIdList = new Set<Id>();
    String updateQueryString = System.Label.CEMCI_RecentUpdatedJobAppQuery;
    Map<ID, List<Id>> mapOfContactIdActiveApp = new Map<ID, List<Id>>();

    CEMCI_Settings__c cs = CEMCI_Settings__c.getOrgDefaults();
    CEMCI_WD_App_Stage_order__mdt[] stageOrders = [
      SELECT MasterLabel, Order__c, New_Stage_Value__c
      FROM CEMCI_WD_App_Stage_order__mdt
    ];
    for (CEMCI_WD_App_Stage_order__mdt stg : stageOrders) {
      stageOrderMap.put(stg.MasterLabel, stg.Order__c);
    }
    //All applications to be considered For the Contacts
    List<WDR_Application__c> appList = new List<WDR_Application__c>(
      [
        SELECT
          Id,
          Text_Resume__c,
          Candidate__c,
          Candidate__r.Candidate_Contact__c,
          Candidate__r.WD_Candidate_Reference_Id__c,
          CreatedDate,
          Candidate_Stage__c,
          Application_Date__c,
          Last_Recruiting_Stage__c,
          is_New__c,
          Boomerang__c,
          Candidate_Source__c,
          Last_Degree_Received__c,
          Field_of_Study__c,
          Last_School_Attended__c
        FROM WDR_Application__c
        WHERE Candidate__r.Candidate_Contact__c IN :contactIds
        ORDER BY createddate DESC
      ]
    );
    // All Applications related to a Contact that are come From the Batch Job
    for (WDR_Application__c app : appList) {
      if (cntctIdToWDAppList.containsKey(app.Candidate__r.Candidate_Contact__c)) {
        cntctIdToWDAppList.get(app.Candidate__r.Candidate_Contact__c).add(app);
        if (app.Candidate_Stage__c != 'Declined by Candidate' && app.Candidate_Stage__c != 'Rejected') {
          if (mapOfContactIdActiveApp.containsKey(app.Candidate__r.Candidate_Contact__c)) {
            mapOfContactIdActiveApp.get(app.Candidate__r.Candidate_Contact__c).add(app.Id);
          } else {
            mapOfContactIdActiveApp.put(app.Candidate__r.Candidate_Contact__c, new List<Id>{ app.Id });
          }
        }
      } else {
        cntctIdToWDAppList.put(app.Candidate__r.Candidate_Contact__c, new List<WDR_Application__c>{ app });
        if (app.Candidate_Stage__c != 'Declined by Candidate' && app.Candidate_Stage__c != 'Rejected') {
          mapOfContactIdActiveApp.put(app.Candidate__r.Candidate_Contact__c, new List<Id>{ app.Id });
        }
      }

      if (!contactWithRecSubmitJobApp.containsKey(app.Candidate__r.Candidate_Contact__c)) {
        contactWithRecSubmitJobApp.put(app.Candidate__r.Candidate_Contact__c, app.Id);
      }
      mapOfIdApplication.put(app.Id, app);
      if (app.is_New__c)
        appIdsforSoT.add(app.Id);
    }
    //All recently updated applications
    String query =
      'Select Id, LAST_WD_Update__C,Candidate_Stage__c, Candidate__r.Candidate_Contact__c From WDR_Application__c WHERE Candidate__r.Candidate_Contact__c IN :contactIds order by' +
      ' ' +
      updateQueryString +
      ' ' +
      'desc';
    for (WDR_Application__c app : database.query(query)) {
      if (!contactWithRecUpdateJobApp.containsKey(app.Candidate__r.Candidate_Contact__c)) {
        contactWithRecUpdateJobApp.put(app.Candidate__r.Candidate_Contact__c, app);
      }
    }

    for (Contact c : updateContacts) {
      Decimal appStageOrder = 0;
      WDR_Application__c jobapp = jobAppForContactId.get(c.id);
      if (jobapp != null) {
        if (jobapp.Marketing_Opt_In__c == 'Yes') {
          c.Marketing_Opt_In__c = 'Opt In';
          c.Recruiting_Opt_In__c = 'Opt In';
        } else {
          c.Marketing_Opt_In__c = 'Opt Out';
          c.Recruiting_Opt_In__c = 'Opt Out';
        }
      }
      //Logic to update URM/URG Field based on Job
      if (contactToJobAppMap.containsKey(c.Id) && (c.URM__c == false || c.URG__c == false)) {
        for (WDR_Application__c app : contactToJobAppMap.get(c.Id)) {
          if (!c.URM__c && app.URM__c) {
            c.URM__c = true;
          }
          if (!c.URG__c && app.URG__c) {
            c.URG__c = true;
          }
        }
      }

      for (WDR_Application__c a : cntctIdToWDAppList.get(c.Id)) {
        //Total Active Application and Most Progressed Job
        if (a.Candidate_Stage__c != 'Declined by Candidate' && a.Candidate_Stage__c != 'Rejected') {
          activeApps.add(a.Id);

          if (stageOrderMap.get(a.Candidate_Stage__c) > appStageOrder) {
            c.MPA_App__c = a.id;
            c.Candidate_Stage__c = a.Candidate_Stage__c;
            c.Most_Progressed_Candidate_ID__c = a.Candidate__r.WD_Candidate_Reference_Id__c;
            appStageOrder = stageOrderMap.get(a.Candidate_Stage__c);
          }
        } else {
          // All inactive applications
          if (!mapOfContactIdActiveApp.containsKey(c.Id)) {
            c.MPA_App__c = null;
            c.Candidate_Stage__c = contactWithRecUpdateJobApp.get(c.id).Candidate_Stage__c;
            activeApps.clear();
          }
        }

        //Hired checkbox
        if (a.Candidate_Stage__c == 'Placement' || a.Candidate_Stage__c == 'Pre-Placement') {
          c.Hired__c = true;
        }
      }
      //Most Recently Submitted Application
      c.MRS_App__c = contactWithRecSubmitJobApp.get(c.id);

      //Logic for Resume Text, Boomerang, Candidate Source, Degree, Field of Study, School
      WDR_Application__c MRSJob = mapOfIdApplication.get(contactWithRecSubmitJobApp.get(c.id));
      if (MRSJob.Text_Resume__c != null) {
        c.Text_Resume__c = MRSJob.Text_Resume__c;
      }
      if (!c.Boomerang__c && MRSJob.Boomerang__c) {
        c.Boomerang__c = true;
      }
      if (String.isNotBlank(MRSJob.Candidate_Source__c)) {
        c.WD_Candidate_Source__c = modifyValueWithSpecialCharacters(MRSJob.Candidate_Source__c);
      }
      if (String.isNotBlank(MRSJob.Last_Degree_Received__c)) {
        c.WD_Candidate_Degree__c = modifyValueWithSpecialCharacters(MRSJob.Last_Degree_Received__c);
      }
      if (String.isNotBlank(MRSJob.Field_of_Study__c)) {
        c.WD_Field_of_Study__c = modifyValueWithSpecialCharacters(MRSJob.Field_of_Study__c);
      }
      if (String.isNotBlank(MRSJob.Last_School_Attended__c)) {
        c.WD_School__c = MRSJob.Last_School_Attended__c;
      }

      //Most Recently Updated Job Application
      c.MRU_App__c = contactWithRecUpdateJobApp.get(c.id).id;
      //Total Application Count
      if (cntctIdToWDAppList.get(c.Id).size() > 0) {
        c.Total_Job_Applications__c = cntctIdToWDAppList.get(c.Id).size();
      }
      //Active Application Count
      if (activeApps.size() > 0) {
        c.Active_Job_Applications__c = activeApps.size();
        activeApps.clear();
      } else if (activeApps.size() == 0) {
        c.Active_Job_Applications__c = null;
      }
      contactsForUpdate.add(c);
    }

    //Processing Source of truth fields
    if (!appIdsforSoT.isEmpty()) {
      WDR_Util handleRecord = new WDR_Util();
      contactsForUpdate = handleRecord.populateSourceofTruthFieldsonContact(appIdsforSoT, contactsForUpdate);
    }

    //Update records in database
    contactsForUpdate = updateContactFieldsForTheJobapplications(contactsForUpdate);

    return contactsForUpdate;
  }

  private static String modifyValueWithSpecialCharacters(String value) {
    if (value.contains(' (') || value.contains(')') || value.contains(',') || value.contains(') ')) {
      value = value.replace(' (', '_');
      value = value.replace(', ', '_');
      if (value.split('\\)').size() > 1) {
        value = value.replace(') ', '');
      } else {
        value = value.replace(')', '');
      }
    }
    return value;
  }

  public static void creatingAuthorizationConsentForJobAppLication(
    List<Contact> updatedContacts,
    Set<Id> Individuals,
    Set<Id> authorzationFormIds,
    Map<Id, WDR_Application__c> jobAppForContactId
  ) {
    CEMCI_AuthorizationFormConsent authorizationForm = new CEMCI_AuthorizationFormConsent(updatedContacts);
    authorizationForm.setIndividuals(Individuals);
    authorizationForm.setAuthorizationFormIds(authorzationFormIds);
    authorizationForm.setJobAppForContactId(jobAppForContactId);
    authorizationForm.setAuthorizationFormConsentsForJobApp();
  }

  public static List<Contact> updateContactFieldsForTheJobapplications(List<contact> contactsForUpdate) {
    if (contactsForUpdate != null && !contactsForUpdate.isEmpty()) {
      Boolean areFieldsAccessible = PF_AccessibilityUtils.checkFLS(
        'Contact',
        PF_AccessibilityUtils.PermissionType.UPDATEABLE,
        new List<string>{
          'leadsource',
          'Marketing_Opt_In__c',
          'Recruiting_Opt_In__c',
          'MPA_App__c',
          'Most_Progressed_Candidate_ID__c',
          'Hired__c',
          'MRS_App__c',
          'MRU_App__c',
          'Total_Job_Applications__c',
          'Active_Job_Applications__c'
        }
      );
      if (areFieldsAccessible) {
        Database.SaveResult[] srList = Database.update(contactsForUpdate, false);

        for (Integer i = 0; i < srList.size(); i++) {
          if (!srList[i].isSuccess()) {
            //If the record processing has failed do not clear the ready too process fields
            Contact contactRec = contactsForUpdate.get(i);
            if (contactRec != null && contactRec.Id != null) {
              for (WDR_Application__c app : cntctIdToWDAppList.get(contactRec.Id)) {
                failedJobAppIdList.add(app.Id);
                failedCandidateIdList.add(app.Candidate__c);
              }
              for (Database.Error objErr : srList[i].getErrors()) {
                PF_Logger.log(
                  'CEMCI',
                  'ERROR',
                  objErr.getMessage(),
                  String.valueof(objErr.getStatusCode()),
                  ' Error during Job Application batch processing on Job app related to ' +
                  contactRec.Id +
                  ' run by UserId ' +
                  UserInfo.getUserId(),
                  'WD Job Application Batch'
                );
              }
            }
          }
        }
      } else {
        PF_Logger.log(
          'CEMCI',
          'ERROR',
          'The Admin running user does not have sufficient access on Contact fields',
          '',
          ' Error during Job Application batch processing Insert UserId ' + UserInfo.getUserId(),
          ''
        );
      }
      if (!PF_Logger.logs.isEmpty()) {
        PF_Logger.createLogs(PF_Logger.logs);
      }
    }
    cntctIdToWDAppList.clear();
    return contactsForUpdate;
  }

  public static void postProcessingActions(List<WDR_Application__c> WDJobapps) {
    List<WDR_Application__c> updateJobApplicationList = populateJobAppUpdateList(WDJobapps);
    List<WDR_Candidate__c> updateCandidateList = populateCandidateUpdateList(WDJobapps);
    WDR_Util.updateRecordAfterProcessing(updateJobApplicationList);
    WDR_Util.updateRecordAfterProcessing(updateCandidateList);
  }

  public static List<WDR_Application__c> populateJobAppUpdateList(List<WDR_Application__c> WDJobapps) {
    List<WDR_Application__c> resultList = new List<WDR_Application__c>();
    for (WDR_Application__c jobapp : WDJobapps) {
      if (!failedJobAppIdList.contains(jobapp.Id)) {
        jobapp.Ready_to_Process__c = false;
        jobapp.is_New__c = false;
        resultList.add(jobapp);
      }
    }
    return resultList;
  }

  public static List<WDR_Candidate__c> populateCandidateUpdateList(List<WDR_Application__c> WDJobapps) {
    Map<Id, WDR_Candidate__c> resultMap = new Map<Id, WDR_Candidate__c>();
    List<Field_Mapping__mdt> fieldMappingList = [
      SELECT From_Field__c, To_Field__c, Is_Active__c, Mapping_Category__c
      FROM Field_Mapping__mdt
      WHERE
        From_Object__c = :Schema.SObjectType.WDR_Candidate__c.getName()
        AND To_Object__c = :Schema.SObjectType.WDR_Candidate__c.getName()
        AND Mapping_Category__c = 'CEMCI_Candidate_Source_of_Truth'
        AND Is_Active__c = TRUE
    ];

    List<Id> candIdList = new List<Id>();
    for (WDR_Application__c app : WDJobapps)
      candIdList.add(app.Candidate__c);
    String query = 'Select Id from WDR_Candidate__c where (';
    for (Field_Mapping__mdt mapping : fieldMappingList) {
      if (mapping.To_Field__c != null)
        query += mapping.To_Field__c + '!=null OR ';
    }
    query = query.substring(0, query.length() - 4);
    query += ') AND Id IN:candIdList';
    //Add all Candidate in database that needs to be reset. Since there could be Candidates that got demographic field updates
    //without an accompanying new Job application, this list is bigger than the processed Job app list. Using a listSizeTracker
    //to keep track of such records and split processing at 10K records. This needs to be truncated at 10K as otherwise we run into
    //risk of updating records from within a loop if more than one batch of 10K records at a batch. This is an edge case and
    //will most likely only happen during large data upserts on Candidates hence truncating at 10K should be fine.
    Integer listSizeTracker = Limits.getDMLStatements();
    for (WDR_Candidate__c candidate : Database.query(query)) {
      if (!failedCandidateIdList.contains(candidate.Id)) {
        WDR_Candidate__c cand = new WDR_Candidate__c(Id = candidate.Id);
        for (Field_Mapping__mdt mapping : fieldMappingList)
          cand.put(mapping.To_Field__c, '');
        if (!resultMap.containsKey(cand.Id) && listSizeTracker <= 5000) {
          resultMap.put(cand.Id, cand);
          listSizeTracker++;
        }
        if (listSizeTracker == 5000)
          break;
      }
    }
    return resultMap.values();
  }
}