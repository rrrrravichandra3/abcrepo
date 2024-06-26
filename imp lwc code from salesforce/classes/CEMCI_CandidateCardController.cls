/**
 * @description       :
 * @author            : Urvish Shah (ushah)
 * @group             :
 * @last modified on  : 09-21-2022
 * @last modified by  : Urvish Shah (ushah)
 **/
public with sharing class CEMCI_CandidateCardController {
  public static Map<String, String> apiNamevsOperator;
  public static Map<String, String> apiLabelvsName;
  public static List<Id> appliedContactIds = new List<Id>();

  public CEMCI_CandidateCardController() {
  }

  /**
   * @description getContactStages : Contact stages will be returned to UI to be used as dearch filters
   * @return   return List<String>
   * All Picklist values of Candidate_Stage__c field
   */
  @Auraenabled(cacheable=true)
  public static List<String> getContactStages() {
    List<String> pickListValuesList = new List<String>();
    for (Schema.PicklistEntry pickListVal : Contact.Candidate_Stage__c.getDescribe().getPicklistValues()) {
      pickListValuesList.add(pickListVal.getLabel());
    }
    return pickListValuesList;
  }

  /**
   * @description findContacts Do a SOSL or SOQL search based on the search data provided from UI/JS
   * @param  soslSearchText soslSearchText description
   * @param  searchFilters  searchFilters [Filter data such as stage, title, date range etc]
   * @param  jobRecId       jobRecId Job requisition ID
   * @return                return Contact results to UI/JS to render as Candidate cards
   */
  @Auraenabled(cacheable=false)
  public static CEMCI_SearchDataModel.ContactWrapper findContacts(
    String soslSearchText,
    String searchFilters,
    Id jobRecId
  ) {
    String escapedSearchText;
    if (String.isNotBlank(soslSearchText)) {
      escapedSearchText = String.escapeSingleQuotes(soslSearchText);
    }

    Map<String, Object> dataWrapper = (Map<String, Object>) JSON.deserializeUntyped(
      String.escapeSingleQuotes(searchFilters)
    );
    getAppliedContacts(jobRecId);
    List<String> reviewedCandidates = getReviewedCandidates(jobRecId);
    //If the Toggle to see "Applied Candidates Only" is O and there no application for Job rec , we
    //do not need further processing.
    //So returning empty List to UI
    if (Boolean.valueOf(dataWrapper.get('onlyAppliedContacts')) && appliedContactIds.size() == 0) {
      return new CEMCI_SearchDataModel.ContactWrapper(new List<Contact>(), appliedContactIds, reviewedCandidates);
    }
    List<CEMCI_SearchDataModel.ClauseWrapper> wrappers = prepareFilterWrappers(dataWrapper, jobRecId);
    List<Contact> contacts;
    if (String.isNotBlank(escapedSearchText)) {
      contacts = CEMCI_soslSearch.soslSearch(escapedSearchText, wrappers, 50, 0);
    } else {
      contacts = CEMCI_soslSearch.soqlSearch(wrappers, 50, 0);
    }

    CEMCI_SearchDataModel.ContactWrapper cw = new CEMCI_SearchDataModel.ContactWrapper(
      contacts,
      CEMCI_CandidateCardController.appliedContactIds,
      reviewedCandidates
    );
    return cw;
  }

  /**
   * @description getContactCountryPicklistValues : Use Schema class to get
   *                                                 picklist values on country field
   *                                                 to use as filters on UI
   * @return   return List<String> : Picklist values of Mailing_Country__c field
   */
  @Auraenabled(cacheable=true)
  public static List<String> getContactCountryPicklistValues() {
    List<String> pickListValuesList = new List<String>();
    for (Schema.PicklistEntry pickListVal : Contact.Mailing_Country__c.getDescribe().getPicklistValues()) {
      pickListValuesList.add(pickListVal.getValue() + '-' + pickListVal.getLabel());
    }
    return pickListValuesList;
  }

  /**
   * @description createCandidatePoolRecords : Create Candidate Match records for selected contacts
   * @param  candRecords : Selected Contacts from UI to be added to Candidate pool
   * @return             return Success/Error response
   */
  @AuraEnabled(cacheable=false)
  public static String createCandidatePoolRecords(List<SObject> candRecords) {
    String responseMessage = 'No records were selected to add to candidate pool';
    if (candRecords.isEmpty()) {
      return responseMessage;
    }
    responseMessage = 'Candidates added to Candidate Pool';
    Database.SaveResult[] results = database.insert(candRecords, false);

    Integer failedRecords = 0;
    for (Integer i = 0; i < results.size(); i++) {
      Database.SaveResult sr = results[i];
      if (!sr.success) {
        failedRecords = +1;
        PF_Logger.log(
          'CEMCI',
          'ERROR',
          String.valueOf(sr.getErrors()),
          'Failed to Create Candidate Pool Record',
          'The following Candidate Pool Record failed to be created: ' + candRecords[i],
          'CEMCI_CandidateCardController'
        );
      }
    }
    if (!PF_Logger.logs.isEmpty()) {
      responseMessage =
        failedRecords +
        ' failed to be created. Please try again and if the issue persists please contact your Salesforce Adminstrator';
      PF_Logger.createLogs(PF_Logger.logs);
      return responseMessage;
    }

    return responseMessage;
  }

  /**
   * @description prepareFilterWrappers : prepare ClauseWrapper innstances for each filter used
   *                                      to use them in the where clause generator for SOSL/SOQL
   * @param  dataWrapper dataWrapper : Has the filte r values (ex: Stage - ('Inactive','Review')
   * @param  jobRecId    jobRecId Job requisition Id to get existing related contacts
   *                     from the "Job Applications related list--> Candidate --> Contact"
   * @return             return description
   */
  public static List<CEMCI_SearchDataModel.ClauseWrapper> prepareFilterWrappers(
    Map<String, Object> dataWrapper,
    Id jobRecId
  ) {
    String contactIdString = getExistingRelatedContacts(jobRecId);
    List<CEMCI_SearchDataModel.ClauseWrapper> clauseWrappers = new List<CEMCI_SearchDataModel.ClauseWrapper>();
    CEMCI_SearchDataModel.ClauseWrapper clause;
    Id rtId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('WDR_Candidate').getRecordTypeId();

    addDefaultClauseWrappers(clauseWrappers, rtId);

    for (String field : dataWrapper.keySet()) {
      if (dataWrapper.get(field) != null) {
        // For dataWrapper.get(field); use a new map to fetch the data type
        if (field.equalsIgnoreCase('onlyAppliedContacts') && !Boolean.valueOf(dataWrapper.get(field))) {
          continue;
        } else if (field.equalsIgnoreCase('boomerang') && !Boolean.valueOf(dataWrapper.get(field))) {
          continue;
        } else if (field.equalsIgnoreCase('tags')) {
          for (Object a : (List<Object>) dataWrapper.get('tags')) {
            clause = new CEMCI_SearchDataModel.ClauseWrapper(
              getFieldAPIName(field),
              String.valueOf(a),
              getOperator((field))
            );
            clauseWrappers.add(clause);
          }
          continue;
        } else if (field.equalsIgnoreCase('searchText')) {
          continue;
        }
        clause = new CEMCI_SearchDataModel.ClauseWrapper(
          getFieldAPIName(field),
          getValue(field, dataWrapper, jobRecId),
          getOperator((field))
        );
        clauseWrappers.add(clause);
      }
    }

    if (contactIdString != null) {
      clause = new CEMCI_SearchDataModel.ClauseWrapper('Id', contactIdString, getOperator(('relatedContacts')));
      clauseWrappers.add(clause);
    }
    //Need to add createddate < today - 7*(from) and createddate > today - 7*(to)
    return clauseWrappers;
  }

  /**
   * @description addDefaultClauseWrappers : Create wrappers for defaulte where clauses
   * @param  clauseWrappers : existing clauseWrappers to add-on to
   * @param  rtId           rtId Record Type Id of WDR_Candidate
   */
  private static void addDefaultClauseWrappers(List<CEMCI_SearchDataModel.ClauseWrapper> clauseWrappers, Id rtId) {
    clauseWrappers.add(
      new CEMCI_SearchDataModel.ClauseWrapper(
        getFieldAPIName('recordTypeId'),
        String.valueOf(rtId),
        getOperator('recordTypeId')
      )
    );
    clauseWrappers.add(
      new CEMCI_SearchDataModel.ClauseWrapper(
        getFieldAPIName('doNotHire'),
        String.valueOf('false'),
        getOperator('doNotHire')
      )
    );
    clauseWrappers.add(
      new CEMCI_SearchDataModel.ClauseWrapper(
        getFieldAPIName('recruitingOptIn'),
        String.valueOf('Opt Out'),
        getOperator('recruitingOptIn')
      )
    );
  }

  /**
   * @description getFieldAPIName : Contains a Map of custom name of filter field to actual field API name
   * @param  apiName : description
   * @return return API Name of the field
   */
  private static String getFieldAPIName(String apiName) {
    if (apiLabelvsName != null) {
      return apiLabelvsName.get(apiName);
    }
    apiLabelvsName = new Map<String, String>();
    //Default values
    apiLabelvsName.put('recordTypeId', 'RecordTypeId');
    apiLabelvsName.put('doNotHire', 'Do_Not_Hire__c');
    apiLabelvsName.put('recruitingOptIn', 'Recruiting_Opt_In__c');

    //Custom/Dynamic values
    apiLabelvsName.put('contactStages', 'Candidate_Stage__c');
    apiLabelvsName.put('title', 'Title');
    apiLabelvsName.put('currentEmployer', 'Account.Name');
    apiLabelvsName.put('fromWeek', 'CreatedDate');
    apiLabelvsName.put('toWeek', 'CreatedDate');
    apiLabelvsName.put('relatedContacts', 'Id');
    apiLabelvsName.put('onlyAppliedContacts', 'Id');
    apiLabelvsName.put('boomerang', 'Boomerang__c');
    apiLabelvsName.put('tags', 'tags__c');
    return apiLabelvsName.get(apiName);
  }

  /**
   * @description getOperator : Contains a Map of custom name of filter field to actual field operator
   * @param  apiName : Key in the map
   * @return return operator for a specific filter to be applied in SOQL filter
   */
  private static String getOperator(String apiName) {
    if (apiNamevsOperator != null) {
      return apiNamevsOperator.get(apiName);
    }

    apiNamevsOperator = new Map<String, String>();

    //Default values
    apiNamevsOperator.put('recordTypeId', '=');
    apiNamevsOperator.put('doNotHire', 'boolean');
    apiNamevsOperator.put('recruitingOptIn', '!=');

    //Custom/Dynamic values
    apiNamevsOperator.put('contactStages', 'IN');
    apiNamevsOperator.put('title', 'LIKE');
    apiNamevsOperator.put('currentEmployer', 'LIKE');
    apiNamevsOperator.put('fromWeek', '<');
    apiNamevsOperator.put('toWeek', '>');
    apiNamevsOperator.put('relatedContacts', 'NOT IN');
    apiNamevsOperator.put('onlyAppliedContacts', 'IN');
    apiNamevsOperator.put('boomerang', 'boolean');
    apiNamevsOperator.put('tags', 'LIKE');
    return apiNamevsOperator.get(apiName);
  }

  /**
   * @description getValue description
   * @param  fieldName : Range start or Range end field Name (fromWeek and toWeek are the possible values)
   * @param  dataWrapper : Filter data
   * @return return Date in String format based on week number
   */
  private static String getValue(String fieldName, Map<String, Object> dataWrapper, String jobRecId) {
    if (fieldName == 'fromWeek' || fieldName == 'toWeek') {
      //return date of 'N' weeks before, where N is an integer and value is sent from UI soql filter
      Date dt = Date.today() - (7 * (Integer.valueOf(dataWrapper.get(fieldName))));
      return String.valueof(dt) + 'T00:00:00Z';
    } else if (fieldName == 'onlyAppliedContacts') {
      return convertCollectionToString(new Set<Id>(CEMCI_CandidateCardController.appliedContactIds), ',');
    } else {
      return String.valueOf(dataWrapper.get(fieldName));
    }
  }

  /**
   * @description getExistingRelatedContacts will fetch all the possible contaci Ids that
   *              shoule be excluded
   *              1. Candidate who already applied and are Rejected or Self Declined
   *              2. Candidates who are already added to the pool
   * @param  jobRecId : WD Job Req Id
   * @return return description
   */
  private static String getExistingRelatedContacts(id jobRecId) {
    String labelValue = System.Label.CandidateCard_Exclusions;
    List<String> candidateStageExclusions = labelValue.split(',');
    Set<Id> contactIds = new Set<Id>();
    List<WDR_Application__c> apps = new List<WDR_Application__c>();
    List<Candidate_Match__c> candidateMatches = new List<Candidate_Match__c>();
    if (jobRecId != null) {
      WDR_Job__c jobReq = [
        SELECT
          id,
          (
            SELECT id, Candidate__r.Candidate_Contact__c
            FROM Applications__r
            WHERE Candidate_Stage__c IN :candidateStageExclusions
          ),
          (SELECT id, Candidate__c FROM Candidate_Matches__r)
        FROM WDR_Job__c
        WHERE Id = :jobRecId
        LIMIT 1
      ];
      if (!jobReq.Applications__r.isEmpty()) {
        apps = jobReq.Applications__r;
      }
      if (!jobReq.Candidate_Matches__r.isEmpty()) {
        candidateMatches = jobReq.Candidate_Matches__r;
      }

      for (WDR_Application__c a : apps) {
        if (a.Candidate__r.Candidate_Contact__c != null) {
          contactIds.add(a.Candidate__r.Candidate_Contact__c);
        }
      }

      for (Candidate_Match__c c : candidateMatches) {
        if (c.Candidate__c != null) {
          contactIds.add(c.Candidate__c);
        }
      }
    } else {
      return null;
    }
    return convertCollectionToString(contactIds, ',');
  }

  private static void getAppliedContacts(Id jobRecId) {
    if (jobRecId == null) {
      return;
    }
    String labelValue = System.Label.CandidateCard_Exclusions;
    List<String> candidateStageExclusions = labelValue.split(',');
    Set<Id> contactIds = new Set<Id>();
    List<WDR_Application__c> apps = new List<WDR_Application__c>();

    WDR_Job__c jobReq = [
      SELECT
        id,
        (
          SELECT id, Candidate__r.Candidate_Contact__c
          FROM Applications__r
          WHERE Candidate_Stage__c NOT IN :candidateStageExclusions
        )
      FROM WDR_Job__c
      WHERE Id = :jobRecId
      LIMIT 1
    ];
    if (!jobReq.Applications__r.isEmpty()) {
      apps = jobReq.Applications__r;
    }

    for (WDR_Application__c a : apps) {
      if (a.Candidate__r.Candidate_Contact__c != null) {
        contactIds.add(a.Candidate__r.Candidate_Contact__c);
      }
    }
    appliedContactIds.addAll(contactIds);
  }

  private static String convertCollectionToString(Set<Id> contactIds, String delim) {
    String[] tmp1 = new List<String>{};
    for (String s : contactIds) {
      tmp1.add(s);
    }
    String returnString = string.join(tmp1, delim);
    return returnString;
  }

  @AuraEnabled
  public static void updateReviewedCandidates(String contactId, String jobRecId) {
    new UpdateReviewedCandidatesOnJobRec().updateReviewedCandidates(contactId, jobRecId);
  }

  @AuraEnabled
  public static void updateUnmarkedCandidates(String contactId, String jobRecId) {
    new UpdateReviewedCandidatesOnJobRec().updateUnmarkedCandidates(contactId, jobRecId);
  }

  @AuraEnabled
  public static List<String> getReviewedCandidates(String jobRecId) {
    return new UpdateReviewedCandidatesOnJobRec().getReviewedCandidates(jobRecId);
  }

  private without sharing class UpdateReviewedCandidatesOnJobRec {
    public void updateReviewedCandidates(String contactId, String jobRecId) {
      try {
        WDR_Job__c jobRec = [SELECT Id, ReviewedCandidates__c FROM WDR_Job__c WHERE ID = :jobRecId];
        if (jobRec.ReviewedCandidates__c == null) {
          jobRec.ReviewedCandidates__c = contactId.trim();
          update jobRec;
        } else {
          if (!jobRec.ReviewedCandidates__c.contains(contactId)) {
            jobRec.ReviewedCandidates__c += ';' + contactId.trim();
            update jobRec;
          }
        }
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }

    public void updateUnmarkedCandidates(String contactId, String jobRecId) {
      try {
        WDR_Job__c jobRec = [SELECT Id, ReviewedCandidates__c FROM WDR_Job__c WHERE ID = :jobRecId];
        if (jobRec.ReviewedCandidates__c != null && jobRec.ReviewedCandidates__c.containsIgnoreCase(contactId)) {
          String revCand = jobRec.ReviewedCandidates__c;
          if (revCand == contactId) {
            jobRec.ReviewedCandidates__c = null;
          } else if (revCand.startsWith(contactId)) {
            jobRec.ReviewedCandidates__c = revCand.remove(contactId + ';');
          } else {
            jobRec.ReviewedCandidates__c = revCand.remove(';' + contactId);
          }
          update jobRec;
        }
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }

    public List<String> getReviewedCandidates(String jobRecId) {
      List<String> reviewedCandidates = new List<String>();
      try {
        WDR_Job__c jobRec = [SELECT Id, ReviewedCandidates__c FROM WDR_Job__c WHERE ID = :jobRecId];
        if (jobRec.ReviewedCandidates__c == null) {
          return reviewedCandidates;
        } else {
          reviewedCandidates = jobRec.ReviewedCandidates__c.split(';');
        }
        return reviewedCandidates;
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }
  }
}