/**
 * @author Apuroop Gadde
 * @date 09-13-2017
 * @group Unit Test Classes
 * @description Unit tests for testing methods in IFB_WDJobToSIFTInterview
 */
@isTest
private class IFB_WDJobToSIFTInterviewTest {
    /**
    * @description Method to setup test data and configurations for unit tests
    **/
    @testSetup 
    static void testSetup() {
    	WDR_Application__c testWDApplication= WDR_TestUtils.createWDRApplication();
        //testWDApplication = [SELECT Job__c,Job__r.Hiring_Manager__c from WDR_Application__c where Id = :testWDApplication.Id];
        IFB_Interview_Candidate__c recruit = new IFB_Interview_Candidate__c(First_Name__c='Candidate0', Last_Name__c='Recruit0', 
                                Email__c='test@test.com', Recruiter_Intro__c = 'test Intro', Region__c='AMER', Zone__c='AMER East',
                                City__c ='New York', State__c='N/A',Do_not_sync_with_WDR__c = false);
        insert recruit;
        
        testWDApplication.Is_this_a_SIFT_Interview__c = 'Yes';
        testWDApplication.SIFT_Recruit__c = recruit.Id;
        update testWDApplication;

        IFB_Interview__c interview = IFBTestData_Interview.getInterview(null, IFBTestData_Interview.Option.SALES_FIRST, 
                                    recruit, null, null, null, null, null, null);
        insert interview;

    }

    /**
     * @description Method to test class constructor with null input
     */
    @isTest
    static void testConstructorWithNull() {
        IFB_WDJobToSIFTInterview testObject = new IFB_WDJobToSIFTInterview(null);
        System.assertEquals(0,testObject.listWDJobIds.size(), 'Class was not initialized properly with null input');
    }

    /**
     * @description Method to test updates on Interview happen when related fields change on WD Job Req
     */
     @isTest
     static void testWDJobReqRelatedFieldsUpdateOnInterview() {
     	WDR_Job__c testJob = [SELECT Id,Hiring_Manager__c,Region__c FROM WDR_Job__c WHERE name = 'test job' LIMIT 1];
     	User newHiringManager = WDR_TestUtils.createHiringManagerWithNoHeirarchy('newFName','newLName');
     	testJob.Hiring_Manager__c = newHiringManager.Id;
        testJob.Region__c = 'updated Region';
     	Test.startTest();
     	update testJob;
     	Test.stopTest();
     	IFB_Interview_Candidate__c recruit = [SELECT Id, Job_Application_WDR__c,Region__c from IFB_Interview_Candidate__c where 
                                              First_Name__c='Candidate0' and Last_Name__c='Recruit0' LIMIT 1];
     	IFB_Interview__c relatedInterview = [SELECT Hiring_Manager__c from IFB_Interview__c where Candidate__c = :recruit.Id];
     	System.assertEquals(newHiringManager.Id,relatedInterview.Hiring_Manager__c,'Hiring Manager is not updated on interview');
     }
}