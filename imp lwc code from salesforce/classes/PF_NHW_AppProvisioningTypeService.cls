public with sharing class PF_NHW_AppProvisioningTypeService extends PF_NHW_ProvisioningTypeService{
    
    public override List<Object> getProvisionings(){
        
        List<NHW_Provisioning__c> appProvisionings = getNHWProvisionings();
        List<ApplicationProvisioning> result = new List<ApplicationProvisioning>();
        
        if(appProvisionings != null){
            for(NHW_Provisioning__c provisioning:appProvisionings){
                result.add(new ApplicationProvisioning(provisioning.Id, provisioning.name, provisioning.Onboarding_Type__c,
                                                       provisioning.is_Auto_Provisioned__c, provisioning.Auto_Display__c, provisioning.metadata__c));
            }
        }
        
        result.sort();

        return result;
    }
    
    public override Set<String> getDependencies(){
        return getProvisioningsDependencies();
    }
    public class ApplicationProvisioning implements Comparable{
        
        @AuraEnabled
        public Id provisioningId{get; private set;}
        
        @AuraEnabled
        public String name{get; private set;}

        @AuraEnabled
        public String category{get; private set;}
        
        @AuraEnabled
        public Boolean isAutoprovisioned{get; private set;}

        @AuraEnabled
        public Boolean isAutoSelected{get; private set;}
        
        @AuraEnabled
        public String metadata{get; private set;}
        
        public ApplicationProvisioning(Id provisioningId, String name, String category, Boolean isAutoprovisioned,
                                       Boolean isAutoSelected, String metadata){
            this.provisioningId = provisioningId;
            this.name = name;
            this.category = category;
            this.isAutoprovisioned = isAutoprovisioned;
            this.isAutoSelected = isAutoSelected;
            this.metadata = metadata;
        }
        
        public Integer compareTo(Object compareTo){
            ApplicationProvisioning app = (ApplicationProvisioning)compareTo;
            return this.name.compareTo(app.name);
        }
    }
}