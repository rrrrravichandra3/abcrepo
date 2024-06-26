public class CaseConnectorExampleException extends CaseConnectorException {
	public override void handle(String step, String request, String transctionId, boolean requireRecovery, String caseId){
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {'sreedhar.karukonda@salesforce.com'}; 
		mail.setToAddresses(toAddresses);
		mail.setTargetObjectId(UserInfo.getUserId());
		mail.setSenderDisplayName('Case Connector Error Notification');

		mail.setSubject('Your Case Transfer Failed with message : '+ this.getMessage() );
		mail.setBccSender(false);
		mail.setUseSignature(false);
		mail.setPlainTextBody( request);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}