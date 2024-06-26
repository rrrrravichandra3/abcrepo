global class MigrateNotesAndTasksFromCandidate implements Database.Batchable<sObject> {
    public String query = 'select Id,name from Contact where recordTypeId=';
        
    global MigrateNotesAndTasksFromCandidate() {
         RecordType candidateRecordType =getCandidateRecordType();
         query =query + '\''+candidateRecordType.Id+  '\' order by createdDate' ;
         System.debug('query--------->'+ query);
	}
	
	global MigrateNotesAndTasksFromCandidate(boolean isTest) {
         RecordType candidateRecordType =getCandidateRecordType();
         query =query + '\''+candidateRecordType.Id+  '\' order by createdDate limit 10' ;
         //String candidateId ='003T000000zXRY7';
         //query='select Id,name from Contact where Id=\'003T000000zXRY7\'';
         System.debug('query--------->'+ query);
	}

	global database.querylocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator(query);
	}	
	
	global void execute(Database.BatchableContext bc, List<sObject> scope) {
		Set<Id> contactIdSet = new Set<Id>();
		for (sObject sObj : scope) {
			//loading the candidate Id's to set object.
		    contactIdSet.add(sObj.Id);	
		}
		if (contactIdSet.size() > 0) {
			
			deleteCandidateSecureInfo(contactIdSet);
			//retrieving notes.
			Map<Id,List<Note>> contactNotesMap = getNotesData(contactIdSet);
			
			//retrieving tasks
			Map<Id,List<Task>> contactTasksMap = getTasksData(contactIdSet);
			
			//Set<Id> contactIdSetWithNotesAndTask = new Set<Id>();
			//contactIdSetWithNotesAndTask.addAll(contactNotesMap.keySet());
			//contactIdSetWithNotesAndTask.addAll(contactTasksMap.keySet());
			// creating the shadow object record for the candidate.
			Map<Id,Id> contactMap = createContactShadowObject(contactIdSet);
			// moving the notes from candidate to shadow record.
			processNotes(contactMap,contactNotesMap);
			// moving the tasks from candidate to shadow record.
			processTasks(contactMap,contactTasksMap);
		}
	} 
	
	global void finish(Database.BatchableContext bc) {
		AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:bc.getJobId()];
	}
	
	private static void deleteCandidateSecureInfo(Set<Id> contactIdSet) {
		try {
		    delete [select Id from Candidate_Secure_Info__c where candidate__c IN :contactIdSet ];  	
		} catch (Exception ex) {
		
		}
	}
	
    /**
	 * Moving the notes from the candidate record to the shadow object.
	 * @param contactMap is a map.
	 *
	 */
	private static void processNotes(Map<Id,Id> contactMap,Map<Id,List<Note>> contactNotesMap) {
		
		User systemUser = [select id,name from user where name='Peter MacGregor'];
		System.debug('System User Id------::'+systemUser.Id);
		Set<Id> owneridSet = new Set<Id>();
		for (Id contactId : contactMap.keySet()) {
			if (contactNotesMap.containsKey(contactId)) {
				for (Note noteInfo : contactNotesMap.get(contactId)) {
					owneridSet.add(noteInfo.ownerid);
				}
			}
		}
		System.debug('owneridSet :::'+ owneridSet);
		Set<Id>  activeUserSet  = new Set<Id>();
		if (owneridSet.size() > 0) {
			for(User userInfo : [select id,isactive from user where id in:owneridSet and isActive=true]) {
				activeUserSet.add(userInfo.Id);
			}
		}
		System.debug('activeUserSet :::'+ activeUserSet);
		List<Note> notesList = null;
		List<Note> createNotesList = new List<Note>();
		List<Note> deleteNotesList = new List<Note>();
		Id contactShadowId = null;
		Id ownerId = systemUser.Id;
		//looping through the contacts.
		
		for (Id contactId : contactMap.keySet()) {
			if (contactNotesMap.containsKey(contactId)) {
				// getting the notes attached to the candidate
				notesList = contactNotesMap.get(contactId);
				System.debug('notesList------::'+notesList);
				// geting the shadow object Id.
				contactShadowId = contactMap.get(contactId);
				System.debug('contactShadowId------::'+contactShadowId);
				if (contactShadowId != null && notesList != null && notesList.size() > 0) {
					// processing the notes
					for (Note noteInfo : notesList) {
						if(activeUserSet.contains(noteInfo.ownerId)) {
							ownerId = noteInfo.ownerId;
						}
						//System.debug('ownerId------::'+ownerId);
						createNotesList.add(new Note(ParentId=contactShadowId, ownerId=ownerId, title=noteInfo.title, body=noteInfo.body,IsPrivate=noteInfo.IsPrivate));
						//noteInfo.ParentId = contactShadowId;
						deleteNotesList.add(noteInfo);
					}
				}
			}
		}
		System.debug('createNotesList--------->'+createNotesList);
		insert createNotesList;
		delete deleteNotesList;
	}
	
	
	/**
	 * Moving the tasks from the candidate record to the shadow object.
	 * @param contactMap is a map.
	 *
	 */
	private static void processTasks(Map<Id,Id> contactMap,Map<Id,List<Task>> contactTasksMap) {
		
		List<Task> taskList = null;
		List<Task> modifiedTasksList = new List<Task>();
		Id contactShadowId = null;
		for (Id contactId : contactMap.keySet()) {
			if (contactTasksMap.containsKey(contactId)) {
				// getting the tasks attached to the candidate
				taskList = contactTasksMap.get(contactId);
				// geting the shadow object Id.
				contactShadowId = contactMap.get(contactId);
				if (contactShadowId != null && taskList != null && taskList.size() > 0) {
					// processing the tasks.
					for (Task taskInfo : taskList) {
						taskInfo.WhatId = contactShadowId;
						taskInfo.WhoId = null;
						modifiedTasksList.add(taskInfo);
					}
				}
			}
		}
		update modifiedTasksList;
	}
	
    /**
	 * Retrieving the candidate record type.
	 */
	private static RecordType getCandidateRecordType() {
		return [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sobjectType='Contact' and r.name='Candidate' ];
	}
	
	/**
	 * Loading the notes data into to a map given the contact id set.
	 * @param contactIdSet is a set.
	 * @return contactNotesMap is map. 
	 */
	private static Map<Id,List<Note>> getNotesData(Set<Id> contactIdSet) {
		Map<Id,List<Note>> contactNotesMap = new Map<Id,List<Note>>();
		for(Note candidateNotes : [select id, parentId,ownerId,title,body,IsPrivate from Note where parentId IN  :contactIdSet ]) {
			if (!contactNotesMap.containsKey(candidateNotes.ParentId)) {
				contactNotesMap.put(candidateNotes.ParentId, new List<Note>());
			}
			contactNotesMap.get(candidateNotes.ParentId).add(candidateNotes);
		}
		
		return contactNotesMap;
	}
	
	/**
	 * Loading the task data into to a map given the contact id set.
	 * @param contactIdSet is a set.
	 * @return contactTasksMap is map. 
	 */
    private static Map<Id,List<Task>> getTasksData(Set<Id> contactIdSet) {
		Map<Id,List<Task>> contactTasksMap = new Map<Id,List<Task>>();
		for(Task taskInfo : [select id, whatId,whoId from Task where whoId IN  :contactIdSet ]) {
			if (!contactTasksMap.containsKey(taskInfo.whoId)) {
				contactTasksMap.put(taskInfo.whoId, new List<Task>());
			}
			contactTasksMap.get(taskInfo.whoId).add(taskInfo);
		}
		
		return contactTasksMap;
	}	
	
	/**
	 * Creating the shadow object for the candidate records.
	 */
	private static Map<Id,Id> createContactShadowObject(Set<Id> contactIdSet) {
		Map<Id,Id> contactMap = new Map<Id,Id> ();
		List<Candidate_Secure_Info__c> candidateSecureInfoList = new List<Candidate_Secure_Info__c>();
		for (Id contactId : contactIdSet) {
			// populating the shadow object.
			candidateSecureInfoList.add(new Candidate_Secure_Info__c(Candidate__c=contactId));
		}
		// saving the records.
		insert candidateSecureInfoList;
		// loading the data to map , contact id and the associated shadow object id.
		for (Candidate_Secure_Info__c candidateSecureInfo : candidateSecureInfoList) {
			contactMap.put(candidateSecureInfo.Candidate__c, candidateSecureInfo.Id);
		}
		return contactMap;
	}
	
	
	static testMethod void testBatch() {
		Test.startTest();
		RecordType accountRecordType = [select id,name from RecordType where SObjectType='Account' and name='Candidate'];
		Account account =[Select Id, name from Account Where recordTypeId =: accountRecordType.Id and name='Candidates'];
		RecordType contactRecordType = [select id,name from RecordType where SObjectType='Contact' and name='Candidate'];
		Contact candidate = new Contact();
		candidate.RecordTypeId=contactRecordType.Id;
		candidate.AccountId = account.Id;
		candidate.FirstName = 'Test FS';
		candidate.lastName='Test Ls';
		candidate.email='a@b.com';
		candidate.Phone='1111111111';
		insert candidate;
		
		Note note = new Note();
		note.parentId=candidate.Id;
		note.Body='test';
		note.IsPrivate= false;
		note.Title='test';
		insert note;
		
		Task currentTask = new Task();
	    currentTask.Subject = 'Test';
	    currentTask.whoId = candidate.Id;
	    currentTask.CallType = 'Outbound';
	    currentTask.ActivityDate = System.today().addDays(1);
	    currentTask.ReminderDateTime = System.today().addDays(1);
	    currentTask.Priority = 'Normal';
	    insert currentTask;
		
		MigrateNotesAndTasksFromCandidate job = new MigrateNotesAndTasksFromCandidate(true);
		Database.executeBatch(job); 
		Test.stopTest();
		
	}
	
	
}