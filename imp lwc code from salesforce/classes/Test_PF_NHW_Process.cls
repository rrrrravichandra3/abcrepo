@isTest
public class Test_PF_NHW_Process {

  private static final String NEW_HIRE_WIZARD = 'New Hire Wizard';
  private static final String PACKAGE_DELIVERY = 'Package Delivery';
  private static final String MAIL_SERVICES = 'Mail Services';

  @TestSetup
  private static void makeData() {
    Case ca;
    string emailId = UserInfo.getUserEmail();
    RecordType employeeRT = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Employee' LIMIT 1];
    Contact con = new Contact(
      FirstName = 'TestMailApp',
      LastName = 'TestLast',
      Email = emailId,
      RecordTypeId = employeeRT.Id
    );
    insert con;
    Contact con2 = new Contact(
      FirstName = 'TestMailApptest',
      LastName = 'TestLasttest',
      Email = emailId,
      RecordTypeId = employeeRT.Id,
      ES_DJC_Is_Manager__c = true
    );
    insert con2;
    Delegate__c delegate = new Delegate__c(Delegate__c = con.Id, Type__c = NEW_HIRE_WIZARD, Manager__c = con2.Id);
    insert delegate;
    ca = new Case(
      contactId = con.Id,
      origin = PACKAGE_DELIVERY,
      NHW_Page_Number__c = 2,
      Type = MAIL_SERVICES,
      ES_DJC_Topic__c = PACKAGE_DELIVERY,
      NHW_Employee_Type__c = 'relocation',
      REWS_Received_Location__c = 'Landmark',
      REWS_Sender__c = 'Amazon',
      REWS_Carrier__c = 'USPS',
      REWS_Oversized__c = true
    );
    insert ca;
    ca = [
      SELECT
        id,
        contactId,
        NHW_Employee_Type__c,
        CreatedById,
        RecordTypeId,
        NHW_Page_Number__c,
        NHW_Job_Application__r.Job__r.Hiring_Manager__c
      FROM Case
      WHERE id = :ca.Id
    ];
    PF_NHW_ProcessHandler.CaseProcessInformation caseInfo = PF_NHW_ProcessHandler.getProcessInformation(ca);
    System.assertEquals(caseInfo.currentStep, ca.NHW_Page_Number__c);
  }
  private static testMethod void moveCaseBackwardTest() {
    Case ca;
    string emailId = UserInfo.getUserEmail();
    RecordType employeeRT = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Employee' LIMIT 1];
    Contact con = new Contact(
      FirstName = 'TestMailApp',
      LastName = 'TestLast',
      Email = emailId,
      RecordTypeId = employeeRT.Id
    );
    insert con;
    User u = [SELECT Id, Email FROM User WHERE Id = :UserInfo.getUserId()];
    u.Contact = con;
    update u;
    Contact con2 = new Contact(
      FirstName = 'TestMailApptest',
      LastName = 'TestLasttest',
      Email = emailId,
      RecordTypeId = employeeRT.Id,
      ES_DJC_Is_Manager__c = true
    );
    insert con2;
    Delegate__c delegate = new Delegate__c(Delegate__c = con.Id, Type__c = NEW_HIRE_WIZARD, Manager__c = con2.Id);
    insert delegate;
    ca = new Case(
      contactId = con.Id,
      origin = PACKAGE_DELIVERY,
      NHW_Page_Number__c = 2,
      Type = MAIL_SERVICES,
      ES_DJC_Topic__c = PACKAGE_DELIVERY,
      NHW_Employee_Type__c = 'relocation',
      REWS_Received_Location__c = 'Landmark',
      REWS_Sender__c = 'Amazon',
      REWS_Carrier__c = 'USPS',
      REWS_Oversized__c = true
    );
    insert ca;
    ca = [
      SELECT
        id,
        contactId,
        NHW_Employee_Type__c,
        CreatedById,
        RecordTypeId,
        NHW_Page_Number__c,Contractor_Hire_Reason__c,
        NHW_Job_Application__r.Job__r.Hiring_Manager__c
      FROM Case
      WHERE id = :ca.Id
    ];
    PF_NHW_ProcessHandler.moveCaseBackward(ca);
    ca.NHW_Page_Number__c = 4;
    ca.NHW_Employee_Type__c = 'contractor';
    System.assertEquals(PF_NHW_Process.getPreviousStep(ca), ca.NHW_Page_Number__c - 1);
  }
  private static testMethod void getProcessInformationTest1() {
    Case ca;
    string emailId = UserInfo.getUserEmail();
    RecordType employeeRT = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Employee' LIMIT 1];
    Contact con = new Contact(
      FirstName = 'TestMailApp',
      LastName = 'TestLast',
      Email = emailId,
      RecordTypeId = employeeRT.Id
    );
    insert con;
    User u = [SELECT Id, Email FROM User WHERE Id = :UserInfo.getUserId()];
    u.Contact = con;
    update u;
    Contact con2 = new Contact(
      FirstName = 'TestMailApptest',
      LastName = 'TestLasttest',
      Email = emailId,
      RecordTypeId = employeeRT.Id,
      ES_DJC_Is_Manager__c = true
    );
    insert con2;
    Delegate__c delegate = new Delegate__c(Delegate__c = con.Id, Type__c = NEW_HIRE_WIZARD, Manager__c = con2.Id);
    insert delegate;
    ca = new Case(
      contactId = con.Id,
      origin = PACKAGE_DELIVERY,
      NHW_Page_Number__c = 2,
      Type = MAIL_SERVICES,
      ES_DJC_Topic__c = PACKAGE_DELIVERY,
      NHW_Employee_Type__c = 'relocation',
      REWS_Received_Location__c = 'Landmark',
      REWS_Sender__c = 'Amazon',
      REWS_Carrier__c = 'USPS',
      REWS_Oversized__c = true
    );
    insert ca;
    ca = [
      SELECT
        id,
        contactId,
        NHW_Employee_Type__c,
        CreatedById,
        RecordTypeId,
        NHW_Page_Number__c,
        NHW_Job_Application__r.Job__r.Hiring_Manager__c
      FROM Case
      WHERE id = :ca.Id
    ];
    ca.NHW_Employee_Type__c = 'contractor';

    PF_NHW_ProcessHandler.CaseProcessInformation caseInfo = PF_NHW_ProcessHandler.getProcessInformation('contractor');
    System.assertEquals(caseInfo.currentStep, 0);
  }
}