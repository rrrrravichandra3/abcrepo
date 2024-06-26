public with sharing class PF_NHW_DesktopProvisioningTypeService extends PF_NHW_ProvisioningTypeService{
    
    public override List<Object> getProvisionings(){
        List<NHW_Provisioning__c> desktopProvisionings = getNHWProvisionings();
        List<desktopProvisioning> result = new List<desktopProvisioning>();
        
        if(desktopProvisionings != null){
            for(NHW_Provisioning__c provisioning:desktopProvisionings){
                result.add(new desktopProvisioning(provisioning.name, provisioning.name));
            }
        }
        
        return result;
    }
    
    public override Set<String> getDependencies(){
        return getProvisioningsDependencies();
    }
    
    public class desktopProvisioning{
        
        @AuraEnabled
        public String label{get; private set;}
        
        @AuraEnabled
        public String value{get; private set;}
        
        public desktopProvisioning(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
}