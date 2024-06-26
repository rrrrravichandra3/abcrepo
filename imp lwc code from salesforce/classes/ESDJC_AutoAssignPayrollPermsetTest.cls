@isTest

public with sharing class ESDJC_AutoAssignPayrollPermsetTest {


    private static testMethod void testPermsetPayrollCreation(){

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User currentUser = [select id from User where Id= : userinfo.getUserId()];
        User payrollAmerManager,otherUser;
        System.runAs(currentUser){
            //populate custom settings... 
            ESDJC_TestUtil.init();
        }
        //create 2 users, one(1) with payroll Amer manager role. 
        payrollAmerManager = new User(Alias = 'payrollt', Email='payrollAmeruser@salesforce.com.test', 
                EmailEncodingKey='UTF-8', LastName='Testing_Permset', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='payrollAmeruser@salesforce.com.test',userRoleId='00E70000001L66A');

        otherUser = new User(Alias = 'standt', Email='standarduser@salesforce.com.test', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='nonpayrollameruser@salesforce.com');

        insert payrollAmerManager;
        insert otherUser;

        Test.startTest();
        ESDJC_AutoAssign_PayrollPermset assignPermBatch = new ESDJC_AutoAssign_PayrollPermset();
        ID batchprocessid = Database.executeBatch(assignPermBatch);
        Test.StopTest();

        //check for permsetassignments... 
        List<PermissionSet> payrollPermSet = [select id from PermissionSet where Name = 'ES_DJC_Payroll_Amer']; 
        System.assertEquals(1,[select count() from PermissionSetAssignment where AssigneeId=:payrollAmerManager.Id and  PermissionSetId = :  payrollPermSet[0].Id]);
        System.assertEquals(0,[select count() from PermissionSetAssignment where AssigneeId=:otherUser.Id and  PermissionSetId = :  payrollPermSet[0].Id]);

    }


}