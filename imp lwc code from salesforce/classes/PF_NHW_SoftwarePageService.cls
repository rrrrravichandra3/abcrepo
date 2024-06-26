public with sharing class PF_NHW_SoftwarePageService extends PF_NHW_PageService{
    
    protected override List<PF_NHW_LightningComponentConfiguration> getComponentsConfig(){
        return PF_NHW_LightningComponentsService.getComponentsConfigForCaseAndPage(provisioningCase, PF_NHW_Page.SOFTWARE);
    }
    
    public void addAdditionalAccessForTableauHire() {
        //Grab the Tableau Camo provisioning record
        //Call profile criteria parser on the record
        List<NHW_Provisioning__c> tableauCamoRec = [Select Id, Name, Profile_Criteria__c FROM NHW_Provisioning__c WHERE Name = 'Tableau Core Access' LIMIT 1];
        //If we get one match back, then we know it's tableau hire
        Boolean isTableauHire = NHW_ProfileCriteriaParser.parseProvisionings(this.provisioningCase, tableauCamoRec).size() == 1 ? True : False;
        Boolean softwareAccessRecExists = False;

        if(isTableauHire) {
            //Check if a software access prov record exists
            for(NHW_Software_Access_Provisioning__c record : [Select Id, Provisioning_Id__c From NHW_Software_Access_Provisioning__c WHERE Provisioning_Case__c =: this.provisioningCase.Id]) {
                if(record.Provisioning_Id__c == tableauCamoRec[0].Id) {
                    softwareAccessRecExists = True;
                    break;
                }
            }
            //if there is no software access record THEN insert
            if(!softwareAccessRecExists) {
                NHW_Software_Access_Provisioning__c newRecord = new NHW_Software_Access_Provisioning__c();
                newRecord.Provisioning_Id__c = tableauCamoRec[0].Id;
                newRecord.Provisioning_Case__c = this.provisioningCase.Id;
                newRecord.Provisioning_name__c = tableauCamoRec[0].Name;
                newRecord.Selected__c = True;
            try {	
				if(NHW_Software_Access_Provisioning__c.sObjectType.getDescribe().isCreateable()){
					Database.insert(newRecord, false);
				}				
			}  catch (DmlException ex) { 
                system.debug('The following exception has occurred: ' + 
                             ex.getDmlStatusCode(0) + ex.getMessage());
            }
            }
        }
    }
    public override String processPageInformation(){

        List<NHW_Software_Access_Provisioning__c> provisioningsToUpsert = new List<NHW_Software_Access_Provisioning__c>();
        List<NHW_Software_Access_Provisioning__c> newProvisionings = getNewProvisionings();
        List<NHW_Software_Access_Provisioning__c> oldProvisionings = getCurrentProvisionings();
        List<NHW_Software_Access_Provisioning__c> provisioningsToReset = new List<NHW_Software_Access_Provisioning__c>();
        Map<String, NHW_Software_Access_Provisioning__c> oldProvisioningsByProvisioningName = new Map<String, NHW_Software_Access_Provisioning__c>();
        
        for(NHW_Software_Access_Provisioning__c oldProvisioning: oldProvisionings){
            oldProvisioningsByProvisioningName.put(oldProvisioning.Provisioning_name__c, oldProvisioning);
        }

        for(NHW_Software_Access_Provisioning__c newProvisioning: newProvisionings){
            if(oldProvisioningsByProvisioningName.containsKey(newProvisioning.Provisioning_name__c)){
                NHW_Software_Access_Provisioning__c oldProvisioning = oldProvisioningsByProvisioningName.get(newProvisioning.Provisioning_name__c);
                oldProvisioning.Configuration__c = newProvisioning.Configuration__c;
                oldProvisioning.Selected__c = newProvisioning.Selected__c;
                provisioningsToUpsert.add(oldProvisioning);
                oldProvisioningsByProvisioningName.remove(newProvisioning.Provisioning_name__c);
            }else{
                provisioningsToUpsert.add(newProvisioning);
            }
            if(!newProvisioning.Selected__c){
                provisioningsToReset.add(newProvisioning);
            }
        }
        
        if(!provisioningsToUpsert.isEmpty()){
            try {
                if(NHW_Software_Access_Provisioning__c.sObjectType.getDescribe().isCreateable() && NHW_Software_Access_Provisioning__c.sObjectType.getDescribe().isUpdateable()){
                    Database.upsert(provisioningsToUpsert, false);
                }
            }  catch (DmlException ex) { 
                system.debug('The following exception has occurred: ' + 
                             ex.getDmlStatusCode(0) + ex.getMessage());
            }
        }
        
        if(!oldProvisioningsByProvisioningName.isEmpty()){
            provisioningsToReset.addAll(oldProvisioningsByProvisioningName.values());
            DELETE oldProvisioningsByProvisioningName.values();
        }
        
        if(!provisioningsToReset.isEmpty()){
            resetCaseInformation(provisioningsToReset);
        }
        
        addAdditionalAccessForTableauHire();

        return null;
    }
    
    private void resetCaseInformation(List<NHW_Software_Access_Provisioning__c> provisionings){
        
        Set<Id> provisioningsIds = new Set<Id>();
        
        for(NHW_Software_Access_Provisioning__c provisioning: provisionings){
            provisioningsIds.add(provisioning.Provisioning_Id__c);
        }
        
        for(NHW_Provisioning__c provisioningConfig: [SELECT Metadata__c FROM NHW_Provisioning__c WHERE Id IN :provisioningsIds]){
            if(!String.isBlank(provisioningConfig.Metadata__c)){
                Map<String, Object> metadata = (Map<String, Object>)JSON.deserializeUntyped(provisioningConfig.Metadata__c);
                if(metadata.containsKey('field')){
                    String field = (String)metadata.get('field');
                    provisioningCase.put(field, null);
                }
            }
        }
    }
    
    private List<NHW_Software_Access_Provisioning__c> getCurrentProvisionings(){
        return [SELECT Provisioning_Case__c, Configuration__c, Provisioning_name__c, Selected__c, Provisioning_Id__c FROM NHW_Software_Access_Provisioning__c WHERE Provisioning_Case__c = :this.provisioningCase.Id];
    }
    
    private List<NHW_Software_Access_Provisioning__c> getNewProvisionings(){

        List<NHW_Software_Access_Provisioning__c> accessProvisionings = new List<NHW_Software_Access_Provisioning__c>();
        
        if(this.additionalInformation != null && this.additionalInformation.containsKey('ITEMS')){
            
            List<Object> accessItems = (List<Object>)this.additionalInformation.get('ITEMS');
            
            for(Object accessItem: accessItems){
                NHW_Software_Access_Provisioning__c  accessProvisioning = 
                    (NHW_Software_Access_Provisioning__c)JSON.deserialize(JSON.serialize(accessItem), NHW_Software_Access_Provisioning__c.class);
                
                accessProvisioning.Provisioning_Case__c = this.provisioningCase.Id;
                accessProvisionings.add(accessProvisioning);
                
            }
        }
        
        return accessProvisionings;
    }
    public override void resetFieldsOnPageSkip(Case ProvisioningCase){ 
        List<NHW_Software_Access_Provisioning__c> provisionings = [SELECT Provisioning_Case__c, Configuration__c, Provisioning_name__c, Selected__c, Provisioning_Id__c 
                                                                  FROM NHW_Software_Access_Provisioning__c WHERE Provisioning_Case__c = :ProvisioningCase.Id];

        DELETE provisionings;
    }
    public override Map<String, Object> getPageConfig(){
        return new Map<String,List<NHW_Software_Access_Provisioning__c>>{'ITEMS_VALUES' => getCurrentProvisionings()};
    }
    
    public override List<ReviewItem> getReviewList(Case provisioningCase, PF_NHW_Process process){
        
        this.provisioningCase = provisioningCase;
        
        List<ReviewItem> reviewList = new List<ReviewItem>();
        List<NHW_Software_Access_Provisioning__c> provisionings = getCurrentProvisionings();
        
        for(NHW_Software_Access_Provisioning__c provisioning:provisionings){
            if(provisioning.Selected__c){
                reviewList.add(new ReviewItem(provisioning.Provisioning_name__c, String.isBlank(provisioning.Configuration__c) ? '-- No config needed --' : provisioning.Configuration__c.replaceAll(';', '; ').replaceAll(':', ': ') ));
            }
        }
       
        return reviewList;
    }
}