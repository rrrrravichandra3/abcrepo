public with sharing class NHW_ProvisioningStore {

    private Case provisioningCase;
    private PF_NHW_ProvisioningType provisioningType;
    public List<NHW_Provisioning__c> provisionings{get; private set;}
    public Set<String> dependencies{get; private set;}
    
    public NHW_ProvisioningStore(Case provisioningCase, PF_NHW_ProvisioningType provisioningType){
        this.provisioningCase = provisioningCase;
        this.provisioningType = provisioningType;
        calculateProvisioningsInfo();
    }
    
    private void calculateProvisioningsInfo(){

        List<NHW_Provisioning__c> allProvisionings = [SELECT Name,Onboarding_Type__c,Onboarding_Category__c,Supportforce_ISC__c,Type__c,Auto_Display__c,is_Auto_Provisioned__c,Need_User_to_Clone__c,
                                                   Filter_Criteria__c, Profile_Criteria__c, Required__c,Drives_BSF__c,Lower_Cutoff__c,Upper_Cutoff__c, Metadata__c,Display_Name__c,Show_Remote_Options__c FROM NHW_Provisioning__c 
                                                   WHERE Type__c = :provisioningType.name order by Name ASC];

        List<NHW_Provisioning__c> matchedProvisionings = new List<NHW_Provisioning__c>();
        List<NHW_Provisioning__c> provisioningsWithProfileFilter = new List<NHW_Provisioning__c>();
        
        for(NHW_Provisioning__c provisioning : allProvisionings){
            
            this.dependencies = NHW_CriteriaEvaluator.getCriteriaDependencies(provisioning.Filter_Criteria__c);
            
            if(NHW_FilterCriteriaParser.parseProvisioning(provisioningCase, provisioning)){
                if(String.isBlank(provisioning.Profile_Criteria__c)){
                    matchedProvisionings.add(provisioning);
                }else{
                    provisioningsWithProfileFilter.add(provisioning);
                }
            }
        }
        
        if(!provisioningsWithProfileFilter.isEmpty()){
            matchedProvisionings.addAll(NHW_ProfileCriteriaParser.parseProvisionings(provisioningCase, provisioningsWithProfileFilter));
        }
        
        this.provisionings = matchedProvisionings;
    }
    
    //This method is used by old NHW.  Please remove it once NHW 2.0 is in place.
    public static List<NHW_Provisioning__c> getProvisionings(Case provisioningCase, String provisioningType){
        
        if(String.isBlank(provisioningType)){
           throw new NHWException('Provisioning type is required'); 
        }
                
        List<NHW_Provisioning__c> provisionings = [SELECT Name,Onboarding_Type__c,Onboarding_Category__c,Supportforce_ISC__c,Type__c,Auto_Display__c,is_Auto_Provisioned__c,Need_User_to_Clone__c,
                                                   Filter_Criteria__c, Profile_Criteria__c, Required__c,Drives_BSF__c,Lower_Cutoff__c,Upper_Cutoff__c, Metadata__c, Show_Remote_Options__c FROM NHW_Provisioning__c 
                                                   WHERE Type__c = :provisioningType];
        List<NHW_Provisioning__c> matchedProvisionings = new List<NHW_Provisioning__c>();
        List<NHW_Provisioning__c> provisioningsWithProfileFilter = new List<NHW_Provisioning__c>();
        
        for(NHW_Provisioning__c provisioning : provisionings){
            if(NHW_FilterCriteriaParser.parseProvisioning(provisioningCase, provisioning)){
                if(String.isBlank(provisioning.Profile_Criteria__c)){
                    matchedProvisionings.add(provisioning);
                }else{
                    provisioningsWithProfileFilter.add(provisioning);
                }
            }
        }
        
        if(!provisioningsWithProfileFilter.isEmpty()){
            matchedProvisionings.addAll(NHW_ProfileCriteriaParser.parseProvisionings(provisioningCase, provisioningsWithProfileFilter));
        }
        
        return matchedProvisionings;
    }
    
}