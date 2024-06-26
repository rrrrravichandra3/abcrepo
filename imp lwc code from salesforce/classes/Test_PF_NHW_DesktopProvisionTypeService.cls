@istest 
public class Test_PF_NHW_DesktopProvisionTypeService { 
    @testSetup 
    static void getNHWProvisionings() {
        Test_PF_NHW_ProvisioningTypeTestFactory.createNHWProvisionings();
    }
    
    @istest
    public static void validateDeskTopProvisioningsForNewHireType1() {       
    	Test.startTest();
        Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        provisioningCase.NHW_Organization__c = 'DummyValue';
        provisioningCase.NHW_Role__c = 'Other';
        
        //initialise Provisioning Type base class and service
        PF_NHW_ProvisioningType pt = PF_NHW_ProvisioningType.getProvisioningTypeByName('DESKTOP');	
        PF_NHW_ProvisioningTypeService ptService = pt.createService(provisioningCase);
        List<Object> provisionings = ptService.getProvisionings();
        Set<String> dependencies = ptService.getDependencies();
		Test.stopTest();
        
        System.assert(dependencies.size()==0);
        System.assert(provisionings.size()==3);
        System.assert((provisionings[0].toString().contains('Linux')||provisionings[0].toString().contains('Windows')||provisionings[0].toString().contains('Mac')));
		
    }
    
     @istest
    public static void validateDesktopProvisioningsForNewHireType2() {
        Test.startTest();
        Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        //update Organization and Role in Provisioning Case
        provisioningCase.NHW_Organization__c = 'Sales Support';
        provisioningCase.NHW_Role__c = 'Sales Strategy';
        provisioningCase.Office_Country__c = 'Hong Kong';
        //initialise Provisioning Type base class and service
        PF_NHW_ProvisioningType pt = PF_NHW_ProvisioningType.getProvisioningTypeByName('DESKTOP');	
        PF_NHW_ProvisioningTypeService ptService = pt.createService(provisioningCase);
        List<Object> provisionings = ptService.getProvisionings();
        Set<String> dependencies = ptService.getDependencies();
        Test.stopTest();
        
        System.assert(dependencies.size()==0);
        System.assert(provisionings.size()==3);
        System.assert((provisionings[0].toString().contains('Linux')||provisionings[0].toString().contains('Windows')||provisionings[0].toString().contains('Mac')));
		
		
    }
    
}