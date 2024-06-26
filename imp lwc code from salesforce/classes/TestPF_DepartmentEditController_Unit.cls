/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestPF_DepartmentEditController_Unit {

       
    public static testMethod void execute_methods_DepartmentEdit() {
        
        GenerateEnvironmentTest.genDepartmentTest();
        
        Test.startTest();
          
        try {
	        Test.setCurrentPageReference(new PageReference('Page.DepartmentEdit'));
	        
	        //Department__c dept = GenerateEnvironmentTest.department;
	        TF2_Department__c dept = GenerateEnvironmentTest.department;
	        
	        ApexPages.StandardController std = new ApexPages.StandardController(dept);
	
	        DepartmentEditController controller = new DepartmentEditController(std);
	        
	        controller.getDepartment();
	        controller.save();
	        controller.saveAndNew();
	        controller.getIdPrefix();
	        controller.getUsers();
        }catch(Exception e){
            System.debug(' ****************** Test_DepartmentEditController * ');
            System.debug(e.getMessage());
        }
        
        Test.stopTest();
        
    }

}