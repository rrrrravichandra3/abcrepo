/**
 * @author Apuroop Gadde
 * @date 09-13-2017
 * @group Unit Test Classes
 * @description Unit tests for testing methods in IFB_NewSIFTInterviewWizardCtrl
 */
@isTest
private class IFBTest_NewSIFTInterviewWizardCtrl {
	/**
	 * @description Method to setup test data and configurations for unit tests
	 */
	@testSetup
	static void testSetup() {

	}

	/**
	 * @description Method to test getInitialResources when the recruit is empty
	 */
	@isTest
	static void testGetInitialResourcesForEmptyRecruit() {
		WDR_Application__c testWDApplication= WDR_TestUtils.createWDRApplication();
		IFB_NewSIFTInterviewWizardCtrl.IFB_NewSIFTInterviewWizardCtrlInitialResources testInitialResources = null;
		try {
        	testInitialResources = IFB_NewSIFTInterviewWizardCtrl.getInitialResources('',(String)testWDApplication.Id,true);			
		} catch(Exception e) {
			System.assert(false,'Exception thrown when recruit is empty');
		}
		System.assertNotEquals(testInitialResources,null,'testInitialResources not initialized properly');
	}

	/**
	 * @description Method to test getInitialResources when the associated recruits does not have any interviews
	 */
	@isTest
	static void testGetInitialResourcesForRecruitWithNoInterviews() {
		WDR_Application__c testWDApplication= WDR_TestUtils.createWDRApplication();
        IFB_Interview_Candidate__c recruit = new IFB_Interview_Candidate__c(First_Name__c='Candidate0', Last_Name__c='Recruit0', Email__c='test@test.com',
                                        Recruiter_Intro__c = 'test Intro', Region__c='AMER', Zone__c='AMER East',City__c ='New York', State__c='N/A',Do_not_sync_with_WDR__c = false);
        insert recruit;
        testWDApplication.Is_this_a_SIFT_Interview__c = 'Yes';
        testWDApplication.SIFT_Recruit__c = recruit.Id;
        update testWDApplication;
		IFB_NewSIFTInterviewWizardCtrl.IFB_NewSIFTInterviewWizardCtrlInitialResources testInitialResources = null;
		try {
        	testInitialResources = IFB_NewSIFTInterviewWizardCtrl.getInitialResources((String)recruit.Id,(String)testWDApplication.Id,true);			
		} catch(Exception e) {
			System.assert(false,'Exception thrown when recruit is empty');
		}
		System.assertEquals(testInitialResources.createdInterviews.size(),0,'testInitialResources not initialized properly');
	}

	/**
	 * @description Method to test getInitialResources when the associated recruits has associated interviews
	 */
	@isTest
	static void testGetInitialResourcesForRecruitWithAssociatedInterviews() {
		WDR_Application__c testWDApplication= WDR_TestUtils.createWDRApplication();
        IFB_Interview_Candidate__c recruit = new IFB_Interview_Candidate__c(First_Name__c='Candidate0', Last_Name__c='Recruit0', Email__c='test@test.com',
                                        Recruiter_Intro__c = 'test Intro', Region__c='AMER', Zone__c='AMER East',City__c ='New York', State__c='N/A',Do_not_sync_with_WDR__c = false);
        insert recruit;
        testWDApplication.Is_this_a_SIFT_Interview__c = 'Yes';
        testWDApplication.SIFT_Recruit__c = recruit.Id;
        update testWDApplication;
        IFB_Interview__c interview = IFBTestData_Interview.getInterview(null, IFBTestData_Interview.Option.SALES_FIRST, 
                                    recruit, null, null, null, null, null, null);
        insert interview;
		IFB_NewSIFTInterviewWizardCtrl.IFB_NewSIFTInterviewWizardCtrlInitialResources testInitialResources = null;
		try {
        	testInitialResources = IFB_NewSIFTInterviewWizardCtrl.getInitialResources((String)recruit.Id,(String)testWDApplication.Id,true);			
		} catch(Exception e) {
			System.assert(false,'Exception thrown when recruit is empty');
		}
		System.assertEquals(testInitialResources.createdInterviews.size(),1,'testInitialResources not initialized properly');
	}

	/**
	 * @description Method to test getInitialResources when the input WD Job application is empty.
	 */
	@isTest
	static void testGetInitialResourcesForEmptyApplication() {
		IFB_NewSIFTInterviewWizardCtrl.IFB_NewSIFTInterviewWizardCtrlInitialResources testInitialResources = null;
		try {
        	testInitialResources = IFB_NewSIFTInterviewWizardCtrl.getInitialResources('','',true);			
		} catch(AuraHandledException e) {
			return;
		}
		System.assert(false,'Exception not thrown as expected when application is empty');		
	}

	/**
	 * @description Method to test create SIFT interviews with when the recruit already exists
	 */
	@isTest
	static void testCreateSIFTInterviewsWithExistingRecruit() {
		WDR_Application__c testWDApplication= WDR_TestUtils.createWDRApplication();
        IFB_Interview_Candidate__c recruit = new IFB_Interview_Candidate__c(First_Name__c='Candidate0', Last_Name__c='Recruit0', Email__c='test@test.com',
                                        Recruiter_Intro__c = 'test Intro', Region__c='AMER', Zone__c='AMER East',City__c ='New York', State__c='N/A',Do_not_sync_with_WDR__c = false);
        insert recruit;
        testWDApplication.Is_this_a_SIFT_Interview__c = 'Yes';
        testWDApplication.SIFT_Recruit__c = recruit.Id;
        update testWDApplication;
        List<User> interviewers = [Select Id, Name, Email from User WHERE UserType = 'Standard' and isActive = true LIMIT 1];
        List<IFB_Interview__c> createdInterviews = IFB_NewSIFTInterviewWizardCtrl.createSIFTInterviews((String)testWDApplication.Id,(String)recruit.Id,null,
        																				new IFB_Interview__c(Candidate__c = recruit.Id),interviewers);
        System.assertEquals(createdInterviews.get(0).Candidate__c,recruit.Id, 'Interviews not created properly when recruit already exists');
	}

