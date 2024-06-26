/**
 * @author Apuroop Gadde
 * @date 09-06-2017
 * @group Unit Test Classes
 * @description Unit tests for testing methods in FB_WDShareJobsAndAppsWithHM
 */
@isTest
private class IFB_WDShareJobsAndAppsWithHMTest {
    /**
    * @description Method to setup test data and configurations for unit tests
    **/
    @testSetup 
    static void testSetup() {
    }

    /**
     * @description Method to test class Initialization with null map as input
     */
    @isTest 
    static void testConstructorWithNull() {
            IFB_WDShareJobsAndAppsWithHM testShareClass = new IFB_WDShareJobsAndAppsWithHM(null,true);
            System.assertEquals(testShareClass.mapOfJobs.size(),0, 'IFB_WDShareJobsAndAppsWithHM was not instantiated properly');
    }

    /**
     * @description Method to test HM sharing when a job is inserted and  has no associated applications
     */
    @isTest
    static void testShareWDJobWithHMAfterInsertWithOutApplications() {
        Test.startTest();
        WDR_Job__c wdJobReq = WDR_TestUtils.createWDRJobReq('test Job');
        Test.stopTest();
        List<WDR_Job__share> share = [SELECT Id FROM WDR_Job__share WHERE parentId = : wdJobReq.Id 
                                              AND RowCause = :Schema.WDR_Job__share.RowCause.Hiring_Manager__c];

        System.assertEquals(1,share.size(),'Job not shared with HM');
    }

    /**
     * @description Method to test HM sharing when a job is updated with a new Hiring Manager
     * and  has no associated applications
     */
    @isTest
    static void testShareWDJobWithHMAfterHMUpdateWithoutApplications() {
        Test.startTest();
        WDR_Job__c wdJobReq = WDR_TestUtils.createWDRJobReq('test job');
        User newHM = WDR_TestUtils.createHiringManagerWithNoHeirarchy('testFName3','testLName3');
        wdJobReq.Hiring_Manager__c = newHM.Id;
        update wdJobReq;
        Test.stopTest();
        List<WDR_Job__share> share = [SELECT Id FROM WDR_Job__share WHERE parentId = : wdJobReq.Id 
                                    AND userOrGroupId = :newHM.Id];
        System.assertEquals(1,share.size(),'Job not shared with updated HM');
    }
    
}