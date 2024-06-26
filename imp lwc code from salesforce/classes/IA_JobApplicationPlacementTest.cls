/**
 * @author Lucas Olivera
 * @date 07-23-2021
 *
 * @description Test Class for IA_JobApplicationPlacement.cls
 *
 */
@isTest
private class IA_JobApplicationPlacementTest {
    @testSetup
    static void setup() {
        IA_Program_Admin__c cs = new IA_Program_Admin__c();
        cs.Name = 'HireEmailCC';
        cs.EmailsToCC__c = 'test@test.com';
        insert cs;
        
        User thisUser = [SELECT Id,UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
        List<User> usersList = new List<User>();
        System.runAs(thisUser) {
            Profile pr = [SELECT id FROM Profile WHERE name='System administrator' limit 1]; 
            UserRole ur = [SELECT id FROM UserRole WHERE name='Do_NOT_Create_SubOrd_SharingRules'];

            for (Integer i = 0; i < 5; i++) {
                User userWithRole = new User(alias = 'test05',
                                    email ='test12345@noemail.com',
                                    emailencodingkey = 'UTF-8',
                                    firstName = 'Test user5',
                                    lastname = 'Testin05'+i,
                                    languagelocalekey = 'en_US',
                                    localesidkey = 'en_US',
                                    profileid = pr.Id,
                                    country = 'United States',
                                    timezonesidkey = 'America/Los_Angeles',
                                    username = 'test05' + i + '@noemail.com',
                                    userroleId = ur.Id);
                usersList.add(userWithRole);
            }
            insert usersList;
        }

        Account acc = new Account(
            name = 'Test Account',
            ownerId = usersList[0].id
        );
        insert acc;
            

        List<Contact> testContactList = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            Contact con = new Contact(firstname = 'Test' + i,
                                    lastname = 'Contact' + i,
                                    AccountId = acc.id,
                                    email = 'testcontactemail'+i+'@test.com',        
                                    recordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('WDR_Candidate')
        .getRecordTypeId());
            testContactList.add(con);
        }
        insert testContactList;

        List<WDR_Job__c> testWDRJobList = new List<WDR_Job__c>();
        for (Integer i = 0; i < 5; i++) {
            WDR_Job__c job = new WDR_Job__c (Name = 'Test Job'+i,
                                          Job_Code__c = '123456'+i,
                                          Hiring_Manager__c = thisUser.Id,
                                          Job_Family_Group__c ='CSG',
                                          Job_Level__c = '3',
                                          Division__c = 'Americas - USA');
            testWDRJobList.add(job);
        }
        insert testWDRJobList;

        //Insert WDR Candidate
        List<WDR_Candidate__c> testWDRCandidateList = new List<WDR_Candidate__c>();
        for (Integer i = 0; i < 5; i++) {
            WDR_Candidate__c wdCandidate = new WDR_Candidate__c(Name = 'test candidate',
                                                            First_Name__c ='test',
                                                            Last_Name__c = 'candidate',
                                                            Email__c = 'testvin@test.com',
                                                            Candidate_Contact__c = testContactList[i].Id);
            testWDRCandidateList.add(wdCandidate);
        }        
        insert testWDRCandidateList;

        //Insert WDR Application
        List<WDR_Application__c> testWDRApplicationList = new List<WDR_Application__c>();
        for (Integer i = 0; i < 5; i++) {
            WDR_Application__c wdApp = new WDR_Application__c (Candidate__c = testWDRCandidateList[i].Id,
                                                            Job__c = testWDRJobList[i].Id,
                                                            Candidate_Stage__c = 'Interview',
                                                            Offer_type__c = 'FTE',
                                                            Boomerang__c = false,
                                                            Internal_Candidate__c = false,
                                                            Confidential__c = false,
                                                            Application_Step__c = 'Round 2');
            testWDRApplicationList.add(wdApp);
        }
        insert testWDRApplicationList;


        // ServiceResource
        List<ServiceResource> testServiceResourceList = new List<ServiceResource>();
        for (Integer i = 0; i < 5; i++) {
            ServiceResource testServiceResource = new ServiceResource(Name = 'TestJAPT'+i,
                                                                Contact__c = testContactList[0].id,
                                                                Volunteer_Email__c = 'testemailJAPT@testemailJAPT.com',
                                                                Job_Title__c = 'Software Developer',
                                                                RelatedRecordId = usersList[i].id,
                                                                IsActive = true,
                                                                Primary_Territory_Assigned__c = true,
                                                                Slot_1_Start_Time__c=system.Now().Time(),
                                                                Slot_2_Start_Time__c = system.Now().addMinutes(40).Time());
            testServiceResourceList.add(testServiceResource);
        }        
        insert testServiceResourceList;

        // ServiceAppointment
        Date slotDate=Date.today().adddays(2);
        Time startTime=Time.newInstance(10, 0, 0, 0);
        Time endTime=Time.newInstance(10, 30, 0, 0);
        
		Datetime startdateTime=Datetime.newInstance(slotDate,startTime);
        Datetime enddateTime=Datetime.newInstance(slotDate,endTime);

        List<ServiceAppointment> testServiceAppointmentList = new List<ServiceAppointment>();
        for (Integer i = 0; i < 5; i++) {
            ServiceAppointment sa = new ServiceAppointment(
                Insider_Volunteer__c = testServiceResourceList[i].Id,
                ContactId = testContactList[i].Id,
                Email = testServiceResourceList[i].Volunteer_Email__c,
                SchedStartTime = startdateTime,
                SchedEndTime = enddateTime,
                ParentRecordId = acc.Id,
                Status = 'Completed'
            );            
            testServiceAppointmentList.add(sa);
        }
        insert testServiceAppointmentList;        
    }

    @IsTest
    static void updateServiceAppointmentForRejectedCandidateTest(){
        // Updating WDR_Application__c to trigger the email notification
        TF2_Business_Site__c bs = new TF2_Business_Site__c(
            Name = 'Test Business Site',
            Country__c = 'USA',
            Street_Address__c = 'Test Street Address',
            Type__c = 'Test'
        );
        insert bs;

        Date startDate = Date.today().adddays(3);

        WDR_Application__c jobApp = [SELECT Id FROM WDR_Application__c LIMIT 1];
        jobApp.Candidate_Stage__c = 'Placement';
        jobApp.Start_Date__c = startDate;
        jobApp.Business_Site__c = bs.Id;
        update jobApp;

        List<Id> jobAppIdList = new List<Id>();
        jobAppIdList.add(jobApp.Id);

        Test.startTest();
        // Case 1: Custom Setting has email address
        IA_JobApplicationPlacement.sendCandidateHireNotificationToVolunteer(jobAppIdList);        
        
        // Case 2: Custom Setting does not have email address
        IA_Program_Admin__c cs = [SELECT EmailsToCC__c FROM IA_Program_Admin__c LIMIT 1];
        cs.EmailsToCC__c = '';
        update cs;
        
        IA_JobApplicationPlacement.sendCandidateHireNotificationToVolunteer(jobAppIdList);
        Test.stopTest(); 
        
        System.assertEquals('Placement', jobApp.Candidate_Stage__c, 'WDR_Application__c record should be in Placement stage to trigger the email notification.');
    }
}