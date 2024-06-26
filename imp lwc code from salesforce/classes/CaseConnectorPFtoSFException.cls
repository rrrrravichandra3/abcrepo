public class CaseConnectorPFtoSFException extends CaseConnectorException {
	public boolean errored{get; set;}
	public Integer httpCode{get; set;}
	public String additionalDetails{get; set;}
	public String transactionId{get; set;}
	public String failedCallType{get; set;}

	public override void handle(String step, String request, String transctionId, boolean requireRecovery, String caseId){
		// Add logi to handle the error
		Case_Connector_Error__c connectorError = new Case_Connector_Error__c();
		connectorError.Step__c = step;
		connectorError.Message__c = this.getMessage();
		connectorError.Aditional_Details__c = this.additionalDetails;
		connectorError.HTTPCode__c = this.httpCode;
		connectorError.Transction_Id__c = transctionId;
		connectorError.Request__c = request;
		connectorError.Need_Recovery__c = requireRecovery;
		connectorError.Case__c = caseId;
		insert connectorError;
	}
}