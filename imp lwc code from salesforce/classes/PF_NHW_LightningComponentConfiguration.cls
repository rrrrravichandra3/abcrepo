public with sharing class PF_NHW_LightningComponentConfiguration {

    @AuraEnabled
    public String id{get; private set;}

    @AuraEnabled
    public List<PF_NHW_LightningComponentAttribute> attributes{get; private set;}
    
    @AuraEnabled
    public List<Object> provisionings{get; set;}
    
    @AuraEnabled
    public Set<String> dependencies{get; private set;}

    public Set<String> fields{get; private set;}
    
    public PF_NHW_LightningComponentConfiguration(String id, String configFields){

        this.id = id;
        attributes = new List<PF_NHW_LightningComponentAttribute>();
        dependencies = new Set<String>();
        fields = new Set<String>();

        if(!String.isBlank(configFields)){
            for(String field: configFields.split(';')){
                fields.add(field.trim());
            }
        }
    }
    
    public void addAttribute(String name, Object value){
        attributes.add(new PF_NHW_LightningComponentAttribute(name, value));
    }
    
    public void addDependencies(Set<String> newDependencies){
        dependencies.addAll(newDependencies);
    }
}