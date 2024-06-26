public with sharing class PF_NHW_VDIProvisioningTypeService extends PF_NHW_ProvisioningTypeService{
     public override List<Object> getProvisionings(){
         List<NHW_Provisioning__c> vdiProvisionings = getNHWProvisionings();
        List<VDIProvisioning> result = new List<VDIProvisioning>();
        
        if(vdiProvisionings != null){
            for(NHW_Provisioning__c provisioning:vdiProvisionings){
                result.add(new VDIProvisioning(provisioning.name, provisioning.name));
            }
        }
        
        return result;
    }
    
    public override Set<String> getDependencies(){
        return getProvisioningsDependencies();
    }
     public class VDIProvisioning{
        
        @AuraEnabled
        public String label{get; private set;}
        
        @AuraEnabled
        public String value{get; private set;}
        
        public VDIProvisioning(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
}