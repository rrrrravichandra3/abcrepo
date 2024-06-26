@isTest
public with sharing class ESDJC_New_User_BatchTEST {
    static testMethod void testESDJCNewUserBatchSuccess() {
        Profile portalUserProfile = [select id from Profile where name='Customer Portal Manager Custom' limit 1];
        ESDJC_Settings__c setting = new ESDJC_Settings__c(SSO_Dreamjobcentral_ID__c = 'fakeusernamex.com', SSO_Service_Provider_Org__c='fakeusername.com' , Site_URL__c='https://drmjobdev-careers.cs30.force.com/dreamjobcentral', Portal_User_Profile_Id__c = portalUserProfile.Id, Phoenix_ESDJC_Batch_Cutoff_Date__c = '2023-12-10 12:00:00');
        insert setting;
        Integer total_number_of_contacts = 5;
        Account salesforceAcc = new Account(Name='Salesfoce', CurrencyIsoCode='USD');
        insert salesforceAcc;
        Id employeeRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Employee').getRecordTypeId();
        
        List<Contact> contacts = new List<Contact>();
        for(Integer idx = 0; idx < total_number_of_contacts; idx++){
            contacts.add(new Contact(Status__c= 'Active', LastName='LastName'+idx, AccountId= salesforceAcc.Id, ES_DJC_Record_Status__c='New', EmployeeNumber__c = idx+'', RecordTypeId=employeeRecordTypeId));
        }
        insert contacts;
        
        Profile userProfiles = [select id from Profile where name='System Administrator' limit 1];
        List<User> users = new List<User>();
        for(Integer idx = 0; idx < total_number_of_contacts; idx++){
            User djc_test_user = new User(alias = 'standt',email='standarduser@drmjob.com',emailencodingkey='UTF-8',lastname='Testing', 
                                          languagelocalekey='en_US',localesidkey='en_US', profileid = userProfiles.id, 
                                          timezonesidkey='America/Los_Angeles',username='dajHGDAHJDGJA'+idx+'@fakeusername.com', EmployeeNumber= idx+'');
            users.add(djc_test_user);
        }
        insert users;
        
        ESDJC_Integration_Log__c log = new ESDJC_Integration_Log__c(Integration_Status__c='In Progress', Integration_Start_Time__c=Datetime.now(), Integration_Finish_Time__c=Datetime.now());
        insert log;
        Test.startTest();
        ESDJC_New_User_Batch newUserBatch = new ESDJC_New_User_Batch(log);
        Id batchJobId = Database.executeBatch(newUserBatch, total_number_of_contacts);
        Test.stopTest();
        ESDJC_Integration_Log__c logQueried = [select Id, Name, DJC_New_User_Job_Status__c from ESDJC_Integration_Log__c where Id=:log.Id];
        System.assertEquals('Success', logQueried.DJC_New_User_Job_Status__c );
        List<Id> contactIds = new List<Id>();
        for(Contact cnt : contacts){
            contactIds.add(cnt.Id);
        }
        List<User> usersQueried = [select Id from User where ContactId in :contactIds];
        System.assertEquals(total_number_of_contacts, usersQueried.size());
    }
}