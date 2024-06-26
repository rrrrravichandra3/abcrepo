public with sharing class PF_NHW_LightningComponentAttribute {

    @AuraEnabled
    public String name{get; private set;}

    @AuraEnabled    
    public Object value{get; private set;}
    
    public PF_NHW_LightningComponentAttribute(String name, Object value){
        this.name = name;
        this.value = value;
    }
}