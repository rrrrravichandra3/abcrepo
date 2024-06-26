@istest
public class Test_PF_NHW_CreateCasesAsync {
  static final string STAGE = 'Placement';
  static final string CASE_CREATE_ASSERT_MSG = 'Case Created';
  @istest
  static void testPreboardingCaseCreation() {
    WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.createJobApp();
    WDR_Application__c DefaultJobApplication = testdata.getDefaultJobApp();
    DefaultJobApplication.Candidate_Stage__c = STAGE;
    Map<id, WDR_Application__c> jobAppMap = new Map<id, WDR_Application__c>();
    jobAppMap.put(DefaultJobApplication.id, DefaultJobApplication);
    Test.startTest();
    NHW_CreateCasesAsync cls = new NHW_CreateCasesAsync(JobAppMap);
    System.enqueueJob(cls);
    EventBus.publish(
                    new PF_Logging_Channel__e(
                    ApplicationName__c = 'NHW',
                    LogLevel__c = 'Error',
                    //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                    ErrorType__c = 'Error',
                    Stack_Trace__c = 'NHW_CreateCasesAsync',
                    Message__c = 'ErrorMessage',
                    Error__c = 'Error Description - Test Class'
                    )
                );
    Test.getEventBus().deliver();
    Test.stopTest();
    List<Case> c = [SELECT id FROM case];
    System.AssertEquals(c.size(), 1, 'Case not created');
  }

  @istest
  static void testPreboardingCaseCreation_NullCandidate() {
    WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.createJobApp();
    WDR_Application__c DefaultJobApplication = testdata.getDefaultJobApp();
    DefaultJobApplication.Candidate_Stage__c = STAGE;
    DefaultJobApplication.Candidate__c = null;
    Map<id, WDR_Application__c> jobAppMap = new Map<id, WDR_Application__c>();
    jobAppMap.put(DefaultJobApplication.id, DefaultJobApplication);
    Test.startTest();
    NHW_CreateCasesAsync cls = new NHW_CreateCasesAsync(JobAppMap);
    System.enqueueJob(cls);
    EventBus.publish(
                    new PF_Logging_Channel__e(
                    ApplicationName__c = 'NHW',
                    LogLevel__c = 'Error',
                    //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                    ErrorType__c = 'Error',
                    Stack_Trace__c = 'NHW_CreateCasesAsync',
                    Message__c = 'ErrorMessage',
                    Error__c = 'Error Description - Test Class'
                    )
                );
    Test.getEventBus().deliver();
    Test.stopTest();
    List<Case> c = [SELECT id FROM case];
    System.AssertEquals(c.size(), 0, CASE_CREATE_ASSERT_MSG);
  }

  @istest
  static void testPreboardingCaseCreation_NullJob() {
    WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.createJobApp();
    WDR_Application__c DefaultJobApplication = testdata.getDefaultJobApp();
    DefaultJobApplication.Candidate_Stage__c = STAGE;
    DefaultJobApplication.Job__c = null;
    Map<id, WDR_Application__c> jobAppMap = new Map<id, WDR_Application__c>();
    jobAppMap.put(DefaultJobApplication.id, DefaultJobApplication);
    Test.startTest();
    NHW_CreateCasesAsync cls = new NHW_CreateCasesAsync(JobAppMap);
    System.enqueueJob(cls);
    EventBus.publish(
                    new PF_Logging_Channel__e(
                    ApplicationName__c = 'NHW',
                    LogLevel__c = 'Error',
                    //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                    ErrorType__c = 'Error',
                    Stack_Trace__c = 'NHW_CreateCasesAsync',
                    Message__c = 'ErrorMessage',
                    Error__c = 'Error Description - Test Class'
                    )
                );
    Test.getEventBus().deliver();
    Test.stopTest();
    List<Case> c = [SELECT id FROM case];
    System.AssertEquals(c.size(), 0, CASE_CREATE_ASSERT_MSG);
  }

  @istest
  static void testPreboardingCaseCreation_InvalidJob() {
    WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.createJobApp();
    WDR_Application__c DefaultJobApplication = testdata.getDefaultJobApp();
    DefaultJobApplication.Candidate_Stage__c = STAGE;
    WDR_Job__c job = testdata.getDefaultJobReq();
    job.Company__c = null;
    Map<id, WDR_Application__c> jobAppMap = new Map<id, WDR_Application__c>();
    jobAppMap.put(DefaultJobApplication.id, DefaultJobApplication);
    Test.startTest();
    update DefaultJobApplication;
    update job;
    NHW_CreateCasesAsync cls = new NHW_CreateCasesAsync(JobAppMap);
    System.enqueueJob(cls);
    EventBus.publish(
                    new PF_Logging_Channel__e(
                    ApplicationName__c = 'NHW',
                    LogLevel__c = 'Error',
                    //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                    ErrorType__c = 'Error',
                    Stack_Trace__c = 'NHW_CreateCasesAsync',
                    Message__c = 'ErrorMessage',
                    Error__c = 'Error Description - Test Class'
                    )
                );
    Test.getEventBus().deliver();
    Test.stopTest();
    List<Case> c = [SELECT id FROM case];
    System.AssertEquals(c.size(), 0, CASE_CREATE_ASSERT_MSG);
  }

