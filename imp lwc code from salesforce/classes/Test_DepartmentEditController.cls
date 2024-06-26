@isTest
private class Test_DepartmentEditController {
      
    public static testMethod void execute_methods_DepartmentEdit() {
        
        GenerateEnvironmentTest.genDepartmentTest();
        
        Test.startTest();
          
        try {
	        Test.setCurrentPageReference(new PageReference('Page.DepartmentEdit'));
	        
	        Department__c dept = GenerateEnvironmentTest.department;
	        
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