/**
 * @author Apuroop Gadde
 * @date 09-12-2017
 * @group Unit Test Classes
 * @description Unit tests for testing methods in IFB_WDUtils
 */
@isTest
private class IFB_WDUtilsTest {
    /**
    * @description Method to setup test data and configurations for unit tests
    **/
    @testSetup 
    static void testSetup() {

    }


    /**
     * @description Method to test send email when errors are found in queue updates and when sift settings does not exist
     */
    @isTest
    static void testMailErrorsWhenSIFTSettingsIsNull() {
    	String errorLog = 'test Log';
    	String errorFileDesc = 'test Log File Desc';
    	String errorFileTitle = 'test Log File Title';
    	try {
    		 IFB_WDUtils.mailErrors(errorLog,errorFileDesc,errorFileTitle);
    	} catch(Exception e) {
    		System.assert(true,'Expecting exception as SIFT setting doesnt exist');
    	}
    	Integer invocations = Limits.getEmailInvocations();
    	System.assertEquals(0,invocations,'No Email should have been sent.');
    }

    /**
     * @description Method to test send email when errors are found in queue updates and when email is empty in sift settings
     */
    @isTest
    static void testMailErrorswithEmptyEmail() {
    	IFB_SIFT_Settings_List__c siftSettingsList = new IFB_SIFT_Settings_List__c();
        siftSettingsList.Name = 'SIFT';
        siftSettingsList.IFB_WD_Integration_Downstream_Err_Emails__c = '';
        upsert siftSettingsList;    	
    	String errorLog = 'test Log';
    	String errorFileDesc = 'test Log File Desc';
    	String errorFileTitle = 'test Log File Title';
    	try {
    		 IFB_WDUtils.mailErrors(errorLog,errorFileDesc,errorFileTitle);
    	} catch(Exception e) {
    		System.assert(false,'Mailing of errors failed with exception:' + e.getStackTraceString());
    	}
    	Integer invocations = Limits.getEmailInvocations();
    	System.assertEquals(0,invocations,'No Email would have been sent.');
    }

    /**
     * @description Method to test send email when errors are found in queue updates and valid email exists in custom settings
     */
    @isTest
    static void testMailErrorsWhenValidEmailExists() {
    	IFB_SIFT_Settings_List__c siftSettingsList = new IFB_SIFT_Settings_List__c();
        siftSettingsList.Name = 'SIFT';
        siftSettingsList.IFB_WD_Integration_Downstream_Err_Emails__c = 'agadde@salesforce.com';
        upsert siftSettingsList;
    	String errorLog = 'test Log';
    	String errorFileDesc = 'test Log File Desc';
    	String errorFileTitle = 'test Log File Title';
    	try {
    		 IFB_WDUtils.mailErrors(errorLog,errorFileDesc,errorFileTitle);
    	} catch(Exception e) {
    		System.assert(false,'Mailing of errors failed with exception:' + e.getStackTraceString());
    	}
    	Integer invocations = Limits.getEmailInvocations();
    	System.assertEquals(1,invocations,'One Email should have been sent.');

    }

    /**
     * @description Method to test getIdsOfSObjectswithFieldChanges when the input parameters contains null
     */
    @isTest
    static void testGetIdsOfSObjectswithFieldsChangeWithNullMap() {
   		List<Id> testIds = IFB_WDUtils.getIdsOfSObjectswithFieldsChange(null,null,WDR_Job__c.sObjectType,WDR_Job__c.sObjectType);
   		System.assertEquals(0,testIds.size(),'List of Ids not returned properly');
    }

    /**
     * @description Method to test getIdsOfSObjectswithFieldChanges when recruit related fields change on job
     */
    @isTest
    static void testGetIdsOfSObjectswithFieldsChangeOnWDJobReqRelatedToRecruit() {
    	Map<Id,WDR_Job__c> triggerNew = new Map<Id,WDR_Job__c>();
    	Map<Id,WDR_Job__c> triggerOld = new Map<Id,WDR_Job__c>();
    	WDR_Job__c testJob = WDR_TestUtils.createWDRJobReq('test job');
    	triggerOld.put(testJob.Id, testJob);
    	WDR_Job__c newtestJob = testJob.clone(true,true,false,false);
    	newtestJob.Region__c = 'new Region';
    	triggerNew.put(testJob.Id, newtestJob);
    	List<Id> changedIds = IFB_WDUtils.getIdsOfSObjectswithFieldsChange(triggerNew,triggerOld,WDR_Job__c.sObjectType,
    							IFB_Interview_Candidate__c.sObjectType);
   		System.assertEquals(testJob.Id,changedIds.get(0),'List of Job Ids with recruit related changes not returned properly');
    }

