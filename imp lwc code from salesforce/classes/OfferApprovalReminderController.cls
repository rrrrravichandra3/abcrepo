global class OfferApprovalReminderController {

	WebService static Boolean SendReminderEmail( Id offerId ){
		
		EmailServicesAddress esa = [ SELECT Id, EmailDomainName FROM EmailServicesAddress where LocalPart = 'offerapprovalreminder' ];

		Boolean isCompleted = false;
		
        EmailTemplate et = [Select Id from EmailTemplate where DeveloperName = 'Offer_Approval_Reminder'];

		List<ProcessInstance> piList = [SELECT Id,ProcessDefinitionId,Status,TargetObjectId FROM ProcessInstance WHERE TargetObjectId = : offerId and status = 'Pending' ];
		if ( piList.size() == 1 ){
			ProcessInstance pi = piList[0];
			//select the current approval base on offer and user record 
			List<ProcessInstanceWorkitem> piw = [ SELECT Id, ActorId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId =: pi.Id ];
			Id employeeRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Employee').getRecordTypeId();
			User u = [select Id, email from User where Id = : piw[0].ActorId ];
			Contact c = [ select Id from Contact where email =: u.email and RecordTypeId =: employeeRTId ];

			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(new String[]{u.email});
			mail.setBccSender(false);
			mail.setWhatId(offerId);
			mail.setTemplateId(et.Id);
			mail.setSaveAsActivity(false);
	 		mail.setTargetObjectId(c.Id);
			Savepoint sp = Database.setSavepoint();
			Messaging.sendEmail( new Messaging.SingleEmailmessage[] {mail} );
			Database.rollback(sp);
	 
			Messaging.SingleEmailMessage mailReal = new Messaging.SingleEmailMessage();
			mailReal.setToAddresses(new String[]{u.email});
			mailReal.setBccSender(false);
			mailReal.setSubject( mail.getSubject() );
			mailReal.setHtmlBody( mail.getHtmlBody() );
			Messaging.sendEmail( new Messaging.SingleEmailmessage[] {mailReal} );
	      	        
	        isCompleted = true;
        
		}  
		
		return isCompleted;
	}
	
	
}