@isTest
private class Test_ESDJC_New_User_Contractor_Batch {
	@testSetup static void testDataSetup() {
      Profile portalUserProfile = [select id from Profile where name='Customer Portal Manager Custom' limit 1];
      ESDJC_Settings__c setting = new ESDJC_Settings__c(SSO_Dreamjobcentral_ID__c = 'fakeusernamex.com', SSO_Service_Provider_Org__c='fakeusername.com', 
      													Site_URL__c='https://drmjobdev-careers.cs30.force.com/dreamjobcentral', Portal_User_Profile_Id__c = portalUserProfile.Id);
      insert setting;
      Integer total_number_of_contacts = 5;
      Account salesforceAcc = new Account(Name='Salesfoce', CurrencyIsoCode='USD');
      insert salesforceAcc;
      Id contractorRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contractor').getRecordTypeId();

      List<Contact> contacts = new List<Contact>();
      for(Integer idx = 0; idx < total_number_of_contacts; idx++){
        contacts.add(new Contact(Status__c= 'Active', LastName='LastName'+idx, AccountId= salesforceAcc.Id, ES_DJC_Record_Status__c='New', EmployeeNumber__c = idx+'', RecordTypeId=contractorRecordTypeId, Email = 'dajHGDAHJDGJA'+idx+'@peopleforce.com'));
      }
      insert contacts;
  }
  static testMethod void testBatchJobExecution() {		
  		Test.StartTest();
			ESDJC_Integration_Log__c log = new ESDJC_Integration_Log__c();
			insert log;
			
   		ESDJC_New_User_Contractor_Batch updateUser = new ESDJC_New_User_Contractor_Batch(log);
   		ID batchprocessid = Database.executeBatch(updateUser);
   		Test.StopTest();
   			
			log = [SELECT DJC_New_Contractor_Batch_Job_Start_Time__c,DJC_New_Contractor_Batch_Job_Finish_Time__c,DJC_New_Contractor_Job_Status__c FROM ESDJC_Integration_Log__c WHERE id = :log.Id];
   			System.assertNotEquals(null, log.DJC_New_Contractor_Batch_Job_Finish_Time__c);
   			System.assertNotEquals(null, log.DJC_New_Contractor_Batch_Job_Start_Time__c);
   			System.assertNotEquals(null, log.DJC_New_Contractor_Job_Status__c);
	}

	static testMethod void testBatchJobExecutionSuccess(){
      System.runAs(new User(Id = UserInfo.getUserId())) {
      Integer total_number_of_contacts = 5;
      ESDJC_Integration_Log__c log = new ESDJC_Integration_Log__c(Integration_Status__c='In Progress', Integration_Start_Time__c=Datetime.now(), Integration_Finish_Time__c=Datetime.now());
      insert log;
      Test.startTest();
      ESDJC_New_User_Contractor_Batch newCotractor = new ESDJC_New_User_Contractor_Batch(log);
      Id batchJobId = Database.executeBatch(newCotractor, total_number_of_contacts);
      Test.stopTest();
      ESDJC_Integration_Log__c logQueried = [select Id, Name, DJC_New_Contractor_Job_Status__c from ESDJC_Integration_Log__c where Id=:log.Id];
      System.assertEquals('Success', logQueried.DJC_New_Contractor_Job_Status__c );
      List<Contact> successfullyUpdatedContact = [select Id, Name, ES_DJC_Record_Status__c from Contact];
      for(Contact cnt: successfullyUpdatedContact){
        System.assertEquals(ESDJC_New_User_Contractor_Batch.SUCCESS_MESSAGE, cnt.ES_DJC_Record_Status__c, 'Record Status should say "New - Completed"');
      }
    }
  }

  	static testMethod void testBatchJobExecutionUserNameCollision(){
	  	Profile userProfiles = [select id from Profile where name='System Administrator' limit 1];
	      
	  	User djc_test_user = new User(alias = 'standt',email='standarduser@drmjob.com',emailencodingkey='UTF-8',lastname='Testing', 
	                                      languagelocalekey='en_US',localesidkey='en_US', profileid = userProfiles.id, 
	                                      timezonesidkey='America/Los_Angeles',username='dajhgdahjdgja4@fakeusernamex.com');
	  	insert djc_test_user;

	     System.runAs(new User(Id = UserInfo.getUserId())) {
	      	Integer total_number_of_contacts = 5;
	      	ESDJC_Integration_Log__c log = new ESDJC_Integration_Log__c(Integration_Status__c='In Progress', Integration_Start_Time__c=Datetime.now(), Integration_Finish_Time__c=Datetime.now());
	      	insert log;
	      	Test.startTest();
	      	ESDJC_New_User_Contractor_Batch newCotractor = new ESDJC_New_User_Contractor_Batch(log);
	      	Id batchJobId = Database.executeBatch(newCotractor, total_number_of_contacts);
	      	Test.stopTest();
	     	ESDJC_Integration_Log__c logQueried = [select Id, Name, DJC_New_Contractor_Job_Status__c from ESDJC_Integration_Log__c where Id=:log.Id];
	      	System.assertEquals('Failure', logQueried.DJC_New_Contractor_Job_Status__c );
	      	List<Contact> successfullyUpdatedContact = [select Id, Name, ES_DJC_Record_Status__c, Email from Contact];
	      	for(Contact cnt: successfullyUpdatedContact){
	      		if(cnt.Email == 'dajHGDAHJDGJA4@peopleforce.com'){
	      			System.assert(cnt.ES_DJC_Record_Status__c.startsWith('New - ERROR:'), 'There should be a user name collision. ' + cnt.ES_DJC_Record_Status__c);
	  			}else{
	  				System.assertEquals(ESDJC_New_User_Contractor_Batch.SUCCESS_MESSAGE, cnt.ES_DJC_Record_Status__c, 'Record Status should say "New - Completed"');
	  			}
	      	}
	    }
  	}
	
}