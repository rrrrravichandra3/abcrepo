public with sharing class PF_NHWCasePickerAuraServices {
	@AuraEnabled
	public static Boolean bannerVisibilityCheck() {
		NH_Settings__c nHS = NH_Settings__c.getOrgDefaults();
		return nHs.Banner_Visibility__c;
	}
}