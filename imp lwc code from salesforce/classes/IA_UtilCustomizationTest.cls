/**
 * @author Lucas Olivera
 * @date 08/02/2021
 *
 * @description Test Class for IA_UtilCustomization
 *
 */
@isTest(isParallel=false) 
private class IA_UtilCustomizationTest {
    @testSetup
    static void setup() {
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

            //Service Resources
            List<ServiceResource> testServiceResources = new List<ServiceResource>();
            for (Integer i = 0; i < 4; i++) {
                ServiceResource testServiceResource = new ServiceResource(Name = 'TestUser' + i, Contact__c = testContacts[i].id, 
                                                                          Volunteer_Email__c = 'testemail' + i + '@testemail' + i + '.com', Job_Title__c = 'Software Developer', 
                                                                          RelatedRecordId = testUsers[i].id, IsActive = true, Primary_Territory_Assigned__c = true,
                                                                          Slot_1_Start_Time__c=system.Now().Time(),Slot_2_Start_Time__c = system.Now().addMinutes(40).Time()
                                                                         );
                testServiceResources.add(testServiceResource);
            }
            testServiceResources[0].Preferred_Name__c = 'Testie0';
            insert testServiceResources;

            // WDR Candidate
            List<WDR_Candidate__c> testWDRCandidateList = new List<WDR_Candidate__c>();
            for (Integer i = 0; i < 4; i++) {
                WDR_Candidate__c candidate = new WDR_Candidate__c(Name = 'Candidate Test' + i, First_Name__c = 'Candidate', Last_Name__c = 'Test' + i, Email__c = 'candidatetestemail' + i + '@email.com', Candidate_Contact__c = testContacts[i].Id);
                testWDRCandidateList.add(candidate);
            }
            insert testWDRCandidateList;

            // WDR Job
            WDR_Job__c job = new WDR_Job__c(Name = 'Test Job', Job_Code__c = '123456', Hiring_Manager__c = testUsers[0].Id, Job_Family_Group__c = 'CSG', Job_Level__c = '3', Division__c = 'Americas - USA');
            insert job;

            // WDR Application
            List<WDR_Application__c> testWDRApplication = new List<WDR_Application__c>();
            for (Integer i = 0; i < 4; i++) {
                WDR_Application__c application = new WDR_Application__c(Candidate__c = testWDRCandidateList[i].Id, Candidate_Stage__c = 'Placement', Offer_Type__c = 'Test', Job__c = job.Id);
                testWDRApplication.add(application);
            }
            testWDRApplication[3].Start_Date__c = Date.newInstance(2016, 12, 9);
            insert testWDRApplication;

            // Update Contacts MPA field
            for (Integer i = 0; i < 4; i++) {
                testContacts[i].MPA_App__c = testWDRApplication[i].Id;
            }
            update testContacts;
        }
    }

    /*******************************************************************************************************
     * @description Test getCandidateStartDateTest.
     */
    @isTest
    static void getCandidateStartDateTest() {
        IA_UtilCustomization instance = new IA_UtilCustomization();
        Test.startTest();
        instance.candidateContactId = [SELECT Id FROM Contact LIMIT 1].Id;
        String testDateString = instance.getCandidateStartDate();
        instance.candidateContactId = [SELECT Id FROM Contact WHERE LastName = 'testLastName3' LIMIT 1].Id;
        String testDateString2 = instance.getCandidateStartDate();
        Test.stopTest();

        System.assertEquals(' soon', testDateString, 'String should be " soon".');
    }
}