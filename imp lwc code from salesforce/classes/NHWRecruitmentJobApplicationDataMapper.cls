@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
public with sharing class NHWRecruitmentJobApplicationDataMapper implements NHWRecruitmentDataMapper {
    //Use to create /surface provisioning case in NHW UI.
    public NHWRecruitmentModel getNHWRecruitmentModelObjectById(Id JobAppId){
        WDR_Application__c jobAppRec = new WDR_Application__c() ;
        NHWRecruitmentModel ModelObject = new NHWRecruitmentModel(NHWModelType.JOBAPPLICATION) ;
        
        jobAppRec = NHWRecruitmentJobApplicationDataMapper.getJobAppRecByID(JobAppId);
        
        if(jobAppRec == null){
            return null;
        }
        
        ModelObject  = NHWRecruitmentJobApplicationDataMapper.mapJobAppToModelObject(jobAppRec);
        
        retrieveCandidateContacts(new NHWRecruitmentModel[]{ModelObject});
        
        if (JobAppRec.Job__r.Hiring_Manager__c != null) {
            User u = [Select Email 
                      From User 
                      Where Id = :JobAppRec.Job__r.Hiring_Manager__c ];
            List<User> portalUsers = [Select Id, ContactId 
                                      From User 
                                      Where Email =: u.Email
                                      And ContactId != null and isactive=true LIMIT 1];
            if(portalUsers.size()>0){
                ModelObject.ManagerContactId = portalUsers[0].ContactId;
            }else{
                ModelObject.ManagerContactId = null;
                
            }
            
        }
        
        return ModelObject;
        
    }
    
    //Used in preboarding case creation 
    public static List<NHWRecruitmentModel> getAllNHWRecruitmentModelObjectsByIds(set<Id> JobAppIds){
        List<WDR_Application__c> jobAppRecs = new List<WDR_Application__c>();
        List<NHWRecruitmentModel> ModelObjects = new  List<NHWRecruitmentModel>();
        
        set<string> emailSet = new set<string>();
        map<string,user> emailUserMap = new map<string,user>();
        
        jobAppRecs     = NHWRecruitmentJobApplicationDataMapper.getJobAppRecByIDs(JobAppIds);
        for(WDR_Application__c jobAppRec:jobAppRecs){
            emailSet.add(JobAppRec.Job__r.Hiring_Manager__r.Email);
            ModelObjects.add( NHWRecruitmentJobApplicationDataMapper.mapJobAppToModelObject(jobAppRec));
        }
        
        retrieveCandidateContacts(ModelObjects);
        
        for (User u : [Select Id, Email, ContactId
                       From User
                       Where Email IN :emailSet
                       And ContactId != null and isActive=true]) {
                           emailUserMap.put(u.Email, u);
                       }
        for(NHWRecruitmentModel ModelObj:ModelObjects){
            if(emailUserMap.containskey(ModelObj.Manager_s_Email)){
                ModelObj.ManagerContactId = emailUserMap.get(ModelObj.Manager_s_Email).ContactId;
            }else{
                ModelObj.ManagerContactId = null;
            }
        }
        
        return ModelObjects;
        
    }
    public List<NHWRecruitmentModel> getAllNHWRecruitmentModelObjectsForMger(set<id> userids){
        
        List<WDR_Application__c> ApplicationRecs = new list<WDR_Application__c>() ;
        List<NHWRecruitmentModel> ModelObjects = new list<NHWRecruitmentModel>() ;
        
        ApplicationRecs = NHWRecruitmentJobApplicationDataMapper.getJobAppRecsByHiringMgerIds(userids);
        
        for(WDR_Application__c AppRec : ApplicationRecs){
            ModelObjects.add( NHWRecruitmentJobApplicationDataMapper.mapJobAppToModelObject(AppRec) );
        } 
        
        retrieveCandidateContacts(ModelObjects);
        
        //TODO:Populate mgercontactId if necessary
        return ModelObjects;
    }
    
    public List<NHWRecruitmentModel> getAllNHWRecruitmentModelObjectsForExecOnboardingTeam(){
        
        List<WDR_Application__c> ApplicationRecs = new list<WDR_Application__c>() ;
        List<NHWRecruitmentModel> ModelObjects = new list<NHWRecruitmentModel>() ;
        
        ApplicationRecs = NHWRecruitmentJobApplicationDataMapper.getJobAppRecsforExecOnboardingTeam();
        
        for(WDR_Application__c AppRec : ApplicationRecs){
            ModelObjects.add( NHWRecruitmentJobApplicationDataMapper.mapJobAppToModelObject(AppRec) );
        } 
        
        retrieveCandidateContacts(ModelObjects);
        
        //TODO:Populate mgercontactId if necessary
        return ModelObjects;
    }
    
    private static void retrieveCandidateContacts(List<NHWRecruitmentModel> models){
        
        Set<Id> candidatesIds = new Set<Id>();
        
        for(NHWRecruitmentModel model:models){
            if(model.EmployeeContactId != null){
                candidatesIds.add(model.EmployeeContactId);
            }
        }
        //if CEMCI changes are live, use the new lookup field Candidate_Contact__c to get contact info
        Map<Id,WDR_Candidate__c> wdCandidatesMap = new Map<Id,WDR_Candidate__c>();
        List<String> conversionWorkerIds = new List<String>();
        if(candidatesIds.size() > 0){
            for(WDR_Candidate__c candidate : [SELECT Id, Candidate_Contact__c,Candidate_Contact__r.EmployeeNumber__c, Candidate_Contact__r.SF_Work_Email__c, Employee_Number__c FROM WDR_Candidate__c WHERE Id IN :candidatesIds]){
                wdCandidatesMap.put(candidate.Id, candidate);
                // W-116225888-OKTA for CW->FTE Conversion get list of worker Ids already available on WDR Candidate
                if(candidate.Employee_Number__c != null) {
                    conversionWorkerIds.add(candidate.Employee_Number__c);
                }
            }
        }

        //W-116225888-OKTA - Conversions - Query old related Contacts and Map worker Id to Email
        List<Contact> relatedConversionContacts = new List<Contact>(); 
        Map<String,String> workerIdToEmailMap = new Map<String,String>();

        if(conversionWorkerIds.size()>0) {
            try {
                relatedConversionContacts = NHW_WDRCandidate_CDC_Service.getExistingContactsForWorkerIds(conversionWorkerIds);
                workerIdToEmailMap = NHW_WDRCandidate_CDC_Service.getSFEmailByWorkerd(relatedConversionContacts);
            } catch(Exception e) {
                System.debug('Caught Exception in NHWRecruitmentJobApplicationDataMapper when trying to query old contacts for CW->FTE Conversions:'+e.getCause());
                System.debug(e.getStackTraceString());
            }   
        }
        

        for(NHWRecruitmentModel model:models){
            Id WDRCandidateId = model.EmployeeContactId;
            if((WDRCandidateId != null) && (wdCandidatesMap.containsKey(WDRCandidateId))){
                    WDR_Candidate__c WDCandidateRec = wdCandidatesMap.get(WDRCandidateId);
                    model.EmployeeContactId = WDCandidateRec.Candidate_Contact__c;
                    String WorkerIdOnCandidateContact = WDCandidateRec.Candidate_Contact__r.EmployeeNumber__c;
                    String SFWorkEmailOnCandidateContact = WDCandidateRec.Candidate_Contact__r.SF_Work_Email__c;
                    String WorkerIdOnWDCandidate = WDCandidateRec.Employee_Number__c;
                    // Worker Id is not yet available from PWTA on Candidate contact
                    // Indicates usual timing where preboarding case generated at placement stage
                    if(WorkerIdOnCandidateContact == null)
                    { 
                        //If Candidate rec has worker id , Indicates merge CW to FTE 
                        if(WorkerIdOnWDCandidate != null)
                        {
                          model.EmployeeNumber = WorkerIdOnWDCandidate;
                        }
                    }else{ //Worker Id available on candidate contact - indicates late preboarding case generation
                       model.EmployeeNumber = WorkerIdOnCandidateContact;
                    }
                    // Email is not yet available from PWTA on Candidate contact
                    // Indicates usual timing where preboarding case generated at placement stage
                    if(SFWorkEmailOnCandidateContact == null){
                        // if Worker Id available on  WD Candidate , let's try to see if existing FTE/CTRCT contact has email.
                         if(WorkerIdOnWDCandidate != null){
                            model.SFWorkEmailAddress = workerIdToEmailMap.get(model.EmployeeNumber) ;
                        }                 
                    }else{//Email already available on candidate contact - indicates late preboarding case generation
                        model.SFWorkEmailAddress =SFWorkEmailOnCandidateContact;
                    }
            }
        }
        
    }
    
    //Helper methods to query all related fields from WorkDay recruiting objects required by NHW    
    public static WDR_Application__c getJobAppRecByID(Id JobAppId){
        List<WDR_Application__c> result = [Select Id, Name, Offer_Type__c, Candidate__c,
                                           Start_Date__c,
                                           Candidate__r.First_Name__c, 
                                           Candidate__r.Last_Name__C,
                                           Candidate__r.Name,
                                           Candidate__r.Email__c, 
                                           Candidate__r.Employee_Number__c,
                                           Candidate__r.Mailing_Street__c,Candidate__r.Mailing_City__c,
                                           Candidate__r.Mailing_State__c,Candidate__r.Mailing_Postal_Code__c,
                                           Candidate__r.Mailing_Country__c,
                                           Job__c,
                                           Job__r.Department__c,
                                           Job__r.Department__r.Name, 
                                           Job__r.Company__c,
                                           Job__r.Company__r.Name, 
                                           Job__r.PCC__c, 
                                           Job__r.PCC__r.Name,
                                           //WDR_Job__r.ts2__Status__c, 
                                           Job__r.Target_Hire_Date__c,
                                           Job__r.Hiring_Manager__c, 
                                           Job__r.Hiring_Manager__r.Name,
                                           Job__r.Hiring_Manager__r.Email,
                                           Job__r.Job_Title__c, 
                                           Job__r.Business_Unit__c,
                                           Job__r.Business_Unit__r.Name,
                                           Job__r.Employment_Type__c, 
                                           Business_Site__c, Business_Site__r.Street_Address__c,
                                           Business_Site__r.State_Province__c, Business_Site__r.Postal_Code__c, 
                                           Business_Site__r.Country__c,Business_Site__r.City__c,Business_Site__r.Name,
                                           Job__r.Region__c,
                                           Job__r.Req_Creation_Reason__c,
                                           Job__r.Is_SVP_Level_Job__c,
                                           End_Date__c,
                                           (Select Id, IsClosed, Email_Address__c,status,RecordTypeId, CaseNumber, NHW_Employee__c, 
                                            NHW_Page_Number__c, First_Name__c, 
                                            Last_Name__c, NHW_Start_Date__c, 
                                            Resource_Type__c, NHW_Employee_Type__c,
                                            Manager_s_Email__c,
                                            Manager_Name__c, Manager_Name__r.Name, Business_Title__c,
                                            NH_Is_Exact_Target__c,
                                            NHW_Organization__c,
                                            NH_FTE_Hire_Reason__c,
                                            NHW_Job_Application__r.Job__r.Hiring_Manager__c,
                                            NHW_Job_Application__r.Job__r.Is_SVP_Level_Job__c,
                                            Created_with_NHW_2_0__c,CreatedDate
                                            From Cases__r
                                            order by createddate desc
                                           )
                                           From WDR_Application__c
                                           Where Id = :JobAppId
                                           AND Candidate__c != null] ; 
        if(!result.isEmpty()){
            return result.get(0);
        }
        return null;
    }   
    public static List<WDR_Application__c> getJobAppRecByIDs(set<id> JobAppIds){
        return [Select Id, Name, Offer_Type__c, Candidate__c,Start_Date__c,
                Candidate__r.First_Name__c, 
                Candidate__r.Last_Name__C,
                Candidate__r.Name,
                Candidate__r.Email__c, 
                Candidate__r.Employee_Number__c,
                Candidate__r.Mailing_Street__c,Candidate__r.Mailing_City__c,
                Candidate__r.Mailing_State__c,Candidate__r.Mailing_Postal_Code__c,
                Candidate__r.Mailing_Country__c,
                Job__c,
                Job__r.Department__c,
                Job__r.Department__r.Name, 
                Job__r.Company__c,
                Job__r.Company__r.Name, 
                Job__r.PCC__c, 
                Job__r.PCC__r.Name,
                //WDR_Job__r.ts2__Status__c, 
                Job__r.Target_Hire_Date__c,
                Job__r.Hiring_Manager__c, 
                Job__r.Hiring_Manager__r.Name,
                Job__r.Hiring_Manager__r.Email,
                Job__r.Job_Title__c, 
                Job__r.Business_Unit__c,
                Job__r.Business_Unit__r.Name,
                Job__r.Employment_Type__c, 
                Business_Site__c, Business_Site__r.Street_Address__c,
                Business_Site__r.State_Province__c, Business_Site__r.Postal_Code__c, 
                Business_Site__r.Country__c,Business_Site__r.City__c,Business_Site__r.Name,
                Job__r.Region__c,Job__r.Req_Creation_Reason__c,Job__r.Is_SVP_Level_Job__c,
                End_Date__c,
                (Select Id, IsClosed, Email_Address__c,status,RecordTypeId, CaseNumber, NHW_Employee__c, 
                 NHW_Page_Number__c, First_Name__c, 
                 Last_Name__c, NHW_Start_Date__c, 
                 Resource_Type__c, NHW_Employee_Type__c,
                 Manager_s_Email__c,
                 Manager_Name__c, Manager_Name__r.Name, Business_Title__c,
                 NH_Is_Exact_Target__c,
                 NHW_Organization__c,
                 NH_FTE_Hire_Reason__c,
                 NHW_Job_Application__r.Job__r.Hiring_Manager__c,
                 NHW_Job_Application__r.Job__r.Is_SVP_Level_Job__c,
                 Created_with_NHW_2_0__c,CreatedDate
                 From Cases__r
                 order by createddate desc
                )
                From WDR_Application__c
                Where 
                Id IN :JobAppIds AND Candidate__c != null] ; 
    }
    public static List<WDR_Application__c> getJobAppRecsByHiringMgerIds(set<id> userids){
        Integer daysBefore;
        
        NH_Settings__c orgDefault = NH_Settings__c.getOrgDefaults();
        if(orgDefault == null) {
            daysBefore = 30;
        }
        else {
            if(orgDefault.Days_Before_Start_Date__c == null) {
                daysBefore = 30;
            }
            else {
                daysBefore = orgDefault.Days_Before_Start_Date__c.intValue();
            }
        }
        
        return [Select Id, Name, Offer_Type__c, Candidate__c,
                Candidate__r.First_Name__c, 
                Candidate__r.Last_Name__C,
                Candidate__r.Name,
                Candidate__r.Email__c, 
                Candidate__r.Employee_Number__c,
                Candidate__r.Mailing_Street__c,Candidate__r.Mailing_City__c,
                Candidate__r.Mailing_State__c,Candidate__r.Mailing_Postal_Code__c,
                Candidate__r.Mailing_Country__c,
                Start_Date__c,
                Job__c,
                Job__r.Department__c,
                Job__r.Department__r.Name, 
                Job__r.Company__c,
                Job__r.Company__r.Name, 
                Job__r.PCC__c, 
                Job__r.PCC__r.Name,
                //WDR_Job__r.ts2__Status__c, 
                Job__r.Target_Hire_Date__c,
                Job__r.Hiring_Manager__c, 
                Job__r.Hiring_Manager__r.Name,
                Job__r.Hiring_Manager__r.Email,
                Job__r.Job_Title__c, 
                Job__r.Business_Unit__c,
                Job__r.Business_Unit__r.Name,
                Job__r.Employment_Type__c, 
                Job__r.Is_SVP_Level_Job__c,
                Business_Site__c, Business_Site__r.Street_Address__c,
                Business_Site__r.State_Province__c, Business_Site__r.Postal_Code__c, 
                Business_Site__r.Country__c,Business_Site__r.City__c,Business_Site__r.Name,
                Job__r.Region__c,
                Job__r.Req_Creation_Reason__c,
                End_Date__c,
                (Select Id, IsClosed, Email_Address__c,status,RecordTypeId, CaseNumber, NHW_Employee__c, 
                 NHW_Page_Number__c, First_Name__c, 
                 Last_Name__c, NHW_Start_Date__c, 
                 Resource_Type__c, NHW_Employee_Type__c,
                 Manager_s_Email__c,
                 Manager_Name__c, Manager_Name__r.Name, Business_Title__c,
                 NH_Is_Exact_Target__c,
                 NHW_Organization__c,NH_FTE_Hire_Reason__c,
                 NHW_Job_Application__r.Job__r.Hiring_Manager__c,
                 NHW_Job_Application__r.Job__r.Is_SVP_Level_Job__c,
                 Created_with_NHW_2_0__c,CreatedDate
                 From Cases__r
                 order by createddate desc
                )
                From WDR_Application__c
                Where Start_Date__c >= :Date.today().addDays(-1 * daysBefore)
                AND
                (Job__r.Hiring_Manager__c IN :userids OR Candidate__r.Candidate_Contact__r.Hiring_Manager__c IN :userids)
                AND Candidate__c != null
                AND Candidate_Stage__c = 'Placement'
                order by
                Start_Date__c 
                ASC] ; 
    }
    
    //ethod to query Job Apps where Job req is for Job Level >=12
    public static List<WDR_Application__c> getJobAppRecsforExecOnboardingTeam(){
        
        Integer daysBefore;
        
        NH_Settings__c orgDefault = NH_Settings__c.getOrgDefaults();
        if(orgDefault == null) {
            daysBefore = 30;
        }
        else {
            if(orgDefault.Days_Before_Start_Date__c == null) {
                daysBefore = 30;
            }
            else {
                daysBefore = orgDefault.Days_Before_Start_Date__c.intValue();
            }
        }
        return [Select Id, Name, Offer_Type__c, Candidate__c,
                Candidate__r.First_Name__c, 
                Candidate__r.Last_Name__C,
                Candidate__r.Name,
                Candidate__r.Email__c, 
                Candidate__r.Employee_Number__c,
                Candidate__r.Mailing_Street__c,Candidate__r.Mailing_City__c,
                Candidate__r.Mailing_State__c,Candidate__r.Mailing_Postal_Code__c,
                Candidate__r.Mailing_Country__c,
                Start_Date__c,
                Job__c,
                Job__r.Department__c,
                Job__r.Department__r.Name, 
                Job__r.Company__c,
                Job__r.Company__r.Name, 
                Job__r.PCC__c, 
                Job__r.PCC__r.Name,
                //WDR_Job__r.ts2__Status__c, 
                Job__r.Target_Hire_Date__c,
                Job__r.Hiring_Manager__c, 
                Job__r.Hiring_Manager__r.Name,
                Job__r.Hiring_Manager__r.Email,
                Job__r.Job_Title__c, 
                Job__r.Business_Unit__c,
                Job__r.Business_Unit__r.Name,
                Job__r.Employment_Type__c, 
                Job__r.Is_SVP_Level_Job__c,
                Business_Site__c, Business_Site__r.Street_Address__c,
                Business_Site__r.State_Province__c, Business_Site__r.Postal_Code__c, 
                Business_Site__r.Country__c,Business_Site__r.City__c,Business_Site__r.Name,
                Job__r.Region__c,
                Job__r.Req_Creation_Reason__c,
                End_Date__c,
                (Select Id, IsClosed, Email_Address__c,status,RecordTypeId, CaseNumber, NHW_Employee__c, 
                 NHW_Page_Number__c, First_Name__c, 
                 Last_Name__c, NHW_Start_Date__c, 
                 Resource_Type__c, NHW_Employee_Type__c,
                 Manager_s_Email__c,
                 Manager_Name__c, Manager_Name__r.Name, Business_Title__c,
                 NH_Is_Exact_Target__c,
                 NHW_Organization__c,NH_FTE_Hire_Reason__c,
                 NHW_Job_Application__r.Job__r.Hiring_Manager__c,
                 NHW_Job_Application__r.Job__r.Is_SVP_Level_Job__c,
                 Created_with_NHW_2_0__c,CreatedDate
                 From Cases__r
                 order by createddate desc
                )
                From WDR_Application__c
                Where Job__r.Is_SVP_Level_Job__c=True 
                AND Start_Date__c >= :Date.today().addDays(-1 * daysBefore)
                AND Candidate_Stage__c = 'Placement'
                AND Candidate__c != null
                order by 
                Start_Date__c 
                ASC] ; 
    }
    
    //Helper method to map data from WorkDay recruiting objects to NHW Case
    public static NHWRecruitmentModel mapJobAppToModelObject(WDR_Application__c JobAppRec){
        
        NHWRecruitmentModel ModelObject = new NHWRecruitmentModel(NHWModelType.JOBAPPLICATION) ; 
        ModelObject.OfferType = JobAppRec.Offer_Type__c;
        ModelObject.ResourceType = JobAppRec.Job__r.Employment_Type__c;
        ModelObject.FirstName = JobAppRec.Candidate__r.First_Name__c;
        ModelObject.LastName = JobAppRec.Candidate__r.Last_Name__c;
        ModelObject.EmployeeName = JobAppRec.Candidate__r.Name;
        ModelObject.CompanyAgencyName = JobAppRec.Job__r.Company__r.Name;
        ModelObject.PrimaryCoverageCountry = JobAppRec.Job__r.PCC__r.Name;
        //TODO:Deprecate same in NHW controller
        //ModelObject.JobStatus =  JobAppRec.Job__r.ts2__Status__c;    
        ModelObject.BusinessTitle = JobAppRec.Job__r.Job_Title__c;
        ModelObject.BusinessUnitName = JobAppRec.Job__r.Business_Unit__r.Name;
        ModelObject.CostCenterName =  JobAppRec.Job__r.Department__r.Name;
        ModelObject.BusinessUnitId = JobAppRec.Job__r.Business_Unit__c; 
        ModelObject.CostCenterId =  JobAppRec.Job__r.Department__c;
        ModelObject.StartDate = JobAppRec.Start_Date__c;   
        ModelObject.Manager_s_Email =  JobAppRec.Job__r.Hiring_Manager__r.Email;
        ModelObject.PersonalEmail = String.valueOf(JobAppRec.Candidate__r.Email__c);
        ModelObject.ModelId = JobAppRec.Id;
        ModelObject.EmployeeContactId = JobAppRec.Candidate__c;
        ModelObject.CompanyId = JobAppRec.Job__r.Company__c;
        ModelObject.BusinessSiteId = JobAppRec.Business_Site__c;
        ModelObject.Region = JobAppRec.Job__r.Region__c;
        ModelObject.HiringManagerName = JobAppRec.Job__r.Hiring_Manager__r.Name;
        ModelObject.EndDate = JobAppRec.End_Date__c;
        ModelObject.ReqCreationReason = JobAppRec.Job__r.Req_Creation_Reason__c;
        if(JobAppRec.Business_Site__c != null && JobAppRec.Business_Site__r.Name.contains('Remote')){
            ModelObject.OfficeAddress = JobAppRec.Candidate__r.Mailing_Street__c;
            ModelObject.OfficeCity = JobAppRec.Candidate__r.Mailing_City__c;
            ModelObject.OfficeStateProvince =  JobAppRec.Candidate__r.Mailing_State__c;
            ModelObject.OfficeZipPostalCode = JobAppRec.Candidate__r.Mailing_Postal_Code__c;
            ModelObject.OfficeCountry = JobAppRec.Candidate__r.Mailing_Country__c;
        }
        else{
            ModelObject.OfficeAddress = JobAppRec.Business_Site__r.Street_Address__c; 
            ModelObject.OfficeCity = JobAppRec.Business_Site__r.City__c;
            ModelObject.OfficeStateProvince = JobAppRec.Business_Site__r.State_Province__c;
            ModelObject.OfficeZipPostalCode = JobAppRec.Business_Site__r.Postal_Code__c;
            ModelObject.OfficeCountry = JobAppRec.Business_Site__r.Country__c;
        }
        
        for (Case c : JobAppRec.Cases__r) {
            if(c.RecordTypeId == NHW_Util.getnhwPreBoardCaseRecordTypeId()  ){
                ModelObject.preboardingCases.add(c); 
            }
            else if(c.RecordTypeId == NHW_Util.getnhwCaseRecordTypeId() ){
                ModelObject.provisioningcases.add(c); 
            }
        }
        
        for(Case c : ModelObject.preboardingCases){
            if (c.IsClosed) {
                ModelObject.supportforceEmail = c.Email_Address__c;
                break;
            }
        }
        
        if(JobAppRec.Business_Site__c != null 
           && JobAppRec.Business_Site__r.Name.contains('Remote') 
          ){
              ModelObject.isRemote = true;
          }
        else{
            ModelObject.isRemote = false;
            
        }
        
        return ModelObject;
    }   
    
}