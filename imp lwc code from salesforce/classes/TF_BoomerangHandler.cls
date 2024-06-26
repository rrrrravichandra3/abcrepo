public with sharing class TF_BoomerangHandler {
	
	public void handleBoomerangLeadsAndContacts(List<CampaignMember> campaignMembers, Boolean boomerangFlag) {
		try {

			if (campaignMembers == null || boomerangFlag == null) {
				return;
			}

			// Get "Boomerang" campaign Id
			Id boomerangCampaignId;
			if (String.isEmpty(TF2Settings__c.getOrgDefaults().Boomerang_Campaign_Id__c) == false) {
				boomerangCampaignId = TF2Settings__c.getOrgDefaults().Boomerang_Campaign_Id__c;
				// Note 1:  Invalid Id exception will be catched by the catch block below.
				// Note 2: 	Wrong Id (like a Candidate record Id, instead of Campaign Id) will not 
				//			generate an exception, 
			} else {
				return;
			}
		
			// Filter all the CampaignMember records that are referencing that Boomerang campaign.
			List<CampaignMember> boomerangCampaignMembers = new List<CampaignMember>();
			for (CampaignMember cm : campaignMembers) {
				if (cm.CampaignId != null && cm.CampaignId == boomerangCampaignId) {
					boomerangCampaignMembers.add(cm);
				}
				
			}

			// Get the "Lead" and "Contact" records information.
			Set<Id> leadIds = new Set<Id>();
			Set<Id> contactIds = new Set<Id>();
			Map<Id, List<CampaignMember>> campaignMembersByLeadId = new Map<Id, List<CampaignMember>>();
			Map<Id, List<CampaignMember>> campaignMembersByContactId = new Map<Id, List<CampaignMember>>();

			for (CampaignMember cm : boomerangCampaignMembers) {
				if (cm.LeadId != null) {
					leadIds.add(cm.LeadId);
					if (!campaignMembersByLeadId.containsKey(cm.LeadId)) {
						campaignMembersByLeadId.put(cm.LeadId, new List<CampaignMember>());
					}
					campaignMembersByLeadId.get(cm.LeadId).add(cm);

				}
	
				if (cm.ContactId != null) {
					contactIds.add(cm.ContactId);
					if (!campaignMembersByContactId.containsKey(cm.ContactId)) {
						campaignMembersByContactId.put(cm.ContactId, new List<CampaignMember>());
					}
					campaignMembersByContactId.get(cm.ContactId).add(cm);
				}
			}

			Map<Id, Lead> leads = new Map<Id, Lead>([select Id, Name, Boomerang__c from Lead where Id in :leadIds]);
			Map<Id, Contact> contacts = new Map<Id, Contact>([select Id, Name, Boomerang__c from Contact where Id in :contactIds 
															  and RecordType.DeveloperName = 'Candidate']);

			TF_IBoomerangCandidates boomerangs = new TF_BoomerangCandidates(boomerangCampaignId);
			boomerangs.getContext().setCampaignMembers(boomerangCampaignMembers);
			boomerangs.getContext().setLeads(leads);
			boomerangs.getContext().setContacts(contacts);
			boomerangs.setBoomerangCampaignId(boomerangCampaignId);
			boomerangs.flagLeads(boomerangFlag);
			boomerangs.flagContacts(boomerangFlag);
			Map<Id, Lead> leadsToUpdate = boomerangs.getLeadsToUpdate();
			Map<Id, Contact> contactsToUpdate = boomerangs.getContactsToUpdate();


			List<Lead> leadsList = new List<Lead>();
			leadsList.addAll(leadsToUpdate.values());

			// Disable 'all' trigger logic in the leadTrigger trigger.
			TF_TriggerDisable.leadTrigger.add('all');
			Database.SaveResult[] leadsSaveResult = Database.update(leadsList, false);
			TF_TriggerDisable.leadTrigger.remove('all');

			for (Integer i = 0; i < leadsSaveResult.size(); i++) {
				Database.SaveResult sr = leadsSaveResult[i];
				Lead l = leadsList[i];
				if (!sr.isSuccess()) {
					if (campaignMembersByLeadId.containsKey(l.Id)) {
						for (CampaignMember cm : campaignMembersByLeadId.get(l.Id)) {
							String errors = '';
							for (Database.Error err : sr.getErrors()) {
								
								String message = err.getMessage();
								if (!String.isEmpty(message)) {
									if (errors != '') {
										errors += '|';
									}
									errors += message;
								}				
							}
							// We prevent the CampaignMember record to be inserted if the Lead Contact could not be marked as "Boomerang"
							cm.addError(Label.TF_Boomerang_Lead_Error + ' [' + l.Name + '] ' + errors);
						}
					}
				}
			}

			List<Contact> contactList = new List<Contact>();
			contactList.addAll(contactsToUpdate.values());

			// Disable 'all' trigger logic in the ContacUpdates trigger.
			TF_TriggerDisable.ContactUpdates.add('all');
			Database.SaveResult[] contactsSaveResult = Database.update(contactList, false);
			TF_TriggerDisable.ContactUpdates.remove('all');

			for (Integer i = 0; i < contactsSaveResult.size(); i++) {
				Database.SaveResult sr = contactsSaveResult[i];
				Contact c = contactList[i];
				if (!sr.isSuccess()) {
					if (campaignMembersByContactId.containsKey(c.Id)) {
						for (CampaignMember cm : campaignMembersByContactId.get(c.Id)) {
							String errors = '';
							for (Database.Error err : sr.getErrors()) {
								
								String message = err.getMessage();
								if (!String.isEmpty(message)) {
									if (errors != '') {
										errors += '|';
									}
									errors += message;
								}				
							}
							// We prevent the CampaignMember record to be inserted if the related Contact could not be marked as "Boomerang"
							cm.addError(Label.TF_Boomerang_Contact_Error + ' [' + c.Name + '] ' + errors);
						}
					}
				}
			}

		} catch (Exception ex) {
			// General exception mark ALL the records as failed.
			for (CampaignMember cm : campaignMembers) {
				cm.addError(Label.TF_Boomerang_Unexpected_Error + ' ' + ex.getMessage());
			}		
		}
	}
}