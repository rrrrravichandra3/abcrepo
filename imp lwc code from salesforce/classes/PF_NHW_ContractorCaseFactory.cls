public class PF_NHW_ContractorCaseFactory {

    public static NHWRecruitmentModel createNewEmptyContractorCase(){
        
        NHWRecruitmentModel model = new NHWRecruitmentModel(NHWModelType.JOBAPPLICATION);

        Case provisioningCase = new Case(NHW_Employee_Type__c = 'Contractor',
                                        NH_Is_Exact_Target__c = false);

        model.provisioningCases = new List<Case>{provisioningCase};
        
        return model;
    }
    
}