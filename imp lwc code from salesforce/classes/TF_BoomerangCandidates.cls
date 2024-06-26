public with sharing class TF_BoomerangCandidates implements TF_IBoomerangCandidates {
	
	@TestVisible private TF_IBoomerangCandidatesContext context;
	@TestVisible private Id boomerangCampaignId;
	@TestVisible private Map<Id, Lead> leadsToUpdateMap;
	@TestVisible private Map<Id, Contact> contactsToUpdateMap;
	
	public TF_BoomerangCandidates(Id campaignId) {
		this.setBoomerangCampaignId(campaignId);
		this.leadsToUpdateMap = new Map<Id, Lead>();
		this.contactsToUpdateMap = new Map<Id, Contact>();
	}

	public void setBoomerangCampaignId(Id campaignId) {
		this.boomerangCampaignId = campaignId;
	}

	public Id getBoomerangCampaignId() {
		return (this.boomerangCampaignId);
	}

	public TF_IBoomerangCandidatesContext getContext() {
		if (this.context == null) {
			this.context = new TF_BoomerangCandidatesContext();
		}

		return this.context;
	}

	public void flagLeads(Boolean flag) {
		if (flag == null) return;

		for (CampaignMember cm  : this.getContext().getCampaignMembers()) {
			if (cm.CampaignId != null) {
				if (this.getBoomerangCampaignId() == cm.CampaignId) {
					if (cm.LeadId != null) {
						if (this.getContext().getLeads().containsKey(cm.LeadId) && this.getContext().getLeads().get(cm.LeadId) != null) {
							Lead l = this.getContext().getLeads().get(cm.LeadId);
							if (l.Boomerang__c != flag) {
								l.Boomerang__c = flag;
								this.leadsToUpdateMap.put(l.Id, l);
							}

						}
					}
				}
			}		
		}
	}

	public void flagContacts(Boolean flag) {
		if (flag == null) return;

		for (CampaignMember cm  : this.getContext().getCampaignMembers()) {
			if (cm.CampaignId != null) {
				if (this.getBoomerangCampaignId() == cm.CampaignId) {
					if (cm.ContactId != null) {
						if (this.getContext().getContacts().containsKey(cm.ContactId) && this.getContext().getContacts().get(cm.ContactId) != null) {
							Contact c = this.getContext().getContacts().get(cm.ContactId);
							if (c.Boomerang__c != flag) {
								c.Boomerang__c = flag;
								this.contactsToUpdateMap.put(c.Id, c);
							}

						} 
					}
				}
			}		
		}
	}

	public Map<Id, Lead> getLeadsToUpdate() {
		if (this.leadsToUpdateMap != null) {
			return this.leadsToUpdateMap;
		} else {
			return new Map<Id, Lead>();
		}
	}

	public Map<Id, Contact> getContactsToUpdate() {
		if (this.contactsToUpdateMap != null) {
			return this.contactsToUpdateMap;
		} else {
			return new Map<Id, Contact>();
		}
	}
}