global with sharing class REWS_Package_Notification_Batch implements Database.Batchable<sObject>{
	
    private EmailTemplate emailT; 
    global final String query; 
    
    global REWS_Package_Notification_Batch(String query) { 
    		
    		this.query = query; 
    		ESDJC_Util.ignoreEmailTriggers=true;
    		emailT = ESDJC_Util.getEmailTemplate('REWS_Delivery_Daily_Email');
  
     }

	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query); 
	}
	
	global void execute(Database.BatchableContext BC,  List<sObject> scope){
	ESDJC_Util.ignoreEmailTriggers=true;
		List<Case>  cases = new List<Case>();
		List<Case>  casesToBeUpdated = new List<Case>();
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		for(sObject s : scope){ 
			Case c = (Case)s; 
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setTargetObjectId(c.contactId);
			mail.setTemplateId(emailT.Id);
			mail.setWhatId(c.Id);
			mail.OrgWideEmailAddressId=REWS_Setting__c.getInstance().Mail_services_Orgwide_email__c;
			cases.add(c);
			emails.add(mail);
		}
    	
		if(emails.size()>0) {
			List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(emails,false);
			for(Integer i=0;i<emailResults.size();i++) {
				if(emailResults[i].isSuccess()) {
					cases.get(i).REWS_Is_Email_Sent__c=true;//set the email sent flag to true.
					cases.get(i).REWS_Email_Last_Sent_On__c = System.now(); 
					casesToBeUpdated.add(cases.get(i));
				}
			}
		}
			
	    if(casesToBeUpdated.size()>0) {
	    	update casesToBeUpdated;
	    }
	}
	
	global void finish (Database.BatchableContext BC){} 

	

}