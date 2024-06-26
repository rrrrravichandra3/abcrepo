@isTest
private class Test_CompetencyGroupDetailController {
      
    public static testMethod void execute_methods_CompetencyGroupDetailController() {
        
        GenerateEnvironmentTest.genCompGroupTest();
        
        Test.setCurrentPageReference(new PageReference('Page.CompetencyGroupDetail'));

        Test.startTest();
 
		try {
	        CompetencyGroup__c oCompetencyGroup = new CompetencyGroup__c();
	        ApexPages.StandardController stdController = new ApexPages.StandardController(oCompetencyGroup);
	        CompetencyGroupDetailController controller = new CompetencyGroupDetailController(stdController);
	
	        oCompetencyGroup = GenerateEnvironmentTest.competencyGroup;
	        
	        CompetencyGroupMember__c competencyGroupMember0 = GenerateEnvironmentTest.createCompetencyGroupMember('Test Competency Group Member 0', 
	                                            'Test CGM 0', GenerateEnvironmentTest.competency.Id, 
	                                            oCompetencyGroup.Id, null);
	         
	        testController(oCompetencyGroup);
	                
	        CompetencyGroupMember__c competencyGroupMember60 = GenerateEnvironmentTest.createCompetencyGroupMember('Test Competency Group Member 60', 
	                                            'Test CGM 60', GenerateEnvironmentTest.competency.Id, 
	                                            oCompetencyGroup.Id, 60);
	        
	        testController(oCompetencyGroup);
	        
	        CompetencyGroupMember__c competencyGroupMember40 = GenerateEnvironmentTest.createCompetencyGroupMember('Test Competency Group Member 40', 
	                                            'Test CGM 40', GenerateEnvironmentTest.competency.Id, 
	                                            oCompetencyGroup.Id, 40);
	
	        testController(oCompetencyGroup);
	        
	        CompetencyGroupMember__c competencyGroupMember30 = GenerateEnvironmentTest.createCompetencyGroupMember('Test Competency Group Member 30', 
	                                            'Test CGM 30', GenerateEnvironmentTest.competency.Id, 
	                                            oCompetencyGroup.Id, 30);
	
	        testController(oCompetencyGroup).goToNewPage();
	        
        }catch(Exception e){
            System.debug(' ****************** Test_CompetencyGroupDetailController * ');
            System.debug(e.getMessage());
        }
        
        Test.stopTest();
        
    }

    public static testMethod void execute_methods_CompetencyGroupDetailController2() {
        
        GenerateEnvironmentTest.genCompGroupTest();
        
        Test.setCurrentPageReference(new PageReference('Page.CompetencyGroupDetail'));
        
        System.runAs(GenerateEnvironmentTest.employeeStandard){
        	
            Test.startTest();
            
            try {
	            CompetencyGroup__c oCompetencyGroup = new CompetencyGroup__c();
	            ApexPages.StandardController stdController = new ApexPages.StandardController(oCompetencyGroup);
	            CompetencyGroupDetailController controller = new CompetencyGroupDetailController(stdController);
	     
	            oCompetencyGroup = GenerateEnvironmentTest.competencyGroup;
	            
	            CompetencyGroupMember__c competencyGroupMember0 = GenerateEnvironmentTest.createCompetencyGroupMember('Test Competency Group Member 0', 
	                                                'Test CGM 0', GenerateEnvironmentTest.competency.Id, 
	                                                oCompetencyGroup.Id, null);
	            
	            testController(oCompetencyGroup);
		        
	        }catch(Exception e){
	            System.debug(' ****************** Test_CompetencyGroupDetailController * ');
	            System.debug(e.getMessage());
	        }
                                
            Test.stopTest();
            
        } 
    }
     
    public static CompetencyGroupDetailController testController(CompetencyGroup__c cg){
        
        CompetencyGroupDetailController controllerFromCompGroup;
        
        try {
        	
	        ApexPages.StandardController stdController = new ApexPages.StandardController(cg);
	        CompetencyGroupDetailController controllerFromStd = new CompetencyGroupDetailController(stdController);
	        controllerFromCompGroup = new CompetencyGroupDetailController(cg);
	        controllerFromCompGroup.saveListAndCheckSum();
	        controllerFromCompGroup.getShowMembers();
	        controllerFromCompGroup.getMsg();
	        controllerFromCompGroup.getCompetencyGroup();
	        controllerFromCompGroup.getCompetencyGroupMembers();
		        
        }catch(Exception e){
            System.debug(' ****************** Test_CompetencyGroupDetailController * ');
            System.debug(e.getMessage());
        }
        
        return controllerFromCompGroup;
    }
   
}