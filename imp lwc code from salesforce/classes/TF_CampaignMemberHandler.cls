public with sharing class TF_CampaignMemberHandler implements TF_AfterInsert, TF_BeforeDelete {

	public void afterInsert(List<CampaignMember> campaignMembers) {
		TF_BoomerangHandler boomerangHandler = new TF_BoomerangHandler();
		boomerangHandler.handleBoomerangLeadsAndContacts(campaignMembers, true);
	}

	public void beforeDelete(List<CampaignMember> campaignMembers) {
		TF_BoomerangHandler boomerangHandler = new TF_BoomerangHandler();
		boomerangHandler.handleBoomerangLeadsAndContacts(campaignMembers, false);
	}
}