/**
 * @author Apuroop Gadde
 * @date 09-06-2017
 * @group Unit Test Classes
 * @description Unit tests for testing methods in IFB_WDShareAppsWithHM
 */
@isTest
private class IFB_WDShareAppsWithHMTest {
    /**
    * @description Method to setup test data and configurations for unit tests
    **/
    @testSetup 
    static void testSetup() {      
    }

    /**
     * @description Method to test WD Job Application sharing to hiring manager on insert of Application
     */
    @isTest
    static void testShareWDAppWithHMAfterInsert() {
        Test.startTest();
        WDR_Application__c wdApplication = WDR_TestUtils.createWDRApplication();
        Test.stopTest();
        wdApplication = [SELECT Job__r.Hiring_Manager__c FROM WDR_Application__c where Id = :wdApplication.Id];
        List<WDR_Application__share> share = [SELECT Id FROM WDR_Application__share WHERE parentId = : wdApplication.Id 
                                              AND userOrGroupId = :wdApplication.Job__r.Hiring_Manager__c];
        System.assertEquals(1,share.size());
    }

    /**
     * @description Method to test WD Job Application sharing to hiring manager on update of related job Req
     */
    @isTest
    static void testShareWDAppWithHMAfterUpdate() {
        Test.startTest();
        WDR_Application__c wdApplication = WDR_TestUtils.createWDRApplication();
        WDR_Job__c wdJobReq2 = WDR_TestUtils.createWDRJobReq('test Job2');
        User newHM = WDR_TestUtils.createHiringManagerWithNoHeirarchy('testFName3','testLName3');
        wdJobReq2.Hiring_Manager__c = newHM.Id;
        update wdJobReq2;
        wdApplication.Job__c = wdJobReq2.Id;
        update wdApplication;
        Test.stopTest();
        List<WDR_Application__share> share = [SELECT Id FROM WDR_Application__share WHERE parentId = : wdApplication.Id 
                                              AND userOrGroupId = :newHm.Id];
        System.assertEquals(1,share.size(),'Apps not shared with the newHM');
    }  
}