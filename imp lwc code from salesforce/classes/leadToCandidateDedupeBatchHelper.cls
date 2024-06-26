public with sharing class leadToCandidateDedupeBatchHelper {

	public static String PRIORITY1 = 'Email';
	public static String PRIORITY2 = 'LinkedIn URL';
	public static String PRIORITY3 = 'Last Name and Emp Org 1';


    /***********************************************************************************************************/

	private static Lead_Contact_Match__c createDedupedRecord(Lead matchedLead, Contact currentContact, String matchingCriteria){
		Lead_Contact_Match__c currentEntry = new Lead_Contact_Match__c();
   		currentEntry.Contact__c = currentContact.Id;
   		currentEntry.Matching_Criteria__c = matchingCriteria;
   		currentEntry.Contact_Name__c = currentContact.Name;
   		currentEntry.Lead_Name__c = matchedLead.Name;
   		currentEntry.Lead_Outbound_Sourcer__c = matchedLead.Outbound_Sourcer__c;
   		return currentEntry;
	}

    /***********************************************************************************************************/
	
	public static void removeMatchedLeads(List<Lead> allLeads, Map<Id, Id> leadIdToMatchingContactId){
		List<Lead> unMatchedLeads = new List<Lead>();
		for(Lead currLead : allLeads){
			if(!(leadIdToMatchingContactId.containsKey(currLead.Id))){
				unMatchedLeads.add(currLead);
			}
		}
		allLeads.clear();
		allLeads.addAll(unMatchedLeads);
	}


	/***********************************************************************************************************/

	public static List<Lead_Contact_Match__c> matchEmail(List<Lead> allLeads, Set<Id> contactsAlreadyDedupedThisBatchInstance, Map<Id, Id> leadIdToMatchingContactId, Map<Id, Lead> leadIdToLeadRecordMap, Map<Id, Contact> contactIdToContactRecordMap){

		
		List<Lead_Contact_Match__c> emailMatchedDeDupes = new List<Lead_Contact_Match__c>();
		
		Map<String, Lead> emailToLeadRecordMap = new Map<String, Lead>();

   		for(Lead currLead : allLeads){
   			//Map Email => Lead
   			if((currLead.Email != null) && (currLead.Email != '')){
   				emailToLeadRecordMap.put(currLead.Email, currLead);
   			}
   		}

   		if(emailToLeadRecordMap.size()>0){
   			//query all contacts with matching email
   			Map<Id,Contact> matchingEmailContactRecordsMap = new Map<Id,Contact>([Select Id, Name, Email, LastName, Outbound_Sourcer__c, 
   				                                                                         Lead_Account__c, LeadSource, Phone, HomePhone,
   				                                                                         MobilePhone, MailingCity, ts2__EmployerOrgName_1__c,
   				                                                                         ts2__Employer1Title__c, MailingState, MailingPostalCode,
   				                                                                         Facebook_Profile__c, ts2__LinkedIn_Profile__c, Rating__c, Number_of_Reach_Outs__c 
   				                                                                    from Contact 
   				                                                                    where Email IN :emailToLeadRecordMap.keySet() 
   				                                                                      AND Id NOT IN :contactsAlreadyDedupedThisBatchInstance 
   				                                                                      AND Id NOT IN :leadIdToMatchingContactId.values()
   				                                                                  ]);
   			if(matchingEmailContactRecordsMap.size()>0){
   				//Create Email to Contact Record
   				Map<String, Contact> emailToContactRecordMap = new Map<String, Contact>();
   				for(Contact currContact : matchingEmailContactRecordsMap.values()){
   					if((currContact.Email != null) && (currContact.Email != '')){
   						emailToContactRecordMap.put(currContact.Email,currContact);
   					}
   				}

   				//Match same email in Lead and Contact
   				for(String currContactEmail : emailToContactRecordMap.keySet()){
   					if(emailToLeadRecordMap.containsKey(currContactEmail)){
   						//Enter them into Maps
   						Lead matchedLead = emailToLeadRecordMap.get(currContactEmail);
   						Contact currentContact = emailToContactRecordMap.get(currContactEmail);
   						leadIdToMatchingContactId.put(matchedLead.Id, currentContact.Id);
   						leadIdToLeadRecordMap.put(matchedLead.Id, matchedLead);
   						contactIdToContactRecordMap.put(currentContact.Id, currentContact);
   						//Create a Lead_Contact_Match__c record
   						emailMatchedDeDupes.add(createDedupedRecord(matchedLead,currentContact,PRIORITY1));
   					}
   				}
   			}
   		}

   		return emailMatchedDeDupes;
	}


	/***********************************************************************************************************/

	public static List<Lead_Contact_Match__c> matchLinkedInURL(List<Lead> allLeads, Set<Id> contactsAlreadyDedupedThisBatchInstance, Map<Id, Id> leadIdToMatchingContactId, Map<Id, Lead> leadIdToLeadRecordMap, Map<Id, Contact> contactIdToContactRecordMap){
		List<Lead_Contact_Match__c> linkedInMatchedDeDupes = new List<Lead_Contact_Match__c>();
		Map<String, Lead> linkedInURLToLeadRecordMap = new Map<String, Lead>();

		//For lead linkedIns, create a set with http:// and https:// prepended to plain url
		Set<String> leadLinkedInwithHttp = new Set<String>();

   		for(Lead currLead : allLeads){
   			//Map URL => Lead
   			if((currLead.Linked_In_URL__c != null) && (currLead.Linked_In_URL__c != '')){
   				String currLeadURL = currLead.Linked_In_URL__c;
   				currLeadURL = currLeadURL.removeStart('http://');
   				currLeadURL = currLeadURL.removeStart('https://');
			    linkedInURLToLeadRecordMap.put(currLeadURL, currLead);

			    leadLinkedInwithHttp.add('http://'+currLeadURL);
			    leadLinkedInwithHttp.add('https://'+currLeadURL);
			}
   		}

   		if(linkedInURLToLeadRecordMap.size()>0){
   			//query all contacts with matching URL
   			Map<Id,Contact> matchingLinkedInContactRecordsMap = new Map<Id,Contact>([Select Id, Name, Email, LastName, Outbound_Sourcer__c,
	   				                                                                         Lead_Account__c, LeadSource, Phone, HomePhone,
	   				                                                                         MobilePhone, MailingCity, ts2__EmployerOrgName_1__c,
	   				                                                                         ts2__Employer1Title__c, MailingState, MailingPostalCode,
	   				                                                                         Facebook_Profile__c, ts2__LinkedIn_Profile__c, Rating__c, Number_of_Reach_Outs__c 
   				                                                                       from Contact 
   				                                                                       where (ts2__LinkedIn_Profile__c IN :linkedInURLToLeadRecordMap.keySet() 
   				                                                                              OR ts2__LinkedIn_Profile__c IN :leadLinkedInwithHttp
   				                                                                             )
   				                                                                         AND Id NOT IN :contactsAlreadyDedupedThisBatchInstance
   				                                                                         AND Id NOT IN :leadIdToMatchingContactId.values()
   				                                                                    ]);
   			if(matchingLinkedInContactRecordsMap.size()>0){
   				//Create linkedin to Contact Record Map
   				Map<String, Contact> linkedInURLToContactRecordMap = new Map<String, Contact>();
   				for(Contact currContact : matchingLinkedInContactRecordsMap.values()){
   					if((currContact.ts2__LinkedIn_Profile__c != null) && (currContact.ts2__LinkedIn_Profile__c != '')){
   						String currContactURL = currContact.ts2__LinkedIn_Profile__c;
   						currContactURL = currContactURL.removeStart('http://');
   						currContactURL = currContactURL.removeStart('https://');
   						linkedInURLToContactRecordMap.put(currContactURL,currContact);
   					}
   				}

   				//Match same email in Lead and Contact
   				for(String currURL : linkedInURLToContactRecordMap.keySet()){
   					if(linkedInURLToLeadRecordMap.containsKey(currURL)){
   						//Enter them into Maps
   						Lead matchedLead = linkedInURLToLeadRecordMap.get(currURL);
   						Contact currentContact = linkedInURLToContactRecordMap.get(currURL);
   						leadIdToMatchingContactId.put(matchedLead.Id, currentContact.Id);
   						leadIdToLeadRecordMap.put(matchedLead.Id, matchedLead);
   						contactIdToContactRecordMap.put(currentContact.Id, currentContact);
   						//Create a Lead_Contact_Match__c record
   						linkedInMatchedDeDupes.add(createDedupedRecord(matchedLead,currentContact,PRIORITY2));
   					}
   				}
   			}
   		}
   		return linkedInMatchedDeDupes;
	}

	/***********************************************************************************************************/


	public static List<Lead_Contact_Match__c> matchLastNameEmployeeOrg(List<Lead> allLeads, Set<Id> contactsAlreadyDedupedThisBatchInstance, Map<Id, Id> leadIdToMatchingContactId, Map<Id, Lead> leadIdToLeadRecordMap, Map<Id, Contact> contactIdToContactRecordMap){
		List<Lead_Contact_Match__c> lastNameEmpOrgMatches = new List<Lead_Contact_Match__c>();
		Map<String, Lead> lastNameEmpOrgNameToLeadRecordMatch = new Map<String, Lead>();
		Set<String> leadLastNames = new Set<String>();
		Set<String> leadEmpOrgNames = new Set<String>();
        //Create necessary sets and maps for query
		for(Lead currLead : allLeads){
			String lastName = '';
			String empOrgName = '';
			if((currLead.LastName != null) && (currLead.LastName !='')){lastName = currLead.LastName;}
			if((currLead.Employer_Organization_Name_1__c != null) && (currLead.Employer_Organization_Name_1__c !='')){empOrgName = currLead.Employer_Organization_Name_1__c;}
			String concatLastNameEmpOrg = lastName + empOrgName;
			if((lastName.length()>0) && (empOrgName.length()>0)){
				leadLastNames.add(lastName);
				leadEmpOrgNames.add(empOrgName);
				lastNameEmpOrgNameToLeadRecordMatch.put(concatLastNameEmpOrg, currLead);
			}
		}

		if(lastNameEmpOrgNameToLeadRecordMatch.size()>0){
			Map<String, Contact> lastNameEmpOrgNameToContactRecordMatch = new Map<String, Contact>();
			List<Contact> matchingLastNameEmpOrgContacts = [ Select Id, Name, Email, LastName, Outbound_Sourcer__c,
	                                                                 Lead_Account__c, LeadSource, Phone, HomePhone,
	                                                                 MobilePhone, MailingCity, ts2__EmployerOrgName_1__c,
	                                                                 ts2__Employer1Title__c, MailingState, MailingPostalCode,
	                                                                 Facebook_Profile__c, ts2__LinkedIn_Profile__c, Rating__c, Number_of_Reach_Outs__c 
			                                                   from Contact 
			                                                   where LastName IN :leadLastNames
			                                                     AND ts2__EmployerOrgName_1__c IN :leadEmpOrgNames
			                                                     AND Id NOT IN :contactsAlreadyDedupedThisBatchInstance 
			                                                     AND Id NOT IN :leadIdToMatchingContactId.values()
			                                                     ];
			for(Contact currContact : matchingLastNameEmpOrgContacts){
				String lastName = '';
				String empOrgName = '';
				if((currContact.LastName != null) && (currContact.LastName != '')){lastName = currContact.LastName;}
				if((currContact.ts2__EmployerOrgName_1__c != null) && (currContact.ts2__EmployerOrgName_1__c != '')){empOrgName = currContact.ts2__EmployerOrgName_1__c;}
				String conCatContactLastNameEmpOrg = lastName + empOrgName;
				if((lastName.length()>0) && (empOrgName.length()>0)){
					lastNameEmpOrgNameToContactRecordMatch.put(conCatContactLastNameEmpOrg, currContact);
				}
			}

			for(String currContactKey : lastNameEmpOrgNameToContactRecordMatch.keySet()){
				if(lastNameEmpOrgNameToLeadRecordMatch.containsKey(currContactKey)){
					//Enter them into Maps
					Lead matchedLead = lastNameEmpOrgNameToLeadRecordMatch.get(currContactKey);
					Contact currentContact = lastNameEmpOrgNameToContactRecordMatch.get(currContactKey);
					leadIdToMatchingContactId.put(matchedLead.Id, currentContact.Id);
					leadIdToLeadRecordMap.put(matchedLead.Id, matchedLead);
					contactIdToContactRecordMap.put(currentContact.Id, currentContact);
					//Create a Lead_Contact_Match__c record
					lastNameEmpOrgMatches.add(createDedupedRecord(matchedLead,currentContact,PRIORITY3));
				}
			}
		}
		return lastNameEmpOrgMatches;
	}

	/***********************************************************************************************************/

	public static List<Contact> updateMatchedContacts(Map<Id, Id> leadIdToMatchingContactId, Map<Id, Lead> leadIdToLeadRecordMap, Map<Id, Contact> contactIdToContactRecordMap){

		List<Contact> contactsToBeUpdated = new List<Contact>();
		
		//For every lead
		for(Id currentLeadId : leadIdToLeadRecordMap.keySet()){
			Boolean contactRequiresUpdate = false;
			Lead currentLead = leadIdToLeadRecordMap.get(currentLeadId);
			Contact matchingContact = contactIdToContactRecordMap.get(leadIdToMatchingContactId.get(currentLeadId));
			//carry over fields from Lead to Contact
				//Lead Account
				if(((matchingContact.Lead_Account__c == null) || (matchingContact.Lead_Account__c =='')) && ((currentLead.Company != null) && (currentLead.Company != ''))){
					matchingContact.Lead_Account__c = currentLead.Company;
					contactRequiresUpdate = true;
				}
				//Lead Source
				if(((matchingContact.LeadSource == null) || (matchingContact.LeadSource =='')) && ((currentLead.LeadSource != null) && (currentLead.LeadSource != ''))){
					matchingContact.LeadSource = currentLead.LeadSource;
					contactRequiresUpdate = true;
				}
				//Phone
				if(((matchingContact.Phone == null) || (matchingContact.Phone =='')) && ((currentLead.Phone != null) && (currentLead.Phone != ''))){
					matchingContact.Phone = currentLead.Phone;
					contactRequiresUpdate = true;
				}
				//Home Phone
				if(((matchingContact.HomePhone == null) || (matchingContact.HomePhone =='')) && ((currentLead.Home_Phone__c != null) && (currentLead.Home_Phone__c != ''))){
					matchingContact.HomePhone = currentLead.Home_Phone__c;
					contactRequiresUpdate = true;
				}
				//Mobile Phone
				if(((matchingContact.MobilePhone == null) || (matchingContact.MobilePhone =='')) && ((currentLead.MobilePhone != null) && (currentLead.MobilePhone != ''))){
					matchingContact.MobilePhone = currentLead.MobilePhone;
					contactRequiresUpdate = true;
				}
				//Mailing City
				if(((matchingContact.MailingCity == null) || (matchingContact.MailingCity =='')) && ((currentLead.Mailing_City__c != null) && (currentLead.Mailing_City__c != ''))){
					matchingContact.MailingCity = currentLead.Mailing_City__c;
					contactRequiresUpdate = true;
				}
				//Employer Organization Name 1
				if(((matchingContact.ts2__EmployerOrgName_1__c == null) || (matchingContact.ts2__EmployerOrgName_1__c =='')) && ((currentLead.Employer_Organization_Name_1__c != null) && (currentLead.Employer_Organization_Name_1__c != ''))){
					matchingContact.ts2__EmployerOrgName_1__c = currentLead.Employer_Organization_Name_1__c;
					contactRequiresUpdate = true;
				}
				//Employer 1 Title
				if(((matchingContact.ts2__Employer1Title__c == null) || (matchingContact.ts2__Employer1Title__c =='')) && ((currentLead.Employer_1_Title__c != null) && (currentLead.Employer_1_Title__c != ''))){
					matchingContact.ts2__Employer1Title__c = currentLead.Employer_1_Title__c;
					contactRequiresUpdate = true;
				}
				//State/Province
				if(((matchingContact.MailingState == null) || (matchingContact.MailingState =='')) && ((currentLead.Mailing_State_Province__c != null) && (currentLead.Mailing_State_Province__c != ''))){
					matchingContact.MailingState = currentLead.Mailing_State_Province__c;
					contactRequiresUpdate = true;
				}
				//ZIP Code
				if(((matchingContact.MailingPostalCode == null) || (matchingContact.MailingPostalCode =='')) && ((currentLead.Mailing_Zip_Postal_Code__c != null) && (currentLead.Mailing_Zip_Postal_Code__c != ''))){
					matchingContact.MailingPostalCode = currentLead.Mailing_Zip_Postal_Code__c;
					contactRequiresUpdate = true;
				}
				//Facebook Profile
				if(((matchingContact.Facebook_Profile__c == null) || (matchingContact.Facebook_Profile__c =='')) && ((currentLead.Facebook_Profile__c != null) && (currentLead.Facebook_Profile__c != ''))){
					matchingContact.Facebook_Profile__c = currentLead.Facebook_Profile__c;
					contactRequiresUpdate = true;
				}
				//LinkedIn URL
				if(((matchingContact.ts2__LinkedIn_Profile__c == null) || (matchingContact.ts2__LinkedIn_Profile__c =='')) && ((currentLead.Linked_In_URL__c != null) && (currentLead.Linked_In_URL__c != ''))){
					matchingContact.ts2__LinkedIn_Profile__c = currentLead.Linked_In_URL__c;
					contactRequiresUpdate = true;
				}
				//Rating
				if(((matchingContact.Rating__c == null) || (matchingContact.Rating__c =='')) && ((currentLead.Rating__c != null) && (currentLead.Rating__c != ''))){
					matchingContact.Rating__c = currentLead.Rating__c;
					contactRequiresUpdate = true;
				}
				//Number of Reachouts
				if(((matchingContact.Number_of_Reach_Outs__c == null) || (matchingContact.Number_of_Reach_Outs__c =='')) && ((currentLead.Number_of_Reach_Outs__c != null) && (currentLead.Number_of_Reach_Outs__c != ''))){
					matchingContact.Number_of_Reach_Outs__c = currentLead.Number_of_Reach_Outs__c;
					contactRequiresUpdate = true;
				}
				//Outbound Sourcer
				if((matchingContact.Outbound_Sourcer__c == null) && (currentLead.Outbound_Sourcer__c != null)){
					matchingContact.Outbound_Sourcer__c = currentLead.Outbound_Sourcer__c;
					contactRequiresUpdate = true;
				}
			// add the contact in the list of contacts to be updated
			if(contactRequiresUpdate == true){
				contactsToBeUpdated.add(matchingContact);
			}

		}
		return contactsToBeUpdated;

	}

	/***********************************************************************************************************/

	public static List<Task> transferTasksToContacts(Map<Id, Id> leadIdToMatchingContactId){
		List<Task> tasksToBeUpdated = new List<Task>();
		List<Task> tasksOfMatchingLeads = [Select Id, whoId from Task where whoId IN :leadIdToMatchingContactId.keySet()];
		for(Task currentTask : tasksOfMatchingLeads){
			Id thisTaskParentLeadId = currentTask.WhoId;
			Id thisTaskParentContactId = leadIdToMatchingContactId.get(thisTaskParentLeadId);
			if(thisTaskParentContactId != null){
				currentTask.WhoId = thisTaskParentContactId;
                tasksToBeUpdated.add(currentTask);
			}
		}
		return tasksToBeUpdated;
	}

	/***********************************************************************************************************/

	public static List<Event> transferEventsToContacts(Map<Id,Id> leadIdToMatchingContactId){
		List<Event> eventsToBeUpdated = new List<Event>();
		List<Event> eventsOfMatchingLeads = [Select Id, whoId from Event where whoId IN :leadIdToMatchingContactId.keySet()];
		for(Event currentEvent : eventsOfMatchingLeads){
			Id thisEventParentLeadId = currentEvent.WhoId;
			Id thisEventParentContactId = leadIdToMatchingContactId.get(thisEventParentLeadId);
			if(thisEventParentContactId != null){
				currentEvent.WhoId = thisEventParentContactId;
				eventsToBeUpdated.add(currentEvent);
			}
		}
		return eventsToBeUpdated;
	}

	/***********************************************************************************************************/

	public static List<Candidate_Secure_Info__c> transferSecureInfoToContacts(Map<Id,Id> leadIdToMatchingContactId){
		List<Candidate_Secure_Info__c> secureInfoToBeUpdated = new List<Candidate_Secure_Info__c>();
		List<Candidate_Secure_Info__c> secureInfoFromMatchingLeads = [Select Id, Lead__c, Candidate__c from Candidate_Secure_Info__c where Lead__c IN :leadIdToMatchingContactId.keySet()];
		for(Candidate_Secure_Info__c currentSecureInfo : secureInfoFromMatchingLeads){
			Id thisSecureInfoParentLeadId = currentSecureInfo.Lead__c;
			Id thisSecureInfoParentContactId = leadIdToMatchingContactId.get(thisSecureInfoParentLeadId);
			if(thisSecureInfoParentContactId != null){
				currentSecureInfo.Candidate__c = thisSecureInfoParentContactId;
				currentSecureInfo.Lead__c = null;
				secureInfoToBeUpdated.add(currentSecureInfo);
			}
		}
		return secureInfoToBeUpdated;
	}

	/***********************************************************************************************************/

	public static List<Note> transferNotesToContacts(Map<Id,Id> leadIdToMatchingContactId, List<Note> notesToBeDeleted){
		List<Note> newNotesToBeCreated = new List<Note>();
		List<Note> notesFromMatchingLeads = [Select Id,Title,Body,IsPrivate,OwnerId,ParentId from Note where ParentId IN :leadIdToMatchingContactId.keySet()];
		for(Note currentNoteFromLead : notesFromMatchingLeads){
			Id thisNoteParentLeadId = currentNoteFromLead.ParentId;
			Id newNoteParentContactId = leadIdToMatchingContactId.get(thisNoteParentLeadId);
			if(newNoteParentContactId != null){
				Note newClonedNote = new Note();
				newClonedNote.Title = currentNoteFromLead.Title;
				newClonedNote.Body = currentNoteFromLead.Body;
				newClonedNote.OwnerId = currentNoteFromLead.OwnerId;
				newClonedNote.IsPrivate = currentNoteFromLead.IsPrivate;
				newClonedNote.ParentId = newNoteParentContactId;

				newNotesToBeCreated.add(newClonedNote);
				notesToBeDeleted.add(currentNoteFromLead);
			}
		}
		return newNotesToBeCreated;
	}

	/***********************************************************************************************************/

	public static List<Attachment> transferAttachmentsToContacts(Map<Id,Id> leadIdToMatchingContactId, List<Attachment> attachmentsToBeDeleted){
		List<Attachment> newAttachmentsToBeCreated = new List<Attachment>();
		List<Attachment> attachmentsFromMatchingLeads = [Select Id, Name, Body, Description, ContentType, IsPrivate, OwnerId, ParentId FROM Attachment where ParentId IN :leadIdToMatchingContactId.keySet()];
		for(Attachment currentAttachment : attachmentsFromMatchingLeads){
			Id thisAttachmentParentLeadId = currentAttachment.ParentId;
			Id newAttachmentParentContactId = leadIdToMatchingContactId.get(thisAttachmentParentLeadId);
			if(newAttachmentParentContactId != null){
				Attachment newClonedAttachment = new Attachment();
				newClonedAttachment.Name = currentAttachment.Name;
				newClonedAttachment.Body = currentAttachment.Body;
				newClonedAttachment.Description = currentAttachment.Description;
				newClonedAttachment.ContentType = currentAttachment.ContentType;
				newClonedAttachment.IsPrivate = currentAttachment.IsPrivate;
				newClonedAttachment.OwnerId = currentAttachment.OwnerId;
				newClonedAttachment.ParentId = newAttachmentParentContactId;

				newAttachmentsToBeCreated.add(newClonedAttachment);
				attachmentsToBeDeleted.add(currentAttachment);
			}
		}
		return newAttachmentsToBeCreated;
	}

	/***********************************************************************************************************/

	public static List<CampaignMember> transferCampaignHistory(Map<Id,Id> leadIdToMatchingContactId){
		List<CampaignMember> newCampaignMembersToBeInserted = new List<CampaignMember>();
		List<CampaignMember> existingCampaignMembers = [SELECT Added_By__c,CampaignId,
		                                                       ContactId,
		                                                       FirstRespondedDate,
		                                                       HasResponded,
		                                                       LeadId,
		                                                       Notes__c,
		                                                       Status 
		                                                 FROM CampaignMember
		                                                 WHERE LeadId IN :leadIdToMatchingContactId.keySet()
		                                                       OR ContactId IN :leadIdToMatchingContactId.values()];
        //Separate the campaign members that belong to matched contacts from those that belong to Leads
        Set<String> contactIDCampaignID = new Set<String>();
        List<CampaignMember> leadsCampaignMembers = new List<CampaignMember>();
        for(CampaignMember currCampMember : existingCampaignMembers){
        	if(currCampMember.LeadId != null){
        		leadsCampaignMembers.add(currCampMember);
        	}else if(currCampMember.ContactId != null){
        		String currentExternalKey = String.valueOf(currCampMember.ContactId)+String.valueOf(currCampMember.CampaignId);
        		contactIDCampaignID.add(currentExternalKey);
        	}
        }
        //Go through Campaigns Members that belong to Lead
        for(CampaignMember currCampMember : leadsCampaignMembers){
        	//check to make sure matching contact is not already in the same campagin
        	String currentExternalKey = String.valueOf(leadIdToMatchingContactId.get(currCampMember.LeadId))+String.valueOf(currCampMember.CampaignId);
        	if(!contactIDCampaignID.contains(currentExternalKey)){
        		CampaignMember newClonedCampaignMember = currCampMember.clone(false, false, false, false);
        		newClonedCampaignMember.LeadId = null;
        		newClonedCampaignMember.ContactId = leadIdToMatchingContactId.get(currCampMember.LeadId);
        		newCampaignMembersToBeInserted.add(newClonedCampaignMember);
        	}
        }
		return newCampaignMembersToBeInserted;
	}

	/***********************************************************************************************************/

	public static void performDatabaseOperations(List<Contact> contactsToBeUpdated, List<Task> tasksToBeUpdated, List<Event> eventsToBeUpdated, List<Candidate_Secure_Info__c> secureInfoToBeUpdated, List<Note> newNotesToBeCreated, List<Note> notesToBeDeleted, List<Attachment> attachmentsToBeDeleted, List<Attachment> newAttachmentsToBeCreated, List<CampaignMember> newCampaignMembersToBeInserted,List<Lead_Contact_Match__c> allMatches, List<Lead> leadsToBeDeleted){
        //Update Matched Contacts
        if(contactsToBeUpdated.size()>0){
        	try{
                Database.update(contactsToBeUpdated,false);
        	}
        	catch(Exception e){}
        	
        }
        //Update Tasks
        if(tasksToBeUpdated.size()>0){
        	try{
        		Database.update(tasksToBeUpdated,false);
        	}
        	catch(Exception e){}
        }
        //Update Events
        if(eventsToBeUpdated.size()>0){
        	try{
        		Database.update(eventsToBeUpdated,false);
        	}
        	catch(Exception e){}
        }
        //Update Secure Info
        if(secureInfoToBeUpdated.size()>0){
        	try{
        		Database.update(secureInfoToBeUpdated,false);
        	}
        	catch(Exception e){}
        }
        //Insert cloned notes
        if(newNotesToBeCreated.size()>0){
        	try{
        		Database.insert(newNotesToBeCreated,false);
        	}
        	catch(Exception e){}
        }
        //Delete original Notes
        if(notesToBeDeleted.size()>0){
        	try{
        		Database.delete(notesToBeDeleted,false);
        	}
        	catch(Exception e){}
        }
        //Delete Original Attachments
        if(attachmentsToBeDeleted.size()>0){
        	try{
        		Database.delete(attachmentsToBeDeleted,false);
        	}
        	catch(Exception e){}
        }
        //Insert cloned Attachments
        if(newAttachmentsToBeCreated.size()>0){
        	try{
        		Database.insert(newAttachmentsToBeCreated,false);
        	}
        	catch(Exception e){}
        }
        //Insert Campaign Members
        if(newCampaignMembersToBeInserted.size()>0){
        	try{
        		Database.insert(newCampaignMembersToBeInserted,false);
        	}
        	catch(Exception e){}
        }
        //Insert the Lead_Contact_Match__c records
        if(allMatches.size()>0){
        	try{
        		Database.insert(allMatches,false);
        	}catch(Exception e){}
            
        }
        
        //Delete the matched Leads
        if(leadsToBeDeleted.size()>0){
        	try{
        		Database.delete(leadsToBeDeleted,false);
        	}
        	catch(Exception e){}
        }
        
    }
	
}