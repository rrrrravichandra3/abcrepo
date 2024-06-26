global class  ESDJC_Update_Contact_Batch implements Database.Batchable<sObject> {
	private ESDJC_Integration_Log__c log;
	private ESDJC_Settings__c settings;
	
	private String batchStatus {get;set;}
	global static String SUCCESS_MESSAGE = 'Completed';
	private String csvContent {get;set;}

	private static Integer CSV_EMPLOYEE_NUMBER_INDEX = 0;
	private static Integer CSV_CONTACT_ID_INDEX = 1;
	private static Integer CSV_USER_ID_INDEX = 2;
	private static Integer CSV_STATUS_INDEX = 3;

	public ESDJC_Update_Contact_Batch(ESDJC_Integration_Log__c log) {
    	System.debug('+++ESDJC_Update_Contact_Batch constructor log='+log);
		this.log = log;
		
		settings = ESDJC_Settings__c.getInstance();
      	csvContent = 'ContactID,Status\n';
		batchStatus = 'Success';
		
		log.DJC_Update_Contact_Batch_Job_Start_Time__c = DateTime.now();
		log.DJC_Update_Contact_Job_Status__c = 'In Progress';
		
	}
	
    global Database.QueryLocator start(Database.BatchableContext BC){
    	System.debug('+++ESDJC_Update_Contact_Batch start');
    	Set<id> successIds = new Set<id>();
    	
    	List<Attachment> attachments = [SELECT Body FROM Attachment WHERE ParentId = :log.Id AND Name LIKE 'ESDJC%User Batch Result.csv%'];
		String csvContent;
		List<String> lines;
		List<String> values;
    	for(Attachment anAttachment : attachments){
    		csvContent = anAttachment.Body.toString();
    		lines = csvContent.split('\n');
    		for(String line: lines){
    			if(line.indexOf(',Completed') >= 0){
    				values = line.split(',');
    				successIds.add(values.get(CSV_CONTACT_ID_INDEX));
    			}
    		}
    	}
    	
    	System.debug('++++successIds='+successIds);
		return Database.getQueryLocator([SELECT ES_DJC_Record_Status__c FROM Contact WHERE id IN: successIds]);
   }
   global void execute(Database.BatchableContext BC,  List<sObject> scope){
    	System.debug('+++ESDJC_Update_Contact_Batch execute scope='+scope);

        if(Schema.Sobjecttype.Contact.isUpdateable()){
			Contact aContact;  	
			List<Contact> contacts = new List<Contact>();
	      	for(Sobject s : scope){
	      		aContact = (Contact) s;
	      		aContact.ES_DJC_Record_Status__c = '';
	      		contacts.add(aContact);
	   		}	
	   		
	   		List<Database.SaveResult> saveResults = Database.update(contacts,false);
	
	      	//-------------Process user update result -------------------     	
	      	Database.SaveResult result;
	      	
	      	for(Integer i=0;i<saveResults.size();i++){
	      		result = saveResults.get(i);
	      		csvContent += result.getId();
	  			if(result.success){
	  				csvContent += ',Completed\n';
	  			} else {
	  				batchStatus = 'Failure';
	  				csvContent += ','+result.getErrors()[0].getMessage()+'\n';
	  			}
	      	}
        } else {
        	ESDJC_Util.displayAccessPrivilegeError('Update Contact');
        }       
   }
    
   global void finish(Database.BatchableContext BC){
        if(Schema.Sobjecttype.Attachment.isCreateable()){
        	Blob body = Blob.valueOf('');
	      	String attachmentName = 'ESDJC Update Contact Batch Result.csv';
	    	List<Attachment> attachments = [SELECT Body FROM Attachment WHERE ParentId = :log.Id AND Name =: attachmentName];
	      	Attachment csvFile;
	      	if(attachments.size() > 0){
	      	 	csvFile= attachments.get(0);
	      	} else {
	      	 	csvFile= new Attachment();
	      	 	csvFile.body = body;
	      		csvFile.parentId=log.id;
	      	}
	      	body = Blob.valueOf(csvFile.Body.toString() + csvContent);
	      	csvFile.Name=attachmentName;
	      	csvFile.body = body;
        	upsert csvFile;
        } else {
        	ESDJC_Util.displayAccessPrivilegeError('Create Attachment');
        }       

        if(Schema.Sobjecttype.ESDJC_Integration_Log__c.isUpdateable()){
			log.DJC_Update_Contact_Batch_Job_Finish_Time__c = DateTime.now();
			log.DJC_Update_Contact_Job_Status__c = batchStatus;
			
			
	    	String[] bodyLines =  new String[] {
	    		'ESDJC Integration Log Id: '+ log.Id,
	    		'ESDJC Integration Log Name: '+ log.Name,
	    		'\n',
	    		'Integration Start Time: '+log.Integration_Start_Time__c,
	    		'Integration Finish Time: '+log.Integration_Finish_Time__c,
	    		'Integration Status: '+log.Integration_Status__c,
	    		'\n',
	    		'DJC New User Batch Job Start Time: '+ log.DJC_New_User_Batch_Job_Start_Time__c,
	    		'DJC New User Batch Job Finish Time: '+log.DJC_New_User_Batch_Job_Finish_Time__c,
	    		'DJC New User Batch Job Status: '+log.DJC_New_User_Job_Status__c,
	    		'\n',
	    		'DJC Update User Batch Job Start Time: '+ log.DJC_Update_User_Batch_Job_Start_Time__c,
	    		'DJC Update User Batch Job Finish Time: '+log.DJC_Update_User_Batch_Job_Finish_Time__c,
	    		'DJC Update User BatchJob Status: '+log.DJC_Update_User_Job_Status__c,
	    		'\n',
	    		'DJC Update Contact Batch Job Start Time: '+ log.DJC_Update_Contact_Batch_Job_Start_Time__c,
	    		'DJC Update Contact Batch Job Finish Time: '+log.DJC_Update_Contact_Batch_Job_Finish_Time__c,
	    		'DJC Update Contact Batch Job Status: '+log.DJC_Update_Contact_Job_Status__c
	    	};
	
			ESDJC_Util.sendStatusEmail(BC, 'ESDJC Update Contact Batch: '+log.Name, new String[] {settings.Batch_Job_Report_Email__c}, bodyLines);		
			update log;
        } else {
        	ESDJC_Util.displayAccessPrivilegeError('Update ESDJC_Integration_Log__c');
        }
   }

}