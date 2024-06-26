@isTest
public class Test_PF_NHW_TrainingProvisionTypeService {
    @testSetup 
    static void getNHWProvisionings() {
        Test_PF_NHW_ProvisioningTypeTestFactory.createNHWProvisionings();
		Onboarding_Setting__c setting = new Onboarding_Setting__c();
        setting.JWT_Aud_Endpoint__c = 'https://testtest.com';
        setting.JWT_User_Name__c = 'test@salesforce.com';
        setting.Org62_Consumer_Key__c = 'testkey';
        setting.Org62_Service_Endpoint__c = 'https://test.com';
        setting.Org62_Token_Endpoint__c = 'https://test.com';
        setting.PF_Certificate__c = 'NHW_CERTIFICATE';
        insert setting;    
    }
   
    @isTest
    public static void validate_TrainingsProvisionings_FTE() {
        Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();       
        //initialise Provisioning Type base class and service
        PF_NHW_ProvisioningType pt = PF_NHW_ProvisioningType.getProvisioningTypeByName('TRAINING');	
        PF_NHW_ProvisioningTypeService ptService = pt.createService(provisioningCase);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NHW_MockCampaignResponseGenerator());
        NHW_Org62Service.accessToken = 'dummytoken';
        List<Object> provisionings = ptService.getProvisionings();
        Set<String> dependencies = ptService.getDependencies();
        Test.stopTest();
        //assert correct training provisoning is returned;
        PF_NHW_TrainingProvisioningTypeService.TrainingProvisioning tp = (PF_NHW_TrainingProvisioningTypeService.TrainingProvisioning) provisionings[0];
        System.assertEquals(tp.TrainingTypeDisplayName, 'Becoming Salesforce');

    }
    
     @isTest
    public static void validate_TrainingsProvisionings_FTE_Selected() {
        Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        provisioningCase.NHW_Training__c = '[{"TrainingType":"Becoming Salesforce","org62ContactId":"","isEnrolled":false,"CampaignId":"701Q0000000TzHDIA7"}]';
        //initialise Provisioning Type base class and service
        PF_NHW_ProvisioningType pt = PF_NHW_ProvisioningType.getProvisioningTypeByName('TRAINING');	
        PF_NHW_ProvisioningTypeService ptService = pt.createService(provisioningCase);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NHW_MockCampaignResponseGenerator());
        NHW_Org62Service.accessToken = 'dummytoken';
        List<Object> provisionings = ptService.getProvisionings();
        Set<String> dependencies = ptService.getDependencies();
        Test.stopTest();
        //assert correct training provisoning is returned;
        PF_NHW_TrainingProvisioningTypeService.TrainingProvisioning tp = (PF_NHW_TrainingProvisioningTypeService.TrainingProvisioning) provisionings[0];
        System.AssertEquals(tp.selectedvalue,'701Q0000000TzHDIA7');

    }
}