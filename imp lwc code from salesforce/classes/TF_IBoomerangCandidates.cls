public interface TF_IBoomerangCandidates {
	
	TF_IBoomerangCandidatesContext getContext();

	void setBoomerangCampaignId(Id campaignId);
	Id getBoomerangCampaignId();

	void flagLeads(Boolean flag);
	void flagContacts(Boolean flag);
	Map<Id, Lead> getLeadsToUpdate();
	Map<Id, Contact> getContactsToUpdate();
}