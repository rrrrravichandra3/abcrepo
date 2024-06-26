@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
public with sharing abstract class PF_NHW_PageService {
    
    protected Case provisioningCase;
    protected Case formerCase;
    protected string flowType;
    protected Map<String, Object> additionalInformation;

    public Map<String, Object> getPageInformation(String flowType, String caseId){
        
        if(!String.isBlank(caseId)){
            provisioningCase = PF_NHW_ProvisioningCaseStore.getProvisioningCaseById(caseId);
        }else if(!String.isBlank(flowType)){
            if(flowType == 'employeeviewandupdate'){
                this.flowType = flowType;
                provisioningCase = PF_NHW_ProvisioningCaseStore.getProvisioningCaseForNewHire(UserInfo.getUserEmail());
                if(provisioningCase == null) {
                    system.debug('Error on PF_NHW_PageService:getPageInformation - No provisioning case found for New Hire');
                    throw new AuraHandledException(PF_NHWAuraServices.EMPLOYEEVIEWANDUPDATE_EXCEPTION_MESSAGE);
                }
            }else{
                provisioningCase = PF_NHW_ProvisioningCaseStore.getEmptyProvisioningCase(PF_NHW_Process.getProcessByName(flowType));
            }
        }
        //Skip for employee view as they woud not be owners of the prov case.
        if((flowType!= null && flowType != 'employeeviewandupdate') || flowType ==null ){
            PF_NHW_SecurityUtil.checkUserHasAccessToCase(provisioningCase);
        }
        
        
        Map<String, Object> pageInformation = new Map<String, Object>();
        Map<String, Object> pageConfig = new Map<String,Object>();
        PF_NHW_Process p = provisioningCase != null ? PF_NHW_Process.getProcessByName(provisioningCase.NHW_Employee_Type__c) : null;
        pageConfig.putAll(getPageConfig());
        pageConfig.put('HELP_URL', NH_Settings__c.getOrgDefaults().NHW_Need_Help_Link__c);
        if(p!=null){
            pageConfig.put('SUBMIT_PROMPT_COMPONENT',p.submitPromptComponentName);
        }else{
            pageConfig.put('SUBMIT_PROMPT_COMPONENT',null);
        }

        if(flowType!= null && flowType == 'contractor'){
            pageConfig.put('SKIP_CONTRACTOR_PROMT', NH_Settings__c.getOrgDefaults().Skip_contractor_submit_promt__c);
        }
        
        provisioningCase = getProvisioningCase();
        
        List<PF_NHW_LightningComponentConfiguration> componentsConfig = getComponentsConfig();
        resetInvisibleFields(componentsConfig);
        
        pageInformation.put('CASE', provisioningCase);
        pageInformation.put('COMP_CONFIG', componentsConfig);
        pageInformation.put('PAGE_CONFIG', pageConfig);
        return pageInformation;
    }
    
    public String processInformation(Case c, Map<String, Object> additionalInfo, Boolean moveForward){
        this.provisioningCase = c;
        this.formerCase = getFormerCase(provisioningCase);
        this.additionalInformation = additionalInfo;
        
        PF_NHW_SecurityUtil.checkUserHasAccessToCase(formerCase);
        this.processPageInformation();
        
        if(moveForward){
            PF_NHW_Process process = PF_NHW_Process.getProcessByName(provisioningCase.NHW_Employee_Type__c);
            provisioningCase.NHW_Page_Number__c = PF_NHW_Process.getNextStep(provisioningCase);
        }
        
        try {
            if(Case.sObjectType.getDescribe().isCreateable() && Case.sObjectType.getDescribe().isUpdateable()){
                Database.UpsertResult result = Database.upsert(provisioningCase, false);
                
                //W-15302981 - Putting Provision case status to on hold if contact is Deactive/inactive - Ajay Kushwah
                if(result.isSuccess() && !moveForward && provisioningCase.NH_Employee_Id__c != null){
                    checkIsContactDeactive(provisioningCase);
                }
            }
        }  catch (DmlException ex) { 
            system.debug('The following exception has occurred: ' + 
                         ex.getDmlStatusCode(0) + ex.getMessage());
        }
        
        //If we need to do any operations after Upsert 
        this.additionalProcessing();
        return provisioningCase.Id;
    }
    
    private void resetInvisibleFields(List<PF_NHW_LightningComponentConfiguration> componentsConfig){
        
        if(provisioningCase == null || provisioningCase.Id == null){
            return;
        }
        
        Boolean updateCase = false;
        
        for(PF_NHW_LightningComponentConfiguration componentConfig: componentsConfig){
            
            Boolean visible;
            Boolean resetWhenHidden;
            
            for(PF_NHW_LightningComponentAttribute attribute: componentConfig.attributes){
                if(attribute.name == 'visible'){
                    visible = (Boolean)attribute.value;
                }else if(attribute.name == 'resetWhenHidden'){
                    resetWhenHidden = (Boolean)attribute.value;
                }
            }

            if(visible != null && resetWhenHidden != null && !visible && resetWhenHidden){
                for(String field: componentConfig.fields){
                    try{
                        provisioningCase.put(field, null);
                        updateCase = true;
                    }catch(Exception ex){
                        System.debug(System.LoggingLevel.ERROR, 'Error reseting field on provisioning case.  Field: ' + field + '.  Exception: ' + ex.getMessage());
                        System.debug(System.LoggingLevel.ERROR, ex.getStackTraceString());
                    }
                }
            }
        }
        
        if(updateCase){
            UPDATE provisioningCase;
        }
    }
    
    protected abstract String processPageInformation();

    protected virtual List<PF_NHW_LightningComponentConfiguration> getComponentsConfig(){
        return new List<PF_NHW_LightningComponentConfiguration>();
    }    
    
    protected virtual void additionalProcessing(){
    }
    
    //This method defines the fields to be cleaned up if this page is skipped based on user selection.
    public virtual void resetFieldsOnPageSkip(Case ProvisioningCase){ 

    }
    protected virtual case  getProvisioningCase(){
        return ProvisioningCase;
    }

    protected virtual Map<String, Object> getPageConfig(){
        return new Map<String,Object>();
    }
    
    public abstract List<ReviewItem> getReviewList(Case provisioningCase, PF_NHW_Process process);
    
    private Case getFormerCase(Case provisioningCase){
        if(provisioningCase != null && !String.isBlank(provisioningCase.Id)){
            return PF_NHW_ProvisioningCaseStore.getProvisioningCaseById(provisioningCase.Id);
        }
        return null;
    }
    
    //W-15302981 - Putting Provision case status to on hold if contact is Deactive/inactive - Ajay Kushwah
    public static void checkIsContactDeactive(Case provisioningCase){
        if(provisioningCase.Status != 'On Hold'){
            Map<String, Contact> inactiveContMap = new Map<String, Contact>();
            for(Contact c : [Select id, Status__c, EmployeeNumber__c from Contact where EmployeeNumber__c =: provisioningCase.NH_Employee_Id__c and recordTypeID = :NHW_Util.getEmployeeContactRecordTypeId()  order by  LastModifiedDate DESC limit 1]){
                inactiveContMap.put(c.EmployeeNumber__c, c);
            }
            
            if(inactiveContMap.size() > 0 && inactiveContMap.get(provisioningCase.NH_Employee_Id__c).Status__c == 'Deactive'){
                provisioningCase.Status_before_OnHold__c = provisioningCase.Status;
                provisioningCase.Status = 'On Hold';
                update provisioningCase;
            } 
        }
    }

    public class ReviewItem{
        
        @AuraEnabled
        public String label;
        
        @AuraEnabled
        public String value;
        
        @AuraEnabled
        public string configComponentName{get; set;}

        @AuraEnabled
        public Boolean isEditable{get; set;}
        
        public ReviewItem(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
}