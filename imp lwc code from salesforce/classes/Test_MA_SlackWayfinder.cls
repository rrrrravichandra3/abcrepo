/**
 * Created by kmoseley on 2/27/21.
 */

@IsTest
private class Test_MA_SlackWayfinder {

    @TestSetup
    static void setUpData(){

        UserRole dummyRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile = [Select Id from Profile where name = 'System Administrator' LIMIT 1];

        User sysAdminUser = new User(
                UserRoleId = dummyRole.Id,
                ProfileId = profile.Id,
                Username = 'testsysadminuser77687@test.com',
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


            //Create acquisition company
            Acquisition_Company__c accCompany = new Acquisition_Company__c(

                    Acquisition_Company_Name__c = 'Slack',
                    Name = 'Slack',
                    Status__c = 'Pre-Diligence'

            );

            Database.insert(accCompany);

            //Create account
            Account account = new Account(

                    Name = 'Slack',
                    Acquisition_Companies__c = accCompany.id,
                    OwnerId = sysAdminUser.Id

            );
            Database.insert(account);

            Acquisition_Contacts__c accContact = new Acquisition_Contacts__c(

                    Name = 'Test Slack',
                    Contact_Status__c = 'New',
                    Hire_Reason__c = 'New Hire',
                    Acquisition_Company__c = accCompany.id,
                    Employee_ID_Target__c = '123456',
                    Email_Address_Target__c = 'test@slack-corp.com'

            );
            Database.insert(accContact);

            //Create contact
            contact = new Contact(
                    FirstName = 'Community',
                    Lastname = 'Contact',
                    AccountId = account.Id,
                    Email = 'test@slack-corp.com',
                    M_A_Community_URL__c = 'https://peopleforce.cs46.force.com/Slack/',
                    Acquisition_Contacts__c = accContact.Id
            );
            Database.insert(contact);
        }
    }


    @isTest
    static void testPostCallout() {
        Test.setMock(HttpCalloutMock.class, new Test_MA_SlackWayfinderHTTPMock());
        Test.startTest();
            HttpResponse response = MA_SlackWayfinderService.workatoWayfinderServiceCallout('{"email_address":"lohsiek@slack-corp.com","message_text":"Your case has been updated","button_link":"https://dreamjobcentral/case/xx","button_text":"View Case"}');
            String contentType = response.getHeader('Content-Type');
            System.assert(contentType == 'application/json');
            String actualValue = response.getBody();
            String expectedValue = '{"status": "ok"}';
            System.assertEquals(actualValue, expectedValue);
            System.assertEquals(200, response.getStatusCode());
        Test.stopTest();
    }

    @isTest
    static void testSendMessage() {
        Test.setMock(HttpCalloutMock.class, new Test_MA_SlackWayfinderHTTPMock());
        List<MA_SlackWayfinderService.SlackMessageBody> messages = new List<MA_SlackWayfinderService.SlackMessageBody>();

        MA_SlackWayfinderService.SlackMessageBody message =
                new MA_SlackWayfinderService.SlackMessageBody(
                        'kbay@slack-corp.com',
                        'test text',
                        'https://www.salesforce.com',
                        'button text');
        messages.add(message);
        Test.startTest();
            MA_SlackWayfinderService.sendMessagesToSlackWayfinderBot(messages,true);
        Test.stopTest();
    }

    @IsTest
    static void testCaseClosedInvocable(){
        Test.setMock(HttpCalloutMock.class, new Test_MA_SlackWayfinderHTTPMock());
        Test.startTest();
        Contact c = [SELECT Id, Acquisition_Contacts__c FROM Contact];
        Case maCase = new Case(ContactId = c.Id,
                Subject = 'test case',
                Acquisition_Contact__c = c.Acquisition_Contacts__c
        );
        Database.insert(maCase);
        List<Id> ids = new List<Id>();
        ids.add(maCase.Id);
        MA_SlackCaseClosed.caseClosed(ids);
        Test.stopTest();
    }

    @IsTest
    static void testCaseOpenedInvocable(){
        Test.setMock(HttpCalloutMock.class, new Test_MA_SlackWayfinderHTTPMock());
        Test.startTest();
        Contact c = [SELECT Id, Acquisition_Contacts__c FROM Contact];
        Case maCase = new Case(ContactId = c.Id,
                Subject = 'test case',
                Acquisition_Contact__c = c.Acquisition_Contacts__c
        );
        Database.insert(maCase);
        List<Id> ids = new List<Id>();
        ids.add(maCase.Id);
        MA_SlackCaseOpened.caseOpened(ids);
        Test.stopTest();
    }

    @IsTest
    static void testCaseCommentInvocable(){
        Test.setMock(HttpCalloutMock.class, new Test_MA_SlackWayfinderHTTPMock());
        Test.startTest();
        Contact c = [SELECT Id, Acquisition_Contacts__c FROM Contact];
        Case maCase = new Case(ContactId = c.Id,
                Subject = 'test case',
                Acquisition_Contact__c = c.Acquisition_Contacts__c
        );
        Database.insert(maCase);
        List<Id> ids = new List<Id>();
        ids.add(maCase.Id);
        MA_SlackCaseComment.caseCommentPosted(ids);
        Test.stopTest();
    }

}