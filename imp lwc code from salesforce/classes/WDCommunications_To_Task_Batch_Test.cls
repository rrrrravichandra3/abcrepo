@isTest
public class WDCommunications_To_Task_Batch_Test {
  @testSetup
  static void setup() {
    CEMCI_Test_Util.createCEMCICustomSetting();
    List<WD_Communication__c> WDComms = new List<WD_Communication__c>();
    for (Integer i = 1; i <= 100; i++) {
      WD_Communication__c Comm = new WD_Communication__c();
      Comm.Name = 'Test Name' + i;
      Comm.Business_Process_Type__c = 'Test Process Type';
      Comm.Notification_Type__c = 'Test Notification Type';
      Comm.Reply_To__c = 'test@notabc.com;test2@notabc.com';
      Comm.Channels__c = 'Test Channel';
      Comm.Message__c = 'Test Message';
      Comm.Notification_Subject__c = 'Test Subject';
      Comm.Recipients_Email__c = 'test@not1abc.com';
      Comm.Notification_Date__c = System.today();

      WDComms.add(Comm);
    }
    insert WDComms;

    Individual ind = new Individual(LastName = 'TestIndivudual');
    insert ind;

    WD_Communication__c Comm = [
      SELECT Id, Recipients_Email__c, Task__c, Business_Process_Type__c, Message__c, Reply_To__c
      FROM WD_Communication__c
      WHERE Id IN :WDComms
      LIMIT 1
    ];
    Test.startTest();
    Profile p1 = [SELECT id FROM Profile WHERE name = 'System Administrator'];
    List<User> userList = new List<User>();
    User opUser = new user(
      alias = 'test123',
      email = 'test@notabc.com',
      emailencodingkey = 'UTF-8',
      firstName = 'Pawan',
      lastname = 'Testing',
      languagelocalekey = 'en_US',
      localesidkey = 'en_US',
      profileid = p1.Id,
      country = 'United States',
      timezonesidkey = 'America/Los_Angeles',
      username = 'test01@not1email.com',
      Available_for_CEMCI_Account_Assignment__c = true
    );
    userList.add(opUser);
    User opUser2 = new user(
      alias = 'test1234',
      email = 'test2@notabc.com',
      emailencodingkey = 'UTF-8',
      firstName = 'Pawan',
      lastname = 'Testing',
      languagelocalekey = 'en_US',
      localesidkey = 'en_US',
      profileid = p1.Id,
      country = 'United States',
      timezonesidkey = 'America/Los_Angeles',
      username = 'test02@not2email.com',
      Available_for_CEMCI_Account_Assignment__c = true
    );
    userList.add(opUser2);
    insert userList;

    Test.stopTest();
    System.AssertEquals(opUser.Email, 'test@notabc.com');

    Id conCandidateRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
      .get('WDR_Candidate')
      .getRecordTypeId();
    Contact con = new Contact(
      lastname = 'test con',
      email = Comm.Recipients_Email__c,
      IndividualId = ind.Id,
      RecordTypeId = conCandidateRecordTypeId
    );
    insert con;
    System.AssertEquals(con.Email, 'test@not1abc.com');

    Lead l = new Lead(
      lastname = 'Test Lead',
      email = Comm.Recipients_Email__c,
      IndividualId = ind.Id,
      Status = 'New',
      Company = 'SFDC'
    );
    insert l;
    System.AssertEquals(l.Email, 'test@not1abc.com');
  }

  @isTest
  static void testWDCommToTaskBatch() {
    Test.startTest();
    WDCommunications_To_Task_Batch WDCBatch = new WDCommunications_To_Task_Batch();
    Id batchId = Database.executeBatch(WDCBatch);
    Test.stopTest();
    System.assertEquals(100, [SELECT COUNT() FROM Task WHERE Subject = 'Test Subject']);
  }
}