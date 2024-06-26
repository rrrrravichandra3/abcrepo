public with sharing class PrehireCommunityController {
    
    /*
* @Author Ronak Bandwal
* @params Id of the current logged in user (new hire community user)
* @returns Id of the provisioning case related to the new hire
*/
    
    @AuraEnabled
    public static Id getProvisioningCaseId(Id userId) {
        Id caseId;
        //get the associated contact for the user - this will be 'WDR Candidate' contact
        User u = [select id,contactid from User where id =:userId];
        
        //query if provisioning case already exists    
        List<Case> provisioningCases = PrehireCommunityCaseService.getProvisioningCases(u.ContactId);
        if(provisioningCases.size()>0) {
            caseId = provisioningCases[0].id;
        } else { //generate new Provisoning case
            
            //query preboarding case
            List<Case> preboardingCases = PrehireCommunityCaseService.getPreboardingCases(u.ContactId);
            Case newProvCase = PF_NHW_ProvisioningCaseStore.generateProvisioningCaseFromPreboardingCase(preboardingCases[0].Id);
            insert newProvCase;
            caseId = newProvCase.Id;
        }
        
        return caseId;
        
    }
    
    @AuraEnabled
    public static List<NHW_Provisioning__c> getProvisionings(Id caseId, String provisioningType) {
        
        PF_NHW_ProvisioningType pt =new PF_NHW_ProvisioningType(provisioningType,null);

        NHW_ProvisioningStore provisioningStore = new NHW_ProvisioningStore(new Case(id=caseId), pt);
        List<Id> provisioningIds = new List<Id>();
        List<NHW_Provisioning__c> provisioningsToReturn = new List<NHW_Provisioning__c>();
        
        if(provisioningStore.provisionings.size()>0) {
            for(NHW_Provisioning__c prov:provisioningStore.provisionings) {
            	provisioningIds.add(prov.Id);
        	}            
        	provisioningsToReturn = [select Id,Name,Static_Resource_image_URL__c from NHW_Provisioning__c where id in :provisioningIds];
        }
        System.debug(provisioningsToReturn);
        return provisioningsToReturn;

    }
    //This code block fetches accessibility related softwares
    @AuraEnabled
    public static List<NHW_Provisioning__c> getSoftwareProvisionings(Id caseId, String provisioningType){
        try {
            PF_NHW_ProvisioningType swpt =new PF_NHW_ProvisioningType(provisioningType,null);
            NHW_ProvisioningStore provisioningStore = new NHW_ProvisioningStore(new Case(id=caseId), swpt);
            List<Id> provisioningIds = new List<Id>();
            List<NHW_Provisioning__c> provisioningsToReturn = new List<NHW_Provisioning__c>();
            
            if(provisioningStore.provisionings.size()>0) {
                for(NHW_Provisioning__c prov:provisioningStore.provisionings) {
                    provisioningIds.add(prov.Id);
                }            
                provisioningsToReturn = [select Id,Name,Static_Resource_image_URL__c from NHW_Provisioning__c where id in :provisioningIds];
            }
            
            return provisioningsToReturn;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateCurrentTask(Id caseId,Integer currentTask){
        system.debug(currentTask);
        try {
            Case provisioningCase = [select Id,NH_Community_Page_Number__c from  Case where id=:caseId];
            provisioningCase.NH_Community_Page_Number__c = currentTask;
            update provisioningCase;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
        
    
     
}