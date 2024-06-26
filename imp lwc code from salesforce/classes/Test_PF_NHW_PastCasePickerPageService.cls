@istest
public class Test_PF_NHW_PastCasePickerPageService {

    private static final String RECORD_TYPE_APINAME_NEW_HIRE_PROCESS_ONBOARDING = 'New_Hire_Process_Onboarding';
    private final static String EMPLOYEE_TYPE_REGULAR = 'regular employee';
    private final static String TEST_EMAIL = 'testDataExec@example.com';


    @testSetup
    static void init() {
        NH_Settings__c nhs = new NH_Settings__c(NoOfDaysBeforeStartDateToSendRemindEmail__c = 15,Valid_AD_Email_Domains__c='salesforce.com');
        insert nhs;
        
    }
    
    //wd4s - show cases with status 'Account in progress - supportforce' on past case page
    @isTest
    public static void showSentToSupportforceCases() {
        Case provisioningCase = new Case(RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_APINAME_NEW_HIRE_PROCESS_ONBOARDING).getRecordTypeId(),
                                        created_with_NHW_2_0__c=true,Manager_s_Email__c = UserInfo.getUserEmail(),NHW_Employee_Type__c=EMPLOYEE_TYPE_REGULAR,NHW_Start_Date__c = Date.today().addDays(10));
      
