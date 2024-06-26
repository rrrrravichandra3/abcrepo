@isTest
public class Test_PF_NHW_CasePickerPageService {
  private static final string EMPLOYEE_TYPE_REGULAR = 'regular employee';
  @testSetup
  static void init() {
    NH_Settings__c nhs = new NH_Settings__c(
      NoOfDaysBeforeStartDateToSendRemindEmail__c = 15,
      Valid_AD_Email_Domains__c = 'salesforce.com'
    );
    insert nhs;

    Contact con = new Contact();
    con.FirstName = 'Manager';
    con.LastName = 'TestData';
    con.email = UserInfo.getUserEmail();
    con.EmployeeNumber__c = '12345';
    con.recordTypeId = NHW_Util.getEmployeeContactRecordTypeId();
    insert con;
  }

  //WD4S - if FTE provisioning case is in status Account in progress, then do not show it on landing page
  @isTest
  static void hideCasesWithStatusAccountinProgressFTE() {
    WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.createJobApp();
    WDR_Application__c defaultJobApplication = testdata.getDefaultJobApp();
    WDR_Job__c defaultJobReq = testdata.getDefaultJobReq();
    DefaultJobApplication.Start_Date__c = System.Today().addDays(16);

    Test.startTest();
    DefaultJobReq.Employment_Type__c = 'Regular';
    update DefaultJobReq;
    DefaultJobApplication.Candidate_Stage__c = 'Placement';
    update DefaultJobApplication;
    Test.stopTest();
    List<Case> cases = [SELECT Id, status FROM Case WHERE NHW_Job_Application__c = :DefaultJobApplication.id];
    cases[0].status = 'Closed';
    update cases;
    Case provisioningCase = PF_NHW_ProvisioningCaseStore.generateProvisioningCaseFromPreboardingCase(cases[0].Id);
    provisioningCase.Status = 'Accounts in Progress - Supportforce';
    insert provisioningCase;
    PF_NHW_PageService pageService = new PF_NHW_CasePickerPageService();
    Map<String, Object> pageinfo = pageService.getPageInformation(EMPLOYEE_TYPE_REGULAR, null);
    Map<String, Object> pageConfig = (Map<String, Object>) pageinfo.get('PAGE_CONFIG');
    List<PF_NHW_CasePickerPageService.CasePickerNewHire> newHires = (List<PF_NHW_CasePickerPageService.CasePickerNewHire>) pageConfig.get(
      'NH'
    );
    System.assertEquals(newHires.size(), 0);
  }

  //WD4S - if FTE provisioning case is in status new, then show it on landing page
  @isTest
  static void showValidCasesStatusFTE() {
    WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.createJobApp();
    WDR_Application__c defaultJobApplication = testdata.getDefaultJobApp();
    WDR_Job__c defaultJobReq = testdata.getDefaultJobReq();
    DefaultJobApplication.Start_Date__c = System.Today().addDays(16);

    Test.startTest();
    DefaultJobReq.Employment_Type__c = 'Regular';
    update DefaultJobReq;
    DefaultJobApplication.Candidate_Stage__c = 'Placement';
    update DefaultJobApplication;
    Test.stopTest();
    List<Case> cases = [SELECT Id, status FROM Case WHERE NHW_Job_Application__c = :DefaultJobApplication.id];
    cases[0].status = 'Closed';
    update cases;
    Case provisioningCase = PF_NHW_ProvisioningCaseStore.generateProvisioningCaseFromPreboardingCase(cases[0].Id);
    insert provisioningCase;
    PF_NHW_PageService pageService = new PF_NHW_CasePickerPageService();
    Map<String, Object> pageinfo = pageService.getPageInformation(EMPLOYEE_TYPE_REGULAR, null);
    Map<String, Object> pageConfig = (Map<String, Object>) pageinfo.get('PAGE_CONFIG');
    List<PF_NHW_CasePickerPageService.CasePickerNewHire> newHires = (List<PF_NHW_CasePickerPageService.CasePickerNewHire>) pageConfig.get(
      'NH'
    );
    System.assertEquals(newHires.size(), 1);
  }

