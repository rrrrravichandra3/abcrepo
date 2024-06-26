public with sharing class PF_NHW_LightningComponentsService {
    
    public static List<PF_NHW_LightningComponentConfiguration> getComponentsConfigForCaseAndPage(Case nhwCase, PF_NHW_Page page){
        
        List<NHW_Lightning_Component__c> components = [SELECT Id__c, Provisioning_Type__c, Configurator__c, Fields__c,
                                                       (SELECT Attribute__c, Criteria__c,Profile_Criteria__c FROM NHW_Lightning_Component_Configurations__r)
                                                       FROM NHW_Lightning_Component__c WHERE Page__c = :page.name];
        
        List<PF_NHW_LightningComponentConfiguration> componentsConfig = new List<PF_NHW_LightningComponentConfiguration>();
        
        for(NHW_Lightning_Component__c lc : components){
            componentsConfig.add(getComponentConfiguration(lc, nhwCase));
        }
        
        return componentsConfig;
    }
    
    public static PF_NHW_LightningComponentConfiguration getComponentConfiguration(Case nhwCase, String componentId){
        
        List<NHW_Lightning_Component__c> components = [SELECT Id__c, Provisioning_Type__c, Configurator__c, Fields__c,
                                                       (SELECT Attribute__c, Criteria__c, Profile_Criteria__c FROM NHW_Lightning_Component_Configurations__r)
                                                       FROM NHW_Lightning_Component__c WHERE Id__c = :componentId];
        
        if(!components.isEmpty()){
            return getComponentConfiguration(components[0], nhwCase);
        }
        
        return null;
    }
    
    private static PF_NHW_LightningComponentConfiguration getComponentConfiguration(NHW_Lightning_Component__c lc, Case nhwCase){
        
        PF_NHW_LightningComponentConfiguration componentConfig = new PF_NHW_LightningComponentConfiguration(lc.Id__c, lc.Fields__c);
        
        for(NHW_Lightning_Component_Configuration__c attributeConfig : lc.NHW_Lightning_Component_Configurations__r){
           
            if(attributeConfig.Profile_Criteria__c == null){
                componentConfig.addAttribute(attributeConfig.Attribute__c, NHW_CriteriaEvaluator.evaluateCriteria(nhwCase, attributeConfig.Criteria__c));
                componentConfig.addDependencies(NHW_CriteriaEvaluator.getCriteriaDependencies(attributeConfig.Criteria__c));          
            }else{
                componentConfig.addAttribute(attributeConfig.Attribute__c, ((NHW_CriteriaEvaluator.evaluateCriteria(nhwCase, attributeConfig.Criteria__c)) && (NHW_ProfileCriteriaParser.evaluateProfileCriteria(nhwCase,attributeConfig))));
                componentConfig.addDependencies(NHW_CriteriaEvaluator.getCriteriaDependencies(attributeConfig.Criteria__c));  
                componentConfig.addDependencies(NHW_CriteriaEvaluator.getCriteriaDependencies(attributeConfig.Profile_Criteria__c));  
            }
            
        }
        
        if(!String.isBlank(lc.Configurator__c)){
            try{
                PF_NHW_LightningComponentConfigurator configurator = (PF_NHW_LightningComponentConfigurator)Type.forName(lc.Configurator__c).newInstance();
                componentConfig.attributes.addAll(configurator.getComponentConfiguration(nhwCase));
            }catch(Exception ex){
                System.debug('Configurator for ' + lc.Id__c + ' is not correctly configured');
            }
        }
        
        if(!String.isBlank(lc.Provisioning_Type__c)){
            PF_NHW_ProvisioningType pt = PF_NHW_ProvisioningType.getProvisioningTypeByName(lc.Provisioning_Type__c);
            if(pt != null){
                PF_NHW_ProvisioningTypeService ptService = pt.createService(nhwCase);
                componentConfig.provisionings = ptService.getProvisionings();
                componentConfig.addDependencies(ptService.getDependencies());
            }
        }
        
        return componentConfig;
    }
    
}