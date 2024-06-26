@isTest
private class CEMCI_Task_Test {
  private static final Id taskRecordTypeId = Task.sObjectType.getDescribe()
    .getRecordTypeInfosByDeveloperName()
    .get('Outbound_Sourcer_Call')
    .getRecordTypeId();
  private static final Date today = system.today();

  static testMethod void updateDatesFromTaskTest() {
    CEMCI_Test_Util.createCEMCICustomSetting();

    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

    //Creation of User Data
    User u1 = new User(
      Alias = 'newUser',
      Email = 'newuser@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'newTestUser1',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'newuserTask@not.salesforce.com'
    );
    insert u1;

    Lead l = new Lead(
      Company = 'Test Company',
      LastName = 'TestLead',
      Email = 'testlead@not.salesforce.com',
      OwnerId = u1.Id
    );
    insert l;

    Account a = new Account(Name = 'Test Account');
    insert a;

    Contact c = new Contact(
      LastName = 'TestContact',
      AccountId = a.id,
      Email = 'testcontact@not.salesforce.com',
      OwnerId = u1.Id
    );
    insert c;

    Integer d = today.day();
    Integer mo = today.month();
    Integer yr = today.year();
    Date todayOffset = Date.newInstance(yr, mo, d);

    Test.startTest();

    Task t = new Task(
      Subject = 'Check in Call',
      Priority = 'Normal',
      Status = 'Completed',
      ActivityDate = today,
      OwnerId = u1.Id,
      RecordTypeId = taskRecordTypeId,
      WhoId = l.Id
    );
    insert t;

    Task t2 = new Task(
      Subject = 'Check in Call',
      Priority = 'Normal',
      Status = 'Completed',
      ActivityDate = today,
      OwnerId = u1.Id,
      RecordTypeId = taskRecordTypeId,
      WhoId = c.Id
    );
    insert t2;

    l = [SELECT Id, Initial_Interaction_Date__c FROM Lead WHERE Id = :l.Id];
    Date leadDate = Date.valueOf(l.Initial_Interaction_Date__c);
    Integer dLead = leadDate.day();
    System.assertEquals(d, dLead);

    c = [SELECT Id, Initial_Interaction_Date__c FROM Contact WHERE Id = :c.Id];
    Date conDate = Date.valueOf(c.Initial_Interaction_Date__c);
    Integer dCon = conDate.day();
    System.assertEquals(d, dCon);
  }
}