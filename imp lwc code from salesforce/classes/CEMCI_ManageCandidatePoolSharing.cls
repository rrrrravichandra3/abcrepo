/**
 * @description       :
 * @author            : Urvish Shah (ushah)
 * @group             :
 * @last modified on  : 06-24-2022
 * @last modified by  : Urvish Shah (ushah)
 **/
public without sharing class CEMCI_ManageCandidatePoolSharing {
  //This map is to store the mapping of Contact and Requisition to make sure that
  //hiring manager of one requisition get access to contacts related to that requisition only
  private static Map<Id, Set<Id>> contactToReqs = new Map<Id, Set<Id>>();

  //Map to store list of candidate matches a particular hiring manager needs access of
  private static Map<Id, Set<Id>> hiringManagerToCandidateMatches = new Map<Id, Set<Id>>();

  //called from insert trigger on Candidate_Match__c object
  /**
   * @description This is called from trigger when Candidate Match records are created
   * This method will get the Hiring Manager and the HM is provided access to WD Rec,
   * Cand Matches for that Job Rec and related contacts for each Cand Match
   * @param  candidateMatches candidateMatches description
   */
  public static void shareJobRecAndContacts(List<Candidate_Match__c> candidateMatches) {
    Set<Id> jobRecIds = new Set<Id>();
    List<Id> contactIds = new List<Id>();
    List<SObject> allShareablRecords = new List<SObject>();

    for (Candidate_Match__c match : candidateMatches) {
      contactIds.add(match.Candidate__c);
      if (match.WD_Job_Requisition__c != null)
        jobRecIds.add(match.WD_Job_Requisition__c);
    }
    Map<Id, WDR_Job__c> jobRecs = new Map<Id, WDR_Job__c>(
      [SELECT Id, Hiring_Manager__c FROM WDR_Job__c WHERE ID IN :jobRecIds]
    );

    for (Candidate_Match__c match : candidateMatches) {
      if (contactToReqs.containsKey(match.Candidate__c)) {
        contactToReqs.get(match.Candidate__c).add(jobRecs.get(match.WD_Job_Requisition__c).Hiring_Manager__c);
      } else {
        contactToReqs.put(
          match.Candidate__c,
          new Set<Id>{ jobRecs.get(match.WD_Job_Requisition__c).Hiring_Manager__c }
        );
      }

      if (!hiringManagerToCandidateMatches.containsKey(jobRecs.get(match.WD_Job_Requisition__c).Hiring_Manager__c)) {
        hiringManagerToCandidateMatches.put(jobRecs.get(match.WD_Job_Requisition__c).Hiring_Manager__c, new Set<Id>());
      }
      hiringManagerToCandidateMatches.get(jobRecs.get(match.WD_Job_Requisition__c).Hiring_Manager__c).add(match.Id);
    }

    allShareablRecords.addAll(shareableData(jobRecs.values(), 'Read'));
    allShareablRecords.addAll(shareableData(contactIds, 'Read'));
    allShareablRecords.addAll(shareableData(hiringManagerToCandidateMatches, 'Edit'));

    save(allShareablRecords);
  }

  //
  /**
   * @description This is called from trigger when Candidate Match records are deleted
   * This method will get the Hiring Manager Id and the HM is revoked access to WD Rec,
   * Cand Matches for that Job Rec and related contacts for each Cand Match whic were alreadt provided
   * Note: Access to Wd Rec is only removed if all Candidate Matches are deleted on the WD Job Rec
   * @param  candidateMatches candidateMatches description
   */
  public static void unShareJobRecAndContacts(Map<Id, Candidate_Match__c> oldDeletedCandidateMatchesMap) {
    Set<Id> jobRecIds = new Set<Id>();
    List<Id> contactIds = new List<Id>();
    List<SObject> allShareablRecords = new List<SObject>();

    for (Candidate_Match__c match : oldDeletedCandidateMatchesMap.values()) {
      if (match.WD_Job_Requisition__c != null)
        jobRecIds.add(match.WD_Job_Requisition__c);
      if (match.Candidate__c != null)
        contactIds.add(match.Candidate__c);
      // If a Hiring Manager got access to a Contact from 2 Job Req's, when Cand match is removed from one pool
      // the access to that contact will
    }

    Map<Id, WDR_Job__c> jobReqs = new Map<Id, WDR_Job__c>(
      [
        SELECT id, Hiring_Manager__c, (SELECT id, Candidate__c FROM Candidate_Matches__r)
        FROM WDR_Job__c
        WHERE Id IN :jobRecIds
      ]
    );

    //After deleting the Candidate Match/s, if
    // there are no matches left then only remove access to Job Rec record
    Map<Id, String> jobRecsToUnshare = new Map<Id, String>();
    for (Id jobRecId : jobReqs.keySet()) {
      if (jobReqs.get(jobRecId).Candidate_Matches__r.isEmpty()) {
        jobRecsToUnshare.put(jobRecId, jobReqs.get(jobRecId).Hiring_Manager__c);
      }
    }

    //Map<Id,String> contactsToUnshare = new Map<Id,String>();
    Map<Id, Set<String>> contactsToUnshare = new Map<Id, Set<String>>();
    for (Candidate_Match__c match : oldDeletedCandidateMatchesMap.values()) {
      if (contactsToUnshare.containsKey(match.Candidate__c)) {
        contactsToUnshare.get(match.Candidate__c).add(jobRecsToUnshare.get(match.WD_Job_Requisition__c));
      } else {
        contactsToUnshare.put(match.Candidate__c, new Set<String>{ jobRecsToUnshare.get(match.WD_Job_Requisition__c) });
      }
    }
    //need to write code for contact data ad job rec data
    List<Candidate_Match__c> matches = [
      SELECT Id, Candidate__c, WD_Job_Requisition__c, WD_Job_Requisition__r.Hiring_Manager__c
      FROM Candidate_Match__c
      WHERE Candidate__c IN :contactIds AND WD_Job_Requisition__r.Hiring_Manager__c IN :jobRecsToUnshare.values()
    ];
    for (Candidate_Match__c match : matches) {
      if (contactsToUnshare.containsKey(match.Candidate__c)) {
        Set<String> hiringManagers = contactsToUnshare.get(match.Candidate__c);
        if (!hiringManagers.isEmpty() && hiringManagers.contains(match.WD_Job_Requisition__r.Hiring_Manager__c)) {
          contactsToUnshare.get(match.Candidate__c).remove(match.WD_Job_Requisition__r.Hiring_Manager__c);
        }
      }
    }

    List<String> allJobRecsToUnshare = new List<String>();
    for (Set<String> jobRecs : contactsToUnshare.values()) {
      allJobRecsToUnshare.addAll(jobRecs);
    }

    deleteSharesOnCandidateMatchDelete(
      jobRecsToUnshare.keySet(),
      jobRecsToUnshare.values(),
      contactsToUnshare.keySet(),
      allJobRecsToUnshare
    );
    //if access is removed for a contact on this Job Req, and HR needs to have access to this contact
  }

  /**
   * @description updateHiringManagerShare called from Wd Rec trigger while deleting
   * When a Hiring Manager is changed on a WD Job Rec, all the sharing records related to WD Job Rec need to be deleted
   * for the Hiring Manager.
   * In this case HM is revoked access to WD Rec,
   * Cand Matches for that Job Rec and related contacts for each Cand Match whic were already provided
   * @param  jobReqIds jobReqIds for which Hiring Manager is changed/updated
   * @param  oldMap    oldMap WD Job
   * @param  newMap    newMap WD job
   */
  public static void updateHiringManagerShare(Set<Id> jobReqIds, Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
    Map<Id, String> jobIdtoOldHMId = new Map<Id, String>();
    for (Id jobId : jobReqIds) {
      sObject oldRecord = Trigger.oldMap.get(jobId);
      jobIdtoOldHMId.put(jobId, String.valueOf(oldRecord.get('Hiring_Manager__c')));
    }

    //Get related Candidate Match Records to Job Reqs
    Map<Id, String> contactIdsToOldHMId = new Map<Id, String>();
    List<Candidate_Match__c> candidateMatches = [
      SELECT id, WD_Job_Requisition__c, Candidate__c
      FROM Candidate_Match__c
      WHERE WD_Job_Requisition__c IN :jobReqIds
    ];
    for (Candidate_Match__c c : candidateMatches) {
      contactIdsToOldHMId.put(c.Candidate__c, jobIdtoOldHMId.get(c.WD_Job_Requisition__c));
    }
    // Create new Sharing Records
    shareJobRecAndContacts(candidateMatches);

    //Delete Share Records for Old Hiring Manager
    deleteSharesForOldHiringManager(jobIdtoOldHMId, contactIdsToOldHMId);
  }

  private static void deleteSharesForOldHiringManager(
    Map<Id, String> jobIdtoOldHMId,
    Map<Id, String> contactIdsToOldHMId
  ) {
    List<SObject> sharesToDelete = new List<SObject>();
    List<WDR_Job__share> jobSharesToDelete = new List<WDR_Job__share>();
    List<ContactShare> contactSharesToDelete = new List<ContactShare>();

    jobSharesToDelete = [
      SELECT id
      FROM WDR_Job__Share
      WHERE ParentId IN :jobIdtoOldHMId.keySet() AND UserOrGroupId IN :jobIdtoOldHMId.values()
    ];
    sharesToDelete.addAll(jobSharesToDelete);

    contactSharesToDelete = [
      SELECT id
      FROM ContactShare
      WHERE ContactId IN :contactIdsToOldHMId.keySet() AND UserOrGroupId IN :contactIdsToOldHMId.values()
    ];
    sharesToDelete.addAll(contactSharesToDelete);
    deleteShareRecords(sharesToDelete);
  }

  private static void deleteSharesOnCandidateMatchDelete(
    Set<Id> jobIds,
    List<String> managerIdsforJobReqs,
    Set<Id> contactIds,
    List<String> managerIdsforContacts
  ) {
    List<SObject> sharesToDelete = new List<SObject>();
    List<WDR_Job__share> jobSharesToDelete = new List<WDR_Job__share>();
    List<ContactShare> contactSharesToDelete = new List<ContactShare>();

    jobSharesToDelete = [
      SELECT id
      FROM WDR_Job__Share
      WHERE ParentId IN :jobIds AND UserOrGroupId IN :managerIdsforJobReqs
    ];
    sharesToDelete.addAll(jobSharesToDelete);

    contactSharesToDelete = [
      SELECT id
      FROM ContactShare
      WHERE ContactId IN :contactIds AND UserOrGroupId IN :managerIdsforContacts
    ];
    sharesToDelete.addAll(contactSharesToDelete);
    deleteShareRecords(sharesToDelete);
  }

  /**
   * @description create shre records for WDR_Job__c records
   * @param  jobRecs    jobRecs description
   * @param  accessType Access to be Provided , Read or Edit
   * @return            List of shareable records
   */
  private static List<sObject> shareableData(List<WDR_Job__c> jobRecs, String accessType) {
    List<sObject> jobShares = new List<sObject>();
    for (WDR_Job__c jobRec : jobRecs) {
      WDR_Job__share jobShr = new WDR_Job__share();
      // Set the ID of record being shared.
      jobShr.ParentId = jobRec.Id;

      // Set the ID of user or group being granted access.
      jobShr.UserOrGroupId = jobRec.Hiring_Manager__c;

      // Set the access level.
      jobShr.AccessLevel = accessType;

      // Set rowCause to 'manual' for manual sharing.
      // This line can be omitted as 'manual' is the default value for sharing objects.
      jobShr.RowCause = Schema.WDR_Job__share.RowCause.Manual;
      jobShares.add(jobShr);
    }
    return jobShares;
  }

  /**
   * @description create shre records for Contact records
   * @param  jobRecs    jobRecs description
   * @param  accessType Access to be Provided , Read or Edit
   * @return List of ContacShare records
   */
  private static List<sObject> shareableData(List<Id> contactIds, String accessType) {
    List<sObject> contactShares = new List<sObject>();
    for (Id contactId : contactIds) {
      ContactShare conShr = new ContactShare();
      // Set the ID of record being shared.
      conShr.ContactId = contactId;

      // Set the ID of user or group being granted access.
      String userId = fetchJobReq(contactId);
      if (userId == null)
        continue;
      conShr.UserOrGroupId = userId; //map.get(contactId);

      // Set the access level.
      conShr.ContactAccessLevel = accessType;

      // Set rowCause to 'manual' for manual sharing.
      // This line can be omitted as 'manual' is the default value for sharing objects.
      conShr.RowCause = Schema.WDR_Job__share.RowCause.Manual;
      contactShares.add(conShr);
    }

    return contactShares;
  }

  /**
   * @description create shre records for Candidate_Match__c records
   * @param  hiringManagerToCandidateMatches
   * @param  accessType Access to be Provided , Read or Edit
   * @return List of Candidate_Match__share records
   */
  private static List<sObject> shareableData(Map<Id, Set<Id>> hiringManagerToCandidateMatches, String accessType) {
    List<sObject> candidateMatchesShare = new List<sObject>();
    for (Id hmId : hiringManagerToCandidateMatches.keySet()) {
      for (Id cmId : hiringManagerToCandidateMatches.get(hmId)) {
        Candidate_Match__share cmShare = new Candidate_Match__share();
        // Set the ID of record being shared.
        cmShare.userorgroupid = hmId;
        cmShare.parentId = cmId;
        cmShare.AccessLevel = accessType;
        candidateMatchesShare.add(cmShare);
      }
    }
    return candidateMatchesShare;
  }

  /**
   * @description SAve all the shareable records for WD Job Rec, Contact and candidate Matches
   * @param  sharingRecords :All data from 3 objects to be shared
   */
  private static void save(List<sObject> sharingRecords) {
    List<Database.SaveResult> results = Database.insert(sharingRecords, false);
    Boolean returnValue = false;
    Integer failedRecords = 0;
    for (Integer i = 0; i < results.size(); i++) {
      if (!results[i].isSuccess()) {
        failedRecords = +1;
        // Get first save result error.
        Database.Error err = results[i].getErrors()[0];
        PF_Logger.log(
          'CEMCI',
          'ERROR',
          String.valueOf(results[i].getErrors()),
          'Failed to Create Sharing Records',
          'The following sharing Record failed to be created: ' + sharingRecords[i],
          'CEMCI_ManageCandidatePoolSharing'
        );
      }
    }
    if (!PF_Logger.logs.isEmpty()) {
      PF_Logger.createLogs(PF_Logger.logs);
    }
  }

  /**
   * @description deleteShareRecords : Delete all the shareable records for WD Job Rec, Contact and candidate Matches
   * @param  sharingRecords :All data from 3 objects to be shared
   */
  private static void deleteShareRecords(List<sObject> sharingRecords) {
    List<Database.DeleteResult> results = Database.delete(sharingRecords, false);
    Integer failedRecords = 0;
    for (Integer i = 0; i < results.size(); i++) {
      if (!results[i].isSuccess()) {
        failedRecords = +1;
        // Get first save result error.
        Database.Error err = results[i].getErrors()[0];
        PF_Logger.log(
          'CEMCI',
          'ERROR',
          String.valueOf(results[i].getErrors()),
          'Failed to delete Sharing Records',
          'The following sharing Record failed to be deleted: ' + sharingRecords[i],
          'CEMCI_ManageCandidatePoolSharing'
        );
      }
    }
    if (!PF_Logger.logs.isEmpty()) {
      PF_Logger.createLogs(PF_Logger.logs);
    }
  }

  /**
   * @description fetchJobReq Get the first element from set
   * @param  contactId contactId description
   * @return           return WD job Requisition ID
   */
  private static String fetchJobReq(String contactId) {
    Set<Id> jobIds = contactToReqs.get(contactId);
    if (jobIds.size() == 0)
      return null;
    String reqID;
    for (Id jobId : jobIds) {
      reqID = jobId;
      break;
    }
    contactToReqs.get(contactId).remove(reqID);
    return reqID;
  }
}