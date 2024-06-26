/* All NHW Util methods should go here. 
CreatedBy: Rakesh Boinepalli. 
Change History: 
10/20/2014: Created Date. 

*/
@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
public without sharing class NHW_Util {
    private static final String CRYPTO_ALGORITHM = 'RS256'; 
    public static Onboarding_Setting__c onboardSetting = Onboarding_Setting__c.getInstance();
    public static NH_Settings__c NHSetting = NH_Settings__c.getInstance();
    public static string INTERNAL_TRAINING_SALES_CAMPAIGN_TYPE = 'Becoming Salesforce - Sales' ;
    public static string INTERNAL_TRAINING_NONSALES_CAMPAIGN_TYPE = 'Becoming Salesforce - Non-Sales' ;
    public static string INTERNAL_TRAINING_CSGBOOTCAMP_CAMPAIGN_TYPE = 'Internal - CSG Bootcamp' ;
    public static string INTERNAL_TRAINING_SALESBOOTCAMP_CAMPAIGN_TYPE = 'Internal - Sales Bootcamp' ;
    public static string INTERNAL_TRAINING_SEBOOTCAMP_CAMPAIGN_TYPE = 'Internal - SE Bootcamp' ;
    public static string INTERNAL_TRAINING_TPBOOTCAMP1_CAMPAIGN_TYPE = 'T&P Bootcamp: Wk 1: All T&P New Hires' ;
    public static string INTERNAL_TRAINING_TPBOOTCAMP2_CAMPAIGN_TYPE = 'T&P Bootcamp: Wk 2: Coding in the Cloud' ;
    public static string NHW_PROCESS_CONTACT_CREATION = 'Contact Creation' ;
    public static string NHW_PROCESS_PREBOARDING_CASE_CREATION = 'Preboarding Case Creation' ;
    public static string NHW_PROCESS_CLOSE_CANCEL_CASE = 'Close Cancel Cases' ;
    public static string NHW_PROCESS_RESCIND_CASE = 'Rescind' ;
    public static string MAPPING_TYPE_CUSTOM = 'Custom Mapping';
    
    
    public static final Integer LAST_N_DAYS=Integer.valueOf(onboardSetting.Pre_boarding_window__c);
    public static final Integer CONTRACTOR_START_WINDOW=Integer.valueOf(onboardSetting.Contractor_pre_boarding_window__c);
    public static final Integer CONTRACTOR_BACKDATE_WINDOW=Integer.valueOf(onboardSetting.Contractor_before_start_window__c);

    
    //ES Next Changes : Getting Job Req creation reasons
    public static set<string> NHWJobCreationReasonstoExclude =  new set<string>( onboardSetting.JobCreationReasons_to_Exclude_For_NHW__c == null ? new list<string>()  : onboardSetting.JobCreationReasons_to_Exclude_For_NHW__c.split(','));



    public static string ERROR_MESSAGE_PREFIX = 'Error message is : ';
    public static string STACK_TRACE = ' Stack Trace:  : ';
    public static string LINE_NUMBER = ' Line Number : ';


    public static set<string> NHWOfferTypestoExclude =  new set<string>( onboardSetting.OfferTypes_to_Exclude_For_NHW__c == null ? new list<string>()  : onboardSetting.OfferTypes_to_Exclude_For_NHW__c.split(','));
   
    //stores the value whether current user is an executive onboarding team member or not
    private static Boolean currentUserExecutive = null;
    //String variable to substitue for current user's email in unit tests
    @TestVisible private static String testVariableCurrentUserEmail = 'test@example.com';
    public List<accessCodeWrapper> accessCodeList;
    public Id newHireCaseId {get;set;}
    
    public static List<NHW_Process_WDR_Stage_Mapping__mdt> ProcessStageMappings = [select Candidate_Stage__c,NHW_Process__c 
                                                                                   from NHW_Process_WDR_Stage_Mapping__mdt];
    private static List<NH_DataMapping__mdt> contactToCaseCWmapping = null;   
    static Map<String, Set<String>> cwWorkOrderStatusMap = new Map<String, Set<String>>();
    
    /*
    * Utility method to get user's email
    * When test is running, it returns the value of variable testVariableCurrentUserEmail
    * From unit test, we can set the value of variable testVariableCurrentUserEmail and simulate a user with long email
    */
    private static String getCurrentUsersEmail(){
        if(Test.isRunningTest()){
            return testVariableCurrentUserEmail;
        }else{
            return UserInfo.getUserEmail();
        }
    }
    /*
    * Utility method to calculate if current user is an exectuive onboarding team member by looking for user's email in custom setting NHW_Executive_Onboarding_Team_Emails__c
    * Method returns the value of the static variable currentUserExecutive
    * If method is run for the first time (tracked by boolean variable currentUserExectuiveStatusCalculated)
    *   it will calculate the value for variable currentUserExecutive
    * else
    *   it will return the value of variable currentUserExecutive
    */
    public static Boolean isCurrentUserExecutive(){
        try{
            if(currentUserExecutive == null){
                String currentUserEmail = getCurrentUsersEmail();
                List<NHW_Executive_Onboarding_Team_Emails__c> existingCustomSettingRecords = new List<NHW_Executive_Onboarding_Team_Emails__c>();
                existingCustomSettingRecords = (NHW_Executive_Onboarding_Team_Emails__c.getAll()).values();
                Set<String> executiveMemberEmails = new Set<String>();
                for(NHW_Executive_Onboarding_Team_Emails__c currentCSrecord : existingCustomSettingRecords){
                    executiveMemberEmails.add(currentCSrecord.Executive_Member_Email__c);
                }
                if(executiveMemberEmails.contains(currentUserEmail)){
                    currentUserExecutive = True;
                }else{
                    currentUserExecutive = False;
                }
            }
            return currentUserExecutive;
        }catch(Exception e){
            System.debug('Error with determining if current user is Executive onboarding team member: '+e.getMessage());
            return False;
        }
    }

    public static set<String> preboardingStages{
        get {
            if (preboardingStages == null ) {
                preboardingStages = new set<string>();
                for(NHW_Process_WDR_Stage_Mapping__mdt  ProcessStageMapping:ProcessStageMappings){
                    if(ProcessStageMapping.NHW_Process__c.equalsIgnoreCase(NHW_PROCESS_PREBOARDING_CASE_CREATION)){
                        preboardingStages.add(ProcessStageMapping.Candidate_Stage__c);
                    }
                }
            } 
            system.debug(LoggingLevel.INFO,'preboardingStages in getter -'+preboardingStages);

            return preboardingStages;
        } set;
    }
    public static set<String> ContactCreationStages{
        get {
            if (ContactCreationStages == null ) {
                ContactCreationStages = new set<string>();
                for(NHW_Process_WDR_Stage_Mapping__mdt  ProcessStageMapping:ProcessStageMappings){
                    if(ProcessStageMapping.NHW_Process__c.equalsIgnoreCase(NHW_PROCESS_CONTACT_CREATION)){
                        ContactCreationStages.add(ProcessStageMapping.Candidate_Stage__c);
                    }
                }
            } 
            system.debug(LoggingLevel.INFO,'ContactCreationStages in getter -'+ContactCreationStages);
            
            return ContactCreationStages;
        } set;
    }
    public static set<String> CloseCancelStages{
        get {
            if (CloseCancelStages == null ) {
                CloseCancelStages = new set<string>();
                for(NHW_Process_WDR_Stage_Mapping__mdt  ProcessStageMapping:ProcessStageMappings){
                    if(ProcessStageMapping.NHW_Process__c.equalsIgnoreCase(NHW_PROCESS_CLOSE_CANCEL_CASE)){
                        CloseCancelStages.add(ProcessStageMapping.Candidate_Stage__c);
                    }
                }
            } 
            system.debug(LoggingLevel.INFO,'CloseCancelStages in getter -'+CloseCancelStages);
            
            return CloseCancelStages;
        } set;
    }

    public static set<String> FinalStages{
        get {
            if (FinalStages == null ) {
                FinalStages = new set<string>();
                for(NHW_Process_WDR_Stage_Mapping__mdt  ProcessStageMapping:ProcessStageMappings){
                    if(ProcessStageMapping.NHW_Process__c.equalsIgnoreCase(NHW_PROCESS_RESCIND_CASE)){
                        FinalStages.add(ProcessStageMapping.Candidate_Stage__c);
                    }
                }
            }
            system.debug(LoggingLevel.INFO,'FinalStages in getter -'+FinalStages);

            return FinalStages;
        } set;
    }
    
    private static final Id nhwPreBoardCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
        'New_Hire_Process').getRecordTypeId();
    
    private static final Id nhwCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('New_Hire_Process_Onboarding').getRecordTypeId();
    private static final Id employeeContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee').getRecordTypeId();
    private static final Id contractorContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contractor').getRecordTypeId();
    private static final Id candidateContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('WDR_Candidate').getRecordTypeId();
    public static final Id candidateAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('WDR_Candidate').getRecordTypeId();
    public static List<Account> CandidateAccounts = [select Id,name  from Account 
                                                     where Name='WDR Candidates' and RecordTypeId=:candidateAccountRecordTypeId];
   
    public Static String getBusinessSiteIdToName(Id businessSiteId){
        for(TF2_Business_Site__c businessSite:[select Id, Name from TF2_Business_Site__c]){
            if(businessSite.Id == businessSiteId){
                return businessSite.Name;
            }
        }
        return '';
    }
    
    public Static String getCostCenterIdToName(Id costCenterId){
        for(TF2_Department__c costCenter:[select Id, Name from TF2_Department__c]){
            if(costCenter.Id == costCenterId){
                return costCenter.Name;
            }
        }
        return '';
    }
    
    public Static String getBusinessUnitIdToName(Id businessUnitId){
        for(Business_Unit__c businessUnit:[select Id, Name from Business_Unit__c]){
            if(businessUnit.Id == businessUnitId){
                return businessUnit.Name;
            }
        }
        return '';
    }    
    public static Id getEmployeeContactRecordTypeId(){
        return employeeContactRecordTypeId; 
    }
    public static Id getContractorContactRecordTypeId(){
        return contractorContactRecordTypeId;
    }
    public static Id getCandidateContactRecordTypeId(){
        return candidateContactRecordTypeId; 
    } 
    public static Id getnhwPreBoardCaseRecordTypeId(){
        return nhwPreBoardCaseRecordTypeId; 
    }
    
    public static Id getnhwCaseRecordTypeId(){
        return nhwCaseRecordTypeId; 
    }
    public static boolean isBUexcluded(String businessUnit){
        List<NH_BU_CC_Selections__c> settings = NH_BU_CC_Selections__c.getall().values();
        for(NH_BU_CC_Selections__c c:settings){        
            if(c.BU_for_Org62_Contractor_Access__c != null && c.BU_for_Org62_Contractor_Access__c.contains(businessUnit)){
                system.debug('***returning true from isBUexcluded');
                return true;
            }
        }
        return false;
    }
    //Get the Org/Profile for given BU CC combo details
    //If they match - valid combo else 'Other'
    private static Map<String,String> ccToProfileMap = new Map<String,String>();
    private static Map<String,String> buToProfileMap = new Map<String,String>();
    static {
        for(NHW_DP_Cost_Centers__c buRec:NHW_DP_Cost_Centers__c.getall().values()){
            if(buRec.Business_Unit_Id__c != null && buToProfileMap.get(buRec.Business_Unit_Id__c+buRec.Profile_Name__c) == null){
                buToProfileMap.put(buRec.Business_Unit_Id__c+buRec.Profile_Name__c,buRec.Profile_Name__c);              
            }
        } 
        for(NHW_DP_Cost_Centers__c ccRec:NHW_DP_Cost_Centers__c.getall().values()){
            if(ccRec.Cost_Centers_id__c != null && ccToProfileMap.get(ccRec.Cost_Centers_id__c) == null){
                ccToProfileMap.put(ccRec.Cost_Centers_id__c,ccRec.Profile_Name__c);
            }
        } 
    }
    public string getOrgForBUCC(string CCId,string BUId){
        System.debug('Given CC'+CCId);
        System.debug('Given BU'+BUId);
        String Org = '';
        if(ccToProfileMap.containskey(ccId) && buToProfileMap.containskey(BUId+ccToProfileMap.get(ccId))){//Both BU and CC have same profile/Org - Hence valid
            Org= ccToProfileMap.get(ccId);
            System.debug(LOGGINGLEVEL.INFO,'Inside match -'+Org);
        }
        else{
            System.debug(LOGGINGLEVEL.INFO,'Inside Unmatched');
            Org = 'Other';
        }
        return Org;
        
    }
    
    /*wrapper to hold all combinations of hiring managers and admin contacts*/
    public class Admin2HiringManager{
        public Id hiringManagerId {get;set;}
        public Id contactAdminId {get;set;}
        public String uniqueCombId {get;set;} 
        
        public Admin2HiringManager(Id hiringM, Id contactA, String uniqCom){
            this.hiringManagerId = hiringM;
            this.contactAdminId = contactA;
            this.uniqueCombId = uniqCom;
        }
        
    }
      
    public class accessCodeWrapper{
        public String accessCodeType {get;set;}
        public String accessCodeName {get;set;}
        public String accessCodeCloneUser {get;set;}
        
        public accessCodeWrapper(String type, String Name, String cloneAccess){
            this.accessCodeType = type;
            this.accessCodeName = Name;
            this.accessCodeCloneUser = cloneAccess;
        }
    } 
    
    /* This method takes a map of contact and hiring manager Ids , so that for bulk records, we can insert delegates for NHW Admins. */
    public static List<Database.SaveResult> insertDelegateForAdmins(List<Admin2HiringManager> adminDelegatesList){
        
        Set<String> existingAdminDelegateSet = new Set<String>();
        List<Delegate__c> adminDelegates = new List<Delegate__c>();
        Set<String> keySet = new Set<String>();
        for(Admin2HiringManager adm : adminDelegatesList){
            keySet.add(String.valueOf(adm.contactAdminId)+String.valueOf(adm.hiringManagerId)+'true');
            
        }
        
        for(Delegate__c del : [select Manager__c,Delegate__c,key__c from Delegate__c where key__c in : keySet]){
            existingAdminDelegateSet.add(del.key__c);
        }
        
        for(Admin2HiringManager adm : adminDelegatesList){
            
            if(!existingAdminDelegateSet.contains(String.valueOf(adm.contactAdminid)+String.valueOf(adm.hiringManagerId)+'true')){
                Delegate__c del = new Delegate__c(Manager__c= adm.hiringManagerId, Delegate__c = adm.contactAdminId, NHW_Is_NWH_Admin__c=true); 
                adminDelegates.add(del);    
            }
        }
        List<Database.SaveResult> results = new List<Database.SaveResult>();
        if(Delegate__c.sObjectType.getDescribe().isCreateable()){
            try {
                results = Database.insert(adminDelegates,false); 
            }catch (DmlException ex) { 
                system.debug('The following exception has occurred in method insertDelegateForAdmins: ' + 
                            ex.getDmlStatusCode(0) + ex.getMessage());
            }
        }
        return results;  
    }
    
    /* This method is to find all admin queue users and then get their associated contacts */
    public static List<Contact> getAdminContactsByQueue(String adminProvisioningQueue){
        
        Set<Id> queueUserIds = new Set<Id>();  // to hold userIds of queue members; 
        Set<String> adminuserEmails = new Set<String>(); //to hold NHW admin emails; 
        List<Contact> contacts = new List<Contact>(); // contacts list to hold all queue member contacts; 
        for(GroupMember gm : [SELECT userOrGroupId FROM GroupMember where Group.Type='Queue' and Group.developerName= : adminProvisioningQueue]){
            if(gm.UserOrGroupId!=null && String.valueOf(gm.UserOrGroupId).startsWith('005')){
                queueUserIds.add(gm.UserOrGroupId);
            } 
        } 
        
        for(User u : [select Email,IsActive from User where id in : queueUserIds]){
            if(u.IsActive){
                adminUserEmails.add(u.Email);
            }
        }
        
        if(adminuserEmails.size()>0){
            contacts =  [select Id,Email,status__c from Contact where recordType.Name in ('Employee','Contractor') and Status__c = 'Active' and Email in : adminUserEmails]; 
            if(contacts.size()<=0){
                contacts = null;
            }
        }
        return contacts;
    }
    
    /* This method is to find all admin queue users and then get their associated contacts */
    public static List<Contact> getAdminContactsByRole(String adminRoleName){
        
        Set<String> adminuserEmails = new Set<String>(); //to hold NHW admin emails; 
        List<Contact> contacts = new List<Contact>(); // contacts list to hold all role member contacts; 
        
        for(User u : [select Email,IsActive from User where userrole.name='IT NH Admin']){
            if(u.IsActive){
                adminUserEmails.add(u.Email);
            }
        }
        
        if(adminuserEmails.size()>0){
            contacts =  [select Id,Email,status__c from Contact where recordType.Name in ('Employee','Contractor') and Status__c = 'Active' and Email in : adminUserEmails]; 
            if(contacts.size()<=0){
                contacts = null;
            }
        }
        return contacts;
    }
    
    
    
  /* check if cases are sent to admins for provisioning, so that on case trigger we determine whether or not to create child admin records for delegate object, if loggedin user is both delegate and also an admin*/

  public static Map<Id,boolean> CheckCasesAdminProvisioned(List<Case> cases){

    Map<Id,boolean> adminSentCases = new Map<Id,boolean>();
    
    List<Case> caseWithAutoprovisioningFlag = [SELECT Id, 
                                                  NHW_Job_Application__c, NHW_Job_Application__r.Auto_Provisioning_Email_Sent__c FROM Case WHERE ID in : cases];
    for(Case cse: caseWithAutoprovisioningFlag){
      if(cse.NHW_Job_Application__r.Auto_Provisioning_Email_Sent__c){
        adminSentCases.put(cse.Id, true);
      }else{
        adminSentCases.put(cse.Id, false);
      }
    }
    return adminSentCases.size() == 0 ? null: adminSentCases;
  }
    
    
    /* get email template*/
    
    public static Id getEmailTemplateId(String tempName){
        try{
            return [select Id from EmailTemplate where DeveloperName =: tempName lIMIT 1].Id;
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        return null;
    }
    
    /* GET ORGWIDE EMAIL*/
    public static Id getOrgWideEmail(String emailAddress){
        try{
            return [select id from OrgWideEmailAddress  where address =:emailAddress LIMIT 1].Id;
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        return null;
    }
    
    
    /* return ID of record Type */
    
    public static Id getNHWRecordTypeId(String recDName){
        try{
            return [select Id from RecordType where sObjectType='case' and developerName=:recDName].Id; 
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        return null;
    }
    
    //public static NHW_Default_Profiles__c getDefaultProfile(
    
    public NHW_Util() {
        
    }       
    

    public string getURLParam(Boolean isPreboarding,Id CaseId,Id RecruitObjId){
        NH_Settings__c settings = NH_Settings__c.getInstance();
        Boolean NHW2Active = settings.NHW_2_0_Active__c;
        String URLParam;
        if(isPreboarding){
            URLParam =  NHW2Active ?  'caseId='+CaseId : 'placementId='+RecruitObjId;
        }else{
            URLParam = 'caseId='+CaseId;
        }
        system.debug(LoggingLevel.INFO,URLParam);
        return URLParam;
    }  
    
    public static String[] getbccAddresses(){
        String[] bccAddressArray = new String[]{};
            try{
                //if today is within no of days of the start date
                if(NH_Settings__c.getInstance()!=null ){
                    String bcc = (String)NH_Settings__c.getInstance().BCC_Email_Addresses__c;
                    bccAddressArray = bcc.split(';',-1);
                }
            }catch(System.Exception e){
                throw e;
            }
        system.debug('****bccAddressArray ' + bccAddressArray);
        return bccAddressArray;
    }
    
    //This method calculates the reminder date for sending reminder emails to Hiring Manager 
    public static Date getReminderDate(){
        Date reminderDate=null;
        try{
            //if today is within no of days of the start date
            if(NH_Settings__c.getInstance()!=null ){
                integer noOfDays = (integer)NH_Settings__c.getInstance().NoOfDaysBeforeStartDateToSendRemindEmail__c;
                reminderDate = System.now().adddays(noOfDays).date();
            }
        }catch(System.Exception e){
            throw e;
        }
        return reminderDate;
    }
    
    public static integer getUrgentReminderJobDay(){
        integer urgentReminderJobDay = null;
        try{
            //if today is within no of days of the start date
            if(NH_Settings__c.getInstance()!=null ){
                urgentReminderJobDay  = (integer)NH_Settings__c.getInstance().WhenToRunUrgentNotificationJob__c;
            }
        }catch(System.Exception e){
            throw e;
        }
        return urgentReminderJobDay;
    }
    
    public static NHWRecruitmentModel getCurrentRecruitmentObject(){ 
        NHWRecruitmentModel modelobject = null;
        Id ObjectId;
        if(ApexPages.currentPage().getParameters().get('placementId')!=null){
            ObjectId = ApexPages.currentPage().getParameters().get('placementId');
        }
        else if(ApexPages.currentPage().getParameters().get('caseId')!=null){
            ObjectId = NHWRecruitmentModelObjectsStore.getModelIdByCaseId(ApexPages.currentPage().getParameters().get('caseId'));
        }
        system.debug(LOGGINGLEVEL.INFO,'modelobject -'+modelobject);
        return modelobject;
    }
    public static case mapPreboardingCaseToRecruitmentModel(NHWRecruitmentModel ModelObj){ 
        Case newCase = modelToCase(ModelObj, null);
        newCase.Subject = 'New Hire Preboarding Request for ' + 
            ModelObj.FirstName + ' ' + 
            ModelObj.LastName;
        newCase.Status = 'Sent to Supportforce';
        newCase.Internal_Support_Category__c = 'New Hire Preboarding Request';
        newCase.Description = 'Please create the AD account and the ' + 
            'Supportforce Internal Contact record for the New Hire.';
        newCase.Origin = 'NHW';
        newCase.NHW_Send_Reminder__c = true;
        newCase.HR_Approved__c = true;
        newCase.RecordTypeId = nhwPreBoardCaseRecordTypeId;
       
        return newCase;
    }

    public static Case modelToCase(NHWRecruitmentModel ModelObj, Case nhwCase){
        Case newCase = null;
        if(nhwCase == null){
            newCase = new Case();
        }else{
            newCase = nhwCase;
        }
        
        newCase.Offer_Type__c = ModelObj.OfferType;
        newCase.Manager_s_Email__c = ModelObj.Manager_s_Email;
        newCase.Manager_Name__c = ModelObj.ManagerContactId;
        newCase.ContactId = ModelObj.ManagerContactId;
        newCase.Office_Address__c = ModelObj.OfficeAddress;
        newCase.Office_City__c = ModelObj.OfficeCity;
        newCase.Office_Country__c = ModelObj.OfficeCountry;
        newCase.Office_State_Province__c = ModelObj.OfficeStateProvince;
        newCase.Office_Zip_Postal_Code__c = ModelObj.OfficeZipPostalCode;
        newCase.NH_Business_Site__c = ModelObj.BusinessSiteId;

        newCase.First_Name__c = ModelObj.FirstName;
        newCase.Last_Name__c = ModelObj.LastName;
        if(ModelObj.SFWorkEmailAddress != NULL){
            newCase.Email_Address__c=ModelObj.SFWorkEmailAddress; 
         }
         else
         {
             newCase.Email_Address__c=ModelObj.PersonalEmail;
         }
        newCase.NH_Personal_Email__c=ModelObj.PersonalEmail;
        newCase.End_Date__c = ModelObj.EndDate;
        newCase.Business_Title__c = ModelObj.BusinessTitle;
        newCase.Division__c = ModelObj.Region;
        newCase.Company__c = ModelObj.CompanyId;
        newCase.Primary_Coverage_Country__c = ModelObj.PrimaryCoverageCountry;
        newCase.Cost_Center_NHW__c = ModelObj.CostCenterName;
        newCase.Business_Unit_NHW__c = ModelObj.BusinessUnitName;        
        newCase.NHW_Business_Unit__c = ModelObj.BusinessUnitId;
        newCase.NHW_Cost_Center__c = ModelObj.CostCenterId;
        newCase.NHW_Start_Date__c = ModelObj.StartDate;
        newCase.Resource_Type__c =  ModelObj.ResourceType == 'Regular' ? 'SFDC Employee' : ModelObj.ResourceType;
        newCase.NHW_Job_Application__c = ModelObj.ModelId;
        newCase.NHW_Employee__c = ModelObj.EmployeeContactId;
        newCase.NH_Employee_Id__c = ModelObj.EmployeeNumber; 
        newCase.NH_FTE_Hire_Reason__c = ModelObj.ReqCreationReason;
        newCase.Type = 'NHW';
        return newCase;
    }
    
    public static list<Case> populatePreboardingCases(set<id> JobAppsIdsRdyForPreboarding){
        list<Case> preboardingCasesToBeCreated = new list<Case>();
        system.debug(LoggingLevel.INFO,JobAppsIdsRdyForPreboarding);
        if(JobAppsIdsRdyForPreboarding.size()>0){
            
            //Get mapping of Job Apps to Model Objects
            List<NHWRecruitmentModel> ModelObjs =  NHWRecruitmentJobApplicationDataMapper.getAllNHWRecruitmentModelObjectsByIds(JobAppsIdsRdyForPreboarding);
            system.debug(LoggingLevel.INFO,ModelObjs);

            //Map Model Objects to Case object
            for(NHWRecruitmentModel ModelObj:ModelObjs){ 
                preboardingCasesToBeCreated.add(NHW_Util.mapPreboardingCaseToRecruitmentModel(ModelObj));
            }
            system.debug(LoggingLevel.INFO,preboardingCasesToBeCreated);
        }
        return preboardingCasesToBeCreated;


    }
    /*
    * Do NOT use below method for any new functionality. To be depreated after CEMCI R2
    */
    public static list<contact> populateCandidateContacts(set<id> candidateIds){
        list<contact> candidateContactsToBeCreated = new list<contact>();
        list<WDR_Candidate__c> CandidatesRecs = [select id,First_Name__c,Last_Name__c,Employee_Number__c,Name,Email__c,(select id,name from contact__r)
                                                    from WDR_Candidate__c
                                                 where  id in :candidateIds];
        system.debug(LoggingLevel.INFO,CandidatesRecs);
        for(WDR_Candidate__c Candidate:CandidatesRecs){
            if(Candidate.contact__r.size()==0){ //Contact doesnt already exist for the candidate
                Contact c = new contact();
                c.FirstName = Candidate.First_Name__c;
                c.LastName  = Candidate.Last_Name__c;
                c.Email     = Candidate.Email__c;
                c.EmployeeNumber__c     = Candidate.Employee_Number__c;
                c.Accountid   = CandidateAccounts.size()>0? CandidateAccounts[0].id : null;
                c.NHW_Candidate__c= Candidate.id;
                c.RecordTypeId = NHW_Util.getCandidateContactRecordTypeId();
                candidateContactsToBeCreated.add(c);
            }

        }
        return candidateContactsToBeCreated;

    
    }
    
    public static Case getCurrentCase(){
        return getProvisioningCaseById(ApexPages.currentPage().getParameters().get('caseId'));
    }
    
    public static Case getProvisioningCaseById(String pcId){
        return [Select Id, CaseNumber, NH_SST_User__c,NHW_Page_Number__c, Offer_Type__c,NH_Employee_Id__c,
                NHW_Organization__c, Resource_Type__c, NHW_Role__c,Business_Objects__c, 
                NHW_Employee__c, First_Name__c, Last_Name__c, 
                Email_Address__c, Division__c, Company__c, Cost_Center_NHW__c,
                Primary_Coverage_Country__c, 
                Job_Status__c, NHW_Cost_Center__c, NHW_Cost_Center__r.Name,
                NHW_Start_Date__c, Manager_Name__c, 
                Onboarding_Buddy_Name__c, Onboarding_Buddy_Email__c, 
                Office_Address__c, Office_City__c, 
                Office_State_Province__c, Office_Zip_Postal_Code__c, 
                Office_Country__c, 
                Floor_Location_Cube_Location__c, 
                NH_ET_Team__c, Case.NH_Shipping_Business_Site__c,
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
                NHW_Job_Application__r.Job__r.Job_Code__c
                From Case
                Where Id = :pcId
                And RecordTypeId = :NHW_Util.getnhwCaseRecordTypeId()]; 
    }
    
    public static HTTPResponse performCallOut(String endpointUrl,String authToken,String methodType,String body){
        HttpRequest req = new HttpRequest(); 
        req.setMethod(methodType);
        req.setEndpoint(endpointUrl);
        req.setHeader('Authorization', 'OAuth '+authToken);
        req.setHeader('Content-Type', 'application/json');
        if(methodType == 'POST' || methodType == 'PATCH'){
            //req.setHeader('Content-Length',String.valueOf(body.length()));
            req.setBody(body);
        }
        req.setTimeout(60000);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('BODY: '+res.getBody());
        System.debug('STATUS:'+res.getStatus());
        System.debug('STATUS_CODE:'+res.getStatusCode());
        return res;
    }
    //NHW_RetryPFDebugLogSchedulable Schedule job every 2 hours  with Name "PF Debug Log Retry Mechanism"
    public static HTTPResponse queryOrg(String endpointUrl, String authToken){
        HttpRequest req = new HttpRequest(); 
        req.setMethod('GET');
        req.setEndpoint(endpointUrl);
        req.setHeader('Authorization', 'OAuth '+authToken);
        req.setHeader('Content-Type', 'application/json');
        
        req.setTimeout(60000);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('BODY: '+res.getBody());
        System.debug('STATUS:'+res.getStatus());
        System.debug('STATUS_CODE:'+res.getStatusCode());
        return res;
    }
    
    public static String getAccessToken(String endpointUrl,String audUrl,String certificate,String targetUserName,String key){
        String access_token;
        PF_JWT jwt = new PF_JWT(CRYPTO_ALGORITHM);
        jwt.cert = certificate;
        jwt.iss = key; 
        jwt.aud = audUrl;
        Map<String,String> claims = new Map<String,String>();
        claims.put('prn',targetUserName);
        jwt.claims = claims;
        try{
            access_token = PF_JWTBearerFlow.getAccessToken(endpointUrl, jwt); 
        }
        catch(Exception e){
            PF_Logger.log('NHW','ERROR', e.getMessage(),e.getTypeName(), e.getLineNumber()+ 'Error while fetching access token', 'NHW_Util');
            return null;
        }
        return access_token;
    }
    
    public static void insertNHWLogs(){
        if(!PF_Logger.logs.isEmpty()){
            PF_Logger.createLogs(PF_Logger.logs);
        }
    }
    
    
    public static String isValidTargetSSTUser(Id selectedUserId, Id managerId, Case nhCase , String empType, String conSearch,String targetOrg){
        
        String empNumber,email;
        User managerUsr,selectedUser;
        NHW_SSTController nhsst = new NHW_SSTController();
        List<User> resultUserSet = new List<User>();
        Case tempCase;
        nhsst.targetObject = targetOrg; 
        try{
            tempCase= [select Id,NH_SST_User__c,NH_GUS_SST_User__c,NH_Supportforce_SST_User__c from case where id = : nhCase.Id];
        } catch (Exception e){
            System.debug('Query wxception ' + e.getMessage());
            return null; //query Exception  
        }
        
        try{
            if(empType!='Contractor' && targetOrg == 'Org62'){
                managerUsr = [select Id,Name,EmployeeNumber,Email from user where contactId = : managerID];
                
                if(tempCase!=null && tempCase.NH_SST_User__c!=null && conSearch == getSSTName(tempCase.NH_SST_User__c)){
                    
                    nhCase.NH_SST_User__c = tempCase.NH_SST_User__c;
                    System.debug('skipping calculation for employee');
                    return 'success';
                }
                empNumber = managerUsr.EmployeeNumber;
                email = managerUsr.Email;
                nhsst.checkForMgmtHierchy = true;
                nhsst.isContractor = false; 
                nhsst.email = email;
                nhsst.empNumber = empNumber; 
                resultUserSet = nhsst.performSearch(conSearch);
            }  else { //for org62  contractors and gus and supportforce sst use cases... 
                nhsst.checkForMgmtHierchy = false;
                if(targetOrg == 'Org62' && tempCase.NH_SST_User__c!=null && getSSTName(tempCase.NH_SST_User__c) == conSearch){
                    nhCase.NH_SST_User__c = tempCase.NH_SST_User__c;
                    return 'success';
                } else if(targetOrg == 'GUS' && tempCase.NH_GUS_SST_User__c!=null && getSSTName(tempCase.NH_GUS_SST_User__c) == conSearch){
                    nhCase.NH_GUS_SST_User__c = tempCase.NH_GUS_SST_User__c;
                    return 'success';
                } else if(targetOrg == 'Supportforce' && tempCase.NH_Supportforce_SST_User__c!=null && getSSTName(tempCase.NH_Supportforce_SST_User__c) == conSearch){
                    nhCase.NH_Supportforce_SST_User__c = tempCase.NH_Supportforce_SST_User__c;
                    return 'success';
                }
                
                if(targetOrg == 'Org62'){
                    nhsst.isContractor = true;
                }
                resultUserSet = nhsst.performSearch(conSearch);
            }
            
            if(resultUserSet.size() == 1 ){
                
                if(targetOrg == 'Org62'){
                    nhCase.NH_SST_User__c = formatSSTUserName(resultUserSet[0].userName,resultUserSet[0].Name);
                } else if(targetOrg == 'GUS'){
                    nhCase.NH_GUS_SST_User__c =  formatSSTUserName(resultUserSet[0].userName,resultUserSet[0].Name); 
                } else if(targetOrg == 'Supportforce'){
                    nhCase.NH_Supportforce_SST_User__c = formatSSTUserName(resultUserSet[0].userName,resultUserSet[0].Name);
                }
                
                
            } else if(resultUserSet.size()>1){
                //throw multiple user found error//
                return 'multiple users found';
            } else if(resultUserSet.isEmpty()){
                //no user found , may be due to management hierarchy// 
                return 'no results';
            } 
            
        } catch(Exception e){
            return 'exception';
        }
        return 'success';
        
    }
    
    public static String getSSTUserName(String sstUser){
        /*sstUser is in format Name:Rakesh Boinepalli;UserName:rboinepalli@salesforce.com */
        if(sstUser!=null){
            try{
                List<String> nameSubString = sstUser.split(';',-1); 
                return nameSubString[1].split(':',-1)[1].trim(); 
            } catch(Exception e){
                return null;
            }
        }
        return null;
        
    }
    
    public static String getSSTName(String sstUser){
        /*sstUser is in format Name:Rakesh Boinepalli;UserName:rboinepalli@salesforce.com */
        if(sstUser!=null){
            try{
                List<String> nameSubString = sstUser.split(';',-1); 
                return nameSubString[0].split(':',-1)[1].trim(); 
            } catch(Exception e){
                return null;
            }
        }
        return null;
        
    }
    
    public static String formatSSTUserName(String userName, String name){
        if(userName!=null && name!=null){
            return 'Name: '+name+'; '+'UserName: '+userName;
        }
        return null;
    }
    
    
    public list<accessCodeWrapper> getaccessCodeList(){
        Case newHireCase = [select NHW_Access_Code__c from Case where Id = :newHireCaseId];
        map<String, map<String, String>> accessMap = new map<String, map<String, String>>();
        list<accessCodeWrapper> selectedAccessList = new list<accessCodeWrapper>();
        if (newHireCase.NHW_Access_Code__c != null && 
            newHireCase.NHW_Access_Code__c != '') {
                set<String> userNameSet = new set<String>();
                map<String, Id> userIdMap = new map<String, Id>();
                for(NHW_AccessCode accessC : (List<NHW_AccessCode>) JSON.deserialize(newHireCase.NHW_Access_Code__c,List<NHW_AccessCode>.class)){
                    for(NHW_AccessDetails accessD: accessC.accessDetailList){
                        if(accessMap.containsKey(accessC.accessType)){
                            accessMap.get(accessC.accessType).put(accessD.name,accessD.userToClone); 
                            accessCodeWrapper aList = new accessCodeWrapper(accessC.accessType,accessD.name,accessD.userToClone);
                            selectedAccessList.add(aList);
                        }
                        else {
                            accessMap.put(accessC.accessType,new Map<String,String>{accessD.name => accessD.userToClone});
                            accessCodeWrapper aList = new accessCodeWrapper(accessC.accessType,accessD.name,accessD.userToClone);
                            selectedAccessList.add(aList);
                        }
                    }
                }
            }
        accessCodeList = selectedAccessList;
        return accessCodeList;
    }
    
    public static Map<String,NHW_Exact_Target_BU__c> exactTargetBUs {
        get {
            Map<String,NHW_Exact_Target_BU__c> etBUs = new Map<String,NHW_Exact_Target_BU__c>();
            
            if(NHW_Exact_Target_BU__c.getInstance() != null){
                for(NHW_Exact_Target_BU__c e:NHW_Exact_Target_BU__c.getall().values()){
                    etBUs.put(e.Business_Unit__c,e);
                }
            }
            if(etBUs != null && etBUs.size() > 0){
                return etBUs;
            }
            else
                return null;
        } set;
        
    }
    
    public static boolean checkIfMarketingCloud(String bu){
        if((bu != '')&&(exactTargetBUs.get(bu) != null)) {
            return true;
        }
        return false;
    }

    public static void updateJobApplicationsRelatedCases(Set<Id> jobAppIds, Set<Id> cancelJobAppIds, Set<Id> JobAppIdsWithRescindHire){
        List<Case> casesToUpdate = new List<Case>();
        List<String> contactsToBeUpdated = new List<String>();
        Set<Id> contactsForRescindHire = new Set<Id>();
        List<WDR_Candidate__c> candidateList = new List<WDR_Candidate__c>();
        Set<Id> candidateIdSet = new Set<Id>();
        List<NHWRecruitmentModel> jobAppModels = NHWRecruitmentJobApplicationDataMapper.getAllNHWRecruitmentModelObjectsByIds(jobAppIds);
        Map<Id, NHWRecruitmentModel> newJobModelsMap = new Map<Id, NHWRecruitmentModel>();
        for(NHWRecruitmentModel model : jobAppModels){
            newJobModelsMap.put(model.ModelId, model);
        }
        if(!newJobModelsMap.isEmpty()){
            List<Case> relatedCases = [SELECT Id, Offer_Type__c,Manager_s_Email__c,Manager_Name__c,ContactId,Office_Address__c,Office_City__c,
                                            Office_Country__c,Office_State_Province__c,Office_Zip_Postal_Code__c,NH_Business_Site__c,
                                            First_Name__c,Last_Name__c,Email_Address__c,NH_Personal_Email__c,Business_Title__c,Division__c,Company__c,
                                            Primary_Coverage_Country__c,Cost_Center_NHW__c,Business_Unit_NHW__c,NHW_Business_Unit__c,
                                            NHW_Cost_Center__c,NHW_Start_Date__c,Resource_Type__c,RecordTypeId,NHW_Job_Application__c,NHW_Employee__c,NH_Employee_Id__c,
                                            Type,Description,Internal_Support_Category__c,Status,Subject,Origin,HR_Approved__c FROM Case 
                                            WHERE NHW_Job_Application__c IN :  jobAppIds];

            for(Case cse : relatedCases){
                cse.Cost_Center_NHW__c = newJobModelsMap.get(cse.NHW_Job_Application__c).CostCenterName;
                cse.Business_Unit_NHW__c = newJobModelsMap.get(cse.NHW_Job_Application__c).BusinessUnitName;        
                cse.NHW_Business_Unit__c = newJobModelsMap.get(cse.NHW_Job_Application__c).BusinessUnitId;
                cse.NHW_Cost_Center__c = newJobModelsMap.get(cse.NHW_Job_Application__c).CostCenterId;
                cse.NHW_Start_Date__c = newJobModelsMap.get(cse.NHW_Job_Application__c).StartDate;
                cse.NH_Business_Site__c = newJobModelsMap.get(cse.NHW_Job_Application__c).BusinessSiteId;
                cse.Manager_s_Email__c = newJobModelsMap.get(cse.NHW_Job_Application__c).Manager_s_Email;
                cse.Manager_Name__c = newJobModelsMap.get(cse.NHW_Job_Application__c).ManagerContactId;
                cse.Office_Address__c = newJobModelsMap.get(cse.NHW_Job_Application__c).OfficeAddress;
                cse.Office_City__c = newJobModelsMap.get(cse.NHW_Job_Application__c).OfficeCity;
                cse.Office_Country__c = newJobModelsMap.get(cse.NHW_Job_Application__c).OfficeCountry;
                cse.Office_State_Province__c = newJobModelsMap.get(cse.NHW_Job_Application__c).OfficeStateProvince;
                cse.Office_Zip_Postal_Code__c = newJobModelsMap.get(cse.NHW_Job_Application__c).OfficeZipPostalCode;
                cse.ContactId = newJobModelsMap.get(cse.NHW_Job_Application__c).ManagerContactId;
                //Irrespective of whether case is closed or not - we push the close-cancel status to ensure Marketing cloud and NHW are aware of the rejection.
                if((cancelJobAppIds != null && cancelJobAppIds.contains(cse.NHW_Job_Application__c))
                  || (JobAppIdsWithRescindHire!= null && JobAppIdsWithRescindHire.contains(cse.NHW_Job_Application__c))){
                    cse.Status = 'Closed - Cancelled';
                    contactsToBeUpdated.add(cse.Email_Address__c);
                    contactsForRescindHire.add(cse.NHW_Employee__c);
                }
                casesToUpdate.add(cse);
            }
        }

        if(!casesToUpdate.isEmpty() && Case.sObjectType.getDescribe().isUpdateable()){
            try {
                    Database.update(casesToUpdate, false);
                }  catch (DmlException ex) { 
                    system.debug('The following exception has occurred in method updateJobApplicationsRelatedCases: ' + 
                                ex.getDmlStatusCode(0) + ex.getMessage());
            }
        }

        if(contactsForRescindHire.size()>0){
            updateContactsForRescindHire(contactsForRescindHire);
        }
        
        if(contactsToBeUpdated != null && contactsToBeUpdated.size() > 0){
            NHW_Org62Service.org62CampaingMemberDeleteCallOut('deleteCampaignMember', contactsToBeUpdated,'');
        }
    
    } 

    @future
    public static void updateContactsForRescindHire(Set<Id> contactIds){
        List<Contact> contactsUpdatedForRescindHire = [Select Id,EmployeeNumber__c from Contact where Id IN :contactIds];
        for(Contact ct : contactsUpdatedForRescindHire){
            ct.EmployeeNumber__c = '';
        }
        if(Contact.sObjectType.getDescribe().isUpdateable()){
            try {
                Database.SaveResult[] srCList = Database.update(contactsUpdatedForRescindHire,false);
                Integer j = 0;
                for(Database.SaveResult sr:srCList){
                    if(!sr.isSuccess()){
                        for(Database.Error err : sr.getErrors()){
                            String Description = ERROR_MESSAGE_PREFIX+ err.getMessage() + '\n'
                                                + ' Status code  : ' + err.getStatusCode() + '\n'
                                                + ' Fields errored : ' + err.getFields() + '\n'
                                                + ' Contact id ' + contactsUpdatedForRescindHire[j].Id;
                            String ErrorMessage = ERROR_MESSAGE_PREFIX+ err.getMessage() ;
                            String ErrorType = 'Error while updating Employee Id of contacts for rescind hire in NHW_Utils';
                            PF_Logger.log('NHW','ERROR',ErrorMessage,ErrorType,Description,'NHW_Util');    
                        }
                    } 
                    j = j+1;
                }
                NHW_Util.insertNHWLogs();
            }  catch (DmlException ex) { 
                system.debug('The following exception has occurred in method updateContactsForRescindHire: ' + 
                            ex.getDmlStatusCode(0) + ex.getMessage());
            }
        }
    }

    public static string getCountryISOCode(String countryName){        
        try{
            GDPR_ISO_Country_Code__mdt countryISOCode= [SELECT ID,Alpha_2_code__c,Country_Name__c FROM GDPR_ISO_Country_Code__mdt WHERE Country_Name__c = :countryName limit 1];  
            return countryISOCode.Alpha_2_code__c;
        }
        catch (Exception e){
            System.debug('getCountryISOCode Query Exception' + e.getMessage());
            return null;   
        }
    }
    

    public static  Map<Id, List<Case>> getPendingCasesForAutoprovisioning(datetime inputDate){
    
        datetime currentDate = inputDate;
        
        Map<Id, List<Case>> pendingCasesMap = new Map<Id, List<Case>>();
        
        for(WDR_Application__c JobApp:[select id, Start_Date__c,Job__r.Hiring_Manager__c,
                                (Select id,subject,contactId,caseNumber,NHW_Job_Application__r.Job__r.Hiring_Manager__r.Email,
                                Internal_Support_Category__c,Status,NH_Is_Exact_Target__c,CreatedDate,Cost_Center_NHW__c, Business_Unit_NHW__c, NHW_Job_Application__c 
                                from cases__r where Origin = 'NHW')
                            from WDR_Application__c 
                            where Start_Date__c >: currentDate.date().addDays(3) and Start_Date__c < :currentDate.date().addDays(8)
                            and Candidate_Stage__c NOT IN :NHW_Util.CloseCancelStages]){//TODO:Add rejection.
        
        for(Case c: JobApp.Cases__r){
        
            if(c.Subject.StartsWith('New Hire Provisioning Request for') && c.Status == 'New'){
        
                if(!pendingCasesMap.containsKey(JobApp.Id)){
                    pendingCasesMap.put(JobApp.Id, new List<Case>());
                }
        
                pendingCasesMap.get(JobApp.Id).add(c);
                
                System.debug('@@@@ Provisioning Request '+pendingCasesMap);               
            }
            else if(c.Subject.StartsWith('New Hire Preboarding Request for') && c.Status == 'Closed' && JobApp.Cases__r.size()==1){
                if(!pendingCasesMap.containsKey(JobApp.Id)){
                    pendingCasesMap.put(JobApp.Id, new List<Case>());
                }
       
                pendingCasesMap.get(JobApp.Id).add(c); 
                
                System.debug('@@@@ Preboarding Request '+pendingCasesMap);    
            } 
        }              
        }
        
        return pendingCasesMap;
    
    }

    /*
    * Method designed to return custom metadata records for data mapping between two objects.
     */
    public static List<NH_DataMapping__mdt> getSourceFieldsFromNHDataMappingMDT(String sourceObj,String targetObj,String process){
        try {
            return [SELECT QualifiedApiName,MappingType__c,SourceFieldApiName__c, TargetFieldAPIName__c FROM NH_DataMapping__mdt WHERE SourceObjectApiName__c = :sourceObj AND TargetObjectApiName__c = :targetObj AND Process__c = :process];
        }catch(Exception err){
            String Description = ERROR_MESSAGE_PREFIX+ err.getMessage()  + '\n'
                    + STACK_TRACE + err.getStackTraceString() + '\n'
                    + LINE_NUMBER + err.getLineNumber();
            String ErrorMessage = ERROR_MESSAGE_PREFIX+ err.getMessage() ;
            String ErrorType = 'Error while query NH_DataMapping__mdt in NHW_Util.getSourceFieldsFromNHDataMappingMDT';
            PF_Logger.log('NHW','ERROR',ErrorMessage,ErrorType,Description,'NHW_SSORUpsertRelatedCasesAsync');
            return null;
        }
    }

    public static List<NH_DataMapping__mdt> getCWContactToCaseMappingData(){
        if(contactToCaseCWmapping == null){
            contactToCaseCWmapping = getSourceFieldsFromNHDataMappingMDT('Contact','Case','CW Contact to Case');
        }
        return contactToCaseCWmapping;
    }

    public static Set<String> getSourceObjectFieldsUsingNHDataMappingMDT(List<NH_DataMapping__mdt> dataMappings){
        Set<String> sourceFields = new Set<String>();
        
        for(NH_DataMapping__mdt mapping : dataMappings){
            if(mapping.MappingType__c == 'Direct Mapping'){
                sourceFields.add(mapping.SourceFieldApiName__c);
            }else if(mapping.MappingType__c == MAPPING_TYPE_CUSTOM){
                String className = mapping.QualifiedApiName;
                try{    
                    NH_DataMapping_CustomMapping customMappingClassInstance;
                    Type myCustomMappingClass=Type.forName(className);
                    customMappingClassInstance=(NH_DataMapping_CustomMapping) myCustomMappingClass.newInstance();
                    List<String> additionalFieldsForCustomMapping = customMappingClassInstance.getAdditionalSourceFieldsString();
                    sourceFields.addAll(additionalFieldsForCustomMapping);
                }catch(Exception err){
                    String Description = ERROR_MESSAGE_PREFIX+ err.getMessage()  + '\n'
                        + STACK_TRACE + err.getStackTraceString() + '\n'
                        + LINE_NUMBER + err.getLineNumber();
                    String ErrorMessage = ERROR_MESSAGE_PREFIX+ err.getMessage() ;
                    String ErrorType = 'Error while getting additional Contact query fields from custom mapping class ' +className+' in PF_NHW_ContactStore.getCW_ContactsForCaseMapping';
                    PF_Logger.log('NHW','ERROR',ErrorMessage,ErrorType,Description,'PF_NHW_ContactStore');
                }
                
            }
        }

        return sourceFields;
    }
    /*
    * Method will map source object field mapping to target object field mapping and also transverse up to related objects.
     */
    public static SObject updateValuesusingNHDataMappingMDT(SObject source, SObject target, List<NH_DataMapping__mdt> dataMappings){
        //first perform custom mappings
        //then perform direct mappings
        //this gives up a way to override custom mappings via direct mappings, incase of a quick fix for a production bug
        for(NH_DataMapping__mdt m: dataMappings){
            if(m.MappingType__c!=MAPPING_TYPE_CUSTOM){continue;}
            String className = m.QualifiedApiName;
            try{
                NH_DataMapping_CustomMapping customMappingClassInstance;
                Type myCustomMappingClass=Type.forName(className);
                customMappingClassInstance=(NH_DataMapping_CustomMapping) myCustomMappingClass.newInstance();
                customMappingClassInstance.performSourceToTargetCustomMapping(source, target);
            }catch(Exception err){
                String Description = ERROR_MESSAGE_PREFIX+ err.getMessage()  + '\n'
                        + STACK_TRACE + err.getStackTraceString() + '\n'
                        + LINE_NUMBER + err.getLineNumber();
                String ErrorMessage = ERROR_MESSAGE_PREFIX+ err.getMessage() ;
                String ErrorType = 'Error while getting performing custom Contact to case mapping from class ' +className+' in PF_NHW_ContactStore.getCW_ContactsForCaseMapping';
                PF_Logger.log('NHW','ERROR',ErrorMessage,ErrorType,Description,'PF_NHW_ContactStore');
            }
            
        }
        //below loop does direct field to field mapping
        for(NH_DataMapping__mdt m: dataMappings){
            if(m.MappingType__c==MAPPING_TYPE_CUSTOM){continue;}
            String sourceString = m.SourceFieldApiName__c;
            //If the source field is a reference field. ex: Field__r.Field__r.Field__c,
            // parse the fields and iterate to get the final field for mapping to source fieeld
            if(sourceString.contains('.')){
                String[] fieldsChain = sourceString.trim().split('\\.');
                SObject o = source;
                for(Integer i = 0; i < fieldsChain.size() - 1; i++){
                    o = o.getSobject(fieldsChain[i]);
                    if(o == null){
                        break;
                    }
                }
                if(o != null){
                    target.put(m.TargetFieldApiName__c,o.get(fieldsChain[fieldsChain.size() - 1]));
                }
            }else{
                target.put(m.TargetFieldApiName__c,source.get(sourceString));
            }
        }
        return target;
    }
    
    public static Map<String,Set<String>> getCWWorkOrderStatusMap(){
        if(cwWorkOrderStatusMap.isEmpty()){
            cwWorkOrderStatusMap = getCWWorkOrderStatusMapFromMDT();
        }
        return cwWorkOrderStatusMap;
    }
    
    /*
    * Method designed to return map of CW Type and respectic WO Status from custom metadata records for Contractor flow
    */
    public static Map<String,Set<String>>  getCWWorkOrderStatusMapFromMDT(){
        Map<String,Set<String>> cwWorkOrderStatusMap = new Map<String,Set<String>>();
        try {
            for(NHW_Work_Order_Status_Mapping__mdt wosMDT: [SELECT CW_Type__c, WO_Status__c FROM NHW_Work_Order_Status_Mapping__mdt  WHERE CW_Type__c != null AND WO_Status__c != null]){
                Set<String> woSet = new Set<String>();
                woSet.addAll(wosMDT.WO_Status__c.trim().split(','));
                cwWorkOrderStatusMap.put(wosMDT.CW_Type__c, woSet);
            }
        }catch(Exception err){
            String Description = ERROR_MESSAGE_PREFIX+ err.getMessage()  + '\n'
                    + STACK_TRACE + err.getStackTraceString() + '\n'
                    + LINE_NUMBER + err.getLineNumber();
            String ErrorMessage = ERROR_MESSAGE_PREFIX+ err.getMessage() ;
            String ErrorType = 'Error while query NHW_Work_Order_Status_Mapping__mdt in NHW_Util.getValidStatusMDT';
            PF_Logger.log('NHW','ERROR',ErrorMessage,ErrorType,Description,'processNHWContractorCaseOnUpdate');
            return null;
        }
        return cwWorkOrderStatusMap;
    }

}