public with sharing class IFB_CaptureFeedbackLightningExtension {
	
	private final IFB_Interview__c interview;
	private static final String STATUS_FEEDBACK_SUBMITTED = 'Feedback Submitted';

	public IFB_CaptureFeedbackLightningExtension(ApexPages.StandardController stdController) {
		this.interview = [select Id, Status__c 
							from IFB_Interview__c 
							where Id = :stdController.getId()];
	}

	public PageReference validateStatusIsNotFeedbackSubmitted(){
		PageReference pageToRedirect = null;
		if (interview.Status__c == STATUS_FEEDBACK_SUBMITTED) {
			pageToRedirect = new PageReference('/' + interview.Id);
		}
		return pageToRedirect;
	}
}