  //WD4S - if contractor provisioning case is in status Accounts in Progress - Supportforce, then do not show it on landing page
  @isTest
  static void hideCasesWithStatusAccountInProgressContractor() {
    Test.startTest();

    Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
    provisioningCase.NHW_Employee_type__c = 'Contractor';
    provisioningCase.Contractor_Hire_Reason__c = 'Standard';
    provisioningCase.Resource_Type__c = 'Independent Contractor';
    insert provisioningCase;
    provisioningCase.Status = 'Accounts in Progress - Supportforce';
    update provisioningCase;
    PF_NHW_PageService pageService = new PF_NHW_CasePickerPageService();
    Map<String, Object> pageinfo = pageService.getPageInformation('contractor', null);
    Test.stopTest();
    Map<String, Object> pageConfig = (Map<String, Object>) pageinfo.get('PAGE_CONFIG');
    List<PF_NHW_CasePickerPageService.CasePickerNewHire> newHires = (List<PF_NHW_CasePickerPageService.CasePickerNewHire>) pageConfig.get(
      'NH'
    );
    System.assertEquals(newHires.size(), 0);
  }
  //WD4S - if contractor provisioning case status in new , then show it on landing page
  @isTest
  static void showValidCasesContractor() {
    Test.startTest();

    Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
    provisioningCase.NHW_Employee_type__c = 'Contractor';
    provisioningCase.Contractor_Hire_Reason__c = 'Standard';
    provisioningCase.Resource_Type__c = 'Independent Contractor';
    insert provisioningCase;
    PF_NHW_PageService pageService = new PF_NHW_CasePickerPageService();
    Map<String, Object> pageinfo = pageService.getPageInformation('contractor', null);
    Test.stopTest();
    Map<String, Object> pageConfig = (Map<String, Object>) pageinfo.get('PAGE_CONFIG');
    List<PF_NHW_CasePickerPageService.CasePickerNewHire> newHires = (List<PF_NHW_CasePickerPageService.CasePickerNewHire>) pageConfig.get(
      'NH'
    );
    System.assertEquals(newHires.size(), 1);
  }

  //for employeeviewandupdate show cases with Regular employement type
  @isTest
  static void showRegularEmployeeType() {
    WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.createJobApp();
    WDR_Application__c defaultJobApplication = testdata.getDefaultJobApp();
    WDR_Job__c defaultJobReq = testdata.getDefaultJobReq();
    DefaultJobApplication.Start_Date__c = System.Today().addDays(16);

    Test.startTest();
    DefaultJobReq.Employment_Type__c = 'Regular';
    update DefaultJobReq;
    DefaultJobApplication.Candidate_Stage__c = 'Placement';
    update DefaultJobApplication;
    Test.stopTest();
    List<Case> cases = [SELECT Id, status FROM Case WHERE NHW_Job_Application__c = :DefaultJobApplication.id];
    cases[0].status = 'Closed';
    update cases;
    Case provisioningCase = PF_NHW_ProvisioningCaseStore.generateProvisioningCaseFromPreboardingCase(cases[0].Id);
    provisioningCase.Email_Address__c = UserInfo.getUserEmail();
    insert provisioningCase;
    PF_NHW_PageService pageService = new PF_NHW_CasePickerPageService();
    Boolean caughtException = false;
    try {
      Map<String, Object> pageinfo = pageService.getPageInformation('employeeviewandupdate', null);
      Map<String, Object> pageConfig = (Map<String, Object>) pageinfo.get('PAGE_CONFIG');
      List<PF_NHW_CasePickerPageService.CasePickerNewHire> newHires = (List<PF_NHW_CasePickerPageService.CasePickerNewHire>) pageConfig.get(
        'NH'
      );
      System.assertEquals(newHires.size(), 1);
    } catch (Exception ex) {
      caughtException = true;
    }
    System.assert(!caughtException);
  }

