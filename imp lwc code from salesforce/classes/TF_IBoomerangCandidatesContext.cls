public interface TF_IBoomerangCandidatesContext {

	void setCampaignMembers(List<CampaignMember> campaignMembers);
	void setLeads(Map<Id, Lead> leads);
	void setContacts(Map<Id, Contact> contacts);
	List<CampaignMember> getCampaignMembers();
	Map<Id, Lead> getLeads();
	Map<Id, Contact> getContacts();
}