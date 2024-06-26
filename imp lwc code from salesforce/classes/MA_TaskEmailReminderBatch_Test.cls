@IsTest
public class MA_TaskEmailReminderBatch_Test {

    @TestSetup
    static void setupTestData(){
        UserRole dummyRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];       
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];     

        User sysAdminUser = new User(
            UserRoleId = dummyRole.Id,
            ProfileId = profile.Id,
            Username = 'taskbatch_testsystemadminuser@test.com',
            Alias = 'test1',
            Email='test@test1.com',
            EmailEncodingKey='UTF-8',
            Firstname='Sys',
            Lastname='Admin User',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        Database.insert(sysAdminUser);
        
        User portalUser = new User();
        Contact contact = new Contact();
              
        System.runAs(sysAdminUser) {
            Acquisition_Company__c accCompany = new Acquisition_Company__c(
                Acquisition_Company_Name__c = 'MA',
                Name = 'MA',
                Status__c = 'Pre-Diligence'
            );
            
            Database.insert(accCompany);
            
            Account account = new Account(
                Name = 'MA',
                Acquisition_Companies__c = accCompany.id,
                OwnerId = sysAdminUser.Id
            );
            Database.insert(account);
            
            Acquisition_Contacts__c accContact = new Acquisition_Contacts__c(
                Name = 'Test Community',
                Contact_Status__c = 'New',
                Hire_Reason__c = 'New Hire',
                Acquisition_Company__c = accCompany.id,
                Employee_ID_Target__c = '123456',
                Email_Address_Target__c = 'test@community.com',
                Salesforce_Email_Address__c = 'test@email.com',
                Remove_Community_Access__c = false
            );
            Database.insert(accContact);
            
            contact = new Contact(
                FirstName = 'Community',
                Lastname = 'Contact',
                AccountId = account.Id,
                Acquisition_Contacts__c = accContact.Id,
                Email = 'test@community.com'
            );
            Database.insert(contact);
            
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name ='M&A Community Portal Custom' Limit 1];
            UserRole portalRole = [SELECT Id FROM UserRole WHERE Name = 'MA Customer User' Limit 1];
            portalUser = new User(
                Username = 'test7686portal@community.com.wayfinder',
                ContactId = contact.Id,
                ProfileId = portalProfile.Id,
                UserRoleId = portalRole.id,
                Alias = 'test123',
                Email = 'test@community.com',
                FederationIdentifier = 'test@community.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Test',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                IsActive = true,
                LanguageLocaleKey = 'en_US'
            );
            Database.insert(portalUser);

            MA_TaskManagementSettings__c customization = new MA_TaskManagementSettings__c(
                Name = 'Test',
                Task_Reminder_Enabled__c = true
            );
            insert customization;
        }
    }

    @isTest
    static void sendEmailReminderPositive() {
        String aContactId = [SELECT Id 
                             FROM Acquisition_Contacts__c 
                             WHERE Name = 'Test Community' LIMIT 1].Id;
        
        List<Acquisition_Contact_Task__c> tasks = new List<Acquisition_Contact_Task__c>();
        for (Integer i = 0; i < 20; i++) {
            tasks.add(new Acquisition_Contact_Task__c(
                Description__c = 'test description ' + i,
                Due_Date__c = System.today().addDays(-i),
                Status__c = 'Not Started',
                Subject__c = 'Test Subject ' + i,
                Acquisition_Contact__c = aContactId
            ));
        }
        insert tasks;
        Test.startTest();
        Database.executeBatch(new MA_TaskEmailReminderBatch());
        Test.stopTest();
        System.assertNotEquals(1, MA_TaskEmailReminderBatch.emailLimits, 'An email should be sent');
    }

    @isTest
    static void sendEmailReminderNegative() {
        String aContactId = [SELECT Id FROM Acquisition_Contacts__c WHERE Name = 'Test Community' LIMIT 1].Id;
        
        List<Acquisition_Contact_Task__c> tasks = new List<Acquisition_Contact_Task__c>();
        for (Integer i = 0; i < 20; i++) {
            tasks.add(new Acquisition_Contact_Task__c(
                Description__c = 'test description ' + i,
                Due_Date__c = System.today().addDays(i),
                Status__c = 'Not Started',
                Subject__c = 'Test Subject ' + i,
                Acquisition_Contact__c = aContactId
            ));
        }
        insert tasks;
        Test.startTest();
        Database.executeBatch(new MA_TaskEmailReminderBatch());
        Test.stopTest();
        System.assertEquals(0, MA_TaskEmailReminderBatch.emailLimits, 'An email shouldn\'t be sent');
    }
  
}