  @istest
  static void testPreboardingCaseCreation_InvalidBuSite() {
    WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.createJobApp();
    WDR_Application__c DefaultJobApplication = testdata.getDefaultJobApp();
    DefaultJobApplication.Candidate_Stage__c = STAGE;
    DefaultJobApplication.Business_Site__c = null;
    DefaultJobApplication.Start_Date__c = Date.today().addDays(16);
    Map<id, WDR_Application__c> jobAppMap = new Map<id, WDR_Application__c>();
    jobAppMap.put(DefaultJobApplication.id, DefaultJobApplication);
    Test.startTest();
      try {
          	update DefaultJobApplication;
    		NHW_CreateCasesAsync cls = new NHW_CreateCasesAsync(JobAppMap);
    		System.enqueueJob(cls);
      } catch (Exception e) {
          
          System.debug(e.getMessage());
      }
    EventBus.publish(
                    new PF_Logging_Channel__e(
                    ApplicationName__c = 'NHW',
                    LogLevel__c = 'Error',
                    //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                    ErrorType__c = 'Error',
                    Stack_Trace__c = 'NHW_CreateCasesAsync',
                    Message__c = 'ErrorMessage',
                    Error__c = 'Error Description - Test Class'
                    )
                );
    Test.getEventBus().deliver();
    
    Test.stopTest();
    List<Case> c = [SELECT id FROM case];
    System.AssertEquals(c.size(), 0, CASE_CREATE_ASSERT_MSG);
  }

  @istest
  static void testPreboardingCaseCreation_InvalidStartDate() {
    WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.createJobApp();
    WDR_Application__c DefaultJobApplication = testdata.getDefaultJobApp();
    DefaultJobApplication.Candidate_Stage__c = STAGE;
    DefaultJobApplication.start_date__c = Date.today().addDays(16);
    DefaultJobApplication.Business_Site__c = null;
    Map<id, WDR_Application__c> jobAppMap = new Map<id, WDR_Application__c>();
    jobAppMap.put(DefaultJobApplication.id, DefaultJobApplication);
      Test.startTest();
    try {
          	update DefaultJobApplication;
    		NHW_CreateCasesAsync cls = new NHW_CreateCasesAsync(JobAppMap);
    		System.enqueueJob(cls);
      } catch (Exception e) {
          System.debug(e.getMessage());
      }
    EventBus.publish(
                    new PF_Logging_Channel__e(
                    ApplicationName__c = 'NHW',
                    LogLevel__c = 'Error',
                    //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                    ErrorType__c = 'Error',
                    Stack_Trace__c = 'NHW_CreateCasesAsync',
                    Message__c = 'ErrorMessage',
                    Error__c = 'Error Description - Test Class'
                    )
                );
    Test.getEventBus().deliver();
    Test.stopTest();
    List<Case> c = [SELECT id FROM case];
    System.AssertEquals(c.size(), 0, CASE_CREATE_ASSERT_MSG);
  }

  @istest
  static void testPreboardingCaseCreation_InvalidCountry() {
    WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.createJobApp();
    WDR_Application__c DefaultJobApplication = testdata.getDefaultJobApp();
    DefaultJobApplication.Candidate_Stage__c = STAGE;
    Map<id, WDR_Application__c> jobAppMap = new Map<id, WDR_Application__c>();
    WDR_Candidate__c cand = testdata.getDefaultCandidate();
    cand.Mailing_City__c = null;
    jobAppMap.put(DefaultJobApplication.id, DefaultJobApplication);
    Test.startTest();
    TF2_Business_Site__c busite = [SELECT id, city__c FROM TF2_Business_Site__c];
    buSite.city__c = 'Remote City';
    update buSite;
    update cand;
    Onboarding_Setting__c settings = [SELECT id, Mailing_Country_to_Exclude_For_NHW__c FROM Onboarding_Setting__c];
    settings.Mailing_Country_to_Exclude_For_NHW__c = 'US';
    update settings;
    update DefaultJobApplication;
    NHW_CreateCasesAsync cls = new NHW_CreateCasesAsync(JobAppMap);
    System.enqueueJob(cls);
    EventBus.publish(
                    new PF_Logging_Channel__e(
                    ApplicationName__c = 'NHW',
                    LogLevel__c = 'Error',
                    //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                    ErrorType__c = 'Error',
                    Stack_Trace__c = 'NHW_CreateCasesAsync',
                    Message__c = 'ErrorMessage',
                    Error__c = 'Error Description - Test Class'
                    )
                );
    Test.getEventBus().deliver();
    Test.stopTest();
    List<Case> c = [SELECT id FROM case];
    System.AssertEquals(c.size(), 0, CASE_CREATE_ASSERT_MSG);
  }

  @istest
  static void testPreboardingCaseCreation_InvalidEmployee() {
    Test.startTest();
    List<Case> c = new List<Case>();
    c.add(new Case());
    NHW_CreateCasesAsync cls = new NHW_CreateCasesAsync(c);
    System.enqueueJob(cls);
    Test.stopTest();
    List<Case> cC = [SELECT id FROM case];
    System.AssertEquals(cC.size(), 0, CASE_CREATE_ASSERT_MSG);
  }
   
}