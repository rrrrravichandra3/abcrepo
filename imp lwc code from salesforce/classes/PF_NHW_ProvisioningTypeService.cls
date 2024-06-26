public abstract class PF_NHW_ProvisioningTypeService {

    public PF_NHW_ProvisioningType provisioningType{get; set;}
    public Case provisioningCase{get; set;}
    protected NHW_ProvisioningStore provisioningStore{get; set;}
    
    public abstract List<Object> getProvisionings();
    
    public abstract Set<String> getDependencies();
    
    protected List<NHW_Provisioning__c> getNHWProvisionings(){
        
        if(provisioningStore == null){
            provisioningStore = new NHW_ProvisioningStore(provisioningCase, provisioningType);
        }
        
        return provisioningStore.provisionings;
    }
    
    protected Set<String> getProvisioningsDependencies(){

        if(provisioningStore == null){
            provisioningStore = new NHW_ProvisioningStore(provisioningCase, provisioningType);
        }
        return provisioningStore.dependencies;
    }
}