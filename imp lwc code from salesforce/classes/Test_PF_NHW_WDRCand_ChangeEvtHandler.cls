@istest
public class Test_PF_NHW_WDRCand_ChangeEvtHandler {
  static id preboardingCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
    .get('New Hire Process')
    .getRecordTypeId();
  static id CWContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
    .get('Contractor')
    .getRecordTypeId();

  @testsetup
  static void setup() {
    NH_Settings__c nhs = new NH_Settings__c(
      NoOfDaysBeforeStartDateToSendRemindEmail__c = 15,
      Valid_AD_Email_Domains__c = 'salesforce.com'
    );
    insert nhs;

    WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.createJobApp();
    WDR_Application__c DefaultJobApplication = testdata.getDefaultJobApp();
    WDR_Candidate__c DefaultCandidate = testdata.getDefaultCandidate();
    Test.enableChangeDataCapture();
    DefaultCandidate.Employee_Number__c = '123456';
    update DefaultCandidate;
    Test.getEventBus().deliver();
    Contact CWContact = new Contact(
      recordtypeid = CWContactRecordTypeId,
      EmployeeNumber__c = '123446',
      LastName = 'OldContact',
      Email = 'testCWcontact@salesforce.com'
    );
    insert CWContact;
  }

  //W-11625888 OKTA - Close preboarding case when worker id is available on WD candidate
  //AS part of WD4S - For conversions, the worker id and email will be available on contact on conversion date ,
  // We want to close the preboarding case with WHENEVER it is available on WD candidate after case creation
  @istest
  static void verifyCaseUpdateonWorkerIdUpdate() {
    WDR_Application__c jobApp = [SELECT id FROM WDR_Application__c LIMIT 1];
    insert new Case(recordTypeid = preboardingCaseRecordTypeId, NHW_Job_Application__c = jobApp.id);
    Contact CWCont = [
      SELECT id, Email, EmployeeNumber__c
      FROM Contact
      WHERE recordtypeid = :CWContactRecordTypeId
      LIMIT 1
    ];
    Test.setCreatedDate(CWCont.Id, Date.today().addDays(-1));
    Test.startTest();
    Test.enableChangeDataCapture();
    WDR_Candidate__c w = [SELECT id, Employee_Number__c FROM WDR_Candidate__c LIMIT 1];
    w.Employee_Number__c = CWCont.EmployeeNumber__c;
    update w;
    Test.getEventBus().deliver();
    Test.stopTest();
    Case cse = [
      SELECT id, Email_address__c, NH_Employee_Id__c, IsClosed
      FROM case
      WHERE recordtypeid = :preboardingCaseRecordTypeId
      LIMIT 1
    ];
    System.assertEquals(cse.Email_address__c, CWCont.Email, 'Correct email did not flow to Case');
    System.assertEquals(cse.NH_Employee_Id__c, w.Employee_Number__c, 'Correct Worker Id did not flow to Case');
    System.assert(cse.IsClosed, 'Preboarding Case did not Close');
  }

  //verify when non-Existing workerId is updated on WDR Candidate, case will remain open
  @istest
  static void verifyCaseUpdateonInvalidWorkerIdUpdate() {
    WDR_Application__c jobApp = [SELECT id FROM WDR_Application__c LIMIT 1];
    insert new Case(recordTypeid = preboardingCaseRecordTypeId, NHW_Job_Application__c = jobApp.id);
    Test.startTest();
    Test.enableChangeDataCapture();
    WDR_Candidate__c w = [SELECT id, Employee_Number__c FROM WDR_Candidate__c LIMIT 1];
    w.Employee_Number__c = '1234499'; //worker id not found
    update w;
    Test.getEventBus().deliver();
    Test.stopTest();
    Case cse = [
      SELECT id, Email_address__c, NH_Employee_Id__c, IsClosed
      FROM case
      WHERE recordtypeid = :preboardingCaseRecordTypeId
      LIMIT 1
    ];
    Contact CWCont = [SELECT id, Email FROM Contact WHERE recordtypeid = :CWContactRecordTypeId LIMIT 1];
    System.assertNotEquals(cse.Email_address__c, CWCont.Email, 'Correct email Should not have flowed to Case');
    System.assert(!cse.IsClosed, 'Preboarding Case should not have Close');
  }

  //OKTA - Close preboarding case when worker id is available on WD candidate
  //AS part of WD4S CW->FTE conversions - We want to close the preboarding case when it is created and
  //worker id is available on WDR Candidate which matches old Contact
  @istest
  static void verifyCaseCreateonWorkerIdAvailable() {
    WDR_Candidate__c wCand = [SELECT id, Employee_Number__c FROM WDR_Candidate__c LIMIT 1];
    Contact CWCont = [
      SELECT id, Email, EmployeeNumber__c
      FROM Contact
      WHERE recordtypeid = :CWContactRecordTypeId
      LIMIT 1
    ];
    Test.setCreatedDate(CWCont.Id, Date.today().addDays(-1));
    WDR_Application__c jobApp = [SELECT id, Candidate_Stage__c FROM WDR_Application__c LIMIT 1];
    wCand.Employee_Number__c = CWCont.EmployeeNumber__c;
    update wCand;
        Test.startTest();
    jobApp.Candidate_Stage__c = 'Placement';
    update jobApp;
    Test.stopTest();
    Case cse = [
      SELECT id, Email_address__c, NH_Employee_Id__c, status, IsClosed
      FROM case
      WHERE recordtypeid = :preboardingCaseRecordTypeId
      LIMIT 1
    ];
    System.debug(cse.Email_address__c + cse.NH_Employee_Id__c + cse.Status);

    System.assertEquals(cse.Email_address__c, CWCont.Email, 'Correct email did not flow to Case');
    System.assertEquals(cse.NH_Employee_Id__c, wCand.Employee_Number__c, 'Correct Worker Id did not flow to Case');
    System.assert(cse.IsClosed, 'Preboarding Case did not Close');
  }

  //OKTA - Close preboarding case when worker id is available on WD candidate
  //AS part of WD4S CW->FTE conversions - We want don't want to close the preboarding case when it is created and
  //worker id is available on WDR Candidate which does not match old contact
  @istest
  static void verifyCaseCreateonInvalidWorkerIdAvailable() {
    WDR_Candidate__c wCand = [SELECT id, Employee_Number__c FROM WDR_Candidate__c LIMIT 1];
    Contact CWCont = [
      SELECT id, Email, EmployeeNumber__c
      FROM Contact
      WHERE recordtypeid = :CWContactRecordTypeId
      LIMIT 1
    ];
    WDR_Application__c jobApp = [SELECT id, Candidate_Stage__c FROM WDR_Application__c LIMIT 1];
    Test.startTest();
    wCand.Employee_Number__c = null;
    update wCand;
    jobApp.Candidate_Stage__c = 'Placement';
    update jobApp;
    Test.stopTest();
    Case cse = [
      SELECT id, Status, Email_address__c, NH_Employee_Id__c, IsClosed
      FROM case
      WHERE recordtypeid = :preboardingCaseRecordTypeId
      LIMIT 1
    ];
    System.assertNotEquals(cse.Email_address__c, CWCont.Email, 'Correct email should not flow to Case');
    System.assert(!cse.IsClosed, 'Preboarding Case should not have Close');
  }
}