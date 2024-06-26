public with sharing class PF_AuraPicklistOption {
	
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String value;
    
    public PF_AuraPicklistOption(String label, String value){
        this.label = label;
        this.value = value;
    }
    
}