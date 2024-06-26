/**
 * @description       :
 * @author            : Urvish Shah (ushah)
 * @group             :
 * @last modified on  : 10-11-2022
 * @last modified by  : Urvish Shah (ushah)
 **/
public with sharing class CEMCI_SearchDataModel {
  /**
   * Wrapper class to store filter and its values that come from UI
   */
  public class FilterWrapper {
    public List<String> contactStages { get; set; }
    public List<String> countries { get; set; }
    public String currentEmployer { get; set; }
    public String title { get; set; }
    public Integer fromWeek { get; set; }
    public Integer toWeek { get; set; }
    public Boolean onlyAppliedContacts { get; set; }
    public Boolean boomerang { get; set; }
  }

  /**
   * Wrapper class to be used while Generating WHERE clause from Filter wrapper
   * This where clause will be used in SOSL or SOQL based on the search scenario
   */
  public class ContactWrapper {
    @AuraEnabled
    public List<Contact> contacts { get; set; }
    @AuraEnabled
    public List<Id> appliedContactIds { get; set; }
    @AuraEnabled
    public List<String> reviewedCandidates { get; set; }

    public ContactWrapper(List<Contact> contacts, List<Id> appliedContactIds, List<String> reviewedCandidates) {
      this.contacts = contacts;
      this.appliedContactIds = appliedContactIds;
      this.reviewedCandidates = reviewedCandidates;
    }
  }

  /**
   * Wrapper class to be used to generate an instance of all data that needs to be sent to UI
   */
  public class ClauseWrapper {
    public String field { get; set; }
    public String operator { get; set; }
    public Object value { get; set; }

    public ClauseWrapper(String field, Object value, String operator) {
      this.field = field;
      this.value = value;
      this.operator = operator;
    }
  }

  public class SearchPageAttributeValuesOnLoadWrapper {
    @AuraEnabled
    public List<String> contactStageValues { get; set; }
    @AuraEnabled
    public List<String> contactCountryValues { get; set; }
    @AuraEnabled
    public List<String> candidateSourceValues { get; set; }
    @AuraEnabled
    public List<String> candidateDegreeValues { get; set; }
    @AuraEnabled
    public List<String> candidateFieldOfStudyValues { get; set; }

    @AuraEnabled
    public CEMCI_SearchSettings__mdt cemciSearchSettings { get; set; }

    public SearchPageAttributeValuesOnLoadWrapper(
      List<String> contactStageValues,
      List<String> contactCountryValues,
      List<String> candidateSourceValues,
      List<String> candidateDegreeValues,
      List<String> candidateFieldOfStudyValues,
      CEMCI_SearchSettings__mdt cemciSearchSettings
    ) {
      this.contactStageValues = contactStageValues;
      this.contactCountryValues = contactCountryValues;
      this.candidateSourceValues = candidateSourceValues;
      this.candidateDegreeValues = candidateDegreeValues;
      this.candidateFieldOfStudyValues = candidateFieldOfStudyValues;
      this.cemciSearchSettings = cemciSearchSettings;
    }
  }
}