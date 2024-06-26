/**
 * @author Lucas Olivera
 * @date 03/30/2022
 *
 * @description Test Class for IA_RecruiterNotification
 *
 */
@isTest
private class IA_RecruiterNotificationTest {
    @testSetup
    static void setup() {
        User thisUser = IA_TestDataFactory.createUserForRunAs();

        System.runAs(thisUser) {
            // Accounts
            List<Account> testAccountList = IA_TestDataFactory.createTestAccounts(1);
            insert testAccountList;

            // Contacts
            List<Contact> testContactList = IA_TestDataFactory.createTestContacts(testAccountList[0], 1);
            testContactList[0].recordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('WDR_Candidate').getRecordTypeId();
            insert testContactList;

            // Job Requisitions
            WDR_Job__c job = new WDR_Job__c(Name = 'Test Job', Job_Code__c = '123456',Job_Title__c ='Salesforce Developer', Hiring_Manager__c = thisUser.Id, Job_Family_Group__c = 'CSG', Job_Level__c = '3', 
                                            Division__c = 'Americas - USA', External_Recruiter_1__c = thisUser.Id, External_Recruiter_2__c = thisUser.Id, Recruitment_Coordinator_1__c = thisUser.Id, 
                                            Recruitment_Coordinator_2__c = thisUser.Id,Internal_Recruiter_1__c = thisUser.Id,Internal_Recruiter_2__c = thisUser.Id,Internal_Recruitment_Coordinator_1__c = thisUser.Id,
                                           Internal_Recruitment_Coordinator_2__c = thisUser.Id);
            insert job;
            
            // Job Requisitions
            WDR_Job__c job1 = new WDR_Job__c(Name = 'Test Job1', Job_Code__c = '123456',Job_Title__c ='Salesforce Developer', Hiring_Manager__c = thisUser.Id, Job_Family_Group__c = 'CSG', Job_Level__c = '3', 
                                            Division__c = 'Americas - USA', External_Recruiter_1__c = thisUser.Id, External_Recruiter_2__c = thisUser.Id, Recruitment_Coordinator_1__c = thisUser.Id, 
                                            Recruitment_Coordinator_2__c = thisUser.Id);
            insert job1;
            
            // Job Requisitions
            WDR_Job__c job2 = new WDR_Job__c(Name = 'Test Job2', Job_Code__c = '123456',Job_Title__c ='Salesforce Developer', Hiring_Manager__c = thisUser.Id, Job_Family_Group__c = 'CSG', Job_Level__c = '3', 
                                            Division__c = 'Americas - USA', External_Recruiter_1__c = thisUser.Id, External_Recruiter_2__c = thisUser.Id, Recruitment_Coordinator_1__c = thisUser.Id, 
                                            Recruitment_Coordinator_2__c = thisUser.Id,Internal_Recruitment_Coordinator_1__c = thisUser.Id);
            insert job2;

            // WDR Candidates
            WDR_Candidate__c wdCandidate = new WDR_Candidate__c(Name = 'test candidate', First_Name__c = 'test', Last_Name__c = 'candidate', Email__c = 'testvin@test.com', Candidate_Contact__c = testContactList[0].Id);
            insert wdCandidate;
            
            // WDR Candidates
            WDR_Candidate__c wdCandidate1 = new WDR_Candidate__c(Name = 'test candidate1', First_Name__c = 'test1', Last_Name__c = 'candidate1', Email__c = 'testvin1@test.com', Candidate_Contact__c = testContactList[0].Id);
            insert wdCandidate1;
            
            // WDR Candidates
            WDR_Candidate__c wdCandidate2 = new WDR_Candidate__c(Name = 'test candidate2', First_Name__c = 'test1', Last_Name__c = 'candidate1', Email__c = 'testvin1@test.com', Candidate_Contact__c = testContactList[0].Id);
            insert wdCandidate2;

            // WDR Applications
            WDR_Application__c wdApp = new WDR_Application__c(Candidate__c = wdCandidate.Id, Job__c = job.Id, Candidate_Stage__c = 'Interview', Offer_type__c = 'FTE', Boomerang__c = false, Internal_Candidate__c = false, Confidential__c = false, Application_Step__c = 'Round 2');
            insert wdApp;
            
            // WDR Applications
            WDR_Application__c wdApp1 = new WDR_Application__c(Candidate__c = wdCandidate1.Id, Job__c = job1.Id, Candidate_Stage__c = 'Interview', Offer_type__c = 'FTE', Boomerang__c = false, Internal_Candidate__c = true, Confidential__c = false, Application_Step__c = 'Round 2');
            insert wdApp1;
            
            // WDR Applications
            WDR_Application__c wdApp2 = new WDR_Application__c(Candidate__c = wdCandidate2.Id, Job__c = job2.Id, Candidate_Stage__c = 'Interview', Offer_type__c = 'FTE', Boomerang__c = false, Internal_Candidate__c = true, Confidential__c = false, Application_Step__c = 'Round 2');
            insert wdApp2;
        }

    }

