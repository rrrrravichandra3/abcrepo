public with sharing class TF_SIFTInterviewCancelCtrl {

	private Id siftInterviewId 		 {get; set;} 
	public Id talentforceInterviewId {get; set;}
	public Id recruitId {get;set;}

	public TF_SIFTInterviewCancelCtrl() {
		try {
			// Atributes are of "Id" type, so it keeps our inputs "clean", meaning that page will throw an exception
			// if the query string contain something different than a valid "Id"
			this.siftInterviewId = ApexPages.currentPage().getParameters().get('sIntId');
			this.talentforceInterviewId = ApexPages.currentPage().getParameters().get('tIntId');

		} catch(Exception ex) {
			// In case there is an exception we inform the user. 
			// They should know this, so they can request a System Admin delete the records if needed.
			String msgStr = 'We could not cancel the SIFT Interview creation process.' + '\n\n' + (ex.getMessage() == null ? '' : ex.getMessage());
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, msgStr);
            ApexPages.addMessage(msg); 
		}
	}

    /*
	 * Deletes the "SIFT Interview" and "Recruit" records that were in progress.
	 * This method is intended to be called as a result of User cancelling the wizard 
	 * that creates the "Recruit"/"SIFT Interview" as part of the Talentforce - SIFT integration
	 * See: "New SIFT Interview" button on Interview 1, 2, 3.
	 */
	public PageReference interviewCreationProcessCancelled() {

		PageReference pr = new PageReference('/');

		// If we don't get the parameters we are expecting, we silenty go home
		if (this.siftInterviewId == null || this.talentforceInterviewId == null) {
			return pr;
		} 	
		
		try {
			// By default, we redirect the user to the Interview 1, 2, 3 page.
			pr = new PageReference('/' + this.talentforceInterviewId);
			

		} catch(Exception ex) {
			// In case there is an exception we inform the user. 
			// They should know this, so they can request a System Admin delete the records if needed.
			String msgStr = 'We could not cancel the SIFT Interview creation process.' + '\n\n' + (ex.getMessage() == null ? '' : ex.getMessage());
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, msgStr);
            ApexPages.addMessage(msg); 
            pr = null;
		}

		return pr;
	}
}