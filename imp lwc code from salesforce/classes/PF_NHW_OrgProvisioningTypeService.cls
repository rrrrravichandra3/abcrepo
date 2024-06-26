public with sharing class PF_NHW_OrgProvisioningTypeService extends PF_NHW_ProvisioningTypeService{
    
    public override List<Object> getProvisionings(){

        List<NHW_Provisioning__c> orgProvisionings = getNHWProvisionings();
        List<OrganizationProvisioning> result = new List<OrganizationProvisioning>();
        
        if(orgProvisionings != null){
            for(NHW_Provisioning__c provisioning:orgProvisionings){
                result.add(new OrganizationProvisioning(provisioning.name, provisioning.name));
            }
        }
        
        result.sort();
        
        return result;
    }
    
    public override Set<String> getDependencies(){
        return getProvisioningsDependencies();
    }

    public class OrganizationProvisioning implements Comparable{
        
        @AuraEnabled
        public String label{get; private set;}
        
        @AuraEnabled
        public String value{get; private set;}
        
        public OrganizationProvisioning(String label, String value){
            this.label = label;
            this.value = value;
        }
        
        public Integer compareTo(Object compareTo){
            
            OrganizationProvisioning op = (OrganizationProvisioning)compareTo;
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