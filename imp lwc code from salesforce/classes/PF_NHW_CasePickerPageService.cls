@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
public without sharing class PF_NHW_CasePickerPageService extends PF_NHW_PageService {

    protected override Map<String, Object> getPageConfig(){
        NH_Settings__c settings = NH_Settings__c.getInstance();
        Onboarding_Setting__c onboardingSetting = Onboarding_Setting__c.getInstance();
        Map<String, Object> pageConfig = new Map<String, Object>();
        pageConfig.put('NH', getNewHires());
        pageConfig.put('numberToShow',settings.Max_Number_of_Cases__c != null?settings.Max_Number_of_Cases__c:4);
        pageConfig.put('numberToIncrease', settings.Number_To_Increase__c !=null?settings.Number_To_Increase__c:4);
        pageConfig.put('SSORisActive',onboardingSetting.SSOR_Feature_Flag__c);
        
        return pageConfig;
    }
    
    private List<CasePickerNewHire> getNewHires(){
        /* Commenting out for now.
        Integer maxNumberOfCases = 4;
        // If a positive value is provided in the custom setting, use it instead of the harcoded value of "4"
        if (NH_Settings__c.getInstance().Max_Number_of_Cases__c != null &&
            NH_Settings__c.getInstance().Max_Number_of_Cases__c >= 1 ) {
            maxNumberOfCases = Integer.valueOf(NH_Settings__c.getInstance().Max_Number_of_Cases__c);
        }
         */

        List<CasePickerNewHire> auraNewHires = new List<CasePickerNewHire>();
        Set<Id> userIds = PF_NHW_SecurityUtil.userIds;
        Set<String> userEmails = PF_NHW_SecurityUtil.userEmails;
        List<NHWRecruitmentModel> newHires = NHWRecruitmentModelObjectsStore.getAllNHWRecruitmentModelObjectsForMger(userIds);
        for(NHWRecruitmentModel newHire:newHires){

            if ((newHire.preboardingCases != null && !newHire.preboardingCases.isEmpty()) ||(newHire.provisioningCases != null && !newHire.provisioningCases.isEmpty())) {
                
                Boolean shouldDisplayHire = true;
                Case pc;
                Case proc;
                //The latter section of the code has an assumption that given multiple preboarding or provisioning cases for a new hire 
                //the first one in the list will be used (list[0]).However the initial checks on shouldDisplayHire look through all the cases to reject display
                //This is causing issues with rescind flow as there are multiple pre and prov cases possible - and older cases are not relevant for shouldDisplayHire decision.
                //Hence we are bubbling the assumption upto this bool check section as follows
                //Given the cases are ordered by created DESC - The most recent case will be the first in the respective pre and prov lists.
                //ShouldDisplay is driven purely based on that first item instead of driving thru rest of the cases.
                //The decision to display hire is driven purely based on the most recently created case - which aligns with how the business process works.
                if(newHire.preboardingCases != null && !newHire.preboardingCases.isEmpty()) {
                     pc = newHire.preboardingCases[0];

                        //Incase duplicate NHWRecruitmentModel exist, we should skip over second iteration
                    //Duplicate check is not relevant as we are anyways taking only one item.
                
                    if( pc.RecordTypeId == NHW_Util.getnhwPreBoardCaseRecordTypeId() && ( !pc.IsClosed || ( pc.IsClosed && pc.Status.containsIgnoreCase('Cancel') ) ) ){
                        shouldDisplayHire = false;
                    }
                    //check on manager criteria modified to make exception for SVP cases
                    if((!((NHW_Util.isCurrentUserExecutive()) && (pc.NHW_Job_Application__r.Job__r.Is_SVP_Level_Job__c==True)))&& (!userEmails.contains(pc.Manager_s_Email__c)) ){
                        shouldDisplayHire = false;
                    }

                }
              if(newHire.provisioningCases != null && newHire.provisioningCases.size()>0){
                 proc =  newHire.provisioningCases[0];

                    if (((proc.IsClosed  || (proc.Status.containsIgnoreCase('Cancel')|| proc.Status.contains('Sent to Supportforce') || proc.Status.contains('Accounts in Progress - Supportforce'))) && 
                        proc.RecordTypeId == NHW_Util.getnhwCaseRecordTypeId() ) && (pc.createddate < proc.createddate)){  //if provisioning case is created after preboarding - It is most recent and then go ahead with suppression decision 

                                 shouldDisplayHire = false;
                            
                    }

                    //check on manager criteria modified to make exception for SVP cases
                    if((!((NHW_Util.isCurrentUserExecutive()) && (proc.NHW_Job_Application__r.Job__r.Is_SVP_Level_Job__c==True)))&& (!userEmails.contains(proc.Manager_s_Email__c)) ){
                        shouldDisplayHire = false;
                    }

               } 
              
                 
                if (shouldDisplayHire) {
                    
                    Id caseId = null;
                    PF_NHW_ProcessHandler.CaseProcessInformation processInformation = null;
                    
                    String title, department;
                    Date caseStartDate;
                    
                    if(newHire.provisioningCases != null && !newHire.provisioningCases.isEmpty()
                        && (!newHire.provisioningCases[0].Status.containsIgnoreCase('Cancel')) //skip the rescind prov case
                    ){
                        
                        caseId = newHire.provisioningCases[0].Id;
                        
                        try{
                            processInformation = PF_NHW_ProcessHandler.getProcessInformation(newHire.provisioningCases[0]);
                        }catch(AuraHandledException ex){
                            System.debug(System.LoggingLevel.ERROR, ex.getMessage());
                            continue;
                        }
                        
                        title = newHire.provisioningCases[0].Business_Title__c;
                        department = newHire.provisioningCases[0].NHW_Organization__c;
                        caseStartDate = newHire.provisioningCases[0].NHW_Start_Date__c;
                        
                    }else if(newHire.preboardingCases != null && !newHire.preboardingCases.isEmpty()){

                        caseId = newHire.preboardingCases[0].Id;
                        
                        try{
                            processInformation = PF_NHW_ProcessHandler.getProcessInformation(newHire.preboardingCases[0]);
                        }catch(AuraHandledException ex){
                            System.debug(System.LoggingLevel.ERROR, ex.getMessage());
                            continue;
                        }
                        
                        title = newHire.preboardingCases[0].Business_Title__c;
                        department = newHire.preboardingCases[0].NHW_Organization__c;
                        caseStartDate = newHire.preboardingCases[0].NHW_Start_Date__c;
                    }

                    Date dateDisplayed = caseStartDate == null? newHire.StartDate : caseStartDate;

                    auraNewHires.add(new CasePickerNewHire(caseId, newHire.EmployeeName, processInformation.currentStep > 0 ? 'in progress' : 'new',
                                                           ((double)processInformation.currentStep) / ((double)processInformation.typeOfProcess.steps.size()),
                                                          DateTime.newInstance(dateDisplayed.year(), dateDisplayed.month(), dateDisplayed.day()).format('MMM dd, yyyy'), title, department,
                                                           PF_NHW_Process.FTE.name,
                                                          dateDisplayed ));
                }
            }
        }

        //code for post-placement manager changes for Contractor and relocation cases was handled in PF_NHW_ProvisioningCaseStore.getContractorAndRelocationProvisioningCases by checking for Manager email on case        
        for(Case c: PF_NHW_ProvisioningCaseStore.getContractorAndRelocationProvisioningCases(userIds, userEmails)){
            PF_NHW_ProcessHandler.CaseProcessInformation processInformation = null;
            processInformation = PF_NHW_ProcessHandler.getProcessInformation(c);
            // not needed -> moved in to SOQL conditions
            auraNewHires.add(new CasePickerNewHire(c.Id, c.First_Name__c + ' ' + c.Last_Name__c, processInformation.currentStep > 0 ? 'in progress' : 'new',
                                                   ((double)processInformation.currentStep) / ((double)processInformation.typeOfProcess.steps.size()),
                                                   DateTime.newInstance(c.NHW_Start_Date__c.year(), c.NHW_Start_Date__c.month(), c.NHW_Start_Date__c.day()).format('MMM dd, yyyy'), c.Business_Title__c, c.NHW_Organization__c,
                                                   c.NHW_Employee_Type__c.toLowerCase(),
                                                  c.NHW_Start_Date__c));
        }
        ////// end of code for post placement cases

       
        auraNewHires.sort();
        /* Commenting out for now...
        while(auraNewHires.size() > maxNumberOfCases){
            auraNewHires.remove(auraNewHires.size() - 1);
        }
         */
        
        return auraNewHires;
    }
    
    public class CasePickerNewHire implements Comparable{
        
        @AuraEnabled
        public String name{get; private set;}
        
        @AuraEnabled
        public String status{get; private set;}
        
        @AuraEnabled        
        public Double progress{get; private set;}
        
        @AuraEnabled
        public String startDate{get; private set;}
        
        @AuraEnabled
        public String caseId{get; private set;}

        @AuraEnabled        
        public String title{get; private set;}
        
        @AuraEnabled        
        public String department{get; private set;}
        
        @AuraEnabled        
        public String flowType{get; private set;}
        
        public Date startDateNoFormat{get; private set;}
        
        public CasePickerNewHire(String caseId, String name, String status,
                                 Double progress, String startDate,
                                 String title, String department, String flowType,
                                 Date startDateNoFormat){
            this.name = name;
            this.status = status;
            this.progress = progress;
            this.startDate = startDate;
            this.caseId = caseId;
            this.title = title;
            this.department = department;
            this.flowType = flowType;
            this.startDateNoFormat = startDateNoFormat;
        }
        
        public Integer compareTo(Object o){
            
            CasePickerNewHire newHire = (CasePickerNewHire)o;
            
            if(this.startDateNoFormat > newHire.startDateNoFormat){
                return 1;
            }else if(this.startDateNoFormat < newHire.startDateNoFormat){
                return -1;
            }

            return 0;
        }
    }
    
    public override String processPageInformation(){
        return null;
    }
    
    public override List<ReviewItem> getReviewList(Case provisioningCase, PF_NHW_Process process){
        return null;
    }
}