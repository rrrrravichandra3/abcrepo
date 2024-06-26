public without sharing class DJC_Survey_Notification_Async {
    
	public static void closedCaseNotificationWithSurvey(List<Id> CaseIds, boolean isManual){
		if (CaseIds!=null){
			doWork(caseIds, isManual, true);
		}
	} 

	@future
	public static void closedCaseNotificationWithSurvey(Id CaseId, boolean isManual){
		if (CaseId != null){
			List<Id> CaseIds = new List<Id>();
			CaseIds.add(caseId);
			doWork(caseIds, isManual, true);
		}
	} 
	
	public static void closedCaseNotificationWithoutSurvey(List<Id> caseIds){
		if(caseIds != null && caseIds.size() >0){
			doWork(caseIds, false, false);
		}
	}
	
	private static void doWork(List<Id> CaseIds, boolean isManual, boolean withSurvey){
		List<Case> surveyCases = new List<Case>();
		List<Messaging.SingleEmailMessage> surveyEmails = new List<Messaging.SingleEmailMessage>();		
		EmailTemplate emailTemplate = ESDJC_Util.getEmailTemplate(withSurvey ? 'ES_Concierge_Case_Closed_Survey_HTML' : 'ES_Concierge_Case_Closed_No_Survey_HTML');
		List<Case>  casesToBeUpdated = new List<Case>();	
		Case[] cases = [select id, contactid, contact.name, contact.email, DJC_Is_Survey_Email_Sent__c from Case where id in :caseIds];
		for (case c : cases){									
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
				if(surveyEmailResults[i].isSuccess() && withSurvey) {
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
}