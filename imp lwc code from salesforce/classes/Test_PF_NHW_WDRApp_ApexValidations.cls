@istest
public class Test_PF_NHW_WDRApp_ApexValidations {    
    @testSetup
    static void init() {
        NH_Settings__c nhs = new NH_Settings__c(NoOfDaysBeforeStartDateToSendRemindEmail__c = 15,Valid_AD_Email_Domains__c='salesforce.com');
        insert nhs;
        
    }
    
    //WD4S -if Region is missing on Job Req -show error
    @isTest
    static void verifyApexValidationMissingRegion() {
        WDR_Testfactory testdata = new WDR_Testfactory();
        testdata.createJobApp();
        WDR_Application__c defaultJobApplication = testdata.getDefaultJobApp();
        WDR_Job__c defaultJobReq = testdata.getDefaultJobReq();
        DefaultJobApplication.Start_Date__c = System.Today().addDays(16);
		
        Test.startTest();
        	DefaultJobReq.Req_Creation_Reason__c = 'Not Acquisition';
        	DefaultJobReq.Region__c = null;
        	update DefaultJobReq;
            DefaultJobApplication.Candidate_Stage__c = 'Placement';
            update DefaultJobApplication;
        Test.stopTest();
        List<PF_Debug_Log__c> err = [select id,description__c,Error_Message__c ,Component__c ,Type__c ,error_type__c from PF_DEbug_Log__c];
        //System.assert(err[1].Error_Message__c.contains('Region'));

    }
    
    //WD4S -if Department is missing on Job Req -show error
    @isTest
    static void verifyApexValidationMissingDepartment() {
        WDR_Testfactory testdata = new WDR_Testfactory();
        testdata.createJobApp();
        WDR_Application__c defaultJobApplication = testdata.getDefaultJobApp();
        WDR_Job__c defaultJobReq = testdata.getDefaultJobReq();
        DefaultJobApplication.Start_Date__c = System.Today().addDays(16);
		
        Test.startTest();
        	DefaultJobReq.Req_Creation_Reason__c = 'Not Acquisition';
        	DefaultJobReq.Department__c = null;
        	update DefaultJobReq;
            DefaultJobApplication.Candidate_Stage__c = 'Placement';
            update DefaultJobApplication;
        Test.stopTest();
        List<PF_Debug_Log__c> err = [select id,description__c,Error_Message__c ,Component__c ,Type__c ,error_type__c from PF_DEbug_Log__c];
        

    }
      
   
}