  //for employeeviewandupdate hide cases with not Regular employement type
  @isTest
  static void hideOtherEmployeeType() {
    WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.createJobApp();
    WDR_Application__c defaultJobApplication = testdata.getDefaultJobApp();
    WDR_Job__c defaultJobReq = testdata.getDefaultJobReq();
    DefaultJobApplication.Start_Date__c = System.Today().addDays(16);

    Test.startTest();
    DefaultJobReq.Employment_Type__c = 'Intern';
    update DefaultJobReq;
    DefaultJobApplication.Candidate_Stage__c = 'Placement';
    update DefaultJobApplication;
    Test.stopTest();
    List<Case> cases = [SELECT Id, status FROM Case WHERE NHW_Job_Application__c = :DefaultJobApplication.id];
    cases[0].status = 'Closed';
    update cases;
    Case provisioningCase = PF_NHW_ProvisioningCaseStore.generateProvisioningCaseFromPreboardingCase(cases[0].Id);
    provisioningCase.Email_Address__c = UserInfo.getUserEmail();
    insert provisioningCase;
    PF_NHW_PageService pageService = new PF_NHW_CasePickerPageService();
    Boolean caughtException = false;
    try {
      Map<String, Object> pageinfo = pageService.getPageInformation('employeeviewandupdate', null);
      Map<String, Object> pageConfig = (Map<String, Object>) pageinfo.get('PAGE_CONFIG');
      pageConfig.get(
        'NH'
      );
    } catch (Exception ex) {
      caughtException = true;
    }
    System.assert(caughtException);
  }

  //validate when preboarding case is closed , then new hire is visible on home page of NHW
  @istest
  public static void validateFTENHWNotStartedCaseVisible() {
    WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.createJobApp();
    WDR_Application__c defaultJobApplication = testdata.getDefaultJobApp();
    Test.startTest();
    DefaultJobApplication.Start_Date__c = System.Today().addDays(16);
    DefaultJobApplication.Candidate_Stage__c = 'Placement';
    update DefaultJobApplication;
      Test.stopTest();
    Case preCase = [
      SELECT id, First_Name__c, Last_Name__c
      FROM Case
      WHERE RecordTypeId = :NHW_Util.getnhwPreBoardCaseRecordTypeId()
      LIMIT 1
    ];
    preCase.status = 'Closed';
    update preCase;
    PF_NHW_PageService pageService = new PF_NHW_CasePickerPageService();
    Map<String, Object> pageinfo = pageService.getPageInformation(EMPLOYEE_TYPE_REGULAR, null);
    Object compConfigList = pageinfo.get('PAGE_CONFIG');
    Map<String, Object> m = (Map<String, Object>) compConfigList;
    List<PF_NHW_CasePickerPageService.CasePickerNewHire> newHires = (List<PF_NHW_CasePickerPageService.CasePickerNewHire>) m.get(
      'NH'
    );
    System.assertEquals(newHires[0].caseId, preCase.id, 'New Hire found');
    System.assertEquals(newHires[0].name, preCase.First_Name__c + preCase.Last_Name__c, 'match name');
  }



  //validate when provisioning case is created (NHW was started), then new hire is visible
  @istest
  public static void validateFTENHWStartedCaseVisible() {
     WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.createJobApp();
    WDR_Application__c defaultJobApplication = testdata.getDefaultJobApp();
    Test.startTest();
    DefaultJobApplication.Start_Date__c = System.Today().addDays(16);
    DefaultJobApplication.Candidate_Stage__c = 'Placement';
    update DefaultJobApplication;
      Test.stopTest();
    Case preCase = [SELECT id FROM Case WHERE RecordTypeId = :NHW_Util.getnhwPreBoardCaseRecordTypeId() LIMIT 1];
    preCase.status = 'Closed';
    update preCase;
    Case provCase = PF_NHW_ProvisioningCaseStore.generateProvisioningCaseFromPreboardingCase(preCase.Id);
    insert provCase;
    PF_NHW_PageService pageService = new PF_NHW_CasePickerPageService();
    Map<String, Object> pageinfo = pageService.getPageInformation(EMPLOYEE_TYPE_REGULAR, null);
    Object compConfigList = pageinfo.get('PAGE_CONFIG');
    Map<String, Object> m = (Map<String, Object>) compConfigList;
    List<PF_NHW_CasePickerPageService.CasePickerNewHire> newHires = (List<PF_NHW_CasePickerPageService.CasePickerNewHire>) m.get(
      'NH'
    );
    System.assertEquals(newHires[0].caseId, provCase.id, 'Match case id');
    System.assertEquals(newHires[0].name, provCase.First_Name__c + provCase.Last_Name__c, 'Match name');
  }
}