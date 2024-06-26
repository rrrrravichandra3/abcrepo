/**
* @author Manish 
* @date 12/07/2022
*
* @description Test Class for IA_ServiceAppointmentDecomission
*
*/
@isTest(isParallel=false) 
public class IA_ServiceAppointmentDecomissionTest {
   @testSetup
    static void setup() {
        test.startTest();
        UserRole ur = new UserRole(Name = 'CEO');
        insert ur;
        User thisUser = new User(Id = UserInfo.getUserId(), UserRoleId = ur.Id);
        update thisUser;

        
        // Assign the below profile Id for the users
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Customer Portal Manager Standard' LIMIT 1];
        System.runAs(thisUser) {
            // Accounts
            Account testAccount = new Account(Name = 'TestAccount');
            insert testAccount;
            //Contacts
            List<Contact> testContacts = new List<Contact>();
            for (Integer i = 0; i < 5; i++) {
                Contact testContact = new Contact(LastName = 'testLastName' + i, Email = 'test' + i + '@test.com', AccountId = testAccount.id);
                testContacts.add(testContact);
            }
            insert testContacts;
            
            //Users
            List<User> testUsers = new List<User>();
            for (Integer i = 0; i < 5; i++) {
                User testUser = new User(Username = 'testCandidate' + i + '@testuser.com', LastName = 'User' + i, Email = 'test' + i + '@test.com', Alias = 'tUser', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = profileId.Id, contactId = testContacts[i].id, LanguageLocaleKey = 'en_US');
                testUsers.add(testUser);
            }
            insert testUsers;
            
            WDR_Job__c job = new WDR_Job__c (
            Name='Test Job',
            Job_Code__c = '123456',
            Hiring_Manager__c=testUsers[0].Id
        );
        insert job;
            //Insert WDR Candidate
        WDR_Candidate__c wdCandidate1 = new WDR_Candidate__c(
            Name = 'test candidate1',
            First_Name__c ='test',
            Last_Name__c = 'candidate',
            Email__c = 'test1231@noemail.com',
            Candidate_Contact__c = testContacts[0].id
        );
        insert wdCandidate1;
        
        WDR_Application__c wdApp2 = new WDR_Application__c (
            Candidate__c =  wdCandidate1.Id,
            Job__c = job.Id,
            Candidate_Stage__c = 'Screen',
            Internal_Candidate__c = true,
            Offer_type__c='FTE'
        );
        insert wdApp2;
            //Service Resources
            List<ServiceResource> testServiceResources = new List<ServiceResource>();
            for (Integer i = 0; i < 4; i++) {
                ServiceResource testServiceResource = new ServiceResource(
                    Name = 'TestUser' + i, 
                    Contact__c = testContacts[i].id, 
                    Volunteer_Email__c = 'testemail' + i + '@testemail' + i + '.com', 
                    Job_Title__c = 'Software Developer', 
                    RelatedRecordId = testUsers[i].id, 
                    IsActive = true, 
                    Primary_Territory_Assigned__c = true,
                    Slot_1_Day__c = 'Monday',
                    Slot_2_Day__c = 'Tuesday',
                    Slot_2_Start_Time__c = Time.newInstance(10, 0, 0, 0),
                    Slot_1_Start_Time__c = Time.newInstance(10, 0, 0, 0)
                );
                if (i == 0) {
                    testServiceResource.Number_Of_Meetings_This_Month__c = 3;
                    testServiceResource.Number_Of_Meetings_Next_Month__c = 3;
                } else if (i == 1) {
                    testServiceResource.Number_Of_Meetings_This_Month__c = 4;
                    testServiceResource.Number_Of_Meetings_Next_Month__c = 4;
                } else if (i == 2) {
                    testServiceResource.Number_Of_Meetings_This_Month__c = 2;
                    testServiceResource.Number_Of_Meetings_Next_Month__c = 4;
                } else if (i == 3) {
                    testServiceResource.Number_Of_Meetings_This_Month__c = 4;
                    testServiceResource.Number_Of_Meetings_Next_Month__c = 2;
                }
                testServiceResources.add(testServiceResource);
            }
            insert testServiceResources;
            //Operating Hours
            OperatingHours optHour = new OperatingHours(name = 'Pacific Standard Time');
            insert optHour;
            // Insert TimeSlots
            List<TimeSlot> lstTimeslots = new List<TimeSlot>();
            List<String> dayOfWeekNames = new List<String>{ 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday' };
                Time startTimeSlot1 = Time.newInstance(11, 0, 0, 0);
            Time endTimeSlot1 = Time.newInstance(11, 30, 0, 0);
            Time startTimeSlot2 = Time.newInstance(10, 0, 0, 0);
            Time endTimeSlot2 = Time.newInstance(10, 30, 0, 0);
            for (String dayOfWeek : dayOfWeekNames) {
                for (Integer i = 0; i < 2; i++) {
                    TimeSlot timeSlotRecord = new TimeSlot(OperatingHoursId = optHour.id, DayOfWeek = dayOfWeek);
                    if (i == 0) {
                        timeSlotRecord.StartTime = startTimeSlot1;
                        timeSlotRecord.EndTime = endTimeSlot1;
                    }
                    if (i == 1) {
                        timeSlotRecord.StartTime = startTimeSlot2;
                        timeSlotRecord.EndTime = endTimeSlot2;
                    }
                    lstTimeslots.add(timeSlotRecord);
                }
            }
            insert lstTimeslots;
            //ServiceTerritory
            ServiceTerritory srvTerritory = new ServiceTerritory(name = 'PacificStandardtime', OperatingHoursId = optHour.Id, IsActive = true);
            insert srvTerritory;
            //ServiceTerritoryMember
            datetime startdate = System.now();
            datetime enddatetime = startdate.addDays(2);
            list<ServiceTerritoryMember> srvTerritoryMembs = new List<ServiceTerritoryMember>();
            for (Integer i = 0; i < 4; i++) {
                ServiceTerritoryMember srvTerritoryMemb = new ServiceTerritoryMember(ServiceResourceId = testServiceResources[i].id, ServiceTerritoryId = srvTerritory.Id, OperatingHoursId = optHour.Id, EffectiveStartDate = startdate, EffectiveEndDate = enddatetime);
                srvTerritoryMembs.add(srvTerritoryMemb);
            }
            insert srvTerritoryMembs;
           test.stopTest();
        }
    }
    
    /********************************************************************
* @description : Test to check status change
* 				
*/
    @isTest
    static void updateServiceAppointmentForRejectedCandidateTest() {
        Date slotDate = Date.today().adddays(2);
        Time startTime = Time.newInstance(10, 0, 0, 0);
        Time endTime = Time.newInstance(10, 30, 0, 0);
        Datetime startdateTime = Datetime.newInstance(slotDate, startTime);
        Datetime enddateTime = Datetime.newInstance(slotDate, endTime);
        
        List<contact> contacts = [SELECT Id FROM Contact WHERE LastName = 'testLastName0'];
        List<Account> accounts = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        List<ServiceResource> srvRes = [SELECT Id FROM ServiceResource WHERE Name = 'TestUser0'];
        ServiceAppointment svApt = new ServiceAppointment(ContactId = contacts[0].Id, ParentRecordId = accounts[0].Id, SchedStartTime = startdateTime, SchedEndTime = enddateTime, Status = 'Scheduled', Insider_Volunteer__c = srvRes[0].id);
        test.startTest();
        insert svApt;
        List<id> ids = new List<id>();
        for(Contact c:contacts){
            ids.add(c.id);
        }
        WDR_Candidate__c candidateId = [Select id from WDR_Candidate__c LIMIT 1];
         ids.add(candidateId.id);
        
        IA_ServiceAppointmentDecomission.updateServiceAppointmentForRejectedCandidate(ids);
    	test.stopTest();
    }
}