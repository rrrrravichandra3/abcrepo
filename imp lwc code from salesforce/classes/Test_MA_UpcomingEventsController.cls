@isTest(SeeAllData=false)
public class Test_MA_UpcomingEventsController {
    
    @testSetup static void createTestData() {
        UserRole dummyRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];       
        Profile profile = [Select Id from Profile where name = 'System Administrator' limit 1];     
        
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
                
                Acquisition_Company_Name__c = 'MA',
                Name = 'MA',
                Status__c = 'Pre-Diligence'
                
            );
            
            Database.insert(accCompany);
            
            //Create account
            Account account = new Account(
                
                Name = 'MA',
                Acquisition_Companies__c = accCompany.id,
                OwnerId = sysAdminUser.Id
                
            );
            Database.insert(account);
            
            Acquisition_Contacts__c accContact = new Acquisition_Contacts__c(
                
                Name = 'Test Community',
                Contact_Status__c = 'New',
                Hire_Reason__c = 'Hire Acquisition',
                Acquisition_Company__c = accCompany.id,
                Employee_ID_Target__c = '123456',
                Email_Address_Target__c = MA_TestUtilityValues.MA_PORTAL_USER_EMAIL
                
            );
            Database.insert(accContact);
            
            //Create contact
            contact = new Contact(
                FirstName = 'Community',
                Lastname = 'Contact',
                AccountId = account.Id,
                Email = MA_TestUtilityValues.MA_PORTAL_USER_EMAIL,
                Acquisition_Contacts__c = accContact.Id
            );
            Database.insert(contact);
            
            //Create user
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name ='M&A Community Portal Custom' Limit 1];
            UserRole portalRole = [SELECT Id FROM UserRole WHERE Name = 'MA Customer User' Limit 1];
            portalUser = new User(
                Username = 'test7686portal@community.com.wayfinder',
                ContactId = contact.Id,
                ProfileId = portalProfile.Id,
                UserRoleId = portalRole.id,
                Alias = 'test123',
                Email = MA_TestUtilityValues.MA_PORTAL_USER_EMAIL,
                FederationIdentifier = MA_TestUtilityValues.MA_PORTAL_USER_EMAIL,
                EmailEncodingKey = 'UTF-8',
                LastName = 'Test',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            Database.insert(portalUser);
            
            List<MA_Community_Events__c> listCommunintyEvents = new List<MA_Community_Events__c>();
            Date today =  date.today();
            Time startTime = Time.newInstance(13, 0, 0, 0);
            listCommunintyEvents.add(new MA_Community_Events__c(Acquisition_Company__c  = accCompany.Id, Event_Type__c = 'Key Date', Name = 'event test 1', Start_Date__c = today.addDays(2), Start_Time__c = startTime, Active__c = true));
            listCommunintyEvents.add(new MA_Community_Events__c(Acquisition_Company__c  = accCompany.Id, Event_Type__c = 'Key Date', Name = 'event test 2', Start_Date__c = today.addDays(3), Start_Time__c = startTime, Active__c = true));
            Database.insert(listCommunintyEvents);
            
            List<MA_Community_Event_Attendee__c> eventAttendees = new List<MA_Community_Event_Attendee__c >();
            eventAttendees.add(new MA_Community_Event_Attendee__c(Acquisition_Contacts__c = accContact.Id,Community_Event__c = listCommunintyEvents[0].Id));
            eventAttendees.add(new MA_Community_Event_Attendee__c(Acquisition_Contacts__c = accContact.Id,Community_Event__c = listCommunintyEvents[1].Id));
            database.insert(eventAttendees);
            
            MA_UpcomingEventsSettings__c eventSettings = new MA_UpcomingEventsSettings__c();
            eventSettings.Name = 'MA_SettingsEvents';
            eventSettings.Title_component__c = 'Upcoming Events & Key Dates';
            eventSettings.Limit_Event__c = 3;
            eventSettings.Button_Label__c = 'Load More';
            eventSettings.Empty_Event_Text__c = 'Looks like you are free and clear the rest of the day.';
            Insert eventSettings;
        }
    }
    
    /**
    * Given: Upcomming community event records are available
    * When: is accessed by MA community user
    * Then: MA community user users should be able to see the event records using LWC
    */
    @isTest
    static void getUpcomingEventWithoutCriteria_MAUser(){
        
        Map<String, List<Object>> eventsWithSettings = new Map<String, List<Object>>();
        User communityUser = [SELECT Id, Name, Email FROM User WHERE Email =: MA_TestUtilityValues.MA_PORTAL_USER_EMAIL];
        
        System.runAs(communityUser){
            Test.StartTest();
            eventsWithSettings = MA_UpcomingEventsController.getEventsAttendeesRecords();
            Test.StopTest();
        }
        
        System.assertEquals(2, eventsWithSettings.get('MA_Community_Events__c').size());   
        System.assertEquals(1, eventsWithSettings.get('MA_UpcomingEventsSettings__c').size());   
    }
    
    /**
    * Given: Upcomming community event records are available with positive filter criteria poulated
    * When: is accessed by MA community user
    * Then: MA community user users should be able to see the event records using LWC
    */
    @isTest
    static void getUpcomingEventWithPositiveCriteria_MAUser(){
        
        Map<String, List<Object>> eventsWithSettings = new Map<String, List<Object>>();
        User communityUser = [SELECT Id, Name, Email FROM User WHERE Email =: MA_TestUtilityValues.MA_PORTAL_USER_EMAIL];
        List<MA_Community_Events__c> commEvent = [Select Id, Filter_Criteria__c from MA_Community_Events__c where Name = 'event test 1'] ;
        System.assert(commEvent.size() != 0, MA_TestUtilityValues.EVENT_NOT_FOUND);  
        
        commEvent[0].Filter_Criteria__c = 'Acquisition_Company_Name__c == MA';
        Update commEvent;
        
        System.runAs(communityUser){
            Test.StartTest();
            eventsWithSettings = MA_UpcomingEventsController.getEventsAttendeesRecords();
            Test.StopTest();
        }
        
        System.assertEquals(2, eventsWithSettings.get('MA_Community_Events__c').size());   
        System.assertEquals(1, eventsWithSettings.get('MA_UpcomingEventsSettings__c').size());   
    }
    
    /**
    * Given: Upcomming community event records are available with negative filter criteria poulated
    * When: is accessed by MA community user
    * Then: MA community user users should not be able to see the event records where criteria doesn't match
    */
    @isTest
    static void getUpcomingEventWithNegativeCriteria_MAUser(){
        
        Map<String, List<Object>> eventsWithSettings = new Map<String, List<Object>>();
        User communityUser = [SELECT Id, Name, Email FROM User WHERE Email =: MA_TestUtilityValues.MA_PORTAL_USER_EMAIL];
        List<MA_Community_Events__c> commEvent = [Select Id, Filter_Criteria__c from MA_Community_Events__c where Name = 'event test 1'] ;
        System.assert(commEvent.size() != 0, MA_TestUtilityValues.EVENT_NOT_FOUND);  
        
        commEvent[0].Filter_Criteria__c = 'Acquisition_Company_Name__c == Test';
        Update commEvent;
        
        System.runAs(communityUser){
            Test.StartTest();
            eventsWithSettings = MA_UpcomingEventsController.getEventsAttendeesRecords();
            Test.StopTest();
        }
        
        System.assertEquals(2, eventsWithSettings.get('MA_Community_Events__c').size());   
        System.assertEquals(1, eventsWithSettings.get('MA_UpcomingEventsSettings__c').size());   
    }

     /**
    * Given: Upcomming community event records are available with attendee data
    * Then: MA community user users should be able to update event records.
    */
    @isTest
    static void getupdateRSVPValue(){
        
        User communityUser = [SELECT Id, Name, Email FROM User WHERE Email =: MA_TestUtilityValues.MA_PORTAL_USER_EMAIL];
        
        List<MA_Community_Event_Attendee__c> communityEventsList = [SELECT Id, Name, Community_Event__c, RSVP__c
                                                                       FROM MA_Community_Event_Attendee__c LIMIT 1];
        System.runAs(communityUser){
            Test.StartTest();
            	MA_UpcomingEventsController.updateRSVPValue(communityEventsList[0].Id,'No');
        	Test.StopTest();
        }
        
        List<MA_Community_Event_Attendee__c> updtaedEventsList = [SELECT Id, Name, Community_Event__c, RSVP__c
                                                                       FROM MA_Community_Event_Attendee__c 
                                                                       WHERE Id=: communityEventsList[0].Id LIMIT 1];
        System.assertEquals('No', updtaedEventsList[0].RSVP__c);   
    }
    
    /**
    * Given: Upcomming community event records are available with attendee data
    * Then: MA  user users should not be able to update event records.
    */
    @isTest
    static void getExeptionupdateRSVPValue(){
        
        User communityUser = [SELECT Id, Name, Email FROM User WHERE Email =: MA_TestUtilityValues.MA_PORTAL_USER_EMAIL];
        
        List<MA_Community_Event_Attendee__c> communityEventsList = [SELECT Id, Name, Community_Event__c, RSVP__c
                                                                       FROM MA_Community_Event_Attendee__c LIMIT 1];
        try{
            System.runAs(communityUser){
                Test.StartTest();
                    MA_UpcomingEventsController.updateRSVPValue(communityEventsList[0].Id,'Noo');
                Test.StopTest();
        	}
        } catch (AuraHandledException e) {
                   // Handle the exception or perform any necessary assertions
                   String expectedErrorMessage = 'Script-thrown exception';
                   System.assertEquals(expectedErrorMessage, e.getMessage());
             }  
    }
    
    @isTest
    static void test_UpcomingEventstatusChange(){
        
        List<MA_Community_Events__c> commEvent = [Select Id, Filter_Criteria__c from MA_Community_Events__c where Name = 'event test 1'] ;
        System.assert(commEvent.size() != 0, MA_TestUtilityValues.EVENT_NOT_FOUND);  
        
        commEvent[0].Active__c = false;
        commEvent[0].Event_Invite_Status__c = 'Sending Invites';
        Update commEvent;
        System.assertEquals(false, commEvent[0].Active__c);   
    }
    
    @isTest
    static void test_UpcomingEventupdated(){
        
        List<MA_Community_Events__c> commEvent = [Select Id, Filter_Criteria__c, Event_Type__c, Start_Date__c
                                                  from MA_Community_Events__c where Name = 'event test 1'] ;
        System.assert(commEvent.size() != 0, MA_TestUtilityValues.EVENT_NOT_FOUND);  
        commEvent[0].Event_Invite_Status__c = 'Changes Complete';
        commEvent[0].Event_Type__c = 'Information Session';
        commEvent[0].Start_Date__c = date.today().addDays(4);
        Update commEvent;
        System.assertEquals('Information Session', commEvent[0].Event_Type__c);   
    }
    
    @isTest
    static void test_updateEventEndDateTime(){
        
        List<MA_Community_Events__c> commEvent = [Select Id, Filter_Criteria__c, Event_Type__c, Start_Date__c, All_Day_Event__c
                                                  from MA_Community_Events__c where Name = 'event test 1'] ;
        System.assert(commEvent.size() != 0, MA_TestUtilityValues.EVENT_NOT_FOUND);  
        commEvent[0].All_Day_Event__c = true;
        Update commEvent;
        System.assertEquals(true, commEvent[0].All_Day_Event__c);   
    }
    
}