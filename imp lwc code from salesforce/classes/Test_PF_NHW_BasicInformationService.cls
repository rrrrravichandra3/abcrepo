@isTest
class Test_PF_NHW_BasicInformationService {

    @TestSetup
    static void createData(){
        Test_PF_NHW_ProvisioningTypeTestFactory.createNHWProvisionings();
        Test_PF_NHW_ProvisioningTypeTestFactory.createNHWLightningComponents();
    }

    @isTest
    static void validateAdditionalProcessInformationFTE() {
        Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        provisioningCase.NHW_Page_Number__c = 1;
        insert provisioningCase;
        List<NHW_Provisioning__c> provs = [select id,Name from NHW_Provisioning__c where Type__c = 'Application'];
        NHW_Software_Access_Provisioning__c currCaseProv = new NHW_Software_Access_Provisioning__c();
        currCaseProv.Provisioning_Case__c = provisioningCase.id;
        currCaseProv.Provisioning_Id__c = provs[0].id;
        currCaseProv.Provisioning_name__c = provs[0].name;
        currCaseProv.Selected__c = true;
        insert currCaseProv;
        Case pastCase = provisioningCase.clone();
        insert pastCase;
        NHW_Software_Access_Provisioning__c pastCaseProv = new NHW_Software_Access_Provisioning__c();
        pastCaseProv.Provisioning_Case__c = pastCase.id;
        pastCaseProv.Provisioning_Id__c = provs[1].id;
        pastCaseProv.Provisioning_name__c = provs[1].name;
        pastCaseProv.Selected__c = false;
        insert pastCaseProv;
        Test.startTest();
        provisioningCase = PF_NHW_ProvisioningCaseStore.getProvisioningCaseById(provisioningCase.id);
        PF_NHW_PageService pageService = new PF_NHW_BasicInformationPageService();
        Map<String,String> additionalInfo = new Map<String,String>();
        additionalInfo.put('CLONECASEID', pastCase.id);
        pageService.processInformation(provisioningCase,additionalInfo,false);
        List<PF_NHW_PageService.ReviewItem> reviewList = pageService.getReviewList(provisioningCase,PF_NHW_Process.getProcessByName(provisioningCase.NHW_Employee_Type__c));
        Test.stopTest();
        System.assert(reviewList!=null,'successful review list creation');
		List<NHW_Software_Access_Provisioning__c> sProvs = [select id,Provisioning_name__c from NHW_Software_Access_Provisioning__c where Provisioning_Case__c=:provisioningCase.id];
        System.assertEquals(sProvs.size(),2,'software provisioning copied from cloned case');
    }
    
    @isTest
    static void validateProcessInformationContractor() {
        Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        provisioningCase.NHW_Employee_Type__c = 'Contractor';
        provisioningCase.Contractor_Hire_Reason__c = 'Standard';
        provisioningCase.Resource_Type__c = 'Agency Temp';
        provisioningCase.NHW_Page_Number__c = 4;
        insert provisioningCase;
        Test.startTest();
        provisioningCase = PF_NHW_ProvisioningCaseStore.getProvisioningCaseById(provisioningCase.id);
        PF_NHW_PageService pageService = new PF_NHW_BasicInformationPageService();
        Map<String,String> additionalInfo = new Map<String,String>();
        pageService.processInformation(provisioningCase,additionalInfo,false);
        Test.stopTest();
		Case c = [select id,Office_City__c from Case where id=:provisioningCase.id];
        System.assertEquals(c.Office_City__c,'California','for contractor and Reloc populate the office address fields based on office business site');
    }
    
     @isTest
    static void validateProvisioningCaseCreationFTE() {
        WDR_TestFactory testdata = new WDR_TestFactory();
        testdata.createJobApp();
        WDR_Application__c jobApp = testdata.getDefaultJobApp();
        Test.startTest();
        jobApp.Candidate_Stage__c = 'Placement';
        update jobApp;
        Test.stopTest();
        Case preCase = [select id from Case];
        PF_NHW_PageService pageService = new PF_NHW_BasicInformationPageService();
        pageService.getPageinformation('regular',preCase.id);
        List<Case> cases = [select id from Case];
        System.assertEquals(cases.size(),2,'provisioning case also created');
    }

}