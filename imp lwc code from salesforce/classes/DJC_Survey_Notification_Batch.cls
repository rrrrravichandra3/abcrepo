global class DJC_Survey_Notification_Batch implements Database.Batchable<sObject> {
	
	private List<Id> caseIds;
	private Boolean isManual;
		 	
	global DJC_Survey_Notification_Batch(List<Id> caseIds, Boolean isManual){
		this.caseIds = caseIds;
		this.isManual = isManual;  
	}
	
	global DJC_Survey_Notification_Batch(Id caseId, Boolean isManual){
		this.caseIds = new List<Id>();
		this.caseIds.add(caseId);
		this.isManual = isManual;  
	}	
		
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator('select id, contactid, contact.name, contact.email, DJC_Is_Survey_Email_Sent__c from Case where id in :caseIds'); 
	}
	
	global void execute(Database.BatchableContext BC,  List<sObject> scope){	
		List<Case> surveyCases = new List<Case>();
		List<Messaging.SingleEmailMessage> surveyEmails = new List<Messaging.SingleEmailMessage>();		
		EmailTemplate emailTemplate = ESDJC_Util.getEmailTemplate('DJC_Survey_Email_Template');
		List<Case>  casesToBeUpdated = new List<Case>();	
		for (sObject sobj : scope){
			Case c = (Case)sobj;						
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();			
			mail.setTemplateId(emailTemplate.id);
			mail.setWhatId(c.Id);
			mail.setTargetObjectId(c.contactId);
			mail.OrgWideEmailAddressId=REWS_Setting__c.getInstance().Mail_services_Orgwide_email__c;
			surveyCases.add(c);
			surveyEmails.add(mail);							
		}		
		if(surveyEmails.size()>0) {
			List<Messaging.SendEmailResult> surveyEmailResults = Messaging.sendEmail(surveyEmails,false);
			for(Integer i=0;i<surveyEmailResults.size();i++) {
				if(surveyEmailResults[i].isSuccess()) {
					surveyCases.get(i).DJC_Is_Survey_Email_Sent__c=true;
					surveyCases.get(i).DJC_Survey_Email_Sent_On__c = System.now(); 
					if (isManual != null){
						surveyCases.get(i).DJC_Was_Survey_Sent_Manually__c = isManual;
					}
					casesToBeUpdated.add(surveyCases.get(i));
				}
			}
			if (casesToBeUpdated.size()>0){
				update casesToBeUpdated;
			}
		}						
	}
	
	global void finish (Database.BatchableContext BC){} 
}