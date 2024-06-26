/**
 * @description       : Test Class for IA_UpdateNumberOfAppointmentsBatch
 * @author            : Sri Kolagani
 * @last modified on  : 09-24-2021
 * 
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   02-10-2021   Sri Kolagani                         Initial Version
 * 1.1   09-24-2021   Lucas Olivera						   Increased test coverage
 **/
@isTest(isParallel=false) 
private class IA_UpdateNumberOfAppointmentsBatchTest {
  @testSetup
  static void setup() {
    UserRole ur = new UserRole(Name = 'CEO');
    insert ur;
    User thisUser = new User(Id = UserInfo.getUserId(), UserRoleId = ur.Id);
    update thisUser;

    // Assign the below profile Id for the users
    Profile profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = 'Customer Portal Manager Standard'
      LIMIT 1
    ];
    System.runAs(thisUser) {
      // Accounts
      Account testAccount = new Account(Name = 'TestAccount');
      insert testAccount;

      //Contacts
      List<Contact> testContacts = new List<Contact>();
      for (Integer i = 0; i < 5; i++) {
        Contact testContact = new Contact(
          LastName = 'testLastName' + i,
          Email = 'test' + i + '@test.com',
          AccountId = testAccount.id
        );
        testContacts.add(testContact);
      }
      insert testContacts;

      //Users
      List<User> testUsers = new List<User>();
      for (Integer i = 0; i < 5; i++) {
        User testUser = new User(
          Username = 'testCandidate' + i + '@testuser.com',
          LastName = 'User' + i,
          Email = 'test' + i + '@test.com',
          Alias = 'tUser',
          TimeZoneSidKey = 'America/Los_Angeles',
          LocaleSidKey = 'en_US',
          EmailEncodingKey = 'UTF-8',
          ProfileId = profileId.Id,
          contactId = testContacts[i].id,
          LanguageLocaleKey = 'en_US'
        );
        testUsers.add(testUser);
      }
      insert testUsers;

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
          Slot_1_Start_Time__c = Time.newInstance(14, 30, 0, 0),
          Slot_2_Start_Time__c = Time.newInstance(15, 30, 0, 0)
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
        }
        testServiceResources.add(testServiceResource);
      }
      insert testServiceResources;

      //Operating Hours
      OperatingHours optHour = new OperatingHours(
        name = 'Pacific Standard Time'
      );
      insert optHour;

      // Insert TimeSlots
      List<TimeSlot> lstTimeslots = new List<TimeSlot>();
      List<String> dayOfWeekNames = new List<String>{
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday'
      };
      Time startTimeSlot1 = Time.newInstance(11, 0, 0, 0);
      Time endTimeSlot1 = Time.newInstance(11, 30, 0, 0);
      Time startTimeSlot2 = Time.newInstance(10, 0, 0, 0);
      Time endTimeSlot2 = Time.newInstance(10, 30, 0, 0);
      for (String dayOfWeek : dayOfWeekNames) {
        for (Integer i = 0; i < 2; i++) {
          TimeSlot timeSlotRecord = new TimeSlot(
            OperatingHoursId = optHour.id,
            DayOfWeek = dayOfWeek
          );
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
      ServiceTerritory srvTerritory = new ServiceTerritory(
        name = 'PacificStandardtime',
        OperatingHoursId = optHour.Id,
        IsActive = true
      );
      insert srvTerritory;

      //ServiceTerritoryMember
      datetime startdate = System.now();
      datetime enddatetime = startdate.addDays(2);
      list<ServiceTerritoryMember> srvTerritoryMembs = new List<ServiceTerritoryMember>();
      for (Integer i = 0; i < 4; i++) {
        ServiceTerritoryMember srvTerritoryMemb = new ServiceTerritoryMember(
          ServiceResourceId = testServiceResources[i].id,
          ServiceTerritoryId = srvTerritory.Id,
          OperatingHoursId = optHour.Id,
          EffectiveStartDate = startdate,
          EffectiveEndDate = enddatetime
        );
        srvTerritoryMembs.add(srvTerritoryMemb);
      }

      insert srvTerritoryMembs;
    }
  }

  @isTest
  static void ghostModeScheduledStatusTest() {
    Date slotDate = Date.today().adddays(2);
    Time startTime = Time.newInstance(10, 0, 0, 0);
    Time endTime = Time.newInstance(10, 30, 0, 0);

    Datetime startdateTime = Datetime.newInstance(slotDate, startTime);
    Datetime enddateTime = Datetime.newInstance(slotDate, endTime);

    List<contact> contacts = [
      SELECT Id
      FROM Contact
      WHERE LastName = 'testLastName2'
    ];
    List<Account> accounts = [
      SELECT Id
      FROM Account
      WHERE Name = 'TestAccount'
    ];
    List<ServiceResource> srvRes = [
      SELECT Id
      FROM ServiceResource
      WHERE Name = 'TestUser2'
      OR Name = 'TestUser3'
    ];

    List<ServiceAppointment> saList = new List<ServiceAppointment>();
    ServiceAppointment svApt = new ServiceAppointment(
      ContactId = contacts[0].Id,
      ParentRecordId = accounts[0].Id,
      SchedStartTime = startdateTime,
      SchedEndTime = enddateTime,
      Status = 'Scheduled',
      Insider_Volunteer__c = srvRes[0].id
    );
    ServiceAppointment svAptNextMonth = new ServiceAppointment(
      ContactId = contacts[0].Id,
      ParentRecordId = accounts[0].Id,
      SchedStartTime = startdateTime.addMonths(1),
      SchedEndTime = enddateTime.addMonths(1),
      Status = 'Scheduled',
      Insider_Volunteer__c = srvRes[0].id
    );
    ServiceAppointment svAptLastMonth = new ServiceAppointment(
      ContactId = contacts[0].Id,
      ParentRecordId = accounts[0].Id,
      SchedStartTime = startdateTime.addMonths(-1),
      SchedEndTime = enddateTime.addMonths(-1),
      Status = 'Scheduled',
      Insider_Volunteer__c = srvRes[0].id
    );
    saList.add(svApt);
    saList.add(svAptNextMonth);
    saList.add(svAptLastMonth);
    insert saList;

    
    Map<Id, List<ServiceAppointment>> meetingsMonthMap = new Map<Id, List<ServiceAppointment>>();
    meetingsMonthMap.put(srvRes[0].Id, saList);

    IA_UpdateNumberOfAppointmentsBatch batch = new IA_UpdateNumberOfAppointmentsBatch();
    batch.serviceResourcetoAppointmentsNextMonth = meetingsMonthMap;
    batch.serviceResourcetoAppointmentsLastMonth = meetingsMonthMap;
    batch.serviceResourcetoAppointmentsThisMonth = meetingsMonthMap;
    

    Map<Id, String> failedRecordsMap = new Map<Id, String>();
    failedRecordsMap.put(saList[0].Id, 'Test error');
    batch.failedUpdateRecords = failedRecordsMap;

    DataBase.executeBatch(batch);

    ServiceResource serRes = [
      SELECT Id, Number_Of_Meetings_This_Month__c
      FROM ServiceResource
      WHERE Id = :srvRes[0].id
    ];
    System.assert(serRes.Number_Of_Meetings_This_Month__c > 0 == true);
  }

  @isTest
  static void ghostModeCanceledStatusTest() {
    Date slotDate = Date.today().adddays(2);
    Time startTime = Time.newInstance(10, 0, 0, 0);
    Time endTime = Time.newInstance(10, 30, 0, 0);

    Datetime startdateTime = Datetime.newInstance(slotDate, startTime);
    Datetime enddateTime = Datetime.newInstance(slotDate, endTime);

    List<contact> contacts = [
      SELECT Id
      FROM Contact
      WHERE LastName = 'testLastName3'
    ];
    List<Account> accounts = [
      SELECT Id
      FROM Account
      WHERE Name = 'TestAccount'
    ];
    List<ServiceResource> srvRes = [
      SELECT Id
      FROM ServiceResource
      WHERE Name = 'TestUser3'
    ];
    ServiceAppointment svApt = new ServiceAppointment(
      ContactId = contacts[0].Id,
      ParentRecordId = accounts[0].Id,
      SchedStartTime = startdateTime,
      SchedEndTime = enddateTime,
      Status = 'Canceled',
      Insider_Volunteer__c = srvRes[0].id
    );
    insert svApt;
    IA_UpdateNumberOfAppointmentsBatch batch = new IA_UpdateNumberOfAppointmentsBatch();
    DataBase.executeBatch(batch);
    ServiceResource serRes = [
      SELECT Id, Number_Of_Meetings_This_Month__c
      FROM ServiceResource
      WHERE Id = :srvRes[0].id
    ];
    List<ServiceAppointment> serviceAppt = [
      SELECT Id, Insider_Volunteer__c, StartDate__c, Status
      FROM ServiceAppointment
      WHERE
        (Status = 'Scheduled'
        OR Status = 'Completed'
        OR Status = 'Rescheduled')
        AND (StartDate__c = THIS_MONTH
        OR StartDate__c = NEXT_MONTH
        OR StartDate__c = LAST_MONTH)
        AND Insider_Volunteer__c = :srvRes[0].id
    ];
    System.assertEquals(
      serviceAppt.size(),
      serRes.Number_Of_Meetings_This_Month__c
    );
  }
}