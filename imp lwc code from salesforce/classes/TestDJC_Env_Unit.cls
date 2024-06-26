@isTest
public with sharing class TestDJC_Env_Unit {
    
    public static Id candidateId {get; set;}
    //public static Id accountId {get; set;}
    public static Id employeeId {get; set;}
    public static Id orgId { get; set; }
    public static User SysAdminUser {get; set;}
    public static User RecruiterUser {get; set;}
    public static User RegionalFBPUser {get; set;}    
    public static Map<String, User> StandardUserMap {get; set;}


    public static void EnvSetup(){
    
        AccoutSetup();

        Account canAcc = [ select Id from Account where name = 'Candidates' limit 1 ];
                
        candidateId = canAcc.Id;
        
        Account empAcc = [ select Id from Account where name = 'salesforce.com' limit 1 ];
        
        employeeId = empAcc.Id;
        
        //TestTF_Env_Unit.StandardUserSetup();
                
        //creating and verify the config setup
        CustomSettingSetupConfig();
        
        //creating and verify the tf2 setup
        CustomSettingSetuptf2();
                

    }

    public static void AccoutSetup() {
        CreateAndReturnSysAdmin();
        
        User runningUser = SysAdminUser;
        
        system.runas( runningUser ){
            orgId = UserInfo.getOrganizationId();
        }
                
        //query record type candidate
        Id CanRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        
        List<Account> accList = new List<Account>();
        
        Account CandidateAcc = new Account();
        CandidateAcc.Name = 'Candidates';
        CandidateAcc.recordtypeId = CanRecordTypeId;
        
        accList.add( CandidateAcc );
        
        Account EmployeeAcc = new Account();
        EmployeeAcc.Name = 'salesforce.com';
        EmployeeAcc.recordtypeId = CanRecordTypeId;
        
        accList.add( EmployeeAcc );
        
        insert accList;
    }

    public static void CustomSettingSetupConfig() {
        
        // check if a config is already build
        ts2__Config__c myconfig = ts2__Config__c.getInstance('Config');     
        
        // check if insert is needed.
        if ( myconfig == null ){
            ts2__Config__c newconfig = new ts2__Config__c();
            newconfig.Name = 'Config';
            newconfig.ts2extams__AMS_Skip_Substatus__c = true;
            newconfig.ts2__AMS_Skip_Stage__c = true;
            newconfig.ts2__EEO_Question_Handler__c = 'Always';
            newconfig.ts2__Enable_Close_Job_Order_Wizard__c = true;
            newconfig.ts2__Enable_Rollover__c = true;
            newconfig.ts2__Enhanced_Apply_to_Job__c = true;
            newconfig.ts2__Invite_to_Apply_Custom_Message__c = true;
            newconfig.ts2__JobOrderParserEndpointRealTime__c = 'https://p.jobscience.com/searchqueue/service.asmx';
            newconfig.ts2__JobTemplateDepartment__c = true;
            newconfig.ts2__JobTemplateJobFunction__c = true;
            newconfig.ts2__JobTemplateLocation__c = true;
            newconfig.ts2__JobTemplate_Primary_Recruiter__c = true;
            newconfig.ts2__Max_Attachment_Size__c = 5120;
            newconfig.ts2__Max_Number_of_Attachments__c = 0;
            newconfig.ts2__Max_Open_Applications__c = 0;
            newconfig.ts2__Question_Set_Handler__c = 'Populate';
            newconfig.ts2__RecruitingAccountId__c = candidateId;
            newconfig.ts2__ResumeParserEndpointBatch__c = 'https://f.jobscience.com/resumeviewerservice/service.asmx';
            newconfig.ts2__ResumeParserEndpointRealTime__c = 'https://p.jobscience.com/searchqueue/service.asmx';
            newconfig.ts2__Resume_Viewer_Type__c = 'PDF';
            newconfig.ts2__Rollover_Days_Valid__c = 999;
            newconfig.ts2__SearchCollectionEndpoint__c = 'https://s1.jobscience.com/SrpDts2/SrpSearch.asmx';
            newconfig.ts2__SearchCollectionName__c = '00DS0000003Ju3G';
            newconfig.ts2__Standard_Question_Handler__c = 'Allways';    
            insert newconfig;   
        }
    }    

    public static void CustomSettingSetuptf2() {

            TF2Settings__c newtf2 = new TF2Settings__c();
            newtf2.Employee_Account__c = employeeId;
            newtf2.Recruiting_Account_Id__c = candidateId;
            newtf2.SetupOwnerId = orgId;
            newtf2.name = 'Peoplforce';
            newtf2.Current_Candidate_Count__c = 1;
            newtf2.Employee_Success_SVP_VP__c = StandardUserMap.get('SVP').Id;
            newtf2.AE_BU_Override__c = '1302 - JFx,1901 - Desk.com,1601 - Radian6,1801 - HCM, 1401 - Do.com,1201 - Heroku,2206 - Model Metrics';
            newtf2.AE_Country_Override__c = 'United States,Japan,United Kingdom,Germany,France,Canada,Australia,Netherlands';
            newtf2.AE_ECOMM_Override__c = ((String)RegionalFBPUser.Id).substring(0, 15);
            newtf2.AE_Job_Code_Override__c = '162C04,162C05,162C06,162C07,180C03,180C04,180C05,182C06,182C07,182C08,182C09,185C06,185C07,185C08,185C09,188C05,188C06,188C07,195C03,195C04,335C07,336C07,336C08,336C09,339C03,339C04,339C05,385C05,385C06,385C07,399C04,399C05,399C06,399C07,400C05,400C07';
            newtf2.Commercial_AE__c = '5850,5852,5853,5854,5855,5856';
            newtf2.Commercial_AE_ID__c = ((String)RegionalFBPUser.Id).substring(0, 15);
            newtf2.Corp_Sales_Departments__c = '411,413,416,421,428,436,320,480,482,484,457,459,432,433,434';
            newtf2.Division_PickList_Values__c = 'Exact Target,CFL,Model Metrics,Shared Services,Desk.com,Do.com,HCM,Successforce,Integration,Radian6,Sales Cloud,Service Cloud,Data Cloud,Heroku,DRO,Emerging Platform,Principal Platform,Chatter,Platform,Shared Services,Pardot,RelateIQ';
            newtf2.Enterprise_AE__c = '5501,5552,5553,5554,5555,5556,5557,5558';
            newtf2.Enterprise_AE_ID__c = ((String)RegionalFBPUser.Id).substring(0, 15);
            newtf2.Field_Corp_Sales_Manager_Departments__c = '404,405,410,414,420,402';
            newtf2.Job_Details_Site_URL__c = '/apex/ts2__JobDetails';
            newtf2.Max_Candidates_Per_Account__c = 50000;
            newtf2.Offer_CFO__c = 'Hello Kitty';
            newtf2.Offer_CFO_ID__c = ((String)RegionalFBPUser.Id).substring(0, 15);
            newtf2.Offer_Total_Reward_Dir__c = 'Hello Kitty';
            newtf2.Offer_Total_Reward_Dir_ID__c = ((String)RegionalFBPUser.Id).substring(0, 15);
            newtf2.Offer_Total_Reward_VP__c = 'Hello Kitty';
            newtf2.Offer_Total_Reward_VP_ID__c = ((String)RegionalFBPUser.Id).substring(0, 15);
            newtf2.Sales_Dept_Num__c = '5700,5400,5402,5403,5702,5000,5853,5850,5852,5558,5854,5855,5856,5102,5500,5502,5503,5800,5802,5208,6305,5150,5152,5153,5755,5756,5505,5804,5506,5750,5752,5450,5753,5754,5550,5552,5553,5554,5555,5556,5557';
            newtf2.SR_EBR_Departments__c = '450,451,454,455,456';
            newtf2.WW_Sales_Departments__c = '406,407,408,409,412,415,418';
                  
            insert newtf2;

    }

    //Insert and Return System Admin
    public static void CreateAndReturnSysAdmin(){
        
        Profile p = [select id from profile where name='System Administrator'];
        User ceoUser = new User(alias = 'standceo', email='standarduserceo@testorg.com', isActive = true,
        emailencodingkey='UTF-8', lastname='ceo', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,
        timezonesidkey='America/Los_Angeles', username='sysAdmin@peopleforce.com.test', FirstName = 'ceo', Title='ceo', Management_Level__c = '1.1 CEO & Chairman');
        insert ceoUser;
        
        SysAdminUser = ceoUser;
    
    }

    // emporg 1 variable
    public static Contact CreateCandidates(  String firstName, String lastName, String email, String Region ) {

        Id CandidateRTID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        
        Contact candidate = new Contact();
        candidate.RecordTypeId=CandidateRTID;
        candidate.AccountId = candidateId;
        candidate.FirstName = firstName;
        candidate.lastName=lastName;
        candidate.email=email;
        candidate.Phone='4153545678';
        candidate.ts2__Text_Resume__c='Dummy record\nthis is an resume\nI enjoy sports.\nphp java';
        
        if ( Region == 'AMER'){
            candidate.MailingStreet = '123 Main St.';
            candidate.MailingCity = 'San Francisco';
            candidate.MailingState = 'CA';
            candidate.MailingCountry='US';
            candidate.MailingPostalCode = '94109';          
        }
        
        if ( Region == 'EMEA' ){
            candidate.MailingStreet = 'Block Two, Lotus Park';
            candidate.MailingCity = 'Middlesex';
            candidate.MailingState = 'Staines';
            candidate.MailingCountry='UK';
            candidate.MailingPostalCode = 'TW18 3AG';           
        }
        
        candidate.ts2__EmployerOrgName_1__c = 'Wato Enterprise';
        
        insert candidate;
        return candidate;
    }    
            
}