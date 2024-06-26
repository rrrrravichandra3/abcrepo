public with sharing class PF_NHW_RoleProvisioningTypeService extends PF_NHW_ProvisioningTypeService{
    
    public override List<Object> getProvisionings(){

        List<NHW_Provisioning__c> roleProvisionings = getNHWProvisionings();
        List<RoleProvisioning> result = new List<RoleProvisioning>();
        
        if(roleProvisionings != null){
            for(NHW_Provisioning__c provisioning:roleProvisionings){
                result.add(new RoleProvisioning(provisioning.name, provisioning.name));
            }
        }
        
        result.sort();
        return result;
    }
    
    public override Set<String> getDependencies(){
        return getProvisioningsDependencies();
    }

    public class RoleProvisioning implements Comparable{
        
        @AuraEnabled
        public String label{get; private set;}
        
        @AuraEnabled
        public String value{get; private set;}
        
        public RoleProvisioning(String label, String value){
            this.label = label;
            this.value = value;
        }
        
        public Integer compareTo(Object compareTo){
            
            RoleProvisioning op = (RoleProvisioning)compareTo;
            if(op.label == 'Other'){
                return -1;
            }
            if(this.label == 'Other'){
                return 1;
            }
            return this.label.compareTo(op.label);
        }
    }
}