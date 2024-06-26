/**
 * @description       :
 * @author            : Urvish Shah (ushah)
 * @group             :
 * @last modified on  : 02-15-2023
 * @last modified by  : Urvish Shah (ushah)
 **/
public with sharing class CEMCI_CandidateSearchController {
  public static Map<String, String> apiNamevsOperator;
  public static Map<String, String> apiLabelvsName;
  public static List<Id> appliedContactIds = new List<Id>();
  private final static Integer MAX_RESULTS = 5;
  public static CEMCI_SearchSettings__mdt cemciSearchSettings;
  public static Set<String> setIgnoreSearchValues = new Set<String>{
    'city',
    'province',
    'postalCode',
    'country',
    'distance',
    'countries'
  };
  public static List<String> campaignTypes;
  static {
    cemciSearchSettings = CEMCI_SearchSettings__mdt.getInstance('CEMCI_CandidateSearch');
    campaignTypes = cemciSearchSettings.Campaign_Types__c?.split(',');
  }

  /**
   * @description findContacts Do a SOSL or SOQL search based on the search data provided from UI/JS
   * @param  soslSearchText soslSearchText description
   * @param  searchFilters  searchFilters [Filter data such as stage, title, date range etc]
   * @return                return Contact results to UI/JS to render as Candidate cards
   */
  @Auraenabled(cacheable=true)
  public static CEMCI_SearchDataModel.ContactWrapper findContacts(
    String soslSearchText,
    String searchFilters,
    Integer limitSize,
    Integer offset,
    Id talentPipelineId
  ) {
    Id rtId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('WDR_Candidate').getRecordTypeId();
    String escapedSearchText;
    if (String.isNotBlank(soslSearchText)) {
      escapedSearchText = String.escapeSingleQuotes(soslSearchText);
    }

    Map<String, Object> dataWrapper = (Map<String, Object>) JSON.deserializeUntyped(searchFilters);
    List<CEMCI_SearchDataModel.ClauseWrapper> wrappers = prepareFilterWrappers(dataWrapper, talentPipelineId);
    List<Contact> contacts;
    if (String.isNotBlank(escapedSearchText)) {
      escapedSearchText = prepareSearchTextString(escapedSearchText, dataWrapper);
      contacts = CEMCI_soslSearch.soslSearch(escapedSearchText, wrappers, limitSize, offset);
    } else {
      contacts = CEMCI_soslSearch.soqlSearch(wrappers, limitSize, offset);
    }

    CEMCI_SearchDataModel.ContactWrapper cw = new CEMCI_SearchDataModel.ContactWrapper(
      contacts,
      new List<Id>(),
      new List<Id>()
    );
    return cw;
  }

  @Auraenabled(cacheable=true)
  public static CEMCI_SearchDataModel.SearchPageAttributeValuesOnLoadWrapper getFilterValuesOnPageLoad() {
    List<String> contactStagePicklistValues = new List<String>();
    for (Schema.PicklistEntry pickListVal : Contact.Candidate_Stage__c.getDescribe().getPicklistValues()) {
      contactStagePicklistValues.add(pickListVal.getLabel());
    }

    List<String> contactCountryPicklistValues = new List<String>();
    for (Schema.PicklistEntry pickListVal : Contact.Mailing_Country__c.getDescribe().getPicklistValues()) {
      contactCountryPicklistValues.add(pickListVal.getValue() + '-' + pickListVal.getLabel());
    }

    List<String> candidateSourcePickListValues = new List<String>();
    for (Schema.PicklistEntry pickListVal : Contact.WD_Candidate_Source__c.getDescribe().getPicklistValues()) {
      candidateSourcePickListValues.add(pickListVal.getValue() + '/API/' + pickListVal.getLabel());
    }

    List<String> candidateDegreePickListValues = new List<String>();
    for (Schema.PicklistEntry pickListVal : Contact.WD_Candidate_Degree__c.getDescribe().getPicklistValues()) {
      candidateDegreePickListValues.add(pickListVal.getValue() + '/API/' + pickListVal.getLabel());
    }

    List<String> candidateFieldOfStudyPickListValues = new List<String>();
    for (Schema.PicklistEntry pickListVal : Contact.WD_Field_of_Study__c.getDescribe().getPicklistValues()) {
      candidateFieldOfStudyPickListValues.add(pickListVal.getValue() + '/API/' + pickListVal.getLabel());
    }

    return new CEMCI_SearchDataModel.SearchPageAttributeValuesOnLoadWrapper(
      contactStagePicklistValues,
      contactCountryPicklistValues,
      candidateSourcePickListValues,
      candidateDegreePickListValues,
      candidateFieldOfStudyPickListValues,
      cemciSearchSettings
    );
  }

  @AuraEnabled(cacheable=false)
  public static String createCampaignMembers(List<CampaignMember> campaignMembers, String campaignId) {
    List<CampaignMember> newCampaignMembers = new List<CampaignMember>();
    Set<Id> existingCampaignMembersContactIds = new Set<Id>();
    Database.SaveResult[] results = new List<Database.SaveResult>{};
    String responseMessage = 'No records were selected to add to Campaign';
    if (campaignMembers.isEmpty()) {
      return responseMessage;
    }
    if (campaignId != null) {
      for (CampaignMember cm : [SELECT id, ContactId, campaignId FROM CampaignMember WHERE campaignId = :campaignId]) {
        existingCampaignMembersContactIds.add(cm.ContactId);
      }
      for (Integer i = 0; i < campaignMembers.size(); i++) {
        CampaignMember cm = campaignMembers[i];
        if (!existingCampaignMembersContactIds.contains(cm.ContactId)) {
          newCampaignMembers.add(cm);
        }
      }
    }

    if (Schema.sObjectType.Campaign.isUpdateable() && (Schema.sObjectType.Contact.isUpdateable() || Schema.sObjectType.Lead.isUpdateable())) {
      results = database.insert(newCampaignMembers);
    }
    else{
      throw new InsufficientAccessException('You do not have a permission to add candidate');
    }
    

    Integer successRecords = 0;
    Integer failedRecords = 0;
    for (Integer i = 0; i < results.size(); i++) {
      Database.SaveResult sr = results[i];
      if (!sr.success) {
        failedRecords += 1;
        PF_Logger.log(
          'CEMCI',
          'ERROR',
          String.valueOf(sr.getErrors()),
          'Failed to Create Campaign Members',
          'The following Campaign Member Record failed to be created: ' + campaignMembers[i],
          'CEMCI_CandidateSearchController'
        );
      } else {
        successRecords += 1;
      }
    }
    responseMessage = String.valueOf(successRecords) + ' new campaign members were added to campaign!';
    if (!PF_Logger.logs.isEmpty()) {
      responseMessage =
        failedRecords +
        ' failed to be created. Please try again and if the issue persists please contact your Salesforce Adminstrator';
      PF_Logger.createLogs(PF_Logger.logs);
      return responseMessage;
    }

    return responseMessage;
  }

  @AuraEnabled(cacheable=false)
  public static String createTalentPipelineCandidates(List<Talent_Pipeline_Candidate__c> tpCandidates, String tpId) {
    List<Talent_Pipeline_Candidate__c> newTPCandidates = new List<Talent_Pipeline_Candidate__c>();
    Set<Id> existingCandidateContactIds = new Set<Id>();
    Database.SaveResult[] results = new List<Database.SaveResult>{};
    String responseMessage = 'No records were selected to add to Pipeline';
    if (tpCandidates.isEmpty()) {
      return responseMessage;
    }
    if (tpId != null) {
      for (Talent_Pipeline_Candidate__c tpc : [
        SELECT id, Contact__c, Talent_Pipeline__c
        FROM Talent_Pipeline_Candidate__c
        WHERE Talent_Pipeline__c = :tpId
      ]) {
        existingCandidateContactIds.add(tpc.Contact__c);
      }
      for (Integer i = 0; i < tpCandidates.size(); i++) {
        Talent_Pipeline_Candidate__c tpc = tpCandidates[i];
        if (!existingCandidateContactIds.contains(tpc.Contact__c)) {
          newTPCandidates.add(tpc);
        }
      }
    }

    if (Schema.sObjectType.Talent_Pipeline_Candidate__c.isCreateable()) {
      results = database.insert(newTPCandidates);
    }
    else{
      throw new InsufficientAccessException('You do not have a permission to add candidate');
    }

    Integer successRecords = 0;
    Integer failedRecords = 0;
    for (Integer i = 0; i < results.size(); i++) {
      Database.SaveResult sr = results[i];
      if (!sr.success) {
        failedRecords += 1;
        PF_Logger.log(
          'CEMCI',
          'ERROR',
          String.valueOf(sr.getErrors()),
          'Failed to Create Candidate',
          'The following Talent pipeline Candidate Record failed to be created: ' + tpCandidates[i],
          'CEMCI_CandidateSearchController'
        );
      } else {
        successRecords += 1;
      }
    }
    responseMessage = String.valueOf(successRecords) + ' new candidates were added to Talent Pipeline!';
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

     *                     from the "Job Applications related list--> Candidate --> Contact"
     * @return             return description
     */
  public static List<CEMCI_SearchDataModel.ClauseWrapper> prepareFilterWrappers(
    Map<String, Object> dataWrapper,
    Id talentPipelineId
  ) {
    String contactIdString = getExistingRelatedContacts(talentPipelineId);
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
        } else if (field.equalsIgnoreCase('addressLookup')) {
          String addressString = getValue(field, dataWrapper);
          Map<String, Object> locationData = CEMCI_getGeoLocationHelper.getGeoLocation(addressString);
          locationData.put('distance', getValue('distance', dataWrapper));
          clause = new CEMCI_SearchDataModel.ClauseWrapper(
            getFieldAPIName(field),
            JSON.serialize(locationData),
            getOperator((field))
          );
          clauseWrappers.add(clause);

          continue;
        } else if (setIgnoreSearchValues.contains(field)) {
          continue;
        }
      }
      clause = new CEMCI_SearchDataModel.ClauseWrapper(
        getFieldAPIName(field),
        getValue(field, dataWrapper),
        getOperator((field))
      );
      clauseWrappers.add(clause);
    }

    if (contactIdString != null) {
      clause = new CEMCI_SearchDataModel.ClauseWrapper('Id', contactIdString, getOperator(('relatedContacts')));
      clauseWrappers.add(clause);
    }
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
    apiLabelvsName.put('countries', 'Mailing_Country__c');
    apiLabelvsName.put('candidateSourceValues', 'WD_Candidate_Source__c');
    apiLabelvsName.put('candidateDegreeValues', 'WD_Candidate_Degree__c');
    apiLabelvsName.put('School', 'WD_School__c');
    apiLabelvsName.put('candidateFieldOfStudyValues', 'WD_Field_of_Study__c');
    apiLabelvsName.put('title', 'Title');
    apiLabelvsName.put('currentEmployer', 'AccountId');
    apiLabelvsName.put('fromWeek', 'MRS_App__r.Application_Date__c');
    apiLabelvsName.put('toWeek', 'MRS_App__r.Application_Date__c');
    apiLabelvsName.put('addressLookup', 'Location__c');

    apiLabelvsName.put('onlyAppliedContacts', 'Id');
    apiLabelvsName.put('boomerang', 'Boomerang__c');
    apiLabelvsName.put('tags', 'tags__c');
    apiLabelvsName.put('relatedContacts', 'Id');
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
    apiNamevsOperator.put('countries', 'IN');
    apiNamevsOperator.put('candidateSourceValues', 'IN');
    apiNamevsOperator.put('candidateDegreeValues', 'IN');
    apiNamevsOperator.put('School', 'LIKE');
    apiNamevsOperator.put('candidateFieldOfStudyValues', 'IN');
    apiNamevsOperator.put('title', 'LIKE');
    apiNamevsOperator.put('currentEmployer', 'IN');
    apiNamevsOperator.put('fromWeek', '<');
    apiNamevsOperator.put('toWeek', '>');
    apiNamevsOperator.put('addressLookup', 'DISTANCE');

    apiNamevsOperator.put('onlyAppliedContacts', 'IN');
    apiNamevsOperator.put('boomerang', 'boolean');
    apiNamevsOperator.put('tags', 'LIKE');
    apiNamevsOperator.put('relatedContacts', 'NOT IN');
    return apiNamevsOperator.get(apiName);
  }

  /**
   * @description getValue description
   * @param  fieldName : Range start or Range end field Name (fromWeek and toWeek are the possible values)
   * @param  dataWrapper : Filter data
   * @return return Date in String format based on week number
   */
  private static String getValue(String fieldName, Map<String, Object> dataWrapper) {
    if (fieldName == 'fromWeek' || fieldName == 'toWeek') {
      //return date of 'N' weeks before, where N is an integer and value is sent from UI soql filter
      Date dt = Date.today() - (7 * (Integer.valueOf(dataWrapper.get(fieldName))));
      return String.valueof(dt);
    } else if (fieldName == 'onlyAppliedContacts') {
      return convertCollectionToString(new Set<Id>(CEMCI_CandidateCardController.appliedContactIds), ',');
    } else {
      return String.valueOf(dataWrapper.get(fieldName));
    }
  }
  private static String convertCollectionToString(Set<Id> contactIds, String delim) {
    String[] tmp1 = new List<String>{};
    for (String s : contactIds) {
      tmp1.add(s);
    }
    String returnString = string.join(tmp1, delim);
    return returnString;
  }

  @AuraEnabled(cacheable=true)
  public static List<LookupSearchResult> lookupSearch(String searchTerm, List<String> selectedIds, String objectName) {
    // Prepare query parameters
    searchTerm += '*';

    String icon;
    String searchQuery = 'FIND \'' + string.escapeSingleQuotes(searchTerm) + '\'' + ' IN ALL FIELDS RETURNING ';

    if (objectName == 'Campaign') {
      searchQuery += 'Campaign(Id, Name WHERE id NOT IN :selectedIds';
      if (campaignTypes != null) {
        searchQuery += ' AND Type IN: campaignTypes';
      }
      searchQuery += ')';
      icon = 'standard:campaign';
    } else if (objectName == 'Account') {
      searchQuery += 'Account(Id, Name WHERE id NOT IN :selectedIds)';
      icon = 'standard:account';
    } else if (objectName == 'TalentPipeline') {
      searchQuery += 'Talent_Pipeline__c(Id, Name WHERE id NOT IN :selectedIds)';
      icon = 'utility:people';
    }

    List<List<SObject>> searchResults = new List<List<SObject>>();
    searchResults = Search.query(searchQuery);

    List<LookupSearchResult> results = new List<LookupSearchResult>();
    for (SObject obj : searchResults[0]) {
      results.add(
        new LookupSearchResult(
          obj.Id,
          obj.getSObjectType().getDescribe().getName(),
          icon,
          obj.get('Name').toString(),
          ''
        )
      );
    }
    results.sort();
    return results;
  }

  private static String getExistingRelatedContacts(id talentPipelineId) {
    String labelValue = System.Label.CandidateCard_Exclusions;
    List<String> candidateStageExclusions = labelValue.split(',');
    Set<Id> contactIds = new Set<Id>();
    List<WDR_Application__c> apps = new List<WDR_Application__c>();
    List<Talent_Pipeline_Candidate__c> tpCandidates = new List<Talent_Pipeline_Candidate__c>();
    if (talentPipelineId != null) {
      for (Talent_Pipeline_Candidate__c tpc : [
        SELECT contact__c, Talent_Pipeline__c
        FROM Talent_Pipeline_Candidate__c
        WHERE Talent_Pipeline__c = :talentPipelineId
      ]) {
        contactIds.add(tpc.contact__c);
      }
    } else {
      return null;
    }
    return convertCollectionToString(contactIds, ',');
  }

  private static string prepareSearchTextString(String searchText, Map<String, Object> dataWrapper) {
    Set<String> stringsForTextSearch = new Set<String>{ 'city', 'province', 'postalCode', 'country' };
    List<String> valuesForSearch = new List<String>();
    List<String> listTags = new List<String>();
    String andParameters = '';

    for (String field : dataWrapper.keySet()) {
      if (stringsForTextSearch.contains(field)) {
        Object value = getValue(field, dataWrapper);
        valuesForSearch.add('"' + value + '"');
      }
    }

    if (!valuesForSearch.isEmpty()) {
      andParameters += ' AND (' + String.join(valuesForSearch, ' OR ') + ')';
    }
    if (!listTags.isEmpty()) {
      andParameters += ' AND (' + String.join(listTags, ' OR ') + ')';
    }

    if (andParameters == '') {
      return searchText;
    } else {
      return searchText + andParameters;
    }
  }
}