@isTest 
private class NHW_MilestoneTimeCalculatorTest {
	/* Commenting the unit tests as SLA feature is disabled in Prod
    @isTest
    static void testMilestoneTimeCalculatorPreboarding() {        
        MilestoneType[] mtLst = [SELECT Id, Name FROM MilestoneType WHERE Name LIKE '%Preboarding%' LIMIT 1];      
        if(mtLst.size() == 0) { return; }
        MilestoneType mt = mtLst[0];
        
        WDR_Testfactory testdata = new WDR_Testfactory();
        testdata.createJobApp();
        WDR_Application__c DefaultJobApplication = testdata.getDefaultJobApp();
        WDR_Job__c DefaultJobReq = testdata.getDefaultJobReq();
        WDR_Candidate__c DefaultCandidate = testdata.getDefaultCandidate();
        DefaultJobApplication.Start_Date__c = System.Today().addDays(16);

        Test.startTest();
            DefaultJobApplication.Candidate_Stage__c = 'Placement';
            update DefaultJobApplication;
        Test.stopTest();
        
        List<Case> cases =[SELECT Id, Office_Country__c, NHW_Start_Date__c, CreatedDate FROM Case WHERE NHW_Job_Application__c = :DefaultJobApplication.id];
        List<NH_Shipping_SLA__mdt> countries = [SELECT Preboarding_SLA__c, Provisioning_SLA__c FROM NH_Shipping_SLA__mdt WHERE Country__c =: cases[0].Office_Country__c LIMIT 1];
        Integer expectedTime = Date.valueOf(cases[0].CreatedDate).daysBetween(cases[0].NHW_Start_Date__c.addDays(Integer.valueOf(-1 * countries[0].Preboarding_SLA__c))) * 24 * 60;

        NHW_MilestoneTimeCalculator calculator = new NHW_MilestoneTimeCalculator();
        Integer actualTriggerTime = calculator.calculateMilestoneTriggerTime(cases[0].Id, mt.Id);
        System.assertEquals(expectedTime, actualTriggerTime);
    }

    @isTest
    static void testMilestoneTimeCalculatorProvisioning() {        
        MilestoneType[] mtLst = [SELECT Id, Name FROM MilestoneType WHERE Name LIKE '%Provisioning%' LIMIT 1];      
        if(mtLst.size() == 0) { return; }
        MilestoneType mt = mtLst[0];
        
        WDR_Testfactory testdata = new WDR_Testfactory();
        testdata.createJobApp();
        WDR_Application__c DefaultJobApplication = testdata.getDefaultJobApp();
        WDR_Job__c DefaultJobReq = testdata.getDefaultJobReq();
        WDR_Candidate__c DefaultCandidate = testdata.getDefaultCandidate();
        DefaultJobApplication.Start_Date__c = System.Today().addDays(16);

        Test.startTest();
            DefaultJobApplication.Candidate_Stage__c = 'Placement';
            update DefaultJobApplication;
        Test.stopTest();
        
        List<Case> cases =[SELECT Id, Office_Country__c, NHW_Start_Date__c, CreatedDate FROM Case WHERE NHW_Job_Application__c = :DefaultJobApplication.id];
        Case provisioningCase = PF_NHW_ProvisioningCaseStore.generateProvisioningCaseFromPreboardingCase(cases[0].Id);
        insert provisioningCase;
        provisioningCase = [SELECT Id, Office_Country__c, NHW_Start_Date__c, CreatedDate FROM Case WHERE Id =: provisioningCase.Id];

        List<NH_Shipping_SLA__mdt> countries = [SELECT Preboarding_SLA__c, Provisioning_SLA__c FROM NH_Shipping_SLA__mdt WHERE Country__c =: provisioningCase.Office_Country__c LIMIT 1];
        Integer expectedTime = Date.valueOf(provisioningCase.CreatedDate).daysBetween(provisioningCase.NHW_Start_Date__c.addDays(Integer.valueOf(-1 * countries[0].Provisioning_SLA__c))) * 24 * 60;

        NHW_MilestoneTimeCalculator calculator = new NHW_MilestoneTimeCalculator();
        Integer actualTriggerTime = calculator.calculateMilestoneTriggerTime(provisioningCase.Id, mt.Id);
        System.assertEquals(expectedTime, actualTriggerTime);
    }*/
}