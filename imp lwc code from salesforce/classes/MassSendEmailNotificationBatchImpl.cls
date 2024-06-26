global class MassSendEmailNotificationBatchImpl implements Database.Batchable<SObject>, Database.Stateful {

	private List<User> usrToSend;
	
	//Constructor
	public MassSendEmailNotificationBatchImpl(List<User> users) {
		this.usrToSend = users;
	}
	
	//Instance methods
	global Database.QueryLocator start(Database.BatchableContext bc) {
		String query = 'Select u.id, ' + 
		                      'u.email, ' + 
		                      'u.FirstName, ' +
		                      'u.LastName, ' + 
		                      'u.name, ' +
		                      'u.Username, ' + 
		                      'u.Years_And_Months_Working__c, ' +
		                      'u.Exclude_from_Emails__c, ' +
		                      'u.Manager__c, ' +
		                      'u.Manager__r.name, ' +
		                      'u.Manager__r.email, ' +
		                      'u.Manager__r.FirstName, ' +
		                      'u.Manager__r.LastName, ' +
		                      'u.Manager__r.Username, ' +
		                      'u.Manager__r.Exclude_from_Emails__c From User u Where id IN: usrToSend';
		
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext bc, List<SObject> users){
		List<User> usersToEmail = (List<User>)users;  
		// send email
		sendEmail(usersToEmail);
	}


	global void finish(Database.BatchableContext bc){
		System.debug('******* Mass Send Email Notifications Batch done. *******');
	}
   	
   	
    //Send an Email to managers
    private void sendEmail(List<User> usersToEmail){
	   	
	   	//Specify the template to use
		Id templateId = [Select Id, Subject, Name, HtmlValue, DeveloperName, Body, Markup From EmailTemplate 
					  	 Where isActive = true
						 And Name ='Performance Review Ad Hoc Short 10 Months'
						 limit 1].Id;
	   	
	   	List<Messaging.SingleEmailMessage> sMailList = new List<Messaging.SingleEmailMessage>();
	   	
   		for(User usr: usersToEmail){
	   		
	   		if(! usr.Exclude_from_Emails__c){

	   			if(usr.Manager__c != null){
	   				
	   				if(!usr.Manager__r.Exclude_from_Emails__c){
	   					
	   					if(usr.Manager__r.Email != ''){
	   						
	   						//Create a new single mail for current user
						   	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

							//Assign the address to send. 
							mail.setTargetObjectId(usr.Id);
				
							String[] toAddresses = new String[] {usr.Manager__r.email}; 
							mail.setToAddresses(toAddresses);
							
							mail.setTemplateID(templateId);
							mail.setSaveAsActivity(false);
							
							sMailList.add(mail);
	   					}else{
							System.debug('Error, Manager email not specified');
	   					}
	   				}else{
						System.debug(usr.Manager__r.name + ' has the Exclude From Emails field checked, so will not receive the email notification.');	
	   				}
	   			}else{
	   				System.debug(usr.name + ' does not have a manager assigned.');
	   			}	
	   		}else{
	   			System.debug(usr.name + ' has the Exclude From Emails field checked, so will not receive the email notification.');
	   		}
   		}
	   	
	   	Messaging.sendEmail(sMailList);
   	}
}