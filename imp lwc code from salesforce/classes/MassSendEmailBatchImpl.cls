global class MassSendEmailBatchImpl implements Database.Batchable<SObject>, Database.Stateful {
	//Instance variables
   	private Set<String> userIds;
   	private List<User> usersToEmail;

   //Constructors
   public MassSendEmailBatchImpl(Set<String> userIds, List<User> users) {
       this.usersToEmail = users;
       this.userIds = userIds;
   }

   //Instance methods

   global Database.QueryLocator start(Database.BatchableContext bc) {
       String query = 'select id, email, firstName, lastName, name from User where id in ';
       String inClause = '(';
        
       for (String iter : userIds) {
           inclause += '\'' + iter + '\',';
       }
       inClause = inClause.substring(0, inClause.length() -1);
       inClause += ')'; 
       query += inClause;
       
       return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext bc, List<SObject> users){
       List<User> usersToEmail = (List<User>)users;  
       // send email
       sendEmail(usersToEmail); 
   }

   global void finish(Database.BatchableContext bc){
       //
   }
   
   
   /**
    * Send an Email with data in parameters
    * @param emailTemplateUniqueName name of email template
    */
	private void sendEmail(List<User> users)
	{
		
		// Specify a template
        list<EmailTemplate> template = [Select Id, Subject, Name, HtmlValue, DeveloperName, Body, Markup From EmailTemplate 
									  	Where isActive = true
										And Name ='MissingV2MOM90Days' 
										limit 1];
        if (template.size() > 0)  
        {
	        List<Messaging.SingleEmailMessage> sMailList = new List<Messaging.SingleEmailMessage>();
	        List<Id> usersId = new List<Id>();
	        // create email message 
	        Messaging.SingleEmailMessage  mail = new Messaging.SingleEmailMessage();
	        for(User u: users){
	         
	        // Assign the addresses for the To lists to the mail object. 
				mail.setTargetObjectId(u.id);
			
			// Specify the name used as the display name.
			mail.setSenderDisplayName(UserInfo.getName());
			
			// Set to True if you want to BCC yourself on the email.
			mail.setBccSender(false);
			
			// Optionally append the salesforce.com email signature to the email.
			// The email address of the user executing the Apex Code will be used.
			mail.setUseSignature(false);
			
			// Specify the text content of the email.
			mail.setTemplateID(template[0].Id);
			mail.setSaveAsActivity(false);			
				sMailList.add(mail);
	        }
			// Send the email you have created. 
	        //Messaging.sendEmail(new Messaging.MassEmailMessage[]{ mail});
	        Messaging.sendEmail(sMailList);
        }
	}
}