public with sharing class CEMCI_CampaignTriggerHandler {
  //*****************************************************************************
  // Method called on After Insert of Campaign Member
  //****************************************************************************/

  public static void onAfterInsert(
    Map<Id, Campaign> newMap,
    List<Campaign> oldList,
    Map<Id, Campaign> oldMap,
    List<Campaign> newList
  ) {
    CEMCI_CampaignMemberStatus.campaigns = newList;
    CEMCI_CampaignMemberStatus.addCampaignMemberStatusBasedOnCampaignType();
  }

  //*****************************************************************************
  // Method called on After update of Campaign Member
  //****************************************************************************/

  public static void onAfterUpdate(
    Map<Id, Campaign> newMap,
    List<Campaign> oldList,
    Map<Id, Campaign> oldMap,
    List<Campaign> newList
  ) {
    List<Campaign> CampaignTypeList = new List<Campaign>();
    for (Campaign camp : newList) {
      if (camp.Type <> oldMap.get(camp.Id).Type) {
        CampaignTypeList.add(camp);
      }
    }
    if (!CampaignTypeList.isEmpty()) {
      CEMCI_CampaignMemberStatus.campaigns = CampaignTypeList;
      CEMCI_CampaignMemberStatus.addCampaignMemberStatusBasedOnCampaignType();
    }
  }
}