        Test.startTest();
        insert provisioningCase;
        provisioningCase.Status='Accounts in Progress - Supportforce'; 
        update provisioningCase;
        PF_NHW_PageService pageService = new PF_NHW_PastCasePickerPageService();
        Map<String, Object> pageinfo = pageService.getPageInformation(EMPLOYEE_TYPE_REGULAR,null); 
        Test.stopTest();
        Map<String,Object> pageConfig = (Map<String,Object>) pageinfo.get('PAGE_CONFIG');
        List<PF_NHW_PastCasePickerPageService.CasePickerNewHire> newHires = (List<PF_NHW_PastCasePickerPageService.CasePickerNewHire>)pageConfig.get('NH');
        System.debug(newHires);
        System.assertEquals(newHires.size(),1);
    }
    
    //wd4s - show SVP cases with status 'Account in progress - supportforce' on past case page
    @isTest
    public static void showSentToSupportforceCasesSVP() {
        NHW_Executive_Onboarding_Team_Emails__c testData1 = new NHW_Executive_Onboarding_Team_Emails__c(Name='1',Executive_Member_Email__c=TEST_EMAIL);
        Test.startTest();
        WDR_Testfactory testdata = new WDR_Testfactory();
        testdata.createJobApp();
        WDR_Application__c defaultJobApplication = testdata.getDefaultJobApp();
        DefaultJobApplication.Candidate_Stage__c = 'Placement';
        WDR_Job__c job = testdata.getDefaultJobReq();
        job.Job_Level__c = '13';
        update job;
        Case provisioningCase = new Case(RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_APINAME_NEW_HIRE_PROCESS_ONBOARDING).getRecordTypeId(),
                                        created_with_NHW_2_0__c=true,Manager_s_Email__c = TEST_EMAIL,NHW_Employee_Type__c=EMPLOYEE_TYPE_REGULAR,NHW_Start_Date__c = Date.today().addDays(10),
                                        NHW_Job_Application__c = DefaultJobApplication.id);
      
        
        insert testData1;
        insert provisioningCase;
        provisioningCase.Status='Accounts in Progress - Supportforce'; 
        update provisioningCase;
        NHW_Util.testVariableCurrentUserEmail = 'testDataExec@example.com';
        PF_NHW_PageService pageService = new PF_NHW_PastCasePickerPageService();
        Map<String, Object> pageinfo = pageService.getPageInformation(EMPLOYEE_TYPE_REGULAR,null); 
        Test.stopTest();
        Map<String,Object> pageConfig = (Map<String,Object>) pageinfo.get('PAGE_CONFIG');
        List<PF_NHW_PastCasePickerPageService.CasePickerNewHire> newHires = (List<PF_NHW_PastCasePickerPageService.CasePickerNewHire>)pageConfig.get('NH');
        System.assertEquals(newHires.size(),1);
    }
    
     //wd4s - Hide open cases on past case page
    @isTest
    public static void hideOpenCases() {
        Case provisioningCase = new Case(RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_APINAME_NEW_HIRE_PROCESS_ONBOARDING).getRecordTypeId(),
                                        created_with_NHW_2_0__c=true,Manager_s_Email__c = UserInfo.getUserEmail(),NHW_Employee_Type__c=EMPLOYEE_TYPE_REGULAR,NHW_Start_Date__c = Date.today().addDays(10));
      
        Test.startTest();
        insert provisioningCase;
        PF_NHW_PageService pageService = new PF_NHW_PastCasePickerPageService();
        Map<String, Object> pageinfo = pageService.getPageInformation(EMPLOYEE_TYPE_REGULAR,null); 
        Test.stopTest();
        Map<String,Object> pageConfig = (Map<String,Object>) pageinfo.get('PAGE_CONFIG');
        List<PF_NHW_PastCasePickerPageService.CasePickerNewHire> newHires = (List<PF_NHW_PastCasePickerPageService.CasePickerNewHire>)pageConfig.get('NH');
        System.assertEquals(newHires.size(),0);
    }
    

    
    
    //FTE - verify sent to supportforce cases are visible on past submission page 
    @isTest
    public static void validate_PastFTE_CaseVisible() {
        Case provCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        provCase.RecordTypeId = NHW_Util.getnhwCaseRecordTypeId();
        provCase.Status = 'Sent to Supportforce';
        provCase.Created_with_NHW_2_0__c = true;
        Case provCase2 = provCase.clone();
        provCase2.NHW_Start_Date__c = Date.today().addDays(10);
        Test.startTest();
        List<Case> cc = new List<Case>{provCase,provCase2};
        insert cc;
        PF_NHW_PageService pageService = new PF_NHW_PastCasePickerPageService();
        Map<String, Object> pageinfo = pageService.getPageInformation(EMPLOYEE_TYPE_REGULAR,null);
        Test.stopTest();
        Object compConfigList = pageinfo.get('PAGE_CONFIG');
        Map<String,Object> m = (Map<String, Object>)compConfigList;
        List<PF_NHW_PastCasePickerPageService.CasePickerNewHire> newHires = (List<PF_NHW_PastCasePickerPageService.CasePickerNewHire>)m.get('NH');
        newHires.sort();
        System.assertEquals(newHires[0].name, provCase2.First_Name__c+' '+provCase2.Last_Name__c);
        System.assertEquals(newHires[1].name, provCase.First_Name__c+' '+provCase.Last_Name__c);
    }
    
    //FTE - verify not sent to supportforce cases are not visible on past submission page 
    @isTest
    public static void validate_PastFTE_CaseNotVisible() {
        Case provCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        provCase.RecordTypeId = NHW_Util.getnhwCaseRecordTypeId();
        provCase.Status = 'New';
        provCase.Created_with_NHW_2_0__c = true;
        Test.startTest();
        insert provCase;
        PF_NHW_PageService pageService = new PF_NHW_PastCasePickerPageService();
        Map<String, Object> pageinfo = pageService.getPageInformation(EMPLOYEE_TYPE_REGULAR,null);
        Test.stopTest();
        Object compConfigList = pageinfo.get('PAGE_CONFIG');
        Map<String,Object> m = (Map<String, Object>)compConfigList;
        List<PF_NHW_PastCasePickerPageService.CasePickerNewHire> newHires = (List<PF_NHW_PastCasePickerPageService.CasePickerNewHire>)m.get('NH');
        System.assertEquals(newHires.size(), 0);
    }
    
    //validate sent to supportforce Contractor Cases are  visible on past submissions page
    @isTest
    public static void validate_PastContractor_CaseVisible() {
        Contact con = new Contact();
        con.FirstName = 'Manager';
        con.LastName ='TestData';
        con.email= UserInfo.getUserEmail();
        con.EmployeeNumber__c ='12345';
        con.recordTypeId = NHW_Util.getEmployeeContactRecordTypeId();
        insert con;
        Case provCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        provCase.RecordTypeId = NHW_Util.getnhwCaseRecordTypeId();
                provCase.Resource_Type__c = 'Other';
        provCase.Contractor_Hire_Reason__c = 'Standard';
        provCase.Status = 'Sent to Supportforce';
        provCase.NHW_Employee_Type__c = 'Contractor';
        provCase.Created_with_NHW_2_0__c = true;
        provCase.Manager_Name__c = con.id;
        Test.startTest();
        insert provCase;
        PF_NHW_PageService pageService = new PF_NHW_PastCasePickerPageService();
        Map<String, Object> pageinfo = pageService.getPageInformation(EMPLOYEE_TYPE_REGULAR,null);
        Test.stopTest();
        Object compConfigList = pageinfo.get('PAGE_CONFIG');
        Map<String,Object> m = (Map<String, Object>)compConfigList;
        List<PF_NHW_PastCasePickerPageService.CasePickerNewHire> newHires = (List<PF_NHW_PastCasePickerPageService.CasePickerNewHire>)m.get('NH');
        System.assertEquals(newHires[0].name, provCase.First_Name__c+' '+provCase.Last_Name__c);
    }
      
    
    //validate new Contractor Cases are not visible on past submissions page
    @isTest
    public static void validate_PastContractor_CaseNotVisible() {
        Contact con = new Contact();
        con.FirstName = 'Manager';
        con.LastName ='TestData';
        con.email= UserInfo.getUserEmail();
        con.EmployeeNumber__c ='12345';
        con.recordTypeId = NHW_Util.getEmployeeContactRecordTypeId();
        insert con;
        Case provCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        provCase.RecordTypeId = NHW_Util.getnhwCaseRecordTypeId();
        provCase.Status = 'New';
        provCase.Resource_Type__c = 'Other';
        provCase.Contractor_Hire_Reason__c = 'Standard';
        provCase.NHW_Employee_Type__c = 'Contractor';
        provCase.Created_with_NHW_2_0__c = true;
        provCase.Manager_Name__c = con.id;
        Test.startTest();
        insert provCase;
        PF_NHW_PageService pageService = new PF_NHW_PastCasePickerPageService();
        Map<String, Object> pageinfo = pageService.getPageInformation(EMPLOYEE_TYPE_REGULAR,null);
        Test.stopTest();
        Object compConfigList = pageinfo.get('PAGE_CONFIG');
        Map<String,Object> m = (Map<String, Object>)compConfigList;
        List<PF_NHW_PastCasePickerPageService.CasePickerNewHire> newHires = (List<PF_NHW_PastCasePickerPageService.CasePickerNewHire>)m.get('NH');
        System.assertEquals(newHires.size(), 0);
        
    }
}