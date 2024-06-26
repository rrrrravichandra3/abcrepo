@isTest
private class Test_ESDJC_ContactHandler {

    static testMethod void testCaseRecordStatus() {
        //Create an employee contact without a portal user
        //This is for testing the use case when an employee is rehired or 
        //a contractor or an intern becomes a full time employee
        
        Account a = new Account(Name='Test1');
        insert a;
        
        Contact c = new Contact( AccountID = a.id, FirstName = 'Test', LastName = 'User', ES_DJC_Contact_Country__c = 'America', 
        email = 'test-user@fakemail.com', RecordTypeId=[select id,name from RecordType where sObjectType='Contact' and Name='Employee'].Id );
        insert c;
        
        System.assertEquals(null, [select ES_DJC_Record_Status__c from Contact where Id=:c.Id].ES_DJC_Record_Status__c);
        
        //update contact's record status to Updated
        c.ES_DJC_Record_Status__c = 'Updated';
        update c;
        
        //Verify if contact's status is new
        System.assertEquals('New', [select ES_DJC_Record_Status__c from Contact where Id=:c.Id].ES_DJC_Record_Status__c);
    }
}