public abstract Class CaseConnectorException Extends Exception {
	public boolean errored{get; set;}
	public Integer httpCode{get; set;}
	public String additionalDetails{get; set;}
	public String transactionId{get; set;}
	public String failedCallType{get; set;}
	/*public override String getMessage(){
		return null;
	}*/
	public abstract void handle(String step, String request, String transctionId, boolean requireRecovery, String caseId);
}