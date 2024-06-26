@isTest
public class Warmline_Trigger_Handler_Test {
    
    @TestSetup
    static void makeData(){
        ESDJC_TestUtil.init();
        Case warmlineCase = ESDJC_TestUtil.getWarmlineCase();
    }
    static testmethod void test_sendWarmlineEscalationNotifications_for_updatedCase(){

        Case warmlineCase = [Select Id from Case limit 1];
        Warmline__c wRecord = ESDJC_TestUtil.getWarmlineCase(warmlineCase);

        Test.startTest();
        wRecord.Disposition__c = 'Employee Relations;Career Advice';
        update wRecord;
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assert(emailInvocations>0);
    }

    static testmethod void test_sendWarmlineEscalationNotifications_for_updatedCasewDisposition(){

        Case warmlineCase = [Select Id from Case limit 1];
        Warmline__c wRecord = ESDJC_TestUtil.getWarmlineCase(warmlineCase);
        wRecord.Disposition__c = 'Career Advice';
        update wRecord;

        Test.startTest();
        wRecord.Disposition__c = 'Career Advice;Employee Relations';
        update wRecord;
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assert(emailInvocations>0);
    }

    static testmethod void test_negativeScenario_for_updatedCase(){

        Case warmlineCase = [Select Id from Case limit 1];
        Warmline__c wRecord = ESDJC_TestUtil.getWarmlineCase(warmlineCase);

        Test.startTest();
        wRecord.Disposition__c = 'Career Advice';
        update wRecord;
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(0, emailInvocations);
    }

    static testmethod void test_sendWarmlineEscalationNotifications_for_newCase(){

        Case warmlineCase = [Select Id from Case limit 1];

        Test.startTest();
        Warmline__c wRecord = new Warmline__c();
        wRecord.Case__c = warmlineCase.Id;
        wRecord.Disposition__c = 'Employee Relations;Career Advice';
        insert wRecord;
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assert(emailInvocations>0);
    }

    static testmethod void test_negativeScenario_for_newCase(){

        Case warmlineCase = [Select Id from Case limit 1];

        Test.startTest();
        Warmline__c wRecord = new Warmline__c();
        wRecord.Case__c = warmlineCase.Id;
        wRecord.Disposition__c = 'Career Advice';
        insert wRecord;
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(0, emailInvocations);
    }
}