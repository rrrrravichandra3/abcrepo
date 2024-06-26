@isTest(seealldata = false)
private class Test_ESDJC_Update_Contractor_User_Batch {
	
	@testSetup static void testDataSetup() {
      Profile portalUserProfile = [select id from Profile where name='Customer Portal Manager Custom' limit 1];
      ESDJC_Settings__c setting = new ESDJC_Settings__c(SSO_Dreamjobcentral_ID__c = 'fakeusernamex.com', SSO_Service_Provider_Org__c='fakeusername.com',
      													Site_URL__c='https://drmjobdev-careers.cs30.force.com/dreamjobcentral', Portal_User_Profile_Id__c = portalUserProfile.Id);
      insert setting;

      Integer total_number_of_contacts = 5;
      Account salesforceAcc = new Account(Name='Salesfoce', CurrencyIsoCode='USD');
      insert salesforceAcc;
      Id employeeRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contractor').getRecordTypeId();

      List<Contact> contacts = new List<Contact>();
      for(Integer idx = 0; idx < total_number_of_contacts; idx++){
        contacts.add(new Contact(Status__c= 'Active', LastName='LastName'+idx, AccountId= salesforceAcc.Id, ES_DJC_Record_Status__c='Updated', EmployeeNumber__c = idx+'', RecordTypeId=employeeRecordTypeId, Email = 'dajHGDAHJDGJA'+idx+'@peopleforce.com'));
      }
      insert contacts;
      //Insert Portal Users
      List<User> portalUsers = new List<User>();
      for(Integer idx = 0; idx < total_number_of_contacts; idx++){
        User djc_test_user = new User(alias = 'standt',email='standarduser@drmjob.com',emailencodingkey='UTF-8',lastname='Testing', 
                                      languagelocalekey='en_US',localesidkey='en_US', profileid = portalUserProfile.id, ContactId = contacts[idx].Id,
                                      timezonesidkey='America/Los_Angeles',username='dajHGDAHJDGJA'+idx+'@peopleforce.com');
        portalUsers.add(djc_test_user);
      }
      insert portalUsers;
  	}

   static testMethod void testBatchJobExecutionSuccess(){
      List<Id> successfulConttactsIds = new List<Id>();
      List<Contact> contacts = [SELECT Id, Name, ES_DJC_Record_Status__c, EmployeeNumber__c, Title, Division__c from Contact];
      for(Contact cnt :  contacts){
          cnt.Division__c = 'Japan';
          cnt.FirstName = 'Changed FirstName';
          cnt.LastName = 'Changed LastName';
          cnt.Title = 'Updated Title';
          cnt.ES_DJC_Business_Unit__c = '1001 Hmm';
          cnt.ES_DJC_Cost_Center__c = '1000';
          successfulConttactsIds.add(cnt.Id);
      }
      update contacts;
      System.runAs(new User(Id = UserInfo.getUserId())) {
      Integer total_number_of_contacts = 5;
      ESDJC_Integration_Log__c log = new ESDJC_Integration_Log__c(Integration_Status__c='In Progress', Integration_Start_Time__c=Datetime.now(), Integration_Finish_Time__c=Datetime.now());
      insert log;
      Test.startTest();
      ESDJC_Update_Contractor_User_Batch updatedCotractor = new ESDJC_Update_Contractor_User_Batch(log);
      Id batchJobId = Database.executeBatch(updatedCotractor, total_number_of_contacts);
      Test.stopTest();
      ESDJC_Integration_Log__c logQueried = [select Id, Name, DJC_Update_Contractor_Job_Status__c from ESDJC_Integration_Log__c where Id=:log.Id];
      System.assertEquals('Success', logQueried.DJC_Update_Contractor_Job_Status__c );
      List<Contact> successfullyUpdatedContact = [select Id, Name, ES_DJC_Record_Status__c from Contact];
      for(Contact cnt: successfullyUpdatedContact){
        System.assertEquals(ESDJC_Update_Contractor_User_Batch.SUCCESS_MESSAGE, cnt.ES_DJC_Record_Status__c, 'Record Status should say "Update - Completed"');
      }

      List<User> updatedUsers = [SELECT Id, Name, LastName, FirstName, Division, Title, Business_Unit__c, Cost_Center__c from User where ContactId in : successfulConttactsIds ];
      for(User usr: updatedUsers){
        System.assertEquals('Japan', Usr.Division, 'Division should be Japan');
        System.assertEquals('Changed FirstName', usr.FirstName, 'First Name should be updated to "Changed FirstName"');
        System.assertEquals('Changed LastName', usr.LastName, 'Last Name should be updated to "Changed LastName"');
        System.assertEquals('Updated Title', usr.Title, 'First Name should be updated to "Updated Title"');
        System.assertEquals('1001 Hmm', usr.Business_Unit__c);
        System.assertEquals('1000', usr.Cost_Center__c);
      }
    }
  }

  static testMethod void testBatchJobExecutionError(){
      List<Id> successfulConttactsIds = new List<Id>();
      List<Contact> contacts = [SELECT Id, Name, ES_DJC_Record_Status__c, EmployeeNumber__c, Title, Division__c, Email, FirstName, LastName, ES_DJC_Business_Unit__c, ES_DJC_Cost_Center__c from Contact];
      for(Contact cnt :  contacts){
          cnt.Division__c = 'Japan';
          cnt.FirstName = 'Changed FirstName';
          cnt.LastName = 'Changed LastName';
          cnt.Title = 'Updated Title';
          cnt.ES_DJC_Business_Unit__c = '1001 Hmm';
          cnt.ES_DJC_Cost_Center__c = '1000';
          if(cnt.Email == 'dajHGDAHJDGJA4@peopleforce.com'){
            cnt.FirstName = 'Supposed To Be failed';
            cnt.Email = 'dajHGDAHJDGJA3@peopleforce.com';
          }
          cnt.ES_DJC_Record_Status__c = 'Updated';
          successfulConttactsIds.add(cnt.Id);
      }
      update contacts;
      System.runAs(new User(Id = UserInfo.getUserId())) {
      Integer total_number_of_contacts = 5;
      ESDJC_Integration_Log__c log = new ESDJC_Integration_Log__c(Integration_Status__c='In Progress', Integration_Start_Time__c=Datetime.now(), Integration_Finish_Time__c=Datetime.now());
      insert log;
      Test.startTest();
      ESDJC_Update_Contractor_User_Batch updatedCotractor = new ESDJC_Update_Contractor_User_Batch(log);
      Id batchJobId = Database.executeBatch(updatedCotractor, total_number_of_contacts);
      Test.stopTest();
      ESDJC_Integration_Log__c logQueried = [select Id, Name, DJC_Update_Contractor_Job_Status__c from ESDJC_Integration_Log__c where Id=:log.Id];
      System.assertEquals('Failure', logQueried.DJC_Update_Contractor_Job_Status__c );
      List<Contact> successfullyUpdatedContact = [select Id, Name, ES_DJC_Record_Status__c, FirstName from Contact];
      for(Contact cnt: successfullyUpdatedContact){
        if(cnt.FirstName == 'Supposed To Be failed'){
          System.assert(cnt.ES_DJC_Record_Status__c.startsWith(ESDJC_Update_Contractor_User_Batch.ERROR_MESSAGE), 'Record Status should say "ERROR:" '+ cnt.ES_DJC_Record_Status__c);
        }else{
          System.assertEquals(ESDJC_Update_Contractor_User_Batch.SUCCESS_MESSAGE, cnt.ES_DJC_Record_Status__c, 'Record Status should say "Update - Completed"');
        }
      }
    }
  }

	
}