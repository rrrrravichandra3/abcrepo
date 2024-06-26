/**
 * @author Apuroop Gadde
 * @date 08-11-2017
 * @group Unit Test Classes
 * @description Unit tests for testing methods in IFB_WDApplicationToSIFTRecruit
 */
@isTest
private class IFB_WDApplicationToSIFTRecruitTest {
    private static String dummyExistingGroup = 'CSG';
    private static String dummyExistingPosition = 'Program Architect';

    /**
    * @description Method to setup test data and configurations for unit tests
    **/
    @testSetup 
    static void testSetup() {
    	WDR_Application__c testWDApplication= WDR_TestUtils.createWDRApplication();
        IFB_Interview_Candidate__c recruit = new IFB_Interview_Candidate__c(First_Name__c='Candidate0', Last_Name__c='Recruit0', Email__c='test@test.com',
                                        Recruiter_Intro__c = 'test Intro', Region__c='AMER', Zone__c='AMER East',City__c ='New York', State__c='N/A',Do_not_sync_with_WDR__c = false);
        insert recruit;
        testWDApplication.Is_this_a_SIFT_Interview__c = 'Yes';
        testWDApplication.SIFT_Recruit__c = recruit.Id;
        update testWDApplication;

        WDR_Application__c testWDOfferRejectedApplication= WDR_TestUtils.createWDROfferRejectedApplication();
        IFB_Interview_Candidate__c offerRejectedRecruit = new IFB_Interview_Candidate__c(First_Name__c='OfferRejectedCandidate0', Last_Name__c='Recruit0', Email__c='test@test.com',
                                        Recruiter_Intro__c = 'test Intro', Region__c='AMER', Zone__c='AMER East',City__c ='New York', State__c='N/A',Do_not_sync_with_WDR__c = false);
        insert offerRejectedRecruit;
        testWDOfferRejectedApplication.Is_this_a_SIFT_Interview__c = 'Yes';
        testWDOfferRejectedApplication.SIFT_Recruit__c = offerRejectedRecruit.Id;
        update testWDOfferRejectedApplication;

        IFB_WDTestUtils.setupSiftSettingsListCS();
    }

    /**
    * @description  Method to test initialization of the class with null values
    **/
    @isTest
    static void testConstructorWithNullArguments() {
    	try {
    		IFB_WDApplicationToSIFTRecruit testAppToRecruit = new IFB_WDApplicationToSIFTRecruit(null,null);
    	}
    	catch(Exception e) {
    		System.assert(false, 'Exception occured when initializing IFB_WDApplicationToSIFTRecruit with null arguments');
    	}
    }

    /**
    * @description Method to test initialization of the class with proper values
    **/
    @isTest
    static void testConstructorWithValidArguments() {
    	IFB_WDApplicationToSIFTRecruit testAppToRecruit;
    	try {
    		testAppToRecruit = new IFB_WDApplicationToSIFTRecruit(new Set<Id>(),WDR_Application__c.sObjectType);
    	}
    	catch(Exception e) {
    		System.assert(false, 'Exception occured when initializing IFB_WDApplicationToSIFTRecruit with appropriate arguments');
    	}
    	System.assert(testAppToRecruit.recruitsToBeUpdated != null, 'Error initializing list recruitsToBeUpdated');
    	System.assert(testAppToRecruit.listWDApplicationIds != null, 'Error initializing list listWDApplicationIds');
    	System.assert(testAppToRecruit.objectType != null, 'Error initializing list objectType');
    }

    /**
    * @description Method to test recruit updates when the related application is updated.
    **/
    @isTest
    static void testRecruitUpdateFromApplication() {
		WDR_Application__c testWDApplication = [SELECT Id,SIFT_Recruiter_Intro__c, SIFT_Group__c, SIFT_Position__c, SIFT_Years_of_Experience__c, 
												Candidate_Stage__c, SIFT_Recruit__c
												FROM WDR_Application__c WHERE Candidate__r.Name = 'TestCandidate' AND Job__r.Name = 'test job' LIMIT 1];
		if(testWDApplication != null) {
			testWDApplication.SIFT_Recruiter_Intro__c = 'test intro';
			testWDApplication.SIFT_Group__c = dummyExistingGroup;
			testWDApplication.SIFT_Position__c = dummyExistingPosition;
			testWDApplication.SIFT_Years_of_Experience__c = 1;
			testWDApplication.Candidate_Stage__c = 'Rejected';
            test.startTest();
			update testWDApplication;
            test.stopTest();	
		}
		IFB_Interview_Candidate__c recruit = [SELECT Id, Recruiter_Intro__c from IFB_Interview_Candidate__c where First_Name__c='Candidate0' 
											  AND Last_Name__c = 'Recruit0'];
		System.assertEquals('test intro',recruit.Recruiter_Intro__c,'Recruiter Intro field was not updated from application');
    }

