public with sharing class PF_NHW_ProcessHandler {
    
    public static CaseProcessInformation getProcessInformation(Case nhwCase){
        
        PF_NHW_SecurityUtil.checkUserHasAccessToCase(nhwCase);
        
        PF_NHW_Process process = null;
        Integer currentStep = 0;

        if(nhwCase.RecordTypeId == NHW_Util.getnhwPreBoardCaseRecordTypeId()){ //It's a preboarding case.  It means it's a FTE whose NHW process hasn't started yet.
            process = PF_NHW_Process.FTE;
        }else{ //It may be either an FTE whose NHW process has started, a contractor or a relocation case.
            process = PF_NHW_Process.getProcessByName(nhwCase.NHW_Employee_Type__c);
        }

        currentStep = (Integer)nhwCase.NHW_Page_Number__c;

        return new CaseProcessInformation(currentStep, process);
    }
    
    public static CaseProcessInformation moveCaseBackward(Case nhwCase){

        PF_NHW_SecurityUtil.checkUserHasAccessToCase(nhwCase);
        
        PF_NHW_Process process = null;
        process = PF_NHW_Process.getProcessByName(nhwCase.NHW_Employee_Type__c);
        
        Integer previousStep = PF_NHW_Process.getPreviousStep(nhwCase);
        
        if(previousStep == 0){
            throw new PF_NHW_PreviousStepNotAllowedException();
        }
        
        nhwCase.NHW_Page_Number__c = previousStep;
        
        UPDATE nhwCase;

        return new CaseProcessInformation(previousStep, process);
    }

    public static CaseProcessInformation getProcessInformation(String flowType){
        PF_NHW_Process process = null;
        process = PF_NHW_Process.getProcessByName(flowType);
        return new CaseProcessInformation(0, process);
    }
    
    public class CaseProcessInformation{
        
        @AuraEnabled
        public Integer currentStep{get; private set;}
        @AuraEnabled
        public PF_NHW_Process typeOfProcess{get; private set;}
        
        public CaseProcessInformation(Integer currentStep, PF_NHW_Process typeOfProcess){
            this.currentStep = currentStep;
            this.typeOfProcess = typeOfProcess;
        }
    }
}