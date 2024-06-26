/**
 * @description       :
 * @author            : Urvish Shah (ushah)
 * @group             :
 * @last modified on  : 06-13-2022
 * @last modified by  : Venkata Akash Gupta Patti (akashpatti)
 **/
public with sharing class CEMCI_ManageCandidatePool {
  @Auraenabled
  public static List<Candidate_Match__c> getMatchingCandidatesForJobReq(Id jobReqId) {
    return [
      SELECT
        WD_Job_Requisition__r.Name,
        WD_Job_Requisition__r.Country__c,
        Candidate__r.Name,
        Candidate__r.Original_Lead_Source__c,
        Status__c,
        WD_Job_Requisition__c,
        Candidate__r.LinkedIn_Profile_URL__c,
        Candidate__r.Account.Name,
        Candidate__r.Title,
        Candidate__r.Email
      FROM Candidate_Match__c
      WHERE WD_Job_Requisition__c = :jobReqId
    ];
  }

  /**
   * @description getListofStages : statuses will be returned to UI to be used in manage candidate pool
   * @return   return List<String>
   * All Picklist values of Candidate_Match__c.Status__c field
   */
  @Auraenabled(cacheable=true)
  public static List<string> getListofStages() {
    List<String> result = new List<String>();
    for (Schema.PicklistEntry pickListVal : Candidate_Match__c.Status__c.getDescribe().getPicklistValues()) {
      result.add(pickListVal.getLabel());
    }
    return result;
  }

  @Auraenabled
  public static void updateCandidateStatus(Id candidateId, String newStatus) {
    try {
      Candidate_Match__c candidate = new Candidate_Match__c(Id = candidateId, Status__c = newStatus);
      update candidate;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @Auraenabled
  public static void removeCandidateFromPool(Id id) {
    try {
      delete new Candidate_Match__c(Id = id);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @Auraenabled
  public static Boolean hasAccess(Id jobRecId) {
    try {
      String hiringManager = [SELECT Hiring_Manager__c FROM WDR_Job__c WHERE Id = :jobRecId].Hiring_Manager__c;
      Id currentUserId = UserInfo.getUserId();
      Boolean hasPermission = FeatureManagement.checkPermission('CEMCI_Access_MCP');
      if (hiringManager == currentUserId || hasPermission) {
        return true;
      }
      return false;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static void createChatterPost(String content, Id parentId) {
    try {
      //Adding a Text post
      FeedItem post = new FeedItem();
      post.ParentId = parentId; //eg. Opportunity id, custom object id..
      post.Body = content;
      insert post;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}