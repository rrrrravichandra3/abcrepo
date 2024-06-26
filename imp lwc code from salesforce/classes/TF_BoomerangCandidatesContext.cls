public with sharing class TF_BoomerangCandidatesContext implements TF_IBoomerangCandidatesContext {
	
	@TestVisible private List<CampaignMember> campaignMembers; 
	@TestVisible private Map<Id, Lead> leadsMap; 
	@TestVisible private Map<Id, Contact> contactsMap; 

	public void setCampaignMembers(List<CampaignMember> campaignMembers) {
		if (campaignMembers != null) {
			if (this.campaignMembers == null) {
				this.campaignMembers = new List<CampaignMember>();
			}

			this.campaignMembers.addAll(campaignMembers); 
		}	
	}

	public void setLeads(Map<Id, Lead> leads) {
		if (leads != null) {
			if (this.leadsMap == null) {
				this.leadsMap = new Map<Id, Lead>();
			}
			
			this.leadsMap.putAll(leads); 
		}
	}

	public void setContacts(Map<Id, Contact> contacts) {
		if (contacts != null) {
			if (this.contactsMap == null) {
				this.contactsMap = new Map<Id, Contact>();
			}
			
			this.contactsMap.putAll(contacts); 
		}
	}

	
	public List<CampaignMember> getCampaignMembers() {
		if (campaignMembers != null) {
			return campaignMembers;
		} else {
			return new List<CampaignMember>();
		}
	}


	public Map<Id, Lead> getLeads() {
		if (leadsMap != null) {
			return leadsMap;
		} else {
			return new Map<Id, Lead>();
		}
	}


	public Map<Id, Contact> getContacts() {
		if (contactsMap != null) {
			return contactsMap;
		} else {
			return new Map<Id, Contact>();
		}
	}
}