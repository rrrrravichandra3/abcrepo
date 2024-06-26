/**
 * @description       : 
 * @author            : Urvish Shah (ushah)
 * @group             : 
 * @last modified on  : 02-15-2023
 * @last modified by  : Urvish Shah (ushah)
**/
public with sharing class CEMCI_CampaignMemberTriggerHandler {
  //*****************************************************************************
  // Method called on before Insert of Campaign Member
  //****************************************************************************/

  public static void onBeforeInsert(List<CampaignMember> newList) {
    CEMCI_CampaignMembers.campaignMembers = newList;
    CEMCI_CampaignMembers.populateProcessingFields();

    if (CEMCI_CampaignMembers.validCampaignMembers != null && CEMCI_CampaignMembers.validCampaignMembers.size() > 0) {
      CEMCI_CampaignMembers.copyOptInFields();
      CEMCI_CampaignMembers.updateApplicationCounts();
    }
  }

  //*****************************************************************************
  // Method called on before Update of Campaign member
  //****************************************************************************/

  public static void onBeforeUpdate(
    List<CampaignMember> newList,
    Map<Id, CampaignMember> newMap,
    List<CampaignMember> oldList,
    Map<Id, CampaignMember> oldMap
  ) {
    CEMCI_CampaignMembers.campaignMembers = newList;
    CEMCI_CampaignMembers.oldCampaignMembers = oldList;
    CEMCI_CampaignMembers.newCampaignMemberMap = newMap;
    CEMCI_CampaignMembers.oldCampaignMemberMap = oldMap;
    CEMCI_CampaignMembers.populateProcessingFields();
    if (CEMCI_CampaignMembers.validCampaignMembers != null && CEMCI_CampaignMembers.validCampaignMembers.size() > 0) {
      CEMCI_CampaignMembers.updateApplicationCounts();
    }
  }

  public static void onBeforeDelete(
    List<CampaignMember> oldList,
    Map<Id, CampaignMember> oldMap
  ) {
    CEMCI_CampaignMembers.oldCampaignMembers = oldList;
    CEMCI_CampaignMembers.oldCampaignMemberMap = oldMap;
    CEMCI_CampaignMembers.validateCampaignMemberDeletion();
  }
  
  //*****************************************************************************
  // Method called on After Insert of Campaign Member
  //****************************************************************************/

  public static void onAfterInsert(
    Map<Id, CampaignMember> newMap,
    List<CampaignMember> oldList,
    Map<Id, CampaignMember> oldMap,
    List<CampaignMember> newList
  ) {
    CEMCI_CampaignMembers.campaignMembers = newList;
    CEMCI_CampaignMembers.oldCampaignMembers = oldList;
    CEMCI_CampaignMembers.newCampaignMemberMap = newMap;
    CEMCI_CampaignMembers.oldCampaignMemberMap = oldMap;
    CEMCI_CampaignMembers.populateProcessingFields();
    if (CEMCI_CampaignMembers.validCampaignMembers != null && CEMCI_CampaignMembers.validCampaignMembers.size() > 0) {
      CEMCI_CampaignMembers.updateDatesFromCampaign();
    }
    CEMCI_CampaignMembers.creatingAuthorizationConsentForCampaignMembers();
  }

  //*****************************************************************************
  // Method called on After Update of Campaign Member
  //****************************************************************************/

  public static void onAfterUpdate(
    Map<Id, CampaignMember> newMap,
    List<CampaignMember> oldList,
    Map<Id, CampaignMember> oldMap,
    List<CampaignMember> newList
  ) {
    CEMCI_CampaignMembers.campaignMembers = newList;
    CEMCI_CampaignMembers.oldCampaignMembers = oldList;
    CEMCI_CampaignMembers.newCampaignMemberMap = newMap;
    CEMCI_CampaignMembers.oldCampaignMemberMap = oldMap;
    CEMCI_CampaignMembers.populateProcessingFields();
    if (CEMCI_CampaignMembers.validCampaignMembers != null && CEMCI_CampaignMembers.validCampaignMembers.size() > 0) {
      CEMCI_CampaignMembers.updateDatesFromCampaign();
    }
    CEMCI_CampaignMembers.creatingAuthorizationConsentForCampaignMembers();
  }
}