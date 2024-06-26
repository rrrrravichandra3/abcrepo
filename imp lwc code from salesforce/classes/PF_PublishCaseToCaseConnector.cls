public with sharing class PF_PublishCaseToCaseConnector {
	@AuraEnabled
	public static String getAppSettings() {
		return CaseConnector_PeopelforceToSupportforce.appSettings();
	}

	@AuraEnabled
	public static String getDestinations() {
		return CaseConnector_PeopelforceToSupportforce.getDestinations();
	}

	@AuraEnabled
	public static String sendToDestination(String caseId, String destination, String route, String subject, String description, String priority, boolean transferAttachments, boolean transferComments, String pii) {
		return CaseConnector_PeopelforceToSupportforce.sendToDestination(caseId, destination, route, subject, description, priority, transferAttachments, transferComments, pii);
	}

	@AuraEnabled
	public static CaseWrapper getCaseRecord(String caseId){
		List<Case> cases = new List<Case>();
		Boolean areFieldsAccessible = PF_AccessibilityUtils.checkFLS('Case', PF_AccessibilityUtils.PermissionType.ACCESSIBLE, new List<String>{'Type', 'ES_DJC_Topic__c', 'PII__c', 'Subject', 'Origin', 'ContactId'});
		if(areFieldsAccessible){
			if(caseId != null){
				cases = [Select Id, Type, ES_DJC_Topic__c, PII__c, Subject, Origin, ContactId, Priority, Description from Case where Id =: caseId];
				if(cases[0].Type == null || cases[0].ES_DJC_Topic__c == null || cases[0].PII__c == null || cases[0].Subject == null || cases[0].Origin == null || cases[0].ContactId == null){
					return new CaseWrapper(cases[0], true, true);
				}
				else{
					return new CaseWrapper(cases[0], true, false);
				}
			}
			else{
				return null;
			}
		}
		else{
			return new CaseWrapper(cases[0], false);
		}
	}

	public class CaseWrapper{
		@AuraEnabled
		public Case caseRecord;
		@AuraEnabled
		public Boolean areFieldsAccessible;
		@AuraEnabled
		public Boolean areFieldsMissing;

		public CaseWrapper(Case caseRecord, Boolean areFieldsAccessible, Boolean areFieldsMissing){
			this.caseRecord = caseRecord;
			this.areFieldsAccessible = areFieldsAccessible;
			this.areFieldsMissing = areFieldsMissing;
		}

		public CaseWrapper(Case caseRecord, Boolean areFieldsAccessible){
			this.caseRecord = caseRecord;
			this.areFieldsAccessible = areFieldsAccessible;
		}
	}
}