    /**
    * @description Method to test recruit updates when the related job is updated.
    **/
    @isTest
    static void testRecruitUpdateFromJob() {
        WDR_Job__c testWDJob = [SELECT Id,Region__c, Target_Hire_Date__c
                                                FROM WDR_Job__c WHERE Name = 'test job' LIMIT 1];
        if(testWDJob != null) {
            testWDJob.Region__c = 'testRegion';
            testWDJob.Target_Hire_Date__c = Date.today();
            
            test.startTest();
            update testWDJob;
            test.stopTest();    
        }
        IFB_Interview_Candidate__c recruit = [SELECT Id, Region__c from IFB_Interview_Candidate__c where First_Name__c='Candidate0' 
                                              AND Last_Name__c = 'Recruit0'];
        System.assertEquals('testRegion',recruit.Region__c,'Region field was not updated from Job');
    }

    /**
    * @description Method to test recruit updates when the related candidate is updated.
    **/
    @isTest
    static void testRecruitUpdateFromCandidate() {
        WDR_Candidate__c testWDCandidate = [SELECT Id,First_Name__c, Last_Name__c, Mailing_State__c, Email__c, Phone__c
                                                FROM WDR_Candidate__c WHERE Name = 'TestCandidate' LIMIT 1];
        if(testWDCandidate != null) {
            testWDCandidate.First_Name__c = 'updateFName';
            testWDCandidate.Last_Name__c = 'updateLName';
            test.startTest();
            update testWDCandidate;
            test.stopTest();    
        }
        IFB_Interview_Candidate__c recruit = [SELECT Id, First_Name__c, Last_Name__c from IFB_Interview_Candidate__c 
                                        where Job_Application_WDR__r.Candidate__c = :testWDCandidate.Id];
        System.assertEquals('updateFName',recruit.First_Name__c,'First Name field was not updated from Candidate');
    }


    /**
    * @description Method to test recruit updates when the related application in placement is updated.
    **/
    @isTest
    static void testRecruitUpdateFromApplicationInPlacement() {
        WDR_Application__c testWDApplication = [SELECT Id, Candidate_Stage__c, Start_Date__c
                                                FROM WDR_Application__c WHERE Candidate__r.Name = 'TestCandidate' AND Job__r.Name = 'test job' LIMIT 1];
        if(testWDApplication != null) {
            testWDApplication.Candidate_Stage__c = 'Placement';
            testWDApplication.Start_Date__c = Date.today().addDays(30);
            test.startTest();
            update testWDApplication;
            test.stopTest();    
        }
        IFB_Interview_Candidate__c recruit = [SELECT Id, Hire_Date__c from IFB_Interview_Candidate__c where First_Name__c='Candidate0' 
                                              AND Last_Name__c = 'Recruit0'];
        System.assertEquals(Date.today().addDays(30),recruit.Hire_Date__c,'Hire Date field was not updated in recruit from application');
    }

    /**
     * @description Method to test recruit updates on an application that is in offer rejected status
     */
    @isTest
    static void testRecruitUpdateFromOfferRejectedApplication() {
        WDR_Application__c testWDOfferRejectedApplication = [SELECT Id, Candidate_Stage__c, Start_Date__c,SIFT_Recruiter_Intro__c
                                                FROM WDR_Application__c WHERE Candidate__r.Name = 'TestOfferRejectedCandidate' AND Job__r.Name = 'test job' LIMIT 1];
        if(testWDOfferRejectedApplication != null) {
            test.startTest();
            testWDOfferRejectedApplication.SIFT_Recruiter_Intro__c = 'updated Intro';
            update testWDOfferRejectedApplication;
            test.stopTest();
    
        }
        IFB_Interview_Candidate__c recruit = [SELECT Id, Recruiter_Intro__c from IFB_Interview_Candidate__c where First_Name__c='OfferRejectedCandidate0' 
                                              AND Last_Name__c = 'Recruit0'];
        System.assertEquals('test Intro',recruit.Recruiter_Intro__c,'Recruiter intro field was updated in recruit from application');        
    }

    /**
    * @description Method to test recruit updates when the related application has candidate rejected.
    **/
    @isTest
    static void testRecruitUpdateForRejectedApplication() {
        WDR_Application__c testWDApplication = [SELECT Id,Candidate_Stage__c FROM WDR_Application__c WHERE Candidate__r.Name = 'TestCandidate' AND Job__r.Name = 'test job' LIMIT 1];
        if(testWDApplication != null) {
            testWDApplication.Candidate_Stage__c = 'Rejected';
            test.startTest();
            update testWDApplication;
            test.stopTest();    
        }
        IFB_Interview_Candidate__c recruit = [SELECT Id, Rejected__c, Accepted_Offer__c from IFB_Interview_Candidate__c where First_Name__c='Candidate0' 
                                              AND Last_Name__c = 'Recruit0'];
        System.assertEquals(true,recruit.Rejected__c,'Rejected checkbox was not updated from application');
    }    

}