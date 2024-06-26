@isTest
public class Test_PF_NHW_SoftwarePageService {
    
    @testSetup
    static void createProvsAndLightningComponents() {
        Test_PF_NHW_ProvisioningTypeTestFactory.createNHWProvisionings();
    }
    
    @istest
    static void validateProcessInformationTableauhire() {
        Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        List<NHW_Provisioning__c> provs = [select id,Name from NHW_Provisioning__c where Type__c = 'Application'];
        NHW_Software_Access_Provisioning__c currCaseProv = new NHW_Software_Access_Provisioning__c();
        currCaseProv.Provisioning_Id__c = provs[0].id;
        currCaseProv.Provisioning_name__c = provs[0].name;
        currCaseProv.Selected__c = true;
        NHW_Software_Access_Provisioning__c currCaseProv2 = new NHW_Software_Access_Provisioning__c();
        currCaseProv2.Provisioning_Id__c = provs[1].id;
        currCaseProv2.Provisioning_name__c = provs[1].name;
        currCaseProv2.Selected__c = true;
        Test.startTest();
        insert provisioningCase;
        currCaseProv.Provisioning_Case__c = provisioningCase.id;
        currCaseProv2.Provisioning_Case__c = provisioningCase.id;
        NH_Profile__c npc = new NH_Profile__c(Name = 'Tableau Core Access',Grouping_Category__c = 'BU CC');
        insert npc;
        insert new NH_BU_CC_Profile__c(NH_Profile__c = npc.id, Business_Unit__c = provisioningCase.NHW_Business_Unit__c , Cost_Center__c = provisioningCase.NHW_Cost_Center__c);
        insert currCaseProv;
        insert currCaseProv2;
        PF_NHW_PageService pageService = new PF_NHW_SoftwarePageService();
        Map<String,Object> pageInfo = pageservice.getPageInformation('regular', provisioningCase.id);
        pageService.processInformation(provisioningCase,new Map<String,Object>(),false);
        List<PF_NHW_PageService.ReviewItem> reviewList = pageService.getReviewList(provisioningCase,PF_NHW_Process.getProcessByName(provisioningCase.NHW_Employee_Type__c));
        System.assert(pageInfo!=null,'page info is populated');
        System.assertEquals(reviewList.size(),1,'provisioning available');
        pageService.resetFieldsOnPageSkip(provisioningCase);
        reviewList = pageService.getReviewList(provisioningCase,PF_NHW_Process.getProcessByName(provisioningCase.NHW_Employee_Type__c));
        System.assertEquals(reviewList.size(),0,'review list reset');
        Test.stopTest();
    }
    
}