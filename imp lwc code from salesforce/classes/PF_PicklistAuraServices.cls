public with sharing class PF_PicklistAuraServices {
    
    @AuraEnabled
    public static List<PF_AuraPicklistOption> getReimbursementClaimCurrencyOptions(){
        return getOptions(DJC_Wellness_Reimbursement_Claim__c.CurrencyIsoCode.getDescribe().getPicklistValues());
    }
    
    @AuraEnabled
    public static List<PF_AuraPicklistOption> getReimbursementEducationCourseTypeOptions(){
        return getOptions(DJC_Wellness_Reimbursement_Claim__c.DJC_Education_Policy__c.getDescribe().getPicklistValues());
    }
    
    @AuraEnabled
    public static List<PF_AuraPicklistOption> getWellnessActivities(){
        return getOptions(DJC_Wellness_Reimbursement_Claim__c.DJC_Wellness_Activity__c.getDescribe().getPicklistValues());
    }

    @AuraEnabled
    public static List<PF_AuraPicklistOption> getReimbursementProviders(String categoryGroup, String contactId){
        
        List<PF_AuraPicklistOption> providers = new List<PF_AuraPicklistOption>();
        
        for (DJC_Wellness_Provider__c provider : [select id, name from DJC_Wellness_Provider__c where DJC_Contact__c = :contactId and Category__c = :categoryGroup order by name]) {
            providers.add(new PF_AuraPicklistOption(provider.name, provider.id));
        }
        
        return providers;
    }
    
    @AuraEnabled
    public static List<PF_AuraPicklistOption> getReportRequestFrequencyOptions(){
        return getOptions(Case.ES_DJC_Report_Request_Frequency__c.getDescribe().getPicklistValues());
    }
    
    @AuraEnabled
    public static List<PF_AuraPicklistOption> getReportRequestEmploymentTypesOptions(){
        return getOptions(Case.ES_DJC_Report_Request_Employment_Types__c.getDescribe().getPicklistValues());
    }
    
    @AuraEnabled
    public static List<PF_AuraPicklistOption> getReportRequestDivisionOptions(){
        return getOptions(Case.ES_DJC_Report_Request_Divisions__c.getDescribe().getPicklistValues());
    }
    
    @AuraEnabled
    public static List<PF_AuraPicklistOption> getNHWDivisionOptions(){
        return getOptions(Case.Division__c.getDescribe().getPicklistValues());
    }
    
    @AuraEnabled
    public static List<PF_AuraPicklistOption> getNHWTeamOptions(){
        return getOptions(Case.NH_ET_Team__c.getDescribe().getPicklistValues());
    }
    
    @AuraEnabled
    public static List<PF_AuraPicklistOption> getNHWSubregionOptions(){
        return getOptions(Case.NH_ET_Sub_Region__c.getDescribe().getPicklistValues());
    }
    
    @AuraEnabled
    public static List<PF_AuraPicklistOption> getNHWETDepartmentCodeOptions(){
        return getOptions(Case.NH_Legacy_ET_Dept_Code__c.getDescribe().getPicklistValues());
    }
    
    @AuraEnabled
    public static List<PF_AuraPicklistOption> getNHWJobStatusOptions(){
        return getOptions(Case.Job_Status__c.getDescribe().getPicklistValues());
    }
    
    @AuraEnabled
    public static List<PF_AuraPicklistOption> getNHWContractorHireReasonOptions(){
        return getOptions(Case.Contractor_Hire_Reason__c.getDescribe().getPicklistValues());
    }
    
    @AuraEnabled
    public static List<PF_AuraPicklistOption> getNHWSoftwareAccessPSERoleOptions(){
        return getOptions(Case.NH_Open_Air_Role__c.getDescribe().getPicklistValues());
    }
    
    @AuraEnabled
    public static List<PF_AuraPicklistOption> getNHWBusinessObjectOptions(){
        return getOptions(Case.Business_Objects__c.getDescribe().getPicklistValues());
    }
    
    @AuraEnabled
    public static List<PF_AuraPicklistOption> getNHWShippingCountryOptions(){
        return getOptions(Case.Shipping_Country__c.getDescribe().getPicklistValues());
    }

    @AuraEnabled
    public static List<PF_AuraPicklistOption> getFormPicklistValues(String formId, String field){
        
        List<String> fieldOptions = [SELECT Options__c FROM PF_Form_Picklist_Field__mdt WHERE PF_Form__r.Id__c = :formId AND DeveloperName = :field].Options__c.split(';');
        List<PF_AuraPicklistOption> options = new List<PF_AuraPicklistOption>();
        
        for(String fieldOption:fieldOptions){
            options.add(new PF_AuraPicklistOption(fieldOption, fieldOption));
        }        
        
        return options;
    }
    
	@AuraEnabled
    public static List<PF_AuraPicklistOption> getReimbursementEducationCourseTypeDuration(){
        return getOptions(DJC_Wellness_Reimbursement_Claim__c.DJC_Education_Course_Duration__c.getDescribe().getPicklistValues());
    }

    private static List<PF_AuraPicklistOption> getOptions(List<Schema.PicklistEntry> entries){
        List<PF_AuraPicklistOption> options = new List<PF_AuraPicklistOption>();
        
        for(Schema.PicklistEntry entry : entries){
            options.add(new PF_AuraPicklistOption(entry.getLabel(), entry.getValue()));
        }
        
        return options;
    }
}