global class BatachableContactPemAssignment implements Database.Batchable<sObject>, Database.Stateful{

	private String queryString = null;
	private Id employeeRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Employee').getRecordTypeId();
	private Id managerProfileId = null;
	private Id employeeProfileId = null;
	private Id smalladminProfileId = null;
	private Id BigAdminProfileId = null;
	private Id VADAdminProfileId = null;
	private Id permSetBaseId = null;
	private Id permSetHMId = null;
	global Boolean hasError = false;
	global String errorMessage = null; 

	private List<PermissionSetAssignment> RecruiterList = new List<PermissionSetAssignment>();
	private Set<Id> SkipSetId = new Set<Id>();
	
	global BatachableContactPemAssignment(){}
	
	global BatachableContactPemAssignment( String query ){
		queryString = query;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		
		if(queryString==null){
			//queryString='select Id, ES_DJC_Is_Manager__c, RecordTypeId, Email from Contact where ES_DJC_Is_Manager__c = true and Email != null and ( CreatedDate = LAST_N_DAYS:1 OR LastModifiedDate = LAST_N_DAYS:1 )';				
            queryString='select Id, ES_DJC_Is_Manager__c, RecordTypeId, Email from Contact where Email != null and ( CreatedDate >= LAST_N_DAYS:1 OR LastModifiedDate >= LAST_N_DAYS:1 ) and RecordTypeId=:employeeRTId';                

		}	 
		
		return Database.getQueryLocator(queryString);		
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){

        //List<User> UserList = new List<User>();		
		//Map<String, Contact> newUserEmailMap = new Map<String, Contact>();
		Set<String> validEmailList = new Set<String>();
		
		List<User> ManagerUserList = new List<User>();	
		List<User> NotManagerUserList = new List<User>();
		Map<String, Contact> ManagerEmailMap = new Map<String, Contact>();
		Map<String, Contact> NotManagerEmailMap = new Map<String, Contact>();

		List<String> skippermsets = new List<String>();
		skippermsets.add( 'Talentforce - Recruiter Base' );
		skippermsets.add( 'Talentforce - Recruiter - Japan' );
		skippermsets.add( 'Talentforce - Recruiter Base w/ Do Not Share' );			
		
		for(SObject obj:scope){ 
			Contact c = (Contact)obj;
			if ( c.ES_DJC_Is_Manager__c == true )
				ManagerEmailMap.put( c.email, c );		
			else
				NotManagerEmailMap.put( c.email, c );							
		}			

		if ( ManagerEmailMap.size() > 0 || NotManagerEmailMap.size() > 0 ){

			if ( smalladminProfileId == null ) { smalladminProfileId = [select Id from Profile where Name = 'systemadministrator' limit 1 ].Id; SkipSetId.add(smalladminProfileId); }
			if ( BigAdminProfileId == null ) { BigAdminProfileId = [select Id from Profile where Name = 'System Administrator' or Name = 'システム管理者' limit 1 ].Id; SkipSetId.add(BigAdminProfileId); }
			if ( VADAdminProfileId == null ) { VADAdminProfileId = [select Id from Profile where Name = 'System Admin - w/o VAD' limit 1 ].Id; SkipSetId.add(VADAdminProfileId); }
			
			if ( managerProfileId ==null ) { managerProfileId = [select Id from Profile where Name = 'Manager' limit 1 ].Id; }
			if ( employeeProfileId == null ) { employeeProfileId = [select Id from Profile where Name = 'Employee' limit 1 ].Id; }

			if ( permSetBaseId == null ) permSetBaseId = [select Id from PermissionSet where label = 'Talentforce Base' limit 1].Id;
			if ( permSetHMId == null ) permSetHMId = [select Id from PermissionSet where label = 'Talentforce - Hiring Manager' limit 1].Id;
			
			RecruiterList = [select Id, AssigneeId from PermissionSetAssignment where PermissionSetId in (select Id from PermissionSet where label in : skippermsets ) ];

	
			Set<Id> CustomSkipId = new Set<Id>();
			List<TF_SkipPermSetAssignment__c> userIDs = TF_SkipPermSetAssignment__c.getall().values();
            if(userIDs.size()>0){
               for(TF_SkipPermSetAssignment__c currUser : userIDs){
                  String currUserId = currUser.Name;
                  if((currUserId.length()==15 || currUserId.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', currUserId)){
                    CustomSkipId.add(Id.valueOf(currUserId));
                  }
               }
            }
			
			if ( RecruiterList != null && RecruiterList.size() > 0 ){
				for ( PermissionSetAssignment p : RecruiterList ){
					CustomSkipId.add( p.AssigneeId );
				}
			}
			
			
			// check size
			
			if ( CustomSkipId.size() > 0 ) {
				if ( ManagerEmailMap.size() > 0 ) 
                    ManagerUserList = [ select Id, People_Manager__c, profileId from User where email in : ManagerEmailMap.keySet() and profileId not in : SkipSetId and Id not in : CustomSkipId and UserType = 'Standard'  ];
				if ( NotManagerEmailMap.size() > 0 ) 
                    NotManagerUserList = [ select Id, People_Manager__c, profileId from User where email in : NotManagerEmailMap.keySet() and profileId not in : SkipSetId and Id not in : CustomSkipId and UserType = 'Standard' ];
			} else {
				if ( ManagerEmailMap.size() > 0 ) 
                    ManagerUserList = [ select Id, People_Manager__c, profileId from User where email in : ManagerEmailMap.keySet() and profileId not in : SkipSetId and UserType = 'Standard' ];
				if ( NotManagerEmailMap.size() > 0 ) 
                    NotManagerUserList = [ select Id, People_Manager__c, profileId from User where email in : NotManagerEmailMap.keySet() and profileId not in : SkipSetId and UserType = 'Standard'  ];

			}	
			
			Set<Id> existingIdSet = new Set<Id>();
			Map<Id, User> UserMap = new Map<Id, User>(); 
			Map<Id, PermissionSetAssignment> psaHMMap = new Map<Id, PermissionSetAssignment>();
			Map<Id, PermissionSetAssignment> psaBASEMap = new Map<Id, PermissionSetAssignment>();
			
			for ( User u : ManagerUserList ){
				if ( u.profileId == managerProfileId || u.profileId == employeeProfileId ){
					existingIdSet.add( u.Id );
					UserMap.put(u.Id, u);
				}
			}
			
			List<PermissionSetAssignment> existingPermList = [ select Id, AssigneeId, PermissionSetId from PermissionSetAssignment where AssigneeId =:existingIdSet and ( PermissionSetId =: permSetBaseId or PermissionSetId =: permSetHMId ) ];

			for( PermissionSetAssignment psa : existingPermList ){
				if ( psa.PermissionSetId == permSetHMId )
					psaHMMap.put(psa.AssigneeId, psa);
				if ( psa.PermissionSetId == permSetBaseId)
					psaBASEMap.put(psa.AssigneeId, psa);	
			}
			
			Map<Id, User> UserHMMap = UserMap.clone();
			Map<Id, User> UserBaseMap = UserMap.clone();
			
			for ( User u : ManagerUserList ){
				if ( u.profileId == managerProfileId || u.profileId == employeeProfileId ){
				
					if ( psaHMMap.get(u.Id) != null )
						UserHMMap.remove(u.Id);
					
					if ( psaBASEMap.get(u.Id) != null )
						UserBaseMap.remove(u.Id);
				}				
			}
			
			List<PermissionSetAssignment> newPermList = new List<PermissionSetAssignment>();

	    	for ( User u : UserBaseMap.values() ){
				PermissionSetAssignment psabase = new PermissionSetAssignment();
				psabase.PermissionSetId = permSetBaseId;
				psabase.AssigneeId = u.Id;
				newPermList.add( psabase );	  
	    	}

	    	for ( User u : UserHMMap.values() ){	    	
				PermissionSetAssignment psaHM = new PermissionSetAssignment();
				psaHM.PermissionSetId = permSetHMId;
				psaHM.AssigneeId = u.Id;
				newPermList.add( psaHM );	 								  		
	    	}	    	
	    	
	    		    	
	    	try {
	    		insert newPermList;
	    	} catch ( Exception ex) {
	    		hasError = true;
	    		errorMessage = '\n\nError Message: ' + ex.getMessage() + '\nStack Trace: ' + ex.getStackTraceString();
	    		system.debug('Something wrong with updating new hiring manager profile in User record.');
	    	}
	    	
	    	// removing old perm set when user is no longer a manager
			Set<Id> rmPermSet = new Set<Id>();

	    	for ( User u : NotManagerUserList ){
				if ( u.profileId == managerProfileId || u.profileId == employeeProfileId ){
					rmPermSet.add( u.Id );
				}
	    	}
	    	
	    	List<PermissionSetAssignment> oldPermList = [select Id, AssigneeId from PermissionSetAssignment where AssigneeId in : rmPermSet and ( PermissionSetId =: permSetBaseId or PermissionSetId =: permSetHMId ) ];
	    	
			if ( oldPermList.size() > 0 ){
				try {
		    		delete oldPermList;
		    	} catch ( Exception ex) {
		    		hasError = true;
		    		errorMessage = '\n\nError Message: ' + ex.getMessage() + '\nStack Trace: ' + ex.getStackTraceString();
		    		system.debug('Something wrong with updating new hiring manager profile in User record.');
		    	}			
			}   	
	    	
		}
		
	}
	
	global void finish(Database.BatchableContext BC){
	    AsyncApexJob a = [SELECT id, ApexClassId, 
	                    JobItemsProcessed, TotalJobItems, 
	                    NumberOfErrors, CreatedBy.Email, ExtendedStatus
	                    FROM AsyncApexJob
	                    WHERE id =:BC.getJobId()];

		if ( ( a != null && a.NumberOfErrors > 0 ) || hasError ) { 

			TF2Settings__c configurations = TF2Settings__c.getInstance();			
			String BatchErrorEmail = configurations.BatchErrorEmail__c;

		    String emailMessage = 'Your batch job '
             + 'BatachableContactPemAssignment '
             + 'has finished. It executed '
             + a.totalJobItems
             + ' batches. Of which, ' + a.jobitemsprocessed
             + ' were processed and '
             + a.numberOfErrors
             + ' batches threw unhandled exceptions.'
             + ' Here is the Batch Job Error message : '
             + a.ExtendedStatus
             + ' \n\nHere is the Handled Exceptions information: ' + errorMessage;
		    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		    String[] toAddresses = new String[] { BatchErrorEmail };
		    mail.setToAddresses(toAddresses);
		    mail.setReplyTo('noreply@salesforce.com');
		    mail.setSubject('Batch job error - PermSet');
		    mail.setPlainTextBody(emailMessage);
		    mail.setHtmlBody(emailMessage);
		    Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
	    }

		System.debug('************* Finised updating perm Batch from Contact. *******');
	}
	
}