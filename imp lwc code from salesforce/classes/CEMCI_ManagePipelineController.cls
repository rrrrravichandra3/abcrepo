/**
 * @description       :
 * @author            : Kyle Moseley (kmoseley)
 * @group             :
 * @last modified on  : 01-23-2023
 * @last modified by  : Urvish Shah (ushah)
 **/

public with sharing class CEMCI_ManagePipelineController {
  public static CEMCI_SearchSettings__mdt cemciSearchSettings;
  public static List<String> campaignTypes;
  static {
    cemciSearchSettings = CEMCI_SearchSettings__mdt.getInstance('CEMCI_CandidateSearch');
    campaignTypes = cemciSearchSettings.Campaign_Types__c?.split(',');
  }

  /**
   * @description getPipelineCandidates - get ALL Talent_Pipeline_Candidate__c records related to a specific Pipeline
   * @param  pipelineId     Id of the Talent_Pipeline__c
   * @return                return List<CandidateWrapper>
   */
  @Auraenabled(cacheable=false)
  public static List<CandidateWrapper> getPipelineCandidates(Id pipelineId) {
    List<CandidateWrapper> results = new List<CandidateWrapper>();

    Set<Id> contactIds = new Set<Id>();

    List<Talent_Pipeline_Candidate__c> cands = [
      SELECT
        id,
        Contact__c,
        Contact__r.Name,
        Contact__r.Title,
        Contact__r.Phone,
        Contact__r.Email,
        CreatedDate,
        CreatedBy.Name,
        Contact__r.Owner.Alias,
        Contact__r.Text_Resume__c,
        Contact__r.MRS_App__r.Application_Date__c,
        Contact__r.MRS_App__r.Job__r.Name
      FROM Talent_Pipeline_Candidate__c
      WHERE Talent_Pipeline__c = :pipelineId
    ];

    for (Talent_Pipeline_Candidate__c c : cands) {
      CandidateWrapper cand = new CandidateWrapper(c);
      results.add(cand);
    }

    return results;
  }

  /**
   * Wrapper class to be used to generate an instance of all data that needs to be sent to UI
   */

  public class CandidateWrapper {
    @AuraEnabled
    public id Id { get; set; }
    @AuraEnabled
    public String Name { get; set; }
    @AuraEnabled
    public String Email { get; set; }
    @AuraEnabled
    public String Title { get; set; }
    @AuraEnabled
    public String Phone { get; set; }
    @AuraEnabled
    public Datetime AddedDate { get; set; }
    @AuraEnabled
    public String AddedBy { get; set; }
    @AuraEnabled
    public Id ContactId { get; set; }
    @AuraEnabled
    public String ContactOwner { get; set; }
    @AuraEnabled
    public String TextResume { get; set; }
    @AuraEnabled
    public String ContactURL { get; set; }
    @AuraEnabled
    public Boolean textResumeIsDisabled { get; set; }
    @AuraEnabled
    public String MRSApplication { get; set; }
    @AuraEnabled
    public String MRSApplicationJobURL { get; set; }

    public CandidateWrapper(Talent_Pipeline_Candidate__c cand) {
      this.Id = cand.Id;
      this.Name = cand.Contact__r.Name;
      this.Email = cand.Contact__r.Email;
      this.Title = cand.Contact__r.Title;
      this.Phone = cand.Contact__r.Phone;
      this.AddedDate = cand.CreatedDate;
      this.AddedBy = cand.CreatedBy.Name;
      this.ContactId = cand.Contact__c;
      this.ContactOwner = cand.Contact__r.Owner.Alias;
      this.TextResume = cand.Contact__r.Text_Resume__c;
      this.ContactURL = '/' + cand.Contact__c;
      this.textResumeIsDisabled = cand.Contact__r.Text_Resume__c == null ? true : false;
      if (cand.Contact__r.MRS_App__r != null && cand.Contact__r.MRS_App__r.Job__r != null) {
        this.MRSApplication = cand.Contact__r.MRS_App__r.Job__r.Name;
        this.MRSApplicationJobURL = '/' + cand.Contact__r.MRS_App__r.Job__c;
        if (cand.Contact__r.MRS_App__r.Application_Date__c != null) {
          this.MRSApplication += ', Date Applied - ' + cand.Contact__r.MRS_App__r.Application_Date__c.format();
        }
      }
    }
  }

  /**
   * @description delete the pipeline Candidates that were selected in the UI to delete.
   * @param  selectedRecords     List<Talent_Pipeline_Candidate__c>
   */
  @auraEnabled
  public static void deletePipelineCandidates(List<Talent_Pipeline_Candidate__c> selectedRecords) {
    if (Schema.sObjectType.Talent_Pipeline_Candidate__c.isDeletable()) {
      delete selectedRecords;
    }
    else{
      throw new InsufficientAccessException('You do not have a permission to remove candidate');
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<LookupSearchResult> lookupSearch(String searchTerm, List<String> selectedIds, String objectName) {
    // Prepare query parameters
    searchTerm += '*';

    String icon;
    String searchQuery = 'FIND \'' + string.escapeSingleQuotes(searchTerm) + '\'' + ' IN ALL FIELDS RETURNING ';

    searchQuery += 'Campaign(Id, Name WHERE id NOT IN :selectedIds';
    /*
        if(campaignTypes != null){
            searchQuery += ' AND Type IN: campaignTypes';
        }
        */
    searchQuery += ')';
    icon = 'standard:campaign';

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
}