public with sharing class PF_NHW_ResTypeProvisioningTypeService extends PF_NHW_ProvisioningTypeService {

    public override List<Object> getProvisionings(){

        List<NHW_Provisioning__c> orgProvisionings = getNHWProvisionings();
        List<ResourceTypeProvisioning> result = new List<ResourceTypeProvisioning>();
        
        if(orgProvisionings != null){
            for(NHW_Provisioning__c provisioning:orgProvisionings){
                result.add(new ResourceTypeProvisioning(provisioning.name, provisioning.Id));
            }
        }
        
        result.sort();
        return result;
    }
    
    public override Set<String> getDependencies(){
        return getProvisioningsDependencies();
    }

    public class ResourceTypeProvisioning implements Comparable{
        
        @AuraEnabled
        public String label{get; private set;}
        
        @AuraEnabled
        public String value{get; private set;}
        
        public ResourceTypeProvisioning(String label, String value){
            this.label = label;
            this.value = value;
        }
        
        public Integer compareTo(Object compareTo){
            ResourceTypeProvisioning op = (ResourceTypeProvisioning)compareTo;
            return this.label.compareTo(op.label);
        }
    }
    
}