	/**
	 * @description Method to test create SIFT interviews with when a new recruit is created
	 */
	@isTest
	static void testCreateSIFTInterviewsWithNewRecruit() {
		WDR_Application__c testWDApplication= WDR_TestUtils.createWDRApplication();
        testWDApplication.Is_this_a_SIFT_Interview__c = 'Yes';
        update testWDApplication;
        IFB_SIFTRecruitProvider recProvider = new IFB_SIFTRecruitProvider(testWDApplication.Id);
        IFB_Interview_Candidate__c newRecruit = recProvider.generateNewRecruit();
        List<User> interviewers = [Select Id, Name, Email from User WHERE UserType = 'Standard' and isActive = true LIMIT 1];
        List<IFB_Interview__c> createdInterviews = IFB_NewSIFTInterviewWizardCtrl.createSIFTInterviews((String)testWDApplication.Id,null,
        											newRecruit,new IFB_Interview__c(),interviewers);
		testWDApplication = [Select SIFT_Recruit__c from WDR_Application__c where Id = :testWDApplication.Id];        
        System.assert(createdInterviews.get(0).Candidate__c == testWDApplication.SIFT_Recruit__c, 'Interviews not created properly when a new recruit is created');
	}


	/**
	 * @description Method to test search interviewers when the input string is null
	 */
	@isTest
	static void testsearchInterviewerwithNullString() {
		List<User> returnUsers = IFB_NewSIFTInterviewWizardCtrl.searchInterviewer(null);
		//System.assertEquals(returnUsers.size(),0,'Invalid users list returned when input string is null');
		System.assertNotEquals(returnUsers.size(),0,'No users were returned when the input is null');
	}

	/**
	 * @description Method to test search interviewers when the input string is empty
	 */
	@isTest
	static void testsearchInterviewerwithEmptyString() {
		List<User> returnUsers = IFB_NewSIFTInterviewWizardCtrl.searchInterviewer('');
		System.assertNotEquals(returnUsers.size(),0,'No users were returned when the input is empty');
	}

	/**
	 * @description Method to test search interviewers when the input string is valid
	 */
	@isTest
	static void testsearchInterviewerwithValidInputString() {
		List<User> returnUsers = IFB_NewSIFTInterviewWizardCtrl.searchInterviewer('sat');
		System.assertNotEquals(returnUsers.size(),0,'No users were returned when the input is empty');
	}

	/**
	 * @description Method to test saveSIFTRecruitMapping with valid application and recruit
	 */
	 @isTest
	 static void testSaveSIFTRecruitMapping() {
		WDR_Application__c testWDApplication= WDR_TestUtils.createWDRApplication();
        testWDApplication.Is_this_a_SIFT_Interview__c = 'Yes';
        update testWDApplication;
        IFB_Interview_Candidate__c recruit = new IFB_Interview_Candidate__c(First_Name__c='Candidate0', Last_Name__c='Recruit0', Email__c='test@test.com',
                                        Recruiter_Intro__c = 'test Intro', Region__c='AMER', Zone__c='AMER East',City__c ='New York', State__c='N/A',Do_not_sync_with_WDR__c = false);
        insert recruit;
        IFB_NewSIFTInterviewWizardCtrl.saveSIFTRecruitMapping((String)testWDApplication.Id,(String)recruit.Id);
		testWDApplication = [Select SIFT_Recruit__c from WDR_Application__c where Id = :testWDApplication.Id];  
		System.assertEquals(testWDApplication.SIFT_Recruit__c,recruit.Id,'Recruit not updated onto WD Job Application');      
	 }

	 /**
	  * @description Method to test getExistingInterviewForRecruit when the input string is empty
	  */
	 @isTest
	 static void testGetExistingInterviewForRecruitWithNullInput() {
	 	List<IFB_Interview__c> relatedInterviews = IFB_NewSIFTInterviewWizardCtrl.getExistingInterviewsForRecruit(null);
	 	System.assertEquals(relatedInterviews.size(),0,'Interviews not returned properly when input string is null');
	 }

	 /**
	  * @description Method to test getExistingInterviewForRecruit when the input string is valid
	  */
	 @isTest
	 static void testGetExistingInterviewForRecruitWithValidInput() {
        IFB_Interview_Candidate__c recruit = new IFB_Interview_Candidate__c(First_Name__c='Candidate0', Last_Name__c='Recruit0', Email__c='test@test.com',
                                        Recruiter_Intro__c = 'test Intro', Region__c='AMER', Zone__c='AMER East',City__c ='New York', State__c='N/A',Do_not_sync_with_WDR__c = false);
        insert recruit;
        IFB_Interview__c interview = IFBTestData_Interview.getInterview(null, IFBTestData_Interview.Option.SALES_FIRST, 
                                    recruit, null, null, null, null, null, null);
        insert interview;	 	
	 	List<IFB_Interview__c> relatedInterviews = IFB_NewSIFTInterviewWizardCtrl.getExistingInterviewsForRecruit((String)recruit.Id);
	 	System.assertEquals(relatedInterviews.size(),1,'Interviews not returned properly when input string is valid');
	 }
}