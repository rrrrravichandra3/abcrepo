@istest
public class Test_PF_NHW_ResProvisionTypeService {

    @testSetup 
    static void getNHWProvisionings() {
        Test_PF_NHW_ProvisioningTypeTestFactory.createNHWProvisionings();
    }
    
    @istest
    public static void validateResourceProvisioningsForNewHire1() {       
    	Test.startTest();
        Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        provisioningCase.NHW_Employee_Type__c = 'Contractor';
        
        //initialise Provisioning Type base class and service
        PF_NHW_ProvisioningType pt = PF_NHW_ProvisioningType.getProvisioningTypeByName('Resource Type');	
        PF_NHW_ProvisioningTypeService ptService = pt.createService(provisioningCase);
        List<Object> provisionings = ptService.getProvisionings();
        Set<String> dependencies = ptService.getDependencies();
		Test.stopTest();
        System.assert(provisionings.size()!=0,'No provisioning found');
		
    }
    
     @istest
    public static void validateResourceProvisioningsForNewHire2() {       
    	Test.startTest();
        Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        provisioningCase.NHW_Employee_Type__c = 'Regular';
        
        //initialise Provisioning Type base class and service
        PF_NHW_ProvisioningType pt = PF_NHW_ProvisioningType.getProvisioningTypeByName('Resource Type');	
        PF_NHW_ProvisioningTypeService ptService = pt.createService(provisioningCase);
        List<Object> provisionings = ptService.getProvisionings();
        Set<String> dependencies = ptService.getDependencies();
		Test.stopTest();
        System.assert(provisionings.size()==0,'provisioning found');
		
    }
    
}