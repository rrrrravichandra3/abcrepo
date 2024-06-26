public with sharing class PF_NHW_BasicInformationPageService extends PF_NHW_PageService{

    private PF_NHW_Process process;
    private TF2_Business_Site__c bs;
    
    protected override List<PF_NHW_LightningComponentConfiguration> getComponentsConfig(){
        return PF_NHW_LightningComponentsService.getComponentsConfigForCaseAndPage(provisioningCase, PF_NHW_Page.BASIC_INFORMATION);
    }
    
    public override String processPageInformation(){

        bs = getBusinessSite(provisioningCase);
        process = PF_NHW_Process.getProcessByName(provisioningCase.NHW_Employee_Type__c);
        
        provisioningCase.Same_as_Office_Location__c = !getIsRemote();
        provisioningCase.RecordTypeId = NHW_Util.getnhwCaseRecordTypeId();
        provisioningCase.NHW_Send_Reminder__c = false;
        provisioningCase.NHW_Page_Number__c = 1;

        //Remove these couple of lines once business unit and cost center text fields are deprecated.
        provisioningCase.Business_Unit_NHW__c = NHW_Util.getBusinessUnitIdToName(provisioningCase.NHW_Business_Unit__c);
        provisioningCase.Cost_Center_NHW__c = [Select Id, Name from TF2_Department__c where Id =: provisioningCase.NHW_Cost_Center__c].Name;
        provisioningCase.origin = 'NHW';

        //For contractor and Reloc populate the office address fields based on office business site.
        if(process != PF_NHW_Process.FTE){
            provisioningCase.Office_Address__c = bs.Street_Address__c != null ?  bs.Street_Address__c : 'N/A';
            provisioningCase.Office_City__c = bs.City__c != null ? bs.City__c : 'N/A';
            provisioningCase.Office_State_Province__c = bs.State_Province__c != null ? bs.State_Province__c : 'N/A';
            provisioningCase.Office_Zip_Postal_Code__c = bs.Postal_Code__c != null ?  bs.Postal_Code__c : 'N/A';
            provisioningCase.Office_Country__c =  bs.Country__c != null ?  bs.Country__c : 'N/A';
        }
        if(process == PF_NHW_Process.RELOCATION){
            provisioningCase.Contractor_Hire_Reason__c = 'Is Relocation';
        }
        
        if(provisioningCase.Id == null){
            provisioningCase.Subject = 'New Hire Provisioning Request for ' + 
                provisioningCase.First_Name__c + ' ' + provisioningCase.Last_Name__c;
        }

        
        return null;
    }
    
    protected override void additionalProcessing(){
           system.debug('this.additionalInformation'+this.additionalInformation);
           if(this.additionalInformation != null && this.additionalInformation.containsKey('CLONECASEID')){
               String CloneCaseId = (String)this.additionalInformation.get('CLONECASEID');
               //get existing NHW Software Access Provisioning recordds from current case. They will be replaced by cloned case's software access records
               List<NHW_Software_Access_Provisioning__c> existingCaseSoftwareProvisionings = [Select Provisioning_Case__c,Configuration__c,Provisioning_Id__c,Provisioning_name__c,Selected__c 
                                                                                              from NHW_Software_Access_Provisioning__c 
                                                                                              Where Provisioning_Case__c=:provisioningCase.Id];
               system.debug('existingCaseSoftwareProvisionings'+existingCaseSoftwareProvisionings);

               //Map them using provisioning Name as the key
               Map<String, NHW_Software_Access_Provisioning__c> existingCaseSoftwareProvisioningsMap = new Map<String,NHW_Software_Access_Provisioning__c>();
               for(NHW_Software_Access_Provisioning__c softProv : existingCaseSoftwareProvisionings){
                   existingCaseSoftwareProvisioningsMap.put(softProv.Provisioning_name__c, softProv);
               }
                //get NHW Software Access Provisioning records from past case and copy their stats (exclude configuration field) to currentCase provisionings
                List<NHW_Software_Access_Provisioning__c> pastCaseSoftwareProvisionings = [Select Provisioning_Case__c,Configuration__c,Provisioning_Id__c,Provisioning_name__c,Selected__c 
                                                                                           from NHW_Software_Access_Provisioning__c 
                                                                                           Where Provisioning_Case__c=:CloneCaseId ];
                for(NHW_Software_Access_Provisioning__c pastCaseSoftProv : pastCaseSoftwareProvisionings){
                    if(!existingCaseSoftwareProvisioningsMap.containsKey(pastCaseSoftProv.Provisioning_name__c)){
                        existingCaseSoftwareProvisioningsMap.put(pastCaseSoftProv.Provisioning_name__c,new NHW_Software_Access_Provisioning__c(Provisioning_Case__c = provisioningCase.Id));
                    }
                    NHW_Software_Access_Provisioning__c currentCaseSoftProv = existingCaseSoftwareProvisioningsMap.get(pastCaseSoftProv.Provisioning_name__c);
                    currentCaseSoftProv.Provisioning_Id__c = pastCaseSoftProv.Provisioning_Id__c;
                    currentCaseSoftProv.Provisioning_name__c = pastCaseSoftProv.Provisioning_name__c;
                    currentCaseSoftProv.Selected__c = pastCaseSoftProv.Selected__c;

                }    
                
                try {
                    if(NHW_Software_Access_Provisioning__c.sObjectType.getDescribe().isCreateable() && NHW_Software_Access_Provisioning__c.sObjectType.getDescribe().isUpdateable()){
                        Database.upsert(existingCaseSoftwareProvisioningsMap.values(), false);
                    }
                }  catch (DmlException ex) { 
                    system.debug('The following exception has occurred: ' + 
                                 ex.getDmlStatusCode(0) + ex.getMessage());
                }
           } 
            
           //Check if any pages are skipped due to change in user selection on page 1 - Eg:Contractor from std to Badge Only.
           PF_NHW_Process process = PF_NHW_Process.getProcessByName(provisioningCase.NHW_Employee_Type__c); 
           Integer startPageNum = 2;//Page 2 is next in sequence.
           Integer targetPageNum= (Integer)provisioningCase.NHW_Page_Number__c; // Current Page number.
           for(integer i=startPageNum;i<targetPageNum;i++){
               //If user navigation is not sequential (In this case - not page 2) - then reset the skipped pages
               if(i-1<process.steps.size()){//To avoid out of bounds in case process.steps changes in future
                    //Cleanup any past user selections on the page as it got skipped
                    PF_NHW_Page page = process.steps[i-1];
                    PF_NHW_PageService pageService = page.createService();
                    pageService.resetFieldsOnPageSkip(provisioningCase); 
               }

           }

    }
    protected override Case  getProvisioningCase(){
        if(provisioningCase != null && provisioningCase.RecordTypeId == NHW_Util.getnhwPreBoardCaseRecordTypeId()){
            Id preboardingCaseId = provisioningCase.Id; 
            Case PreboardingCase = [select id,NHW_Send_Reminder__c 
                                    from Case where id =:preboardingCaseId];
			
            //Moved CreateProvisioning Logic to Store class as it can be reused outside this page service class.
            provisioningCase = PF_NHW_ProvisioningCaseStore.generateProvisioningCaseFromPreboardingCase(preboardingCaseId);
            INSERT provisioningCase;

            //Reset NHW_Send_Reminder__c flag on preboarding case to 
            //Indicate to Marketing cloud that provisioning has started and stop Manager reminder emails.
            PreboardingCase.NHW_Send_Reminder__c = false;
            update PreboardingCase; 

        }
        return provisioningCase;
    }
    //Moved createProvisioningCase from Preboarding Logic to Store class as it can be reused outside this page service class.
    /*       
    private void createProvisioningCase(Id preboardingCaseId){
        
        Id modelId = NHWRecruitmentModelObjectsStore.getModelIdByCaseId(preboardingCaseId);
        
        if(modelId != null){
            
            NHWRecruitmentModel modelobject = NHWRecruitmentModelObjectsStore.getNHWRecruitmentModelObjectById(modelId);
            
            if(modelobject.ModelType == NHWModelType.PLACEMENT){
                provisioningCase.NHW_Placement__c = modelobject.ModelId;
            }else{
                provisioningCase.NHW_Job_Application__c = modelobject.ModelId;
            }
            
            provisioningCase.Id = null;
            provisioningCase.Offer_Type__c = modelobject.OfferType;
            provisioningCase.Resource_Type__c = modelobject.ResourceType;
            provisioningCase.NHW_Employee__c = modelobject.EmployeeContactId;
            provisioningCase.NH_Employee_Id__c = modelobject.EmployeeNumber;
            provisioningCase.First_Name__c = modelobject.FirstName;
            provisioningCase.Last_Name__c = modelobject.LastName;
            provisioningCase.Company__c = modelobject.CompanyId;
            provisioningCase.Company_Agency_Name__c = modelobject.CompanyAgencyName;
            provisioningCase.Primary_Coverage_Country__c = modelobject.PrimaryCoverageCountry;
            provisioningCase.Job_Status__c = modelobject.JobStatus;
            provisioningCase.Business_Title__c = modelobject.BusinessTitle;
            provisioningCase.Business_Unit_NHW__c = modelobject.BusinessUnitName;
            provisioningCase.Cost_Center_NHW__c =  modelobject.CostCenterName;
            provisioningCase.NHW_Business_Unit__c = modelobject.BusinessUnitId;
            provisioningCase.NHW_Cost_Center__c =  modelobject.CostCenterId;
            provisioningCase.NHW_Start_Date__c = modelobject.StartDate;
            provisioningCase.NH_Personal_Email__c = String.valueOf(modelobject.PersonalEmail);  
            provisioningCase.description='';
            provisioningCase.NH_Business_Site__c = modelobject.BusinessSiteId;
            provisioningCase.Office_Address__c =modelobject.OfficeAddress;
            provisioningCase.Office_City__c =modelobject.OfficeCity;
            provisioningCase.Office_State_Province__c = modelobject.OfficeStateProvince;
            provisioningCase.Office_Zip_Postal_Code__c =modelobject.OfficeZipPostalCode;
            provisioningCase.Office_Country__c = modelobject.OfficeCountry;
            provisioningCase.Manager_Name__c = modelobject.ManagerContactId;
            provisioningCase.Manager_s_Email__c = modelobject.Manager_s_Email;
            provisioningCase.Email_Address__c = modelobject.supportforceEmail;
            provisioningCase.End_Date__c = modelobject.EndDate;
            provisioningCase.NHW_Employee_Type__c = 'regular employee';
            provisioningCase.RecordTypeId = NHW_Util.getnhwCaseRecordTypeId();
            provisioningCase.NHW_Send_Reminder__c = false;
            provisioningCase.NHW_Page_Number__c = 1;
            provisioningCase.origin = 'NHW';
            provisioningCase.status = 'New';
            provisioningCase.Subject = 'New Hire Provisioning Request for ' + provisioningCase.First_Name__c + ' ' + provisioningCase.Last_Name__c;
        }
    }*/
    
    private TF2_Business_Site__c getBusinessSite(Case provisioningCase){

        if(!String.isBlank(provisioningCase.NH_Business_Site__c)){
            
            return [Select Id, Street_Address__c, City__c,
                            State_Province__c, Postal_Code__c,
                            Country__c, Name
                            From TF2_Business_Site__c 
                    WHERE Id = :provisioningCase.NH_Business_Site__c];
        }
        
        return null;
    }

    private Boolean getIsRemote(){
        if(bs != null){
            return bs.Name.contains('Remote');
        }
        return null;
    }
    
    public override List<ReviewItem> getReviewList(Case provisioningCase, PF_NHW_Process process){
        
        this.provisioningCase = provisioningCase;
        
        List<ReviewItem> reviewList = new List<ReviewItem>();

        reviewList.add(new ReviewItem('Name', provisioningCase.First_Name__c + ' ' + provisioningCase.Last_Name__c));
        reviewList.add(new ReviewItem('Email', provisioningCase.Email_Address__c));
        reviewList.add(new ReviewItem('Which Department Will This Hire Be In?', provisioningCase.NHW_Organization__c));
        reviewList.add(new ReviewItem('Role', provisioningCase.NHW_Role__c));
        reviewList.add(new ReviewItem('Where Will They Work?', provisioningCase.NH_Business_Site__r.Name));
        reviewList.add(new ReviewItem('Start Date', String.valueOf(provisioningCase.NHW_Start_Date__c)));

        if(!String.isBlank(String.valueOf(provisioningCase.End_Date__c))){
            reviewList.add(new ReviewItem('End Date', String.valueOf(provisioningCase.End_Date__c)));
        }
        reviewList.add(new ReviewItem('Title', provisioningCase.Business_Title__c));
        reviewList.add(new ReviewItem('What Type Of Work Is It?', provisioningCase.Resource_Type__c));
        
        reviewList.add(new ReviewItem('Cost Center', provisioningCase.NHW_Cost_Center__r.Name));
        reviewList.add(new ReviewItem('Business Unit', provisioningCase.NHW_Business_Unit__r.Name));
        reviewList.add(new ReviewItem('Manager Name', provisioningCase.Manager_Name__r.Name));
        reviewList.add(new ReviewItem('SFDC Company', provisioningCase.Company__r.Name));
        reviewList.add(new ReviewItem('Primary Coverage Country', provisioningCase.Primary_Coverage_Country__c));
        reviewList.add(new ReviewItem('Division', provisioningCase.Division__c));
        
        if(!String.isBlank(provisioningCase.Job_Status__c)){
            reviewList.add(new ReviewItem('Job Status', provisioningCase.Job_Status__c));
        }

        if(!String.isBlank(provisioningCase.Contractor_Hire_Reason__c)){
            reviewList.add(new ReviewItem('Contractor Hire Reason', provisioningCase.Contractor_Hire_Reason__c));
        }
        
        if(!String.isBlank(provisioningCase.NH_ET_Team__c)){
            reviewList.add(new ReviewItem('Team', provisioningCase.NH_ET_Team__c));
        }
        
        if(!String.isBlank(provisioningCase.NH_ET_Sub_Region__c)){
            reviewList.add(new ReviewItem('Sub-Region', provisioningCase.NH_ET_Sub_Region__c));
        }
        
        if(!String.isBlank(provisioningCase.NH_Legacy_ET_Dept_Code__c)){
            reviewList.add(new ReviewItem('ET Department Code', provisioningCase.NH_Legacy_ET_Dept_Code__c));
        }

        return reviewList;
    }
}