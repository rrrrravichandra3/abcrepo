public with sharing class IFB_SelectOption {
	
	@AuraEnabled public String value;
	@AuraEnabled public String label;
	@AuraEnabled public Boolean isDisabled;
	
	public IFB_SelectOption(String value, String label) {
		this.value = value;
		this.label = label;
	}

	public IFB_SelectOption(String value, String label, Boolean isDisabled) {
		this.value = value;
		this.label = label;
		this.isDisabled = isDisabled;
	}
}