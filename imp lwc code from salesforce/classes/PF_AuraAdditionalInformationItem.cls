public with sharing class PF_AuraAdditionalInformationItem {
    
    public enum FieldType{NumberField, StringField}
    
    @AuraEnabled
    public String name {get; set;}
    @AuraEnabled
    public String columns {get;set;}

    @AuraEnabled    
    public List<PF_AuraAdditionalInformationField> fields {get{
        if(fields == null){
            fields = new List<PF_AuraAdditionalInformationField>();
        }
        return fields;   
    } set;}
        
    public PF_AuraAdditionalInformationItem(String name, String columns){
        this.name = name;
        this.columns = columns;
    }
    
    public void addInformationField(String label, Object value, FieldType type, String format, String helpText){
        fields.add(new PF_AuraAdditionalInformationField(label, value, type, format, helpText));
    }
        
        public class PF_AuraAdditionalInformationField{

		    @AuraEnabled
            public String label {get; set;}
            @AuraEnabled
            public String type{get;set;}
            @AuraEnabled
            public String format{get;set;}
            @AuraEnabled            
            public String helpText{get;set;}
		    @AuraEnabled
            public Object value {get; set;}
            
            
            public PF_AuraAdditionalInformationField(String label, Object value, FieldType fieldType, String format, String helpText){
                this.label = label;
                this.value = value;
                this.type = fieldType.name();
                this.format = format;
                this.helpText = helpText;
            }
        }
}