    /********************************************************************
     * @description Test for sending email notifications to External
     * 				Recruiters 1 and 2 on Job Requisition
     */
    @isTest
    static void sendRecruiterNotificationTest() {
        List<WDR_Application__c> wdApps = [SELECT Id,Job__r.External_Recruiter_2__r.Email,Job__r.External_Recruiter_1__r.Email,
                                           Job__r.Recruitment_Coordinator_1__r.Email,Job__r.Recruitment_Coordinator_2__r.Email,
                                           Job__r.Internal_Recruiter_1__r.Email,Job__r.Internal_Recruiter_2__r.Email,
                                           Job__r.Internal_Recruitment_Coordinator_1__r.Email,Job__r.Internal_Recruitment_Coordinator_2__r.Email
                                           FROM WDR_Application__c where Job__r.Name = 'Test Job'];
        Test.startTest();
        List<Id> wdAppsIds = new List<Id>((new Map<Id, SObject>(wdApps)).keySet());
        IA_RecruiterNotification.sendRecruiterNotification(wdAppsIds);
        map<string,list<string>> testData = IA_RecruiterNotification.externallRecruiterNotification(wdApps[0]);
        IA_RecruiterNotification.internalRecruiterNotification(wdApps[0]);
        Integer invocations = Limits.getEmailInvocations();
        System.assertEquals(invocations, 0, 'No Emails Sent');
        Test.stopTest();
        // No System.assertEquals() since we are sending emails
    }
    
    /********************************************************************
     * @description Test for sending email notifications to External
     * 				Recruiters 1 and 2 on Job Requisition
     */
    @isTest
    static void sendRecruiterNotificationTest1() {
        List<WDR_Application__c> wdApps = [SELECT Id,Job__r.External_Recruiter_2__r.Email,Job__r.External_Recruiter_1__r.Email,
                                           Job__r.Recruitment_Coordinator_1__r.Email,Job__r.Recruitment_Coordinator_2__r.Email,
                                           Job__r.Internal_Recruiter_1__r.Email,Job__r.Internal_Recruiter_2__r.Email,
                                           Job__r.Internal_Recruitment_Coordinator_1__r.Email,Job__r.Internal_Recruitment_Coordinator_2__r.Email
                                           FROM WDR_Application__c where Job__r.Name = 'Test Job1'];
        Test.startTest();
        IA_RecruiterNotification.internalRecruiterNotification(wdApps[0]);
        Integer invocations = Limits.getEmailInvocations();
        System.assertEquals(invocations, 0, 'No Emails Sent');
        Test.stopTest();
        // No System.assertEquals() since we are sending emails
    }
    
    /********************************************************************
     * @description Test for sending email notifications to External
     * 				Recruiters 1 and 2 on Job Requisition
     */
    @isTest
    static void sendRecruiterNotificationTest2() {
        List<WDR_Application__c> wdApps = [SELECT Id,Job__r.External_Recruiter_2__r.Email,Job__r.External_Recruiter_1__r.Email,
                                           Job__r.Recruitment_Coordinator_1__r.Email,Job__r.Recruitment_Coordinator_2__r.Email,
                                           Job__r.Internal_Recruiter_1__r.Email,Job__r.Internal_Recruiter_2__r.Email,
                                           Job__r.Internal_Recruitment_Coordinator_1__r.Email,Job__r.Internal_Recruitment_Coordinator_2__r.Email
                                           FROM WDR_Application__c where Job__r.Name = 'Test Job2'];
        Test.startTest();
        IA_RecruiterNotification.internalRecruiterNotification(wdApps[0]);
        Integer invocations = Limits.getEmailInvocations();
        System.assertEquals(invocations, 0, 'No Emails Sent');
        Test.stopTest();
        // No System.assertEquals() since we are sending emails
    }
}