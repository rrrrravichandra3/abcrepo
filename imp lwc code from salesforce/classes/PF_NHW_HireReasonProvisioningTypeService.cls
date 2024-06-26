public with sharing class PF_NHW_HireReasonProvisioningTypeService extends PF_NHW_ProvisioningTypeService {
public override List<Object> getProvisionings(){

        List<NHW_Provisioning__c> orgProvisionings = getNHWProvisionings();
        List<HireReasonProvisioning> result = new List<HireReasonProvisioning>();
        
        if(orgProvisionings != null){
            for(NHW_Provisioning__c provisioning:orgProvisionings){
                result.add(new HireReasonProvisioning(provisioning.name, provisioning.Id));
            }
        }
        
        return result;
    }
    
    public override Set<String> getDependencies(){
        return getProvisioningsDependencies();
    }

    public class HireReasonProvisioning {
        
        @AuraEnabled
        public String label{get; private set;}
        
        @AuraEnabled
        public String value{get; private set;}
        
        public HireReasonProvisioning(String label, String value){
            this.label = label;
            this.value = value;
        }
        

    }
}