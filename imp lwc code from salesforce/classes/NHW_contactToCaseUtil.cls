/*
* this class is intentionally made without sharing. Contact updates are done by Workday Integration user, which may not have access to all the records being queried in this class
*/
public with sharing class NHW_contactToCaseUtil {

	//Data that needs to be queried in order to populate Case fields

	//Business Unit's Name is populated on Case Field Business_Unit_NHW__c
	private Static Set<Id> businessUnitToBeQueried = new Set<Id>();
	//Business site's address is populated on Case address fields
	private Static Set<Id> businessSiteToBeQueried = new Set<Id>();
	//If business site is remote, WD Candidate's address is populated on Case address Field
	private Static Set<Id> wdCandidatesToBeQueried = new Set<Id>();
	//Hiring Manager's email is copied on to Case field 
	private Static Set<Id> hiringManagerUsersToBeQueried = new Set<Id>();
	//Hiring manager's contactId is copied on to Case field
	private Static Set<String> hiringMgrContactsToBeQueried = new Set<String>();
	//Cost Center's Names are copied on to Case field
	private Static Set<Id> costCentersToBeQueried = new Set<Id>();
	//Data set to track which fields on the contact record changed
	private Static Map<Id,Set<String>> contactIdToFieldChanges = new Map<Id,Set<String>>();
	//Cases that need to be queried
	private Static List<Case> nhwCases;
	//Cases that were Close-Cancelled and will need CampaignMember deleted
	private Static List<String> org62CampaignMembersToBeDeleted = new List<String>();
	//Cases that finally need update
	private Static List<Case> casesToBeUpdated = new List<Case>();
	//Maps to store additional data that wll be queried
	private Static Map<Id,Business_Unit__c> businessUnitsMap;
	private Static Map<Id,TF2_Business_Site__c> businessSitesMap;
	private Static Map<Id,User> hiringManagerUsers;
	private Static Map<String,Contact> hiringManagerContactMap = new Map<String,Contact>();
	private Static Map<Id,TF2_Department__c> costCenterMap;

	public static void performUpdatesToCase(Map<Id,Contact> newContactMap,Map<Id,Contact> oldContactMap,Onboarding_Setting__c settings){
		//for each contact track the field changes and collect Ids of additional data that needs to be queried
		for(Contact ct : newContactMap.values()){
			if(settings.Candidate_Record_Type__c!=null 
			&& (ct.recordTypeId==Id.valueOf(settings.Candidate_Record_Type__c)
			    || ct.recordTypeId == NHW_Util.getcandidateContactRecordTypeId())){
				
				Contact oldContactValue = oldContactMap.get(ct.Id);
				trackFieldChanges(ct, oldContactValue);
			}
		}

		//query the cases that have lookup to above contacts
		//NOTE: we only consider the contacts where relevant fields changed
		queryRelatedCases();

		//query related data from other objects
		queryAdditionalData();
		
		//Iterate through every case and make the necessary changes
		performChangesToCases(newContactMap);
		
		//perform DML operation to Update cases
		if(!casesToBeUpdated.isEmpty()){
			update casesToBeUpdated;
		}

		//for cases that were close cancelled, delete the Org62 campaign member
		if(org62CampaignMembersToBeDeleted != null && org62CampaignMembersToBeDeleted.size() > 0){
            NHW_Org62Service.org62CampaingMemberDeleteCallOut('deleteCampaignMember', org62CampaignMembersToBeDeleted,'');
        } 
		
	}

	/*
	*  Method that tracks which fields changed on a contact. Stores the names of fields changed in a set of string in Map contactIdToFieldChanges
	*  Only the contact Ids in the Map contactIdToFieldChanges are considered for propagating changes to related cases
	*/
	private static void trackFieldChanges(Contact newContactValue, Contact oldContactValue){

		trackEmployeeIdChange(newContactValue,oldContactValue);
		trackBusinessUnitChange(newContactValue, oldContactValue);
		trackBusinessSiteChange(newContactValue, oldContactValue);
		trackCostCenterChange(newContactValue, oldContactValue);
		trackHiringManagerChange(newContactValue, oldContactValue);
		trackCandidateStageChange(newContactValue, oldContactValue);
		trackStartDateChange(newContactValue, oldContactValue);
		trackEmailChange(newContactValue, oldContactValue);
	}

	/*
	* Once the Map contactIdToFieldChanges has recorded all the contacts that have relevant fields changed, cases containing lookup to thse contacts are queried
	*/
	private static void queryRelatedCases(){
		nhwCases = [select Id, NHW_Employee__c,
							  NHW_Start_Date__c, 
							  Status,
							  Email_Address__c, 
							  NHW_Business_Unit__c, Business_Unit_NHW__c, 
							  NHW_Cost_Center__c, Cost_Center_NHW__c,
							  NH_Business_Site__c, Office_Address__c, Office_City__c, Office_Country__c, Office_State_Province__c, Office_Zip_Postal_Code__c,
							  NHW_Job_Application__r.Candidate__c, NHW_Job_Application__r.Candidate__r.Name,
							  NHW_Job_Application__r.Candidate__r.Mailing_Street__c,
							  NHW_Job_Application__r.Candidate__r.Mailing_City__c,
							  NHW_Job_Application__r.Candidate__r.Mailing_State__c,
							  NHW_Job_Application__r.Candidate__r.Mailing_Country__c,
							  NHW_Job_Application__r.Candidate__r.Mailing_Postal_Code__c
					  from case 
					  where NHW_Employee__c in: contactIdToFieldChanges.keySet()
					  		AND NHW_Start_Date__c> = :Date.Today() AND Status != 'Closed - Cancelled']; 
	}

	/*
	* In order to populate some fields on Case object, data from lookup references need to be queried
	* This method queries, businessUnits, business Sites, WD Candidates, Cost Center, Hiring Managers and Hiring Manager Contact records
	*/
	private static void queryAdditionalData(){
		businessUnitsMap = new Map<Id, Business_Unit__c>([Select Id, Name from Business_Unit__c where Id IN :businessUnitToBeQueried]);
		businessSitesMap = new Map<Id,TF2_Business_Site__c>([Select Id, Name, Street_Address__c, City__c, State_Province__c, Country__c,Postal_Code__c from TF2_Business_Site__c where Id IN :businessSiteToBeQueried AND Active__c = True ]);
		costCenterMap = new Map<Id,TF2_Department__c>([Select Id, Name from TF2_Department__c where Id IN :costCentersToBeQueried]);
		hiringManagerUsers = new Map<Id,User>([Select Id, Email from User where Id IN :hiringManagerUsersToBeQueried]);
		//get emails of hiring managers
		for(User u : hiringManagerUsers.values()){
			hiringMgrContactsToBeQueried.add(u.Email);
		}
		//now retrieve the contact record of hiring manager users
		List<Contact> hiringManagerContacts = [Select Id, Email from Contact where Email IN:hiringMgrContactsToBeQueried];
		//put contacts in a map where they can be retreieved via email
		for(Contact ct:hiringManagerContacts){
			hiringManagerContactMap.put(ct.Email,ct);
		}
	}

	/*
	* Method to flow changes from Contact to cases
	*/
	private static void performChangesToCases(Map<Id,Contact> contactNewMap){
		for(Case currentCase : nhwCases){
			if(!contactIdToFieldChanges.containsKey(currentCase.NHW_Employee__c)){
				continue;
			}
			Set<String> contactFieldChanges = contactIdToFieldChanges.get(currentCase.NHW_Employee__c);
			//for currentCase, find the related contact that was updated
			Contact updatedContact = contactNewMap.get(currentCase.NHW_Employee__c);
			//Employee Id Change
			//no action needed. A dummy update on related cases will be done 

			//Start Date Change
			startDateChange(currentCase,updatedContact,contactFieldChanges);
			
			//Candidate Stage Changed
			candidateStageChange(currentCase,updatedContact,contactFieldChanges);
			
			//Hiring Manager Changed
			hiringManagerChange(currentCase,updatedContact,contactFieldChanges);
			
			//Cost Center Changed
			costCenterChange(currentCase,updatedContact,contactFieldChanges);
			
			//Business Site Changed
			businessSiteChange(currentCase,updatedContact,contactFieldChanges);
			
			//Business Unit Changed
			businessUnitChange(currentCase,updatedContact,contactFieldChanges);

			//Email Changed
			emailChange(currentCase,updatedContact,contactFieldChanges);
			
			casesToBeUpdated.add(currentCase);
		}
	}

	/********************* Private Utility Methods to perform smaller tasks *************/

	//Utility Method to check if EMployee Id on contact record changed
	private static void trackEmployeeIdChange(Contact newContactValue, Contact oldContactValue){
		if(String.isNotBlank((newContactValue.EmployeeNumber__c)) && (newContactValue.EmployeeNumber__c) != (oldContactValue.EmployeeNumber__c)){
			if(!contactIdToFieldChanges.containsKey(newContactValue.Id)){
				contactIdToFieldChanges.put(newContactValue.Id,new Set<String>());
			}
			(contactIdToFieldChanges.get(newContactValue.Id)).add('EmployeeNumber');
		}
	}

	//Utility Method to check if Business Unit on contact record changed
	//Also stores the ID of business unit, so it can be queried later to retrive related data
	private static void trackBusinessUnitChange(Contact newContactValue, Contact oldContactValue){
       if(String.isNotBlank((newContactValue.WD_Business_Unit__c)) && (newContactValue.WD_Business_Unit__c) != (oldContactValue.WD_Business_Unit__c)){
			//we will need business unit's name to be added on case record
			businessUnitToBeQueried.add(newContactValue.WD_Business_Unit__c);
			//make a note that Business Unit changed on this contact record
			if(!contactIdToFieldChanges.containsKey(newContactValue.Id)){
				contactIdToFieldChanges.put(newContactValue.Id,new Set<String>());
			}
			(contactIdToFieldChanges.get(newContactValue.Id)).add('BusinessUnit');
		}
	}

	//Utility Method to check if Business Site on contact record changed
	//Also stores Business Site ID and WD Candidate ID, so they can be queried later to retrieve related data
	private static void trackBusinessSiteChange(Contact newContactValue, Contact oldContactValue){
		if(String.isNotBlank((newContactValue.Business_Site__c)) && (newContactValue.Business_Site__c) != (oldContactValue.Business_Site__c)){
			//we will need business Site's name
			businessSiteToBeQueried.add(newContactValue.Business_Site__c);
			//make a note that business site changed on this contact
			if(!contactIdToFieldChanges.containsKey(newContactValue.Id)){
				contactIdToFieldChanges.put(newContactValue.Id,new Set<String>());
			}
			(contactIdToFieldChanges.get(newContactValue.Id)).add('BusinessSite');
		}
	}

	//Utility Method to check if Cost Center on contact record changed
	//Also stores Cost Center Id, so it can be queried later to retrieve related data
	private static void trackCostCenterChange(Contact newContactValue, Contact oldContactValue){
		if(String.isNotBlank((newContactValue.WD_Department__c)) && (newContactValue.WD_Department__c) != (oldContactValue.WD_Department__c)){
			//name of cost center needs to be copied on to case field Cost_Center_NHW__c
			costCentersToBeQueried.add(newContactValue.WD_Department__c);
			//make a note that cost center changed on this contact
			if(!contactIdToFieldChanges.containsKey(newContactValue.Id)){
				contactIdToFieldChanges.put(newContactValue.Id,new Set<String>());
			}
			(contactIdToFieldChanges.get(newContactValue.Id)).add('CostCenter');
		}
	}

	//Utility Method to check if Hiring Manager on contact record changed
	//Also stores Ids of Hiring Managers, so they can be queried later to retrieve related data
	private static void trackHiringManagerChange(Contact newContactValue, Contact oldContactValue){
		if(String.isNotBlank((newContactValue.Hiring_Manager__c)) && (newContactValue.Hiring_Manager__c) != (oldContactValue.Hiring_Manager__c)){
			//hiring manager's email and corresponding cotanct record will be needed to populate case fields
			hiringManagerUsersToBeQueried.add(newContactValue.Hiring_Manager__c);
			//make a note that hiring manager changed on this contact
			if(!contactIdToFieldChanges.containsKey(newContactValue.Id)){
				contactIdToFieldChanges.put(newContactValue.Id,new Set<String>());
			}
			(contactIdToFieldChanges.get(newContactValue.Id)).add('HiringManager');
		}
	}

	//Utility Method to check if Candidate Stage on contact record changed
	private static void trackCandidateStageChange(Contact newContactValue, Contact oldContactValue){
		if(String.isNotBlank((newContactValue.Candidate_Stage__c)) && (newContactValue.Candidate_Stage__c) != (oldContactValue.Candidate_Stage__c)){
			//make a note that candidate stage changed on this contact
			if(!contactIdToFieldChanges.containsKey(newContactValue.Id)){
				contactIdToFieldChanges.put(newContactValue.Id,new Set<String>());
			}
			(contactIdToFieldChanges.get(newContactValue.Id)).add('CandidateStage');
		}
	}

	//Utility Method to check if Start Date on contact record changed
	private static void trackStartDateChange(Contact newContactValue, Contact oldContactValue){
		if((newContactValue.Start_Date__c != null) && (newContactValue.Start_Date__c) != (oldContactValue.Start_Date__c)){
			//make a note that start date changed on this contact
			if(!contactIdToFieldChanges.containsKey(newContactValue.Id)){
				contactIdToFieldChanges.put(newContactValue.Id,new Set<String>());
			}
			(contactIdToFieldChanges.get(newContactValue.Id)).add('StartDate');
		}
	}

//Utility Method to check if Email on contact record changed
	private static void trackEmailChange(Contact newContactValue, Contact oldContactValue){
		if(String.isNotBlank((newContactValue.SF_Work_Email__c)) && (newContactValue.SF_Work_Email__c) != (oldContactValue.SF_Work_Email__c)){
			//make a note that start date changed on this contact
			if(!contactIdToFieldChanges.containsKey(newContactValue.Id)){
				contactIdToFieldChanges.put(newContactValue.Id,new Set<String>());
			}
			(contactIdToFieldChanges.get(newContactValue.Id)).add('Email');
		}
	}

/*
	* Utility Method to perform actions when email on contact changes
	* updated email is copied to Case.Email_Address__c field
	*/
	private static void emailChange(Case currentCase, Contact caseContact, Set<String> contactFieldChanges){
		if(contactFieldChanges.contains('Email')){
			currentCase.Email_Address__c = caseContact.SF_Work_Email__c;
		}
	}


	/*
	* Utility Method to perform actions when start date on contact changes
	* updated start date is copied to Case.NHW_Start_Date__c field
	*/
	private static void startDateChange(Case currentCase, Contact caseContact, Set<String> contactFieldChanges){
		if(contactFieldChanges.contains('StartDate')){
			currentCase.NHW_Start_Date__c = caseContact.Start_Date__c;
		}
	}

	/*
	* Utility Method to perform actions when Candidate Stage on contact changes
	* If Candidate Stage changed to "Declined By Candidate " or "Rejected", case's status is changed to 'Closed - Cancelled'
	* For Cancelled cases, perform a callout to org62 to delete campaign member record
	* This functionality is present on WD Job req and WD Job App trigger. 
	* Refer to NHW_Util.updateJobApplicationsRelatedCases method
	*/
	
	private static void candidateStageChange(Case currentCase, Contact caseContact, Set<String> contactFieldChanges){
		if(contactFieldChanges.contains('CandidateStage')){
			String newCandidateStage = caseContact.Candidate_Stage__c;
			if(( !(String.isBlank(newCandidateStage))
			   &&(newCandidateStage.equalsIgnoreCase('Declined by Candidate') || newCandidateStage.equalsIgnoreCase('Rejected'))
			   ) && (currentCase.Status != 'Closed - Cancelled')){ //case status needs to be 'closed-cancelled', unless it was already cancelled
			   		currentCase.Status = 'Closed - Cancelled';
					org62CampaignMembersToBeDeleted.add(currentCase.Email_Address__c);
			}
		}
	}

	/*
	* Utility Method to perform actions when Hiring Manager on contact changes
	* Hiring Manager's email is copied to field Case.Manager_s_Email__c
	* Hiring Manager's contact record is populated onto Case lookup fields ContactID and Manager_Name__c
	*/
	private static void hiringManagerChange(Case currentCase, Contact caseContact, Set<String> contactFieldChanges){
		if(contactFieldChanges.contains('HiringManager')){
			//email of hiring manager get copied onto Case field NH Manager's Email
			String managerEmail = hiringManagerUsers.get(caseContact.Hiring_Manager__c).Email;
			currentCase.Manager_s_Email__c = managerEmail;
			//mamager contact Id is copied onto case object as ContactID and NH Manager Name
			Id managerContactId = hiringManagerContactMap.get(managerEmail).Id;
			currentCase.ContactId = managerContactId;
			currentCase.Manager_Name__c = managerContactId;
		}
	}

	/*
	* Utility Method to perform actions when Cost Center on contact changes
	* Cost Center Lookup is copied to field Case.NHW_Cost_Center__c
	* Cost Center's name is copied onto picklist field Case.Cost_Center_NHW__c
	*/
	private static void costCenterChange(Case currentCase, Contact caseContact, Set<String> contactFieldChanges){
		if(contactFieldChanges.contains('CostCenter')){
			currentCase.NHW_Cost_Center__c = caseContact.WD_Department__c;
			currentCase.Cost_Center_NHW__c = costCenterMap.get(caseContact.WD_Department__c).Name;
		}
	}

	/*
	* Utility Method to perform actions when Business Site on contact changes
	* Lookup to new business site is copied to field Case.NH_Business_Site__c
	* If Business Site's name contains "Remote", WD Candidate's address is copied onto Case address fields
	* Otherwise, Business site's address is copied onto case address fields
	*/
	private static void businessSiteChange(Case currentCase, Contact caseContact, Set<String> contactFieldChanges){
		if(contactFieldChanges.contains('BusinessSite')){
			Id newBusinessSiteId = caseContact.Business_Site__c;
			currentCase.NH_Business_Site__c = newBusinessSiteId;
			if(newBusinessSiteId!=null && businessSitesMap.containsKey(newBusinessSiteId)){
				TF2_Business_Site__c newBusinessSite = businessSitesMap.get(newBusinessSiteId);
				if(newBusinessSite.Name.contains('Remote')){
					//get mailing info from WD Candidate
					if((currentCase.NHW_Job_Application__c != null) && (currentCase.NHW_Job_Application__r.Candidate__c != null)){
						currentCase.Office_Address__c = currentCase.NHW_Job_Application__r.Candidate__r.Mailing_Street__c;
						currentCase.Office_City__c = currentCase.NHW_Job_Application__r.Candidate__r.Mailing_City__c;
						currentCase.Office_Country__c = currentCase.NHW_Job_Application__r.Candidate__r.Mailing_Country__c;
						currentCase.Office_State_Province__c = currentCase.NHW_Job_Application__r.Candidate__r.Mailing_State__c;
						currentCase.Office_Zip_Postal_Code__c = currentCase.NHW_Job_Application__r.Candidate__r.Mailing_Postal_Code__c;
					}
					
				}else{
					//get mailing info from business site
					currentCase.Office_Address__c = newBusinessSite.Street_Address__c;
					currentCase.Office_City__c = newBusinessSite.City__c;
					currentCase.Office_Country__c = newBusinessSite.Country__c;
					currentCase.Office_State_Province__c = newBusinessSite.State_Province__c;
					currentCase.Office_Zip_Postal_Code__c = newBusinessSite.Postal_Code__c;
				}
			}
		}
	}

	
	/*
	* Utility Method to perform actions when Business Unit on contact changes
	* Lookup to new business unit is copied to field Case.NHW_Business_Unit__c
	* Business Unit's name is copied to picklist field Case.Business_Unit_NHW__c
	*/
	private static void businessUnitChange(Case currentCase, Contact caseContact, Set<String> contactFieldChanges){
		if(contactFieldChanges.contains('BusinessUnit')){
			Id newBusinessUnitId = caseContact.WD_Business_Unit__c;
			currentCase.NHW_Business_Unit__c = newBusinessUnitId;
			if(businessUnitsMap.containsKey(newBusinessUnitId)){
				currentCase.Business_Unit_NHW__c = businessUnitsMap.get(newBusinessUnitId).Name;
			}
		}
	}
	
	//W-15308729  code added for SD changes > 30 requirements
	//Test class :NHW_contactToCaseUtilTest method: testCasestoOnHold
	/*
	* Method to update associated cases to 'On Hold' when Status on an Employee contact changes from Active to Deactive or viceversa
	*/
	public static void performUpdatesToCaseIfEmployeeContact(Map<Id,Contact> newContactMap,Map<Id,Contact> oldContactMap){
		
        Set<Id> contactIdsToBeQueried = new Set<Id>();
		Set<String> contactSFEmailsTobeQueried = new Set<String>();
		Set<String> contactWorkerIdsTobeQueried = new Set<String>();
		Set<String> workerIdsActivated = new Set<String>();
		Set<String> workerIdsDeactivated = new Set<String>();
		List<Case> contactCasesToBeUpdated = new List<Case>();
		for(Contact ct : newContactMap.values()){
			if( (ct.recordTypeId == NHW_Util.getEmployeeContactRecordTypeId() )
				&& String.isNotBlank((ct.Status__c))
				&& ((ct.Status__c) != ((oldContactMap.get(ct.id)).Status__c))
				&& ((ct.Status__c=='Active')||(ct.Status__c=='Deactive'))
			){
				contactIdsToBeQueried.add(ct.id);
				if(String.isnotBlank(ct.SF_Work_Email__c)){
					contactSFEmailsTobeQueried.add(ct.SF_Work_Email__c);
				}
				if(String.isnotBlank(ct.EmployeeNumber__c)){
					contactWorkerIdsTobeQueried.add(ct.EmployeeNumber__c);
					if(ct.Status__c=='Active')
						workerIdsActivated.add(ct.EmployeeNumber__c);
					if(ct.Status__c=='Deactive')
						workerIdsDeactivated.add(ct.EmployeeNumber__c);
				}
			}
		}
		List<WDR_Candidate__c> wdrCandidatesWithSameWorkerId = new List<WDR_Candidate__c>();
		List<Case> contactCases = [select Id, NHW_Employee__c,
							  NHW_Start_Date__c, 
							  Status,
							  Email_Address__c, 
							  NHW_Business_Unit__c, Business_Unit_NHW__c, 
							  NHW_Cost_Center__c, Cost_Center_NHW__c,
							  NH_Business_Site__c, Office_Address__c, Office_City__c, Office_Country__c, Office_State_Province__c, Office_Zip_Postal_Code__c,
							  NHW_Job_Application__r.Candidate__c, NHW_Job_Application__r.Candidate__r.Name,
							  NHW_Job_Application__r.Candidate__r.Mailing_Street__c,
							  NHW_Job_Application__r.Candidate__r.Mailing_City__c,
							  NHW_Job_Application__r.Candidate__r.Mailing_State__c,
							  NHW_Job_Application__r.Candidate__r.Mailing_Country__c,
							  NHW_Job_Application__r.Candidate__r.Mailing_Postal_Code__c
							  ,recordtype.DeveloperName,
							  Status_before_OnHold__c,
							  NHW_Employee__r.SF_Work_Email__c,
							  NHW_Employee__r.EmployeeNumber__c,
							  NHW_Job_Application__r.Candidate__r.Employee_Number__c
					  from case 
					  where (NHW_Employee__c in: contactIdsToBeQueried OR NHW_Employee__r.SF_Work_Email__c in :contactSFEmailsTobeQueried OR NHW_Employee__r.EmployeeNumber__c in :contactWorkerIdsTobeQueried  OR NHW_Job_Application__r.Candidate__r.Employee_Number__c in :contactWorkerIdsTobeQueried)
					  		AND NHW_Start_Date__c> = :Date.Today() 
							AND Status != 'Closed'
							AND ((recordtype.DeveloperName=:'New_Hire_Process') OR (recordtype.DeveloperName=:'New_Hire_Process_Onboarding'))];
		System.debug('contactCases--->'+contactCases);
        for(Case currentCase : contactCases){
			String newContactStatus;
			if(workerIdsActivated.contains(currentCase.NHW_Job_Application__r.Candidate__r.Employee_Number__c)){
				newContactStatus = 'Active';
			}
			else if(workerIdsDeactivated.contains(currentCase.NHW_Job_Application__r.Candidate__r.Employee_Number__c)){
				newContactStatus = 'Deactive';
			}
			
					
			// if the contact inactivates, update the case status to on Hold
			if(( newContactStatus!= null && !(String.isBlank(newContactStatus)) &&(newContactStatus.equalsIgnoreCase('Deactive') )) 
			&&	
			( ((currentCase.Status == 'New')||(currentCase.Status == 'Accounts in Progress - Peopleforce'))
				&& (currentCase.recordtype.DeveloperName =='New_Hire_Process'))
				||
				( (/*(currentCase.Status == 'New')||*/(currentCase.Status == 'Accounts in Progress - Supportforce')||(currentCase.Status == 'Sent to Supportforce'))
				&& (currentCase.recordtype.DeveloperName =='New_Hire_Process_Onboarding'))
			   ){ //case status needs to be 'On Hold', unless it was already Closed
					currentCase.Status_before_OnHold__c =currentCase.Status;
			   		currentCase.Status = 'On Hold';
			}
			// if the contact activates, update the case status to previous value before On Hold
			if(( !(String.isBlank(newContactStatus)) &&(newContactStatus.equalsIgnoreCase('Active') )) 
				&& (currentCase.Status != 'Closed')
				&& (currentCase.Status == 'On Hold')
				&& ((currentCase.recordtype.DeveloperName =='New_Hire_Process')||(currentCase.recordtype.DeveloperName =='New_Hire_Process_Onboarding'))
			   ){ //case status needs to revert back to original value (before putting on hold)
					if(currentCase.recordtype.DeveloperName =='New_Hire_Process'					
					&& !(String.isBlank(currentCase.NHW_Employee__r.EmployeeNumber__c))
					&& !(String.isBlank(currentCase.NHW_Employee__r.SF_Work_Email__c))){
						currentCase.Status = 'Closed';
						currentCase.Status_before_OnHold__c ='';
					}
					else{
						if(!String.isBlank(currentCase.Status_before_OnHold__c)){
							currentCase.Status = currentCase.Status_before_OnHold__c;
							currentCase.Status_before_OnHold__c ='';
						}
					}
			}	
			contactCasesToBeUpdated.add(currentCase);
			
		}
		//perform DML operation to Update cases
		if(!contactCasesToBeUpdated.isEmpty()){
            System.debug('contactCasesToBeUpdated--->'+contactCasesToBeUpdated);
			update contactCasesToBeUpdated;
		}

	}				
		
}