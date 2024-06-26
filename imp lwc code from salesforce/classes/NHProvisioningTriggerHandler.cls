public without sharing class NHProvisioningTriggerHandler {
    
    public static void updateProvisioningRecords(List<NHW_Provisioning__c> provs) {
        for(NHW_Provisioning__c prov : provs){
            prov.ExternalIdentifier__c = prov.Name+prov.Organization__c+prov.Type__c+prov.Duplicate_Reason__c; 
        }
    }
    
}