@isTest
public class Test_PF_NHW_VDIProvisionTypeService {
    @testSetup 
    static void getNHWProvisionings() {
        Test_PF_NHW_ProvisioningTypeTestFactory.createNHWProvisionings();
    }
    @istest
    public static void validateVDIProvisioningsForNewHireType() {
    	Test.startTest();
        Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        provisioningCase.NHW_Organization__c = 'CSG';
        provisioningCase.NHW_Role__c = 'Other';
		provisioningCase.Office_Country__c = 'India';        
        //initialise Provisioning Type base class and service
        PF_NHW_ProvisioningType pt = PF_NHW_ProvisioningType.getProvisioningTypeByName('VDI');	
        PF_NHW_ProvisioningTypeService ptService = pt.createService(provisioningCase);
        List<Object> provisionings = ptService.getProvisionings();
        Set<String> dependencies = ptService.getDependencies();
        Test.stopTest();
        System.assert(dependencies.size()==0);
        System.assert(provisionings.size()==22);
        System.assert((provisionings[0].toString().contains('Congnizant')||provisionings[0].toString().contains('Accenture')));		
		
    }
    

}