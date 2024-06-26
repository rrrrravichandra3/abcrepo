public class PF_NHW_EmailConfigurator implements PF_NHW_LightningComponentConfigurator{
    
    public List<PF_NHW_LightningComponentAttribute> getComponentConfiguration(Case c){
        String emailHelpText = '';
        if(!String.isBlank(c.NHW_Employee_Type__c)){
            if(c.NHW_Employee_Type__c.containsIgnorecase('Regular Employee')){
                emailHelpText = NH_Settings__c.getOrgDefaults().FTE_Email_Help_Text__c;
            }else if(c.NHW_Employee_Type__c.containsIgnorecase('contractor')){
                emailHelpText = NH_Settings__c.getOrgDefaults().Contractor_Email_Help_Text__c;
            }else if(c.NHW_Employee_Type__c.containsIgnorecase('relocation')){
                emailHelpText = NH_Settings__c.getOrgDefaults().Relocation_Email_Help_Text__c;
            }
        } 
        return new List<PF_NHW_LightningComponentAttribute>{new PF_NHW_LightningComponentAttribute('EMAIL_HELP_TEXT', emailHelpText)};
    }

}