global without sharing class DJC_Survey_Service { 
	webService static String sendSurvey(String djcCaseId) {
		
		if ((djcCaseId==null) || (djcCaseId=='')){
			return 'Illegal argument passed. Case Id cannot be null or blank.';
		}
		Case[] c = [select recordtype.name,origin,isClosed,DJC_Is_Survey_Email_Sent__c,ContactId,Division_Lookup__c from case where id = :djcCaseId ];
		if (c.size() == 0){
			return 'Case not found';
		}  
		boolean isClosed = c[0].isClosed;
		boolean isSurveyEmailSent = c[0].DJC_Is_Survey_Email_Sent__c;  	
		String contactId = c[0].ContactId;
		String division = c[0].Division_Lookup__c;
		String origin = c[0].origin;
		String recordtype = c[0].recordtype.name;
		if ((contactId == null) || contactId.equals('')) {
			return 'Case Contact is missing.';
		}
		if ((recordtype!=null)&&((recordtype.equalsIgnoreCase('New Hire Process - Onboarding'))||(recordtype.equalsIgnoreCase('New Hire Process')))){
			return 'Surveys are disabled for New Hire Process cases.';
		}
		if ((!isClosed) || (isSurveyEmailSent)){
			return 'Whoops! You cannot send a survey to this employee because the case is not closed or a survey has already been sent.';
		}else{
			DJC_Survey_Notification_Async.closedCaseNotificationWithSurvey(djcCaseId, true);
			return 'ok';	
		}  			
	}
}