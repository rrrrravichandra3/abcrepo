public with sharing class TF_ApplicationPanelSummaryCtrl {
	public PageReference redirectToPanelSummary() {
		PageReference redirectPage;
		String recruitId = ApexPages.currentPage().getParameters().get('ruitId');
		
		if (String.isBlank(recruitId) == false) {
			redirectPage = Page.IFB_PanelCandidateOverview;
			redirectPage.getParameters().put('id', recruitId);	
		} else {
			String msgStr = Label.TF_SIFT_No_recruit_in_application;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, msgStr);
            ApexPages.addMessage(msg);
            redirectPage = null;
		}
		
		return redirectPage;
	}
}