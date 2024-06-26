@istest
public class Test_PF_NHWRecruitmentJobAppDataMapper {

    @testSetup
    static void init() {
        NH_Settings__c nhs = new NH_Settings__c(NoOfDaysBeforeStartDateToSendRemindEmail__c = 15,Valid_AD_Email_Domains__c='salesforce.com');
        insert nhs;
        
    }

	//WD4S -Case-creation getting worker email from candidate contact if available
    @isTest
    static void workerEmailPresentOnCandidateContact() {
        WDR_Testfactory testdata = new WDR_Testfactory();
        testdata.createJobApp();
        WDR_Application__c defaultJobApplication = testdata.getDefaultJobApp();
        defaultJobApplication.Start_Date__c = System.Today().addDays(16);

        Test.startTest();
            defaultJobApplication.Candidate_Stage__c = 'Placement';
        	WDR_Candidate__c cand = testdata.getDefaultCandidate();
        	Contact cont = [Select id,email from contact where id=:cand.Candidate_Contact__c];
        	cont.SF_Work_Email__c = 'worker@email.com';
        	update cont;
            update defaultJobApplication;
        Test.stopTest();
        System.debug([select id,description__c,Error_Message__c ,Component__c ,Type__c ,error_type__c from PF_DEbug_Log__c]);
        List<Case> cases =[SELECT Id, Email_Address__c FROM Case WHERE NHW_Job_Application__c = :defaultJobApplication.id];
        System.assertEquals(cases[0].Email_Address__c,cont.SF_Work_Email__c);
    }
    
    //WD4S -Case-creation worker email is not available on candidate contact - set to personal email
    @isTest
    static void workerEmailAbsentOnCandidateContact() {
        WDR_Testfactory testdata = new WDR_Testfactory();
        testdata.createJobApp();
        WDR_Application__c defaultJobApplication = testdata.getDefaultJobApp();
        WDR_Candidate__c defaultCandidate = testdata.getDefaultCandidate();
        defaultJobApplication.Start_Date__c = System.Today().addDays(16);

        Test.startTest();
            defaultJobApplication.Candidate_Stage__c = 'Placement';
            update defaultJobApplication;
        Test.stopTest();
        List<Case> cases =[SELECT Id, Email_Address__c FROM Case WHERE NHW_Job_Application__c = :defaultJobApplication.id];
        System.assertEquals(cases[0].Email_Address__c,defaultCandidate.email__c.tolowercase());
    }

    //WD4S - verify resource type on preboarding case when employment type is 'Regular'
    @isTest
    static void verifyRegularResourceTypeOnCase() {
        WDR_Testfactory testdata = new WDR_Testfactory();
        testdata.createJobApp();
        WDR_Application__c defaultJobApplication = testdata.getDefaultJobApp();
        WDR_Job__c defaultJobReq = testdata.getDefaultJobReq();
        defaultJobApplication.Start_Date__c = System.Today().addDays(16);

        Test.startTest();
        	defaultJobReq.Employment_Type__c = 'Regular';
        	update defaultJobReq;
            defaultJobApplication.Candidate_Stage__c = 'Placement';
            update defaultJobApplication;
        Test.stopTest();
        List<Case> cases =[SELECT Id, Resource_Type__c FROM Case WHERE NHW_Job_Application__c = :defaultJobApplication.id];
        System.assertEquals(cases[0].Resource_Type__c,'SFDC Employee');
    }
    
    //WD4S - verify resource type on preboarding case when employment type is not 'Regular'
    @isTest
    static void verifyOtherResourceTypeOnCase() {
        WDR_Testfactory testdata = new WDR_Testfactory();
        testdata.createJobApp();
        WDR_Application__c defaultJobApplication = testdata.getDefaultJobApp();
        WDR_Job__c defaultJobReq = testdata.getDefaultJobReq();
        defaultJobApplication.Start_Date__c = System.Today().addDays(16);

        Test.startTest();
        	defaultJobReq.Employment_Type__c = 'Intern';
        	update defaultJobReq;
            defaultJobApplication.Candidate_Stage__c = 'Placement';
            update defaultJobApplication;
        Test.stopTest();
        List<Case> cases =[SELECT Id, Resource_Type__c FROM Case WHERE NHW_Job_Application__c = :defaultJobApplication.id];
        System.assertEquals(cases[0].Resource_Type__c,'Intern');
    }
    
}