    /**
     * @description Method to test getIdsOfSObjectswithFieldChanges when recruit related fields change on application
     */
    @isTest
    static void testGetIdsOfSObjectswithFieldsChangeOnWDJobApplicationRelatedToRecruit() {
    	Map<Id,WDR_Application__c> triggerNew = new Map<Id,WDR_Application__c>();
    	Map<Id,WDR_Application__c> triggerOld = new Map<Id,WDR_Application__c>();
    	WDR_Application__c testApplication = WDR_TestUtils.createWDRApplication();
    	triggerOld.put(testApplication.Id, testApplication);
    	WDR_Application__c newtestApplication = testApplication.clone(true,true,false,false);
    	newtestApplication.SIFT_Recruiter_Intro__c = 'updated Intro 123';
    	triggerNew.put(testApplication.Id, newtestApplication);
    	List<Id> changedIds = IFB_WDUtils.getIdsOfSObjectswithFieldsChange(triggerNew,triggerOld,WDR_Application__c.sObjectType,
    							IFB_Interview_Candidate__c.sObjectType);
   		System.assertEquals(testApplication.Id,changedIds.get(0),'List of Application Ids with recruit related changes not returned properly');
    }

    /**
     * @description Method to test getIdsOfSObjectswithFieldChanges when recruit related fields change on WD candidate
     */
    @isTest
    static void testGetIdsOfSObjectswithFieldsChangeOnWDCandidateRelatedToRecruit() {
    	Map<Id,WDR_Candidate__c> triggerNew = new Map<Id,WDR_Candidate__c>();
    	Map<Id,WDR_Candidate__c> triggerOld = new Map<Id,WDR_Candidate__c>();
    	WDR_Candidate__c testCand = WDR_TestUtils.createWDRCandidate();
    	triggerOld.put(testCand.Id, testCand);
    	WDR_Candidate__c newtestCand = testCand.clone(true,true,false,false);
    	newtestCand.Mailing_City__c = 'updated city';
    	triggerNew.put(testCand.Id, newtestCand);
    	List<Id> changedIds = IFB_WDUtils.getIdsOfSObjectswithFieldsChange(triggerNew,triggerOld,WDR_Candidate__c.sObjectType,
    							IFB_Interview_Candidate__c.sObjectType);
   		System.assertEquals(testCand.Id,changedIds.get(0),'List of Candidate Ids with recruit related changes not returned properly');
    }

    /**
     * @description Method to test getIdsOfSObjectswithFieldChanges when interview related fields change on job
     */
    @isTest
    static void testGetIdsOfSObjectswithFieldsChangeOnWDJobReqRelatedToInterview() {
    	Map<Id,WDR_Job__c> triggerNew = new Map<Id,WDR_Job__c>();
    	Map<Id,WDR_Job__c> triggerOld = new Map<Id,WDR_Job__c>();
    	WDR_Job__c testJob = WDR_TestUtils.createWDRJobReq('test job');
    	triggerOld.put(testJob.Id, testJob);
    	WDR_Job__c newtestJob = testJob.clone(true,true,false,false);
    	newtestJob.Hiring_Manager__c = WDR_TestUtils.createHiringManagerWithNoHeirarchy('updateFName','updateLName').Id;
    	triggerNew.put(testJob.Id, newtestJob);
    	List<Id> changedIds = IFB_WDUtils.getIdsOfSObjectswithFieldsChange(triggerNew,triggerOld,WDR_Job__c.sObjectType,
    							IFB_Interview__c.sObjectType);
   		System.assertEquals(testJob.Id,changedIds.get(0),'List of Job Ids with interview related changes not returned properly');
    }

    /**
     * @description Method to test getIdsOfSObjectswithFieldChanges when recruit related fields do not change on job
     */
    @isTest
    static void testGetIdsOfSObjectswithFieldsChangeOnWDJobReqNotRelatedToRecruit() {
    	Map<Id,WDR_Job__c> triggerNew = new Map<Id,WDR_Job__c>();
    	Map<Id,WDR_Job__c> triggerOld = new Map<Id,WDR_Job__c>();
    	WDR_Job__c testJob = WDR_TestUtils.createWDRJobReq('test job');
    	triggerOld.put(testJob.Id, testJob);
    	WDR_Job__c newtestJob = testJob.clone(true,true,false,false);
    	newtestJob.Hiring_Manager__c = WDR_TestUtils.createHiringManagerWithNoHeirarchy('updateFName','updateLName').Id;
    	triggerNew.put(testJob.Id, newtestJob);
    	List<Id> changedIds = IFB_WDUtils.getIdsOfSObjectswithFieldsChange(triggerNew,triggerOld,WDR_Job__c.sObjectType,
    							IFB_Interview_Candidate__c.sObjectType);
   		System.assertEquals(0,changedIds.size(),'List of Job Ids not returned properly');
    } 

    /**
     * @description Method to test getValuesForCustomSetting with null input
     */
    @isTest
    static void testGetValuesForCustomSettingWithNullInput() {
    	Set<String> returnSet = IFB_WDUtils.getValuesForCustomSetting(null);
    	System.assertEquals(0,returnSet.size(), 'Set of custom setting values size is not 0, should be 0');
    }

    /**
     * @description Method to test getValuesForCustomSetting with valid input
     */
    @isTest 
    static void testGetValuesForCustomSettingWithValidInput() {
    	IFB_WDTestUtils.setupSiftSettingsListCS();
    	Set<String> returnSet = IFB_WDUtils.getValuesForCustomSetting('WDR_Rejected_Offer_Status__c');
    	System.assertNotEquals(0,returnSet.size(),'Set of custom setting values size is 0, should not be 0');
    }
}