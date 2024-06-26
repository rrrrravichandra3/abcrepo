public with sharing class PF_NHW_LaptopProvisioningTypeService extends PF_NHW_ProvisioningTypeService{

    public override List<Object> getProvisionings(){

        List<NHW_Provisioning__c> laptopProvisionings = getNHWProvisionings();
        List<LaptopProvisioning> result = new List<LaptopProvisioning>();
        
        if(laptopProvisionings != null){
            for(NHW_Provisioning__c provisioning:laptopProvisionings){
                result.add(new LaptopProvisioning(provisioning.name, provisioning.name));
            }
        }
        
        return result;
    }
    
    public override Set<String> getDependencies(){
        return getProvisioningsDependencies();
    }

    public class LaptopProvisioning{
        
        @AuraEnabled
        public String label{get; private set;}
        
        @AuraEnabled
        public String value{get; private set;}
        
        public LaptopProvisioning(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
}