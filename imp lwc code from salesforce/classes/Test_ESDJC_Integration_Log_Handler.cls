@isTest(SeeAllData=false)
public with sharing class Test_ESDJC_Integration_Log_Handler {
    public static testMethod void testNewUserCreation() {
        ESDJC_TestUtil.init();
        Test.StartTest();
        Contact newContact = createNewContact();        
        Contact aContact = [SELECT ES_DJC_Record_Status__c FROM Contact WHERE EmployeeNumber__c=:newContact.EmployeeNumber__c];
        System.assertEquals('New', aContact.ES_DJC_Record_Status__c);
 
        user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        User newUser;
        system.runAs(currentUser){
            
           newUser = createNewUser(newContact);
        }
        List<User> djcUsers = [SELECT username from User WHERE EmployeeNumber=:newUser.EmployeeNumber];
        System.assertEquals(1, djcUsers.size());
 
        
        ESDJC_Integration_Log__c log = new ESDJC_Integration_Log__c();
        log.Integration_Start_Time__c = DateTime.now();
        insert log;
                
        log.Integration_Finish_Time__c = DateTime.now();
        log.Integration_Status__c = 'Success';
        update log;
        Test.StopTest();        
        
        log = [SELECT DJC_New_User_Batch_Job_Finish_Time__c,DJC_New_User_Batch_Job_Start_Time__c,DJC_New_User_Job_Status__c,DJC_Update_Contact_Batch_Job_Finish_Time__c,DJC_Update_Contact_Batch_Job_Start_Time__c,DJC_Update_Contact_Job_Status__c,DJC_Update_User_Batch_Job_Finish_Time__c,DJC_Update_User_Batch_Job_Start_Time__c,DJC_Update_User_Job_Status__c,Integration_Finish_Time__c,Integration_Start_Time__c,Integration_Status__c FROM ESDJC_Integration_Log__c WHERE id=:log.Id];
        System.assertNotEquals(null, log.DJC_New_User_Batch_Job_Start_Time__c);
        System.assertNotEquals(null, log.DJC_New_User_Batch_Job_Finish_Time__c);
        System.assertNotEquals(null, log.DJC_New_User_Job_Status__c);
 
        //System.assertNotEquals(null, log.DJC_Update_Contact_Batch_Job_Start_Time__c);
        //System.assertNotEquals(null, log.DJC_Update_Contact_Batch_Job_Finish_Time__c);
        //System.assertNotEquals(null, log.DJC_Update_Contact_Job_Status__c);
        
        System.assertNotEquals(null, log.DJC_Update_User_Batch_Job_Start_Time__c);
        System.assertNotEquals(null, log.DJC_Update_User_Batch_Job_Finish_Time__c);
        System.assertNotEquals(null, log.DJC_Update_User_Job_Status__c);
 
        djcUsers = [SELECT username from User WHERE EmployeeNumber=:newUser.EmployeeNumber];
        System.assertEquals(1, djcUsers.size());
        
        //djcUser = [SELECT username from User WHERE EmployeeNumber=:aUser.EmployeeNumber AND Username=:ESDJC_Util.getDJCUserName(aUser.Username)];
        //System.assertEquals(1, djcUser.size());
        //System.assertEquals(ESDJC_Util.getDJCUserName(aUser.Username), djcUser.Username); 
        
        //aContact = [SELECT ES_DJC_Record_Status__c FROM Contact WHERE EmployeeNumber__c=:newUser.EmployeeNumber];
        //System.assertEquals('', aContact.ES_DJC_Record_Status__c);
    }
 
 
    public static User createNewUser(Contact contact) {
        Profile p = [SELECT Id FROM profile WHERE name='Employee'];
 
        User u = new User();
        u.username = contact.FirstName+'@dreamjobcentral.com';
        u.email = contact.FirstName+'@dreamjobcentral.com';
        u.lastName = contact.FirstName;
        u.firstName = contact.FirstName;
        String alias = contact.LastName;
        u.alias = alias;
        u.CommunityNickname = alias;
        u.languagelocalekey = 'en_US';
        u.localesidkey = 'en_US';
        u.profileId = p.Id;
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = 'America/Los_Angeles';
        u.Manager__c = '00570000001JGKmAAO';            
        u.Department = '3020-Enterprise Salesforce Services';
 
        //u.ContactId = contact.Id;
            
        //u.UserType = 'Standard';
       // u.UserRoleId = '00e70000000wFfXAAU';//'00E70000000z4rYEAQ';//'00EQ0000000O6M7';    
        u.CurrencyIsoCode = 'USD';
        u.IsActive = true;
        
        u.EmployeeNumber = contact.EmployeeNumber__c;
        
        insert u;
        return u;
    }
 
    public static Contact createNewContact() {
        RecordType employee = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND Name = 'Employee'];
        Account anAccount;
        if([SELECT count() FROM Account WHERE Name = 'Employee'] == 0){
            anAccount =  new Account(Name = 'Employee'); 
            insert anAccount;
        }
        else{
            anAccount = [SELECT Id FROM Account WHERE Name = 'Employee'];
        }
 
        Contact aContact = new Contact();
        aContact.AccountId = anAccount.Id;
        aContact.RecordTypeId = employee.Id;
        aContact.FirstName = 'Portal';
        aContact.LastName = 'Contact';
        aContact.Division__c = 'Americas - USA';
        aContact.ES_DJC_Record_Status__c = 'New';
        aContact.EmployeeNumber__c = '987654321';
        aContact.ES_DJC_Is_Manager__c = false;
        aContact.ES_DJC_Record_Status__c = 'New';
                
        insert aContact;
        return aContact;
    }
 
}