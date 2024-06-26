public with sharing class BoardEmailController {

	public String ipAddress {get; set;}
	public Integer type {get; set;}

	public BoardEmailController(){
        Map<String, String> mapHeaders = ApexPages.currentPage().getHeaders();   
        type = Integer.valueof( ApexPages.currentPage().getParameters().get('type') );
        if(mapHeaders != null) {

            ipAddress = mapHeaders.get('True-Client-IP');
            if(ipAddress == null){
                ipAddress = mapHeaders.get('X-Salesforce-SIP');
            }
        }

	}

	public PageReference checkAndRedirect(){

			TF2Settings__c configurations = TF2Settings__c.getInstance();			
			String ResumeErrorEmail = configurations.ResumeErrorEmail__c;

			if ( ResumeErrorEmail == null )
				ResumeErrorEmail = 'afang@salesforce.com';

		    String emailMessage = 'I/O error alert ' + System.now() + ' ' + ipAddress;
		    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		    String[] toAddresses = new String[] { ResumeErrorEmail };
		    mail.setToAddresses(toAddresses);
		    mail.setReplyTo('noreply@salesforce.com');
		    mail.setSubject('Misfire');		    
		    if ( type == 1 )
		    	mail.setSubject('IO job board Error : Read Time Out ');
		    if ( type == 2 )
		    	mail.setSubject('IO job board Error : End Of File');		    
		    mail.setPlainTextBody(emailMessage);
		    mail.setHtmlBody(emailMessage);
		    Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });

		    return null;	
	}
}