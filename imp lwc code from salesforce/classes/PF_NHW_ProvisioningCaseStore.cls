public with sharing class PF_NHW_ProvisioningCaseStore {
    
    public static Case getProvisioningCaseById(Id caseId){
        
        return [Select Id, CaseNumber,ParentId, RecordTypeId,Status,
                NH_SST_User__c,NHW_Page_Number__c, Offer_Type__c,NH_Employee_Id__c,
                NHW_Organization__c, Resource_Type__c, NHW_Role__c,Business_Objects__c, 
                NHW_Employee__c, First_Name__c, Last_Name__c, 
                Email_Address__c, Division__c, Company__c,
                Company__r.Name, Cost_Center_NHW__c,
                Agreement_Received__c, Primary_Coverage_Country__c, 
                Job_Status__c, NHW_Cost_Center__c, NHW_Cost_Center__r.Name,
                NHW_Start_Date__c, Manager_Name__c, Manager_Name__r.Name,
                Onboarding_Buddy_Name__c, Onboarding_Buddy_Email__c, 
                Office_Address__c, Office_City__c, 
                Office_State_Province__c, Office_Zip_Postal_Code__c, 
                Office_Country__c, 
                Floor_Location_Cube_Location__c, 
                NH_ET_Team__c, NH_Shipping_Business_Site__c, NH_Shipping_Business_Site__r.Name,
                NH_Shipping_Local_Contact_Info__c,
                Mobile_Phone_Required__c, Desk_and_VoiceMail__c,
                Existing_Equipment__c, 
                Computer_Type__c, NHW_Access_Code__c,
                Same_as_Office_Location__c, Laptop_Type__c,
                End_Date__c, Contractor_Hire_Reason__c,
                NHW_Training__c, NHW_Employee_Type__c, 
                Shipping_Address__c, Shipping_City__c, NH_Personal_Email__c, 
                Shipping_Zip_Postal__c, Shipping_State__c, 
                Shipping_Country__c, Description, 
                Location_Type__c, NH_Business_Site__c,
                Business_Unit_NHW__c, NHW_Business_Unit__c, NHW_Business_Unit__r.Name,
                ES_DJC_Business_Justification__c, Business_Title__c,
                Manager_s_Email__c, NH_Is_Exact_Target__c,
                NH_ET_Sub_Region__c,NH_Legacy_ET_Dept_Code__c,
                NH_Open_Air_Role__c,
                NHW_Job_Application__r.Job__r.Job_Code__c,
                NHW_Job_Application__r.Job__r.Employment_Type__c,
                NHW_Job_Application__r.Job__r.Is_SVP_Level_Job__c,
                NH_Training_Email_Merge__c,NHW_Trail_Guide__c,NH_FTE_Hire_Reason__c,
                CreatedById, LastModifiedById,
                NHW_Job_Application__r.Job__r.Hiring_Manager__c,
                NH_Business_Site__r.Name, Created_with_NHW_2_0__c,
                Is_Accessibility_required__c
                From Case Where Id = :caseId]; 
    }
    
    public static case generateProvisioningCaseFromPreboardingCase(Id PreboardingCaseId){
        
        Id modelId = NHWRecruitmentModelObjectsStore.getModelIdByCaseId(preboardingCaseId);
        Case provisioningCase= PF_NHW_ProvisioningCaseStore.getProvisioningCaseById(preboardingCaseId);
        if(modelId != null){
            
            NHWRecruitmentModel modelobject = NHWRecruitmentModelObjectsStore.getNHWRecruitmentModelObjectById(modelId);
            
            provisioningCase.NHW_Job_Application__c = modelobject.ModelId;
            
            provisioningCase.Id = null;
            provisioningCase.Offer_Type__c = modelobject.OfferType;
            provisioningCase.Resource_Type__c = modelobject.ResourceType;
            provisioningCase.NHW_Employee__c = modelobject.EmployeeContactId;
            provisioningCase.First_Name__c = modelobject.FirstName;
            provisioningCase.Last_Name__c = modelobject.LastName;
            provisioningCase.Company__c = modelobject.CompanyId;
            provisioningCase.Primary_Coverage_Country__c = modelobject.PrimaryCoverageCountry;
            provisioningCase.Job_Status__c = modelobject.JobStatus;
            provisioningCase.Business_Title__c = modelobject.BusinessTitle;
            provisioningCase.NH_Personal_Email__c = String.valueOf(modelobject.PersonalEmail);  
            provisioningCase.description='';
            provisioningCase.Email_Address__c = modelobject.supportforceEmail;
            provisioningCase.End_Date__c = modelobject.EndDate;
            provisioningCase.NHW_Employee_Type__c = 'regular employee';
            provisioningCase.RecordTypeId = NHW_Util.getnhwCaseRecordTypeId();
            provisioningCase.NHW_Send_Reminder__c = false;
            provisioningCase.NH_FTE_Hire_Reason__c = modelobject.ReqCreationReason;
            provisioningCase.NHW_Page_Number__c = 1;
            provisioningCase.origin = 'NHW';
            provisioningCase.status = 'New'; 
            provisioningCase.Subject = 'New Hire Provisioning Request for ' + provisioningCase.First_Name__c + ' ' + provisioningCase.Last_Name__c;
        } 
        return provisioningCase;
        
    }
    
    public static List<Case> getContractorAndRelocationProvisioningCases(Set<Id> userIds, Set<String> userEmails){
        return [Select Id, CaseNumber,ParentId, RecordTypeId,Status,
                NH_SST_User__c,NHW_Page_Number__c, Offer_Type__c,NH_Employee_Id__c,
                NHW_Organization__c, Resource_Type__c, NHW_Role__c,Business_Objects__c, 
                NHW_Employee__c, First_Name__c, Last_Name__c, 
                Email_Address__c, Division__c, Company__c,
                Company__r.Name, Cost_Center_NHW__c,
                Agreement_Received__c, Primary_Coverage_Country__c, 
                Job_Status__c, NHW_Cost_Center__c, NHW_Cost_Center__r.Name,
                NHW_Start_Date__c, Manager_Name__c, Manager_Name__r.Name,
                Onboarding_Buddy_Name__c, Onboarding_Buddy_Email__c, 
                Office_Address__c, Office_City__c, 
                Office_State_Province__c, Office_Zip_Postal_Code__c, 
                Office_Country__c,  
                Floor_Location_Cube_Location__c, 
                NH_ET_Team__c, NH_Shipping_Business_Site__c, NH_Shipping_Business_Site__r.Name,
                NH_Shipping_Local_Contact_Info__c,
                Mobile_Phone_Required__c, Desk_and_VoiceMail__c,
                Existing_Equipment__c, 
                Computer_Type__c, NHW_Access_Code__c,
                Same_as_Office_Location__c, Laptop_Type__c,
                End_Date__c, Contractor_Hire_Reason__c,
                NHW_Training__c, NHW_Employee_Type__c, 
                Shipping_Address__c, Shipping_City__c, NH_Personal_Email__c, 
                Shipping_Zip_Postal__c, Shipping_State__c, 
                Shipping_Country__c, Description, 
                Location_Type__c, NH_Business_Site__c,
                Business_Unit_NHW__c, NHW_Business_Unit__c, NHW_Business_Unit__r.Name,
                ES_DJC_Business_Justification__c, Business_Title__c,
                Manager_s_Email__c, NH_Is_Exact_Target__c,
                NH_ET_Sub_Region__c,NH_Legacy_ET_Dept_Code__c,
                NH_Open_Air_Role__c,
                NHW_Job_Application__r.Job__r.Job_Code__c,
                NHW_Job_Application__r.Job__r.Employment_Type__c,
                NHW_Job_Application__r.Job__r.Is_SVP_Level_Job__c,
                CreatedById, LastModifiedById,
                NH_Business_Site__r.Name,
                NHW_Job_Application__r.Job__r.Hiring_Manager__c,
                Created_with_NHW_2_0__c
                From Case
                Where RecordTypeId =: NHW_Util.getnhwCaseRecordTypeId()
                AND IsClosed = false And Status NOT IN ('Sent to Supportforce','Accounts in Progress - Supportforce')
                AND (NHW_Employee_Type__c = :PF_NHW_Process.CONTRACTOR.name OR NHW_Employee_Type__c = :PF_NHW_Process.RELOCATION.name)
                AND (CreatedById IN :userIds
                     Or LastModifiedById IN :userIds
                     Or Manager_s_Email__c IN :userEmails)
                
               ];
    }
    
    public static List<Case> getPastProvisioningCases(Set<Id> userIds){
        Set<String> userEmails = getUserEmails(userIds);
        Date limitDate = Date.today().addMonths(-3);
        
        return [Select Id, CaseNumber,ParentId, RecordTypeId,
                NH_SST_User__c,NHW_Page_Number__c, Offer_Type__c,NH_Employee_Id__c,
                NHW_Organization__c, Resource_Type__c, NHW_Role__c,Business_Objects__c, 
                NHW_Employee__c, First_Name__c, Last_Name__c, 
                Email_Address__c, Division__c, Company__c,
                Company__r.Name, Cost_Center_NHW__c,
                Agreement_Received__c, Primary_Coverage_Country__c, 
                Job_Status__c, NHW_Cost_Center__c, NHW_Cost_Center__r.Name,
                NHW_Start_Date__c, Manager_Name__c, Manager_Name__r.Name,
                Onboarding_Buddy_Name__c, Onboarding_Buddy_Email__c, 
                Office_Address__c, Office_City__c, 
                Office_State_Province__c, Office_Zip_Postal_Code__c, 
                Office_Country__c,  
                Floor_Location_Cube_Location__c, 
                NH_ET_Team__c, NH_Shipping_Business_Site__c, NH_Shipping_Business_Site__r.Name,
                NH_Shipping_Local_Contact_Info__c,
                Mobile_Phone_Required__c, Desk_and_VoiceMail__c,
                Existing_Equipment__c, 
                Computer_Type__c, NHW_Access_Code__c,
                Same_as_Office_Location__c, Laptop_Type__c,
                End_Date__c, Contractor_Hire_Reason__c,
                NHW_Training__c, NHW_Employee_Type__c, 
                Shipping_Address__c, Shipping_City__c, NH_Personal_Email__c, 
                Shipping_Zip_Postal__c, Shipping_State__c, 
                Shipping_Country__c, Description, 
                Location_Type__c, NH_Business_Site__c,
                Business_Unit_NHW__c, NHW_Business_Unit__c, NHW_Business_Unit__r.Name,
                ES_DJC_Business_Justification__c, Business_Title__c,
                Manager_s_Email__c, NH_Is_Exact_Target__c,
                NH_ET_Sub_Region__c,NH_Legacy_ET_Dept_Code__c,
                NH_Open_Air_Role__c,
                NHW_Job_Application__r.Job__r.Job_Code__c,
                NHW_Job_Application__r.Job__r.Employment_Type__c,
                NHW_Job_Application__r.Job__r.Is_SVP_Level_Job__c,
                CreatedById, LastModifiedById,
                NH_Business_Site__r.Name,
                NHW_Job_Application__r.Job__r.Hiring_Manager__c,
                Created_with_NHW_2_0__c
                From Case
                Where RecordTypeId =: NHW_Util.getnhwCaseRecordTypeId()
                AND (IsClosed = true OR Status IN ('Sent to Supportforce','Accounts in Progress - Supportforce') )
                AND(
                    (   //Contractor and Relocation
                        (NHW_Employee_Type__c = :PF_NHW_Process.CONTRACTOR.name OR NHW_Employee_Type__c = :PF_NHW_Process.RELOCATION.name)
                        AND
                        (
                            //if manager email is blank, stick to old logic 
                            ((Manager_s_Email__c = null) AND (CreatedById IN :userIds OR LastModifiedById IN :userIds))
                            OR
                            //if manager email is populated, use that to pull cases
                            (Manager_s_Email__c !=null AND Manager_s_Email__c IN :userEmails)
                        )
                    )
                    OR
                    (   //FTE
                        NHW_Employee_Type__c = :PF_NHW_Process.FTE.name
                        AND
                        (
                            //if manager email is blank, stick to old logic
                            ((Manager_s_Email__c = null) 
                             AND
                             (
                                 (NHW_Job_Application__r.Job__r.Hiring_Manager__c != null AND NHW_Job_Application__r.Job__r.Hiring_Manager__c IN :userIds)
                             )
                            )
                            //if manager email is populated, use that to pull cases
                            OR
                            ( Manager_s_Email__c !=null AND Manager_s_Email__c IN :userEmails)
                        )
                    )
                )
                AND NHW_Start_Date__c >= :limitDate
                
               ];
    }
    
    public static List<Case> getPastProvisioningSVPCases(Set<Id> hiringManagerCaseIds){
        Date limitDate = Date.today().addMonths(-3);
        
        return [Select Id, CaseNumber,ParentId, RecordTypeId,
                NH_SST_User__c,NHW_Page_Number__c, Offer_Type__c,NH_Employee_Id__c,
                NHW_Organization__c, Resource_Type__c, NHW_Role__c,Business_Objects__c, 
                NHW_Employee__c, First_Name__c, Last_Name__c, 
                Email_Address__c, Division__c, Company__c,
                Company__r.Name, Cost_Center_NHW__c,
                Agreement_Received__c, Primary_Coverage_Country__c, 
                Job_Status__c, NHW_Cost_Center__c, NHW_Cost_Center__r.Name,
                NHW_Start_Date__c, Manager_Name__c, Manager_Name__r.Name,
                Onboarding_Buddy_Name__c, Onboarding_Buddy_Email__c, 
                Office_Address__c, Office_City__c, 
                Office_State_Province__c, Office_Zip_Postal_Code__c, 
                Office_Country__c,  
                Floor_Location_Cube_Location__c, 
                NH_ET_Team__c, NH_Shipping_Business_Site__c, NH_Shipping_Business_Site__r.Name,
                NH_Shipping_Local_Contact_Info__c,
                Mobile_Phone_Required__c, Desk_and_VoiceMail__c,
                Existing_Equipment__c, 
                Computer_Type__c, NHW_Access_Code__c,
                Same_as_Office_Location__c, Laptop_Type__c,
                End_Date__c, Contractor_Hire_Reason__c,
                NHW_Training__c, NHW_Employee_Type__c, 
                Shipping_Address__c, Shipping_City__c, NH_Personal_Email__c, 
                Shipping_Zip_Postal__c, Shipping_State__c, 
                Shipping_Country__c, Description, 
                Location_Type__c, NH_Business_Site__c,
                Business_Unit_NHW__c, NHW_Business_Unit__c, NHW_Business_Unit__r.Name,
                ES_DJC_Business_Justification__c, Business_Title__c,
                Manager_s_Email__c, NH_Is_Exact_Target__c,
                NH_ET_Sub_Region__c,NH_Legacy_ET_Dept_Code__c,
                NH_Open_Air_Role__c,
                NHW_Job_Application__r.Job__r.Job_Code__c,
                NHW_Job_Application__r.Job__r.Employment_Type__c,
                CreatedById, LastModifiedById,
                NH_Business_Site__r.Name,
                NHW_Job_Application__r.Job__r.Hiring_Manager__c,
                NHW_Job_Application__r.Job__r.Is_SVP_Level_Job__c,
                Created_with_NHW_2_0__c
                From Case
                Where RecordTypeId =: NHW_Util.getnhwCaseRecordTypeId()
                AND (IsClosed = true OR Status IN ('Sent to Supportforce','Accounts in Progress - Supportforce') )
                AND (NHW_Employee_Type__c = :PF_NHW_Process.FTE.name)
                AND (NHW_Job_Application__r.Job__r.Is_SVP_Level_Job__c = true)
                AND (Id NOT IN :hiringManagerCaseIds)
                AND NHW_Start_Date__c >= :limitDate
                
               ];
    }
    
    public static Case getEmptyProvisioningCase(PF_NHW_Process process){
        Case provisioningCase = new Case(RecordTypeId = NHW_Util.getnhwCaseRecordTypeId(), NHW_Employee_Type__c = process.name, NH_Is_Exact_Target__c = false);
        if(process == PF_NHW_Process.RELOCATION){
            provisioningCase.Resource_Type__c = 'SFDC Employee';
        }
        return provisioningCase;
    }
    
    public static Set<String> getUserEmails(Set<Id> userIds){
        Set<String> userEmails = new Set<String>();
        for(User u:[Select Email from User where Id IN:userIds]){
            userEmails.add(u.Email);
        }
        return userEmails;
    }
    
    public static Case getProvisioningCaseForNewHire(String emailAddress){
        
        List<Case> provisioningcaseForNewHire = [Select Id, CaseNumber,ParentId, RecordTypeId,Status,
                NH_SST_User__c,NHW_Page_Number__c, Offer_Type__c,NH_Employee_Id__c,
                NHW_Organization__c, Resource_Type__c, NHW_Role__c,Business_Objects__c, 
                NHW_Employee__c, First_Name__c, Last_Name__c, 
                Email_Address__c, Division__c, Company__c,
                Company__r.Name, Cost_Center_NHW__c,
                Agreement_Received__c, Primary_Coverage_Country__c, 
                Job_Status__c, NHW_Cost_Center__c, NHW_Cost_Center__r.Name,
                NHW_Start_Date__c, Manager_Name__c, Manager_Name__r.Name,
                Onboarding_Buddy_Name__c, Onboarding_Buddy_Email__c, 
                Office_Address__c, Office_City__c, 
                Office_State_Province__c, Office_Zip_Postal_Code__c, 
                Office_Country__c,  
                Floor_Location_Cube_Location__c, 
                NH_ET_Team__c, NH_Shipping_Business_Site__c, NH_Shipping_Business_Site__r.Name,
                NH_Shipping_Local_Contact_Info__c,
                Mobile_Phone_Required__c, Desk_and_VoiceMail__c,
                Existing_Equipment__c, 
                Computer_Type__c, NHW_Access_Code__c,
                Same_as_Office_Location__c, Laptop_Type__c,
                End_Date__c, Contractor_Hire_Reason__c,
                NHW_Training__c, NHW_Employee_Type__c, 
                Shipping_Address__c, Shipping_City__c, NH_Personal_Email__c, 
                Shipping_Zip_Postal__c, Shipping_State__c, 
                Shipping_Country__c, Description, 
                Location_Type__c, NH_Business_Site__c,
                Business_Unit_NHW__c, NHW_Business_Unit__c, NHW_Business_Unit__r.Name,
                ES_DJC_Business_Justification__c, Business_Title__c,
                Manager_s_Email__c, NH_Is_Exact_Target__c,
                NH_ET_Sub_Region__c,NH_Legacy_ET_Dept_Code__c,
                NH_Open_Air_Role__c,
                NHW_Job_Application__r.Job__r.Job_Code__c,
                NHW_Job_Application__r.Job__r.Is_SVP_Level_Job__c,
                NHW_Job_Application__r.Job__r.Employment_Type__c,
                NH_Training_Email_Merge__c,NHW_Trail_Guide__c,NH_FTE_Hire_Reason__c,
                CreatedById, LastModifiedById,
                NHW_Job_Application__r.Job__r.Hiring_Manager__c,
                NH_Business_Site__r.Name, Created_with_NHW_2_0__c,
                Is_Accessibility_required__c 
                From Case 
                Where NHW_Job_Application__r.Job__r.Employment_Type__c = 'Regular' 
                AND Email_Address__c =: emailAddress AND Status != 'Closed - Cancelled' 
                AND NHW_Employee_Type__c = 'Regular Employee' 
                ORDER BY ClosedDate DESC LIMIT 1]; 
        
        if(provisioningcaseForNewHire != null && !provisioningcaseForNewHire.isEmpty()) {
            return provisioningcaseForNewHire[0];
        }
        
        return null;
    }

    
       
}