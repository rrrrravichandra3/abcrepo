/**
 * @author Apuroop Gadde
 * @date 09-13-2017
 * @group Unit Test Classes
 * @description Unit tests for testing methods in IFB_NewSIFTInterviewWizardUtil
 */
@isTest
private class IFBTest_NewSIFTInterviewWizardUtil {
	/**
	 * @description Method to setup test data and configurations for unit tests
	 */
	/* 
	@testSetup
	static void testSetup() {

	}
	*/

	/**
	 * @description Method to test getIntrvwRTsForMatchingGroupAndPosition when input is null
	 */
	 /*
	@isTest
	static void testGetIntrvwRTsForMatchingGroupAndPositionWithNullInput() {
		List<IFB_SelectOption> intRecordTypes = IFB_NewSIFTInterviewWizardUtil.getIntrvwRTsForMatchingGroupAndPosition(null);
		System.assertEquals(intRecordTypes.size(),0,'Error when retreiving record types for null input');
	}
	*/

	/**
	 * @description Method to test getIntrvwRTsForMatchingGroupAndPosition when input is invalid
	 */
	 /*
	@isTest
	static void testGetIntrvwRTsForMatchingGroupAndPositionWithInvalidInput() {
		List<IFB_SelectOption> intRecordTypes = IFB_NewSIFTInterviewWizardUtil.getIntrvwRTsForMatchingGroupAndPosition('test group');
		System.assertEquals(intRecordTypes.size(),0,'Error when retreiving record types for invalid input');
	}
	*/

	/**
	  * @description Method to test getInterviewsForRecruit when the input string is empty
	  */
	 /*
	 @isTest
	 static void testGetInterviewsForRecruitWithNullInput() {
	 	List<IFB_Interview__c> relatedInterviews = IFB_NewSIFTInterviewWizardUtil.getInterviewsForRecruit(null);
	 	System.assertEquals(relatedInterviews.size(),0,'Interviews not returned properly when input string is null');
	 }
	 */

	 /**
	  * @description Method to test getInterviewsForRecruit when the input string is valid
	  */
	 /*
	 @isTest
	 static void testGetInterviewsForRecruitWithValidInput() {
        IFB_Interview_Candidate__c recruit = new IFB_Interview_Candidate__c(First_Name__c='Candidate0', Last_Name__c='Recruit0', Email__c='test@test.com',
                                        Recruiter_Intro__c = 'test Intro', Region__c='AMER', Zone__c='AMER East',City__c ='New York', State__c='N/A',Do_not_sync_with_WDR__c = false);
        insert recruit;
        IFB_Interview__c interview = IFBTestData_Interview.getInterview(null, IFBTestData_Interview.Option.SALES_FIRST, 
                                    recruit, null, null, null, null, null, null);
        insert interview;	 	
	 	List<IFB_Interview__c> relatedInterviews = IFB_NewSIFTInterviewWizardUtil.getInterviewsForRecruit(recruit.Id);
	 	System.assertEquals(relatedInterviews.size(),1,'Interviews not returned properly when input string is valid');
	 }
	 */

	 /**
	  * @description Method to test getWDJobApplication when the input is null
	  */
	 /*
	 @isTest
	 static void testGetWDJobApplicationWithNullInput() {
	 	WDR_Application__c testApplication = IFB_NewSIFTInterviewWizardUtil.getWDJobApplication(null);
	 	System.assertEquals(testApplication,null,'Error getting job application when input is null');
	 }
	 */

	 /**
	  * @description Method to test getWDJobApplication when the input is valid
	  */
	  /*
	 @isTest
	 static void testGetWDJobApplicationWithValidInput() {
		WDR_Application__c testWDApplication= WDR_TestUtils.createWDRApplication();	 	
	 	WDR_Application__c testApplication = IFB_NewSIFTInterviewWizardUtil.getWDJobApplication(testWDApplication.Id);
	 	System.assertEquals(testApplication.Id,testWDApplication.ID,'Error getting job application when input is valid');
	 }
	 */
}