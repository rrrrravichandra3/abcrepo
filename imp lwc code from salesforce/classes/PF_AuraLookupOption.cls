public with sharing class PF_AuraLookupOption {

    @AuraEnabled
    public String id;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public List<String> additionalInformation;
        
    public PF_AuraLookupOption(String id, String name){
        this.id = id;
        this.name = name;
        additionalInformation = new List<String>();
    }
}