global class ESDJC_New_User_Contractor_Batch implements Database.Batchable<sObject> , Database.Stateful{
	private ESDJC_Integration_Log__c log;
	private ESDJC_Settings__c settings;
	private String batchStatus {get;set;}
	global static String SUCCESS_MESSAGE = 'New - Completed';
	global static String ERROR_MESSAGE = 'New - ERROR: ';
	private String PF_ORG;
	public String errorMessage = '';
	Map<id, Contact> id2ContactMap = new Map<id, Contact>();
	
	global ESDJC_New_User_Contractor_Batch(ESDJC_Integration_Log__c log) {		
		       
		this.log = log;
		settings = ESDJC_Settings__c.getInstance();		
		batchStatus = 'Success';		
		
		log.DJC_New_Contractor_Batch_Job_Start_Time__c = DateTime.now();
		log.DJC_New_Contractor_Job_Status__c = 'In Progress';
	}

	global Database.QueryLocator start(Database.BatchableContext BC){		
		 
		List<String> businessUnits = new List<String>(); // business units to be excluded
		Set<String> businessUnitsSet = new Set<String>(); 
		if(settings.BU_Exclusion_list__c!=null){
			businessUnits = settings.BU_Exclusion_list__c.split(';',-1);
		}
		for(String s : businessUnits){
			businessUnitsSet.add(s.trim()); // set to hold Exact Target employees: we are not creating portal users for ET employees. 
		}
		
		PF_ORG = '@'+settings.SSO_Service_Provider_Org__c;
		
		return Database.getQueryLocator([SELECT  Name,  ES_DJC_Business_Unit__c,EmployeeNumber__c,Id,ES_DJC_Is_Manager__c,
										 Email, FirstName, LastName, Division__c, Title, ES_DJC_Cost_Center__c,
										 Primary_Country_of_Coverage_PCC__c FROM Contact WHERE ES_DJC_Record_Status__c = 'New' AND 
											RecordType.name='Contractor' AND Status__c = 'Active' and 
											ES_DJC_Business_Unit__c NOT IN :businessUnitsSet and Email!=null]);
	}


	global void execute(Database.BatchableContext BC,  List<sObject> scope){
		
		System.debug('+++ESDJC_New_User_Contractor_Batch execute scope.size()='+scope.size());
		
		List<Database.SaveResult> saveResults;
		Database.SaveResult result;		
		Contact aContact;

		if(Schema.Sobjecttype.User.isCreateable()){
			//-------------Create New Users -------------------     	
			List<User> newUsers = new List<User>();					
			User djcUser;
			for(Sobject s : scope){
				aContact = (Contact) s;
				id2ContactMap.put(aContact.id, aContact);
				String username = aContact.email.split('@')[0];
				system.debug('aContact.email '+aContact.email);
				system.debug('username '+username);
				djcUser = new User();
				djcUser.ContactId = aContact.id;
				djcUser.Username = ESDJC_Util.getDJCUserName(username+PF_ORG);
				system.debug('djcUser.Username '+djcUser.Username);
				djcUser.CommunityNickname = ESDJC_Util.getNickname(8);
				djcUser.profileId = settings.Portal_User_Profile_Id__c;      						
				djcUser.IsActive = true;
				djcUser.UserPermissionsChatterAnswersUser = true;
				djcUser.Primary_Coverage_Country_PCC__c = aContact.Primary_Country_of_Coverage_PCC__c;
				djcUser.Title = aContact.Title;
				djcUser.Cost_Center__c = aContact.ES_DJC_Cost_Center__c;
				djcUser.Business_Unit__c = aContact.ES_DJC_Business_Unit__c;
				djcUser.EmployeeNumber = aContact.EmployeeNumber__c;
				djcUser.Email = aContact.email;
				djcUser.FirstName = aContact.FirstName;
				djcUSer.LastName = aContact.LastName;
				djcUser.Alias = (username.length()>=5)?username.substring(0,5):username;
				djcUser.Division = aContact.Division__c;
				if (djcUser.Division != null && djcUser.Division.equalsIgnoreCase('Japan')){
					djcUser.LanguageLocaleKey = 'ja';			
					djcUser.LocaleSidKey = 'ja_JP';
					djcUser.TimeZoneSidKey = 'Asia/Tokyo';
					djcUser.EmailEncodingKey = 'UTF-8';
					djcUser.CurrencyIsoCode = 'USD';					
				}else{
					djcUser.LanguageLocaleKey = 'en_US';			
					djcUser.LocaleSidKey = 'en_US';
					djcUser.TimeZoneSidKey = 'America/Los_Angeles';
					djcUser.EmailEncodingKey = 'UTF-8';
					djcUser.CurrencyIsoCode = 'USD';
				}
				newUsers.add(djcUser);
			}
			System.debug('+++ESDJC_New_User_Contractor_Batch execute newUsers.size()='+newUsers.size());
			
			saveResults = Database.insert(newUsers,false);
			
			//-------------Process user creation result -------------------     	
			User aUser;
			for(Integer i=0;i<saveResults.size();i++){
				result = saveResults.get(i);
				aUser = newUsers.get(i);
				aContact =  id2ContactMap.get(aUser.Contactid);
				if(result.success){
					aContact.ES_DJC_Record_Status__c = SUCCESS_MESSAGE;
					aContact.ES_DJC_Portal_User_Language__c= aUser.languagelocalekey;
				} else {
					batchStatus = 'Failure';	
					String errorMessageHere = ERROR_MESSAGE+result.getErrors()[0].getMessage();	
                    aContact.ES_DJC_Record_Status__c = errorMessageHere.length()> 255 ? errorMessageHere.substring(0,255) : errorMessageHere;
                    errorMessage += 'Contact : ' + aContact.Name + ' -- ' + aContact.EmployeeNumber__c + ' record processing Failed with message : '+ aContact.ES_DJC_Record_Status__c+ '\n';
				}
			}
			
			if(Schema.Sobjecttype.PermissionSetAssignment.isCreateable()){
			//-------------Assign Permission Sets -------------------     	
			List<PermissionSetAssignment> permSetAssignment = new List<PermissionSetAssignment>();
			PermissionSetAssignment permSet;
			PermissionSetAssignment managerPerm;
			for(User newUser: newUsers){
				permSet = new PermissionSetAssignment();
				permSet.AssigneeId = newUser.Id;
				if(ESDJC_Util.getRegionFromDivision(newUser.Division) == ESDJC_Util.REGION_AMER){
					permSet.PermissionSetId = settings.Portal_User_Amer_Permset_Id__c;
				} else if(ESDJC_Util.getRegionFromDivision(newUser.Division) == ESDJC_Util.REGION_EMEA){
					permSet.PermissionSetId = settings.Portal_User_Emea_Permset_Id__c;
				} else if(ESDJC_Util.getRegionFromDivision(newUser.Division) == ESDJC_Util.REGION_APAC){
					permSet.PermissionSetId = settings.Portal_User_Apac_Permset_Id__c;	
				} else if(ESDJC_Util.getRegionFromDivision(newUser.Division) == ESDJC_Util.REGION_JAPAN){
					permSet.PermissionSetId = settings.Portal_User_Japan_Permset_Id__c;	
				}
				permSetAssignment.add(permSet);
								
			}
			saveResults = Database.insert(permSetAssignment,false);
			
		} else {
			ESDJC_Util.displayAccessPrivilegeError('Create PermissionSetAssignment');
			errorMessage += 'Record processing Failed with message :  User does not have access to PermissionSetAssignment.\n';
		}
							
		} else {
			ESDJC_Util.displayAccessPrivilegeError('Create User');
		}
	}
	
	global void finish(Database.BatchableContext BC){
		if(Schema.Sobjecttype.Contact.isUpdateable()){
			try{
				update id2ContactMap.values();
			}catch(Exception ex){
				batchStatus = 'Failure';
				errorMessage += 'Record processing Failed with message : '+ (ex.getMessage().length()> 255 ? ex.getMessage().substring(0,255) : ex.getMessage()) + '\n';
			}
        }else{
        	batchStatus = 'Failure';
        	errorMessage += 'Record processing Failed with message :  User does not have access to update Contacts.\n';
        }
		if(Schema.Sobjecttype.ESDJC_Integration_Log__c.isUpdateable()){
			log.DJC_New_Contractor_Batch_Job_Finish_Time__c = DateTime.now();
			log.DJC_New_Contractor_Job_Status__c = batchStatus;
			String[] bodyLines =  new String[] {
				'ESDJC Integration Log Id: '+ log.Id,
				'ESDJC Integration Log Name: '+ log.Name,
				'\n',
				'Integration Start Time: '+log.Integration_Start_Time__c,
				'Integration Finish Time: '+log.Integration_Finish_Time__c,
				'Integration Status: '+log.Integration_Status__c,
				'\n',
				'DJC New Contractor Batch Job Start Time: '+ log.DJC_New_Contractor_Batch_Job_Start_Time__c,
				'DJC New Contractor Batch Job Finish Time: '+log.DJC_New_Contractor_Batch_Job_Finish_Time__c,
				'DJC New Contractor Batch Job Status: '+log.DJC_New_Contractor_Job_Status__c,
				'\n ************* If batch is failed, Please check following message for Records and corresponding errors:\n',
				errorMessage
			};
			
			ESDJC_Util.sendStatusEmail(BC, 'ESDJC New Contractor Batch: '+log.Name, new String[] {settings.Batch_Job_Report_Email__c}, bodyLines);		
			update log;
		} else {
			ESDJC_Util.displayAccessPrivilegeError('Update ESDJC_Integration_Log__c');
		}
	}
}