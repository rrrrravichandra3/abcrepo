public with sharing class PF_NHW_Process {
    
    public static PF_NHW_Process FTE{get; private set;}
    public static PF_NHW_Process CONTRACTOR {get; private set;}
    public static PF_NHW_Process RELOCATION {get; private set;}
    public static PF_NHW_Process EMPLOYEEVIEWANDUPDATE {get; private set;}

    static{
        FTE = new PF_NHW_Process('regular employee', new List<PF_NHW_Page>{
            PF_NHW_Page.BASIC_INFORMATION,
            PF_NHW_Page.HARDWARE,
            PF_NHW_Page.SOFTWARE,
            PF_NHW_Page.TRAININGS,
            PF_NHW_Page.REVIEW}, 'PF_NHW_FTESubmitPrompt');
        CONTRACTOR = new PF_NHW_Process('contractor', new List<PF_NHW_Page>{
            PF_NHW_Page.BASIC_INFORMATION,
            PF_NHW_Page.HARDWARE,
            PF_NHW_Page.SOFTWARE,
            PF_NHW_Page.ADDTNLINFO,
            PF_NHW_Page.REVIEW}, 'PF_NHW_ContractorSubmitPrompt');
        RELOCATION = new PF_NHW_Process('relocation', new List<PF_NHW_Page>{
            PF_NHW_Page.BASIC_INFORMATION,
            PF_NHW_Page.HARDWARE,
            PF_NHW_Page.SOFTWARE,
            PF_NHW_Page.ADDTNLINFO,                
            PF_NHW_Page.REVIEW}, null);
        
        EMPLOYEEVIEWANDUPDATE = new PF_NHW_Process('employeeviewandupdate', new List<PF_NHW_Page>{
           PF_NHW_Page.TRAININGS_EMPLOYEEVIEW,PF_NHW_Page.REVIEW}, null);
    }

    @AuraEnabled
    public List<PF_NHW_Page> steps{get; private set;}
    
    @AuraEnabled
    public String name{get; private set;}
    
    @AuraEnabled
    public String submitPromptComponentName{get; private set;}
        
    private PF_NHW_Process(String name, List<PF_NHW_Page> steps, String submitPromptComponentName){
        this.name = name;
        this.steps = steps;
        this.submitPromptComponentName = submitPromptComponentName;
    }

    public static PF_NHW_Process getProcessByName(String processName){
        if(!String.isBlank(processName)){
            if(processName.equalsIgnoreCase('regular employee')){
                return FTE;
            }
            if(processName.equalsIgnoreCase('contractor')){
                return CONTRACTOR;
            }
            if(processName.equalsIgnoreCase('relocation')){
                return RELOCATION;
            }
            if(processName.equalsIgnoreCase('employeeviewandupdate')){
                return EMPLOYEEVIEWANDUPDATE;
            }
        }
        return null;
    } 
    
    public static Integer getNextStep(Case provisioningCase){
        
        PF_NHW_Process process = getProcessByName(provisioningCase.NHW_Employee_Type__c);
        
        if((process == CONTRACTOR && provisioningCase.NHW_Page_Number__c == 1)&&(provisioningCase.Contractor_Hire_Reason__c == 'Badge-Only' ||
                                 provisioningCase.Contractor_Hire_Reason__c == 'Temp Receptionist')){

                return 4;
        }

        return (Integer)provisioningCase.NHW_Page_Number__c + 1;
    }
    
    public static Integer getPreviousStep(Case provisioningCase){
        
        PF_NHW_Process process = getProcessByName(provisioningCase.NHW_Employee_Type__c);
        
        if((process == CONTRACTOR && provisioningCase.NHW_Page_Number__c == 4)&&(provisioningCase.Contractor_Hire_Reason__c == 'Badge-Only' ||
                                 provisioningCase.Contractor_Hire_Reason__c == 'Temp Receptionist')){
                return 1;
            
        }

        return (Integer)provisioningCase.NHW_Page_Number__c - 1;
    }

    public class ProcessStep{
        
        @AuraEnabled
        public String name{get; private set;}
        @AuraEnabled
        public String component{get; private set;}
        
        public ProcessStep(String name, String component){
            this.name = name;
            this.component = component;
        }
    }
}