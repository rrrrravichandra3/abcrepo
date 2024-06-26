@SuppressWarnings('PMD.CognitiveComplexity')
@isTest
public class NHWCaseTriggerHandler_Test {
  private static String STANDARD_BU = '0000';
  private static String STANDARD_CC = '1111';

  private static String BU_T_AND_P = '1234';
  private static String BU_FINANCE = '4567';
  private static String BU_IT = '9012';

  private static String CC_T_AND_P = '1472';
  private static String CC_FINANCE = '2583';
  private static String CC_IT = '6914';

  private static final String RECORD_TYPE_ALL_EXPENSE_CASES = 'All_Expense_Cases';
  private static final String RECORD_TYPE_NEW_HIRE_PROCCESS = 'New_Hire_Process';
  private static final String RECORD_TYPE_NEW_HIRE_PROCCESS_ONBOARDING = 'New_Hire_Process_Onboarding';
  private static final String RECORD_TYPE_NEW_HIRE_PROCCESS_ONBOARDING_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_NEW_HIRE_PROCCESS_ONBOARDING).getRecordTypeId();
  private static final String CASE_TYPE_EXPENSE_AMEX = 'Expense / Amex';
  private static final String RECORD_TYPE_CANDIDATE = 'Candidate';

  private static final String ORIGIN_CASE_AMER = 'Email to Case_AMER';
  private static final String ORIGIN_CASE_APAC = 'Email to Case_APAC';
  private static final String ORIGIN_CASE_EMEA = 'Email to Case_EMEA';
  private static final String ORIGIN_CASE_EXPENSE = 'Email to Case_Expense Notice Claims';

  private static final String MSG_NUMBER_OF_CASES_MISMATCH = 'Number of cases mismatch';

  private static List<TF2_Department__c> costCenters = new List<TF2_Department__c>{
    new TF2_Department__c(Name = CC_T_AND_P),
    new TF2_Department__c(Name = CC_FINANCE),
    new TF2_Department__c(Name = CC_IT)
  };

  private static List<Business_Unit__c> businessUnits = new List<Business_Unit__c>{
    new Business_Unit__c(Name = BU_T_AND_P, BU_Code__c = BU_T_AND_P),
    new Business_Unit__c(Name = BU_FINANCE, BU_Code__c = BU_FINANCE),
    new Business_Unit__c(Name = BU_IT, BU_Code__c = BU_IT)
  };

  @testSetup
  static void init() {
    NH_Settings__c nhs = new NH_Settings__c(
      NoOfDaysBeforeStartDateToSendRemindEmail__c = 15,
      Valid_AD_Email_Domains__c = 'salesforce.com',
      Disable_Jitterbit_Enable_S2S__c = false,
      Jitterbit_PF_To_SF_Service_URL__c = 'https://test-salesforce.jitterbit.net/PF_Service_Cloud__Onboarding-Dev/NHWCasesPFtoSF',
      JitterbitAuthText__c = 'c3JlZWRoYXIua2FydWtvbmRhQHNhbGVzZm9yY2UuY29tOjFSYW1yZWRkeTE='
    );
    insert nhs;
    
      Onboarding_Setting__c obs = new Onboarding_Setting__c(
          Candidate_Record_Type__c = NHW_Util.getcandidateContactRecordTypeId(),
          Onboarding_Record_Type_Id__c = RECORD_TYPE_NEW_HIRE_PROCCESS_ONBOARDING_ID
      );
    insert obs;

    NHW_DP_Cost_Centers__c buTAndP = new NHW_DP_Cost_Centers__c(
      Name = 'BU-' + BU_T_AND_P,
      Business_Unit_Id__c = BU_T_AND_P,
      Profile_Name__c = 'T&P'
    );
    NHW_DP_Cost_Centers__c buFinance = new NHW_DP_Cost_Centers__c(
      Name = 'BU-' + BU_FINANCE,
      Business_Unit_Id__c = BU_FINANCE,
      Profile_Name__c = 'Finance'
    );
    NHW_DP_Cost_Centers__c buIT = new NHW_DP_Cost_Centers__c(
      Name = 'BU-' + BU_IT,
      Business_Unit_Id__c = BU_IT,
      Profile_Name__c = 'IT'
    );

    NHW_DP_Cost_Centers__c ccTAndP = new NHW_DP_Cost_Centers__c(
      Name = 'CC-' + CC_T_AND_P,
      Cost_Centers_id__c = CC_T_AND_P,
      Profile_Name__c = 'T&P'
    );
    NHW_DP_Cost_Centers__c ccFinance = new NHW_DP_Cost_Centers__c(
      Name = 'CC-' + CC_FINANCE,
      Cost_Centers_id__c = CC_FINANCE,
      Profile_Name__c = 'Finance'
    );
    NHW_DP_Cost_Centers__c ccIT = new NHW_DP_Cost_Centers__c(
      Name = 'CC-' + CC_IT,
      Cost_Centers_id__c = CC_IT,
      Profile_Name__c = 'IT'
    );

    List<NHW_DP_Cost_Centers__c> ccsbus = new List<NHW_DP_Cost_Centers__c>{
      buTAndP,
      buFinance,
      buIT,
      ccTAndP,
      ccFinance,
      ccIT
    };
    insert ccsbus;

    insert costCenters;
    insert businessUnits;

    Contact con = new Contact(
      recordtypeid = NHW_Util.getCandidateContactRecordTypeId(),
      Email = 'SalesForceUAT_candidate@test.com',
      FirstName = 'test',
      LastName = 'Candidate',
      MailingCountry = 'Candidate Country',
      MailingState = 'CA',
      EmployeeNumber__c = '12345'
    );
    insert con;
  }

  static testMethod void fteFlowPreboardingCaseTest() {
    Contact contactRecord = [
      SELECT Id, EmployeeNumber__c
      FROM Contact
      WHERE Email = 'SalesForceUAT_candidate@test.com'
    ];

    Case tAndpCase = new Case();
    tAndpCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
      .get(RECORD_TYPE_NEW_HIRE_PROCCESS)
      .getRecordTypeId();
    tAndpCase.Cost_Center_NHW__c = CC_T_AND_P;
    tAndpCase.Business_Unit_NHW__c = BU_T_AND_P;
    tAndpCase.NHW_Employee__c = contactRecord.Id;

    Case financeCase = new Case();
    financeCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
      .get(RECORD_TYPE_NEW_HIRE_PROCCESS)
      .getRecordTypeId();
    financeCase.Cost_Center_NHW__c = CC_FINANCE;
    financeCase.Business_Unit_NHW__c = BU_FINANCE;
    financeCase.NHW_Employee__c = contactRecord.Id;

    Case itCase = new Case();
    itCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
      .get(RECORD_TYPE_NEW_HIRE_PROCCESS)
      .getRecordTypeId();
    itCase.Cost_Center_NHW__c = CC_IT;
    itCase.Business_Unit_NHW__c = BU_IT;
    itCase.NHW_Employee__c = contactRecord.Id;

    List<Case> cases = new List<Case>{ tAndpCase, financeCase, itCase };

    Test.startTest();
    insert cases;

    cases = [
      SELECT NH_Profile__c, NH_Employee_Id__c
      FROM Case
      WHERE Id = :cases[0].Id OR Id = :cases[1].Id OR Id = :cases[2].Id
    ];

    System.assertEquals(3, cases.size(), MSG_NUMBER_OF_CASES_MISMATCH);

    for (Case c : cases) {
      System.assert(
        (c.Id == tAndpCase.Id &&
        c.NH_Profile__c == 'T&P') ||
        (c.Id == financeCase.Id &&
        c.NH_Profile__c == 'Finance') ||
        (c.Id == itCase.Id &&
        c.NH_Profile__c == 'IT')
      );
      System.assert(c.NH_Employee_Id__c == '12345');
      c.NH_profile__c = '';
    }

    update cases;

    cases = [SELECT NH_Profile__c FROM Case WHERE Id = :cases[0].Id OR Id = :cases[1].Id OR Id = :cases[2].Id];

    for (Case c : cases) {
      System.assert(
        ((c.Id == tAndpCase.Id &&
        c.NH_Profile__c == 'T&P') ||
        (c.Id == financeCase.Id &&
        c.NH_Profile__c == 'Finance') ||
        (c.Id == itCase.Id &&
        c.NH_Profile__c == 'IT')),
        'Expecting profile to be populated in update event'
      );
    }

    Test.stopTest();
  }

  static testMethod void fteFlowProvisioningCaseTest() {
    Contact contactRecord = [
      SELECT Id, EmployeeNumber__c
      FROM Contact
      WHERE Email = 'SalesForceUAT_candidate@test.com'
    ];
    Case tAndpCase = new Case();
    tAndpCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
      .get(RECORD_TYPE_NEW_HIRE_PROCCESS_ONBOARDING)
      .getRecordTypeId();
    tAndpCase.Cost_Center_NHW__c = CC_T_AND_P;
    tAndpCase.Business_Unit_NHW__c = BU_T_AND_P;
    tAndpCase.NHW_Employee__c = contactRecord.Id;

    Case financeCase = new Case();
    financeCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
      .get(RECORD_TYPE_NEW_HIRE_PROCCESS_ONBOARDING)
      .getRecordTypeId();
    financeCase.Cost_Center_NHW__c = CC_FINANCE;
    financeCase.Business_Unit_NHW__c = BU_FINANCE;
    financeCase.NHW_Employee__c = contactRecord.Id;

    Case itCase = new Case();
    itCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
      .get(RECORD_TYPE_NEW_HIRE_PROCCESS_ONBOARDING)
      .getRecordTypeId();
    itCase.Cost_Center_NHW__c = CC_IT;
    itCase.Business_Unit_NHW__c = BU_IT;
    itCase.NHW_Employee__c = contactRecord.Id;

    List<Case> cases = new List<Case>{ tAndpCase, financeCase, itCase };

    Test.startTest();
    insert cases;

    cases = [
      SELECT NH_Profile__c, NH_Employee_Id__c
      FROM Case
      WHERE Id = :cases[0].Id OR Id = :cases[1].Id OR Id = :cases[2].Id
    ];

    System.assertEquals(3, cases.size(), MSG_NUMBER_OF_CASES_MISMATCH);

    for (Case c : cases) {
      System.assertNotEquals(
        true,
        (c.Id == tAndpCase.Id &&
        c.NH_Profile__c == 'T&P') &&
        (c.Id == financeCase.Id &&
        c.NH_Profile__c == 'Finance') &&
        (c.Id == itCase.Id &&
        c.NH_Profile__c == 'IT')
      );
      System.assert(c.NH_Employee_Id__c == '12345');
    }

    Test.stopTest();
  }

  static testMethod void contractorFlowProvisioningCaseTest() {
    List<Business_Unit__c> bus = [
      SELECT Name
      FROM Business_Unit__c
      WHERE Name IN :new List<String>{ BU_T_AND_P, BU_FINANCE, BU_IT }
    ];
    List<TF2_Department__c> ccs = [
      SELECT Name
      FROM TF2_Department__c
      WHERE Name IN :new List<String>{ CC_T_AND_P, CC_FINANCE, CC_IT }
    ];

    Case tAndpCase = new Case();
    tAndpCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
      .get(RECORD_TYPE_NEW_HIRE_PROCCESS_ONBOARDING)
      .getRecordTypeId();
    tAndpCase.NHW_Cost_Center__c = ccs[0].Name == CC_T_AND_P
      ? ccs[0].Id
      : ccs[1].Name == CC_T_AND_P ? ccs[1].Id : ccs[2].Name == CC_T_AND_P ? ccs[2].Id : null;
    tAndpCase.NHW_Business_Unit__c = bus[0].Name == BU_T_AND_P
      ? bus[0].Id
      : bus[1].Name == BU_T_AND_P ? bus[1].Id : bus[2].Name == BU_T_AND_P ? bus[2].Id : null;

    Case financeCase = new Case();
    financeCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
      .get(RECORD_TYPE_NEW_HIRE_PROCCESS_ONBOARDING)
      .getRecordTypeId();
    financeCase.NHW_Cost_Center__c = ccs[0].Name == CC_FINANCE
      ? ccs[0].Id
      : ccs[1].Name == CC_FINANCE ? ccs[1].Id : ccs[2].Name == CC_FINANCE ? ccs[2].Id : null;
    financeCase.NHW_Business_Unit__c = bus[0].Name == BU_FINANCE
      ? bus[0].Id
      : bus[1].Name == BU_FINANCE ? bus[1].Id : bus[2].Name == BU_FINANCE ? bus[2].Id : null;

    Case itCase = new Case();
    itCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
      .get(RECORD_TYPE_NEW_HIRE_PROCCESS_ONBOARDING)
      .getRecordTypeId();
    itCase.NHW_Cost_Center__c = ccs[0].Name == CC_IT
      ? ccs[0].Id
      : ccs[1].Name == CC_IT ? ccs[1].Id : ccs[2].Name == CC_IT ? ccs[2].Id : null;
    itCase.NHW_Business_Unit__c = bus[0].Name == BU_IT
      ? bus[0].Id
      : bus[1].Name == BU_IT ? bus[1].Id : bus[2].Name == BU_IT ? bus[2].Id : null;

    List<Case> cases = new List<Case>{ tAndpCase, financeCase, itCase };

    insert cases;

    cases = [SELECT NH_Profile__c FROM Case WHERE Id = :cases[0].Id OR Id = :cases[1].Id OR Id = :cases[2].Id];

    System.assertEquals(3, cases.size(), MSG_NUMBER_OF_CASES_MISMATCH);

    for (Case c : cases) {
      System.assertNotEquals(
        true,
        (c.Id == tAndpCase.Id &&
        c.NH_Profile__c == 'T&P') &&
        (c.Id == financeCase.Id &&
        c.NH_Profile__c == 'Finance') &&
        (c.Id == itCase.Id &&
        c.NH_Profile__c == 'IT')
      );
    }
  }

  //WD4S- When both valid Worker id and Email are updated on case , status should be changed to 'Closed'
  @isTest
  static void updateCasesWithValidEmailAndvalidWorkerId() {
    Case cse = new Case(Status = 'Open');
    cse.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
      .get(RECORD_TYPE_NEW_HIRE_PROCCESS)
      .getRecordTypeId();
    insert cse;
    Contact contactRecord = [
      SELECT Id, EmployeeNumber__c
      FROM Contact
      WHERE Email = 'SalesForceUAT_candidate@test.com'
    ];
    Test.startTest();
    cse.NHW_Employee__c = contactRecord.Id;
    cse.Email_Address__c = 'testEmp@salesforce.com';
    update cse;
    Test.stopTest();
    cse = [SELECT id, status, IsClosed FROM Case WHERE id = :cse.id];
    System.assert(cse.IsClosed);
  }

  //WD4S- When valid Worker id is not updated on case , status should be default - 'Accounts in Progress - Peopleforce'
  @isTest
  static void updateCasesWithValidEmailAndInvalidWorkerId() {
    Case cse = new Case();
    cse.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
      .get(RECORD_TYPE_NEW_HIRE_PROCCESS)
      .getRecordTypeId();
    Test.startTest();
    insert cse;
    cse.NHW_Employee__c = null;
    cse.Email_Address__c = 'testEmp@salesforce.com';
    update cse;
    Test.stopTest();
    cse = [SELECT id, status, IsClosed FROM Case WHERE id = :cse.id];
    System.assert(!cse.IsClosed);
    System.assertEquals('Accounts in Progress - Peopleforce', cse.Status);
  }

  //WD4S- When valid email is not updated on case , status should be default - 'Accounts in Progress - Peopleforce'
  @isTest
  static void updateCasesWithInvalidEmailAndWorkerId() {
    Case cse = new Case();
    cse.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_NEW_HIRE_PROCCESS).getRecordTypeId();
    Test.startTest();
    insert cse;
    Contact contactRecord = [
      SELECT Id, EmployeeNumber__c
      FROM Contact
      WHERE Email = 'SalesForceUAT_candidate@test.com'
    ];
    cse.NHW_Employee__c = contactRecord.id;
    cse.Email_Address__c = 'testEmp@notsalesforce.com';
    update cse;
    Test.stopTest();
    cse = [SELECT id, status, IsClosed FROM Case WHERE id = :cse.id];
    System.assert(!cse.IsClosed);
    System.assertEquals('Accounts in Progress - Peopleforce', cse.Status);
  }
    
  static testMethod void testUpdateSSTUserClone() {
        Contact contactRecord = [
            SELECT Id, EmployeeNumber__c
            FROM Contact
            WHERE Email = 'SalesForceUAT_candidate@test.com'
        ];
        Case tAndpCase = new Case();
        tAndpCase.RecordTypeId = RECORD_TYPE_NEW_HIRE_PROCCESS_ONBOARDING_ID;
        tAndpCase.Cost_Center_NHW__c = CC_T_AND_P;
        tAndpCase.Business_Unit_NHW__c = BU_T_AND_P;    
        tAndpCase.NHW_Employee__c = contactRecord.Id;
        tAndpCase.NHW_Access_Code__c = '[{"accessType":"Force.com Org & Application","accessDetailList":[{"userToClone":"Chinmai Konakalla","sfSSt":null,"org62SST":"Name: Amarachi Otisi; UserName: aotisi@salesforce.com.devpro173; email:aotisi@salesforce.com","name":"Org62","isc":"Internal Salesforce.com App New Hire Access Request","gusSST":null,"contractorSST":null,"category":"Employee Essentials"},{"userToClone":"pvakkalanka@supportforce.com.spfqa15","sfSSt":"Name: Pooja Vakkalanka; UserName: pvakkalanka@supportforce.com.spfqa15; email:pvakkalanka@salesforce.com","org62SST":null,"name":"Supportforce","isc":"Internal Salesforce.com App New Hire Access Request","gusSST":null,"contractorSST":null,"category":"Productivity Essentials"}]},{"accessType":"Cloud Application (Non Force.com)","accessDetailList":[]},{"accessType":"Mobile","accessDetailList":[]}]';
        tAndpCase.status = 'Sent to Supportforce';
        Test.startTest();
        insert tAndpCase;
        tAndpCase.NH_Profile__c = 'T&P';
        update tAndpCase;
        Test.stopTest();
    }
}