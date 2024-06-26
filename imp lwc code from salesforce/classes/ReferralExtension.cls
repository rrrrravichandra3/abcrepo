public with sharing class ReferralExtension {

	public ReferralExtension() {
	}

	public PageReference ListViewRedirect() {
		PageReference pageref = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/' );
		pageref.setRedirect(true);
		return pageref;
	}


}